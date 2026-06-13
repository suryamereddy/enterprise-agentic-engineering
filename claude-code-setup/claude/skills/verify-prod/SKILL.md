---
name: verify-prod
description: Verify code output against real production/live data before claiming parity. Pulls the real artifact (prod query, live API spec, captured wire body) and diffs field-by-field. Use for any integration (API, pipeline, file export) before "done".
user-invocable: true
argument-hint: "[what to verify, e.g. 'request payload vs live API spec']"
---

# Verify against real data — $ARGUMENTS

Unit tests prove internal consistency; only comparison against the real thing proves correctness. Never fabricate a sample — if the real artifact is unavailable, say so and how to get it.

## Step 1 — pick the source of truth
| Verifying | Real source | How to capture |
|---|---|---|
| API payload shape | live OpenAPI spec | fetch `<your-api-spec-url>` and extract to `/tmp/api-spec.json` |
| Wire body the code sends | the serializing integration test | run the test that captures the serialized body; dump it |
| Pipeline output | the real store | query the real datastore (on a private network, prefer a direct/gateway connection) |
| Egress event | the real topic / captured event | consume / read the captured event |
| Prod data sample | prod output archive | read the archive — do NOT reconstruct from schema |

## Step 2 — capture BOTH sides with real commands
- Real artifact → save to `/tmp/real-<thing>.json`, show the command + raw result.
- Code output → run it (don't infer), save to `/tmp/code-<thing>.json`.

## Step 3 — diff field-by-field
Report every: missing field, extra field the consumer rejects, wrong shape (nested value/override objects, typed identifiers, reference qualifier vs type terms), wrong value, wrong casing, wrong type.

## Step 4 — verdict
```
PARITY (list what was compared)  |  N MISMATCHES (fix before done)  |  CANNOT VERIFY: <what's needed + the command to get it>
```

## Gotchas
- Make sure your `gh`/cloud CLI is on the account that has access to the target repo/resource before you start.
- Resources behind an IP allowlist or private endpoint may need VPN; off-VPN, fall back to a direct token-based request (`curl` with a scoped bearer token) instead of an SDK that breaks on a corp-proxy cert.
- For the deeper version, hand off to the `prod-data-verifier` subagent.

> This codifies "always verify against real data" and "never fabricate." A "1:1" claim is routinely wrong until diffed against the live spec; a feature "ready" on hundreds of green unit tests can still have prod-data bugs that only a real-data diff catches.
