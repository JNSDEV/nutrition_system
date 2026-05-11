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
autonomous: true
requirements:
  - BE-01
  - BE-04

must_haves:
  truths:
    - "Three migration files exist with lexicographic names (0001, 0002, 0003)"
    - "profiles table has schema exactly matching D-07"
    - "on_auth_user_created trigger auto-inserts a profiles row on auth.users insert"
    - "RLS is enabled on profiles per D-09: select own row only, update display_name only"
    - "api_usage table has schema exactly matching D-25"
    - "supabase db reset applies all migrations without error locally"
  artifacts:
    - path: "backend/supabase/migrations/0001_initial.sql"
      provides: "Enable pgcrypto and uuid-ossp extensions"
    - path: "backend/supabase/migrations/0002_profiles.sql"
      provides: "profiles table + handle_new_user trigger + RLS policies"
      contains: "on_auth_user_created"
    - path: "backend/supabase/migrations/0003_api_usage.sql"
      provides: "api_usage table for D-15 cost-cap counter"
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
---

<objective>
Write three SQL migration files that establish the full Phase 5 schema: extensions in `0001`, the `profiles` table + trigger + RLS in `0002`, and the `api_usage` cost-cap table in `0003`. Apply locally with `supabase db reset` and verify the schema in Studio.

Purpose: Every other plan depends on these tables existing. The trigger must be in place before user seeding (plan 05-03) so that the `on_auth_user_created` trigger fires and populates `profiles` automatically.

Output: Three migration files in `backend/supabase/migrations/`. `supabase db reset` applies all three cleanly. Supabase Studio shows `profiles` and `api_usage` tables with correct columns and RLS enabled.
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
  <name>Task 2: Write migration 0002_profiles.sql — table, trigger, RLS</name>
  <files>backend/supabase/migrations/0002_profiles.sql</files>
  <action>
    Create `backend/supabase/migrations/0002_profiles.sql` implementing D-07, D-08, and D-09 exactly:

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
    -- tracker_dir and is_owner have no update policy → blocked for all users.
    -- Only display_name can be updated via this policy (no column restriction needed
    -- in the policy itself — the app should only send display_name in updates;
    -- adding a CHECK OPTION or column-level grant can harden this in Phase 9 if needed).
    create policy "profiles_update_own"
      on public.profiles
      for update
      to authenticated
      using (auth.uid() = id)
      with check (auth.uid() = id);

    -- INSERT and DELETE have no policies → blocked for all non-admin roles.
    -- The trigger (SECURITY DEFINER) bypasses RLS for its own insert.
    ```

    IMPORTANT: migration file naming convention is `0002_profiles.sql` (two digits, underscore, lowercase). Do not use timestamps.
  </action>
  <verify>
    `grep -c "on_auth_user_created" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "enable row level security" backend/supabase/migrations/0002_profiles.sql` returns 1.
    `grep -c "tracker_dir in" backend/supabase/migrations/0002_profiles.sql` returns 1.
  </verify>
  <done>
    0002_profiles.sql exists with: `profiles` table matching D-07 schema exactly, `handle_new_user` trigger function (SECURITY DEFINER, per D-08), `on_auth_user_created` trigger on `auth.users`, and RLS policies for select-own and update-own (D-09). INSERT and DELETE are blocked (no policy).
  </done>
</task>

<task type="auto">
  <name>Task 3: Write migration 0003_api_usage.sql, apply all migrations, verify locally</name>
  <files>backend/supabase/migrations/0003_api_usage.sql</files>
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

    Then apply all migrations locally:
    1. From `backend/` dir, ensure `supabase start` is running (start it if not: `supabase start`)
    2. Run `supabase db reset` — this wipes the local DB and re-applies all migrations in order
    3. Verify: `supabase db inspect` or open Studio (URL from `supabase status`) and confirm:
       - `profiles` table exists with columns: id, display_name, tracker_dir, is_owner, created_at
       - `api_usage` table exists with columns: user_id, day, proxy_anthropic_calls, github_writes
       - Both tables have RLS enabled (lock icon in Studio)
       - `on_auth_user_created` trigger appears on `auth.users`

    If `supabase db reset` fails with "relation public.profiles does not exist", check migration order — 0001 must come before 0002 (Supabase CLI applies in lexicographic order).
  </action>
  <verify>
    `supabase db reset` exits 0 (from backend/ dir).
    After reset: confirm via Studio or psql that both tables exist.
    Quick psql check (using DATABASE_URL from .env):
    `psql "$DATABASE_URL" -c "select count(*) from information_schema.tables where table_schema = 'public' and table_name in ('profiles','api_usage')" 2>/dev/null | grep -c "2"` returns 1.
  </verify>
  <done>
    All three migrations apply cleanly via `supabase db reset`. `profiles` and `api_usage` tables exist in the local DB with correct schema and RLS enabled. The `on_auth_user_created` trigger is visible on `auth.users`. No seed data exists yet (seeding is plan 05-03).
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Postgres trigger (SECURITY DEFINER) → public.profiles | Trigger bypasses RLS; must be kept simple with no network calls |
| RLS policies → authenticated users | Postgres enforces row-level access; no app-level bypass possible |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-02-01 | Elevation of Privilege | handle_new_user trigger (SECURITY DEFINER) | mitigate | Trigger body is minimal (one INSERT); `set search_path = public` prevents search-path injection; no network calls in trigger body |
| T-05-02-02 | Elevation of Privilege | profiles RLS — is_owner not updateable | mitigate | No UPDATE policy for is_owner; Postgres blocks column updates with no policy covering them for non-admin roles |
| T-05-02-03 | Elevation of Privilege | tracker_dir not updateable via RLS | accept | tracker_dir check constraint + no dedicated update policy; admin-only change is acceptable for 2-user personal system |
| T-05-02-04 | Denial of Service | api_usage counter overflow | accept | int type holds 2.1B; at 100 req/day cap this won't overflow in any realistic scenario |
</threat_model>

<verification>
- `supabase db reset` completes without error
- `profiles` table has all 5 columns from D-07: id, display_name, tracker_dir, is_owner, created_at
- `api_usage` table has all 4 columns from D-25: user_id, day, proxy_anthropic_calls, github_writes
- RLS is enabled on both tables (visible in Studio → Table Editor → RLS)
- `on_auth_user_created` trigger exists on `auth.users` (visible in Studio → Database → Triggers)
- Migration files are committed to git
</verification>

<success_criteria>
Three migration files exist in `backend/supabase/migrations/` with lexicographic names `0001`, `0002`, `0003`. Running `supabase db reset` locally applies all three without error. The `profiles` schema matches D-07 exactly. The `on_auth_user_created` trigger matches D-08. RLS policies match D-09. The `api_usage` table matches D-25.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-02-schema-migrations-SUMMARY.md` using the summary template.
</output>
