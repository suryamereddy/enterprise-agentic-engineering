# docs/status/ — living project status (NOT the always-applied instructions)

Companion to `.github/copilot-instructions.md`. Holds the **volatile** half of project knowledge — PR numbers, rollout progress, "awaiting X", dated counts, branch/stash state — that goes stale fast.

## Why this folder exists
- **`.github/copilot-instructions.md` is applied to EVERY Copilot Chat request.** Stale status in that file = stale facts fed into every prompt. So the instructions file holds ONLY durable, evergreen rules (architecture, invariants, conventions).
- **This folder is NOT auto-loaded.** Copilot reads it only when you point it here (`#file:docs/status/<slug>.md` or by opening it). That's the point — status that goes stale must not be auto-injected.
- Unlike a memory store, there's no auto-recall in Copilot — so the discipline is simply: *keep the always-applied file durable; park the moving parts here.*

## The split rule (also in copilot-instructions.md + CUSTOMIZE.md)
- **Durable** (rule, lesson, landmine, design fact, config coordinate) → `.github/copilot-instructions.md`.
- **Volatile** (PR#, status, date, count, rollout step, "awaiting") → here, `docs/status/<slug>.md`, updated in place.

## Conventions
- **Stable filename per effort** (`my-feature.md`), updated in place — not dated snapshots (dated reports/plans go in `docs/handoffs/` or `docs/plans/`).
- First line: `_last updated: YYYY-MM-DD_` (run `date` for the real date).
- Link out to dated handoff/plan docs rather than duplicating them.
- This is committed repo content, so **no secrets** — reference the secret store, never paste a value.
