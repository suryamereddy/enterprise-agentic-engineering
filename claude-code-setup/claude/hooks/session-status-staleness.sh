#!/bin/bash
# SessionStart hook — scans every project's status files (~/.claude/projects/*/status/*.md)
# and, if any carry a `_last updated: YYYY-MM-DD` older than the threshold, injects a
# one-line reminder. Catches the "I forgot to update the status file" failure that a
# memory/status split exists to prevent. Non-blocking, silent when nothing is stale.
# macOS (BSD) date.
#
# Wire (settings.json): add to the SessionStart hooks array alongside inject-date.sh.

THRESHOLD_DAYS=14

NOW="$(date +%s)"
STALE=""
for f in "$HOME"/.claude/projects/*/status/*.md; do
  [ -f "$f" ] || continue
  case "$(basename "$f")" in README.md) continue ;; esac
  d="$(grep -m1 -oE '_last updated: [0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" 2>/dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')"
  [ -z "$d" ] && continue
  then_s="$(date -j -f '%Y-%m-%d' "$d" +%s 2>/dev/null)" || continue
  age=$(( (NOW - then_s) / 86400 ))
  if [ "$age" -gt "$THRESHOLD_DAYS" ]; then
    STALE="$STALE $(basename "$f" .md)(${age}d)"
  fi
done

[ -z "$STALE" ] && exit 0

cat <<JSON
{ "hookSpecificOutput": { "hookEventName": "SessionStart", "additionalContext": "Stale project status (>${THRESHOLD_DAYS}d since _last updated_):$STALE. If you touch one of these efforts, re-verify its live state and refresh its status/<slug>.md (run \`date\`). Durable rules in the matching memory are still good; only the status snapshot is old." } }
JSON
exit 0
