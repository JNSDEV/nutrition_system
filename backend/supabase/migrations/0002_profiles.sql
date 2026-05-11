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
