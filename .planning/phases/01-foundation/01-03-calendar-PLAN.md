---
phase: 01-foundation
plan: 03
type: execute
wave: 1
depends_on: []
files_modified:
  - calendar/cycling-2026.md
autonomous: true
requirements: [CAL-01]
must_haves:
  truths:
    - "User can open calendar/cycling-2026.md and read the standard weekly session pattern (Mon–Sun)"
    - "User can open calendar/cycling-2026.md and read the full Sunday long-ride progression from May 11–17 through Aug 3–9"
    - "Marker rows (SPORTIVE, BENCHMARK, REHEARSAL, HEATHLAND) are preserved verbatim as load-shape signals"
  artifacts:
    - path: "calendar/cycling-2026.md"
      provides: "Single source of truth for Jonas's cycling load through 2026-08-09"
      contains: "## Standard week"
  key_links:
    - from: "calendar/cycling-2026.md"
      to: "Phase 2 CAL-02 daily target resolution"
      via: "Two-table structure: standard-week (day → session/kcal) + Sunday-progression (date-range → long-ride/kcal) per D-08"
      pattern: "## Sunday progression"
---

<objective>
Create `calendar/cycling-2026.md` as the single source of truth for Jonas's training load, lifted directly from the cycling tables in `.planning/PROJECT.md` (lines 50–82) per D-06..D-09.

Purpose: Establishes the integration contract that Phase 2 CAL-02 and Phase 3 slash commands depend on for daily kcal target resolution.
Output: One markdown file with frontmatter, two tables, and verbatim marker rows.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-foundation/01-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create calendar/cycling-2026.md with two tables</name>
  <read_first>
    - .planning/PROJECT.md (specifically lines 50–82 — the two cycling tables)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-06..D-09 calendar shape rules)
  </read_first>
  <files>calendar/cycling-2026.md</files>
  <action>
    1. `mkdir -p calendar`
    2. Create `calendar/cycling-2026.md` with this exact structure:

```
---
title: Cycling Calendar 2026
category: calendar
source: PROJECT.md
last_updated: 2026-05-05
---

# Cycling Calendar 2026

## Standard week

| Day | Session | Duration | Est. kcal |
|-----|---------|----------|-----------|
| Mon | Z1 commute (both legs) | ~50 min | 250–300 |
| Tue | Intensity (VO2 / Threshold, alt.) | 60–75 min | 700–800 |
| Wed | Z2 Zwift indoor | 45–60 min | 450–500 |
| Thu | OFF | — | 0 |
| Fri | Fasted Z2 (75 min) + Z1 commute home | ~100 min | 750–850 |
| Sat | Strength (full body) | 45–60 min | 250–350 |
| Sun | Long Z2 outdoor (variable) | varies | see below |

## Sunday progression

| Week | Long ride | Est. kcal |
|------|-----------|-----------|
| May 11–17 | 70 km / 2:50 | 1,500 |
| May 18–24 | 85 km / 3:30 | 1,800 |
| **May 25–31** | **105 km gravel SPORTIVE** | 2,500 |
| Jun 1–7 | 60 km recovery | 1,300 |
| Jun 8–14 | 95 km | 2,000 |
| Jun 15–21 | 110 km | 2,400 |
| Jun 22–28 | 80 km recovery | 1,700 |
| **Jun 29–Jul 5** | **180 km road BENCHMARK** | 3,500 |
| Jul 6–12 | 100 km gravel | 2,300 |
| **Jul 13–19** | **140 km gravel REHEARSAL** | 3,200 |
| Jul 20–26 | 90 km recovery | 2,000 |
| Jul 27–Aug 2 | 60 km taper | 1,300 |
| **Aug 3–9** | **HEATHLAND 161 km gravel (event)** | 3,800 |
```

    3. Marker rows (SPORTIVE, BENCHMARK, REHEARSAL, HEATHLAND) MUST appear verbatim with `**bold**` formatting per D-09 — Phase 3 keys off them.
    4. Standard week MUST have 7 day rows (Mon–Sun); Sunday progression MUST have 13 week rows (May 11–17 through Aug 3–9).
    5. Frontmatter has exactly 4 fields per D-07: `title`, `category: calendar`, `source: PROJECT.md`, `last_updated: 2026-05-05`. No extras (D-04 spirit).
  </action>
  <verify>
    <automated>test -f calendar/cycling-2026.md && head -1 calendar/cycling-2026.md | grep -qx '\-\-\-' && grep -q "^category: calendar$" calendar/cycling-2026.md && grep -q "^source: PROJECT.md$" calendar/cycling-2026.md && grep -q "^last_updated: 2026-05-05$" calendar/cycling-2026.md && grep -q "^## Standard week$" calendar/cycling-2026.md && grep -q "^## Sunday progression$" calendar/cycling-2026.md && grep -q "SPORTIVE" calendar/cycling-2026.md && grep -q "BENCHMARK" calendar/cycling-2026.md && grep -q "REHEARSAL" calendar/cycling-2026.md && grep -q "HEATHLAND" calendar/cycling-2026.md && grep -q "^| Mon |" calendar/cycling-2026.md && grep -q "^| Sun |" calendar/cycling-2026.md && grep -q "May 11–17" calendar/cycling-2026.md && grep -q "Aug 3–9" calendar/cycling-2026.md && echo OK</automated>
  </verify>
  <acceptance_criteria>
    - `calendar/cycling-2026.md` exists
    - Line 1 is `---`
    - Contains `category: calendar`
    - Contains `source: PROJECT.md`
    - Contains `last_updated: 2026-05-05`
    - Contains `## Standard week`
    - Contains `## Sunday progression`
    - Standard-week table has rows for Mon, Tue, Wed, Thu, Fri, Sat, Sun (7 days)
    - Sunday-progression table has 13 week rows from `May 11–17` through `Aug 3–9`
    - Contains marker tokens verbatim: `SPORTIVE`, `BENCHMARK`, `REHEARSAL`, `HEATHLAND`
    - kcal values for each row match PROJECT.md lines 50–82 exactly
  </acceptance_criteria>
  <done>calendar/cycling-2026.md exists with both locked tables and frontmatter; Phase 2 CAL-02 has the integration contract it needs.</done>
</task>

</tasks>

<verification>
- File exists with correct frontmatter
- Both tables present with correct row counts (7 + 13)
- All 4 marker tokens present
- kcal values match PROJECT.md source
</verification>

<success_criteria>
ROADMAP Phase 1 success criterion #5 satisfied: User can open `calendar/cycling-2026.md` and read the standard weekly session pattern plus the full Sunday long-ride progression through 2026-08-09.
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation/01-03-SUMMARY.md` documenting: file created, table row counts, marker rows preserved.
</output>
