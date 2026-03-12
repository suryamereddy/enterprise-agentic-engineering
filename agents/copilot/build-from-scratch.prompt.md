---
description: "Build a new microservice from scratch following layered architecture patterns"
mode: "agent"
tools: ["read_file", "list_dir", "create_file", "replace_string_in_file", "run_in_terminal", "grep_search", "semantic_search"]
---

# Build from Scratch

You are building a new microservice following a layered architecture.
The structure is repeatable and maintainable across all projects.

## User Input Required

- **App name**: {{app-name}}
- **Type**: Serverless Functions | Container App (BackgroundService) | Web API
- **Message topics**: consumer topics and producer topics
- **Database containers**: container names with partition keys
- **External APIs**: endpoints requiring authentication

## Layered Architecture

```
┌─────────────────────────────────────────────┐
│ 1. Clients  (Functions / WebApi / Workers)  │  ← Entry points
├─────────────────────────────────────────────┤
│ 2. Contracts (DTOs, Interfaces)             │  ← Data contracts
├─────────────────────────────────────────────┤
│ 3. Managers  (Orchestration)                │  ← Compose calls
├─────────────────────────────────────────────┤
│ 4. Engines   (Business Logic)               │  ← Rules, transforms
├─────────────────────────────────────────────┤
│ 5. Accessors (Data Access)                  │  ← Database, APIs
├─────────────────────────────────────────────┤
│ 6. Utilities (Cross-cutting)                │  ← Auth, HTTP, logging
├─────────────────────────────────────────────┤
│ 7. Common    (Constants, Helpers)            │  ← Shared code
└─────────────────────────────────────────────┘
```

## Mandatory Patterns

1. **Constants file** in Common project for all config keys and strings
2. **Dead letter queue** for every message consumer
3. **Hash-based delta detection** before processing
4. **Structured logging** with correlation IDs
5. **Health checks**: /startup, /liveness, /readiness
6. **Circuit breaker** for external HTTP calls
7. **Test project per layer** with 80%+ coverage target

## After Building

1. Build the project
2. Run tests (unit tests only in CI)
3. Verify no compiler/linter warnings
4. Ready for Expert Code Review
