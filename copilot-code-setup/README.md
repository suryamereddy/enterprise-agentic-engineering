# copilot-dev-kit

An opinionated **GitHub Copilot** baseline: always-on engineering instructions, reusable review/diagnose/verify prompts, scoped instruction files, a scaled pre-ship gate (Chat prompt + CI), and a 3-layer secret-commit blocker. The Copilot port of a Claude Code setup — generic and sanitized; fill in the `<…>` bits.

> No names, repos, endpoints, or credentials inside. Copilot customizes very differently from Claude Code (no hooks/subagents/auto-memory) — see [`docs/claude-vs-copilot.md`](docs/claude-vs-copilot.md) for the honest mapping and what doesn't translate.

## What you get

| Area | File(s) | What |
|---|---|---|
| **Always-on instructions** | `.github/copilot-instructions.md`, `AGENTS.md` | 8 principles + hard rules + conventions, auto-applied to Chat & the coding agent |
| **Prompts** (`/` in Chat) | `.github/prompts/*.prompt.md` | `done-check` (scaled gate), `adversarial-review`, `prod-data-verify`, `diagnose`, `verify-prod`, `grill-me`, `handoff`, `mermaid-validate`, `ci-run-debug`, `pr-review-triage`, `creds-index` |
| **Custom agents** (dropdown / subagents) | `.github/agents/*.agent.md` | read-only reviewers: `adversarial-reviewer`, `security-auditor`, `performance-engineer`, `prod-data-verifier` (+ a `stack-reviewer` template) |
| **Scoped rules** | `.github/instructions/*.instructions.md` | security + no-hand-built-JSON, applied to matching paths automatically |
| **Editor wiring** | `.vscode/settings.json` | commit-message / review / PR-description instructions (the still-active VS Code settings) |
| **Secret blocker** | `git-hooks/pre-commit` + `.github/secret-patterns.txt` | blocks committing a secret; pair with GitHub push protection |
| **CI gate** | `.github/workflows/pre-ship-check.yml` | secret scan + your build/test as a required check |
| **Status discipline** | `docs/status/` + `docs/handoffs/` | durable facts in the instructions file; volatile status parked here (not auto-loaded) |

## Install

```bash
git clone <this-repo> copilot-dev-kit
cd copilot-dev-kit
bash install.sh /path/to/your/repo      # defaults to current dir; backs up anything it overwrites
```

Then:
1. Fill in `<…>` in `.github/copilot-instructions.md` (your stack + conventions).
2. Add your literal secret strings to `.github/secret-patterns.txt`.
3. In Copilot Chat, try `/done-check`, `/adversarial-review`, `/diagnose`; pick a reviewer from the agents dropdown.
4. **Commit the `.github/` files** so teammates and the Copilot coding agent pick them up.
5. Turn on **GitHub push protection** + make **Pre-ship check** a required status check (commands in the installer output).

## How this maps from Claude Code
The big translations (full table in [`docs/claude-vs-copilot.md`](docs/claude-vs-copilot.md)):
- `CLAUDE.md` → `.github/copilot-instructions.md` + `AGENTS.md`
- skills → `.github/prompts/*.prompt.md`
- reviewer subagents → `.github/agents/*.agent.md` custom agents (run as subagents)
- **hooks → git pre-commit + GitHub Actions + push protection** (Copilot has no lifecycle hooks)
- auto-memory → keep durable facts in the instructions file; volatile status in `docs/status/` (no auto-recall in Copilot)

## Client caveats (verified 2026)
- `copilot-instructions.md` + `AGENTS.md` work everywhere (incl. github.com & coding agent). **Prompt files and `.instructions.md` are VS Code-first** and do not apply on github.com Chat.
- VS Code's `codeGeneration`/`testGeneration` instruction settings are **deprecated** — this kit uses `.github/instructions/` instead.
- Prompt/agent frontmatter uses the current `agent:` field (older VS Code used `mode:`). `tools:` must use **canonical namespaced names** (`search/codebase`, `search`, `search/usages`, `search/changes`, `read/problems`, `edit/editFiles`, `execute/runInTerminal`, `execute/runTests`, `web/fetch`) — bare aliases like `codebase` are now **rejected** by VS Code, and unknown names are silently ignored.

## Layout
```
copilot-dev-kit/
├── install.sh                       # scaffolds .github/, .vscode/, .git/hooks into a target repo
├── README.md
├── AGENTS.md                        # → repo root (always-on non-negotiables)
├── docs/
│   ├── CUSTOMIZE.md                 # adapt to your stack
│   ├── claude-vs-copilot.md         # the honest Claude-Code → Copilot mapping
│   ├── status/                      # durable-vs-volatile discipline (README + example)
│   ├── handoffs/                    # dated handoffs/deliverables
│   └── templates/                   # stack-reviewer agent template (copy + fill in)
├── github/                          # → installs into the repo's .github/
│   ├── copilot-instructions.md
│   ├── secret-patterns.txt
│   ├── prompts/                     # 11 prompt files (/ in Chat)
│   ├── agents/                      # 4 reviewer custom agents (.agent.md)
│   ├── instructions/                # 2 path-scoped .instructions.md
│   └── workflows/pre-ship-check.yml # CI gate (secret scan + your build/test)
├── git-hooks/pre-commit             # → .git/hooks/pre-commit (secret scanner)
└── vscode/settings.json             # → .vscode/ (commit/review/PR instruction wiring)
```

## License / sharing
Free to copy and adapt. No warranty. Review every prompt/hook/workflow before trusting it.
