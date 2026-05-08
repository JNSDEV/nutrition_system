---
phase: 02-trackers-baselines
plan: 02
subsystem: trackers/farva
tags: [tracker, farva, baseline, scaffold]
requires:
  - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-01, D-06, D-07, D-08)
  - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention)
provides:
  - trackers/farva/progress.md (slim baseline tracker)
  - trackers/farva/daily/ (tracked empty dir for Phase 3 /log-day)
  - trackers/farva/weekly/ (tracked empty dir for Phase 3 /weekly-review)
affects:
  - Phase 3 commands (/log-day, /weekly-review) — will write into these dirs
  - CAL-02 contract Farva branch (library/cal-02-contract.md, plan 02-05) — slimmer output schema for person: farva
tech-stack:
  added: []
  patterns:
    - Slim baseline frontmatter (D-06): no Event, no training fields, no protein floor, no secondary target
    - Lowercase directory + Title-case display (D-01): trackers/farva/ + "Farva" in title
    - .gitkeep convention for tracked empty dirs (matches Jonas tracker scaffold from 02-01)
key-files:
  created:
    - trackers/farva/progress.md
    - trackers/farva/daily/.gitkeep
    - trackers/farva/weekly/.gitkeep
  modified: []
decisions:
  - Used `<discussion>` as source per D-07 (authored fresh from CONTEXT.md, not migrated from .txt)
  - Body kept minimal: ## Targets + ## Notes only — no ## Event (forbidden by D-06), no ## Training (Jonas-only per D-11)
  - target_date stored as bare token `ASAP` (not quoted) — matches D-08 lock and the verbatim frontmatter example in 02-CONTEXT.md lines 152–164
metrics:
  duration: ~5 min
  tasks_completed: 2
  files_created: 3
  files_modified: 0
  completed: 2026-05-05
---

# Phase 02 Plan 02: Farva Tracker Scaffold Summary

Seeded Farva's progress tracker (slim baseline: 58 → 53 kg ASAP, no event, no training fields) and created tracked-but-empty `daily/` + `weekly/` directories so Phase 3 commands have target paths. Mirrors the Jonas scaffold from plan 02-01 but with the D-06 slim shape.

## What Shipped

### `trackers/farva/progress.md`
Slim frontmatter per D-06/D-07/D-08 — only the both-people fields plus the locked Farva seed values:

```yaml
title: Farva — Progress
category: tracker
person: farva
source: <discussion>
last_updated: 2026-05-05
start_weight_kg: 58
target_weight_kg: 53
target_date: ASAP
```

Body: `## Targets` (primary 53 kg ASAP, no training-load fueling) + `## Notes` (running history lives in weekly summaries). No `## Event` heading. No `## Training` heading. No Jonas-only frontmatter fields (`event`, `event_window`, `secondary_target_kg`, `secondary_target_date`, `protein_floor_g_per_day`).

### `trackers/farva/daily/.gitkeep` and `trackers/farva/weekly/.gitkeep`
Empty placeholder files so the two empty subdirectories are tracked by git. Phase 3 `/log-day` writes into `daily/YYYY-MM-DD.md` (D-02), `/weekly-review` writes into `weekly/YYYY-Www.md` (D-03).

## Tasks → Commits

| Task | Name                                              | Commit  | Files                                                              |
| ---- | ------------------------------------------------- | ------- | ------------------------------------------------------------------ |
| 1    | Create Farva progress.md with slim frontmatter    | 4e484fa | trackers/farva/progress.md                                         |
| 2    | Create empty tracked daily/ + weekly/ for Farva   | 5ddc6d5 | trackers/farva/daily/.gitkeep, trackers/farva/weekly/.gitkeep      |

## Verification

Both `<verify>` blocks executed and passed. Specifically:
- `trackers/farva/progress.md` exists at the lowercase path (NOT `partner/`, NOT `Farva/`)
- All required frontmatter keys present with locked values; all forbidden keys absent
- `## Targets` and `## Notes` headings present in correct order; `## Event` heading absent
- Both `.gitkeep` files exist; both directories exist on disk and are tracked by git

## Success Criteria

ROADMAP success criterion #2 (re-mapped per D-01) satisfied: opening `trackers/farva/progress.md` immediately shows `start_weight_kg: 58` and `target_weight_kg: 53` with `target_date: ASAP`. Phase 3 commands have empty-but-tracked daily/weekly directories to write into.

## Deviations from Plan

None — plan executed exactly as written. No bugs found, no missing functionality, no blocking issues, no architectural decisions required.

## Authentication Gates

None — no external services, no auth required (markdown-only system).

## Known Stubs

None. The scaffold is intentionally minimal (slim baseline + empty dirs); Phase 3 fills in the daily/weekly logs. This is by design per D-06 and the plan's `<objective>`, not a stub.

## Threat Flags

None. No new network endpoints, auth paths, file access patterns, or trust-boundary changes — this plan only writes static markdown files inside the project's own `trackers/` tree.

## Self-Check: PASSED

- FOUND: trackers/farva/progress.md
- FOUND: trackers/farva/daily/.gitkeep
- FOUND: trackers/farva/weekly/.gitkeep
- FOUND commit: 4e484fa
- FOUND commit: 5ddc6d5
