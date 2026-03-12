# Prompt Library

> A consolidated reference of every prompt pattern in this framework, organized by workflow stage.
> Copy these into your AI tools (Copilot, Claude, ChatGPT) as starting points.

---

## Table of Contents

1. [Deep Onboarding Prompts](#1-deep-onboarding-prompts)
2. [Build & Implement Prompts](#2-build--implement-prompts)
3. [Review Prompts](#3-review-prompts)
4. [Testing Prompts](#4-testing-prompts)
5. [Debug & Investigation Prompts](#5-debug--investigation-prompts)
6. [Infrastructure & CI/CD Prompts](#6-infrastructure--cicd-prompts)
7. [Migration Prompts](#7-migration-prompts)
8. [Meta Prompts](#8-meta-prompts)

---

## 1. Deep Onboarding Prompts

### Full Repository Onboarding

```
Perform a complete Deep Onboarding of this repository. Generate the 8-document suite:
1. Master Context Manifest
2. Architecture Deep Dive (with Mermaid diagrams)
3. File-by-file Codebase Walkthrough
4. Integration Points inventory
5. Configuration Guide
6. Testing Strategy assessment
7. Deployment Runbook
8. Known Issues & Technical Debt

For every file: document purpose, key classes/methods, dependencies, and test coverage.
Do not skip files. Do not abbreviate.
```

### Targeted Module Onboarding

```
Deep Onboard the [MODULE_NAME] module specifically:
- What does it do?
- What are its dependencies?
- What calls it?
- What are its configuration requirements?
- What's its test coverage?
- What are its known issues?

Read every file in the module before answering.
```

### Pre-Modification Comprehension Check

```
Before I modify [FILE_PATH], I need complete understanding:
1. Read the entire file
2. Trace all callers (what invokes this code?)
3. Trace all callees (what does this code invoke?)
4. What configuration does it depend on?
5. What tests cover this code?
6. What would break if I change the signature of [METHOD_NAME]?
```

---

## 2. Build & Implement Prompts

### New Feature Implementation

```
Implement [FEATURE_DESCRIPTION] following the established architecture:
1. Read existing code patterns first
2. Match the DI pattern already used in this project
3. Create interfaces/contracts in the appropriate module
4. Implement in the appropriate layer
5. Register dependencies
6. Write unit tests (80%+ coverage)
7. Update configuration if needed

Follow naming conventions. No magic strings. Async all the way.
```

### New Service/Consumer

```
Create a new [message consumer / HTTP endpoint / background service] for [PURPOSE]:
1. Follow the layered architecture (Client → Manager → Engine → Accessor)
2. Include DLQ handling for any message processing
3. Include health check endpoints
4. Include correlation ID propagation
5. Include structured logging at boundaries
6. Create unit tests for all layers
7. Update configuration constants

Show me the complete implementation across all layers.
```

### Build-Review-Iterate Cycle

```
I've implemented [FEATURE]. Now:
1. Switch to Expert Reviewer mode
2. Conduct 5 review rounds (Architecture, Security, Resilience, Performance, Testing)
3. Report all findings by severity
4. After I acknowledge, fix all Critical and High issues
5. Repeat the review on the fixed code
6. Continue until no Critical/High findings remain
```

---

## 3. Review Prompts

### 5-Round Expert Review

```
Review all changes in [FILE_LIST / PR / BRANCH]:

Round 1: Architecture & Pattern Compliance
Round 2: Security (OWASP Top 10, input validation, secrets)
Round 3: Error Handling & Resilience (DLQ, circuit breaker, no double-retry)
Round 4: Performance (async, connection pooling, partition keys)
Round 5: Testing & Maintainability (coverage, naming, constants)

For each finding: Severity | File | Issue | Fix | Pattern violated
```

### Security-Focused Review

```
Security audit of [FILE_LIST]:
- Input validation on all external data
- No secrets in code or logs
- Proper auth token handling
- Safe deserialization
- SHA-pinned dependencies
- No SQL/NoSQL injection vectors
- OWASP Top 10 compliance check

Rate each finding: Critical / High / Medium / Low with CWE reference.
```

### Pre-Merge Checklist

```
Pre-merge review for [BRANCH]:
- [ ] All tests passing
- [ ] No new warnings introduced
- [ ] Constants used (no magic strings)
- [ ] Async all the way (no blocking on async operations)
- [ ] DLQ for any new consumers
- [ ] Partition key in all DB queries
- [ ] Structured logging at boundaries
- [ ] SHA-pinned any new action references
- [ ] Documentation updated
- [ ] Configuration changes documented

Flag any unchecked items.
```

---

## 4. Testing Prompts

### Generate Comprehensive Tests

```
Generate unit tests for [CLASS_NAME]:
1. One test class per source class
2. Test naming: MethodName_Scenario_ExpectedBehavior
3. Structure: Arrange / Act / Assert

Required scenarios for each public method:
- Happy path (valid input → expected output)
- Null/empty input handling
- Boundary values
- Error paths (dependency failures)
- DLQ scenarios (for consumers)

Use [MOCK_FRAMEWORK] for dependencies. Use explicit argument matchers (never literal defaults that cause framework errors).
80%+ coverage minimum.
```

### Test Gap Analysis

```
Analyze test coverage for [PROJECT]:
1. List all public methods in source code
2. List all existing test methods
3. Identify untested methods
4. Identify untested scenarios (null paths, error paths, boundaries)
5. Prioritize gaps by risk (critical paths first)
6. Generate skeleton tests for the top 10 gaps
```

---

## 5. Debug & Investigation Prompts

### Bug Investigation Protocol

```
Investigate the bug: [DESCRIPTION]

Follow the 6-step protocol:
1. REPRODUCE: Identify exact conditions that trigger the bug
2. ISOLATE: Narrow to the specific component/method
3. ROOT CAUSE: Trace the execution path to find the actual cause
4. FIX: Implement the minimal fix (not a rewrite)
5. VERIFY: Write a test that would have caught this
6. PROTECT: Add regression test to prevent recurrence

If you suspect the fix but aren't certain: stash the current changes, prove the root cause against the original code, then apply the fix.
```

### The Stash-and-Prove Pattern

```
I suspect [HYPOTHESIS] is causing [ISSUE].

Before fixing:
1. Document the current behavior
2. Write a test that reproduces the bug
3. Verify the test fails
4. Only THEN implement the fix
5. Verify the test now passes
6. Check no other tests broke

Never trust a fix you can't prove.
```

---

## 6. Infrastructure & CI/CD Prompts

### New Pipeline

```
Create a CI/CD pipeline for [PROJECT]:
- Build → Test → Analyze → Publish → Deploy
- SHA-pin ALL third-party actions
- OIDC authentication (no PATs)
- Unit tests only in CI (separate integration workflow)
- Quality gates on PR
- Deploy workflow with manual approval gates
- Paired rollback workflow

Include environment-specific configs for [dev/qa/prod].
```

### Infrastructure Provisioning

```
Provision infrastructure for [SERVICE]:
Required resources: [LIST]

Rules:
- Naming: {type}-{app}-{env}
- All resources tagged: application, environment, team, managed-by
- Secrets in Key Vault / secret manager only
- Managed identity for service auth
- Monitoring and alerting configured
- Environment configs: dev, qa, prod (identical code, different values)
- Rollback procedure documented
```

---

## 7. Migration Prompts

### API Layer Migration

```
Migrate [API_NAME] from [MIDDLEWARE] to native implementation:

Phase 1: Analyze existing endpoints (routes, methods, payloads)
Phase 2: Map each endpoint to target architecture layers
Phase 3: Implement in order of traffic volume × maintenance cost
Phase 4: Create contract tests ensuring parity
Phase 5: Parallel running with traffic comparison
Phase 6: Cutover with instant rollback capability
Phase 7: Decommission old endpoints

Priority = traffic × cost. Start with highest priority endpoints.
```

### Database Migration

```
Migrate data from [SOURCE] to [TARGET]:

Requirements:
1. Dry-run mode (validate without writing)
2. Batch processing with configurable size
3. Delta detection (skip unchanged records)
4. Rollback capability at any point
5. Progress tracking with ETA
6. Error collection (don't stop on single failure)
7. Audit log of all operations

Show me the implementation with all safety controls.
```

---

## 8. Meta Prompts

### Agent Role Assignment

```
You are now operating as a [ROLE]:
- Deep Onboarder: Exhaustive codebase comprehension
- Expert Reviewer: 5-round multi-dimensional review
- Security Reviewer: OWASP-focused vulnerability assessment
- Performance Reviewer: Scalability and efficiency analysis
- Bug Investigator: 6-step root cause analysis
- Pipeline Engineer: CI/CD with security best practices

Maintain this role until I say "switch role" or "reset".
```

### Session Kickoff

```
Starting a new session on [PROJECT]:
1. Read the project's AI instruction file
2. Read the README
3. Understand the current state of the codebase
4. List any recent changes or open issues
5. Confirm your understanding before I give you tasks

Context: [BRIEF_DESCRIPTION_OF_WHAT_WE'RE_WORKING_ON]
```

---

## Tips for Effective Prompting

1. **Be specific about the output format** — tables, code blocks, checklists, Mermaid diagrams
2. **Provide file paths** — Always reference exact files, don't make the AI guess
3. **Set the review depth** — "Quick scan" vs "exhaustive review" vs "5 rounds"
4. **Chain the workflow** — Build → Review → Fix → Review → Ship (not Build → Ship)
5. **Use role assignment** — "You are a security specialist" focuses the response
6. **Reference existing patterns** — "Follow the pattern in [existing_file]" beats describing from scratch
7. **Demand evidence** — "Show me the test that proves this works" before accepting any fix

---

*These prompts are extracted from 72 production development sessions. They work because they encode specific failure modes and their solutions, not generic advice.*
