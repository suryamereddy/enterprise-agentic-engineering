#!/bin/bash
# PreToolUse hook (matcher: Bash) — blocks `git add` / `git commit` when the
# staged/working content matches a known secret pattern. Earlier + agent-facing
# complement to a global git pre-commit hook (which catches ALL commits).
# Exit 2 = block + show stderr to the model. Exit 0 = allow.
#
# Install: copy to ~/.claude/hooks/guard-secret-commit.sh ; chmod +x
# Wire into settings.json hooks.PreToolUse (matcher "Bash").
# Reuses ~/.claude/git-hooks/secret-patterns.txt.

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
case "$CMD" in
  *"git add"*|*"git commit"*) ;;
  *) exit 0 ;;
esac

PATTERNS="$HOME/.claude/git-hooks/secret-patterns.txt"
[ -f "$PATTERNS" ] || exit 0

# Look at what would be committed: STAGED diff only (an unrelated unstaged secret must
# not block an innocent commit — the global pre-commit hook is also cached-only).
# Lines explicitly marked `pragma: allowlist secret` are a sanctioned FP escape valve
# (so a confirmed false positive never forces --no-verify, which is banned).
CONTENT="$(git diff --cached --no-color 2>/dev/null | grep -v 'pragma: allowlist secret')"
[ -z "$CONTENT" ] && exit 0

while IFS= read -r pat; do
  case "$pat" in ''|\#*) continue ;; esac
  if printf '%s' "$CONTENT" | grep -E -i -q -- "$pat"; then
    echo "BLOCKED: a secret matching a known pattern is in the staged/working changes — do not commit it. Remove the credential (use a secrets manager / Key Vault reference or env var), then re-stage. Patterns: ~/.claude/git-hooks/secret-patterns.txt." >&2
    exit 2
  fi
done < "$PATTERNS"
exit 0
