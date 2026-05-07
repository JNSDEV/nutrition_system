---
phase: 04-onboarding-docs
plan: "01"
type: execute
wave: 1
depends_on: []
files_modified:
  - README.md
autonomous: false
requirements:
  - DOC-01

must_haves:
  truths:
    - "A first-time reader opens README.md and sees the operating-loop diagram before any other content"
    - "A reader can locate any command by name from the six-row commands table"
    - "A reader knows exactly what to run on each day of their first week using the quickstart table"
    - "A reader knows how to log from a phone without reading any other file"
    - "A reader can orient in the folder structure from the ASCII tree"
    - "The file is complete: all seven locked sections present in D-03 order"
  artifacts:
    - path: "README.md"
      provides: "Top-level onboarding document"
      contains: "operating loop diagram, what-is-this paragraph, quickstart week table, commands table, mobile-buffer example, folder tree, where-to-look-next links"
  key_links:
    - from: "README.md"
      to: ".claude/commands/README.md"
      via: "link in commands table section"
      pattern: "commands/README"
    - from: "README.md"
      to: "docs/conventions.md"
      via: "link in where-to-look-next section"
      pattern: "docs/conventions"
    - from: "README.md"
      to: "CHANGELOG.md"
      via: "link in where-to-look-next section"
      pattern: "CHANGELOG"
    - from: "README.md"
      to: "CONTRIBUTING.md"
      via: "link in where-to-look-next section"
      pattern: "CONTRIBUTING"
---

<objective>
Create the top-level `README.md` — the first document a reader (or future-Jonas returning after a break) encounters. It must make the whole system legible in a single pass without duplicating content from other docs.

Purpose: Satisfy DOC-01 and ROADMAP Phase 4 success criterion 1.
Output: `README.md` at the project root with all seven sections locked in D-03 order.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/04-onboarding-docs/04-CONTEXT.md
@.claude/commands/README.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Write README.md with all seven locked sections</name>
  <files>README.md</files>
  <action>
Create `README.md` at the project root. Follow the D-03 section order exactly (per D-03):

**Section 1 — Operating-loop diagram (D-01)**
First content the reader sees. Use an ASCII cycle diagram showing the full loop.
Base it on the D-01 hint from 04-CONTEXT.md specifics section:
```
        ┌──────── plan (weekly) ────────┐
        │                                │
   adjust ◀── review ◀── log ◀── eat ◀── cook ──┐
        │                                        │
        └─────── prep (today) ───────────────────┘
```
Label the slash commands inline where they fit: `/weekly-plan` at "plan", `/prep-today` at "prep", `/log-day` at "log", `/weekly-review` at "review". Keep ASCII simple — planner's discretion on exact rendering, but the cycle must be readable in a mono font.

**Section 2 — What this is + why (one short paragraph)**
Draw the "decision-fatigue" framing from PROJECT.md Core Value section. Key phrase: "cook → eat → log → adjust without each step requiring fresh thought." Keep to 3–5 sentences. Reference Jonas and Farva by name.

**Section 3 — Quickstart week (D-04)**
6-row markdown table, one row per command event. Use the exact shape from 04-CONTEXT.md specifics (D-04 hint). Columns: When | Command | What it does. Rows:
- Sun evening | `/weekly-plan` | Plan next 7 days conversationally; writes `trackers/weekly-plans/YYYY-Www.md`
- Sun evening | `/shopping-list` | Derive shopping list from the new plan
- Mon morning | `/prep-today` | Today's cooking/portioning brief (chat-only)
- Mon evening | `/log-day` | Log today's meals + weights + training
- Mid-week | `/swap-meal` | Mid-day alternative if a meal won't fit (chat-only)
- Following Mon | `/weekly-review` | 7-day review + optional kcal adjustment for next week

Heading: `## Quickstart: your first week`

**Section 4 — Six commands at a glance (D-03 item 4)**
Markdown table: Command | Does what | Writes to. One row per command. Keep brief — end with: "Full convention reference: [`.claude/commands/README.md`](.claude/commands/README.md)". Do NOT duplicate the conventions doc content.

**Section 5 — Mobile-buffer flow (D-06)**
Heading: `## Logging from your phone`. Worked example of ~10 lines showing:
1. Open Claude mobile chat
2. Type `/log-day` (or just say "log today's meals")
3. Paste MFP/Cronometer totals or describe meals in free text
4. Claude captures the message in chat
5. Next time at the laptop, run `/log-day` again — it smart-merges the phone entry (per Phase 3 D-12)
Use a fenced code or blockquote to show the actual mobile-chat example. Name `/log-day` explicitly as the command that pairs with this pattern.

**Section 6 — Folder tree (D-05)**
ASCII tree, top-level only (one nesting level deep). Include the exact directories from D-05 hint:
```
library/          # Durable knowledge — meals, recipes, calorie targets, cycling/training rules
calendar/         # Cycling-2026 calendar, session_type per date
templates/        # File-shape templates for daily logs, weekly plans, etc.
trackers/
  jonas/          # Daily logs, weekly summaries, progress.md (Heathland milestones)
  farva/          # Daily logs, weekly summaries, progress.md
  weekly-plans/   # Plans + shopping lists per ISO week
.claude/commands/ # 6 slash command prompt templates
docs/             # conventions.md and other reference docs
.planning/        # GSD workflow artifacts (PROJECT, ROADMAP, phase context)
```

**Section 7 — Where to look next**
Brief bullet list of links:
- [`docs/conventions.md`](docs/conventions.md) — file-naming rules, date format, person-name resolution
- [`CHANGELOG.md`](CHANGELOG.md) — what shipped at each milestone
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — adding meals, recipes, or new slash commands
- [`.planning/PROJECT.md`](.planning/PROJECT.md) — Jonas/Farva goals, cycling calendar, full operating-loop context

**Tone:** Concise and practical — no marketing language. The system is markdown-as-instructions; so should the README be. No front-matter block (GitHub convention, not GSD custom frontmatter).
  </action>
  <verify>
    <automated>
      # All 7 required sections present
      grep -c "cook.*eat\|eat.*log\|adjust.*plan\|plan.*cook" README.md
      grep -c "Quickstart" README.md
      grep -c "commands/README" README.md
      grep -c "phone\|mobile\|buffer\|log-day" README.md
      grep -c "library/" README.md
      grep -c "docs/conventions" README.md
      grep -c "CHANGELOG" README.md
      grep -c "CONTRIBUTING" README.md
      # All 6 slash commands named
      grep -c "/prep-today\|/log-day\|/weekly-plan\|/shopping-list\|/weekly-review\|/swap-meal" README.md
      # Farva named (not Partner)
      grep -v "Partner" README.md | grep -c "Farva"
      grep -c "Partner" README.md  # should be 0
    </automated>
  </verify>
  <done>
    README.md exists at project root. All 7 sections present in D-03 order. Operating-loop diagram is first content. Quickstart table has 6 rows covering Sun–Mon cycle. Commands table has 6 rows and links to .claude/commands/README.md. Mobile-buffer section names /log-day and shows worked example. Folder tree covers all top-level directories. Where-to-look-next links to docs/conventions.md, CHANGELOG.md, CONTRIBUTING.md, .planning/PROJECT.md. "Partner" does not appear anywhere in the file.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>README.md at project root with 7 sections per D-03 order</what-built>
  <how-to-verify>
    Open README.md and read it as a first-time reader would:
    1. Confirm the operating-loop diagram appears before any prose paragraph
    2. Confirm the quickstart table has 6 rows covering Sun evening through the following Mon
    3. Confirm the commands table has all 6 commands and links to .claude/commands/README.md
    4. Confirm the mobile-buffer section contains a worked example using /log-day
    5. Confirm the folder tree shows trackers/jonas/, trackers/farva/, trackers/weekly-plans/
    6. Confirm where-to-look-next has links to docs/conventions.md, CHANGELOG.md, CONTRIBUTING.md, .planning/PROJECT.md
    7. Confirm "Partner" does not appear anywhere
    8. Confirm the tone is concise and practical, not marketing-speak
  </how-to-verify>
  <resume-signal>Type "approved" or describe any issues to fix</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| none | Pure markdown creation; no code, no inputs, no external calls |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-01 | Information Disclosure | README.md | accept | No sensitive data in README; system is single-user markdown on local disk |
</threat_model>

<verification>
After task 1 completes, run:

```bash
# File exists
test -f README.md && echo "EXISTS"

# No "Partner" references (must be 0)
grep -c "Partner" README.md || echo "CLEAN"

# All 6 commands named (must be 6 or more)
grep -oE "/(prep-today|log-day|weekly-plan|shopping-list|weekly-review|swap-meal)" README.md | sort -u | wc -l

# Key cross-links present
grep -l "commands/README" README.md
grep -l "docs/conventions" README.md
grep -l "CHANGELOG" README.md
grep -l "CONTRIBUTING" README.md
```
</verification>

<success_criteria>
- `README.md` exists at project root
- Seven sections present in D-03 locked order
- Operating-loop diagram is the first content block (before any prose paragraph)
- Quickstart table: 6 rows, names each slash command, covers the full week cycle
- Commands table: 6 rows, links to `.claude/commands/README.md`
- Mobile-buffer section: worked `/log-day` example present
- Folder tree: ASCII, top-level only, all directories named
- Where-to-look-next: links to `docs/conventions.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `.planning/PROJECT.md`
- "Partner" does not appear in the file
- ROADMAP Phase 4 SC-1 satisfied
</success_criteria>

<output>
After completion, create `.planning/phases/04-onboarding-docs/04-01-SUMMARY.md`
</output>
