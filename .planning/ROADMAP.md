# Roadmap: Nutrition System

## Overview

Four phases turn 15 existing `.txt` knowledge files into a fully operational markdown-first nutrition system for two people. Phase 1 migrates and structures the durable knowledge base. Phase 2 scaffolds per-person trackers and wires the cycling calendar into daily target resolution. Phase 3 implements all 6 slash commands that drive the daily/weekly operating loop. Phase 4 documents the system so both users can rely on it without re-explaining it to Claude each session.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation** - Migrate library, structure templates, archive originals, establish cycling calendar
- [x] **Phase 2: Trackers & Baselines** - Scaffold per-person trackers with seeded baselines, enable calendar-driven daily target resolution
- [x] **Phase 3: Slash Commands** - Implement all 6 operating-loop commands (completed 2026-05-06)
- [ ] **Phase 4: Onboarding & Docs** - README and conventions doc so the system is self-explaining

## Phase Details

### Phase 1: Foundation
**Goal**: The durable knowledge base is structured, browsable, and ready for slash commands to read from
**Depends on**: Nothing (first phase)
**Requirements**: LIB-01, LIB-02, LIB-03, LIB-04, CAL-01
**Success Criteria** (what must be TRUE):
  1. User can open `library/` and find 11 named `.md` files covering goals, meals, recipes, portions, cooking rules, preferences, training nutrition, calorie targets, macro templates, daily structure, and fast-food rules
  2. User can open `templates/` and find the four weekly/repeatable templates (weekly-plan, weekly-tracker, meal-prep-planner, shopping-list)
  3. User can open `archive/legacy-txt/` and confirm all 15 original `.txt` files are present and unmodified
  4. User can read `library/README.md` and understand how library, templates, and trackers relate to each other and to the slash commands
  5. User can open `calendar/cycling-2026.md` and read the standard weekly session pattern plus the full Sunday long-ride progression through 2026-08-09
**Plans**: 5 plans
- [ ] 01-01-library-migration-PLAN.md — Migrate 11 root .txt files into library/*.md with locked frontmatter
- [ ] 01-02-templates-migration-PLAN.md — Migrate 4 template-shaped .txt files into templates/*.md
- [ ] 01-03-calendar-PLAN.md — Create calendar/cycling-2026.md with two locked tables from PROJECT.md
- [x] 01-04-library-readme-PLAN.md — Write library/README.md indexing all 15 migrated files + loop primer
- [ ] 01-05-archive-originals-PLAN.md — Move 15 originals to archive/legacy-txt/ + add archive README

### Phase 2: Trackers & Baselines
**Goal**: Per-person trackers exist with real starting data, and slash commands can resolve today's cycling row to derive Jonas's daily kcal target
**Depends on**: Phase 1
**Requirements**: TRK-01, TRK-02, TRK-03, TRK-04, CAL-02
**Success Criteria** (what must be TRUE):
  1. User can open `trackers/jonas/progress.md` and see starting weight 87.9 kg, targets (85 kg by 2026-05-30, then 80 kg), and the Heathland event (2026-08-03/09)
  2. User can open `trackers/farva/progress.md` and see starting weight 58 kg and target 53 kg (per Phase 2 D-01: directory lowercase `farva/`, supersedes earlier `partner/` placeholder)
  3. User can open `templates/daily-log.md` and find fields for meals, weight, training, energy/hunger notes, and free-text comments
  4. User can open `templates/weekly-summary.md` and find fields for 7-day weight average, adherence %, training totals, and kcal/macro adjustment proposal
  5. A slash command reading `cycling-2026.md` for today's date (2026-05-05) resolves to the correct session type and estimated kcal burn for Jonas's daily target
**Plans**: 5 plans
- [x] 02-01-trackers-jonas-PLAN.md — Seed trackers/jonas/progress.md with locked baselines + Heathland Event section, scaffold daily/ + weekly/ dirs
- [x] 02-02-trackers-farva-PLAN.md — Seed trackers/farva/progress.md with slim baseline (no event/training), scaffold daily/ + weekly/ dirs
- [x] 02-03-template-daily-log-PLAN.md — Create templates/daily-log.md (shared) with hybrid kcal/macro estimate+actual fields and meal-reference convention
- [x] 02-04-template-weekly-summary-PLAN.md — Create templates/weekly-summary.md (shared) with Weight / Adherence / Training / Adjustment-proposal sections
- [x] 02-05-cal02-contract-PLAN.md — Lock CAL-02 contract at library/cal-02-contract.md + record Farva resolution in PROJECT.md

### Phase 3: Slash Commands
**Goal**: All 6 operating-loop commands are implemented as Claude Code slash commands that read from the library and trackers, and write into the appropriate dated files
**Depends on**: Phase 2
**Requirements**: CMD-01, CMD-02, CMD-03, CMD-04, CMD-05, CMD-06
**Success Criteria** (what must be TRUE):
  1. User can run `/prep-today` and receive a cooking/portioning brief naming specific meals from this week's plan, with portions split for Jonas vs Farva and leftover utilization noted
  2. User can run `/log-day` and have today's daily-log file created (or updated) for both Jonas and Farva, with training auto-suggested from the cycling calendar
  3. User can run `/weekly-plan` and receive a 7-day meal plan drawn from `library/meals.md` and `library/recipes.md`, respecting the 4-portion convention and the current week's cycling load
  4. User can run `/shopping-list` and receive a shopping list derived from the active weekly plan, normalized against the pantry baseline
  5. User can run `/weekly-review` for Jonas or Farva and receive 7-day average weight, weight trend vs target, adherence summary, and a concrete kcal/macro adjustment grounded in the established rules
  6. User can run `/swap-meal` mid-day and receive an alternative meal from the library that fits the remaining macros for that person
**Plans**: 7 plans
- [x] 03-00-setup-PLAN.md — Create .claude/commands/ directory + README with all shared conventions (D-01..D-06, D-22 resolution)
- [x] 03-01-prep-today-PLAN.md — /prep-today command (CMD-01, D-07..D-09)
- [x] 03-02-log-day-PLAN.md — /log-day command with smart-merge and MFP paste flow (CMD-02, D-10..D-13)
- [x] 03-03-weekly-plan-PLAN.md — /weekly-plan conversational propose-then-write (CMD-03, D-14..D-17)
- [x] 03-04-shopping-list-PLAN.md — /shopping-list ingredient aggregation (CMD-04, D-18..D-19)
- [x] 03-05-weekly-review-PLAN.md — /weekly-review metrics + adjustment apply (CMD-05, D-20..D-22)
- [x] 03-06-swap-meal-PLAN.md — /swap-meal remaining-macro search (CMD-06, D-23..D-24)

### Phase 4: Onboarding & Docs
**Goal**: A first-time reader can understand the system, navigate to any file, and know how to log from a phone without any prior explanation
**Depends on**: Phase 3
**Requirements**: DOC-01, DOC-02
**Success Criteria** (what must be TRUE):
  1. User can read top-level `README.md` and understand the daily/weekly loop, where every file type lives, and how to log on the go using Claude mobile as a buffer
  2. User can read `docs/conventions.md` and find the file-naming rules (daily/YYYY-MM-DD.md, weekly/YYYY-Www.md), date format standard, and how partner's display name is resolved
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 4/5 | In progress | - |
| 2. Trackers & Baselines | 5/5 | Complete | 2026-05-06 |
| 3. Slash Commands | 7/7 | Complete   | 2026-05-06 |
| 4. Onboarding & Docs | 0/TBD | Not started | - |
