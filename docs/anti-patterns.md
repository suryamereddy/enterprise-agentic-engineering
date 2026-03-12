# Anti-Patterns

### What fails in AI-assisted development — and why

> *Every anti-pattern in this document caused a real problem in a production engineering context. They're organized by severity and frequency. Learn from documented failures instead of discovering them yourself.*

---

## Critical Anti-Patterns

### 1. Blind Conversion
**What it is**: Converting or migrating code without deeply understanding the original logic first.

**What happens**: The AI generates code that compiles, looks correct, and even passes basic tests — but implements *different business logic* than the original. The AI fills knowledge gaps with plausible guesses instead of flagging uncertainty.

**Real example**: A Python-to-TypeScript conversion produced code with 409 errors that didn't exist in the original. The AI hadn't converted — it had reimagined. ([Full case study](case-studies.md#the-humbling))

**Prevention**: Always Deep Onboard the source code first. Use Revert-Prove-Rebuild for every conversion task. Compare output behavior against original behavior, not just code structure.

---

### 2. Skipping Comprehension
**What it is**: Asking AI to modify a codebase neither you nor the AI fully understand.

**What happens**: Changes that seem isolated have cascading effects. A "simple" refactoring breaks an integration path that wasn't visible without full context. Configuration dependencies surface in production, not in development.

**Real example**: Modifications to a service's consumer configuration caused offset management failures because the background worker's Kafka initializer relied on centralized configuration settings that weren't documented anywhere — only discoverable through exhaustive file reading.

**Prevention**: Always Deep Onboard before modifying. If you're tempted to skip it for a "quick fix," that's exactly when you need it most.

---

### 3. Trust-by-Default
**What it is**: Accepting AI-generated code without structured verification.

**What happens**: Subtle bugs in areas where the AI's training data is thin (domain-specific business logic, legacy system integrations, edge cases in streaming pipelines). These bugs pass code review because they look correct to humans who also lack full context.

**Prevention**: Build-Review-Iterate (5+ rounds). Revert-Prove-Rebuild when modifying existing behavior. Never merge AI-generated code that hasn't been through at minimum 3 review rounds.

---

## High Severity Anti-Patterns

### 4. The Double-Retry Trap
**What it is**: Adding application-level retry (e.g., Polly) on top of library-native retry (e.g., librdkafka's built-in retry).

**What happens**: A single failed operation gets retried exponentially: library retry (3 attempts) × application retry (3 attempts) = 9+ attempts. This amplifies load on failing services, delays DLQ routing, and produces confusing logs.

**Real example**: A Kafka producer had both library-native retry AND application-level retry configured. A downstream service outage caused 9x the expected load when message delivery resumed, triggering cascading failures.

**Prevention**: Before adding retry logic, check if the underlying library has native retry. If it does, only handle the *final* failure at the application level.

```
❌ WRONG — Library already retries
retryPolicy.execute(() -> producer.send(topic, message));  // Java
await retryPolicy.ExecuteAsync(() => producer.ProduceAsync(topic, message));  // C#

✅ CORRECT — Handle only final failure
try { producer.send(topic, message); }
catch (ProduceException ex) { publishToDlq(message, ex); }
```

---

### 5. No Dead Letter Queue
**What it is**: Message consumers that don't route failed messages to a DLQ.

**What happens**: Silent data loss. Failed messages disappear. Downstream systems report missing data hours or days later. No forensic capability to understand what failed or replay messages.

**Prevention**: Non-negotiable. Every consumer gets a DLQ. Enforced at code review. ([DLQ patterns](methodology.md#6-dead-letter-queue-everything))

---

### 6. Magic Strings
**What it is**: Hardcoded string literals scattered throughout the codebase instead of centralized constants.

**What happens**: The same configuration key is typed differently in two places. A topic name has a typo in one consumer but not another. A database container name changes and 4 of 6 references are updated.

**Prevention**: All configuration keys, topic names, container names, and test categories in a centralized constants file. AI agents should be instructed to always use constants, never literals.

---

### 7. Floating Dependency Versions
**What it is**: Using version tags (e.g., `@v4`) instead of commit SHAs for CI/CD actions and dependency references.

**What happens**: Supply chain attacks via compromised tags. A maintainer pushes a malicious update to `@v4`, and every pipeline using that tag gets the compromised code.

**Real example**: A multi-repository CI/CD audit revealed 12 references to `@v4` or `@v3` across workflows. All were replaced with full SHA pins.

**Prevention**: SHA-pin every third-party action reference. Version-lock every package dependency. No floating references anywhere.

```
❌ WRONG
uses: actions/checkout@v4

✅ CORRECT
uses: actions/checkout@<full-commit-sha>
```

---

## Medium Severity Anti-Patterns

### 8. Over-Abstraction on First Pass
**What it is**: AI generating unnecessary abstractions, interfaces, and helper utilities for functionality that's only used once.

**What happens**: Increased complexity without corresponding value. More files to maintain. More indirection to trace during debugging. Code review takes longer because reviewers must understand the abstraction to evaluate the implementation.

**Prevention**: Instruct AI to generate the minimum correct implementation first. Abstractions should be extracted when a pattern repeats, not predicted in advance.

---

### 9. Mixing Design Patterns Within a Project
**What it is**: Using one architectural pattern in a project that has already established a different convention (e.g., introducing constructor injection in a project using service locator, or mixing Active Record with Repository pattern).

**What happens**: Inconsistent code paths. Some services resolved one way, others another way. New team members can't predict which pattern applies. Testing becomes harder because different setup is needed depending on the resolution mechanism.

**Prevention**: Match the project's existing pattern. Always. If the project uses service locator, follow it. If it uses constructor injection, follow that. Never introduce a different pattern into an established codebase without an explicit migration plan.

---

### 10. Cross-Partition Database Queries
**What it is**: Querying a partitioned database (Cosmos DB, DynamoDB, Cassandra, etc.) without specifying the partition key.

**What happens**: The query scans every partition — dramatically increasing cost and latency. A query that should cost 5 RUs and take 10ms instead costs 500 RUs and takes 2 seconds.

**Prevention**: Always specify partition key in every query. AI agents should be instructed to flag any query that doesn't include a partition key.

---

### 11. Sync-over-Async
**What it is**: Blocking on async operations instead of properly awaiting them (e.g., `.Result`/`.Wait()` in C#, `asyncio.run()` inside an existing event loop in Python, or blocking `CompletableFuture.get()` in Java without timeout).

**What happens**: Thread pool starvation under load. Deadlocks in UI or web contexts. Performance degradation that only appears under high concurrency — invisible in development, catastrophic in production.

**Prevention**: Async all the way down. Every I/O method is async, every consumer awaits it, all the way to the entry point. AI agents should be instructed to flag any synchronous blocking on async operations.

---

### 12. Logging Secrets
**What it is**: Writing tokens, connection strings, or PII to log output.

**What happens**: Secrets appear in log aggregation systems where they're visible to anyone with log access. Connection strings in Application Insights. Bearer tokens in CloudWatch. API keys in Datadog.

**Prevention**: Structured logging with explicit field selection. Never log raw request/response bodies that might contain credentials. AI agents should be instructed to flag any logging call that includes a variable named `token`, `password`, `connectionString`, or `secret`.

---

### 13. Milestone/Pre-Release Dependencies
**What it is**: Using milestone or pre-release versions of dependencies in production code.

**What happens**: Breaking changes between milestone and GA. In one case, a Spring Framework milestone (M8) worked, but the GA release removed a critical authentication class entirely — breaking auth with no migration path. In another, a beta NuGet package introduced a breaking API change between RC and stable release.

**Prevention**: Only GA releases in production. If a pre-release feature is needed, pin the exact version and document the migration plan for when the stable release ships.

---

## Low Severity (But Pernicious) Anti-Patterns

### 14. Assumption-Based Coding
**What it is**: AI assumes business logic when the specification is unclear, instead of asking for clarification.

**Prevention**: Instruct AI: *"If you don't know, say you don't know. Don't fill gaps with assumptions."*

### 15. Test Names Without Context
**What it is**: Test method names like `Test1()` or `ProcessTestAsync()` instead of `MethodName_Scenario_ExpectedBehavior`.

**Prevention**: Standardize on `MethodName_Scenario_ExpectedBehavior` pattern. AI agents should follow this convention.

### 16. Mock Framework Expression Gotchas
**What it is**: Using language defaults or implicit values in mock framework setup expressions where the framework requires explicit matchers.

**What happens**: Unexpected compiler errors or runtime failures in test setup. The same code works outside of mock expressions but fails inside them due to framework-specific limitations (e.g., expression tree constraints in C# Moq, argument matcher scope in Java Mockito, or mock resolution in Python unittest.mock).

**Prevention**: Always use the mock framework's explicit matchers. When in doubt, be explicit rather than relying on defaults.

---

## The Pattern Behind the Patterns

Every anti-pattern here shares a root cause: **insufficient context before action.**

- Blind Conversion → no comprehension of source intent
- Double-Retry → no knowledge of library behavior
- Magic Strings → no centralized source of truth
- Cross-Partition Queries → no understanding of data architecture

The methodology's answer is always the same: **understand first, then act.** Deep Onboarding exists because every other anti-pattern becomes less likely when you start with comprehensive understanding.

---

→ [The Methodology](methodology.md) — The practices that prevent these
→ [Case Studies](case-studies.md) — Real instances of these anti-patterns (and recoveries)
→ [Team Onboarding](team-onboarding.md) — Teaching your team to avoid them
