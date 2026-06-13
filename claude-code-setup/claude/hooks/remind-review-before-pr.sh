#!/bin/bash
# PreToolUse hook (matcher: Bash) — a SINGLE soft reminder at the PR boundary.
# Fires only on `gh pr create` (the meaningful gate), NOT on every commit and NOT
# on every "done" claim. Does NOT spawn agents and does NOT block — it asks once
# whether the pre-ship review ran. Cheap: one grep, no model calls.
#
# Install: ~/.claude/hooks/remind-review-before-pr.sh ; chmod +x ; wire into PreToolUse matcher "Bash"

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
case "$CMD" in
  *"gh pr create"*) ;;
  *) exit 0 ;;
esac

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "Opening a PR — did you run /done-check for this change? (real-data verify + adversarial review SCALED to the diff: 0-1 reviewer for small/low-risk, up to 3 for large/prod-touching/contract). If yes, proceed. One-time reminder at the PR boundary, not a block."
  }
}
JSON
exit 0
