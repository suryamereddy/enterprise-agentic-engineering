# AGENTS.md

> Read by the GitHub Copilot coding agent (and other agentic tools). The full engineering principles live in [`.github/copilot-instructions.md`](.github/copilot-instructions.md) — the coding agent reads both. This file states the non-negotiables.

## Non-negotiables
- **Never fabricate** data, samples, or results — use real sources or say you don't have them.
- **Verify against real data** before claiming an integration works; diff field-by-field.
- **"Done" requires evidence** — scaled review + challenging tests + failure-branch coverage + real-data proof, not just green unit tests.
- **Diagnose root cause before fixing** — never patch a symptom (timeout/retry/poll bump).
- **Never commit a secret** — secret manager / Actions secrets only; pre-commit hook + push protection enforce it.
- **Never use `--no-verify`**; never push to a merged/closed PR branch; never flip a prod flag without approval.

## Before committing or opening a PR
Run the review gate (see `.github/prompts/done-check.prompt.md`): review scaled to the change, ≥90% challenging coverage, failure-branch tests, real-data proof. Pull the read-only reviewer agents (`adversarial-reviewer`, `security-auditor`, `performance-engineer`, `prod-data-verifier` in `.github/agents/`) as subagents for large/risky/contract changes.

## Conventions
- Keep `.github/copilot-instructions.md` durable (evergreen facts only). Put volatile status (PR#s, rollout) in `docs/status/`, never in the always-applied instructions.
