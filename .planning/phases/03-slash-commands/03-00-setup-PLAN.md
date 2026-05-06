---
phase: 03-slash-commands
plan: "00"
type: execute
wave: 1
depends_on: []
files_modified:
  - .claude/commands/README.md
autonomous: true
requirements:
  - CMD-01
  - CMD-02
  - CMD-03
  - CMD-04
  - CMD-05
  - CMD-06

must_haves:
  truths:
    - "The .claude/commands/ directory exists"
    - "A README.md in that directory explains the file-shape convention so all 6 command files are authored consistently"
    - "The README documents the conversational-args principle (no positional args)"
    - "The README records the D-22 decision (weekly_kcal_adjustments field in progress.md) so downstream commands implement it uniformly"
  artifacts:
    - path: ".claude/commands/README.md"
      provides: "Convention reference for all 6 command files"
      contains: "argument-hint, D-01, D-02, D-22"
  key_links:
    - from: ".claude/commands/README.md"
      to: ".claude/commands/*.md"
      via: "shared authoring convention"
      pattern: "argument-hint"
---

<objective>
Bootstrap the `.claude/commands/` directory and write a single README that documents every cross-cutting convention all 6 slash commands must follow. This is a prerequisite for plans 03-01 through 03-06.

Purpose: Give every command author (and every future executor) one reference document so conventions are applied uniformly without re-deriving them from scattered CONTEXT.md decisions.

Output: `.claude/commands/` directory + `.claude/commands/README.md`.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/03-slash-commands/03-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create .claude/commands/ directory and write README.md</name>
  <files>.claude/commands/README.md</files>
  <action>
Create the `.claude/commands/` directory (it does not exist yet — Phase 3 creates it, per D-01).

Write `.claude/commands/README.md` with the following content covering every convention shared across all 6 command files. This file is NOT a slash command itself — it is a reference for command authors and for any future maintainer.

Content to include:

**1. File-shape convention (D-01)**
Each `.claude/commands/{name}.md` file uses Claude Code's frontmatter convention:
```
---
description: One short sentence describing the command for /help.
argument-hint:
---
<prompt body the model sees when the command is invoked>
```
`argument-hint` is always left empty (D-02).

**2. Conversational-args principle (D-02)**
No command requires positional arguments. Defaults are today's date and both people (Jonas and Farva). Date, person, MFP paste, and preferences come from a follow-up chat turn when needed. Rationale: most usage is on mobile — fewer typed args wins.

**3. Write-vs-propose-vs-chat matrix (D-03)**
| Command | Behavior |
|---------|----------|
| /log-day | Write directly; smart-merge if file exists |
| /weekly-review | Write directly; then propose adjustment in chat |
| /weekly-plan | Propose in chat, write on user confirm |
| /shopping-list | Propose in chat, write on user confirm |
| /prep-today | Chat-only, no file write |
| /swap-meal | Chat-only, no file write |

**4. Library-anchor resolution (D-04)**
Meal references use format `library:meals#{anchor}`. To resolve: read `library/meals.md`, find the H2/H3 heading whose kebab-case form equals the anchor, take that section's body. Ambiguous anchors (duplicate headings) → first occurrence wins; flag in chat.

**5. Date semantics (D-05)**
Default date = today (system clock). File paths follow Phase 2 conventions:
- Daily logs: `trackers/{person}/daily/YYYY-MM-DD.md`
- Weekly summaries: `trackers/{person}/weekly/YYYY-Www.md`
- Weekly plans: `trackers/weekly-plans/YYYY-Www.md`
- Shopping lists: `trackers/weekly-plans/YYYY-Www-shopping.md`
ISO week format: `YYYY-Www` using Python `%G-W%V` (e.g. `2026-W19`).

**6. Person identifiers (D-06)**
Directory tokens: lowercase `jonas` / `farva`.
Display names in prose and chat output: `Jonas` / `Farva`.

**7. CAL-02 contract (for commands that touch kcal targets)**
Every command that resolves "today's kcal target" MUST read `library/cal-02-contract.md` first for the locked schema, then read `library/calorie-targets.md` (formula), `library/macro-templates.md` (macro archetypes), and `calendar/cycling-2026.md` (session type + est. kcal burn) at runtime.

**8. D-22 decision: how /weekly-review records an applied adjustment**
When `/weekly-review` applies an adjustment to `progress.md`, it appends an entry to a `weekly_kcal_adjustments` list in that file's frontmatter. Schema:
```yaml
weekly_kcal_adjustments:
  - week: YYYY-Www
    delta_kcal_per_day: +200    # or -150, or 0
    reason: ">0.8 kg/wk loss — adding carbs on training days"
    applied: YYYY-MM-DD
```
Commands that need "this week's effective target" add the most recent entry's `delta_kcal_per_day` to `base_kcal` from the CAL-02 resolution. This is additive on top of the formula; it does not overwrite `target_weight_kg` or `target_date`. The `last_updated` field in `progress.md` is always updated to the application date.

**9. ROADMAP display-name note**
ROADMAP.md still references "Partner" in Phase 3 success criteria (historical placeholder). The canonical name is `farva` (directory) / `Farva` (display), per Phase 2 D-01. Phase 4 docs sweep will update ROADMAP.md — not in scope for Phase 3.

**10. Empty-state behavior**
| Command | Missing precondition behavior |
|---------|-------------------------------|
| /prep-today | No active weekly plan → chat "run /weekly-plan first" |
| /log-day | First run of day → fresh template instantiation |
| /weekly-plan | Plan already exists → "amend or replace?" |
| /shopping-list | No active weekly plan → chat error |
| /weekly-review | <4 weight readings → "insufficient data" in Weight section; still write file |
| /swap-meal | No daily log yet → ask for remaining macro budget intent |
  </action>
  <verify>
File `.claude/commands/README.md` exists and contains all 10 convention sections above. Check: `grep -l "argument-hint\|D-22\|weekly_kcal_adjustments\|farva" .claude/commands/README.md`
  </verify>
  <done>`.claude/commands/README.md` exists; contains the file-shape convention, conversational-args principle, write-vs-propose matrix, library-anchor resolution, date semantics, person identifiers, CAL-02 contract pointer, D-22 adjustment field schema, ROADMAP name note, and empty-state matrix.</done>
</task>

</tasks>

<verification>
- `.claude/commands/` directory created
- `.claude/commands/README.md` exists with all 10 sections
- `weekly_kcal_adjustments` field schema documented (D-22 decision resolved)
</verification>

<success_criteria>
Any executor writing plans 03-01..03-06 can read this README and know exactly how to structure their command file without consulting CONTEXT.md.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-00-setup-SUMMARY.md`
</output>
