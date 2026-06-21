# Deck — *Not Vibe Coding: Native AI Engineering*

Slide deck for the 45-min talk, in three versions — a reveal.js **projector** deck (v1/v2) and a responsive **mobile** deck (v3). All are self-contained and work **fully offline** (reveal.js is vendored in `vendor/`; v3 has no dependencies).

Speaker script (verbatim words, timing, demo cues): [../2026-06-21-talk-FINAL.md](../2026-06-21-talk-FINAL.md)

## Versions

- **`index-v2.html` — v2 (current projector deck).** Self-contained **reveal.js** deck (vendored in `vendor/` — works fully offline, no CDN). Refined after a 3-expert panel review (Keynote Coach · Information Designer · Senior Skeptic). Changes: bigger fonts for back-row legibility, `center:false` to stop fragment-jump, the 99% story now resolves on-slide, spoken transitions + a hand-raise in the notes, the close broken into short beats, the yacht story reframed to teach, Werner jargon translated, and two new Q&A backup slides (harness-loop diagram + "Start Monday"). Full rationale: [../research/debate/SYNTHESIS-v2-debate.md](../research/debate/SYNTHESIS-v2-debate.md).
- **`index-v3.html` — v3 (mobile-friendly paged deck).** Same content as v2, but rebuilt as a **responsive paged deck** (no reveal.js, so it *reflows* instead of letterboxing on a phone). Advances **one slide at a time** — click the **› corner arrow** (reveal.js-style, bottom-right, just like v1/v2), swipe left/right, or use arrow keys / a presenter clicker. Each slide reflows to the screen (single-column on phones → multi-column on desktop, the harness loop goes vertical on mobile) and scrolls internally if it's tall. A subtle slide counter sits bottom-left; a top progress bar tracks position; deep-links via `#/<n>`; **Speaker notes** toggle (study mode, persisted). On phones the header shows just the title (the `· S. Mereddy` byline returns on desktop) so nothing truncates. Works offline and prints to PDF (all slides stacked).
- **`index-v1.html` — v1 (frozen snapshot).** The original reveal.js deck, kept for reference. Script snapshot: `../2026-06-21-talk-FINAL-v1.md`.

### Which one do I open?

| You want to… | Open | Navigate |
|---|---|---|
| Present on a projector / screen-share | `index-v2.html` (v2) | arrows · `S` = speaker view |
| Present or read on a phone/tablet | `index-v3.html` (v3) | › corner arrow · swipe · arrows · tap **Speaker notes** |
| Compare against the original | `index-v1.html` (v1) | arrows |

## Present it

- **Open:** double-click `index-v2.html` (works via `file://`) — or serve it: `python3 -m http.server 8911` then open `http://localhost:8911/index-v2.html`.
- **Fullscreen:** `F` · **Exit:** `Esc`
- **Speaker view (notes + timer + next-slide preview):** press `S` — opens a second window. Put that on your laptop, the deck on the projector. Every slide's notes hold the verbatim words + demo cues + safety reminders.
- **Navigate:** `→ / Space` next · `←` back · `Esc` slide overview · click the dots/arrows.
- **Fragments:** several slides reveal point-by-point on each `→`.

## Export a PDF backup (do this before you travel)

Open the v2 deck with `?print-pdf` and print to PDF from Chrome:

```
http://localhost:8911/index-v2.html?print-pdf
```
Chrome → Print → Destination: Save as PDF → Background graphics ON → Margins: None → Save. That PDF is your zero-dependency fallback if the laptop/projector misbehaves. (The v3 mobile deck also prints to PDF directly — all slides stack.)

## Host it for free (GitHub Pages)

> **Does pushing to a GitHub repo render the HTML?** **No — not by itself.** Opening an `.html` file on github.com shows the *source code* (or a raw blob), not the rendered page. To get a clickable, rendered URL you must enable **GitHub Pages** (free), which publishes the repo as a static website.

> ⚠️ **Security first — do NOT publish `agent-plans`.** This deck lives inside `agent-plans/`, which contains internal/work notes. GitHub Pages makes the published site **public even when the source repo is private** (private Pages needs a paid Enterprise plan). **Never enable Pages on the `agent-plans` repo** — copy *only* the `deck/` folder into a separate, dedicated repo.

**Recommended: a dedicated public repo with just the deck**

```bash
# from a throwaway working dir — copy ONLY the deck folder
cp -R "~/Git/agent-plans/conference-talk/deck" ./not-vibe-coding-deck
cd not-vibe-coding-deck
git init -b main
git add .
git commit -m "Not Vibe Coding — talk deck (v1/v2/v3)"
# create an EMPTY public repo on github.com first, then:
git remote add origin https://github.com/<you>/not-vibe-coding-deck.git
git push -u origin main
```
Then on github.com: **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: `main` / `/ (root)` → Save.** After ~1 min your URLs are live:

- `https://<you>.github.io/not-vibe-coding-deck/index-v2.html` (projector)
- `https://<you>.github.io/not-vibe-coding-deck/index-v3.html` (mobile — share this link)

**Make the root URL work:** Pages serves `index.html` by default, but the files are named `index-v2.html` / `index-v3.html`. Either rename your preferred version to `index.html`, or add a tiny `index.html` that redirects (e.g. to the mobile deck):
```html
<!doctype html><meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=index-v3.html">
<a href="index-v3.html">Open the deck →</a>
```

**Free alternatives** (also static-HTML hosts, drag-and-drop the `deck/` folder): **Netlify Drop** (netlify.com/drop), **Cloudflare Pages**, **Vercel**, or **GitLab Pages**. All render the HTML and give a public URL; the same "don't upload private notes" caution applies. For a quick throwaway render of a single file already on GitHub, `raw.githack.com` works too.

## Structure (matches the script's SLIDE LIST)

1. Title / holding · 2. Cold open (black — secret-block demo) · 3. **1,117** · 4. Two camps + thesis · 5. The numbers · 6. Core divider (spine line) · 7. Beat 1 Build (marquee demo) · 8. Beat 2 Correct (Humbling + 99% + resolution) · 9. Beat 3 Ship/Operate (clip) · 10. Harness divider · 11. Inventory + 4 pillars (/recall demo) · 12. Economics · 13. 11 Commandments · 14. Close · then **backup/Q&A** slides (credibility ledger, methodologies, case studies, **harness-loop diagram**, **Start-Monday path**, presenter demo-runbook).

## On-stage reminders (baked into the speaker notes)

- The 99% queue docs were **hidden / silently excluded** — **never say "deleted."**
- Headline `~$1k/mo` and `4,000–6,000 hrs` are **estimates** — say so.
- **Never run `/creds-index` / the `creds` skill on stage** (real credentials). Secret-block demo uses a **fake** key shape. `werner-new-app` is the recorded clip only.
- Any live demo stalls >10s → cut to the recorded fallback and keep talking. The lowest-risk demo (`/recall`) is last on purpose.

## Tweaks

- **Title:** edit slide 1 (`Not Vibe Coding` vs `The Moat Is the Harness, Not the Model`) in each version's HTML.
- **Fragment behavior (v2):** the projector deck runs `center: false` (points stay put as they appear). Flip it in the `Reveal.initialize({…})` block at the bottom of `index-v2.html` if you want re-centering.
- **Edit once, mirror:** v2 (reveal.js) and v3 (paged) hold the same content in different markup — change both when you edit a slide's wording.
