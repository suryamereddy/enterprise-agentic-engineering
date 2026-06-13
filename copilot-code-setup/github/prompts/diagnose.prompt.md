---
description: "Root-cause a failure/bug/slowness with a deterministic feedback loop before touching the fix — never patch the symptom"
agent: "agent"
tools: ["search/codebase", "search", "search/changes", "read/problems", "execute/runInTerminal", "execute/runTests"]
---

# Diagnose — build the loop, find the root cause, THEN fix

Never bump a timeout / widen a poll / relax an assertion / add a retry as the first move. Work the loop below until you can state the root cause with real evidence.

## 1. Build a deterministic, fast feedback loop

Reduce the failure to something you can re-run in seconds and that fails reliably:
- **Unit/test:** run the single failing test in isolation with your runner's filter flag (e.g. a `--filter` / `-k` / `-t` name match). Drop build-skip flags that error on your toolchain version.
- **HTTP/API:** `curl` the endpoint directly and capture the exact request/response. If logs are behind a corporate proxy, use a token + a direct `curl` to the log API instead of an SDK that breaks on the proxy cert.
- **Datastore:** replay the real query/doc with the actual partition/primary key (use a direct/gateway connection on a private network). Don't reason about data you haven't queried.
- **Message queue:** replay from the real offset — a consumer-replay harness or the broker CLI against the live topic; check headers + enqueue/ingest timestamps.

## 2. Make it differential (the highest-signal move)

Get the SAME input through the OLD (passing) and NEW (failing) path and diff:
- field-by-field payload diff (run the `verify-prod` prompt)
- old vs new model deserialization of the same stored doc
- prod baseline vs your output

The diff usually points straight at the root cause.

## 3. Rank falsifiable hypotheses — and disprove them with evidence

Write 2-4 hypotheses, each with a check that would FALSIFY it. Run the cheapest first. Treat **slowness >1-2s as a signal**, not a knob: profile what's eating the time (backlog, stalled consumer, N+1, autoscaler on the wrong topic, a hang) — prove it with timestamps (enqueue time, telemetry), not a guess.

## 4. Bisect if still unclear

`git bisect`, or toggle the suspect change off/on, or binary-search a config. Narrow to the exact line/commit/setting.

## 5. Only now: fix the ROOT CAUSE + add a regression test

- The fix may be product/infra, not the test. If the *code* is wrong, fix the code — never edit the test to match wrong behavior (test-fits-code is forbidden).
- Add a regression test that fails before / passes after.

## Output

State: **root cause** (with the evidence that proves it) → **the fix** (and why it addresses the cause, not the symptom) → **the regression test**. If you can't name the root cause with evidence, you haven't diagnosed it — keep going. Watch especially for silent data-loss failure modes (a missing/unmapped field, an absent permission, a parse fallback that fails open) — assume silent exclusion until real counts prove otherwise.
