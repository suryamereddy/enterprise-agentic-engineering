# GitHub Copilot Instructions — Enterprise Agentic Engineering

> This file configures AI assistants working within this repository.

## Repository Context

This is a public thought leadership repository documenting a methodology for structured AI-assisted enterprise software development. It is NOT a code repository — it contains documentation, agent configurations, and templates.

## Content Standards

- All content is vendor-agnostic where possible
- Enterprise references are anonymized — no company names, team members, or internal system names
- Technologies mentioned (Azure, .NET, Confluent Kafka, etc.) are public vendor names and acceptable
- Case studies use anonymized project names ("The Colossus", "The Humbling", etc.)

## When Editing Content

- Maintain the "This Is Not Vibe Coding" branding and anti-hype positioning
- Keep evidence-based claims (session counts, message counts, metrics)
- Preserve the 6-practice methodology structure
- Preserve the 10 Commandments
- Do not introduce enterprise-specific details

## When Creating New Agent Files

- Follow existing frontmatter format (YAML with name, description, tools, model)
- Copilot prompts: `agents/copilot/*.prompt.md`
- Claude agents: `agents/claude/*.md`
- Keep agent instructions actionable and protocol-driven
- Include severity ratings in review agents
- Include checklists in builder agents

## File Organization

```
README.md              — Hero landing page
MANIFESTO.md           — Philosophical foundation
docs/                  — Deep reference materials
agents/copilot/        — VS Code Copilot prompt files
agents/claude/         — Claude Code agent files
templates/             — Customizable starter templates
```
