---
phase: 05-backend-foundation
plan: 02
type: execute
wave: 2
depends_on:
  - "05-01"
files_modified:
  - backend/supabase/migrations/0001_initial.sql
  - backend/supabase/migrations/0002_profiles.sql
  - backend/supabase/migrations/0003_api_usage.sql
  - backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql
autonomous: true
requirements:
  - BE-01
  - BE-04
last_updated: 2026-05-11

must_haves:
  truths:
    - "Four migration files exist with lexicographic names (0001, 0002, 0003, 0004)"
    - "profiles table has schema exactly matching D-07"
    - "on_auth_user_created trigger auto-inserts a profiles row on auth.users insert"
    - "RLS is enabled on profiles per D-09: select own row only, update display_name only (tracker_dir and is_owner are admin-only at database level)"
    - "api_usage table has schema exactly matching D-25"
    - "increment_proxy_calls Postgres function exists and atomically increments proxy_anthropic_calls"
    - "supabase db reset applies all migrations without error locally"
  artifacts:
    - path: "backend/supabase/migrations/0001_initial.sql"
      provides: "Enable pgcrypto and uuid-ossp extensions"
    - path: "backend/supabase/migrations/0002_profiles.sql"
      provides: "profiles table + handle_new_user trigger + RLS policies with column-level GRANT"
      contains: "on_auth_user_created"
    - path: "backend/supabase/migrations/0003_api_usage.sql"
      provides: "api_usage table for D-15 cost-cap counter"
    - path: "backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql"
      provides: "Atomic increment Postgres function called by proxy-anthropic via supabase.rpc()"
      contains: "increment_proxy_calls"
  key_links:
    - from: "auth.users (Supabase Auth)"
      to: "public.profiles"
      via: "on_auth_user_created trigger"
      pattern: "after insert on auth.users"
    - from: "public.profiles.id"
      to: "auth.users.id"
      via: "FK with ON DELETE CASCADE"
      pattern: "references auth.users(id) on delete cascade"
    - from: "public.api_usage.user_id"
      to: "auth.users.id"
      via: "FK with ON DELETE CASCADE"
      pattern: "references auth.users(id) on delete cascade"
    - from: "proxy-anthropic Edge Function"
      to: "public.api_usage.proxy_anthropic_calls"
      via: "supabase.rpc('increment_proxy_calls', ...) calling 0004 function"
      pattern: "increment_proxy_calls"
---

<objective>
Write four SQL migration files that establish the full Phase 5 schema: extensions in `0001`, the `profiles` table + trigger + RLS in `0002`, the `api_usage` cost-cap table in `0003`, and the `increment_proxy_calls` atomic RPC function in `0004`. Apply locally with `supabase db reset` and verify the schema in Studio.

Purpose: Every other plan depends on these tables existing. The trigger must be in place before user seeding (plan 05-03). The `increment_proxy_calls` function must exist before plan 05-04 deploys `proxy-anthropic`, which calls it via `supabase.rpc()` to enforce the D-15 cost cap atomically.

Output: Four migration files in `backend/supabase/migrations/`. `supabase db reset` applies all four cleanly. Supabase Studio shows `profiles` and `api_usage` tables with correct columns, RLS enabled, and the `increment_proxy_calls` function visible under Database → Functions.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/05-backend-foundation/05-CONTEXT.md
@.planning/phases/05-backend-foundation/05-RESEARCH.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Write migration 0001_initial.sql — extensions</name>
  <files>backend/supabase/migrations/0001_initial.sql</files>
  <action>
    Create `backend/supabase/migrations/0001_initial.sql`:

    ```sql
    -- 0001_initial.sql
    -- Enable required Postgres extensions.
    -- pgcrypto: password hashing for local seed.sql (supabase/seed.sql).
    -- uuid-ossp: gen_random_uuid() in case pgcrypto uuid functions are needed.
    -- Both are pre-enabled on Supabase cloud but must be declared in migrations
    -- for local dev (supabase db reset starts from a clean Postgres instance).

    create extension if not exists "pgcrypto";
    create extension if not exists "uuid-ossp";
    ```

    This migration is intentionally minimal — its only job is to guarantee the extensions are available before 0002 runs.
  </action>
  <verify>
    `ls backend/supabase/migrations/0001_initial.sql` exits 0.
    `grep -c "pgcrypto" backend/supabase/migrations/0001_initial.sql` returns 1.
  </verify>
  <done>0001_initial.sql exists and enables pgcrypto and uuid-ossp.</done>
</task>

<task type="auto">
  <name>Task 2: Write migration 0002_profiles.sql — table, trigger, RLS with column-level GRANT</name>
  <files>backend/supabase/migrations/0002_profiles.sql</files>
  <action>
    Create `backend/supabase/migrations/0002_profiles.sql` implementing D-07, D-08, and D-09 exactly.

    D-09 requires that `tracker_dir` and `is_owner` are admin-only — not just at the app layer but enforced at the database level. This is achieved by revoking broad UPDATE permission and granting column-specific access:

    ```sql
    -- 0002_profiles.sql
    -- Profiles table (D-07), auto-creation trigger (D-08), and RLS policies (D-09).

    -- ── Table ──────────────────────────────────────────────────────────────────
    create table public.profiles (
      id          uuid        primary key references auth.users(id) on delete cascade,
      display_name text       not null,
      tracker_dir  text       not null check (tracker_dir in ('jonas', 'farva')),
      is_owner     boolean    not null default false,
      created_at   timestamptz default now()
    );

    -- ── Trigger function ───────────────────────────────────────────────────────
    -- Reads raw_user_meta_data set by the seed script (display_name, tracker_dir).
    -- is_owner is true only when display_name is exactly 'Jonas'.
    -- SECURITY DEFINER so the function can insert into public.profiles even when
    -- called from the auth schema context.
    -- set search_path = public prevents search-path injection.
    create or replace function public.handle_new_user()
    returns trigger
    language plpgsql
    security definer set search_path = public
    as $$
    begin
      insert into public.profiles (id, display_name, tracker_dir, is_owner)
      values (
        new.id,
        coalesce(new.raw_user_meta_data->>'display_name', new.email),
        coalesce(new.raw_user_meta_data->>'tracker_dir', 'jonas'),
        (new.raw_user_meta_data->>'display_name' = 'Jonas')
      );
      return new;
    end;
    $$;

    -- Trigger fires after every INSERT on auth.users (D-08).
    -- This covers both the seed script (plan 05-03) and any future signup.
    create trigger on_auth_user_created
      after insert on auth.users
      for each row execute procedure public.handle_new_user();

    -- ── RLS policies (D-09) ────────────────────────────────────────────────────
    alter table public.profiles enable row level security;

    -- SELECT: authenticated user can read only their own row.
    create policy "profiles_select_own"
      on public.profiles
      for select
      to authenticated
      using (auth.uid() = id);

    -- UPDATE: authenticated user can update only their own row.
    create policy "profiles_update_own"
      on public.profiles
      for update
      to authenticated
      using (auth.uid() = id)
      with check (auth.uid() = id);

    -- D-09: tracker_dir and is_owner are admin-only columns.
    -- Revoke broad UPDATE, then grant only display_name to authenticated role.
    -- This enforces the column restriction at the database level, not just app-layer trust.
    revoke update on public.profiles from authenticated;
    grant update (display_name) on public.profiles to authenticated;

    -- INSERT and DELETE have no policies → blocked for all non-admin roles.
    -- The trigger (SECURITY DEFINER) bypasses RLS for its own insert.
    ```

    IMPORTANT: migration file naming convention is `0002_profiles.sql` (four digits, underscore, lowercase). Do not use timestamps.
  </action>
  <verify>
    `grep -c "on_auth_user_created" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "enable row level security" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "tracker_dir in" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "revoke update" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "grant update (display_name)" backend/supabase/migrations/0002_profiles.sql` returns 1.
  </verify>
  <done>
    0002_profiles.sql exists with: `profiles` table matching D-07 schema exactly, `handle_new_user` trigger function (SECURITY DEFINER, per D-08), `on_auth_user_created` trigger on `auth.users`, RLS policies for select-own and update-own, and column-level GRANT restricting UPDATE to `display_name` only (per D-09: `tracker_dir` and `is_owner` are admin-only at the database level). INSERT and DELETE are blocked (no policy).
  </done>
</task>

<task type="auto">
  <name>Task 3: Write migrations 0003 and 0004, apply all, verify locally</name>
  <files>
    backend/supabase/migrations/0003_api_usage.sql
    backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql
  </files>
  <action>
    Create `backend/supabase/migrations/0003_api_usage.sql` implementing D-25:

    ```sql
    -- 0003_api_usage.sql
    -- Cost-guardrail counter table (D-25).
    -- Used by proxy-anthropic (D-15: 100 req/day soft cap per user).
    -- github_writes column reserved for a future write cap (Phase 9 consideration).

    create table public.api_usage (
      user_id               uuid   not null references auth.users(id) on delete cascade,
      day                   date   not null,
      proxy_anthropic_calls int    not null default 0,
      github_writes         int    not null default 0,
      primary key (user_id, day)
    );

    -- RLS: users can read their own usage row (for future in-app cap display).
    -- Write access is admin-only (Edge Functions use service-role key to upsert).
    alter table public.api_usage enable row level security;

    create policy "api_usage_select_own"
      on public.api_usage
      for select
      to authenticated
      using (auth.uid() = user_id);
    ```

    Create `backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql`:

    ```sql
    -- 0004_rpc_increment_proxy_calls.sql
    -- Atomic increment function for proxy-anthropic's D-15 cost cap.
    -- Called via supabase.rpc('increment_proxy_calls', { p_user_id, p_day }) from _shared/usage.ts.
    -- Uses INSERT ... ON CONFLICT DO UPDATE to atomically increment without a read-then-write race.
    -- The Edge Function calls this with a service-role client (bypasses RLS).

    create or replace function public.increment_proxy_calls(p_user_id uuid, p_day date)
    returns void
    language sql
    security definer
    set search_path = public
    as $$
      insert into public.api_usage (user_id, day, proxy_anthropic_calls)
      values (p_user_id, p_day, 1)
      on conflict (user_id, day)
      do update set proxy_anthropic_calls = api_usage.proxy_anthropic_calls + 1;
    $$;
    ```

    Then apply all migrations locally:
    1. From `backend/` dir, ensure `supabase start` is running (start it if not: `supabase start`)
    2. Run `supabase db reset` — this wipes the local DB and re-applies all migrations in order
    3. Verify: open Studio (URL from `supabase status`) and confirm:
       - `profiles` table exists with columns: id, display_name, tracker_dir, is_owner, created_at
       - `api_usage` table exists with columns: user_id, day, proxy_anthropic_calls, github_writes
       - Both tables have RLS enabled (lock icon in Studio)
       - `on_auth_user_created` trigger appears on `auth.users`
       - `increment_proxy_calls` function visible under Database → Functions

    If `supabase db reset` fails with "relation public.profiles does not exist", check migration order — 0001 must come before 0002, and 0003 must come before 0004 (Supabase CLI applies in lexicographic order).
  </action>
  <verify>
    `supabase db reset` exits 0 (from backend/ dir).
    `grep -c "increment_proxy_calls" backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql` returns 1.
    `grep -c "on conflict" backend/supabase/migrations/0004_rpc_increment_proxy_calls.sql` returns 1.
    After reset: confirm via Studio or psql that both tables exist.
    Quick psql check (using DATABASE_URL from .env):
    `psql "$DATABASE_URL" -c "select count(*) from information_schema.tables where table_schema = 'public' and table_name in ('profiles','api_usage')" 2>/dev/null | grep -c "2"` returns 1.
    `psql "$DATABASE_URL" -c "select count(*) from information_schema.routines where routine_schema = 'public' and routine_name = 'increment_proxy_calls'" 2>/dev/null | grep -c "1"` returns 1.
  </verify>
  <done>
    All four migrations apply cleanly via `supabase db reset`. `profiles` and `api_usage` tables exist in the local DB with correct schema and RLS enabled. The `on_auth_user_created` trigger is visible on `auth.users`. The `increment_proxy_calls` function exists in the `public` schema, is `SECURITY DEFINER`, and uses an atomic `INSERT ... ON CONFLICT DO UPDATE` to increment the counter. No seed data exists yet (seeding is plan 05-03).
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Postgres trigger (SECURITY DEFINER) → public.profiles | Trigger bypasses RLS; must be kept simple with no network calls |
| RLS policies → authenticated users | Postgres enforces row-level access; no app-level bypass possible |
| increment_proxy_calls (SECURITY DEFINER) → public.api_usage | Called by service-role Edge Function; atomic update prevents race on counter |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-02-01 | Elevation of Privilege | handle_new_user trigger (SECURITY DEFINER) | mitigate | Trigger body is minimal (one INSERT); `set search_path = public` prevents search-path injection; no network calls in trigger body |
| T-05-02-02 | Elevation of Privilege | profiles RLS — is_owner not updateable | mitigate | Column-level GRANT: `revoke update on profiles from authenticated; grant update (display_name) on profiles to authenticated` — enforced at DB level, not app-layer trust |
| T-05-02-03 | Elevation of Privilege | tracker_dir not updateable via RLS | mitigate | Same column-level GRANT as T-05-02-02: only `display_name` is grantable to authenticated role |
| T-05-02-04 | Denial of Service | api_usage counter overflow | accept | int type holds 2.1B; at 100 req/day cap this won't overflow in any realistic scenario |
| T-05-02-05 | Tampering | increment_proxy_calls race condition | mitigate | Atomic `INSERT ... ON CONFLICT DO UPDATE SET ... = ... + 1` at the Postgres level; no read-then-write gap |
</threat_model>

<verification>
- `supabase db reset` completes without error
- `profiles` table has all 5 columns from D-07: id, display_name, tracker_dir, is_owner, created_at
- `api_usage` table has all 4 columns from D-25: user_id, day, proxy_anthropic_calls, github_writes
- RLS is enabled on both tables (visible in Studio → Table Editor → RLS)
- `on_auth_user_created` trigger exists on `auth.users` (visible in Studio → Database → Triggers)
- `increment_proxy_calls` function exists in the `public` schema (visible in Studio → Database → Functions)
- Column-level GRANT: `REVOKE UPDATE ON profiles FROM authenticated; GRANT UPDATE (display_name) ON profiles TO authenticated` — verified in migration file
- Migration files are committed to git
</verification>

<success_criteria>
Four migration files exist in `backend/supabase/migrations/` with lexicographic names `0001`, `0002`, `0003`, `0004`. Running `supabase db reset` locally applies all four without error. The `profiles` schema matches D-07 exactly. The `on_auth_user_created` trigger matches D-08. RLS policies match D-09, with column-level GRANT ensuring `tracker_dir` and `is_owner` cannot be updated by authenticated users at the database level. The `api_usage` table matches D-25. The `increment_proxy_calls` function atomically increments the cost-cap counter used by plan 05-04.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-02-schema-migrations-SUMMARY.md` using the summary template.
</output>
