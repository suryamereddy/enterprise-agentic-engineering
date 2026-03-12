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

**Real example**: Modifications to a service's consumer configuration caused offset management failures because the worker's Kafka initializer relied on Azure App Configuration settings that weren't documented anywhere — only discoverable through exhaustive file reading.

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

**Real example**: A Kafka producer had both librdkafka native retry AND Polly retry configured. A downstream service outage caused 9x the expected load when message delivery resumed, triggering cascading failures.

**Prevention**: Before adding retry logic, check if the underlying library has native retry. If it does, only handle the *final* failure at the application level.

```
❌ WRONG — Library already retries
retryPolicy.ExecuteAsync(() => producer.ProduceAsync(topic, message));

✅ CORRECT — Handle only final failure
try { await producer.ProduceAsync(topic, message); }
catch (ProduceException ex) { await PublishToDlqAsync(message, ex); }
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

### 9. Mixing Dependency Injection Patterns
**What it is**: Using Constructor DI in a project that uses the Factory pattern (or vice versa).

**What happens**: Inconsistent service resolution. Some services are resolved via `UtilityFactory.ResolveRequiredService<T>()`, others via constructor injection. New team members can't predict which pattern applies. Testing becomes harder because Moq and factory resolution require different setup.

**Prevention**: Match the project's existing pattern. Always. If the project has `FactoryBase`, use Factory. If it has `*Resolver.cs`, use Constructor DI. Never introduce a different pattern.

---

### 10. Cross-Partition Database Queries
**What it is**: Querying a partitioned database (Cosmos DB, DynamoDB, etc.) without specifying the partition key.

**What happens**: The query scans every partition — dramatically increasing cost and latency. A query that should cost 5 RUs and take 10ms instead costs 500 RUs and takes 2 seconds.

**Prevention**: Always specify partition key in every query. AI agents should be instructed to flag any query that doesn't include a partition key.

---

### 11. Sync-over-Async
**What it is**: Using `.Result` or `.Wait()` on async operations instead of `await`.

**What happens**: Thread pool starvation under load. Deadlocks in UI contexts. Performance degradation that only appears under high concurrency — invisible in development, catastrophic in production.

**Prevention**: Async all the way down. Every I/O method is async, every consumer `await`s it, all the way to the entry point. AI agents should be instructed to flag any `.Result` or `.Wait()` call.

---

### 12. Logging Secrets
**What it is**: Writing tokens, connection strings, or PII to log output.

**What happens**: Secrets appear in log aggregation systems where they're visible to anyone with log access. Connection strings in Application Insights. Bearer tokens in CloudWatch.

**Prevention**: Structured logging with explicit field selection. Never log raw request/response bodies that might contain credentials. AI agents should be instructed to flag any `_logger.Log*` call that includes a variable named `token`, `password`, `connectionString`, or `secret`.

---

### 13. Milestone/Pre-Release Dependencies
**What it is**: Using milestone or pre-release versions of dependencies in production code.

**What happens**: Breaking changes between milestone and GA. In one case, a Spring Framework milestone (M8) worked, but the GA release (7.0.2) removed a `MethodSecurityMetadataSource` class entirely — breaking authentication with no migration path.

**Prevention**: Only GA releases in production. If a milestone feature is needed, pin the exact pre-release version and document the migration plan for when GA ships.

---

## Low Severity (But Pernicious) Anti-Patterns

### 14. Assumption-Based Coding
**What it is**: AI assumes business logic when the specification is unclear, instead of asking for clarification.

**Prevention**: Instruct AI: *"If you don't know, say you don't know. Don't fill gaps with assumptions."*

### 15. Test Names Without Context
**What it is**: Test method names like `Test1()` or `ProcessTestAsync()` instead of `MethodName_Scenario_ExpectedBehavior`.

**Prevention**: Standardize on `MethodName_Scenario_ExpectedBehavior` pattern. AI agents should follow this convention.

### 16. Moq Expression Tree Gotcha
**What it is**: Using `default` for optional parameters in Moq Setup/Verify expressions.

**What happens**: Compiler error CS0854 — expression tree limitation. Confusing because the same code works outside of Moq lambdas.

**Prevention**: Always use `It.IsAny<T>()` instead of `default` in Moq expressions.

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
