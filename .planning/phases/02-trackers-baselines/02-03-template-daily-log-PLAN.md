---
phase: 02-trackers-baselines
plan: 03
type: execute
wave: 1
depends_on: []
files_modified:
  - templates/daily-log.md
autonomous: true
requirements: [TRK-03]
must_haves:
  truths:
    - "User can open templates/daily-log.md and find fields for meals, weight, training, energy/hunger notes, and free-text comments"
    - "Template carries both kcal_estimate and kcal_actual (hybrid kcal model per D-13)"
    - "Meal logging convention shown in template uses library:meals#{anchor} reference plus optional free-text deviation"
  artifacts:
    - path: "templates/daily-log.md"
      provides: "shared daily-log template for both jonas and farva (D-09)"
      contains: "category: daily-log"
  key_links:
    - from: "templates/daily-log.md ## Meals section"
      to: "library/meals.md anchors"
      via: "library:meals#{anchor} reference convention (D-12)"
      pattern: "library:meals#"
---

<objective>
Create the single shared daily-log template at `templates/daily-log.md` with locked frontmatter (D-10), locked body sections in order (D-11), the meal-reference convention (D-12), and the hybrid kcal/macro estimate+actual fields (D-13).

Purpose: TRK-03 — Phase 3's `/log-day` instantiates this template into `trackers/{person}/daily/YYYY-MM-DD.md` for both Jonas and Farva. Optional fields stay blank for Farva (no training).
Output: `templates/daily-log.md`.
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
  <name>Task 1: Create templates/daily-log.md with locked frontmatter and body skeleton</name>
  <files>templates/daily-log.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-09 shared template, D-10 frontmatter, D-11 body sections, D-12 meal convention, D-13 hybrid kcal, daily-log skeleton lines 165–196)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention)
  </read_first>
  <action>
Create file `templates/daily-log.md` with EXACTLY this content (copied verbatim from CONTEXT.md daily-log skeleton at lines 165–196, then expanded with the locked sections D-11 and meal convention D-12):

```markdown
---
title: <Person> — <YYYY-MM-DD>
category: daily-log
person: jonas | farva
source: templates/daily-log.md
last_updated: <YYYY-MM-DD>
date: <YYYY-MM-DD>
weight_kg: <number or null>
kcal_estimate: <number or null>
kcal_actual: <number or null>
protein_estimate_g: <number or null>
protein_actual_g: <number or null>
carb_estimate_g: <number or null>
carb_actual_g: <number or null>
fat_estimate_g: <number or null>
fat_actual_g: <number or null>
---

# <Person> — <YYYY-MM-DD>

> Template usage: `/log-day` instantiates this file at `trackers/{person}/daily/YYYY-MM-DD.md`. Replace `<...>` placeholders. Optional sections (Training) stay blank for Farva.

## Meals

Convention (per D-12): each meal line cites a library reference plus optional free-text deviation.
Format: `- {Meal slot}: {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`
Off-library meals: prefix with `(off-library)` and use plain free text.

- Breakfast: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Lunch: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Dinner: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Snacks: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>

## Training

<Jonas only — pulled from cycling-2026.md row for today's date; note any deviation from the planned session (skipped, shortened, intensity differed). Leave blank for Farva.>

## Notes

<Energy level, hunger pattern through the day, sleep, stress, free-text observations. Both Jonas and Farva.>
```

Notes on the kcal/macro fields (D-13): `*_estimate_*` is what Claude computes from library:meals references at log-time; `*_actual_*` is the user's MFP/Cronometer paste. Adherence (D-15) prefers `_actual_` and falls back to `_estimate_`. Both stay nullable.

Do NOT add additional frontmatter fields beyond those listed (resist scope creep per Phase 1 D-04 spirit).
Do NOT add additional body sections beyond `## Meals`, `## Training`, `## Notes` (D-11 locks order and set).
  </action>
  <verify>
    <automated>test -f templates/daily-log.md && grep -q '^category: daily-log$' templates/daily-log.md && grep -q '^person: jonas | farva$' templates/daily-log.md && grep -q '^date: <YYYY-MM-DD>$' templates/daily-log.md && grep -q '^weight_kg: <number or null>$' templates/daily-log.md && grep -q '^kcal_estimate: <number or null>$' templates/daily-log.md && grep -q '^kcal_actual: <number or null>$' templates/daily-log.md && grep -q '^protein_estimate_g: <number or null>$' templates/daily-log.md && grep -q '^protein_actual_g: <number or null>$' templates/daily-log.md && grep -q '^carb_estimate_g:' templates/daily-log.md && grep -q '^fat_actual_g:' templates/daily-log.md && grep -q '^## Meals$' templates/daily-log.md && grep -q '^## Training$' templates/daily-log.md && grep -q '^## Notes$' templates/daily-log.md && grep -q 'library:meals#' templates/daily-log.md</automated>
  </verify>
  <acceptance_criteria>
    - File `templates/daily-log.md` exists
    - Frontmatter contains: `category: daily-log`, `person: jonas | farva`, `date`, `weight_kg`, `kcal_estimate`, `kcal_actual`, `protein_estimate_g`, `protein_actual_g`, `carb_estimate_g`, `carb_actual_g`, `fat_estimate_g`, `fat_actual_g`, `source: templates/daily-log.md`
    - Body contains H2 headings `## Meals`, `## Training`, `## Notes` in this exact order
    - `## Meals` section shows the `library:meals#{anchor}` convention with at least one example line
    - `## Training` section flagged as Jonas-only (Farva blank)
    - No body sections beyond Meals / Training / Notes
  </acceptance_criteria>
  <done>Template file exists with locked frontmatter (incl. hybrid kcal/macro pairs), three locked body sections, meal convention spelled out.</done>
</task>

</tasks>

<verification>
- `templates/daily-log.md` parses as valid YAML frontmatter + Markdown body
- All 8 nullable kcal/macro fields present (4 estimate + 4 actual per D-13)
- Body shape matches D-11 exactly (Meals, Training, Notes — no extras)
</verification>

<success_criteria>
ROADMAP success criterion #3 satisfied: User can open `templates/daily-log.md` and find fields for meals, weight, training, energy/hunger notes, and free-text comments.
</success_criteria>

<output>
After completion, create `.planning/phases/02-trackers-baselines/02-03-SUMMARY.md`.
</output>
