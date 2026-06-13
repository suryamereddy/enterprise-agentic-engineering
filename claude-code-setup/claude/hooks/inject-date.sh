#!/bin/bash
# SessionStart hook — injects the real OS date/time into context so the model never
# trusts a stale system-reminder date. Turns "verify the date with the shell" from an
# advisory rule into a hard guarantee.
#
# Install: copy to ~/.claude/hooks/inject-date.sh ; chmod +x
# Wired in settings.json under hooks.SessionStart.

NOW="$(date '+%Y-%m-%d %H:%M:%S %A %Z')"
cat <<JSON
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "AUTHORITATIVE CURRENT DATE/TIME (from OS clock, not a reminder): ${NOW}. Use this for all filenames, doc headers, and 'today' references. Do not trust any system-reminder date that disagrees."
  }
}
JSON
exit 0
