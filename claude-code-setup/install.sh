#!/usr/bin/env bash
# Enterprise Agentic Engineering — operational harness installer.
# Installs the runnable Claude Code baseline (CLAUDE.md, settings, hooks, skills,
# secret-scanner) into ~/.claude/, and the repo's reviewer agents from ../agents/claude/.
# SAFE: backs up anything it would overwrite first. Re-runnable.
#
#   bash claude-code-setup/install.sh
#
set -euo pipefail
HARNESS="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HARNESS/.." && pwd)"
DEST="$HOME/.claude"
STAMP="$(date '+%Y%m%d-%H%M%S')"
BK="$DEST/_pre-harness-backup-$STAMP"

echo "== Enterprise Agentic Engineering — harness installer =="
echo "  repo: $REPO"
echo "  dest: $DEST"
mkdir -p "$DEST"

# 1) Back up anything we will touch
echo "-- backing up existing config -> $BK"
mkdir -p "$BK"
for p in CLAUDE.md settings.json hooks agents skills git-hooks; do
  [ -e "$DEST/$p" ] && cp -R "$DEST/$p" "$BK/" && echo "   backed up $p"
done
git config --global --get core.hooksPath > "$BK/old-global-hookspath.txt" 2>/dev/null || echo "(none)" > "$BK/old-global-hookspath.txt"

# 2) Deploy the harness payload
echo "-- deploying CLAUDE.md, settings.json, hooks, git-hooks, skills"
echo "   NOTE: settings.json is OVERWRITTEN (backup above) — merge custom perms back if needed."
cp "$HARNESS/claude/CLAUDE.md"     "$DEST/CLAUDE.md"
cp "$HARNESS/claude/settings.json" "$DEST/settings.json"
mkdir -p "$DEST/hooks" "$DEST/skills" "$DEST/git-hooks" "$DEST/agents"
cp -R "$HARNESS/claude/hooks/."     "$DEST/hooks/"
cp -R "$HARNESS/claude/skills/."    "$DEST/skills/"
cp -R "$HARNESS/claude/git-hooks/." "$DEST/git-hooks/"
chmod +x "$DEST/hooks/"*.sh 2>/dev/null || true
chmod +x "$DEST/git-hooks/pre-commit" 2>/dev/null || true

# 3) Install the reviewer agents (single source of truth: ../agents/claude/)
echo "-- installing reviewer agents from $REPO/agents/claude/"
cp "$REPO/agents/claude/"*.md "$DEST/agents/" 2>/dev/null && \
  echo "   $(ls "$REPO/agents/claude/"*.md | wc -l | xargs) agents installed" || \
  echo "   (no agents/claude/*.md found)"

# 4) Wire the global git secret-scanner
EXISTING_HP="$(git config --global --get core.hooksPath || true)"
if [ -n "$EXISTING_HP" ] && [ "$EXISTING_HP" != "$DEST/git-hooks" ]; then
  echo "!! git core.hooksPath already set to: $EXISTING_HP — NOT overwriting."
  echo "   To enable the secret scanner, point it at $DEST/git-hooks or merge the pre-commit logic."
else
  git config --global core.hooksPath "$DEST/git-hooks"
  echo "-- git core.hooksPath -> $DEST/git-hooks (secret scanner active)"
fi

# 5) Optionally seed the memory/status scaffold for a project
echo
read -r -p "Seed the memory + status scaffold for a project? Enter its path (blank to skip): " PROJ || true
if [ -n "${PROJ:-}" ]; then
  PROJ_ABS="$(cd "$PROJ" 2>/dev/null && pwd || echo "$PROJ")"
  ENC="$(printf '%s' "$PROJ_ABS" | sed 's#/#-#g')"
  MEMDIR="$DEST/projects/$ENC/memory"; STATUSDIR="$DEST/projects/$ENC/status"
  if [ -d "$MEMDIR" ] && [ -n "$(ls -A "$MEMDIR" 2>/dev/null)" ]; then
    echo "!! $MEMDIR already non-empty — NOT overwriting your memories."
  else
    mkdir -p "$MEMDIR" "$STATUSDIR"
    cp "$HARNESS/claude-memory-template/"*.md "$MEMDIR/"
    cp "$HARNESS/claude-memory-template/status/"*.md "$STATUSDIR/"
    echo "-- seeded memory -> $MEMDIR  (delete the _EXAMPLE-*.md once read)"
  fi
fi

mkdir -p "$HOME/agent-plans"

cat <<DONE

== Done. Backup at: $BK ==

NEXT STEPS:
  1. RESTART Claude Code (agents/hooks/settings load at session start). Then /agents.
  2. Fill in your creds:   ~/.claude/skills/creds-index/SKILL.md
  3. Add known secret literals to: ~/.claude/git-hooks/secret-patterns.txt
  4. Set your model:  /config
  5. Read claude-code-setup/CUSTOMIZE.md and docs/operational-harness.md.

To revert: restore from $BK and run
  git config --global core.hooksPath "$(cat "$BK/old-global-hookspath.txt")"
DONE
