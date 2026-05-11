# Roadmap: Nutrition System

## Current Milestone

### v1.1 — Hybrid Mobile App

**Goal:** Both Jonas and Farva can run all 6 slash commands from a Flutter app on their own phone, with reads/writes flowing through Supabase to a shared GitHub repo. Quality stays at Claude Sonnet/Opus level. Personal use only (TestFlight + Android internal).

**Stack:** Flutter (Unlockd CLI scaffold) · Supabase (auth + 2 Edge Functions) · GitHub-as-backend · Anthropic API via backend proxy.

## Phases

**Phase Numbering:**
- Integer phases (5, 6, 7, …): planned milestone work
- Decimal phases (5.1, etc.): urgent insertions (marked INSERTED)

- [ ] **Phase 5: Backend Foundation** — Supabase project, auth, Anthropic + GitHub Edge Functions
- [ ] **Phase 6: Flutter App Scaffold + Auth** — Unlockd CLI scaffold, sign-in flow, sign-out
- [ ] **Phase 7: Chat UI + Slash Command Picker** — Single chat screen, markdown rendering, command picker
- [ ] **Phase 8: /log-day End-to-End (MVP Slice)** — First command wired through entire stack; de-risks architecture
- [ ] **Phase 9: Remaining Commands + Multi-Profile** — Wire 5 remaining commands + Farva write restrictions
- [ ] **Phase 10: TestFlight + Android Distribution** — Build, distribute, smoke-test on both phones

## Phase Details

### Phase 5: Backend Foundation
**Goal**: Supabase project with auth and the 2 Edge Functions (`proxy-anthropic`, `github-fs`) the app will depend on, plus the `profiles` table.
**Depends on**: Nothing (new milestone start)
**Requirements**: BE-01, BE-02, BE-03, BE-04
**Success Criteria** (what must be TRUE):
  1. Supabase project is provisioned; 2 user accounts (Jonas, Farva) exist and can sign in via email
  2. `proxy-anthropic` Edge Function returns a successful response when called with a valid JWT and a small test prompt; Anthropic key is never exposed to the client
  3. `github-fs` Edge Function can `read` an existing file, `list` a directory, and `write` a new file in the shared `nutrition_system` repo with a commit attributed to the authenticated user; GitHub PAT is never exposed to the client
  4. `profiles` table is auto-populated on first sign-in; row contains `display_name`, `tracker_dir`, `is_owner`
**Plans**: 6 plans
- [x] 05-01-repo-bootstrap-PLAN.md — backend/ skeleton, Supabase CLI link
- [x] 05-02-schema-migrations-PLAN.md — profiles + api_usage migrations + trigger
- [x] 05-03-user-seeding-PLAN.md — Jonas + Farva accounts seeded; profiles trigger verified
- [ ] 05-04-proxy-anthropic-PLAN.md — Anthropic proxy Edge Function with cost cap
- [ ] 05-05-github-fs-PLAN.md — GitHub FS Edge Function (read/list/write with retry)
- [ ] 05-06-health-deploy-e2e-PLAN.md — health function + full E2E cloud verification

### Phase 6: Flutter App Scaffold + Auth
**Goal**: Flutter app runs on iOS + Android with sign-in, sign-out, and a placeholder Chat screen.
**Depends on**: Phase 5
**Requirements**: APP-01, APP-02, APP-03
**Success Criteria** (what must be TRUE):
  1. App built via Unlockd CLI scaffold launches on iOS simulator and Android emulator
  2. Sign-in screen accepts email/password (or magic link) and creates a session via Supabase
  3. Session persists across app restarts via secure storage; token auto-refresh works
  4. Settings screen exposes sign-out; user can switch accounts
**Plans**: TBD

### Phase 7: Chat UI + Slash Command Picker
**Goal**: Functional chat UI with markdown rendering and a `/`-picker for the 6 commands. No backend command logic yet — picker just sends raw text.
**Depends on**: Phase 6
**Requirements**: APP-04, APP-05
**Success Criteria** (what must be TRUE):
  1. Chat screen renders user messages and assistant messages in a scrollable list
  2. Input field with `/`-trigger shows a picker of the 6 commands; selection inserts text
  3. Markdown in assistant replies is rendered (tables, headings, bullets, code blocks)
  4. Sending a message hits `proxy-anthropic` directly (no command dispatcher yet) and shows the reply — proves the stack end-to-end as a basic chat
**Plans**: TBD

### Phase 8: /log-day End-to-End (MVP Slice)
**Goal**: First slash command wired through the entire stack — backend command dispatcher reads source files, composes the v1.0 prompt, calls Anthropic, writes daily-log files via `github-fs`. Smart-merge preserved.
**Depends on**: Phase 7
**Requirements**: CMD-MOB-01
**Success Criteria** (what must be TRUE):
  1. Backend command-dispatch Edge Function exists and accepts a command name + chat context
  2. Running `/log-day` from the app produces or updates `trackers/jonas/daily/YYYY-MM-DD.md` AND `trackers/farva/daily/YYYY-MM-DD.md` as a single commit in the shared repo
  3. Smart-merge from v1.0 D-12 works: re-running `/log-day` the same day appends to Meals, overwrites scalar frontmatter, recomputes estimates
  4. MFP/Cronometer paste parsing (v1.0 D-11) works in the mobile chat
**Plans**: TBD

### Phase 9: Remaining Commands + Multi-Profile
**Goal**: All 5 remaining commands work end-to-end. Farva can only write under `trackers/farva/`.
**Depends on**: Phase 8
**Requirements**: CMD-MOB-02, CMD-MOB-03, CMD-MOB-04, CMD-MOB-05, CMD-MOB-06, MP-01, MP-02, MP-03
**Success Criteria** (what must be TRUE):
  1. `/prep-today`, `/swap-meal` work as chat-only (no file write)
  2. `/weekly-plan` proposes-then-writes `trackers/weekly-plans/YYYY-Www.md` after user confirm; amend-or-replace guard works
  3. `/shopping-list` proposes-then-writes `trackers/weekly-plans/YYYY-Www-shopping.md`
  4. `/weekly-review` writes weekly files for both people (or just the signed-in user if Farva); optional `weekly_kcal_adjustments` append works
  5. When Farva is signed in, the dispatcher rejects writes to paths outside `trackers/farva/` with a clear error
  6. When Jonas is signed in, all write paths succeed
**Plans**: TBD

### Phase 10: TestFlight + Android Distribution
**Goal**: Both users have the app installed on their own phone and complete the full daily loop on live infrastructure.
**Depends on**: Phase 9
**Requirements**: DIST-01, DIST-02, DIST-03
**Success Criteria** (what must be TRUE):
  1. iOS build is on TestFlight; Jonas + Farva are added as testers and can install
  2. Android build is distributed (Play internal track or direct APK) and installable on both Android phones (if either user runs Android)
  3. On each user's phone, the full daily loop runs: sign in → `/prep-today` (or chat-only command) → `/log-day` → verify the commit lands in the GitHub repo
  4. No P0 bugs blocking the daily loop; minor issues logged in `.planning/` for v1.2 candidates
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 5 → 6 → 7 → 8 → 9 → 10

| Phase | Plans | Status | Completed |
|-------|-------|--------|-----------|
| 5. Backend Foundation | 0/TBD | Not started | - |
| 6. Flutter Scaffold + Auth | 0/TBD | Not started | - |
| 7. Chat UI | 0/TBD | Not started | - |
| 8. /log-day MVP slice | 0/TBD | Not started | - |
| 9. Remaining Commands + Multi-Profile | 0/TBD | Not started | - |
| 10. TestFlight + Android | 0/TBD | Not started | - |

## Shipped Milestones

<details>
<summary><strong>v1.0 — MVP (shipped 2026-05-08)</strong></summary>

5 phases (1, 2, 3, 4, 4.1-INSERTED), 28 plans, 18 v1 requirements delivered. Markdown-only system: durable library, per-person trackers, 6 slash commands, onboarding docs, plus an audit-driven closure phase that wired the library anchors and CAL-02 mapping.

→ `.planning/milestones/v1.0-ROADMAP.md`
→ `.planning/milestones/v1.0-REQUIREMENTS.md`

</details>
