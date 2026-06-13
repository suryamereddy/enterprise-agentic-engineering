---
applyTo: "**"
---

# Security rules (apply to all code)

Write code an attacker can't trivially break. These are non-negotiable for any generated or modified code.

## Input & injection
- **Validate all external input** — anything from HTTP requests, message payloads, query params, headers, files, or third-party APIs is untrusted until validated (type, range, length, format, allow-list).
- **Parameterize every query.** Never build SQL or a datastore query by string concatenation/interpolation with user input — use parameter binding / prepared statements. Same for OS commands (no shelling out with concatenated input) and LDAP/header values.

## Secrets
- **Secrets come from a secret manager or environment, never source.** No keys/tokens/connection strings/passwords in code, config, tests, or logs. If a value must appear in a repo, it is a reference to the secret store, not the literal value.
- Never log a secret, even at debug level.

## AuthZ / authN
- **Authorize at every endpoint.** Every externally reachable route enforces its authorization gate — no endpoint trusts that an upstream layer already checked.
- Don't trust caller-supplied identity; validate the caller actually owns the resource id being acted on (guard against IDOR).

## Deserialization & outbound
- **Safe deserialization only.** No unsafe binary formatters, no polymorphic type-name handling on untrusted payloads. Deserialize into known, explicit types.
- **No SSRF.** Don't build an outbound URL/host from request input without an allow-list. Never disable host/cert verification.

## Transport & data exposure
- TLS with real certificate verification for all external communication; no weak crypto (MD5/SHA1 for security, hardcoded IVs).
- Don't leak PII/financial data in logs, error responses, or outbound payloads; don't return fields the caller shouldn't see.
