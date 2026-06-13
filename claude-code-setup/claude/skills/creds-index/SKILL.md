---
name: creds-index
description: One-stop index of YOUR credentials, endpoints, OAuth clients, API keys, service accounts, and how-to-fetch each. Invoke to find any cred fast instead of hunting across files. FILL THIS IN with your own services — it ships as an empty template.
user-invocable: true
---

# Credentials index (TEMPLATE — fill in your own)

> This is a starter template. Replace the examples below with YOUR services.
> **RULE: this file holds the *fetch command / location*, never the literal secret value.**
> Secret values live in a secret manager (Key Vault / Secrets Manager / 1Password) or a
> gitignored local env file. This skill file lives only in `~/.claude/` (never a git repo).

When invoked, return the relevant entry below (or `/creds <service>` for one service).

## How to use this index
- Each entry gives: the endpoint, the auth method, and the exact command to fetch the live secret at the moment you need it.
- Never paste a literal secret into a tracked repo file. If a value must appear in a repo, it's a reference (env var / KV name), not the value.

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
