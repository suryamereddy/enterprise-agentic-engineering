---
name: pr-review-triage
description: Triage PR review comments — list unresolved Copilot/human review threads, address them, and resolve via GraphQL (REST can't tell resolved-state; resolve needs GraphQL).
user-invocable: true
argument-hint: "[PR number] [repo, default current]"
allowed-tools: Bash
---

# PR review triage — PR #$1

```bash
gh auth switch --user <your-gh-account> 2>/dev/null   # if the repo needs a specific account
R="${2:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"
PR="$1"
```

## 1. List review comments (filter to unresolved / a reviewer)
```bash
gh api "repos/$R/pulls/$PR/comments" --paginate \
  --jq '.[] | {path, line, user: .user.login, body: .body[0:120], created_at}'
# Copilot review summary:
gh api "repos/$R/pulls/$PR/reviews" --jq '.[] | select(.user.login=="Copilot") | {state, submitted_at, body: .body[0:200]}'
```

## 2. Find UNRESOLVED threads (REST can't tell you resolved-state — use GraphQL)
```bash
gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
    reviewThreads(first:100){ nodes{ id isResolved isOutdated path line
      comments(first:1){ nodes{ author{login} body } } } } } } }' \
  -f owner="${R%/*}" -f repo="${R#*/}" -F pr="$PR" \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved==false) | {id, path, line, body: .comments.nodes[0].body[0:120]}'
```

## 3. After fixing — resolve a thread (GraphQL; there is no REST resolve)
```bash
gh api graphql -f query='mutation($id:ID!){ resolveReviewThread(input:{threadId:$id}){ thread{ isResolved } } }' -f id="<threadId>"
```

> Codifies the recurring graphql `reviewThreads`/`resolveReviewThread` pattern. Never push to a branch whose PR is already merged (a squash-merge strands the commit) — check `gh pr view $PR --json state` first.
