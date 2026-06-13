#!/bin/bash
# PreToolUse hook (matcher: Bash) — blocks `git push` to a branch whose PR is
# already MERGED or CLOSED, which would strand the commit (squash-merge orphan).
# Enforces "check PR status before pushing" as a hard stop.
#
# Reads the tool call JSON on stdin: {"tool_name":"Bash","tool_input":{"command":"..."}}
# Exit 2 = block + show stderr to the model. Exit 0 = allow.
#
# Install: copy to ~/.claude/hooks/guard-merged-pr-push.sh ; chmod +x
# Requires: gh CLI authenticated.

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"

# Only act on git push commands
case "$CMD" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

# Resolve current branch
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
[ -z "$BRANCH" ] && exit 0
[ "$BRANCH" = "main" ] && exit 0   # pushing main directly is governed elsewhere

# Find a PR for this branch and check its state (gh; fail-open if gh unavailable)
STATE="$(gh pr view "$BRANCH" --json state --jq '.state' 2>/dev/null)"
[ -z "$STATE" ] && exit 0   # no PR found or gh not available -> don't block

if [ "$STATE" = "MERGED" ] || [ "$STATE" = "CLOSED" ]; then
  echo "BLOCKED: branch '$BRANCH' has a PR in state $STATE. A push here will strand the commit (squash-merge orphan — it won't reach main). Branch fresh off origin/main and open a new PR instead." >&2
  exit 2
fi
exit 0
