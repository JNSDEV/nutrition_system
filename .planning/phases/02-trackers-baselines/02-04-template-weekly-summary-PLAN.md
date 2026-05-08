---
phase: 02-trackers-baselines
plan: 04
type: execute
wave: 1
depends_on: []
files_modified:
  - templates/weekly-summary.md
autonomous: true
requirements: [TRK-04]
must_haves:
  truths:
    - "User can open templates/weekly-summary.md and find fields for 7-day weight average, adherence %, training totals, and kcal/macro adjustment proposal"
    - "Adherence section names ±10% kcal-target band and the actual-wins-over-estimate rule (D-15)"
    - "Adjustment proposal section requires prose grounded in library/calorie-targets.md (not just a number)"
  artifacts:
    - path: "templates/weekly-summary.md"
      provides: "shared weekly-summary template for both jonas and farva (D-14)"
      contains: "category: weekly-summary"
  key_links:
    - from: "templates/weekly-summary.md ## Adjustment proposal section"
      to: "library/calorie-targets.md"
      via: "adjustment rules sourced from calorie-targets (D-15)"
      pattern: "calorie-targets.md"
---

<objective>
Create the single shared weekly-summary template at `templates/weekly-summary.md` with locked frontmatter and the four locked body sections (D-14, D-15): `## Weight`, `## Adherence`, `## Training` (Jonas only), `## Adjustment proposal`.

Purpose: TRK-04 — Phase 3's `/weekly-review` instantiates this template into `trackers/{person}/weekly/YYYY-Www.md`. The Adjustment proposal section is the actionable output of the weekly loop.
Output: `templates/weekly-summary.md`.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/02-trackers-baselines/02-CONTEXT.md
@.planning/phases/01-foundation/01-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create templates/weekly-summary.md with locked frontmatter and four body sections</name>
  <files>templates/weekly-summary.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-14 shared template, D-15 four locked sections, weekly-summary skeleton lines 197–220)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention)
  </read_first>
  <action>
Create file `templates/weekly-summary.md` with EXACTLY this content (copied verbatim from CONTEXT.md weekly-summary skeleton at lines 197–220, expanded with the section semantics from D-15):

```markdown
---
title: <Person> — Week <YYYY-Www>
category: weekly-summary
person: jonas | farva
source: templates/weekly-summary.md
last_updated: <YYYY-MM-DD>
iso_week: <YYYY-Www>
---

# <Person> — Week <YYYY-Www>

> Template usage: `/weekly-review` instantiates this file at `trackers/{person}/weekly/YYYY-Www.md` (ISO week, e.g. `2026-W19.md`). Section `## Training` stays blank for Farva.

## Weight

- 7-day average: <kg> (n=<readings>/7)
- Trend vs target: <kg this week, +/- vs target rate>

Rule (per D-15): average computed from daily-log `weight_kg` fields. Missing days drop out. If fewer than 4 of 7 readings, flag the average as "low confidence — n<4".

## Adherence

- <percent>% of days within ±10% of that day's kcal target (n=<days with data>/7)

Rule (per D-15): for each day, prefer `kcal_actual` over `kcal_estimate`. Days with neither = "no data" and don't count toward the denominator. ±10% band applied to that day's CAL-02-resolved kcal target.

## Training

<Jonas only — totals from cycling-2026.md rows for the ISO week: km, hours, est. kcal sum. Note any deviations logged in daily `## Training` sections. Leave blank for Farva.>

## Adjustment proposal

<Concrete kcal/macro shift for next week, plus the *why* — grounded in the rules in `library/calorie-targets.md`. Prose, not just a number.

Example shape: "Weight ↓0.6 kg this week vs target rate of −0.3 kg/wk → losing too fast. Suggest +100 kcal/day from carbs on long-ride days (Sun, Wed) to protect Heathland build. Hold protein floor at 150–180 g."

Reference the specific rule from `library/calorie-targets.md` you applied (e.g. ">0.8 kg/wk loss = add kcal" / "<0.3 kg/wk loss × 2 weeks = reduce kcal").>
```

Do NOT add additional frontmatter fields beyond those listed.
Do NOT add additional body sections beyond the four (D-15 locks the set).
  </action>
  <verify>
    <automated>test -f templates/weekly-summary.md && grep -q '^category: weekly-summary$' templates/weekly-summary.md && grep -q '^person: jonas | farva$' templates/weekly-summary.md && grep -q '^iso_week: <YYYY-Www>$' templates/weekly-summary.md && grep -q '^## Weight$' templates/weekly-summary.md && grep -q '^## Adherence$' templates/weekly-summary.md && grep -q '^## Training$' templates/weekly-summary.md && grep -q '^## Adjustment proposal$' templates/weekly-summary.md && grep -q '7-day average' templates/weekly-summary.md && grep -q '±10%' templates/weekly-summary.md && grep -q 'library/calorie-targets.md' templates/weekly-summary.md</automated>
  </verify>
  <acceptance_criteria>
    - File `templates/weekly-summary.md` exists
    - Frontmatter contains: `category: weekly-summary`, `person: jonas | farva`, `iso_week`, `source: templates/weekly-summary.md`, `last_updated`
    - Body contains H2 headings in this exact order: `## Weight`, `## Adherence`, `## Training`, `## Adjustment proposal`
    - `## Weight` section names "7-day average" and the n<4 low-confidence rule
    - `## Adherence` section names the ±10% band and actual-wins-over-estimate rule
    - `## Training` section flagged Jonas-only
    - `## Adjustment proposal` section references `library/calorie-targets.md` and demands prose + concrete shift
    - No additional sections beyond the four locked
  </acceptance_criteria>
  <done>Template file exists with locked frontmatter and all four body sections in correct order, with section semantics spelled out per D-15.</done>
</task>

</tasks>

<verification>
- `templates/weekly-summary.md` parses as valid YAML frontmatter + Markdown body
- Four-section body matches D-15 exactly
- Adjustment proposal section explicitly anchors on `library/calorie-targets.md`
</verification>

<success_criteria>
ROADMAP success criterion #4 satisfied: User can open `templates/weekly-summary.md` and find fields for 7-day weight average, adherence %, training totals, and kcal/macro adjustment proposal.
</success_criteria>

<output>
After completion, create `.planning/phases/02-trackers-baselines/02-04-SUMMARY.md`.
</output>
