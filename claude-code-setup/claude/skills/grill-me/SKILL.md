---
name: grill-me
description: Interview you one question at a time down each branch of a design/approach decision before any code is written — recommend an answer per question, and explore the codebase to answer it instead of asking when possible. (Pattern from mattpocock/skills.)
user-invocable: true
argument-hint: "[the decision / feature / change to think through]"
---

# Grill me — surface the decisions before the code

For `$ARGUMENTS`, walk the decision tree **one question at a time**. Don't dump a wall of questions — ask the single most load-bearing one, get the answer, then branch.

## Rules
- **One question per turn.** Make it the highest-leverage unresolved decision. Give 2-4 concrete options + **a recommendation with a one-line why**.
- **Explore before asking.** If the codebase already answers it (existing pattern, constant, convention, prior art in a neighbor repo), find it and state the answer — don't ask something that's effectively already decided. (e.g. "this repo uses `*Resolver.cs` DI, not FactoryBase — so I'll follow that.")
- **Confirm assumptions, don't bury them.** When you must assume, say "I'm assuming X (because Y) — correct me" rather than silently proceeding.
- **Branch on the answer.** Each answer opens the next real fork (data shape → storage → concurrency → failure mode → test strategy). Keep going until the approach is fully pinned.
- **Stop when it's decided.** When there are no load-bearing unknowns left, summarize the agreed approach (Approach / files-to-touch / how-verified / open-assumptions) — that becomes the plan-gate doc.

## Why this fits
Serves "architect, not coder" + "evidence over assumptions": it forces the decisions to surface *before* a single line is written, at the cheapest possible point. Pairs with a plan-gate rule — grill-me produces the plan, the plan gets the go/no-go. Stack-agnostic.
