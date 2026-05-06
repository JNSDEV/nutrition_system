---
phase: 03-slash-commands
plan: "04"
subsystem: slash-commands
tags: [markdown, slash-command, shopping-list, weekly-plan, recipe-aggregation, pantry-baseline]

# Dependency graph
requires:
  - phase: 03-03
    provides: weekly-plan command that writes trackers/weekly-plans/YYYY-Www.md (the file shopping-list reads)
  - phase: 01-foundation
    provides: library/recipes.md ingredient source and templates/shopping-list.md pantry baseline
provides:
  - .claude/commands/shopping-list.md — /shopping-list slash command
  - Derives a grouped, pantry-subtracted shopping list from the active weekly plan
  - Propose-then-write flow; writes trackers/weekly-plans/YYYY-Www-shopping.md on confirm
affects:
  - 03-CONTEXT (D-18, D-19 satisfied)
  - Phase 4 docs sweep (README will document this command)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - propose-then-write with natural-language inline edit loop (D-19)
    - pantry-baseline flagging (flag not delete: append "(pantry — skip unless running low)")
    - recipe anchor resolution via library/recipes.md heading matching
    - 4-portion scale baked-in convention (no runtime rescaling)
    - store-section grouping: produce / proteins / pantry / fridge / freezer

key-files:
  created:
    - .claude/commands/shopping-list.md
  modified: []

key-decisions:
  - "Pantry items flagged with (pantry — skip unless running low) rather than deleted — user retains visibility for restocking decisions"
  - "Ingredient aggregation sums quantities across all recipe anchors found in the week's plan; unit normalisation (g→kg, ml→L above 500) left to Claude's runtime judgement"
  - "Inline edit loop shows only the changed section for small edits to keep chat compact (D-19 phone-readable requirement)"

patterns-established:
  - "propose-before-write: present grouped list in chat, accept natural-language edits, write only on clear confirmation signal"
  - "pantry-flag-not-delete: pantry baseline items remain visible with a flag so user can restock intentionally"

requirements-completed:
  - CMD-04

# Metrics
duration: 2min
completed: 2026-05-06
---

# Phase 03 Plan 04: Shopping List Summary

**`/shopping-list` command that aggregates recipe ingredients from the active weekly plan, flags pantry-stocked items, groups by store section (produce/proteins/pantry/fridge/freezer), proposes in chat with inline-edit support, and writes `trackers/weekly-plans/YYYY-Www-shopping.md` on confirmation**

## Performance

- **Duration:** 2 min
- **Started:** 2026-05-06T13:18:00Z
- **Completed:** 2026-05-06T13:20:19Z
- **Tasks:** 1 (+ checkpoint)
- **Files modified:** 1

## Accomplishments

- Created `.claude/commands/shopping-list.md` with complete 5-step prompt flow
- Missing-plan guard: outputs exact prescribed error and stops if `trackers/weekly-plans/{iso-week}.md` is absent (D-18)
- Recipe anchor resolution walks `library/recipes.md` headings, falls back to `library/meals.md`, flags unresolvable refs gracefully
- Pantry baseline from `templates/shopping-list.md` is flagged (not deleted) so the user sees restocking candidates
- Store-section grouping: Produce / Proteins / Pantry / Fridge / Freezer (D-19)
- Natural-language inline edit loop with partial re-render for small changes (phone-friendly)
- Output file written with required frontmatter on clear confirmation signal

## Task Commits

1. **Task 1: Write .claude/commands/shopping-list.md** - `2d2ab56` (feat)

## Files Created/Modified

- `.claude/commands/shopping-list.md` — `/shopping-list` slash command: 5-step prompt covering guard, read, aggregate, propose, write

## Decisions Made

- Pantry items flagged with `(pantry — skip unless running low)` rather than removed — preserves user's restocking visibility without cluttering the "must buy" signal.
- Inline edit loop shows only the changed section for small edits, full section re-render for larger changes — keeps chat output compact on mobile.
- Unit normalisation (g→kg above 500 g, ml→L above 500 ml) delegated to Claude's runtime judgement rather than hard-coded thresholds — simpler prompt, appropriate for a markdown-only system.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- All six slash commands are now complete: `/prep-today`, `/log-day`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal`
- Phase 4 (docs sweep) can proceed: README.md for `.claude/commands/`, ROADMAP.md display-name fix, PROJECT.md stale "partner" references
- No blockers

---
*Phase: 03-slash-commands*
*Completed: 2026-05-06*
