# Customizing claude-dev-kit to your stack

The kit ships generic. Here's how to make it yours.

## 1. Your credentials index
Edit `~/.claude/skills/creds-index/SKILL.md`. For each service add: endpoint, auth method, and the **fetch command** (never the literal secret). Then `/creds-index` finds any cred instantly. Secret *values* live in your secret manager / a gitignored env file — never in a tracked repo.

## 2. Your secret-commit blocker
Edit `~/.claude/git-hooks/secret-patterns.txt`:
- Paste the **exact literal strings** of your real keys/tokens/client-ids under "ADD YOUR OWN" (zero false positives, highest-value).
- The generic provider shapes (`ghp_`, `AKIA`, JWT, etc.) already work.
- Confirmed false positive? Add `pragma: allowlist secret` to that line — **never `--no-verify`**.
Test it: try to commit a file containing one of your literals; it should be blocked.

## 3. A reviewer for YOUR stack
Copy the repo's `templates/stack-reviewer.agent.md` to `~/.claude/agents/<your-stack>-reviewer.md`, give it a lowercase-hyphen `name`, and fill in the `<FILL IN>` blocks with your own hard-won invariants — the bugs that have actually bitten you (the silent-failure modes, the config traps, the concurrency rules). This is the highest-leverage customization: a reviewer that knows your scars. Reference it from `/done-check`. **Don't bake secrets/host names/account ids into it.**

Keep repo-specific reviewers as **project** agents (`<repo>/.claude/agents/`), not global — a global one misfires on other repos.

## 4. The formatter hook
`stop-dotnet-format.sh` runs `dotnet format` on changed `.cs` files at turn end. Swap it for your formatter:
- JS/TS → `prettier --write`
- Python → `black` / `ruff format`
- Go → `gofmt -w`
Keep the "changed files only, non-blocking, at Stop (not per-edit)" shape — per-edit formatting is slow and can break the next exact-match edit.

## 5. Optional: prod feature-flag guard
`guard-prod-flag-flip.sh` blocks flipping a production flag without explicit approval. It ships but is **not wired** by default. To enable, add it to the `PreToolUse`→`Bash` hooks array in `~/.claude/settings.json` and edit the script to match your flag tooling (LaunchDarkly, etc.).

## 6. Permissions
`settings.json` denies force-push and prod-looking destructive SQL, and asks on DB shells / DML. Tighten or loosen for your environment. Add allow-rules for tools you use constantly to cut permission prompts (or run `/fewer-permission-prompts`, a built-in Claude Code skill — not part of this kit).

## 7. Company-specific skills you may want to rebuild
These weren't shipped (too specific), but the pattern is reusable — each is a `SKILL.md` that captures a workflow you re-derive constantly:
- **Cloud log pulls** — the proxy/auth-safe way to query your log backend.
- **Prod datastore queries** — fetch conn-string from your secret manager, read-only, with a safety check.
- **Billing/usage** — wrap your provider's billing API.
Write each once as a skill; stop re-deriving the incantation every session.

## 8. The memory/status discipline
- **Durable facts** → a memory file (`~/.claude/projects/<project>/memory/<slug>.md`), indexed in `MEMORY.md`.
- **Volatile status** (PR#s, rollout, "awaiting X") → `…/status/<slug>.md`, updated in place; the memory ends with a `Live status → …` pointer.
- Why: memory is auto-recalled, so stale status there poisons context. `status/` is never auto-recalled.
- After editing any agent/hook/settings on disk: **restart the session** — they load at session start.
