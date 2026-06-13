---
description: "Compact the current session into a clean handoff doc — done/in-progress/blocked/decisions/artifacts; redacts secrets"
agent: "agent"
tools: ["search/codebase", "search", "search/changes", "execute/runInTerminal"]
---

# Handoff — durable session state

Write a handoff doc so the next session (or the next agent) resumes with full context and ZERO stale assumptions. Save to `docs/handoffs/YYYY-MM-DD-<slug>-handoff.md` (run `date` for the real date first).

## Structure

```markdown
# Handoff — <effort> (<date>)
## Goal
<what we're trying to achieve, in 2 lines>
## Done (with EVIDENCE)
- <item> — proof: <CI run id / datastore query result / prod diff / test output> (link/path, don't paste secrets)
## In progress
- <item> — where it stands, next concrete step
## Blocked
- <item> — blocked on: <what / who>
## Key decisions made (and why)
- <decision> — rationale
## Artifacts (by path, not duplicated)
- plan: docs/handoffs/<...>.md · branch: <name> · PR: #<n> (state: <open/merged>)
## Open assumptions to confirm
- <assumption> — verify by: <command>
## Suggested next prompts
- diagnose · adversarial-review · verify-prod · ...
```

## Rules

- **Reference artifacts by PATH, don't paste them** (keeps it short, avoids duplicating big diffs).
- **Redact secrets** — never write a key/token/connection string into the handoff (a secret-scanner would block a commit anyway, and your credential index has the real values when needed).
- **Evidence, not claims** — every "Done" item cites real proof. If something's "done" without proof, list it under In-progress with "pending verification."
- **State PR status** — note if the branch's PR is already merged/closed (a follow-up push would strand the commit on a squash-merge).

## Why this fits

Directly counters the stale-context-revival failure mode (a revived session acting on a stale snapshot): a crisp, current handoff means the next context starts from truth, not a guess. Pairs with a living per-effort tracker (e.g. a `STATE.md`) — handoff is the session-end snapshot, the tracker is the running state.
