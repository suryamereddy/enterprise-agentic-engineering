# The Operational Harness

### Turning the methodology into enforcement — the runnable layer

> The [methodology](methodology.md) and the [10 Commandments](../README.md) describe *what* disciplined AI engineering looks like. This document covers *how it's enforced* — the deterministic harness that makes the discipline automatic instead of remembered. These are the practices that emerged **after** the original 20-month dataset (Apr–Jun 2026), once the methodology was stable enough to mechanize.
>
> Everything here ships, runnable, in [`claude-code-setup/`](../claude-code-setup/). One command installs it: `bash claude-code-setup/install.sh`.

---

## The core shift: prose → enforcement

A principle in a doc is advisory — the AI (and the human) can forget it under context pressure. A principle in a **hook**, a **settings rule**, or a **gated skill** fires every time, deterministically. The harness moves the highest-value rules from "we agreed to do this" to "the system does this."

| Methodology principle | Was (prose) | Now (enforcement) |
|---|---|---|
| Review your own code (Commandment 3) | "do 5+ rounds" | `/done-check` — a gate run at the commit/PR boundary, reviewer count **scaled to the diff** |
| Trust but verify (Commandment 2) | "stash, prove, rebuild" | `verify-prod` + `prod-data-verifier` agent — diff output against the real artifact, field by field |
| One-click setup (Commandment 6) | aspiration | `install.sh` — the harness installs itself in one command |
| Never commit a secret | code review | 3-layer secret scanner (git pre-commit + PreToolUse hook + pattern list) |

---

## 1. Hooks — deterministic guardrails

Shell hooks wired in `settings.json` that fire on lifecycle events. They can't be forgotten.

- **SessionStart** — inject the real OS date (kills stale-date errors); flag any project `status/` file older than 14 days.
- **PreToolUse(Bash)** — block pushing to a merged/closed PR branch; block committing a secret; remind to run `/done-check` at `gh pr create`.
- **PreToolUse(Write)** — nudge deliverables (plans/reports) into `agent-plans/`.
- **Stop** — format the files changed this turn (once, at turn end — never per-edit).

**Hard-won hook gotchas** (each cost real debugging):
- Hooks, agents, and `settings.json` load at **session start**. Edit them on disk → **restart** to load. (Agents made via the `/agents` UI apply immediately.)
- Every hook that prints JSON must include `hookSpecificOutput.hookEventName` (exact event name). A PreToolUse "ask" uses `permissionDecision` + `permissionDecisionReason` — not `systemMessage`.
- `PostToolUse` fires only on tool **success**. A failed Bash command does **not** fire it — so "capture failures via PostToolUse" doesn't work; the failure is visible inline anyway.

## 2. The scaled review gate — refining "5+ rounds"

The original commandment said *always* 5+ review rounds. At scale that's wasteful on trivial diffs and insufficient on contract changes. `/done-check` **scales the review to the change**, run once at the commit/PR boundary:

| Change | Reviewers | |
|---|---|---|
| Trivial (≤~30 lines, no logic/prod) | 0–1 | one adversarial pass or careful self-review |
| Normal feature/fix | 1–2 | adversarial-reviewer (+ repo-specific reviewer) |
| Large / risky / prod / contract / migration | 3 | independent reviewers, no shared context |

The gate also requires: ≥90% coverage with tests that *try to break* the code (not test-fits-code), E2E for every scenario incl. failure branches, and **proof against real data** — not just green unit tests.

## 3. The 3-layer secret-commit blocker

Secrets reach prod via a secret manager, never source. Three independent layers stop a commit:
1. **Global git `pre-commit`** — scans the staged diff against `secret-patterns.txt`; blocks any repo, even outside Claude.
2. **PreToolUse hook** — blocks `git add`/`commit` of staged content matching a pattern, before it happens.
3. **`secret-patterns.txt`** — generic provider shapes + *your* literal keys (zero false positives).

Confirmed false positive? Add `pragma: allowlist secret` to that line — **never `--no-verify`**. (A broad bare-base64 pattern is deliberately excluded — it blocks minified JS and lockfile hashes.)

## 4. Memory hygiene — durable vs. volatile

Persistent memory is auto-recalled into context every session, so **stale facts there poison every future session.** The discipline:
- **Durable** (rules, landmines, design facts) → a memory file, indexed in `MEMORY.md`.
- **Volatile** (PR numbers, rollout state, "awaiting X", dated counts) → a `status/<slug>.md` sibling, updated in place, **never auto-recalled**. The memory ends with a `Live status → …` pointer.

This keeps recall sharp on long-lived projects: the evergreen knowledge is always in context; the point-in-time status is one deliberate read away, and a SessionStart hook flags it when it goes stale.

## 5. Specialist reviewer agents

Read-only, evidence-backed, no-fabrication reviewers pulled at the gate. Beyond the repo's existing security/performance/test/quality reviewers, the harness adds:
- **`adversarial-reviewer`** — tries to *break* the code (edge cases, races, failure branches), not validate it.
- **`prod-data-verifier`** — pulls the real artifact and diffs the code's output field-by-field. The teeth on Commandment 2.
- **`stack-reviewer` template** ([`templates/stack-reviewer.agent.md`](../templates/stack-reviewer.agent.md)) — copy it and encode *your* stack's hard-won invariants (the DLQ rules of Commandment 7, your silent-failure modes). A reviewer that knows your scars beats any generic one.

---

## Install

```bash
bash claude-code-setup/install.sh   # backs up your existing ~/.claude first
# then RESTART Claude Code, fill in creds-index + secret-patterns, set your model
```

See [`claude-code-setup/CUSTOMIZE.md`](../claude-code-setup/CUSTOMIZE.md) to adapt the formatter hook, secret patterns, and stack-reviewer to your environment.
