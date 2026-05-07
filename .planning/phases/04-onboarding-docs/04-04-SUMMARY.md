---
phase: 04-onboarding-docs
plan: "04"
subsystem: docs
tags: [markdown, contributing, library-anchors, slash-commands, calorie-targets]

requires:
  - phase: 03-slash-commands
    provides: .claude/commands/README.md — slash command conventions and command index
  - phase: 01-foundation
    provides: library/calorie-targets.md — authoritative kcal thresholds

provides:
  - CONTRIBUTING.md — three-section maintenance guide for future-Jonas

affects: [any phase adding new library content, new commands, or changing kcal thresholds]

tech-stack:
  added: []
  patterns:
    - "CONTRIBUTING.md as single-page maintenance guide at project root"

key-files:
  created:
    - CONTRIBUTING.md
  modified: []

key-decisions:
  - "calorie-targets.md is authoritative over D-21 defaults documented in .claude/commands/README.md"
  - "CONTRIBUTING.md links to .claude/commands/README.md rather than duplicating conventions"

patterns-established:
  - "New library headings derive anchors via kebab-case; duplicate headings forbidden"
  - "New slash commands require README.md command table + commands/README.md index updates"

requirements-completed:
  - DOC-01

duration: 3min
completed: 2026-05-07
---

# Phase 04 Plan 04: Contributing Guide Summary

**One-page `CONTRIBUTING.md` covering library anchor conventions, slash command registration steps, and calorie-target file authority**

## Performance

- **Duration:** ~3 min
- **Started:** 2026-05-07
- **Completed:** 2026-05-07
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Created `CONTRIBUTING.md` at project root with three sections per D-12
- Section 1 explains H2/H3 heading → kebab-case anchor derivation and warns against duplicate headings
- Section 2 links to `.claude/commands/README.md` and calls out README command table + conventions.md updates required for new commands
- Section 3 designates `library/calorie-targets.md` as the runtime authoritative source over D-21 defaults

## Task Commits

1. **Task 1: Write CONTRIBUTING.md with three sections per D-12** - `db25c4f` (docs)

## Files Created/Modified

- `/Users/jonasockerman/Documents/nutrition_system/CONTRIBUTING.md` - Three-section maintenance guide for future-Jonas

## Decisions Made

None - followed plan as specified. D-12 content requirements were precise; no judgment calls needed.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Plans 04-01 through 04-03 (README, conventions, CHANGELOG) and 04-05 (terminology sweep) remain
- CONTRIBUTING.md is complete and immediately usable

---
*Phase: 04-onboarding-docs*
*Completed: 2026-05-07*
