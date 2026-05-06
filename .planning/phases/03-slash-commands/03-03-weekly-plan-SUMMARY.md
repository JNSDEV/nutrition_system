---
phase: 03-slash-commands
plan: "03"
subsystem: slash-commands
tags: [weekly-plan, conversational, propose-write, cycling-load, 4-portion]
dependency_graph:
  requires: [03-00]
  provides: [CMD-03, weekly-plan-command]
  affects: [03-04-shopping-list, 03-01-prep-today]
tech_stack:
  added: []
  patterns: [propose-then-write, batched-questions, consecutive-dinner-pairs]
key_files:
  created:
    - .claude/commands/weekly-plan.md
  modified: []
decisions:
  - "D-17 amend-or-replace guard is Step 1 — fires before any other logic"
  - "D-14 batched 4-question opener with cycling-calendar pre-fill (Q2) and prior-week dinner pre-fill (Q3)"
  - "D-15 plan algorithm: 3 cook-events, consecutive dinner pairs, cycling-load alignment, protein floor check"
  - "D-16 propose-then-write: markdown table in chat, natural-language amendment loop, file write only on confirm"
metrics:
  duration: ~10 min
  completed: 2026-05-06
  tasks_completed: 1
  files_created: 1
  files_modified: 0
---

# Phase 3 Plan 03: Weekly Plan Command Summary

## One-liner

Conversational 7-day meal planner with batched 4-question opener, consecutive dinner-pair algorithm, cycling-load alignment, and propose-then-write loop writing to `trackers/weekly-plans/YYYY-Www.md`.

## What Was Built

`.claude/commands/weekly-plan.md` — the `/weekly-plan` slash command implementing the full D-14..D-17 flow:

**Step 1 (D-17):** Checks for an existing week plan. If found, displays it as a table and asks "amend or replace?" before proceeding.

**Step 2 (D-14):** One batched chat turn with all four questions — fridge/leftovers, training peak (with cycling-calendar pre-fill identifying highest-load day by session_type priority order), repeat meals (with prior-week dinner pre-fill), dislikes/cravings.

**Step 3:** Reads 7 planning input files: meals.md, macro-templates.md, fast-food-rules.md, preferences.md, jonas/progress.md, cycling-2026.md, cal-02-contract.md.

**Step 4 (D-15):** 8-rule plan algorithm in priority order — fridge-first, dislikes/cravings, cycling-load alignment (carb-heavy on long-ride/race days, lighter on rest days), 3 consecutive dinner pairs with COOK flags and 1 flex day, leftover lunches by default, breakfast rotation from meals.md (default: Protein overnight oats), snacks per macro-templates.md, Jonas protein floor check with auto-adjustment.

**Step 5 (D-16):** Full week as markdown table (Day | Lunch | Dinner | Training | Notes) with `library:meals#{anchor}` refs and COOK markers. Natural-language amendment loop — applies change, re-shows table, waits for next confirm. No file write until "ok"/"write it"/"looks good".

**Step 6:** Writes `trackers/weekly-plans/{this-iso-week}.md` with required frontmatter (title, category, iso_week, last_updated) and per-day structure (Breakfast / Lunch / Dinner / Snack / Training / Notes). Confirms with follow-up commands suggestion.

## Deviations from Plan

None — plan executed exactly as written. The file was found already committed in `1c2db3f` (feat(03-05)) from a prior session that batch-created multiple command files simultaneously.

## Known Stubs

None. The command file is a prompt template — no data stubs present.

## Threat Flags

None. This command reads library/tracker files and writes to `trackers/weekly-plans/`. No new network endpoints, auth paths, or trust-boundary crossings introduced.

## Self-Check: PASSED

- `.claude/commands/weekly-plan.md` exists: FOUND
- Commit `1c2db3f` contains the file: FOUND
- Keyword verification (13 matches vs threshold 5): PASSED
- All D-14..D-17 requirements present in file: PASSED
