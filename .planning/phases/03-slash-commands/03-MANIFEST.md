---
title: Phase 3 — Slash Commands Manifest
category: planning
phase: 03
last_updated: 2026-05-06
---

# Phase 3: Slash Commands — Plan Manifest

**Phase goal:** All 6 operating-loop commands implemented as Claude Code slash commands that read from the library and trackers, and write into the appropriate dated files.

**Requirements covered:** CMD-01, CMD-02, CMD-03, CMD-04, CMD-05, CMD-06

---

## Plans

| Plan | File | Requirements | Wave | Depends On | Autonomous | Files Touched |
|------|------|--------------|------|------------|------------|---------------|
| 03-00 | 03-00-setup-PLAN.md | CMD-01..06 (prerequisite) | 1 | — | yes | `.claude/commands/README.md` |
| 03-01 | 03-01-prep-today-PLAN.md | CMD-01 | 2 | 03-00 | no (checkpoint) | `.claude/commands/prep-today.md` |
| 03-02 | 03-02-log-day-PLAN.md | CMD-02 | 2 | 03-00 | no (checkpoint) | `.claude/commands/log-day.md` |
| 03-03 | 03-03-weekly-plan-PLAN.md | CMD-03 | 2 | 03-00 | no (checkpoint) | `.claude/commands/weekly-plan.md` |
| 03-04 | 03-04-shopping-list-PLAN.md | CMD-04 | 3 | 03-03 | no (checkpoint) | `.claude/commands/shopping-list.md` |
| 03-05 | 03-05-weekly-review-PLAN.md | CMD-05 | 2 | 03-00 | no (checkpoint) | `.claude/commands/weekly-review.md` |
| 03-06 | 03-06-swap-meal-PLAN.md | CMD-06 | 2 | 03-00 | no (checkpoint) | `.claude/commands/swap-meal.md` |

---

## Dependency Graph

```
03-00 (Wave 1)
  └── 03-01 (Wave 2) — /prep-today
  └── 03-02 (Wave 2) — /log-day
  └── 03-03 (Wave 2) — /weekly-plan
      └── 03-04 (Wave 3) — /shopping-list
  └── 03-05 (Wave 2) — /weekly-review
  └── 03-06 (Wave 2) — /swap-meal
```

**Key dependency note:** 03-04 (`/shopping-list`) depends on 03-03 (`/weekly-plan`) because the shopping-list command reads the weekly-plan file shape produced by `/weekly-plan`. The executor of 03-04 should confirm the `trackers/weekly-plans/YYYY-Www.md` file shape from 03-03 before writing the shopping-list command.

All other Wave 2 plans (03-01, 03-02, 03-03, 03-05, 03-06) are independent of each other and can run in parallel.

---

## Wave Execution Order

### Wave 1 — Must complete first
| Plan | Action |
|------|--------|
| 03-00 | Create `.claude/commands/` directory + write README.md with all shared conventions |

### Wave 2 — Parallel after Wave 1 (except 03-04)
| Plan | Command File | Can Run Parallel With |
|------|-------------|----------------------|
| 03-01 | prep-today.md | 03-02, 03-03, 03-05, 03-06 |
| 03-02 | log-day.md | 03-01, 03-03, 03-05, 03-06 |
| 03-03 | weekly-plan.md | 03-01, 03-02, 03-05, 03-06 |
| 03-05 | weekly-review.md | 03-01, 03-02, 03-03, 03-06 |
| 03-06 | swap-meal.md | 03-01, 03-02, 03-03, 03-05 |

### Wave 3 — After 03-03 completes
| Plan | Command File | Notes |
|------|-------------|-------|
| 03-04 | shopping-list.md | Reads weekly-plan file shape; execute after 03-03 human-verify is approved |

---

## Files Created by This Phase

```
.claude/commands/
  README.md              (03-00)
  prep-today.md          (03-01)
  log-day.md             (03-02)
  weekly-plan.md         (03-03)
  shopping-list.md       (03-04)
  weekly-review.md       (03-05)
  swap-meal.md           (03-06)

trackers/weekly-plans/   (directory created by /weekly-plan on first use)
  YYYY-Www.md            (runtime output of /weekly-plan)
  YYYY-Www-shopping.md   (runtime output of /shopping-list)
```

---

## D-22 Resolution (Planner Decision)

The open question in D-22 ("per-week kcal-target field in progress.md") is resolved as follows:

**Decision: Additive `weekly_kcal_adjustments` list in progress.md frontmatter.**

Schema:
```yaml
weekly_kcal_adjustments:
  - week: 2026-W19
    delta_kcal_per_day: +200
    reason: ">0.8 kg/wk loss — adding carbs on training days"
    applied: 2026-05-06
```

Rationale:
- Does NOT overwrite `target_weight_kg` or `target_date` (those are milestone goals, not weekly levers)
- Does NOT require touching `library/calorie-targets.md` (the formula stays durable and person-agnostic)
- The most recent entry's `delta_kcal_per_day` is additive on top of `base_kcal` from the CAL-02 formula
- Multiple adjustments across weeks are preserved in order — the history is self-documenting in progress.md
- Honors Phase 2 D-15: progress.md is durable; weekly-summaries are append-only

All 6 commands that touch kcal targets (and `/weekly-review` specifically) implement this field shape as documented in `.claude/commands/README.md`.

---

## ROADMAP Discrepancy Note

ROADMAP.md Phase 3 success criteria still reference "Partner" (e.g. "Jonas vs Partner", "Jonas or Partner"). The canonical name resolved in Phase 2 is `farva` (directory token) / `Farva` (display name). All Phase 3 plan files use `farva`/`Farva`. The ROADMAP.md update is deferred to Phase 4 docs sweep (per Phase 3 CONTEXT.md deferred section).

---

## Source Coverage Audit

| Source | ID | Item | Covered By |
|--------|----|------|------------|
| REQUIREMENTS | CMD-01 | /prep-today command | 03-01 |
| REQUIREMENTS | CMD-02 | /log-day command | 03-02 |
| REQUIREMENTS | CMD-03 | /weekly-plan command | 03-03 |
| REQUIREMENTS | CMD-04 | /shopping-list command | 03-04 |
| REQUIREMENTS | CMD-05 | /weekly-review command | 03-05 |
| REQUIREMENTS | CMD-06 | /swap-meal command | 03-06 |
| ROADMAP SC-1 | — | prep-today brief with portions | 03-01 |
| ROADMAP SC-2 | — | log-day writes both files + training | 03-02 |
| ROADMAP SC-3 | — | weekly-plan 7-day from library | 03-03 |
| ROADMAP SC-4 | — | shopping-list from plan + pantry | 03-04 |
| ROADMAP SC-5 | — | weekly-review weight/adherence/adjustment | 03-05 |
| ROADMAP SC-6 | — | swap-meal fits remaining macros | 03-06 |
| CONTEXT D-01 | — | .claude/commands/{name}.md shape | 03-00 |
| CONTEXT D-02 | — | conversational args, no positional | 03-00 |
| CONTEXT D-03 | — | write/propose/chat matrix | 03-00 |
| CONTEXT D-04 | — | library:meals#{anchor} resolution | 03-00, applied in 03-02/03/04/06 |
| CONTEXT D-05 | — | date semantics + file paths | 03-00 |
| CONTEXT D-06 | — | person identifiers jonas/farva | 03-00 |
| CONTEXT D-07 | — | /prep-today scope + reads | 03-01 |
| CONTEXT D-08 | — | /prep-today 4-section output | 03-01 |
| CONTEXT D-09 | — | /prep-today no-plan guard | 03-01 |
| CONTEXT D-10 | — | /log-day scope + template instantiation | 03-02 |
| CONTEXT D-11 | — | /log-day two-step MFP paste flow | 03-02 |
| CONTEXT D-12 | — | /log-day smart-merge rules | 03-02 |
| CONTEXT D-13 | — | /log-day conversational meal entry | 03-02 |
| CONTEXT D-14 | — | /weekly-plan batched 4-question opener | 03-03 |
| CONTEXT D-15 | — | /weekly-plan algorithm | 03-03 |
| CONTEXT D-16 | — | /weekly-plan propose-then-write | 03-03 |
| CONTEXT D-17 | — | /weekly-plan amend-or-replace guard | 03-03 |
| CONTEXT D-18 | — | /shopping-list reads plan + recipes | 03-04 |
| CONTEXT D-19 | — | /shopping-list propose-then-write | 03-04 |
| CONTEXT D-20 | — | /weekly-review writes both files | 03-05 |
| CONTEXT D-21 | — | /weekly-review computation | 03-05 |
| CONTEXT D-22 | — | /weekly-review apply adjustment | 03-05 (+ D-22 resolved by planner) |
| CONTEXT D-23 | — | /swap-meal chat-only + remaining macros | 03-06 |
| CONTEXT D-24 | — | /swap-meal no file write | 03-06 |

All 24 decisions and all 6 requirements covered. No gaps.
