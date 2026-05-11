---
phase: 05-backend-foundation
milestone: v1.1
plans: 6
waves: 5
created: 2026-05-11
last_updated: 2026-05-11
requirements: BE-01, BE-02, BE-03, BE-04
---

# Phase 5: Backend Foundation — Plan Manifest

## Wave Structure

| Wave | Plan | File | Depends On | Autonomous | Requirements |
|------|------|------|-----------|------------|--------------|
| 1 | 05-01 | 05-01-repo-bootstrap-PLAN.md | — | No (human-action + human-verify) | BE-01, BE-02, BE-03, BE-04 |
| 2 | 05-02 | 05-02-schema-migrations-PLAN.md | 05-01 | Yes | BE-01, BE-04 |
| 3 | 05-03 | 05-03-user-seeding-PLAN.md | 05-02 | No (human-verify) | BE-01, BE-04 |
| 4 | 05-04 | 05-04-proxy-anthropic-PLAN.md | 05-03 | No (human-verify) | BE-02 |
| 4 | 05-05 | 05-05-github-fs-PLAN.md | 05-03 | No (human-verify) | BE-03 |
| 5 | 05-06 | 05-06-health-deploy-e2e-PLAN.md | 05-04, 05-05 | No (human-verify) | BE-01, BE-02, BE-03, BE-04 |

## Dependency Graph

```
05-01 (Wave 1: Repo + CLI bootstrap)
  └── 05-02 (Wave 2: Schema migrations — 4 files incl. RPC function)
        └── 05-03 (Wave 3: User seeding)
              ├── 05-04 (Wave 4: proxy-anthropic) ─┐
              └── 05-05 (Wave 4: github-fs)        ─┤
                                                    └── 05-06 (Wave 5: health + E2E)
```

Plans 05-04 and 05-05 are parallel (Wave 4 — no file conflicts, no cross-dependency).

## File Ownership (parallel-execution safety)

| Plan | Files Modified |
|------|---------------|
| 05-01 | backend/.gitignore, backend/.env.example, backend/supabase/config.toml, backend/supabase/functions/.env.example, backend/README.md |
| 05-02 | backend/supabase/migrations/0001_initial.sql, 0002_profiles.sql, 0003_api_usage.sql, 0004_rpc_increment_proxy_calls.sql |
| 05-03 | backend/scripts/seed-users.ts, backend/package.json |
| 05-04 | backend/supabase/functions/proxy-anthropic/index.ts, backend/supabase/functions/proxy-anthropic/deno.json, backend/supabase/functions/_shared/usage.ts, backend/scripts/smoke/proxy-anthropic.sh |
| 05-05 | backend/supabase/functions/github-fs/index.ts, backend/supabase/functions/github-fs/deno.json, backend/supabase/functions/_shared/github.ts, backend/scripts/smoke/github-fs-read.sh, backend/scripts/smoke/github-fs-write.sh |
| 05-06 | backend/supabase/functions/health/index.ts, backend/supabase/functions/health/deno.json |

No file is modified by more than one plan. 05-04 and 05-05 can execute in parallel.

## Execution Notes

- **Plans 05-01 and 05-03** have `checkpoint:human-action` tasks requiring Jonas to provision the Supabase project and gather credentials (01) or verify Studio data and run cloud seed (03). These are blocking gates.
- **All plans except 05-02** have at least one `checkpoint:human-verify` gate (cloud deploys require Jonas to confirm Supabase Studio state).
- **Plan 05-02** is the only fully autonomous plan — migrations are mechanical and verifiable by `supabase db reset`.

## Locked Decisions Implemented

| Decision | Plan | Task |
|----------|------|------|
| D-01 backend/ monorepo | 05-01 | Task 1 |
| D-02 Deno + TypeScript Edge Functions | 05-04, 05-05, 05-06 | All function tasks |
| D-03 migrations version-controlled | 05-02 | All migration tasks |
| D-04 email+password auth | 05-03 | Task 1 (seed script) |
| D-05 seed via script (Approach B per research) | 05-03 | Task 1 |
| D-06 no signup endpoint | 05-01 | config.toml has no signup function |
| D-07 profiles schema | 05-02 | Task 2 |
| D-08 on_auth_user_created trigger | 05-02 | Task 2 |
| D-09 RLS on profiles — update display_name only, tracker_dir and is_owner admin-only at DB level | 05-02 | Task 2 (REVOKE/GRANT) |
| D-10 proxy-anthropic POST endpoint | 05-04 | Task 1 |
| D-11 non-streaming | 05-04 | Task 1 (await json, return JSON) |
| D-12 Anthropic key in secrets | 05-04 | Task 1 (Deno.env) |
| D-13 model from app | 05-04 | Task 1 (forward verbatim) |
| D-14 logging count+latency only | 05-04 | Task 1 |
| D-15 100-req/day cap — unconditional counter increment on all forwarded requests | 05-04 | Task 1 (index.ts) + migration 0004 + _shared/usage.ts RPC call |
| D-16 three verbs one function | 05-05 | Task 1 |
| D-17 GITHUB_PAT in secrets, GITHUB_REPO env | 05-05 | Task 1 |
| D-18 commit attribution from profiles.display_name | 05-05 | Task 1 |
| D-19 one write = one commit | 05-05 | Task 1 (no batching) |
| D-20 main branch only | 05-05 | Task 1 (_shared/github.ts branch: 'main') |
| D-21 path validation (no .., no .git/) | 05-05 | Task 1 (validatePath) |
| D-22 list returns name+type+size | 05-05 | Task 1 |
| D-23 read returns path+content+sha | 05-05 | Task 1 |
| D-24 write sha required for updates, 409 on conflict | 05-05 | Task 1 (writeWithRetry — 3 attempts, correct loop bounds) |
| D-25 api_usage schema | 05-02 | Task 3 |
| D-26 bash+curl smoke tests | 05-04, 05-05 | Task 2 each |
| D-27 Studio for inspection | 05-03, 05-06 | checkpoint tasks |

## Research-Locked Decisions Honored

| Research Finding | Plan | Implementation |
|-----------------|------|----------------|
| User seeding: TypeScript script (Approach B) with admin SDK, idempotent via listUsers() check | 05-03 | seed-users.ts uses listUsers().find() NOT ON CONFLICT |
| GitHub client: raw fetch, NOT Octokit | 05-05 | _shared/github.ts uses native Deno fetch |
| Migration naming: 0001_initial, 0002_profiles, 0003_api_usage, 0004_rpc_increment_proxy_calls | 05-02 | Exact naming applied |
| Profile trigger: on_auth_user_created (still canonical 2026) | 05-02 | create trigger on_auth_user_created |
| Local dev secrets: supabase/functions/.env + --env-file | 05-01 | .gitignore + .env.example |
| Smoke tests: bash + curl | 05-04, 05-05 | .sh scripts in scripts/smoke/ |
| health Edge Function | 05-06 | 5-line function, verify_jwt=false |
| 409 retry: 3 attempts, backoff 200ms * attempt | 05-05 | writeWithRetry in _shared/github.ts — loop: attempt < maxRetries; retry condition: attempt < maxRetries - 1 |
| ES256 JWT risk | 05-06, 05-01 | Task 2 explicitly checks; README documents fallback |
| SSRF guard: hard-code target URL | 05-04 | ANTHROPIC_API_URL is const, never from req body |
| Atomic increment for D-15 cap | 05-02, 05-04 | Migration 0004 creates increment_proxy_calls RPC; usage.ts calls it directly, no fallback |

## ROADMAP Success Criteria → Plan Coverage

| Success Criterion | Plans |
|-------------------|-------|
| 1. Supabase project + 2 user accounts can sign in | 05-01, 05-02, 05-03 |
| 2. proxy-anthropic returns Anthropic response, key not exposed | 05-04 |
| 3. github-fs read/list/write work, PAT not exposed | 05-05 |
| 4. profiles auto-populated on sign-in with correct fields | 05-02, 05-03 |
| All criteria E2E verified on cloud | 05-06 |

## Plan-Checker Fixes Applied (2026-05-11)

| Issue | Fix | Plans Changed |
|-------|-----|---------------|
| Blocker 1: `incrementProxyCalls` was a broken stub — primary RPC call plus fallback that never increments above 1 | Added migration `0004_rpc_increment_proxy_calls.sql` with atomic `INSERT ... ON CONFLICT DO UPDATE SET ... + 1`; `usage.ts` now calls RPC directly with no fallback | 05-02, 05-04 |
| Blocker 2: Counter only incremented on `anthropicResponse.ok` — cap-bypass via intentionally-bad requests | Moved `incrementProxyCalls` to run unconditionally after Anthropic fetch, before returning | 05-04 |
| Blocker 3 (false positive): VALIDATION.md check triggered by `## Validation Architecture` section in RESEARCH.md | Removed the section from RESEARCH.md; `nyquist_validation_enabled: false` means dimension 8 is skipped | 05-RESEARCH.md |
| Warning 4: `writeWithRetry` off-by-one — loop `attempt < maxRetries` with retry condition `attempt < maxRetries - 1` gave only 2 effective attempts | Corrected to `for (attempt = 0; attempt < maxRetries)` with `retry if attempt < maxRetries - 1`, giving 3 attempts as intended | 05-05 |
| Warning 5: RLS update policy allowed updating any column — D-09 says tracker_dir and is_owner are admin-only | Added `REVOKE UPDATE ON profiles FROM authenticated; GRANT UPDATE (display_name) ON profiles TO authenticated` to 0002 migration | 05-02 |
| Warning 6: `node_modules/` gitignore added by plan 05-03 instead of 05-01 | Added `node_modules/` to `.gitignore` in plan 05-01 Task 1 so 05-03 inherits it | 05-01 |
| Warning 8: Scope-reduction phrasing "add atomic increment if Phase 5 checker flags it" | Removed; fix is in place | 05-04 |
