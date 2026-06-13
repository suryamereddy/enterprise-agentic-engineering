#!/bin/bash
# Stop hook (fires ONCE when the turn finishes) — formats the .cs files this turn
# changed, in one pass, at the turn boundary. This is an EXAMPLE of doing batch work
# at the Stop boundary rather than per-edit: a per-edit (PostToolUse: Write|Edit|
# MultiEdit) variant would run `dotnet format` (2-5s Roslyn/MSBuild load) on EVERY
# .cs edit (20-50s across a refactor), violating the ">1-2s is a signal" rule, and
# rewrite files under the agent which can break a follow-up exact-match Edit. Running
# once at Stop avoids all of that.
# Non-blocking: formatting issues warn only; they never stop the turn.
#
# Wire (settings.json):
#   "Stop": [ { "hooks": [ { "type":"command", "command":"~/.claude/hooks/stop-dotnet-format.sh" } ] } ]

INPUT="$(cat)"
CWD="$(printf '%s' "$INPUT" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("cwd",""))' 2>/dev/null)"
[ -n "$CWD" ] && cd "$CWD" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Changed .cs files in the working tree (staged + unstaged), repo-relative -> absolute.
# Use git diff --name-only (handles renames/spaces correctly) instead of porcelain+$NF,
# which mangled `R old -> new` lines and quoted paths-with-spaces.
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
mapfile -t CS < <( { git -C "$ROOT" diff --name-only --diff-filter=ACMR 2>/dev/null; \
                     git -C "$ROOT" diff --cached --name-only --diff-filter=ACMR 2>/dev/null; } \
  | sort -u | grep -i '\.cs$' | sed "s|^|$ROOT/|")
[ "${#CS[@]}" -eq 0 ] && exit 0

DOTNET="dotnet"; [ -x "$HOME/.dotnet/dotnet" ] && DOTNET="$HOME/.dotnet/dotnet"
command -v "$DOTNET" >/dev/null 2>&1 || exit 0

# Group changed files by their owning .csproj, format each project's set in one call.
declare -A BYPROJ
for f in "${CS[@]}"; do
  [ -f "$f" ] || continue
  d="$(dirname "$f")"; proj=""
  while [ "$d" != "/" ]; do
    proj="$(find "$d" -maxdepth 1 -name '*.csproj' 2>/dev/null | head -1)"
    [ -n "$proj" ] && break; d="$(dirname "$d")"
  done
  [ -n "$proj" ] && BYPROJ["$proj"]+=" --include $f"
done

WARN=""
for proj in "${!BYPROJ[@]}"; do
  OUT="$("$DOTNET" format "$proj" ${BYPROJ[$proj]} --no-restore 2>&1)" || \
    WARN="$WARN $(basename "$proj"): $(printf '%s' "$OUT" | tail -1)"
done

[ -n "$WARN" ] && cat <<JSON
{ "hookSpecificOutput": { "hookEventName": "Stop", "additionalContext": "dotnet format ran on changed .cs files at turn end (non-blocking). Notes:$(printf '%s' "$WARN" | cut -c1-300)" } }
JSON
exit 0
