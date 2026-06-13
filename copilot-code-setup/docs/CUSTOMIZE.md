# Customizing copilot-dev-kit

## 1. Your instructions
Edit `.github/copilot-instructions.md` — fill in the `<…>` (stack, conventions). This is applied to **every** Copilot Chat request, so keep it durable: evergreen facts only. Put volatile status (open PRs, rollout state) in `docs/status/<topic>.md`, never here.

## 2. Your secret blocker
Edit `.github/secret-patterns.txt`: paste the **exact literal strings** of your real keys/tokens under "ADD YOUR OWN" (zero false positives). Generic provider shapes already work. Confirmed false positive? Add `pragma: allowlist secret` to that line — never `--no-verify`.
Pair it with **GitHub push protection** (server-side, catches everyone): public repos free; private needs Advanced Security.

> **Caveat:** the repo-local `.git/hooks/pre-commit` does **not** run if you have a global `git config --global core.hooksPath` set (it overrides repo hooks). The installer warns you if so. In that case, add the scan logic to your global hooks dir, or just rely on the CI workflow + push protection (which catch everyone, including teammates who never installed the hook).

## 3. The CI gate
`.github/workflows/pre-ship-check.yml` ships with a placeholder build/test step. Replace it with your real commands (enforce ≥90% coverage on new code, fail on failure-branch gaps), then make **"Pre-ship check"** a **required status check** via a branch protection rule / ruleset so it gates merges — including Copilot coding-agent PRs.

## 4. Scoped rules for your stack
Add `.github/instructions/<topic>.instructions.md` with `applyTo:` globs (comma-separated string, e.g. `applyTo: "**/*.ts,**/*.tsx"`). Encode the rules that have actually bitten you. Note: these apply in VS Code/JetBrains/CLI, **not github.com Chat** — put cross-surface rules in `copilot-instructions.md`/`AGENTS.md`.

## 5. More prompts
Copy any `.github/prompts/*.prompt.md` as a template. Frontmatter `agent: "agent"` lets the prompt read files/run tools; use a read-only `tools:` set for pure reviewers. (Older VS Code used `mode:` instead of `agent:` — `agent:` is the current field; keep `mode:` only if you target an older client.) Use **canonical namespaced tool names** (`search/codebase`, `search`, `edit/editFiles`, `execute/runInTerminal`, `execute/runTests`, `read/problems`, `search/usages`, `search/changes`, `web/fetch`) — bare aliases like `codebase` are now rejected by VS Code and unknown names are silently ignored.

## 6. VS Code custom agents (shipped)
The kit ships four read-only reviewer agents at `.github/agents/*.agent.md` (`adversarial-reviewer`, `security-auditor`, `performance-engineer`, `prod-data-verifier`). VS Code loads any `.md`/`.agent.md` in `.github/agents/` as a custom agent and can run them as **subagents** of the pre-ship gate. To add a stack-specific reviewer, copy `docs/templates/stack-reviewer-TEMPLATE.agent.md` to `.github/agents/<your-stack>-reviewer.agent.md`, set a lowercase-hyphen `name:`, and fill in every `<FILL IN>` with the silently-failing invariants from your own incidents. Keep it workspace-scoped (a global one misfires on other repos). Don't bake secrets/hostnames/ids into it.

## 7. Personal (user-global) instructions
Copilot's personal instructions are **UI-only** on github.com (Chat → profile → Personal instructions) — not a committable file, so they can't ship in a kit. In VS Code you can keep user-profile instruction files. Use these for *your* cross-repo preferences; use the repo's `.github/` for team rules.

## 8. The memory discipline (adapted)
Copilot has no auto-recalled memory. The discipline that survives: keep `copilot-instructions.md` durable; route point-in-time status to `docs/status/`. Stale facts in the always-applied instructions mislead every session.
