#!/bin/bash
# PreToolUse hook (matcher: Write) — warns when a plan/report/analysis .md is being
# written OUTSIDE an agent-plans/ directory. Enforces the "deliverables go to
# agent-plans/" convention. Non-blocking by default (asks), since some .md genuinely
# belongs in a repo (docs/, README). Flip the `exit 0`->`exit 2` to hard-block.
#
# Install: ~/.claude/hooks/redirect-agentplans-path.sh ; chmod +x ; wire into PreToolUse matcher "Write"

INPUT="$(cat)"
read -r TOOL PATHV <<EOF
$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d.get("tool_name",""), d.get("tool_input",{}).get("file_path",""))' 2>/dev/null)
EOF
[ "$TOOL" = "Write" ] || exit 0
case "$PATHV" in *.md) ;; *) exit 0 ;; esac
# Already in agent-plans? fine.
case "$PATHV" in */agent-plans/*) exit 0 ;; esac
# Does the filename look like a deliverable (plan/report/analysis/etc.)?
base="$(basename "$PATHV" | tr '[:upper:]' '[:lower:]')"
case "$base" in
  *plan*|*report*|*analysis*|*findings*|*summary*|*audit*|*proposal*|*comparison*|*review*)
    cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "This looks like a deliverable ($base) being written OUTSIDE an agent-plans/ directory. By convention, reports/plans/analyses go to \$HOME/agent-plans/YYYY-MM-DD-<slug>.md. If this is genuinely repo docs (docs/, README), allow it; otherwise redirect to agent-plans."
  }
}
JSON
    exit 0 ;;
esac
exit 0
