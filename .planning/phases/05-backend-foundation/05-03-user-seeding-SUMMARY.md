---
phase: 05-backend-foundation
plan: 03
subsystem: backend-auth
tags: [supabase, supabase-auth, admin-sdk, seeding, rls, typescript, ts-node]

requires:
  - "05-01: backend/ scaffold + CLI linked to cloud project hqljsvubvvfcatyonowb"
  - "05-02: profiles table + on_auth_user_created trigger + RLS applied to cloud"
provides:
  - "Idempotent admin-SDK seeding script (backend/scripts/seed-users.ts)"
  - "backend/package.json + lockfile pinning @supabase/supabase-js, ts-node, typescript, @types/node"
  - "Two seeded users in cloud auth.users: Jonas (491d7166-bce5-49a8-8171-87ee4e2ce603) and Farva (87e2d0cd-b5eb-4452-8cd2-dc392bcde2b5)"
  - "Two profiles rows auto-populated by the on_auth_user_created trigger with correct display_name, tracker_dir, and is_owner"
  - "Verified RLS: signed-in user can only read their own profiles row"
affects:
  - 05-04-edge-functions
  - 05-05-smoke-tests

tech-stack:
  added:
    - "@supabase/supabase-js@^2"
    - "ts-node@^10"
    - "typescript@^5"
    - "@types/node@^20"
  patterns:
    - "Idempotency via listUsers() → find(email) instead of ON CONFLICT (admin SDK has no upsert-user primitive)"
    - "email_confirm:true on admin createUser to bypass confirmation email for seeded accounts"
    - "user_metadata.{display_name,tracker_dir} consumed by the on_auth_user_created trigger from 05-02"
    - "Secrets stay in backend/.env (gitignored); script reads from process.env at runtime"

key-files:
  created:
    - backend/scripts/seed-users.ts
    - backend/package.json
    - backend/package-lock.json
  modified: []

key-decisions:
  - "Seed against the cloud project (hqljsvubvvfcatyonowb), not a local Supabase stack — Docker is not running on this workstation, matching the 05-02 fallback. The cloud project is the source of truth for this single-developer system."
  - "Verification done via Supabase JS client (service-role for ground truth, anon + signed-in JWT for RLS), not psql — DATABASE_URL is intentionally empty in backend/.env and the local Postgres URL from supabase status doesn't exist (no local stack)."
  - "Idempotency check uses auth.admin.listUsers() because admin.getUserByEmail() is not present in all SDK 2.x minor versions; listUsers + find by email is portable across the v2 line."

patterns-established:
  - "Cloud-only verification fallback: JS client (admin SDK + anon-with-JWT) substitutes for the plan's psql/local-stack checks; same pattern used in 05-02"
  - "Two-pass run for idempotency proof: first run shows [OK] Created, second run shows [SKIP] already exists"
  - "RLS proof requires two queries from the same client: SELECT * (returns own row only) and SELECT * WHERE id=<other-user> (returns 0 rows). Both must hold to demonstrate RLS isn't accidentally returning all rows."

requirements-completed: [BE-01, BE-04]

duration: ~5 min executor wall-clock
completed: 2026-05-11
---

# Phase 05 Plan 03: User Seeding Summary

**Idempotent TypeScript admin-SDK script (`backend/scripts/seed-users.ts`) seeded Jonas and Farva into the cloud `auth.users` table; the `on_auth_user_created` trigger from 05-02 auto-populated `public.profiles` with correct `display_name`/`tracker_dir`/`is_owner`; RLS verified to block cross-user reads.**

## Performance

- **Duration:** ~5 min executor wall-clock (Task 1 commit → checkpoint return; +~30s on resume for SUMMARY)
- **Started:** 2026-05-11T08:56:48Z
- **Completed:** 2026-05-11T09:01:26Z (pre-SUMMARY); SUMMARY commit immediately after
- **Tasks:** 3 (2 executed + 1 human-verify checkpoint, confirmed by user)
- **Files created:** 3 (committed) + 0 modified

## Accomplishments

- `backend/scripts/seed-users.ts` written: idempotent admin-SDK seeder using `auth.admin.listUsers()` for existence check, `auth.admin.createUser()` with `email_confirm:true` and `user_metadata` consumed by the 05-02 trigger.
- `backend/package.json` + `package-lock.json` committed; `npm install` clean (29 packages, 0 vulnerabilities).
- Two users created in cloud project `hqljsvubvvfcatyonowb`:
  - Jonas — `491d7166-bce5-49a8-8171-87ee4e2ce603` — `jonas@nutrition-system.local`
  - Farva — `87e2d0cd-b5eb-4452-8cd2-dc392bcde2b5` — `farva@nutrition-system.local`
- `on_auth_user_created` trigger from 05-02 fired correctly: 2 rows in `public.profiles` with exact expected values (Jonas: `tracker_dir=jonas`, `is_owner=true`; Farva: `tracker_dir=farva`, `is_owner=false`).
- Idempotency proven: re-running the script logs `[SKIP] … already exists` for both users and exits 0.
- RLS proven in both directions:
  - Jonas signed in → `SELECT * FROM profiles` returns exactly 1 row (his own).
  - Jonas signed in → `SELECT * FROM profiles WHERE id=<Farva's id>` returns 0 rows.
- Both users successfully sign in via email + password against the cloud Auth endpoint.
- User confirmed the cloud Supabase Dashboard checks (Authentication → Users; Table Editor → profiles; RLS lock icon) during the human-verify checkpoint.

## Task Commits

Each task was committed atomically per the plan's task boundaries:

1. **Task 1: Write seed-users.ts and package.json** — `384a216` (feat)
2. **Task 2: Run seed against cloud + verify trigger + RLS** — no commit (run-and-verify task with no repo artifacts; mutates cloud `auth.users` + `profiles` only)
3. **Task 3: human-verify checkpoint — confirm in Supabase Studio** — confirmed by user ("verified"); no commit

**Plan metadata:** added by the SUMMARY commit immediately following this file (`docs(05-03): summary of user-seeding`).

## Files Created/Modified

- `backend/scripts/seed-users.ts` — idempotent admin-SDK seed script for Jonas + Farva. Reads `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `JONAS_PASSWORD`, `FARVA_PASSWORD` from `process.env`. Existence check via `auth.admin.listUsers()`; creation via `auth.admin.createUser({ email_confirm:true, user_metadata })`.
- `backend/package.json` — dependencies (`@supabase/supabase-js@^2`) + devDeps (`ts-node@^10`, `typescript@^5`, `@types/node@^20`); `seed` npm script.
- `backend/package-lock.json` — npm lockfile pinning 29 transitive packages.

Local-only (gitignored, NOT committed):

- `backend/.env` — populated with `JONAS_PASSWORD` and `FARVA_PASSWORD` (along with the pre-existing `SUPABASE_*` keys from 05-01). Gitignore confirmed via `git check-ignore -v backend/.env` → `backend/.gitignore:1:.env`.
- `backend/node_modules/` — gitignored from 05-01.

## Decisions Made

- **Cloud-only seeding and verification.** Same rationale as 05-02: Docker is not running on this workstation, and the cloud project (`hqljsvubvvfcatyonowb`, West EU) is the source of truth for this single-developer system. The plan's local-stack steps (Task 2's `supabase status` + `psql "$LOCAL_DATABASE_URL"`) were substituted with cloud + JS-client verification. See deviation 1 below.
- **JS-client verification (not psql).** `DATABASE_URL` is intentionally empty in `backend/.env`. Verification used a transient `verify-seed.mjs` (run, inspected output, deleted — never staged) that wraps `auth.admin.listUsers()`, service-role `from('profiles').select('*')`, and an anon-client `signInWithPassword` for the RLS proof. This is strictly stronger than psql because it exercises the same Auth path the Flutter app will use.
- **Idempotency via listUsers + find.** The Supabase admin SDK does not expose `getUserByEmail()` on all v2 minor versions. `listUsers()` + `users.find(u => u.email === spec.email)` is portable. Acceptable performance for a 2-user seed; if the user table grows, paginate.
- **No hardcoded UUIDs in the script.** Created user IDs are read from the `createUser` response (and logged) — the trigger reads `NEW.id` from `auth.users`, so the script does not need to know them in advance.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 — Blocking] Local Supabase stack does not exist; seeded and verified against cloud instead.**

- **Found during:** Task 2 (the plan's local-stack run + psql verification step).
- **Issue:** The plan's Task 2 prescribes `supabase status` + `npx ts-node scripts/seed-users.ts` with local URL/keys, followed by `psql "$LOCAL_DATABASE_URL" -c "select ... from public.profiles"`. None of that environment exists on this workstation — Docker Desktop is not running (same as 05-02), so there is no local Supabase stack, no local Postgres container, and no `LOCAL_DATABASE_URL`. The plan-checker in earlier phases authorized this fallback (see 05-02 SUMMARY's matching deviation), and the executor prompt's `<starting_state>` and `<verify_substitution>` explicitly direct this substitution.
- **Fix:** Ran the seed script against the cloud project directly (`backend/.env` already points at `https://hqljsvubvvfcatyonowb.supabase.co` with the cloud service-role key). Verified results via a transient one-off `verify-seed.mjs` (never committed, deleted after use) that performs:
  1. `auth.admin.listUsers()` → counts and IDs.
  2. Service-role `from('profiles').select('*')` → ground-truth rows.
  3. anon `signInWithPassword({jonas})` → JWT.
  4. Authorized `from('profiles').select('*')` → expect 1 row (own).
  5. Authorized `from('profiles').select('*').eq('id', farvaId)` → expect 0 rows.
  6. anon `signInWithPassword({farva})` → both users can sign in.
- **Files modified:** None (script is unchanged from the plan spec; the substitution affects only the run environment and verification method).
- **Verification:** All six JS checks passed. Output transcript was shown to the user at the human-verify checkpoint; user then confirmed the cloud Supabase Dashboard visually (Authentication → Users showed 2 users; Table Editor → profiles showed 2 rows with correct columns; RLS lock icon visible). Verifier reply: "verified".
- **Committed in:** N/A — environment substitution, not a code change. Documented here per the deviation rules.

---

**Total deviations:** 1 (environment fallback; documented and authorized by the executor prompt — not a code deviation; identical pattern to 05-02).
**Impact on plan:** None on scope, schema, or script behavior. The seed script in git is exactly what the plan specifies and is fully usable against any future local stack the user spins up (idempotency will see the cloud users as absent locally and seed them). The only impact is which Supabase environment was targeted during this session.

## Verification Performed

Verified against linked cloud project `hqljsvubvvfcatyonowb` (West EU, Ireland) via JS client:

| Check | Expected | Actual |
|-------|----------|--------|
| `auth.users` count (admin.listUsers) | 2 | 2 |
| Jonas in auth.users | id=491d7166-bce5-49a8-8171-87ee4e2ce603 | match |
| Farva in auth.users | id=87e2d0cd-b5eb-4452-8cd2-dc392bcde2b5 | match |
| `profiles` count (service-role select) | 2 | 2 |
| Jonas profile | display_name='Jonas', tracker_dir='jonas', is_owner=true | match |
| Farva profile | display_name='Farva', tracker_dir='farva', is_owner=false | match |
| Idempotency re-run | both [SKIP] | both [SKIP], exit 0 |
| RLS — Jonas signed in, SELECT * | 1 row (own) | 1 row |
| RLS — Jonas signed in, WHERE id=Farva.id | 0 rows | 0 rows |
| Jonas sign-in via anon key + email+password | OK | OK |
| Farva sign-in via anon key + email+password | OK | OK |
| User dashboard confirmation (Authentication → Users) | 2 users visible | confirmed |
| User dashboard confirmation (Table Editor → profiles) | 2 rows visible | confirmed |
| User dashboard confirmation (RLS lock icon on profiles) | present | confirmed |

## Issues Encountered

- **`MODULE_TYPELESS_PACKAGE_JSON` warning when running `seed-users.ts`.** Node logs a cosmetic warning that `seed-users.ts` is not declared as ESM in `package.json`. ts-node still parses and runs the file correctly — both seed runs succeeded and emitted the expected output. Adding `"type": "module"` to `backend/package.json` would silence the warning but is deferred: ts-node's CommonJS-default mode is the canonical setup, and switching to ESM globally would require touching shared Edge Function code in 05-04. Logged as an observation; no functional impact.
- **`verify-seed.mjs` bare-specifier resolution.** The first invocation from `/tmp/` failed to resolve `@supabase/supabase-js` (no `node_modules/` adjacent to the file). Copied the script into `backend/` for the run, then deleted — never staged; clean `git status` confirmed afterwards.

## User Setup Required

None for this plan. The two passwords were provided via the executor prompt and written to the gitignored `backend/.env`. No external dashboard or service configuration is required by future plans on top of what 05-01 already documented.

## Threat Surface Scan

No new threat surface beyond the plan's `<threat_model>`. Mitigations from the register are in place:

- **T-05-03-01 (service-role key exposure):** Key read from `process.env.SUPABASE_SERVICE_ROLE_KEY` only; never hardcoded; `.env` gitignored (confirmed); committed files grep clean for the literal value.
- **T-05-03-02 (user passwords leaked):** Passwords read from `process.env.JONAS_PASSWORD` / `FARVA_PASSWORD`; `.env.example` has blank values; no commit contains the literal passwords.
- **T-05-03-03 (admin script elevation accepted):** Script is local/admin-run, not exposed as a network endpoint.
- **T-05-03-04 (broken RLS):** Actively verified at runtime — Jonas's signed-in client sees 1 profile row (own), 0 rows when filtering by Farva's id. Both halves of the test passed.

## Next Phase Readiness

Ready for the remaining waves of phase 05:

- **05-04 (edge-functions):** Has two authenticated users to obtain JWTs from for `verify_jwt=true` Edge Function tests (`proxy-anthropic`, `github-fs`). Jonas's JWT can be obtained via `supabase.auth.signInWithPassword` with the anon key and the password in `backend/.env`.
- **05-05 (smoke-tests):** Can now write end-to-end smoke scripts that sign in as Jonas or Farva, hit Edge Functions, and assert on RLS behaviour with real seeded data.
- **Hybrid app milestones beyond phase 05:** The Flutter client can authenticate against the cloud project with the same credentials used here.

No blockers identified.

## Self-Check

Verifying claims from this Summary:

- `backend/scripts/seed-users.ts` — FOUND
- `backend/package.json` — FOUND
- `backend/package-lock.json` — FOUND
- Commit `384a216` — FOUND (`feat(05-03): add seed-users.ts and package.json with admin SDK`)
- `grep -c createUser backend/scripts/seed-users.ts` returns 2 — VERIFIED
- `grep -c listUsers backend/scripts/seed-users.ts` returns 3 — VERIFIED
- `grep -c node_modules backend/.gitignore` returns 1 — VERIFIED (from 05-01; not re-added)
- `git check-ignore backend/.env` — VERIFIED (ignored)
- Committed files grep-clean for the literal password values — VERIFIED
- Cloud auth.users contains Jonas (491d7166...) and Farva (87e2d0cd...) — VERIFIED (admin.listUsers + user-confirmed in dashboard)
- Cloud public.profiles has 2 rows with correct display_name/tracker_dir/is_owner — VERIFIED (service-role select + user-confirmed in dashboard)
- Idempotent re-run yields [SKIP] for both — VERIFIED
- RLS: Jonas reads 1 own row, 0 cross-user rows — VERIFIED

## Self-Check: PASSED

---
*Phase: 05-backend-foundation*
*Completed: 2026-05-11*
