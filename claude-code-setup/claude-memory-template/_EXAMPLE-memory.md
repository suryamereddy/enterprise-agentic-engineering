---
name: example-project-landmine
description: "EXAMPLE — delete me. Shows the shape of a good durable memory: a hard-won rule + why + how-to-apply + a status pointer"
metadata:
  node_type: memory
  type: project
---

> DELETE THIS FILE. It's a worked example of a durable memory entry. Copy the shape, not the content.

**The durable rule (always true):** `<the invariant / landmine / design fact>` — e.g. "Sorting on a sparse field in our datastore silently EXCLUDES rows missing that field — it once hid 99% of a prod queue with no error."

**Why (the real incident):** `<what happened, with real numbers>` — keep it factual, no invented data.

**How to apply:** `<the rule to follow next time>` — e.g. "Before shipping a sort/filter on a nullable/added field: count the rows missing it first, and plan a backfill."

Related: `[[other-memory]]`.

Live status (PR#s, rollout, dated counts) → ~/.claude/projects/<project>/status/example-project.md
