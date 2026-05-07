# Requirements

Source-of-truth list of v1 requirements. Each requirement is atomic, testable, and user-centric. Phase mapping lives in `ROADMAP.md`; traceability table is at the bottom of this file.

## v1 Requirements

### Library — migrate the existing knowledge base

- [ ] **LIB-01**: User can browse a structured `library/` directory containing all durable nutrition knowledge (goals, daily structure, meals, recipes, portions, cooking rules, preferences, training nutrition, calorie targets, macro templates, fast-food rules) — migrated from the 15 root `*.txt` files into individually-named `.md` files.
- [ ] **LIB-02**: User can find weekly/repeatable templates (weekly meal plan, weekly tracker, meal-prep planner, shopping list) under a `templates/` directory.
- [ ] **LIB-03**: Original `*.txt` files are archived (moved to `archive/legacy-txt/`) — not deleted — so original wording stays auditable.
- [ ] **LIB-04**: User can read a `library/README.md` that explains the structure of `library/` and `templates/` and how they relate to trackers and slash commands.

### Calendar — cycling load drives daily targets

- [x] **CAL-01**: User can read a single-source-of-truth `calendar/cycling-2026.md` containing the standard weekly pattern AND the Sunday long-ride progression through 2026-08-09. _(Phase 01-03)_
- [ ] **CAL-02**: System (via slash commands) can resolve "today's cycling row" from `cycling-2026.md` and use it to set Jonas's daily kcal target.

### Trackers — per-person scaffolding & baselines

- [ ] **TRK-01**: User can find a `trackers/jonas/` directory with subfolders `daily/`, `weekly/`, plus a `progress.md` file seeded with starting weight (87.9 kg), targets (85 kg by 2026-05-30, then 80 kg ASAP), and the goal-event (Heathland 161 km, 2026-08-03/09).
- [ ] **TRK-02**: User can find a `trackers/partner/` directory with the same shape, seeded with starting weight (58 kg) and target (53 kg ASAP).
- [ ] **TRK-03**: User can find a daily-log template (`templates/daily-log.md`) used by both trackers — captures meals, weight, training, energy/hunger notes, and free-text comments.
- [ ] **TRK-04**: User can find a weekly-summary template (`templates/weekly-summary.md`) — captures 7-day weight average, adherence %, training totals, kcal/macro adjustment proposal.

### Commands — daily/weekly operating loop

- [ ] **CMD-01**: User can run `/prep-today` and get a clear cooking/portioning brief for today (what to cook, what to thaw, portions for Jonas vs Partner, leftover utilization), based on this week's plan and library portion guidelines.
- [ ] **CMD-02**: User can run `/log-day` and have today's daily-log file created/updated for Jonas and Partner — with meals, weight, training (auto-suggested from cycling calendar), and free-text notes.
- [x] **CMD-03**: User can run `/weekly-plan` and get a generated meal plan for the upcoming week, drawn from `library/meals.md` + `library/recipes.md`, respecting the 4-portion meal-prep convention and the cycling calendar's load profile.
- [x] **CMD-04**: User can run `/shopping-list` and get a derived weekly shopping list for the active weekly plan, normalized against the pantry baseline in `templates/shopping-list.md`.
- [ ] **CMD-05**: User can run `/weekly-review` for either person (or both) and receive: 7-day average weight, weight-trend vs targets, adherence summary, training summary, and a concrete kcal/macro adjustment proposal grounded in the established adjustment rules (>0.8 kg/wk = add; <0.3 kg/wk × 2 = reduce).
- [ ] **CMD-06**: User can run `/swap-meal` mid-day and get an alternative meal from `library/meals.md` that fits the remaining macros for that person.

### Docs — onboarding & operating notes

- [x] **DOC-01**: User can read a top-level `README.md` that explains the system, the daily/weekly loop, where things live, and how to log on the go (Claude-mobile-as-buffer pattern).
- [ ] **DOC-02**: User can read a `docs/conventions.md` describing file-naming (e.g. `daily/2026-05-05.md`, `weekly/2026-W19.md`), date format, and how partner's display name is resolved (placeholder "Partner" — overridable).

## v2 Requirements (deferred, not v1)

- [ ] Mobile sync (Obsidian / iCloud / iA Writer) — instead of chat-with-Claude buffer
- [ ] Body-measurement tracking (waist, photos) in addition to weight
- [ ] Auto-import of training data from Strava / Garmin
- [ ] Per-recipe pre-computed kcal/macros (replacing reliance on external app)
- [ ] Recipe scaling beyond 2-person/4-portion convention

## Out of Scope (v1 — won't build)

- Custom web/mobile/CLI app — markdown-only by deliberate decision.
- Foods/ingredients calorie database — external app (MFP / Cronometer) owns this.
- Photo-based meal logging.
- Fitness API integrations.
- Multi-household / sharing-with-others features — system is for two specific people.

## Traceability

| REQ-ID  | Phase   | Notes |
|---------|---------|-------|
| LIB-01  | Phase 1 | Migrate 15 txt files → library/*.md |
| LIB-02  | Phase 1 | Four templates under templates/ |
| LIB-03  | Phase 1 | Archive originals to archive/legacy-txt/ |
| LIB-04  | Phase 1 | library/README.md explaining structure |
| CAL-01  | Phase 1 | calendar/cycling-2026.md single source of truth |
| CAL-02  | Phase 2 | Calendar date resolution used by slash commands |
| TRK-01  | Phase 2 | trackers/jonas/ with seeded progress.md |
| TRK-02  | Phase 2 | trackers/partner/ with seeded progress.md |
| TRK-03  | Phase 2 | templates/daily-log.md |
| TRK-04  | Phase 2 | templates/weekly-summary.md |
| CMD-01  | Phase 3 | /prep-today command |
| CMD-02  | Phase 3 | /log-day command |
| CMD-03  | Phase 3 | /weekly-plan command |
| CMD-04  | Phase 3 | /shopping-list command |
| CMD-05  | Phase 3 | /weekly-review command |
| CMD-06  | Phase 3 | /swap-meal command |
| DOC-01  | Phase 4 | Top-level README.md |
| DOC-02  | Phase 4 | docs/conventions.md |
