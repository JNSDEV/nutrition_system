---
phase: 02-trackers-baselines
plan: 01
subsystem: trackers/jonas
tags: [tracker, jonas, baselines, heathland]
requires:
  - calendar/cycling-2026.md
  - .planning/phases/02-trackers-baselines/02-CONTEXT.md
provides:
  - trackers/jonas/progress.md
  - trackers/jonas/daily/
  - trackers/jonas/weekly/
affects:
  - Phase 3 /log-day, /prep-today, /weekly-review (consume progress.md baselines + Event phase mapping)
tech-stack:
  added: []
  patterns: [markdown-frontmatter, gitkeep-empty-dirs]
key-files:
  created:
    - trackers/jonas/progress.md
    - trackers/jonas/daily/.gitkeep
    - trackers/jonas/weekly/.gitkeep
  modified: []
decisions:
  - "Build phase mapped May 11 – Jul 19 (covers SPORTIVE, BENCHMARK, REHEARSAL markers); taper Jul 20 – Aug 2; peak Aug 3–9 HEATHLAND week — grounded verbatim in cycling-2026.md Sunday progression rows"
  - "REHEARSAL token (Jul 13–19) included as a build-phase signal alongside BENCHMARK/SPORTIVE — CONTEXT.md D-05 only enumerated BENCHMARK/SPORTIVE explicitly, but REHEARSAL is a peer marker in cycling-2026.md and belongs in build"
metrics:
  duration_minutes: 3
  tasks_completed: 2
  files_created: 3
  files_modified: 0
  completed_date: 2026-05-05
---

# Phase 2 Plan 01: Jonas Tracker Scaffold Summary

Seeded Jonas's `progress.md` with locked baselines (87.9 → 85 → 80 kg, Heathland 161 km gravel 2026-08-03..09, protein floor 150–180 g/day) and a `## Event` section that grounds build/taper/peak phases in the actual SPORTIVE/BENCHMARK/REHEARSAL/HEATHLAND tokens from `calendar/cycling-2026.md`. Created tracked-but-empty `daily/` and `weekly/` subdirectories ready for Phase 3 commands to populate.

## What Shipped

- `trackers/jonas/progress.md` — frontmatter exactly per D-07/D-08 (verbatim seed values), with `## Targets`, `## Event`, `## Notes` body sections in locked order.
- `trackers/jonas/daily/.gitkeep` and `trackers/jonas/weekly/.gitkeep` — empty placeholders so Phase 3 `/log-day` (D-02) and `/weekly-review` (D-03) have target directories on first write.

## Event Phase Mapping (grounded in cycling-2026.md)

| Phase | Window | Anchor markers |
| ----- | ------ | -------------- |
| Build | May 11 – Jul 19 | SPORTIVE (May 25–31, 105 km gravel), BENCHMARK (Jun 29 – Jul 5, 180 km road), REHEARSAL (Jul 13–19, 140 km gravel) |
| Taper | Jul 20 – Aug 2 | recovery 90 km → taper 60 km |
| Peak  | Aug 3–9 | HEATHLAND 161 km gravel (event) |

Phase 3 `/weekly-review` will read this section to reason about training-load shifts.

## Tasks & Commits

| Task | Name | Commit |
| ---- | ---- | ------ |
| 1    | Create trackers/jonas/progress.md | `0bd8cb3` |
| 2    | Create empty tracked daily/ and weekly/ subdirectories | `821af22` |

## Verification

- All `<verify>` automated grep assertions for Task 1 passed (every locked frontmatter field present verbatim incl. en-dash in `protein_floor_g_per_day: 150–180`).
- Task 2 verified: both `.gitkeep` files exist and are committed; both directories tracked; no stray log files.
- ROADMAP success criterion #1 satisfied: `trackers/jonas/progress.md` shows starting weight 87.9 kg, primary target 85 kg by 2026-05-30, secondary 80 kg ASAP, Heathland event 2026-08-03/09.

## Deviations from Plan

None — plan executed as written. One minor authoring choice within the Discretion budget (CONTEXT.md "Claude's Discretion" bullet on Event mapping): included the REHEARSAL token as a build-phase anchor. Rationale: REHEARSAL is the same class of tokenized milestone as BENCHMARK/SPORTIVE on the cycling-2026.md Sunday progression, and excluding it would leave Jul 13–19 unaccounted for in the build narrative. Disposition documented in `decisions[]` above.

## Known Stubs

None. Both `.gitkeep` files are intentionally empty placeholders for tracked directories — they are not stubs, they are the artifact spec'd by D-02/D-03.

## Self-Check: PASSED

- `trackers/jonas/progress.md` — FOUND
- `trackers/jonas/daily/.gitkeep` — FOUND
- `trackers/jonas/weekly/.gitkeep` — FOUND
- Commit `0bd8cb3` — FOUND
- Commit `821af22` — FOUND
