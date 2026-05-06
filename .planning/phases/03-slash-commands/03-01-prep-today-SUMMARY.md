---
phase: 03-slash-commands
plan: "01"
subsystem: slash-commands
tags: [markdown, slash-command, prep-today, cooking-brief, portioning, training-nutrition]

# Dependency graph
requires:
  - phase: 03-00
    provides: .claude/commands/ directory and shared conventions README
  - phase: 02-trackers-baselines
    provides: library/cal-02-contract.md, library/calorie-targets.md, library/macro-templates.md, library/training-nutrition.md, library/portions.md, library/cooking-rules.md, trackers/jonas/progress.md, trackers/farva/progress.md, calendar/cycling-2026.md
provides:
  - /prep-today slash command — 4-section daily cooking/portioning brief for Jonas and Farva
affects:
  - 03-02 (log-day — same read patterns for CAL-02 and weekly plan)
  - 03-05 (weekly-review — same progress.md and calorie adjustment reads)
  - 03-06 (swap-meal — similar daily-macro resolution pattern)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Slash command prompt body as self-contained instructions referencing durable library/ and trackers/ paths"
    - "Hard guard at top of prompt: check for active weekly plan before proceeding (D-09)"
    - "CAL-02 contract resolution sequence: calorie-targets.md → macro-templates.md → cycling-2026.md → weekly_kcal_adjustments"

key-files:
  created:
    - .claude/commands/prep-today.md
  modified: []

key-decisions:
  - "Chat-only output — no file write per D-03 (briefs are ephemeral, undo cost is zero)"
  - "No-plan guard outputs the exact prescribed message and exits without improvising (D-09)"
  - "CAL-02 contract read order enforced: cal-02-contract.md → calorie-targets.md → macro-templates.md (README D-07)"
  - "Leftover section is omitted entirely if no leftover applies — reduces noise on normal cook days"

patterns-established:
  - "Slash command frontmatter: description (one sentence) + empty argument-hint — matches D-01 shape"
  - "Step-numbered prompt body for multi-source reads — improves model reliability on complex lookup chains"

requirements-completed:
  - CMD-01

# Metrics
duration: 3min
completed: 2026-05-06
---

# Phase 3 Plan 01: prep-today Summary

**6-step /prep-today prompt reads weekly plan, cycling calendar, CAL-02 contract, cooking-rules, and portions to output a mobile-friendly 4-section cooking and portioning brief for Jonas and Farva**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-06T12:20:07Z
- **Completed:** 2026-05-06T12:23:57Z
- **Tasks:** 1 (+ checkpoint)
- **Files modified:** 1

## Accomplishments

- Created `.claude/commands/prep-today.md` with correct Claude Code frontmatter (description + empty argument-hint)
- Implemented D-09 no-plan guard with exact prescribed message: "No weekly plan for this week — run `/weekly-plan` first."
- Implemented D-08 four-section brief: cook today / thaw tomorrow / portion split / leftover note
- Wired Heathland-build context: training-nutrition.md consulted when session_type is a training day
- Enforced CAL-02 contract read sequence per README Section 7

## Task Commits

1. **Task 1: Write .claude/commands/prep-today.md** — `d91aedf` (feat)

## Files Created/Modified

- `.claude/commands/prep-today.md` — /prep-today slash command prompt template

## Decisions Made

- Chat-only output, no file write (D-03) — briefs are ephemeral, matches established convention
- No-plan guard exits immediately with exact message per D-09, does not improvise
- Leftover section omitted entirely when not applicable (keeps brief clean on normal days)

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None.

## Known Stubs

None — command reads from files that already exist in the repo. No hardcoded values or placeholder data.

## Threat Flags

None — this file is a chat-only read-only command. No new network endpoints, auth paths, file write paths, or schema changes introduced.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- `/prep-today` command is ready for use whenever a `trackers/weekly-plans/YYYY-Www.md` file exists
- Next: Plan 03-02 `/log-day` (Wave 2, same depends_on: 03-00)
- CAL-02 read pattern established here is reusable by `/log-day`, `/swap-meal`, and `/weekly-review`

---
*Phase: 03-slash-commands*
*Completed: 2026-05-06*
