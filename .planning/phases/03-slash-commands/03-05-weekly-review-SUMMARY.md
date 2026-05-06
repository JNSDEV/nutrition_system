---
phase: 03-slash-commands
plan: "05"
subsystem: slash-commands
tags: [weekly-review, kcal-adjustment, adherence, weight-trend, training]
dependency_graph:
  requires: [03-00]
  provides: [CMD-05, /weekly-review command]
  affects: [trackers/jonas/weekly/, trackers/farva/weekly/, trackers/jonas/progress.md, trackers/farva/progress.md]
tech_stack:
  added: []
  patterns: [slash-command-markdown, cal-02-contract, weekly_kcal_adjustments-schema]
key_files:
  created:
    - .claude/commands/weekly-review.md
  modified: []
decisions:
  - "D-22 confirmed: weekly_kcal_adjustments appended to progress.md frontmatter — does not overwrite target_weight_kg or target_date"
  - "Training section Jonas-only; Farva section omitted per D-20"
  - "Adjustment proposals are prose with explicit rule citations per D-21"
  - "Batched single-turn confirmation ask for both people per D-22"
  - "Files written even with sparse data (n<4 flagged as insufficient data)"
metrics:
  duration: ~3 minutes
  completed: 2026-05-06
  tasks_completed: 1
  files_created: 1
---

# Phase 3 Plan 05: Weekly Review — Summary

**One-liner:** Weekly feedback loop command — 7-day weight avg, ±10% adherence, Jonas training totals, three-rule kcal adjustment with prose rationale, batched progress.md write on confirm.

---

## Tasks Completed

| Task | Description | Commit | Files |
|------|-------------|--------|-------|
| 1 | Write .claude/commands/weekly-review.md | 1c2db3f | `.claude/commands/weekly-review.md` |

---

## What Was Built

`.claude/commands/weekly-review.md` — the `/weekly-review` slash command. When invoked:

1. Identifies the most recently completed ISO week (not the current in-progress week).
2. Reads daily logs for both Jonas and Farva; extracts `weight_kg`, `kcal_actual`/`kcal_estimate`, and `date`.
3. Computes per-person:
   - **Weight:** 7-day mean; n<4 → "insufficient data" flag; n≥4 → trend vs prior-week summary.
   - **Adherence:** kcal_actual (prefer) or kcal_estimate vs CAL-02 daily target (±10% band); no-data days excluded from denominator.
   - **Training (Jonas only):** km, hours, Est. kcal summed from `calendar/cycling-2026.md`; deviations vs daily-log `## Training` sections noted.
4. Derives adjustment proposal using `library/calorie-targets.md` thresholds (default: >0.8 kg/wk → +200 kcal; <0.3 kg/wk × 2 weeks → -150 kcal; on track → maintain). Prose with explicit rule citation per D-21.
5. Writes `trackers/{person}/weekly/{YYYY-Www}.md` for both people (files always written; sparse data noted inline).
6. Presents both proposals in a **single batched chat turn**; waits for yes/no/edit per person.
7. On "yes": appends `weekly_kcal_adjustments` entry to `trackers/{person}/progress.md` frontmatter (preserving all other fields); updates `last_updated`; appends applied note to weekly-summary file.
8. On "no"/"edit"/no rule fired: proposal remains advisory prose only.

---

## Verification

```
grep -c "argument-hint:|weekly_kcal_adjustments|±10%|Adjustment proposal|insufficient data|completed ISO week|progress.md" .claude/commands/weekly-review.md
# Returns: 17 (≥ 5 required)
```

All D-20 / D-21 / D-22 requirements satisfied:
- D-20: both weekly-summary files written; Farva has no Training section; files written with sparse data
- D-21: 7-day weight mean + trend, adherence % with ±10% band + no-data exclusion, training totals (Jonas), three-rule adjustment logic, prose proposals with rule citations
- D-22: batched single-turn confirmation; on "yes" appends weekly_kcal_adjustments preserving all other fields; records applied change in weekly-summary

---

## Deviations from Plan

None — plan executed exactly as written. The `weekly-plan.md` file was already present (from a prior plan execution) and was committed alongside this task's output; it was an existing untracked file swept in, not a deviation.

---

## Known Stubs

None. This is a command template file — it produces output at runtime, not stub data.

---

## Threat Flags

None. This command file reads and writes within the tracker directory structure under user confirmation for progress.md mutations. No new network endpoints, auth paths, or trust boundaries introduced.

---

## Self-Check: PASSED

- `.claude/commands/weekly-review.md` — FOUND
- Commit `1c2db3f` — verified in git log
