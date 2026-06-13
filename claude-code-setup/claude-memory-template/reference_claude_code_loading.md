---
name: reference_claude_code_loading
description: "Claude Code loads agents/hooks/settings at SESSION START — after editing them on disk you must restart the session; agents created via /agents UI apply immediately"
metadata:
  node_type: memory
  type: reference
---

**Claude Code loads subagents, hooks, and `settings.json` at SESSION START.** If you add/edit those files directly on disk (e.g. via `cp`/an installer), the running session does NOT pick them up — `/agents` shows empty and the agent isn't invocable. **Fix: restart the session.** Agents created through the `/agents` *UI* apply immediately without restart. (Confirmed Claude Code v2.1.x, docs code.claude.com/docs/en/sub-agents and /hooks.)

**Agent locations & scope:**
- User-level: `~/.claude/agents/*.md` — available in every session.
- Project-level: `<repo>/.claude/agents/*.md` — available only when the session's project is that repo. Keep repo-specific reviewers project-scoped (a global one would misfire on other repos).

**Valid agent frontmatter** (none cause silent-skip): `name` (req, lowercase-hyphen), `description` (req), `tools` (comma string OR YAML list both work), `model` (incl. `inherit` — the default), `permissionMode` (`default|acceptEdits|auto|dontAsk|bypassPermissions|plan`). Silent-skip causes: missing name/description, malformed YAML, duplicate `name`, or wrong file extension.

**Hook output schema:** every hook that prints JSON must include `hookSpecificOutput.hookEventName` equal to the exact event (`SessionStart|PreToolUse|PostToolUse|Stop`). PreToolUse "ask" uses `permissionDecision` + `permissionDecisionReason` (not `systemMessage`). `PostToolUse` fires only on tool SUCCESS — a failed Bash command does not fire it. Exit 0 + empty stdout is a valid no-op.

Related: [[feedback_memory_hygiene]].
