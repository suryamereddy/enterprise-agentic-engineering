---
description: "Validate every Mermaid diagram in repo Markdown locally with the real parser (mermaid@11 + jsdom, no Chromium) before pushing"
agent: "agent"
tools: ["search/codebase", "search", "execute/runInTerminal"]
---

# Validate Mermaid diagrams locally — ${input:glob:docs/**/*.md}

GitHub's Mermaid renderer fails on syntax the editor accepts. Validate with the real parser before pushing.

## Steps

1. Extract every ` ```mermaid ` block to `[{file,startLine,code}]`.
2. Set up the parser (~2s):
```bash
mkdir -p /tmp/mmval && cd /tmp/mmval && npm i mermaid@11 jsdom >/dev/null 2>&1
```
3. Node ESM validator (`/tmp/mmval/val.mjs`):
```javascript
import { JSDOM } from 'jsdom';
import mermaid from 'mermaid';
const { window } = new JSDOM('<!DOCTYPE html><body></body>');
globalThis.window = window;
globalThis.document = window.document;
// DO NOT set globalThis.navigator — it's a read-only getter on Node 25 and throws.
mermaid.initialize({ startOnLoad: false, securityLevel: 'loose' });
const blocks = JSON.parse(process.argv[2]); // [{file,startLine,code}]
let fail = 0;
for (const b of blocks) {
  try { await mermaid.parse(b.code); }
  catch (e) { fail++; console.log(`FAIL ${b.file}:${b.startLine} — ${String(e).split('\n')[0]}`); }
}
console.log(fail ? `\n${fail} diagram(s) failed` : 'All diagrams parse OK');
process.exit(fail ? 1 : 0);
```
4. Run it with the extracted JSON.

## Most common breaker

A **`;` inside a label/message** — GitHub treats it as a statement separator (e.g. `A->>B: foo (x; y)` breaks a sequenceDiagram). Also avoid `{ }` inside quoted flowchart labels. Replace `;` with `,` or `—`.

> Verify diagrams render — don't assume. The in-editor preview and GitHub's renderer disagree on edge cases, and a parse error silently drops the diagram on GitHub.
