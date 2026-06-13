# Copilot custom instructions — engineering principles

> Always applied to Copilot Chat in this repo. Customize the `<…>` bits for your project. The companion **prompt files** (`.github/prompts/`) are run with `/` in Chat; **instruction files** (`.github/instructions/`) apply to matching paths automatically.

## How to work here

1. **Never fabricate.** Every value, sample, payload, count, or conclusion must come from a real source — a real query, real logs, real captured output, or running the code. If you don't have the real thing, say so and go get it. No plausible-looking stand-ins presented as real. Label any unavoidable reconstruction loudly, up front.

2. **Verify against real data before calling it done.** Unit tests prove internal consistency; only comparison against real output / the live API spec / captured data proves correctness. For any integration (API, pipeline, export), diff the code's output against the real artifact field-by-field. (Run the `/verify-prod` prompt.)

3. **"Done" needs evidence — not "it compiles and tests pass."** Before a commit or PR, run the `/done-check` prompt. The bar: review **scaled to the change** (skip for trivial diffs; adversarial review for normal; multiple independent passes for large/prod/contract changes); ≥90% coverage on new code with tests that *try to break* it (never test-fits-code); coverage for failure branches, not just the happy path; and proof against real data. If any item is incomplete, say so — don't claim done.

3b. **Review your own output first.** Copilot's draft is a draft. Re-read the diff adversarially (or run `/adversarial-review`) and fix what you find before asking a human to review.

4. **Diagnose before you fix — never patch a symptom.** When something fails, errors, or is slow, don't bump a timeout, widen a poll, relax an assertion, or add a retry first. Find WHY with real evidence (logs, timestamps, the data it touched). Only fix once you can state the root cause. (Run `/diagnose`.)

5. **Use the real date.** Don't guess "today" — when a date matters (filenames, headers), state that you need the current date and use the actual system date.

6. **Think like an architect, not a code typer.** Enforce invariants at the data layer (constraints, not just app code), deliver real UX (not happy-path defaults), and ship the obvious companion flows (retry, consent, audit, reviewer UX) without being asked feature-by-feature. "Functional" is not "done."

7. **Plan before you build for any non-trivial change.** Write a short plan first — Approach · Files to touch · How it'll be verified (real-data/spec proof) · Open questions — and surface the open questions before the first edit. (Run `/grill-me` to pin down a design decision one question at a time.)

## Hard rules (don't break without explicit approval)

- **Never commit a secret.** Real keys/tokens/secrets never go into a tracked file (config, test, appsettings, yaml). Secrets reach prod via a secret manager / env vars / GitHub Actions secrets — never source. If a value must appear in a repo, it's a reference, not the value. (A git pre-commit hook + GitHub push protection enforce this.)
- **Never push to a branch whose PR is already merged/closed** — branch fresh off the default branch instead.
- **Never flip a production feature flag** without a human decision.
- **Don't bypass commit/push hooks** (no `--no-verify`). For a confirmed false-positive secret match, add the inline marker `pragma: allowlist secret` to that line.

## Secrets & credentials

- Keep credentials/endpoints in your secret manager (Key Vault / Secrets Manager / 1Password) or GitHub Actions secrets — never in a tracked file. Reference them by name; fetch the value at runtime.
- This repo's secret scanner (`git-hooks/pre-commit` + `.github/secret-patterns.txt`) and GitHub push protection block any secret from being committed.

## Project conventions

- **Keep THIS file durable.** It's applied to every Copilot request, so put only evergreen facts here (architecture, invariants, conventions). Put **volatile status** — open PR numbers, rollout state, "awaiting X", dated counts — in `docs/status/<topic>.md`, NOT here. Stale facts in this file mislead every future session.
- **Deliverables** (plans, reports, analyses) go in `docs/` (e.g. `docs/handoffs/`, `docs/plans/`), named `YYYY-MM-DD-<slug>.md`.
- **Tech stack:** `<fill in: languages, frameworks, cloud, datastore, messaging>`. Path-specific rules live in `.github/instructions/`.

## Prompts you can run (`/` in Chat)
`/done-check` · `/adversarial-review` · `/prod-data-verify` · `/diagnose` · `/verify-prod` · `/grill-me` · `/handoff` · `/mermaid-validate` · `/ci-run-debug` · `/pr-review-triage` · `/creds-index`

## Reviewer agents (agents dropdown / subagents)
`adversarial-reviewer` · `security-auditor` · `performance-engineer` · `prod-data-verifier` — read-only specialists pulled at the commit/PR boundary by `/done-check`.
