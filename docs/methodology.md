# The Methodology

### Six practices for AI-assisted development at enterprise scale

> *Extracted from 72 AI development sessions across 40+ production microservices. Each practice was developed iteratively and validated across multiple production projects.*

---

## Overview

```
┌─────────────┐     ┌──────────────┐     ┌─────────────────┐
│    Deep      │     │    Build     │     │    Expert        │
│  Onboard     │ ──→ │  (generate)  │ ──→ │  Review ×5+      │
│ (understand) │     │              │     │                  │
└─────────────┘     └──────────────┘     └──────┬──────────┘
                                                 │
                    ┌──────────────┐     ┌───────▼──────────┐
                    │    Ship      │ ◀── │     Fix          │
                    │  (deploy)    │     │   (iterate)      │
                    └──────────────┘     └──────────────────┘
```

The cycle is simple: **Understand → Build → Review → Fix → Ship.** The discipline is in the details.

---

## 1. Deep Onboarding

### The Principle

> *"Never modify code you haven't fully understood."*

Before any modification to a repository — a bug fix, feature addition, refactoring, or migration — execute a structured comprehension protocol. The AI reads every file, documents every function, and maps every dependency. The engineer then reviews and validates the AI's understanding, correcting misinterpretations, confirming business logic, and annotating gaps.

### The Protocol

Provide the AI with this structured prompt:

```
Role: Act as a Senior Software Architect and Lead System Engineer.
You are performing a "Deep Onboarding" of this repository.
Your goal is to achieve 100% technical mastery of this codebase.

Task: Perform an exhaustive, file-by-file and logic-by-logic audit.
Do not summarize; detail everything.

This is your integration roadmap — the same context any new architect
needs, but built for an AI agent.
```

### The 8-Document Output

The protocol produces a standardized mastery suite:

| # | Document | Purpose |
|---|----------|---------|
| 1 | **Master Context Manifest** | Project identity, purpose, ownership, tech stack |
| 2 | **Architecture Deep Dive** | Component diagrams, data flows, layer dependencies |
| 3 | **Codebase Walkthrough** | File-by-file technical audit of every module |
| 4 | **Integration Points** | External dependencies, API contracts, message schemas |
| 5 | **Configuration Guide** | Environment-specific settings, secrets, feature flags |
| 6 | **Testing Strategy** | Unit, integration, E2E approaches and coverage gaps |
| 7 | **Deployment Runbook** | CI/CD pipeline, rollback procedures, environment promotion |
| 8 | **Known Issues & Technical Debt** | Documented gaps, workarounds, improvement areas |

### Why It Works

- **Surfaces undocumented dependencies**: In every application of Deep Onboarding (15+ repositories), the process discovered integration paths, configuration dependencies, or cross-service inconsistencies not captured in any existing documentation.
- **Builds shared context**: The 8-document suite becomes the project's living knowledge base, useful for both AI agents and human engineers joining the team.
- **Prevents blind modifications**: Understanding-first means changes are surgical, not speculative.

### When to Use It

- **First time touching a repository** — Always. No exceptions.
- **Before a major refactoring** — Re-onboard to catch state drift since last review.
- **Before a migration** — Document source logic exhaustively before building target.
- **Quarterly refresh** — Codebases evolve. Deep Onboarding should be a recurring practice.

### Anti-Pattern: Skipping Comprehension

In Session 30 (of 72), a code conversion was attempted without deep understanding of the original. The AI generated code that compiled, passed linting, and looked correct — but contained fundamentally different business logic. The failure wasn't in the AI's code generation. It was in the absence of a comprehension phase.

---

## 2. Build-Review-Iterate

### The Principle

> *"AI output is a draft, not gospel. 5+ review rounds before human review."*

After generating code, the same AI is re-tasked as an expert reviewer with explicit instructions for maximum scrutiny. This mode-switching is essential — the AI identifies its own omissions from a review perspective that it missed during generation.

### The Protocol

**Step 1: Generate**
Direct the AI to implement the feature using appropriate architecture patterns.

**Step 2: Switch to Review Mode**
```
Act as an expert code reviewer. Review the code you just generated 
with the highest level of scrutiny. For each finding:

- Severity: Critical / High / Medium / Low
- File and line number
- Issue description
- Suggested fix

Focus on: security, performance, error handling, naming conventions,
architecture compliance, edge cases, and production readiness.
```

**Step 3: Fix All Findings**
Address every finding, including Low severity items during early rounds.

**Step 4: Re-Review**
Run the review again. Aim for <3 findings per round.

**Step 5: Human Review**
Only after 5+ AI review rounds with diminishing findings, submit for human PR review.

### Evidence

| Session | Feature | Review Rounds | Findings Caught |
|---------|---------|---------------|-----------------|
| CI/CD Pipeline Build | Deploy + Rollback workflows | 5 | 45+ issues: security gaps, edge cases, naming violations |
| Middleware Elimination | Direct API integration | 5 | OAuth retry, duplicate retry conflict, concern separation |
| Financial Processing | Outbox pattern + Change Feed | 3+ | Batch optimization, error handling, flag race conditions |
| Multi-Destination Bridge | Event delivery to 3 systems | 5 | Retry edge cases, XML mapping bugs, flag race conditions |

### Why Mode-Switching Works

When an AI generates code, it's optimizing for completion — making choices that move toward a working implementation. When the same AI reviews that code, it's optimizing for correctness — looking for violations, edge cases, and gaps. These are fundamentally different objectives, and the tension between them produces better code than either alone.

---

## 3. Revert-Prove-Rebuild

### The Principle

> *"When AI output is suspect, prove the original works first."*

When modifying existing code and the results are unexpected, don't debug the AI's changes. Instead:

### The Protocol

```
1. REVERT:  git stash (save AI changes)
2. PROVE:   Run the same tests/analysis on the original code
3. COMPARE: If original works and AI version doesn't → AI introduced the bug
4. REBUILD: From original source, line-by-line, with zero assumptions
```

### Origin Story

A Python-to-TypeScript conversion. The AI generated code that compiled and passed linting. It produced 409 errors that the original Python code never generated. The AI hadn't converted — it had *reimagined*, filling understanding gaps with plausible but incorrect logic.

The fix:
```
> "I stashed all your new changes. Now run the analysis with the old 
>  code and see if that works. If you are right, you should see the 
>  same issues. If you don't see the same issues, it's your code."
```

The original code worked perfectly. The AI had introduced the bug.

From that point forward: never trust "conversion" — always validate against the original.

### When to Apply

- **Every code conversion** (language migration, framework upgrade)
- **Every refactoring** that changes behavior, not just structure
- **Any time results don't match expectations** after AI modifications
- **As preventive practice**: Stash → verify baseline → pop → compare diffs

The protocol adds approximately 10 minutes of validation time and has prevented multiple production defects.

---

## 4. Multi-Agent Orchestration

### The Principle

> *"Independent tasks run in parallel; dependent tasks run sequentially."*

For complex features, decompose work into a dependency graph. Run independent workstreams through parallel AI agents.

### Patterns

**Repository-Parallel Deep Onboarding**
A single directive triggers Deep Onboarding across multiple repositories simultaneously:
```
Deep Onboard app-service-a, app-service-b, and app-service-c in parallel.
For each, produce the 8-document mastery suite. Then synthesize:
- Cross-service dependencies
- Shared database containers
- Common Kafka topics
- Naming inconsistencies
```

**Concurrent Validation**
During application development, separate agents validate independent dimensions:
- Agent 1: Internationalization across 3 languages
- Agent 2: Security review (OWASP Top 10)
- Agent 3: Performance profiling

**Analysis + Generation**
- Agent 1: Analyze real production message data from a streaming topic
- Agent 2: Generate the consumer application based on the expected schema from Agent 1's analysis

### The Dependency Graph Rule

Decomposing work into dependency graphs is not overhead — it's architecture. It forces you to answer: "What depends on what?" Before any multi-agent session, draw the DAG:

```
Deep Onboard (A, B, C)          ← Parallel (independent repos)
        │
        ▼
Build shared models              ← Sequential (depends on onboarding)
        │
    ┌───┴───┐
    ▼       ▼
Build A   Build B                ← Parallel (independent features)
    │       │
    └───┬───┘
        ▼
Integration test (A + B)        ← Sequential (depends on both builds)
        │
        ▼
Expert review                    ← Sequential (depends on integration)
```

---

## 5. Documentation as Deliverable

### The Principle

> *"Architecture diagrams and runbooks are deliverables, not extras."*

Every major AI session produces documentation artifacts as primary outputs, not afterthoughts. Because the AI already holds full project context from Deep Onboarding, documentation generation consumes approximately 5% of session time.

### Standard Artifacts

| Artifact | When | Purpose |
|----------|------|---------|
| Architecture diagram (Mermaid) | After Deep Onboarding | Visual system understanding |
| Integration mapping document | Before migration | All external dependencies documented |
| Deployment plan of action | Before deploy | Step-by-step with rollback criteria |
| Acceptance criteria | Before feature complete | Testable requirements |
| Team communication | After breaking changes | Plain-language explanation of what changed and why |

### Example

Eliminating a middleware API layer (229 messages) produced:
1. Complete codebase audit of the middleware's logic
2. Integration mapping document (all inputs, outputs, transforms)
3. The actual code migration (direct API integration)
4. Test coverage for every migrated endpoint
5. Deployment plan with rollback steps
6. Team communication explaining the architectural change

The documentation wasn't extra work — it was generated as a natural byproduct of the AI having full project context.

---

## 6. Dead Letter Queue Everything

### The Principle

> *"Every message consumer needs a dead letter queue. No exceptions."*

When a message consumer fails to process a message, it must route the failed message to a DLQ topic with:
- The original payload (unchanged)
- Error metadata (exception message, stack trace summary)
- Retry context (original topic, partition, offset, retry count)
- Timestamp of failure

### Why This Is Non-Negotiable

Silent message drops are the most dangerous failure mode in event-driven systems. They don't trigger alerts, don't appear in dashboards, and don't show up until a downstream system reports missing data — hours or days later.

### DLQ Pattern

```
Consumer → Process Message
  │
  ├── SUCCESS → Commit offset, continue
  │
  └── FAILURE → Publish to DLQ topic with metadata:
                  - originalTopic
                  - originalPartition
                  - originalOffset
                  - errorMessage
                  - failedAt (ISO 8601)
                  - retryCount
                  
                Log at ERROR level → Continue consuming
```

### Operational Impact

DLQ topics provide:
- **No silent data loss**: Every failure is captured and queryable
- **Reprocessing capability**: Failed messages can be replayed after fixes
- **Forensic analysis**: Error patterns reveal systemic issues (e.g., schema mismatches, upstream data quality)
- **Alerting integration**: DLQ message rates trigger automated alerts

---

## The 10 Commandments

The methodology distilled into a quick-reference card:

| # | Commandment | One-Liner |
|---|-------------|-----------|
| 1 | **Deep Onboard First** | Never modify code you haven't fully understood |
| 2 | **Trust but Verify** | AI output is a draft — stash, prove original works, then rebuild |
| 3 | **Review Your Own Code** | 5+ AI review rounds for critical paths before human review |
| 4 | **Never Double-Retry** | If the library retries natively, don't add application-level retry |
| 5 | **Document as You Build** | Architecture diagrams and runbooks are deliverables, not extras |
| 6 | **One-Click or It Doesn't Count** | Setup must be a single command |
| 7 | **DLQ Everything** | Every message consumer needs a dead letter queue |
| 8 | **Hash Before You Process** | SHA-256 delta detection to avoid redundant work |
| 9 | **Dry-Run Before Live** | Data migration tools must have `--dry-run` mode |
| 10 | **Pin Your Dependencies** | SHA-pinned actions, version-locked packages, no floating refs |

---

## Applying This to Your Stack

The methodology is tech-stack-agnostic. Here's how to adapt it:

### For Any Language/Framework
1. **Copy `templates/copilot-instructions.md`** and customize for your stack
2. **Define your layer rules**: What calls what? What's forbidden?
3. **Set your DI pattern**: Match your project's existing convention
4. **List your naming conventions**: Namespaces, classes, methods, tests
5. **Document your anti-patterns**: What specific mistakes does your stack invite?

### For Any Cloud Provider
1. **Map your data layer**: What's the equivalent of Cosmos DB / DynamoDB / Firestore?
2. **Map your streaming layer**: Kafka / EventBridge / Pub/Sub?
3. **Map your CI/CD**: GitHub Actions / GitLab CI / CircleCI / Jenkins?
4. **Map your IaC**: Pulumi / Terraform / CDK / CloudFormation?

### For Any Team Size
| Team Size | Starting Point |
|-----------|---------------|
| Solo engineer | Deep Onboarding + Build-Review-Iterate on your primary repo |
| Small team (3-5) | Add Revert-Prove-Rebuild + shared `copilot-instructions.md` |
| Medium team (6-15) | Full 6-week onboarding plan + standardized agent library |
| Large team (15+) | Multi-agent orchestration + centralized instruction distribution |

---

*Every practice in this document exists because its absence caused a problem. Every commandment was broken before it was written.*

→ [See the evidence: Case Studies](case-studies.md)
→ [Roll it out: Team Onboarding Plan](team-onboarding.md)
→ [Learn from failures: Anti-Patterns](anti-patterns.md)
