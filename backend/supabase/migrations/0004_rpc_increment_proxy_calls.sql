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
