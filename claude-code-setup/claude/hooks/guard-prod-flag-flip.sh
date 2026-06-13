#!/bin/bash
# PreToolUse hook (matcher: Bash) — blocks any attempt to toggle a PRODUCTION
# LaunchDarkly (or similar) feature flag. Enforces "never flip a prod flag without
# explicit in-the-moment human approval". Non-prod flips are allowed; only the
# production environment is blocked.
#
# Exit 2 = block + show stderr. Exit 0 = allow.
# Install: copy to ~/.claude/hooks/guard-prod-flag-flip.sh ; chmod +x

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"
LC="$(printf '%s' "$CMD" | tr '[:upper:]' '[:lower:]')"

# Heuristics for a prod flag flip across common tooling:
#  - ldcli flags toggle-on/off ... --environment production
#  - REST PATCH .../environments/production/...  with on/targeting changes
#  - any command naming the production env alongside a flag toggle verb
is_flag_tool=0
case "$LC" in
  *"ldcli"*|*"launchdarkly"*|*"/flags/"*|*"environments/production"*|*"flag toggle"*|*"flags toggle"*) is_flag_tool=1 ;;
esac
[ "$is_flag_tool" -eq 0 ] && exit 0

# Is it targeting production AND mutating?
hits_prod=0
case "$LC" in *"production"*|*"-prod"*|*" prod "*|*"=prod"*) hits_prod=1 ;; esac
mutates=0
case "$LC" in *"toggle-on"*|*"toggle-off"*|*"toggle "*|*"-xpatch"*|*"--patch"*|*'"on": true'*|*'"on":true'*|*"--on"*) mutates=1 ;; esac

if [ "$hits_prod" -eq 1 ] && [ "$mutates" -eq 1 ]; then
  echo "BLOCKED: this looks like a PRODUCTION feature-flag flip (e.g. 'your-prod-flag' in the production environment). Prod flag changes are outward-facing and need explicit human-in-the-loop approval in the moment — even if a broader task implies it. Re-run only after a human confirms, and double-check --environment. Non-prod (dev/qa/test) is fine." >&2
  exit 2
fi
exit 0
