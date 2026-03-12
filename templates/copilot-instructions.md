# Copilot Instructions Template

> **Copy this file to `.github/copilot-instructions.md` in your repository and customize the bracketed placeholders.**
> This template encodes battle-tested patterns from 20 months of enterprise AI-assisted development.

---

## Organization Context

**Company**: [YOUR_COMPANY]
**Domain**: [YOUR_DOMAIN — e.g., logistics, fintech, healthcare, e-commerce]
**Stack**: [YOUR_STACK — e.g., Java 21 / Spring Boot, .NET 8, Python 3.12, Node.js 20, PostgreSQL, Kafka]
**Environments**: [YOUR_ENVS — e.g., DEV → QA → PROD]

---

## Architecture

All projects follow a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────────┐
│ 1. Clients  (Entry Points)                  │  ← HTTP triggers, message consumers, timers
├─────────────────────────────────────────────┤
│ 2. Contracts (DTOs, Interfaces)             │  ← Shared type definitions
├─────────────────────────────────────────────┤
│ 3. Managers  (Orchestration)                │  ← Compose calls across layers
├─────────────────────────────────────────────┤
│ 4. Engines   (Business Logic)               │  ← Transformations, rules, validations
├─────────────────────────────────────────────┤
│ 5. Accessors (Data Access)                  │  ← Database, external APIs, queues
├─────────────────────────────────────────────┤
│ 6. Utilities (Cross-cutting)                │  ← Auth, HTTP clients, logging
├─────────────────────────────────────────────┤
│ 7. Common    (Constants, Helpers)            │  ← Shared constants, base classes
└─────────────────────────────────────────────┘
```

### Layer Rules

| Layer | May Call | Never Calls |
|-------|---------|-------------|
| Client | Manager | Engine, Accessor directly |
| Manager | Engine, Accessor, Utility | Other Managers |
| Engine | Accessor, Utility | Manager, Client |
| Accessor | Utility | Manager, Engine, Client |

---

## Coding Standards

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Namespaces | `[YOUR_COMPANY].{App}.{Layer}` | `Acme.OrderService.Managers` |
| Interfaces | `I` prefix | `IOrderManager` |
| Methods | PascalCase, async suffix | `ProcessOrderAsync()` |
| Constants | PascalCase in Constants class | `Constants.DatabaseConnectionString` |
| Private fields | `_camelCase` | `_logger`, `_configuration` |
| Test methods | `MethodName_Scenario_Expected` | `ProcessOrder_ValidInput_ReturnsSuccess` |

### Constants (STRICT)

All magic strings and numbers MUST go into a dedicated constants file:

```
Constants.DATABASE_CONNECTION_STRING = "DatabaseConnectionString"
Constants.UNIT_TEST = "Unit-Test"
// Add your constants here
```

Adapt to your language — `Constants.cs`, `Constants.java`, `constants.py`, `constants.ts`, etc.

### Async/Await

- All I/O operations MUST be async
- Methods returning async results should follow naming conventions (`Async` suffix in C#, etc.)
- Never block on async operations — always await/then properly

---

## Database Patterns

[CUSTOMIZE: Add your database patterns here]

**Key Rules:**
- Always specify partition/shard key in queries
- Use ETags for optimistic concurrency
- Singleton database clients (connection reuse)
- Bulk operations for batch processing

---

## Message Streaming Patterns

[CUSTOMIZE: Add your Kafka/ServiceBus/EventGrid patterns here]

**Topic Naming**: `@{environment}-{domain}-{entity}-{event}-v{version}`

**Key Rules:**
- Every consumer MUST have a Dead Letter Queue
- Include correlation ID in all message headers
- Hash-based delta detection to skip unchanged messages
- Never add application retry on top of library-native retry

---

## Error Handling

- Circuit breaker + retry for external HTTP calls (but never double-retry)
- Dead letter queue for every message consumer
- SHA-256 delta detection to avoid redundant processing
- Structured logging with correlation IDs
- Never log sensitive data (tokens, connection strings, PII)

---

## Testing Standards

| Element | Standard |
|---------|----------|
| Framework | [xUnit / NUnit / MSTest / Jest / pytest] |
| Mocking | [Moq / NSubstitute / Mockito / Jest mocks] |
| Naming | `MethodName_Scenario_ExpectedBehavior` |
| Coverage | 80%+ per project |

---

## CI/CD Rules

1. **SHA-pin ALL actions** — Never `@v4`, always full commit SHA
2. **OIDC auth over PAT** — Use managed identity for deployments
3. **Test categories filter** — Only unit tests in CI
4. **Quality gates enforced** on PRs

---

## Security

- NEVER commit secrets — use secret management
- NEVER use PATs in CI/CD — use OIDC / Managed Identity
- ALWAYS validate input from external sources
- ALWAYS use HTTPS/TLS
- SHA-pin all third-party action/package references

---

## The 10 Commandments

1. **Deep Onboard First** — Never modify code you haven't fully understood
2. **Trust but Verify** — AI output is a draft, not gospel
3. **Review Your Own Code** — 5+ review rounds for critical paths
4. **Never Double-Retry** — If the library retries natively, don't add application-level retry on top
5. **Document as You Build** — Architecture diagrams and runbooks are deliverables
6. **One-Click or It Doesn't Count** — Setup must be a single command
7. **DLQ Everything** — Every message consumer needs a dead letter queue
8. **Hash Before You Process** — Delta detection to avoid redundant processing
9. **Dry-Run Before Live** — Data migration tools must have dry-run modes
10. **Pin Your Dependencies** — SHA-pinned actions, version-locked packages

---

*Customize this template for your team. The conventions above are proven across 40+ production microservices over 20 months of AI-assisted development.*
