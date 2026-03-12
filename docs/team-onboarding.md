# Team Onboarding Plan

### Getting your team productive with AI-assisted development in 6 weeks

> *This plan was developed through actual organizational rollout at a Fortune 500 enterprise. Each week builds on the previous, progressing from individual comprehension to team-scale orchestration.*

---

## Prerequisites

Before starting the 6-week program:

1. **AI tooling installed**: GitHub Copilot + Copilot Chat (or equivalent)
2. **`copilot-instructions.md` deployed**: Customize `templates/copilot-instructions.md` for your stack and place at `.github/copilot-instructions.md` in your workspace root
3. **Methodology Cheat Sheet printed**: Give every participant a physical copy of the 10 Commandments
4. **Primary repo identified**: Each engineer picks the repo they'll work in throughout the program

---

## Week 1: Deep Onboarding — Understanding First

### Objective
Learn to comprehend codebases through structured AI collaboration before making any modifications.

### Day 1–2: Setup & Orientation
1. Verify AI tooling works in your IDE
2. Read the [Manifesto](../MANIFESTO.md) — understand *why* structured AI engineering matters
3. Read the [10 Commandments](../docs/methodology.md#the-10-commandments) — print and pin at your desk

### Day 3–5: First Deep Onboarding
1. Open your team's primary repository
2. Use the [Deep Onboarding prompt](../agents/copilot/deep-onboarding.prompt.md) 
3. Let the AI generate the 8-document mastery suite
4. **Read every document critically** — this is your knowledge validation exercise
5. Mark everything the AI got wrong, missed, or misunderstood

### Homework
- Complete Deep Onboarding of one repo
- Write a 1-page report: What did the AI understand correctly? What did it miss? What did it get wrong?
- Share findings with the team

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| Completed suite with >20 corrections | Completed suite with <10 corrections | Completed suite with <3 corrections |

---

## Week 2: Build-Review-Iterate — Quality Through Cycles

### Objective
Learn to use AI as both generator and reviewer, building the habit of structured multi-round review.

### The Pattern
```
Build (AI generates code)
  → Review (AI reviews with maximum scrutiny)
    → Fix (address all findings)
      → Re-Review (AI confirms fixes)
        → …repeat until <3 findings…
          → Human Review (final sign-off)
            → Ship
```

### Exercise
1. Pick a small feature or bug fix in your repo
2. Let AI build it
3. **Immediately** run Expert Review on the generated code using the [expert-review prompt](../agents/copilot/expert-review.prompt.md)
4. Fix every finding — don't skip Low severity items in early rounds
5. Run review again — aim for diminishing findings each round
6. Only after 3+ rounds, submit for human PR review

### Key Lesson
> *"AI output is a draft, not gospel."*
>
> In a tracked production incident, AI-generated code passed visual inspection 
> but contained different business logic than the original. The fix: always 
> verify, never assume correctness.

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| 1 AI review round before human | 3 AI review rounds | 5+ rounds with <3 findings in final |

---

## Week 3: Revert-Prove-Rebuild — Trust Through Verification

### Objective
Build the muscle memory for verifying AI output against original behavior before accepting changes.

### The Stash-and-Prove Protocol
```bash
# 1. Make your AI modifications
# 2. Stash them before testing
git stash

# 3. Run tests on the ORIGINAL code
# Use your project's test command:
#   dotnet test | mvn test | pytest | npm test | go test ./...
your-test-command

# 4. Does the original work as expected?
# YES → Your AI changes might have introduced a bug
# NO  → The bug was pre-existing

# 5. Restore your changes
git stash pop

# 6. Run the same tests
your-test-command

# 7. Compare results — understand every difference
```

### Exercise
1. Ask AI to refactor a method in your repo
2. Before accepting, stash and verify original behavior
3. Compare: Is the refactoring correct? Safe? Complete?
4. Did the AI introduce any subtle changes you didn't ask for?

### Common AI Mistakes to Watch For
- Changing error handling behavior (swallowing vs propagating exceptions)
- Altering retry/timeout configurations
- Adding or removing null checks that change control flow
- Renaming variables in ways that break reflection/serialization
- "Improving" code by changing its behavior

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| Applied protocol once with guidance | Applied independently on 3+ changes | Catches AI-introduced behavior changes before testing |

---

## Week 4: Production Data Analysis — AI as Forensic Tool

### Objective
Learn to use AI for safe analysis of production-adjacent data (database containers, message topics, logs).

### The Dry-Run Rule
> **ALWAYS dry-run first.** Never modify production data without preview.

### Exercise
1. Pick a development/QA database container
2. Use AI to analyze data distribution:
   - How many records? What's the partition key distribution?
   - Any hot partitions? Any orphan records?
   - What's the average document size?
3. Generate a findings report with recommendations

### Key Numbers to Know
| Metric | Healthy | Concerning |
|--------|---------|-----------|
| Database RU/s utilization | < 80% provisioned | > 90% (throttling risk) |
| Message consumer lag | < 1,000 messages | > 10,000 (falling behind) |
| DLQ message rate | < 0.1% of throughput | > 1% (systemic issue) |
| Test coverage (new code) | > 80% | < 60% |

### Safety Rules
- Use temporary consumer groups for streaming topic analysis (don't disturb active consumers)
- Query replicas when available, not primary
- Never run DELETE operations without preview + confirmation
- Log every data operation for audit trail

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| Analyzed 1 container with guidance | Independent analysis with findings report | Identified and resolved a data quality issue |

---

## Week 5: Multi-Agent Orchestration — Scaling AI Work

### Objective
Learn to decompose complex tasks into parallel workstreams directed by multiple AI agents.

### Pattern: Sequential Agent Pipeline
```
1. DeepOnboarder    → Understand the codebase
2. Build the feature (using build-from-scratch prompt)
3. TestGenerator    → Generate comprehensive tests
4. ExpertReviewer   → Multi-round review
5. PipelineEngineer → Verify CI/CD
```

### Pattern: Parallel Exploration
```
Explore service-a, service-b, and service-c in parallel.
For each, identify:
- Message topics consumed and produced
- Database containers used
- External APIs called
Synthesize into a cross-service dependency map.
```

### Exercise
1. Pick a feature that touches multiple services or layers
2. Use Deep Onboarding on each affected area (in parallel if independent)
3. Build the feature with cross-dependency awareness
4. Review with Expert Review
5. Document the cross-area integration

### The Dependency Graph Rule
Before starting parallel work, draw the dependency DAG:
```
Independent tasks → Run in parallel
Dependent tasks  → Run sequentially
```

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| Completed sequential pipeline | Ran 2 agents in parallel | Orchestrated 3+ agents with dependency management |

---

## Week 6: CI/CD & Operational Mastery

### Objective
Use AI to generate, review, and validate production-grade deployment infrastructure.

### Pipeline Generation
1. Use the [CI/CD pipeline prompt](../agents/copilot/cicd-pipeline.prompt.md) for new workflows
2. **Verify SHA-pinning**: Every third-party action must use a full commit SHA, not a version tag
3. **Verify credential security**: No PATs, no hardcoded tokens — OIDC/federated credentials only
4. **Verify rollback**: Every deploy workflow must have a corresponding rollback path

### Validation Commands
```bash
# Check for floating version references (should return nothing)
grep -r "@v[0-9]" .github/workflows/

# Check for hardcoded credentials (should return nothing)
grep -rE "PAT|TOKEN|password|secret" .github/workflows/ --include="*.yml"

# Check for missing SHA pins
grep -rE "uses:.*@(?!sha-)" .github/workflows/
```

### Exercise
1. Generate a CI/CD pipeline for your repo using the prompt
2. Run the validation commands above
3. Fix any findings through Build-Review-Iterate
4. Deploy to development environment, validate health endpoints

### Success Criteria
| Beginner | Intermediate | Expert |
|----------|-------------|--------|
| Generated pipeline with AI assistance | Pipeline passes all validation checks | Pipeline includes rollback + multi-env promotion |

---

## Measuring Success

### Individual Growth Metrics

| Metric | Week 1 | Week 3 | Week 6 |
|--------|--------|--------|--------|
| Deep Onboarding time (first repo) | 1 week | 2 days | 4 hours |
| Code review rounds before human | 1 AI round | 3 AI rounds | 5 AI rounds |
| Test coverage on AI-generated code | 60% | 80% | 95% |
| Time to deploy a new feature | 2 weeks | 1 week | 2 days |

### Team Health Metrics

| Metric | Baseline | 6-Week Target |
|--------|----------|--------------|
| PR review cycle time | 3 days | 1 day |
| Production incidents from new code | 2/month | 0/month |
| Repos with Deep Onboarding docs | 0–2 | All active repos |
| Engineers using Build-Review-Iterate | 0 | All team members |

---

## Post-Program: Sustaining the Practice

### Monthly
- **Deep Onboarding refresh** on repos with significant changes
- **Case study sharing**: Each team member presents one AI success/failure
- **Prompt library update**: New templates from discovered patterns

### Quarterly
- **Full portfolio Deep Onboarding** refresh
- **Methodology retrospective**: What's working? What needs adjustment?
- **Metric review**: Are the gains sustaining?

### Continuously
- **Every PR**: Minimum 3 AI review rounds before human review
- **Every conversion/migration**: Revert-Prove-Rebuild protocol applied
- **Every data operation**: Dry-run → verify → execute
- **Every new consumer**: DLQ implementation verified at code review

---

## Resources

| Resource | Location | Purpose |
|----------|----------|---------|
| The Methodology | [docs/methodology.md](methodology.md) | Complete 6-practice framework |
| The Manifesto | [MANIFESTO.md](../MANIFESTO.md) | Philosophical foundation |
| Case Studies | [docs/case-studies.md](case-studies.md) | Evidence and examples |
| Anti-Patterns | [docs/anti-patterns.md](anti-patterns.md) | What to avoid |
| Deep Onboarding Prompt | [agents/copilot/deep-onboarding.prompt.md](../agents/copilot/deep-onboarding.prompt.md) | Week 1 starting point |
| Expert Review Prompt | [agents/copilot/expert-review.prompt.md](../agents/copilot/expert-review.prompt.md) | Week 2 core tool |
| Instruction Template | [templates/copilot-instructions.md](../templates/copilot-instructions.md) | Customizable for your stack |

---

*This plan was battle-tested through actual organizational rollout. Adjust timelines for your team's pace, but preserve the sequence: **understand → review → verify → analyze → orchestrate → deploy**. Each week's skills are prerequisites for the next.*
