#!/usr/bin/env bash
# copilot-dev-kit installer — scaffolds the Copilot baseline into a TARGET REPO.
# (Copilot customization is repo-level, not user-global.) Backs up anything it overwrites.
#
#   bash install.sh [path-to-repo]      # defaults to current directory
#
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
REPO="${1:-$PWD}"
REPO="$(cd "$REPO" && pwd)"
STAMP="$(date '+%Y%m%d-%H%M%S')"

echo "== copilot-dev-kit installer =="
echo "  kit:  $KIT"
echo "  repo: $REPO"
[ -d "$REPO/.git" ] || echo "  (warning: $REPO is not a git repo root — the pre-commit hook won't install)"

bk(){ if [ -e "$1" ]; then cp -R "$1" "$1.pre-kit-$STAMP.bak" && echo "   backed up $(basename "$1")"; fi; return 0; }

# 1) .github/ — instructions, prompts, agents, instruction-files, workflow, secret patterns
mkdir -p "$REPO/.github/prompts" "$REPO/.github/instructions" "$REPO/.github/agents" "$REPO/.github/workflows"
bk "$REPO/.github/copilot-instructions.md"
cp "$KIT/github/copilot-instructions.md" "$REPO/.github/"
cp "$KIT/github/secret-patterns.txt"     "$REPO/.github/"
cp "$KIT/github/prompts/"*.md            "$REPO/.github/prompts/"
cp "$KIT/github/instructions/"*.md        "$REPO/.github/instructions/"
cp "$KIT/github/agents/"*.md              "$REPO/.github/agents/"
cp "$KIT/github/workflows/pre-ship-check.yml" "$REPO/.github/workflows/"
echo "-- .github/ scaffolded (copilot-instructions, prompts, agents, instructions, workflow, secret-patterns)"

# 2) AGENTS.md at repo root
bk "$REPO/AGENTS.md"; cp "$KIT/AGENTS.md" "$REPO/AGENTS.md"
echo "-- AGENTS.md at repo root"

# 3) .vscode/settings.json (don't clobber — drop alongside if one exists)
mkdir -p "$REPO/.vscode"
if [ -f "$REPO/.vscode/settings.json" ]; then
  cp "$KIT/vscode/settings.json" "$REPO/.vscode/settings.copilot-dev-kit.json"
  echo "!! .vscode/settings.json exists — wrote settings.copilot-dev-kit.json instead; MERGE the keys manually."
else
  cp "$KIT/vscode/settings.json" "$REPO/.vscode/settings.json"
  echo "-- .vscode/settings.json (commit/review/PR instruction wiring)"
fi

# 4) git pre-commit secret scanner (repo-local)
if [ -d "$REPO/.git" ]; then
  HOOK="$REPO/.git/hooks/pre-commit"
  bk "$HOOK"; cp "$KIT/git-hooks/pre-commit" "$HOOK"; chmod +x "$HOOK"
  echo "-- .git/hooks/pre-commit installed (secret scanner)"
  GHP="$(git config --global --get core.hooksPath || true)"
  if [ -n "$GHP" ]; then
    echo "!! WARNING: a global core.hooksPath ($GHP) is set — it OVERRIDES this repo-local"
    echo "   pre-commit, so the hook above will NOT run. Either add the secret-scan logic to"
    echo "   $GHP/pre-commit, or rely on the CI workflow + GitHub push protection (recommended)."
  fi
fi

# 5) deliverables/status dirs (+ seed the discipline READMEs if absent)
mkdir -p "$REPO/docs/status" "$REPO/docs/handoffs"
[ -f "$REPO/docs/status/README.md" ]   || cp "$KIT/docs/status/README.md"   "$REPO/docs/status/README.md"
[ -f "$REPO/docs/handoffs/README.md" ] || cp "$KIT/docs/handoffs/README.md" "$REPO/docs/handoffs/README.md"
echo "-- docs/status/ + docs/handoffs/ scaffolded (durable-vs-volatile discipline)"

cat <<DONE

== Done. ==

NEXT STEPS:
  1. Fill in <…> in .github/copilot-instructions.md (tech stack, conventions).
  2. Add your literal secret strings to .github/secret-patterns.txt.
  3. In Chat, run a prompt:  /done-check  ·  /adversarial-review  ·  /diagnose
     ...and pick a reviewer agent from the agents dropdown (adversarial-reviewer,
     security-auditor, performance-engineer, prod-data-verifier).
  4. Commit the .github/ files so teammates + the Copilot coding agent pick them up.
  5. Turn on GitHub-native enforcement (recommended):
       # secret scanning push protection (public repos free; private needs Advanced Security):
       gh api -X PATCH repos/{owner}/{repo} -F security_and_analysis='{"secret_scanning_push_protection":{"status":"enabled"}}'
       # then make "Pre-ship check" a REQUIRED status check via a branch protection rule / ruleset.

NOTE: VS Code's codeGeneration/testGeneration instruction settings are deprecated —
this kit uses .github/instructions/*.instructions.md instead (works in VS Code/JetBrains/CLI).
Path-specific instruction files do NOT apply on github.com Chat — AGENTS.md +
copilot-instructions.md cover that surface.
DONE
