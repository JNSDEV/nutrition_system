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
