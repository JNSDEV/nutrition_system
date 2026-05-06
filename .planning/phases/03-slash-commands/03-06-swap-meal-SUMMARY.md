---
phase: 03-slash-commands
plan: "06"
subsystem: slash-commands
tags: [markdown, slash-command, macro-tracking, meal-swap, chat-only]

# Dependency graph
requires:
  - phase: 03-00-setup
    provides: .claude/commands/ directory and README conventions
  - phase: 02-trackers-baselines
    provides: cal-02-contract.md, daily-log template, library/meals.md anchors
  - phase: 01-foundation
    provides: library/calorie-targets.md, library/macro-templates.md, calendar/cycling-2026.md
provides:
  - /swap-meal slash command — mid-day meal alternative with macro-fit logic
affects: [03-slash-commands, 04-docs]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Chat-only command pattern: reads library + trackers, returns options, writes nothing (D-24)"
    - "CAL-02 resolution chain: cal-02-contract → calorie-targets → macro-templates → cycling-2026"
    - "Remaining-budget computation: daily target − sum of logged meal estimates"
    - "Archetype-match filtering: meal slot → library/meals.md archetype field"

key-files:
  created:
    - .claude/commands/swap-meal.md
  modified: []

key-decisions:
  - "Chat-only with no file write (D-24): mid-day swaps are exploratory; /log-day smart-merge handles eventual logging"
  - "Person+slot combined clarification question if both missing — reduces mobile typing friction (D-02)"
  - "Empty-state: asks for intent rather than failing when no daily log exists yet"
  - "Protein floor check for Jonas only via progress.md; skipped for Farva (D-06)"
  - "10% kcal tolerance, relaxes to 20% with note if nothing fits within budget"

patterns-established:
  - "Fallback tolerance escalation: if no meal fits ≤110% budget, try ≤120% and note it"
  - "Remaining-budget stated in chat before options — user can sanity-check before choosing"

requirements-completed: [CMD-06]

# Metrics
duration: 2min
completed: 2026-05-06
---

# Phase 03 Plan 06: Swap Meal Summary

**Chat-only `/swap-meal` command that reads today's daily log, resolves the CAL-02 target, computes remaining kcal/macro budget, and returns 1-3 archetype-matched alternatives from `library/meals.md` — no file written.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-05-06T12:27:29Z
- **Completed:** 2026-05-06T12:29:40Z
- **Tasks:** 1 (+ checkpoint)
- **Files modified:** 1

## Accomplishments

- `/swap-meal` command created at `.claude/commands/swap-meal.md`
- Covers all 6 steps: person/slot identification, daily-log read, CAL-02 resolution, remaining-budget computation, library search with archetype + macro filtering, options presentation
- Empty-state handled: no daily log → asks for macro budget intent rather than failing
- Jonas protein floor check enforced; Farva skips training fields per D-06
- Tight-budget fallback: relaxes 10% tolerance to 20% with a chat note

## Task Commits

1. **Task 1: Write .claude/commands/swap-meal.md** — `8664090` (feat)

**Plan metadata:** TBD after final docs commit

## Files Created/Modified

- `.claude/commands/swap-meal.md` — 106-line chat-only prompt: identifies person/slot, reads today's log, resolves CAL-02 target, computes remaining macros, filters library/meals.md, returns 1-3 options with `library:meals#{anchor}` refs

## Decisions Made

None beyond plan spec — all implementation decisions (tolerance %, protein floor source, archetype expansion rule for dinner) followed the plan's explicit instructions.

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- All 6 slash commands are now written (`/prep-today`, `/log-day` pending, `/weekly-plan` pending, `/shopping-list` pending, `/weekly-review` pending, `/swap-meal` done at 03-06)
- Phase 4 docs sweep can reference this command as part of the README

## Known Stubs

None — command reads from live library files and tracker files at runtime. No hardcoded data or placeholder values.

## Threat Flags

None — command is read-only (D-24), creates no network endpoints, writes no files, exposes no new trust boundaries.

---

*Phase: 03-slash-commands*
*Completed: 2026-05-06*
