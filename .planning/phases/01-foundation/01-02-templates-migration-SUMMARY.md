---
phase: 01-foundation
plan: 02
subsystem: templates
tags: [migration, markdown, templates]
requires: []
provides:
  - templates/weekly-plan.md
  - templates/weekly-tracker.md
  - templates/meal-prep-planner.md
  - templates/shopping-list.md
affects: []
tech_stack:
  added: []
  patterns:
    - "Locked YAML frontmatter (D-03): title, category, source, last_updated"
    - "Verbatim migration with H1 + minimal list bulleting (D-01)"
key_files:
  created:
    - templates/weekly-plan.md
    - templates/weekly-tracker.md
    - templates/meal-prep-planner.md
    - templates/shopping-list.md
  modified: []
decisions:
  - "Preserved source headers (e.g. 'Weekly Meal Plan for 2 People') verbatim under H1 — D-01 verbatim wins over de-dup with H1"
  - "Did NOT bullet day labels (Monday:, Lunch:) — they are section labels, not list-shaped lines"
metrics:
  duration_minutes: ~4
  completed_date: 2026-05-05
  tasks_completed: 1
  files_created: 4
---

# Phase 01 Plan 02: Templates Migration Summary

One-liner: Migrated 4 template-shaped .txt files (weekly-plan, weekly-tracker, meal-prep-planner, shopping-list) into `templates/*.md` with locked D-03 frontmatter and verbatim content per D-01/D-02.

## What Shipped

- `templates/weekly-plan.md` (61 lines) — from `10_weekly_meal_plan.txt`
- `templates/weekly-tracker.md` (38 lines) — from `11_weekly_tracker_template.txt`
- `templates/meal-prep-planner.md` (40 lines) — from `13_meal_prep_planner.txt`
- `templates/shopping-list.md` (54 lines) — from `14_shopping_list_week.txt`
- Total: 193 lines across 4 files.

All four files open with the locked 4-field YAML frontmatter (`title`, `category: template`, `source: <original .txt>`, `last_updated: 2026-05-05`) followed by the H1 from the D-02 mapping table.

## Verification Results

- `ls templates/*.md | wc -l` → 4
- All 4 files line 1 = `---`, contain `category: template`, correct mapped `source:`, and `last_updated: 2026-05-05`
- No forbidden fields present (`tags:`, `applies_to:`, `kcal_role:` per D-04)
- Original 4 source `.txt` files still present in repo root (untouched per scope)

## Judgement Calls (D-01 "obvious list-shaped lines")

Source files were already heavily list-shaped (most non-section lines start with `-`). Decisions made:

1. **Preserved source-level headers verbatim under the H1.** E.g. `weekly-plan.md` keeps the original line "Weekly Meal Plan for 2 People" as the first body line under the new `# Weekly Meal Plan` H1. Per D-01, do not paraphrase — the source phrasing differs (audience cue "for 2 People") and is content, not just a title.
2. **Did NOT bullet day-of-week or section labels** like `Monday:`, `Lunch:`, `Dinner:`, `Goal:`, `Rules:`, `Date:`, `Weight:`. These are section labels, not items in a list. Bulleting them would change semantics.
3. **Did NOT bullet `Cook 4 portions` / `Cook extra for Monday if needed`** trailing notes in `weekly-plan.md` — they are inline notes attached to the day, not list items. Left them as plain lines per "lean toward less transformation".
4. All lines that already started with `-` in source were preserved as-is (already valid Markdown bullets).

## Deviations from Plan

None — plan executed exactly as written.

## Commits

- `6f82640` — feat(01-02): migrate 4 template .txt files to templates/*.md

## Self-Check: PASSED

- FOUND: templates/weekly-plan.md
- FOUND: templates/weekly-tracker.md
- FOUND: templates/meal-prep-planner.md
- FOUND: templates/shopping-list.md
- FOUND: commit 6f82640
- FOUND: originals 10_/11_/13_/14_*.txt still in repo root
