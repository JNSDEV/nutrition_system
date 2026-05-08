---
phase: 02-trackers-baselines
plan: 03
subsystem: templates
tags: [template, daily-log, hybrid-kcal]
requires:
  - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-09..D-13)
  - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention)
provides:
  - templates/daily-log.md (shared daily-log template for Jonas + Farva)
affects:
  - Phase 3 /log-day command (will instantiate this template per person per day)
tech-stack:
  added: []
  patterns:
    - "Hybrid kcal/macro model: *_estimate (Claude-computed) + *_actual (MFP/Cronometer paste); actual wins"
    - "Meal-reference convention: library:meals#{anchor} + optional free-text deviation"
key-files:
  created:
    - templates/daily-log.md
  modified: []
decisions:
  - "Followed D-13 hybrid kcal model verbatim — 4 estimate + 4 actual nullable frontmatter fields"
  - "Body sections locked to Meals / Training / Notes per D-11 (no extras added)"
  - "Training section explicitly flagged Jonas-only; Farva leaves it blank (D-09 + D-11)"
metrics:
  duration: ~3 min
  completed: 2026-05-05
  tasks_completed: 1
  files_changed: 1
requirements: [TRK-03]
---

# Phase 02 Plan 03: Shared Daily-Log Template Summary

Shipped `templates/daily-log.md` — single shared template that Phase 3's `/log-day` will instantiate as `trackers/{person}/daily/YYYY-MM-DD.md` for both Jonas and Farva. Locks the frontmatter (D-10), the body section order (D-11), the meal-reference convention (D-12), and the hybrid kcal/macro estimate+actual model (D-13).

## What Changed

**Created:** `templates/daily-log.md`
- Frontmatter (16 fields): foundational 4 (`title`, `category: daily-log`, `source`, `last_updated`) + `person`, `date`, `weight_kg`, plus 8 nullable kcal/macro fields (4 `*_estimate*` + 4 `*_actual*`)
- Body H2 sections in locked order: `## Meals`, `## Training`, `## Notes`
- Meals section spells out the `library:meals#{anchor}` convention with example lines for all 4 slots (Breakfast/Lunch/Dinner/Snacks)
- Training section flagged Jonas-only (Farva blank)
- Notes section reserved for energy/hunger/sleep/stress free text

## Tasks Completed

| # | Task                                                      | Commit  | Files                       |
| - | --------------------------------------------------------- | ------- | --------------------------- |
| 1 | Create templates/daily-log.md with locked frontmatter and body skeleton | b311ef1 | templates/daily-log.md      |

## Verification

Plan automated check passed (all 14 grep assertions):
- Frontmatter fields present: `category: daily-log`, `person: jonas | farva`, `date`, `weight_kg`, `kcal_estimate`, `kcal_actual`, `protein_estimate_g`, `protein_actual_g`, `carb_estimate_g`, `fat_actual_g`
- Body H2 headings present in correct order: `## Meals`, `## Training`, `## Notes`
- Meal-reference convention `library:meals#` present in body

Manual checks:
- File parses as valid YAML frontmatter + Markdown body
- All 8 nullable kcal/macro fields present (4 estimate + 4 actual per D-13)
- No body sections beyond Meals / Training / Notes (D-11 respected)

## Deviations from Plan

None — plan executed exactly as written. Template content matches the verbatim spec in the plan's `<action>` block.

## Downstream Impact

- **Phase 3 `/log-day`** consumes this template directly. Frontmatter and body shape must not be reshuffled without updating that command.
- **Phase 3 `/weekly-review`** reads `weight_kg` (D-15 weight average), `kcal_actual` || `kcal_estimate` (D-15 adherence), and the meal lines from instantiated daily logs.
- **Phase 4 docs / PROJECT.md update** still pending — PROJECT.md says "the markdown system is not the calorie database" but D-13 establishes a hybrid (estimate + actual) model. Already tracked under `<deferred>` in 02-CONTEXT.md.

## Self-Check: PASSED

- File `templates/daily-log.md` — FOUND
- Commit `b311ef1` — FOUND in `git log`
- SUMMARY.md `.planning/phases/02-trackers-baselines/02-03-SUMMARY.md` — being written by this step
