#!/usr/bin/env bash
# copilot-dev-kit installer. Two modes (combine them):
#
#   bash install.sh <repo>            # REPO-LEVEL: scaffolds the repo's .github/ (for the team/that repo)
#   bash install.sh --user-global     # USER-GLOBAL: installs principles + prompts + agents into
#                                      #   ~/.copilot/ so they apply to EVERY repo / all your work (like ~/.claude)
#   bash install.sh <repo> --user-global   # both
#
# Backs up anything it overwrites.
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date '+%Y%m%d-%H%M%S')"
bk(){ if [ -e "$1" ]; then cp -R "$1" "$1.pre-kit-$STAMP.bak" && echo "   backed up $(basename "$1")"; fi; return 0; }

USERGLOBAL=0; REPO=""
for a in "$@"; do case "$a" in --user-global|--user) USERGLOBAL=1;; -*) ;; *) REPO="$a";; esac; done
[ -z "$REPO" ] && [ $USERGLOBAL -eq 0 ] && REPO="$PWD"   # no args -> repo-install the current dir

echo "== copilot-dev-kit installer =="
echo "  kit: $KIT"

# ============ USER-GLOBAL (~/.copilot) — applies to EVERY repo ============
if [ $USERGLOBAL -eq 1 ]; then
  CO="$HOME/.copilot"
  echo "-- USER-GLOBAL install -> $CO/  (applies to all your Copilot work)"
  mkdir -p "$CO/instructions" "$CO/prompts" "$CO/agents"
  cp "$KIT/user-global/instructions/"*.md "$CO/instructions/"   # 00-principles (always-on)
  cp "$KIT/github/instructions/"*.md       "$CO/instructions/"   # scoped security / json rules
  cp "$KIT/github/prompts/"*.md            "$CO/prompts/"
  cp "$KIT/github/agents/"*.md             "$CO/agents/"
  echo "   ~/.copilot/instructions/ (principles + scoped) · prompts/ · agents/ — apply in every repo (Copilot CLI)"
  echo "   VS Code: point chat.instructionsFilesLocations / promptFilesLocations at your user profile to match."
fi

# ============ REPO-LEVEL (.github) — for the team / that repo ============
if [ -n "$REPO" ]; then
  REPO="$(cd "$REPO" && pwd)"
  echo "-- REPO install -> $REPO/.github/"
  [ -d "$REPO/.git" ] || echo "   (warning: $REPO is not a git repo root — the pre-commit hook won't install)"
  mkdir -p "$REPO/.github/prompts" "$REPO/.github/instructions" "$REPO/.github/agents" "$REPO/.github/workflows"
  bk "$REPO/.github/copilot-instructions.md"
  cp "$KIT/github/copilot-instructions.md" "$REPO/.github/"
  cp "$KIT/github/secret-patterns.txt"     "$REPO/.github/"
  cp "$KIT/github/prompts/"*.md            "$REPO/.github/prompts/"
  cp "$KIT/github/instructions/"*.md        "$REPO/.github/instructions/"
  cp "$KIT/github/agents/"*.md              "$REPO/.github/agents/"
  cp "$KIT/github/workflows/pre-ship-check.yml" "$REPO/.github/workflows/"
  bk "$REPO/AGENTS.md"; cp "$KIT/AGENTS.md" "$REPO/AGENTS.md"
  mkdir -p "$REPO/.vscode"
  if [ -f "$REPO/.vscode/settings.json" ]; then
    cp "$KIT/vscode/settings.json" "$REPO/.vscode/settings.copilot-dev-kit.json"
    echo "   !! .vscode/settings.json exists — wrote settings.copilot-dev-kit.json; MERGE the keys."
  else
    cp "$KIT/vscode/settings.json" "$REPO/.vscode/settings.json"
  fi
  if [ -d "$REPO/.git" ]; then
    HOOK="$REPO/.git/hooks/pre-commit"; bk "$HOOK"; cp "$KIT/git-hooks/pre-commit" "$HOOK"; chmod +x "$HOOK"
    GHP="$(git config --global --get core.hooksPath || true)"
    [ -n "$GHP" ] && echo "   !! global core.hooksPath ($GHP) OVERRIDES the repo pre-commit — rely on CI + push protection."
  fi
  mkdir -p "$REPO/docs/status" "$REPO/docs/handoffs"
  [ -f "$REPO/docs/status/README.md" ]   || cp "$KIT/docs/status/README.md"   "$REPO/docs/status/README.md"
  [ -f "$REPO/docs/handoffs/README.md" ] || cp "$KIT/docs/handoffs/README.md" "$REPO/docs/handoffs/README.md"
  echo "   .github/ (instructions, prompts, agents, workflow, secret-patterns) + AGENTS.md + .vscode + docs/"
fi

cat <<DONE

== Done. ==
- REPO-LEVEL files apply in that repo + its PRs (teammates, the coding agent, github.com).
- USER-GLOBAL files (~/.copilot) apply to EVERY repo you work in via Copilot CLI — your personal baseline.
  (Run with --user-global on each of your machines; it's the Copilot equivalent of ~/.claude.)

NEXT:
  1. Fill in <…> in the principles / copilot-instructions (tech stack, conventions).
  2. Add your secret literals to secret-patterns.txt (repo) — and personal creds to ~/.copilot/prompts/creds-index.prompt.md.
  3. In Chat: /done-check · /adversarial-review · /diagnose ; pick a reviewer from the agents dropdown.
  4. Turn on GitHub push protection + make "Pre-ship check" a required status check.
DONE
