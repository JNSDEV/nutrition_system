---
title: Phase 4 — Onboarding & Docs Manifest
category: planning
phase: 04
last_updated: 2026-05-07
---

# Phase 4: Onboarding & Docs — Plan Manifest

**Phase goal:** A first-time reader can understand the system, navigate to any file, and know how to log from a phone without any prior explanation.

**Requirements covered:** DOC-01, DOC-02

---

## Plans

| Plan | File | Requirements | Wave | Depends On | Autonomous | Files Touched |
|------|------|--------------|------|------------|------------|---------------|
| 04-01 | 04-01-readme-PLAN.md | DOC-01 | 1 | — | no (checkpoint) | `README.md` |
| 04-02 | 04-02-conventions-PLAN.md | DOC-02 | 1 | — | no (checkpoint) | `docs/conventions.md` |
| 04-03 | 04-03-changelog-PLAN.md | DOC-01 | 1 | — | yes | `CHANGELOG.md` |
| 04-04 | 04-04-contributing-PLAN.md | DOC-01 | 1 | — | yes | `CONTRIBUTING.md` |
| 04-05 | 04-05-terminology-cleanup-PLAN.md | DOC-01, DOC-02 | 1 | — | yes | `.planning/PROJECT.md`, `.planning/REQUIREMENTS.md`, `.planning/ROADMAP.md` |

---

## Dependency Graph

```
All five plans are independent — no cross-file dependencies.
Each plan writes exclusively to its own file(s).
All plans run in Wave 1.

04-01 (Wave 1) — README.md
04-02 (Wave 1) — docs/conventions.md
04-03 (Wave 1) — CHANGELOG.md
04-04 (Wave 1) — CONTRIBUTING.md
04-05 (Wave 1) — .planning/{PROJECT,REQUIREMENTS,ROADMAP}.md
```

**Why independent:** Each plan creates or edits a disjoint set of files. No plan reads output produced by another plan in this phase (04-01 links to docs/conventions.md, but docs/conventions.md is a path reference, not a runtime input to the README writing task).

**Recommended execution order:** Run all five in parallel or in any order. If running sequentially, 04-05 (terminology cleanup) last is slightly preferable — the cleanup edits ROADMAP.md and REQUIREMENTS.md, which are also read by 04-01/04-02 for context. Running 04-05 last means the new docs were drafted against the slightly stale terminology, but since content is pulled from CONTEXT.md (not ROADMAP prose), this has zero practical impact.

---

## Wave Execution Order

### Wave 1 — All plans (fully parallel)

| Plan | Action | Checkpoint? |
|------|--------|-------------|
| 04-01 | Create `README.md` with 7 locked sections | yes — human reads and approves |
| 04-02 | Create `docs/conventions.md` with 7 locked sections | yes — human reads and approves |
| 04-03 | Create `CHANGELOG.md` with Keep-a-Changelog v1.0 entry | no |
| 04-04 | Create `CONTRIBUTING.md` with 3 sections | no |
| 04-05 | Edit PROJECT.md / REQUIREMENTS.md / ROADMAP.md: Partner → Farva + hybrid-kcal fix | no |

---

## Files Created by This Phase

```
README.md                       (04-01) — new
docs/
  conventions.md                (04-02) — new (docs/ dir created)
CHANGELOG.md                    (04-03) — new
CONTRIBUTING.md                 (04-04) — new

Edited (not created):
.planning/PROJECT.md            (04-05) — terminology + hybrid-kcal fix
.planning/REQUIREMENTS.md       (04-05) — TRK-02 partner→farva
.planning/ROADMAP.md            (04-05) — Phase 1/2/3 SC Partner→Farva
```

---

## Source Coverage Audit

| Source | ID | Item | Covered By |
|--------|----|------|------------|
| REQUIREMENTS | DOC-01 | Top-level README.md | 04-01 |
| REQUIREMENTS | DOC-02 | docs/conventions.md | 04-02 |
| ROADMAP SC-1 | — | README: loop, file locations, mobile logging | 04-01 |
| ROADMAP SC-2 | — | conventions.md: file naming, date format, person-name resolution | 04-02 |
| CONTEXT D-01 | — | README opens with operating-loop diagram | 04-01 |
| CONTEXT D-02 | — | README and conventions.md split by purpose | 04-01, 04-02 |
| CONTEXT D-03 | — | README locked 7-section order | 04-01 |
| CONTEXT D-04 | — | Quickstart week in README (6-row table) | 04-01 |
| CONTEXT D-05 | — | ASCII folder tree in README | 04-01 |
| CONTEXT D-06 | — | Mobile-buffer worked example in README | 04-01 |
| CONTEXT D-07 | — | conventions.md locked 7-section order | 04-02 |
| CONTEXT D-08 | — | Rename procedure (4 steps) in conventions.md | 04-02 |
| CONTEXT D-09 | — | Terminology cleanup sweep (Partner → Farva) | 04-05 |
| CONTEXT D-10 | — | DOC-02 wording preserved unchanged | 04-02, 04-05 |
| CONTEXT D-11 | — | CHANGELOG.md with Keep-a-Changelog v1.0 entry | 04-03 |
| CONTEXT D-12 | — | CONTRIBUTING.md with 3 sections | 04-04 |

All 12 decisions and both requirements covered. No gaps.

---

## Frozen Artifact Constraint

`.planning/phases/01-*`, `.planning/phases/02-*`, `.planning/phases/03-*` — all files in these directories are frozen historical artifacts and MUST NOT be edited by any Phase 4 plan.

Plan 04-05 includes an explicit pre-edit grep verification step to confirm the frozen directories are left untouched.

---

## REQUIREMENTS.md DOC-01/DOC-02 Checkbox Flip

Per D-09, the `[ ]` checkboxes on DOC-01 and DOC-02 in REQUIREMENTS.md should be flipped to `[x]` once Phase 4 ships. This is NOT part of plan 04-05 — it should be done as part of the phase-close commit (e.g. after all five plans have completed and been verified). The checkpoint step is noted here so it is not forgotten.

---

*Phase: 04-onboarding-docs*
*Manifest written: 2026-05-07*
