---
description: "Pre-ship gate — run before commit/PR: scaled adversarial review, ≥90% challenging coverage, E2E incl. failure branches, real-data proof"
agent: "agent"
tools: ["search/codebase", "search", "search/changes", "search/usages", "read/problems", "execute/runInTerminal", "execute/runTests"]
---

# Done-check — the pre-commit / pre-PR gate

Run this **once, at the commit/PR boundary** — not on every turn, not on every "done" claim (that wastes time and tokens). It's the gate right before `git commit` / opening a PR. "It compiles and tests pass" is NOT enough. If any item is unmet, the change isn't ready — say which and why.

## 1. Adversarial review — SCALED to the change (don't always do 3)

Pick the reviewer effort by diff size + risk so small changes stay cheap:

| Change | Review effort | How |
|---|---|---|
| Trivial (≤~30 lines, no logic/prod path) | **0–1 pass** | one adversarial pass, or a careful self-review |
| Normal feature/fix | **1–2 passes** | the `adversarial-reviewer` agent (or `/adversarial-review` prompt) plus any repo-specific lens |
| Large / risky / touches prod / data migration / contract | **3 passes** | three independent reviewers with no shared context — prefer the `adversarial-reviewer`, `security-auditor`, and a repo-specific `stack-reviewer` agent for diversity |

```
# scope first, then scale:
git diff --stat origin/main...HEAD
```

Review the changed files adversarially (pull the `adversarial-reviewer` / `security-auditor` agents as subagents, or run the `/adversarial-review` prompt) at the scaled effort; collect findings, dedupe, fix each, re-review the fixes. A clean review on a large change is a failed review — keep digging. Address every finding, no cherry-picking.

## 2. ≥90% coverage on NEW code, written to challenge

Tests must try to break the implementation: edge cases, boundaries, races, failure branches, invalid inputs, concurrent deliveries, partial failures. Measure on **new code** independently (a per-diff coverage report), not whole-repo diluted coverage.

**Anti-pattern (forbidden):** writing a test, seeing it fail, then editing the *test* to match what the code does. If a test fails and the *code* is wrong, fix the code. Only change a test when the test was wrong about the spec.

## 3. E2E test for every scenario

Every new endpoint, flow, and failure branch gets an E2E test — incl. not-found, dependency-unavailable, 409 race, optimistic-concurrency / ETag exhaustion, upstream error → compensating action, app error, dead-letter replay, quarantine. Happy paths alone are insufficient.

## 4. Automation/integration suite covers every scenario

Not just smoke: happy, validation-negative, auth-negative, idempotency, duplicate-replay, races, load (≥20 concurrent), failure-branch proofs with datastore doc verification, dead-letter, quarantine, outbound reply verification, live-spec parity, message offset/header checks.

## 5. Prove it with real data

Produce evidence — not "I believe this works":
- Datastore queries showing expected docs / status transitions
- Logs / telemetry showing the code paths executed
- Message-queue offsets + headers on the right topics
- Correlation IDs round-tripped through the integration
- Raw tool output / screenshots

(For the deeper version, run the `prod-data-verify` prompt.)

## 6. Contracts 1:1 against the LIVE spec

Verify against the API spec's live/published endpoint, not a cached or neighboring copy. Pattern-matching from neighboring repo code is NOT verification — neighbors may be drifted.

## Output

End with a checklist:
```
[x] reviews scaled to change — all findings addressed
[x] ≥90% new-code coverage, challenging tests, no test-fits-code
[x] E2E for every scenario incl. failure branches
[x] automation/integration suite covers every scenario
[x] real-data proof captured (paste/links)
[x] 1:1 vs live spec
DONE  — or —  STILL in_progress: <item> because <reason>
```

When something genuinely can't be finished in-session (cloud access, CI creds, human review), say "compile + unit green, pending <X> by user" — never call it done.
