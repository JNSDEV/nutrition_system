---
phase: 02-trackers-baselines
plan: 04
subsystem: templates
tags: [template, weekly-summary, tracker]
requires:
  - library/calorie-targets.md
  - .planning/phases/02-trackers-baselines/02-CONTEXT.md
provides:
  - templates/weekly-summary.md
affects:
  - trackers/jonas/weekly/
  - trackers/farva/weekly/
tech_stack:
  added: []
  patterns:
    - "Shared template, instantiated per person (D-14)"
    - "Locked frontmatter + locked H2 section set (D-03 / D-15)"
key_files:
  created:
    - templates/weekly-summary.md
  modified: []
decisions:
  - "Four-section body locked: Weight, Adherence, Training, Adjustment proposal (D-15)"
  - "Adherence band fixed at ±10% with actual-wins-over-estimate (D-15)"
  - "Adjustment proposal must cite library/calorie-targets.md rule (D-15)"
metrics:
  duration: ~5 min
  completed: 2026-05-06
  tasks: 1
  files_changed: 1
requirements: [TRK-04]
---

# Phase 02 Plan 04: Shared weekly-summary template Summary

Shared `templates/weekly-summary.md` created with locked frontmatter and the four D-15 body sections (Weight, Adherence, Training, Adjustment proposal), so Phase 3's `/weekly-review` can instantiate it per person at `trackers/{person}/weekly/YYYY-Www.md`.

## What Was Built

- **`templates/weekly-summary.md`** — single shared template (D-14). Frontmatter fields: `title`, `category: weekly-summary`, `person: jonas | farva`, `source`, `last_updated`, `iso_week`. Four H2 body sections in the D-15 order with section semantics spelled out:
  - `## Weight` — 7-day average, n=readings/7 form, n<4 low-confidence rule
  - `## Adherence` — ±10% band on day's CAL-02-resolved kcal target, prefer `kcal_actual` over `kcal_estimate`, no-data days excluded from denominator
  - `## Training` — Jonas-only, totals from `cycling-2026.md` for the ISO week
  - `## Adjustment proposal` — prose grounded in `library/calorie-targets.md` rules with worked example

## Commits

- `8a98826` feat(02-04): add shared weekly-summary template

## Verification

Automated verification from PLAN passed:
- File exists
- Frontmatter contains `category: weekly-summary`, `person: jonas | farva`, `iso_week: <YYYY-Www>`
- All four H2 headings present in correct order
- Weight section names "7-day average"
- Adherence section names "±10%"
- Adjustment proposal references `library/calorie-targets.md`

Manual checks against acceptance criteria:
- [x] No frontmatter fields beyond the locked set
- [x] No body sections beyond the four locked
- [x] Training section flagged Jonas-only
- [x] Adjustment proposal demands prose + concrete shift, not just a number

## Deviations from Plan

None — plan executed exactly as written. Template content is verbatim from the plan's `<action>` block.

## Self-Check: PASSED

- FOUND: templates/weekly-summary.md
- FOUND: 8a98826 (feat(02-04): add shared weekly-summary template)
