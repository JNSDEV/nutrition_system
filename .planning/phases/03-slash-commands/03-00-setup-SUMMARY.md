---
phase: 03-slash-commands
plan: "00"
subsystem: slash-commands-bootstrap
tags: [commands, conventions, readme, D-22]
dependency_graph:
  requires: []
  provides: [".claude/commands/README.md"]
  affects: ["03-01", "03-02", "03-03", "03-04", "03-05", "03-06"]
tech_stack:
  added: []
  patterns: ["markdown-only", "Claude Code slash command frontmatter convention"]
key_files:
  created:
    - .claude/commands/README.md
  modified: []
decisions:
  - "D-22 resolved: weekly_kcal_adjustments additive list in progress.md frontmatter (not overwriting target_weight_kg or target_date)"
  - "argument-hint always left empty per conversational-args principle (D-02)"
metrics:
  duration: "~10 minutes"
  completed: 2026-05-06
  tasks_completed: 1
  tasks_total: 1
  files_created: 1
  files_modified: 0
---

# Phase 3 Plan 00: Setup Summary

**One-liner:** Bootstrap `.claude/commands/` directory with a README documenting all 10 cross-cutting conventions (D-01..D-06, CAL-02, D-22, ROADMAP note, empty-state matrix) so all 6 command files can be authored uniformly.

---

## What Was Built

Created the `.claude/commands/` directory (did not exist previously — Phase 3 creates it per D-01) and wrote `.claude/commands/README.md` as a unified reference for all command authors.

The README covers 10 sections:

1. **File-shape convention (D-01)** — Claude Code frontmatter format (`description`, `argument-hint`) + prompt body
2. **Conversational-args principle (D-02)** — no positional args, defaults to today + both people
3. **Write-vs-propose-vs-chat matrix (D-03)** — per-command behavior contract
4. **Library-anchor resolution (D-04)** — `library:meals#{anchor}` lookup procedure, ambiguity and miss handling
5. **Date semantics (D-05)** — file path patterns for daily/weekly/plans/shopping, ISO week format
6. **Person identifiers (D-06)** — `jonas`/`farva` directory tokens, `Jonas`/`Farva` display names
7. **CAL-02 contract** — mandatory read sequence for any command touching kcal targets
8. **D-22 decision** — `weekly_kcal_adjustments` additive list schema, adjustment rules, effective-target computation
9. **ROADMAP display-name note** — "Partner" in ROADMAP.md is a historical placeholder; Phase 4 will fix it
10. **Empty-state behavior** — per-command behavior when preconditions are missing

---

## Files Created

| File | Purpose |
|------|---------|
| `.claude/commands/README.md` | Convention reference for all 6 command files (03-01..03-06) |

---

## Commits

| Hash | Message |
|------|---------|
| f1da772 | feat(03-00): create .claude/commands/ and write shared conventions README |

---

## Deviations from Plan

None — plan executed exactly as written.

---

## Known Stubs

None. This plan is documentation-only; no data stubs exist.

---

## Threat Flags

None. This plan creates markdown documentation only; no network endpoints, auth paths, file access patterns, or schema changes at trust boundaries.

---

## Self-Check: PASSED

- [x] `.claude/commands/README.md` exists
- [x] Contains all 10 convention sections
- [x] Contains `argument-hint` (Section 1 and 2)
- [x] Contains `D-22` and `weekly_kcal_adjustments` (Section 8)
- [x] Contains `farva` (Section 6 and throughout)
- [x] Commit f1da772 exists in git log
