- [Memory hygiene](feedback_memory_hygiene.md) — Memory files stay durable-only; volatile project status (PR#s, rollout, counts) goes to the status/ sibling folder, never memory or agent-plans
- [Claude Code loads at session start](reference_claude_code_loading.md) — agents/hooks/settings load at SESSION START; restart after editing on disk; /agents UI applies immediately. User agents global, repo agents load in-repo
- [EXAMPLE durable memory](_EXAMPLE-memory.md) — delete this; it shows the shape of a good durable memory entry

<!--
This is the auto-memory INDEX. One line per memory file: - [Title](file.md) — one-line hook.
It's loaded into context every session; topic files are recalled on relevance.
Add a line here whenever you add a memory file. Keep volatile status OUT (see feedback_memory_hygiene).
-->
