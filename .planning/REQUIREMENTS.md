# Requirements — v1.1 (Hybrid Mobile App)

Source-of-truth requirements for v1.1. Each requirement is atomic, testable, user-centric. Phase mapping lives in `ROADMAP.md`; traceability table is at the bottom.

**Milestone goal:** Both Jonas and Farva can run all 6 v1.0 slash commands from a Flutter app on their own phone (iOS + Android), with reads/writes flowing through a Supabase-mediated backend to a shared GitHub repo. Quality stays at Claude Sonnet/Opus level (Anthropic API proxied through backend). Personal use only — TestFlight + Android internal distribution, no App Store submission.

## v1.1 Requirements

### Backend — Supabase as the API + auth + GitHub gateway

- [ ] **BE-01**: A Supabase project exists with `auth.users` enabled (email/password or magic link), seeded with 2 accounts: Jonas and Farva.
- [ ] **BE-02**: A Supabase Edge Function `proxy-anthropic` accepts an authenticated request, forwards the body to `api.anthropic.com/v1/messages` using a server-held Anthropic key, and returns the response. App never sees the key.
- [ ] **BE-03**: A Supabase Edge Function `github-fs` exposes 3 verbs (`read`, `write`, `list`) for paths in the shared `nutrition_system` GitHub repo. Reads return file contents; writes create commits on `main` with the authenticated user's name in the commit author. The GitHub PAT is server-held.
- [ ] **BE-04**: User profile table `profiles` (linked to `auth.users`) stores `display_name` (`Jonas` / `Farva`), `tracker_dir` (`jonas` / `farva`), `is_owner` (true for Jonas, false for Farva). Profile is created automatically on first sign-in.

### Flutter app — chat-first UI

- [ ] **APP-01**: A Flutter app scaffolded via the Unlockd CLI runs on iOS and Android. Bottom-nav has one screen: Chat. Settings is a top-right icon.
- [ ] **APP-02**: User can sign in with email + password (or magic link) against the Supabase project. Session persists via secure storage; auto-refresh handles token expiry.
- [ ] **APP-03**: User can sign out and switch accounts from Settings.
- [ ] **APP-04**: Chat screen renders a message list, an input field with a "/" picker for the 6 commands, and a send button. Markdown is rendered in assistant replies (tables, headings, code blocks).
- [ ] **APP-05**: User can tap a "/" in the input and pick from a list of the 6 slash commands; selection inserts the command text and submits when send is tapped.

### Command pipeline — backend orchestration of slash commands

- [ ] **CMD-MOB-01**: When user sends `/log-day` in chat, the app calls a backend command-dispatch Edge Function. The function reads the required source files via `github-fs` (templates, library, today's daily-log if it exists), composes the v1.0 `/log-day` prompt body, sends it to `proxy-anthropic`, and either (a) writes the resulting daily-log files for both people via `github-fs` (single commit, two files), or (b) returns the model's clarifying question to the user to continue the conversation. Smart-merge from v1.0 D-12 is preserved.
- [ ] **CMD-MOB-02**: `/prep-today` works end-to-end: reads weekly plan + cycling calendar + cooking-rules + portions, returns the 4-section brief in chat. No file write. Honors the no-active-plan guard from v1.0 D-09.
- [ ] **CMD-MOB-03**: `/weekly-plan` works end-to-end: reads library/meals.md anchors + calendar + macro-templates + progress.md (protein floor), runs the conversational 4-question opener, iterates on the proposal, and writes `trackers/weekly-plans/YYYY-Www.md` via `github-fs` on user confirm. Amend-or-replace guard from v1.0 D-17 preserved.
- [ ] **CMD-MOB-04**: `/shopping-list` works end-to-end: reads the active weekly plan, walks recipes, aggregates against pantry baseline, writes `trackers/weekly-plans/YYYY-Www-shopping.md` on confirm.
- [ ] **CMD-MOB-05**: `/weekly-review` works end-to-end: reads the most-recently-completed ISO week's daily logs + cycling rows + calorie-targets, computes weight mean/trend, adherence, training totals, adjustment proposal. Writes `trackers/{person}/weekly/YYYY-Www.md` for both. Optionally appends `weekly_kcal_adjustments` to `progress.md` on user confirm (v1.0 D-22 schema preserved).
- [ ] **CMD-MOB-06**: `/swap-meal` works end-to-end: reads today's daily log + cal-02-contract + meals.md, returns 1-3 alternatives that fit remaining macros. No file write (v1.0 D-24).

### Multi-profile — Farva writes only her own data

- [ ] **MP-01**: When Farva is signed in, the command dispatcher restricts file writes to paths under `trackers/farva/`. Attempts to write `trackers/jonas/` or shared paths (`library/`, `calendar/`, `templates/`, `trackers/weekly-plans/`) are rejected by the backend with a clear error message.
- [ ] **MP-02**: When Farva runs `/log-day`, only her file is written (skip Jonas's). When she runs `/weekly-review`, only her weekly file is written.
- [ ] **MP-03**: When Jonas is signed in, full write access to all paths. He can run `/log-day` and write for both people; `/weekly-review` writes for both.

### Distribution — TestFlight + Android internal

- [ ] **DIST-01**: iOS build is signed and uploaded to TestFlight; Jonas + Farva are added as internal testers.
- [ ] **DIST-02**: Android build is generated (release signed APK or AAB) and shared via Play Console internal testing track OR direct sideload, depending on what's simpler for personal use.
- [ ] **DIST-03**: Both users can install the build on their own phone and complete the full daily loop (sign in → `/prep-today` → `/log-day` → success) on the live Supabase backend.

## v1.2 Requirements (deferred from v1.1)

- [ ] Push notifications (daily prep + weekly review reminders)
- [ ] Offline cache for last-7-days reads
- [ ] Photo-log OCR fallback for MFP/Cronometer screenshots
- [ ] Speech-to-text input for `/log-day`
- [ ] App Store / Play Store submission (currently personal-only)

Plus carried over from v1.0:
- [ ] Body-measurement tracking (waist, photos)
- [ ] Auto-import of training data from Strava / Garmin
- [ ] Per-recipe pre-computed kcal/macros
- [ ] Recipe scaling beyond 4-portion convention

## Out of Scope (v1.1 — won't build)

- App Store submission (personal-only this milestone).
- Onboarding screens beyond a single sign-in. Both users get the build pre-configured.
- Custom calorie/macro database — Anthropic + library/cal-02-contract chain stays authoritative.
- Real-time multi-device sync conflict UI — assume one person writes at a time; let GitHub be the conflict layer (rare with 2 users).
- Push notifications, offline cache, photo OCR (all v1.2 per scope ceiling).

## Traceability

| REQ-ID  | Phase | Notes |
|---------|-------|-------|
| BE-01   | Phase 5 | Supabase project + auth + 2 seeded accounts |
| BE-02   | Phase 5 | Anthropic API proxy Edge Function |
| BE-03   | Phase 5 | GitHub FS Edge Function |
| BE-04   | Phase 5 | profiles table linked to auth.users |
| APP-01  | Phase 6 | Flutter scaffold via Unlockd CLI |
| APP-02  | Phase 6 | Supabase auth flow in app |
| APP-03  | Phase 6 | Sign out / switch account |
| APP-04  | Phase 7 | Chat screen with markdown rendering |
| APP-05  | Phase 7 | Slash command picker |
| CMD-MOB-01 | Phase 8 | /log-day E2E (vertical MVP slice) |
| CMD-MOB-02..06 | Phase 9 | Remaining 5 commands wired |
| MP-01..03 | Phase 9 | Multi-profile write restrictions |
| DIST-01..03 | Phase 10 | TestFlight + Android + smoke test on both phones |
