---
name: ci-run-debug
description: Debug a failing GitHub Actions run — find the run, pull only the failed-step logs, drill into the job, and re-run.
user-invocable: true
argument-hint: "[workflow or branch] [repo, default current]"
allowed-tools: Bash
---

# Debug a CI run

```bash
gh auth switch --user <your-gh-account> 2>/dev/null   # if the repo needs a specific account
R="${2:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
```

## 1. Find the run
```bash
gh run list -R "$R" --limit 15           # or: --branch <branch> / --workflow "<name>"
```

## 2. Pull ONLY the failed steps (don't drown in green logs)
```bash
RID=<run-id>
gh run view "$RID" -R "$R" --log-failed | tail -200
# full per-job logs if needed:
gh run view "$RID" -R "$R"               # lists jobs + which failed
gh api "repos/$R/actions/runs/$RID/jobs" --jq '.jobs[] | {name, conclusion, html_url}'
```

## 3. Common CI failure classes to check
- **Private package-feed restore red** → feed/provisioning not ready; reference the feed via a CI variable, never hardcode a per-repo feed name.
- **OIDC 403 on a data-plane action** → the deploy identity has a broad role but not the specific action; don't add code that calls it.
- **`dotnet test --no-build` "argument ...dll invalid"** (.NET 10 + xunit 3.x) → drop `--no-build`.
- **Connector/sidecar deploy 404 racing a restart** → run the dependent deploy step when the primary is already healthy.

## 4. Re-run
```bash
gh run rerun "$RID" -R "$R"                 # whole run
gh run rerun "$RID" -R "$R" --failed        # only failed jobs
```

> Building blocks: `gh auth switch`, `gh run view --log-failed`. Pairs with `pr-review-triage`.
