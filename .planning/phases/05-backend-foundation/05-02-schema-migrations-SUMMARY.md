---
phase: 05-backend-foundation
plan: 02
subsystem: backend-db
tags: [supabase, postgres, migrations, rls, trigger, rpc, schema]

requires:
  - "05-01: backend/ scaffold + CLI linked to cloud project hqljsvubvvfcatyonowb"
provides:
  - "Four SQL migrations (0001..0004) applied to cloud DB"
  - "public.profiles table (D-07) + on_auth_user_created trigger (D-08) + RLS with column-level GRANT (D-09)"
  - "public.api_usage table (D-25) with select-own RLS"
  - "public.increment_proxy_calls(uuid, date) atomic RPC for D-15 cost cap"
affects:
  - 05-03-seed-users
  - 05-04-edge-functions
  - 05-05-smoke-tests

tech-stack:
  added: []
  patterns:
    - "Four-digit lexicographic migration naming (0001_*, 0002_*) instead of timestamps"
    - "Column-level GRANT for admin-only field enforcement (revoke broad UPDATE + grant specific columns to authenticated)"
    - "SECURITY DEFINER trigger function with set search_path = public to mitigate search-path injection"
    - "Atomic counter via INSERT ... ON CONFLICT DO UPDATE — no read-then-write race"
    - "Cloud-push fallback when Docker is unavailable (supabase db push --linked instead of supabase db reset)"

key-files:
  created:
    - backend/supabase/migrations/0001_initial.sql
    - backend/supabase/migrations/0002_profiles.sql
    - backend/supabase/migrations/0003_api_usage.sql
    - backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql
  modified: []

key-decisions:
  - "Applied to linked cloud project via 'supabase db push' instead of local 'supabase db reset' because Docker Desktop was not running. Cloud project was empty (verified in 05-01), so this is non-destructive."
  - "Committed 0003 and 0004 together as Task 3 per the plan's task boundaries (the plan groups them in a single <task>)."
  - "Did NOT start Docker — push-to-cloud was the documented fallback in the executor prompt for exactly this case."

requirements-completed: [BE-01, BE-04]

duration: ~3 min executor wall-clock
completed: 2026-05-11
---

# Phase 05 Plan 02: Schema Migrations Summary

**Four migrations (0001 extensions, 0002 profiles + trigger + RLS with column-level GRANT, 0003 api_usage, 0004 increment_proxy_calls RPC) authored and applied to the linked cloud project via `supabase db push`. Schema verified end-to-end against D-07, D-08, D-09, and D-25.**

## Performance

- **Duration:** ~3 min executor wall-clock
- **Started:** 2026-05-11
- **Completed:** 2026-05-11
- **Tasks:** 3
- **Files created:** 4

## Accomplishments

- Four SQL migrations written with lexicographic naming (0001..0004), no timestamps.
- All four applied cleanly to the linked Supabase cloud project (`hqljsvubvvfcatyonowb`) via `supabase db push --include-all --linked`.
- `profiles` schema matches D-07 exactly (5 columns: id, display_name, tracker_dir, is_owner, created_at).
- `handle_new_user` trigger function created as SECURITY DEFINER with `set search_path = public` (D-08 + T-05-02-01 mitigation).
- `on_auth_user_created` trigger fires after insert on `auth.users` — verified present in `information_schema.triggers`.
- RLS enabled on both `profiles` and `api_usage` (rowsecurity=t in pg_tables).
- Column-level GRANT correctly restricts UPDATE to `display_name` only (T-05-02-02 and T-05-02-03 mitigations).
- `api_usage` schema matches D-25 (user_id, day, proxy_anthropic_calls, github_writes; composite PK).
- `increment_proxy_calls(uuid, date)` RPC exists with `INSERT ... ON CONFLICT DO UPDATE` for atomic counter increment (T-05-02-05 mitigation).

## Task Commits

1. **Task 1: 0001_initial.sql — extensions** — `3a56f0b` (feat)
2. **Task 2: 0002_profiles.sql — table, trigger, RLS with column-level GRANT** — `73860c5` (feat)
3. **Task 3: 0003_api_usage.sql + 0004_rpc_increment_proxy_calls.sql + apply + verify** — `f5a8d88` (feat)

Final SUMMARY commit will follow this file.

## Files Created/Modified

- `backend/supabase/migrations/0001_initial.sql` — pgcrypto + uuid-ossp extensions
- `backend/supabase/migrations/0002_profiles.sql` — profiles table, handle_new_user trigger, RLS policies, column-level GRANT
- `backend/supabase/migrations/0003_api_usage.sql` — api_usage cost-cap table with select-own RLS
- `backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql` — atomic increment RPC (SECURITY DEFINER)

## Decisions Made

- **Cloud-push instead of local reset.** Docker Desktop was not running on the workstation. The executor prompt explicitly authorized `supabase db push` against the empty linked cloud project as the documented fallback. This avoided a developer context switch (start Docker, wait for it, retry) and matches the single-developer reality where the cloud DB is the source of truth anyway. The migrations are still ordered for clean `supabase db reset` if a future contributor wires up Docker.
- **Task 3 commits 0003 + 0004 together.** The plan's task boundaries put both files in one `<task>` block; honored that boundary rather than splitting into two commits.
- **No hardcoded UUIDs in migrations.** Users will be seeded in 05-03; the trigger reads `auth.users` rows by reference, never by literal ID.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 — Blocking] Docker not running; used cloud push instead of local reset.**
- **Found during:** Task 3, when attempting verification step `supabase db reset`.
- **Issue:** Docker Desktop was not running, so `supabase db reset` (which requires a local Postgres container) would fail.
- **Fix:** Per the executor prompt's documented fallback for exactly this scenario, ran `supabase db push --include-all --linked` against the empty cloud project (`hqljsvubvvfcatyonowb`). Output confirmed all four migrations applied in order.
- **Files modified:** None (no migration changes; only the application environment changed).
- **Verification:** Ran `psql` (via `/opt/homebrew/opt/libpq/bin/psql`) against the cloud pooler URL to confirm: 2 expected tables exist, 2 expected functions exist, trigger present on `auth.users`, RLS enabled on both tables, profiles has 5 columns matching D-07, api_usage has 4 columns matching D-25.
- **Committed in:** Documentation in commit message of `f5a8d88`.

---

**Total deviations:** 1 (environment fallback; documented and authorized by executor prompt — not a code deviation).
**Impact on plan:** None on scope or schema. The only impact is which environment the migrations were applied to. The migration files themselves are unchanged from the plan's specification.

## Verification Performed

Verified against linked cloud project `hqljsvubvvfcatyonowb` (West EU, Ireland) via `psql`:

| Check | Expected | Actual |
|-------|----------|--------|
| `profiles` and `api_usage` exist in `public` | 2 rows | 2 rows |
| `handle_new_user` and `increment_proxy_calls` in `public` routines | 2 rows | 2 rows |
| `on_auth_user_created` trigger on `auth.users` | 1 row | 1 row |
| RLS enabled on `profiles` and `api_usage` | t, t | t, t |
| `profiles` columns | id, display_name, tracker_dir, is_owner, created_at | exact match |
| `api_usage` columns | user_id, day, proxy_anthropic_calls, github_writes | exact match |

Cross-user RLS check (a row from user A returning empty when queried as user B) is deferred to plan 05-03 / 05-05 — needs seeded users first.

## Issues Encountered

- **Docker not running** — handled via the documented cloud-push fallback (see Deviations).
- **`psql` not in default PATH** — exists at `/opt/homebrew/opt/libpq/bin/psql`; prepended to PATH for verification. Not a project issue, just a workstation observation.

## User Setup Required

None for this plan. The migrations are applied to the cloud DB and committed to git. The next plan (05-03 seed-users) will fill in the empty `JONAS_PASSWORD` and `FARVA_PASSWORD` fields in `backend/.env` before running.

## Threat Surface Scan

No new threat surface beyond what the plan's `<threat_model>` already enumerates. All mitigations from the register (T-05-02-01 through T-05-02-05) are implemented in the migration files:

- T-05-02-01 (trigger SECURITY DEFINER): `set search_path = public` is present in `handle_new_user`.
- T-05-02-02 / T-05-02-03 (column-level GRANT): `revoke update ...; grant update (display_name) ...` is present in 0002.
- T-05-02-05 (atomic counter): `INSERT ... ON CONFLICT DO UPDATE` is present in 0004.
- T-05-02-04 (counter overflow): accepted — no mitigation needed.

## Next Phase Readiness

Ready for Wave 3 of phase 05:
- **05-03 (seed-users)** can now run — `auth.users` insertions will fire `on_auth_user_created` and populate `profiles`.
- **05-04 (edge-functions)** has its `increment_proxy_calls` RPC ready for `proxy-anthropic`.
- **05-05 (smoke-tests)** can assert on tables, RLS, and the RPC end-to-end after 05-03 seeds users.

No blockers.

## Self-Check

- `backend/supabase/migrations/0001_initial.sql` — FOUND
- `backend/supabase/migrations/0002_profiles.sql` — FOUND
- `backend/supabase/migrations/0003_api_usage.sql` — FOUND
- `backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql` — FOUND
- Commit `3a56f0b` — FOUND (`feat(05-02): add 0001_initial.sql for postgres extensions`)
- Commit `73860c5` — FOUND (`feat(05-02): add 0002_profiles.sql with auth trigger and RLS`)
- Commit `f5a8d88` — FOUND (`feat(05-02): add 0003 api_usage and 0004 increment_proxy_calls RPC`)
- Cloud DB verification (psql queries) — ALL PASSED

## Self-Check: PASSED

---
*Phase: 05-backend-foundation*
*Completed: 2026-05-11*
