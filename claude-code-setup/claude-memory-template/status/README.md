# status/ — living project status (NOT memory, NOT a deliverable)

Companion to `../memory/`. Holds the **volatile** half of project knowledge — PR numbers, rollout progress, "awaiting X", dated counts, branch/stash state — that goes stale fast.

## Why this folder exists
- **Memory files (`../memory/`) are auto-recalled into context.** Stale status in a memory file = stale facts fed into context. So memory holds ONLY durable, evergreen rules.
- **This folder is NOT part of the memory system** → never auto-recalled. It's read deliberately, by path, when working that effort.
- It lives under `~/.claude` (never a git repo) → not committable, unlike a shareable `agent-plans/` deliverable.

## The split rule (also in CLAUDE.md + memory `feedback_memory_hygiene`)
- **Durable** (rule, lesson, landmine, design fact, config coordinate) → memory file.
- **Volatile** (PR#, status, date, count, rollout step, "awaiting") → here, `status/<slug>.md`, updated in place.
- Each memory file ends with: `Live status → ~/.claude/projects/<project>/status/<slug>.md`.

## Conventions
- **Stable filename per effort** (`my-feature.md`), updated in place — not dated snapshots (those go in `agent-plans/`).
- First line: `_last updated: YYYY-MM-DD_` (run `date`). A SessionStart hook flags files older than 14 days.
- Link out to dated `agent-plans/` report/plan docs rather than duplicating them.
