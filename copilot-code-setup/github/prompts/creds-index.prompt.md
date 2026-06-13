---
description: "One-stop index of YOUR credentials, endpoints, OAuth clients, API keys, and how to fetch each — fill this in; ships as an empty template"
agent: "agent"
tools: ["search/codebase", "search"]
---

# Credentials index (TEMPLATE — fill in your own)

> This is a starter template prompt. Replace the examples below with YOUR services, then
> run `/creds-index <service>` to recall one fast instead of hunting across notes.
> **RULE: this file holds the *fetch command / location*, never the literal secret value.**
> Secret values live in a secret manager (Key Vault / Secrets Manager / 1Password) or a
> gitignored local env file / GitHub Actions secret.

When invoked, return the relevant entry below (or `/creds-index <service>` for one service).

## How to use this index

- Each entry gives: the endpoint, the auth method, and the exact command to fetch the live secret at the moment you need it.
- Never paste a literal secret into a tracked repo file. If a value must appear in a repo, it's a reference (env var / KV name / Actions secret), not the value.
- A repo prompt file IS committed — so this file must NEVER contain a real secret. (The secret scanner will block it anyway.)

---

## Example entries (replace these)

### <service-name> (e.g. internal API)
- **Base URL:** `https://<your-host>/...`
- **Auth:** OAuth client_credentials | API key header | bearer
- **Token URL:** `https://<your-idp>/oauth2/token`
- **Client id:** `<client-id>`  ·  **Secret:** fetch with →
  ```
  az keyvault secret show --vault-name <your-vault> --name <secret-name> --query value -o tsv
  # or: aws secretsmanager get-secret-value --secret-id <name> --query SecretString --output text
  # or: op read "op://<vault>/<item>/credential"
  ```

### <cloud / database>
- **How to reach it:** `<vpn / private endpoint / gateway note>`
- **Connection string:** fetch from `<secret manager command>` — never inline.

### <git host account>
- Active account needed for org repos: `<your-account>` — switch with `gh auth switch --user <account>`.

---

## Adding a new cred
Append a new `### <service>` block above with: endpoint · auth method · the fetch command (never the value).
Then it's instantly findable here instead of scattered across notes.

> Personal/cross-repo creds you don't want committed: keep this prompt as a **user-level** prompt file
> (VS Code user profile, or `~/.copilot/prompts/`) instead of in the repo's `.github/prompts/`.
