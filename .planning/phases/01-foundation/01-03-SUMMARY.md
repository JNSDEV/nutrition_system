---
phase: 01-foundation
plan: 03
subsystem: calendar
tags: [calendar, cycling, integration-contract]
requires: [PROJECT.md cycling tables (lines 50–82)]
provides: [calendar/cycling-2026.md]
affects: [Phase 2 CAL-02, Phase 3 slash commands (date-resolution)]
tech_stack:
  added: []
  patterns: [two-table calendar shape (standard-week + Sunday-progression) per D-06/D-08]
key_files:
  created:
    - calendar/cycling-2026.md
  modified: []
decisions:
  - Two-table shape lifted verbatim from PROJECT.md (D-06)
  - Frontmatter category=calendar, source=PROJECT.md (D-07)
  - Marker rows preserved verbatim with bold formatting (D-09)
metrics:
  duration_min: 2
  completed: 2026-05-05
requirements_completed: [CAL-01]
---

# Phase 1 Plan 03: Cycling Calendar Summary

Single source of truth for Jonas's 2026 cycling load created at `calendar/cycling-2026.md` — two-table layout (standard week + Sunday progression) lifted verbatim from PROJECT.md, ready for Phase 2 CAL-02 daily kcal target resolution.

## What Was Built

- **`calendar/cycling-2026.md`** (38 lines, 1 file)
  - Frontmatter: 4 fields per D-07 (`title`, `category: calendar`, `source: PROJECT.md`, `last_updated: 2026-05-05`)
  - `## Standard week` table — 7 rows (Mon, Tue, Wed, Thu, Fri, Sat, Sun) with Day / Session / Duration / Est. kcal
  - `## Sunday progression` table — 13 rows (May 11–17 through Aug 3–9) with Week / Long ride / Est. kcal
  - Marker rows preserved verbatim with `**bold**` formatting: SPORTIVE (May 25–31), BENCHMARK (Jun 29–Jul 5), REHEARSAL (Jul 13–19), HEATHLAND (Aug 3–9)

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create calendar/cycling-2026.md with two tables | 8f38b99 | calendar/cycling-2026.md |

## Verification

Automated check passed (all greps OK): file exists, frontmatter complete, both H2 headings present, all 4 marker tokens present, Mon/Sun day rows present, May 11–17 / Aug 3–9 boundary weeks present. kcal values match PROJECT.md lines 50–82 exactly.

## Acceptance Criteria

- [x] `calendar/cycling-2026.md` exists
- [x] Line 1 is `---`
- [x] Contains `category: calendar`, `source: PROJECT.md`, `last_updated: 2026-05-05`
- [x] Contains `## Standard week` and `## Sunday progression`
- [x] Standard-week table has 7 day rows (Mon–Sun)
- [x] Sunday-progression table has 13 week rows (May 11–17 → Aug 3–9)
- [x] Marker tokens verbatim: SPORTIVE, BENCHMARK, REHEARSAL, HEATHLAND
- [x] kcal values match PROJECT.md source

## Deviations from Plan

None — plan executed exactly as written.

## Key Decisions

- Followed D-06/D-07/D-09 verbatim; no deviation from locked frontmatter or table shape
- No date-by-date expansion (deferred per CONTEXT.md deferred-ideas list)

## Integration Contract Established

Phase 2 CAL-02 and Phase 3 slash commands resolve "today's row" via:
1. Day-of-week → standard-week table
2. If Sunday → look up date's week range in Sunday progression table
3. Marker rows are load-shape signals (SPORTIVE/BENCHMARK/REHEARSAL/HEATHLAND) — Phase 3 keys off them for fueling guidance

## Self-Check: PASSED

- FOUND: calendar/cycling-2026.md
- FOUND: commit 8f38b99
