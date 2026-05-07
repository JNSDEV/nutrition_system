---
phase: 04-onboarding-docs
plan: "05"
subsystem: planning-docs
tags: [terminology, cleanup, d-09]
dependency_graph:
  requires: []
  provides: [updated-project-md, updated-requirements-md]
  affects: [.planning/PROJECT.md, .planning/REQUIREMENTS.md]
tech_stack:
  added: []
  patterns: [markdown-only-edits]
key_files:
  modified:
    - .planning/PROJECT.md
    - .planning/REQUIREMENTS.md
decisions:
  - "ROADMAP.md required no edits: Phase 2/3 success criteria already used Farva from prior planner work; line 88 plan-description bullet preserved as accurate historical context"
  - "PROJECT.md resolved-name callout (line 31) preserved: 'Partner's display name is Farva' is correct historical context, not stale terminology"
  - "DOC-02 wording preserved per D-10: 'placeholder Partner — overridable' is intentionally accurate"
metrics:
  duration: "~10 minutes"
  completed: "2026-05-07"
  tasks_completed: 2
  tasks_total: 2
---

# Phase 04 Plan 05: Terminology Cleanup Summary

**One-liner:** D-09 sweep replacing residual "Partner" with "Farva" across PROJECT.md and REQUIREMENTS.md, plus hybrid-kcal model wording locked to MFP/Cronometer actuals + library estimates pattern.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Verify scope — grep before editing | (pre-edit baseline, no commit) | baseline greps documented |
| 2 | Apply D-09 edits | d156f87 | .planning/PROJECT.md, .planning/REQUIREMENTS.md |

## Changes Made

### .planning/PROJECT.md

- Title paragraph: "for him and his partner" → "for him and Farva"
- Per-person trackers bullet: "Jonas and Partner" → "Jonas and Farva"
- Core Value: "Jonas and Partner" → "Jonas and Farva"
- Users table: "Partner" row → "Farva"; following prose updated
- Goals section: `### Partner` heading → `### Farva`
- Source Material code block: `partner/` path → `farva/`
- Active requirements bullet: `trackers/partner/` → `trackers/farva/`
- Active requirements bullet: "Jonas + Partner baselines" → "Jonas + Farva baselines"
- Key Decisions table: "Partner = consumer only" → "Farva = consumer only"
- Open Questions: removed the resolved "Partner's preferred display name" entry (resolved in Phase 2 D-01)
- **Hybrid-kcal wording**: added clarifying sentence — "The markdown system stores both actuals (from MFP/Cronometer) and estimates (from library formulas); it never recomputes the external app's number."

**Preserved:** Line 31 resolved-name callout (`> Resolved (Phase 2, D-01): Partner's display name is **Farva**`) — correct historical context.

### .planning/REQUIREMENTS.md

- TRK-02: `trackers/partner/` → `trackers/farva/` (requirement text)
- CMD-01: "portions for Jonas vs Partner" → "portions for Jonas vs Farva"
- CMD-02: "Jonas and Partner" → "Jonas and Farva"
- Traceability table TRK-02 notes: `trackers/partner/` → `trackers/farva/`

**Preserved:** DOC-02 line — `how partner's display name is resolved (placeholder "Partner" — overridable)` — intentionally kept per D-10 (this wording is now historically accurate).

### .planning/ROADMAP.md

No edits needed. Phase 2 success criterion 2 already read `trackers/farva/progress.md` (from Phase 2 D-01 planner work). Phase 3 success criteria already used "Farva" throughout. Line 88 plan-description bullet preserved as-is (it documents the purpose of this plan, not stale terminology).

## Post-Edit Grep Verification

| Check | Result |
|-------|--------|
| `grep -v "...historical exceptions..." PROJECT.md \| grep -c "Partner"` | 0 |
| `grep -c "Partner" ROADMAP.md` (line 88 plan description only) | 1 (expected) |
| `grep -c "partner/" PROJECT.md` | 0 |
| Farva/farva count in PROJECT.md | 11 |
| Farva/farva count in REQUIREMENTS.md | 4 |
| `grep -c "stores both" PROJECT.md` | 1 |
| Frozen phases/01, /02, /03 modified | 0 (confirmed untouched) |

## Deviations from Plan

None — plan executed exactly as written.

Note: The plan objective listed ROADMAP.md as a target file, but post-baseline grep confirmed its Phase 1/2/5 success criteria already used "Farva" from earlier planner work. No edit was needed. This is consistent with the plan's own instruction: "Check if this already says farva or still says partner."

## Known Stubs

None. All references to Farva in the edited files are wired to actual directory paths and content.

## Threat Flags

None. Pure markdown edits; no new network endpoints, auth paths, or schema changes introduced.

## Self-Check: PASSED

- [x] .planning/PROJECT.md exists and contains "farva/" (not "partner/")
- [x] .planning/REQUIREMENTS.md exists and TRK-02 reads "trackers/farva/"
- [x] Commit d156f87 exists in git log
- [x] Frozen phases/01-03 show no modifications
