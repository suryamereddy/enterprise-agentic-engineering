---
name: feedback_memory_hygiene
description: "Keep memory files durable-only; volatile project status (PR#s, rollout, counts) goes to the status/ sibling folder, not memory and not agent-plans"
metadata:
  node_type: memory
  type: feedback
---

**Memory files hold DURABLE facts only. Volatile status goes to `status/`.**

**Why:** memory is auto-recalled into context (MEMORY.md every session + topic files on relevance). Status that goes stale — PR numbers, "awaiting <person>", rollout progress, dated counts, branch/stash state — then gets fed back as if current. Splitting them keeps recall sharp.

**How to apply:**
- **Durable → memory** (`~/.claude/projects/<project>/memory/<slug>.md`): the rule, lesson, landmine, design fact, config coordinate. Keep ≤ ~1 screen.
- **Volatile → status** (`~/.claude/projects/<project>/status/<slug>.md`): a stable file updated in place (NOT dated snapshots — those go to `agent-plans/`; NOT a memory file — it must never be auto-recalled). First line `_last updated: YYYY-MM-DD_` (run `date`).
- End every project memory with: `Live status → ~/.claude/projects/<project>/status/<slug>.md`.
- `status/` lives under `~/.claude` (never a git repo) → not committable, unlike `agent-plans/` which is for shareable deliverables.

Also enforced as a standing rule in the global CLAUDE.md ("Output conventions"). See [[reference_claude_code_loading]].
