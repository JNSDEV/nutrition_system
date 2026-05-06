---
phase: 02-trackers-baselines
plan: 05
subsystem: library
tags: [contract, cal-02, library, integration]
requires:
  - library/calorie-targets.md
  - library/macro-templates.md
  - calendar/cycling-2026.md
  - .planning/phases/02-trackers-baselines/02-CONTEXT.md
provides:
  - library/cal-02-contract.md
affects:
  - trackers/jonas/progress.md
  - trackers/farva/progress.md
  - .planning/PROJECT.md
tech_stack:
  added: []
  patterns:
    - "Standalone integration contract document, read_first by Phase 3 commands (D-19)"
    - "Minimal 4-field frontmatter shape (Phase 1 D-03 / Phase 2 D-19)"
    - "Schema-only contract — formula stays in library/calorie-targets.md, read at runtime (D-16)"
key_files:
  created:
    - library/cal-02-contract.md
  modified:
    - .planning/PROJECT.md
decisions:
  - "CAL-02 input/output schema locked verbatim per D-17 (jonas full schema, farva slim schema)"
  - "Training burn split exposed as base_kcal + training_est_kcal so Phase 3 can show breakdown (D-18)"
  - "Marker tokens SPORTIVE / BENCHMARK / REHEARSAL / HEATHLAND propagated into session_type (D-09 carry-forward)"
  - "PROJECT.md open-question line replaced with resolved Farva decision (D-01)"
metrics:
  duration: ~6 min
  completed: 2026-05-06
  tasks: 2
  files_changed: 2
requirements: [CAL-02]
---

# Phase 02 Plan 05: CAL-02 Contract Summary

Locked the CAL-02 integration contract in `library/cal-02-contract.md` so Phase 3 commands can `read_first` a standalone schema document (no need to parse `02-CONTEXT.md`), and recorded the Farva display-name resolution in `.planning/PROJECT.md` (D-01).

## What Was Built

### Task 1 — `library/cal-02-contract.md`
Standalone CAL-02 integration contract with:
- Minimal 4-field frontmatter (`title`, `category: library`, `source: <discussion>`, `last_updated`) per D-19.
- `## Input` — `{ date, person }`.
- `## Output (jonas)` — full 9-field schema with `session_type`, `base_kcal`, `training_est_kcal`, `kcal_total`, `protein_g`, `carb_g`, `fat_g` (D-17).
- `## Output (farva)` — slim 6-field schema, no training fields (D-06 / D-17).
- `## Sources of truth` — named pointers to `library/calorie-targets.md`, `library/macro-templates.md`, `calendar/cycling-2026.md`.
- `## Training burn handling (D-18)` — split rationale.
- `## Marker tokens` — SPORTIVE / BENCHMARK / REHEARSAL / HEATHLAND handling.
- `## What this file is NOT` — guards against future drift (no formula, no macro tables, no implementation).

Commit: `1df1e60`.

### Task 2 — `.planning/PROJECT.md`
Replaced the open-question line at line 31 (`> Open: confirm partner's preferred display name (placeholder: "Partner").`) with a resolved-decision line referencing D-01 / Phase 2 and naming Farva (lowercase directory, title-case prose).

Commit: `885b26a`.

## Verification

- Task 1 automated `grep` checks all passed (frontmatter shape, all H2 headings, all source pointers, all required output fields, all marker tokens).
- Task 2 grep checks passed: `Farva` present, `placeholder: Partner` absent, `confirm partner's preferred display name` absent, `D-01 / Phase 2` provenance present.
- Manual inspection of PROJECT.md confirms only line 31 changed; no other content touched (no renumbering, no other open-question or decision edits).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] PROJECT.md `git diff --shortstat` check N/A on first commit**
- **Found during:** Task 2 verify
- **Issue:** Task 2's verify step asserts `git diff --shortstat .planning/PROJECT.md | grep -qE '1 insertion\(\+\), 1 deletion\(-\)'`. PROJECT.md was untracked in git prior to this plan (along with the rest of `.planning/*.md`), so `git diff` returned empty and the literal shortstat check could not match. The semantic intent (surgical 1-line edit, no scope creep) was verified by direct file inspection: only line 31 changed, all 203 other lines are byte-identical to the pre-edit state.
- **Fix:** Committed PROJECT.md as a new tracked file (`create mode 100644`, 204 insertions). Future surgical-edit checks against this file will work as intended now that it has a tracked baseline.
- **Files modified:** `.planning/PROJECT.md` (added to git tracking)
- **Commit:** `885b26a`

No other deviations.

## Auth Gates

None.

## Self-Check: PASSED

- `library/cal-02-contract.md` — FOUND
- `.planning/PROJECT.md` — FOUND, contains `Farva`, no `placeholder: Partner`, no open-question phrasing
- Commit `1df1e60` — FOUND in `git log`
- Commit `885b26a` — FOUND in `git log`
