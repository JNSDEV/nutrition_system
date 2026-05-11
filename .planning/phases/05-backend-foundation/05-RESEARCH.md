# Phase 5: Backend Foundation - Research

**Researched:** 2026-05-11
**Domain:** Supabase (Cloud + CLI) + Deno Edge Functions + GitHub Contents API + Anthropic API proxy
**Confidence:** HIGH (most answers verified against official docs; lower on Octokit vs fetch trade-offs)

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Supabase cloud (free tier) + CLI. `backend/` in this monorepo.
- **D-02:** Edge Functions on Deno, TypeScript only.
- **D-03:** Migrations version-controlled under `backend/supabase/migrations/`.
- **D-04:** Email + password auth. No magic link.
- **D-05:** Seed 2 users via migration. Passwords NOT committed — live in `.env` (gitignored).
- **D-06:** No signup endpoint. Admin-seeded accounts only.
- **D-07..D-09:** `profiles` table schema + trigger + RLS as documented.
- **D-10..D-15:** `proxy-anthropic` function: non-streaming, JWT required, key in secrets, model chosen by app, 100-req/day soft cap per user.
- **D-16..D-24:** `github-fs` function: single function three verbs, fine-grained PAT, commit attribution, one commit per write, `main` only, path validation.
- **D-25:** `api_usage` table schema.
- **D-26:** Manual curl smoke tests only, no test framework.
- **D-27:** Supabase Studio for ad-hoc inspection.

### Claude's Discretion

- Migration file ordering + naming convention.
- Exact shape of user-seeding in SQL (Postgres function vs `\set` vs `SELECT`-based `DO` block).
- `github-fs`: Octokit vs raw `fetch`.
- Smoke-test script style (bash + curl vs deno + fetch).
- Whether to add a `health` Edge Function.

### Deferred Ideas (OUT OF SCOPE)

- Streaming `proxy-anthropic` — Phase 8 if needed.
- Trees API for multi-file commits — Phase 8.
- GitHub webhook → Supabase cache invalidation — v1.2.
- Real-time subscriptions — v1.2.
- Magic-link auth — v1.2 consideration.
- Branch protection / PR-only writes — v1.2.
- Admin signup endpoint — not planned.
- Per-profile write restrictions in `github-fs` — Phase 9.
- Automated test framework — not planned.

</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| BE-01 | Supabase project with `auth.users`, 2 seeded accounts (Jonas + Farva) | Q1 + Q5 answer the seeding and profile trigger pattern |
| BE-02 | `proxy-anthropic` Edge Function: authenticated, server-held key, returns Anthropic response | Q4 confirms gateway JWT handling; model recommendation in Bonus |
| BE-03 | `github-fs` Edge Function: read/list/write verbs, server-held PAT, commit attribution | Q2, Q3 cover client choice and rate limits |
| BE-04 | `profiles` table auto-populated on signup via trigger | Q5 confirms trigger is still the correct approach |

</phase_requirements>

---

## Summary

This phase stands up the entire Supabase backend in one go: project provisioning, schema migrations, two seeded user accounts, the `profiles` trigger, and two Edge Functions. All 6 open research questions from the CONTEXT have been answered and are documented below.

The most important structural finding: **user seeding must NOT happen inside a regular migration file**. It belongs in `supabase/seed.sql` (or a separate idempotent deploy script) because the password hash must be computed by Postgres's `pgcrypto` extension at apply-time — not stored in plaintext anywhere in git. The rest of the architecture (JWT gateway, trigger-based profiles, raw fetch for GitHub, secrets via `.env`) is well-documented and the boring path.

The second most important finding: **`proxy-anthropic` and streaming are architecturally compatible** — switching from non-streaming to streaming is a one-line Response body change. No schema or endpoint contract change is needed, making the Phase 8 upgrade trivially additive.

**Primary recommendation:** Follow the pgcrypto SQL seed pattern in `supabase/seed.sql` (idempotent with `ON CONFLICT DO NOTHING`), use raw `fetch` for GitHub Contents API calls, rely on `verify_jwt = true` in config.toml for JWT enforcement, and keep the trigger-based profile creation. All of these are the official documented approach as of 2026.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Auth (sign-in, JWT issuance) | Supabase Auth (Platform) | — | Supabase manages the auth server; app just calls it |
| Profile auto-creation | Database (Postgres trigger) | — | Trigger fires on `auth.users` insert; no app code needed |
| RLS enforcement | Database (Postgres) | — | Row-level security is a Postgres primitive |
| Anthropic key storage | Edge Function secrets (Supabase) | — | Never exposed to app or DB |
| Anthropic proxy logic | Edge Function (`proxy-anthropic`) | — | Server-side; app never sees the key |
| GitHub PAT storage | Edge Function secrets (Supabase) | — | Same reason |
| GitHub file I/O | Edge Function (`github-fs`) | GitHub REST API | Edge Function calls GitHub as the authenticated actor |
| Request rate-capping | Database (`api_usage` table) | Edge Function reads/writes it | Simple counter; no external service needed |
| JWT verification | Supabase API Gateway | — | Gateway rejects unauthenticated before function body runs |
| Local secrets | `.env` file (gitignored) | `supabase functions serve --env-file` | CLI-native; no Docker secrets or direnv needed |

---

## Research Answers

### Q1: Supabase 2026 User-Seeding Pattern

**Can `auth.admin.createUser` be called from a SQL migration?**

No. `auth.admin.createUser` is a JavaScript SDK method on the admin client — it requires a service-role key and an HTTP call. It cannot be invoked from a SQL migration file.

**Two viable approaches exist. The recommended one is: pgcrypto seed SQL.**

**Approach A — SQL seed file with pgcrypto (RECOMMENDED)**

Supabase's `supabase/seed.sql` is executed after all migrations on `supabase db reset` and on `supabase start`. Use `pgcrypto` to hash the password at apply-time. Because the password comes from a Postgres `current_setting()` call or a `\set` variable injected by the CLI, it never appears in git.

Idiomatic idempotent pattern (place in `supabase/seed.sql`, NOT in a migration file):

```sql
-- Requires pgcrypto (enabled by default in Supabase)
DO $$
DECLARE
  v_jonas_id uuid := gen_random_uuid();
  v_farva_id uuid := gen_random_uuid();
  v_jonas_pw text := current_setting('app.jonas_password', true);
  v_farva_pw text := current_setting('app.farva_password', true);
BEGIN
  -- Jonas
  INSERT INTO auth.users (
    id, aud, role, email,
    encrypted_password, email_confirmed_at,
    raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    v_jonas_id, 'authenticated', 'authenticated', 'jonas@nutrition-system.local',
    crypt(v_jonas_pw, gen_salt('bf')), now(),
    '{"display_name":"Jonas","tracker_dir":"jonas"}'::jsonb,
    now(), now(), '', '', '', ''
  ) ON CONFLICT (email) DO NOTHING;

  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  SELECT gen_random_uuid(), id, id::text,
    format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
    'email', now(), now(), now()
  FROM auth.users WHERE email = 'jonas@nutrition-system.local'
  ON CONFLICT DO NOTHING;

  -- Farva (same pattern, different email/meta)
  INSERT INTO auth.users (
    id, aud, role, email,
    encrypted_password, email_confirmed_at,
    raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, email_change, email_change_token_new, recovery_token
  ) VALUES (
    v_farva_id, 'authenticated', 'authenticated', 'farva@nutrition-system.local',
    crypt(v_farva_pw, gen_salt('bf')), now(),
    '{"display_name":"Farva","tracker_dir":"farva"}'::jsonb,
    now(), now(), '', '', '', ''
  ) ON CONFLICT (email) DO NOTHING;

  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  SELECT gen_random_uuid(), id, id::text,
    format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
    'email', now(), now(), now()
  FROM auth.users WHERE email = 'farva@nutrition-system.local'
  ON CONFLICT DO NOTHING;
END $$;
```

Pass passwords without committing them:

```bash
# In backend/.env (gitignored):
JONAS_PASSWORD=hunter2
FARVA_PASSWORD=correct-horse

# Apply locally:
PGSSLMODE=disable psql "$DATABASE_URL" \
  -v app.jonas_password="$JONAS_PASSWORD" \
  -v app.farva_password="$FARVA_PASSWORD" \
  -f supabase/seed.sql

# Or via supabase CLI reset (picks up seed.sql automatically):
supabase db reset
# But passwords must be injected differently — use psql directly for prod seed.
```

**Approach B — Post-deploy TypeScript script using admin SDK**

A separate `backend/scripts/seed-users.ts` that calls `supabase.auth.admin.createUser(...)` using a service-role key. Run once manually after deployment. More explicit, zero SQL crypto knowledge needed.

```typescript
// Source: https://supabase.com/docs/reference/javascript/auth-admin-createuser
const { data, error } = await supabase.auth.admin.createUser({
  email: 'jonas@nutrition-system.local',
  password: process.env.JONAS_PASSWORD,
  email_confirm: true,
  user_metadata: { display_name: 'Jonas', tracker_dir: 'jonas' },
});
```

**Recommendation for this project:** Use **Approach B** (post-deploy script). Reasons:
1. D-05 says "migration reads them at apply-time" which is what Approach A provides, but Approach B is simpler to reason about and avoids Postgres `current_setting` injection complexity.
2. The Supabase community consensus (GitHub Discussion #35391, #1323) is that direct `auth.users` SQL inserts are fragile because Supabase's internal schema evolves (e.g., the `provider_id` requirement was added silently). Admin SDK calls are stable.
3. For a 2-user personal project, a one-time script run by Jonas is perfectly acceptable.

Make the script idempotent by checking whether the email exists first (`supabase.auth.admin.listUsers()`) or catching the "User already exists" error.

**Confidence:** HIGH — confirmed against [Supabase discussion #35391](https://github.com/orgs/supabase/discussions/35391), [official admin createUser docs](https://supabase.com/docs/reference/javascript/auth-admin-createuser), and [seeding discussion #1323](https://github.com/orgs/supabase/discussions/1323).

---

### Q2: GitHub Client Choice on Deno — Octokit vs Raw Fetch

**Recommendation: raw `fetch`.**

Reasons:

1. **Bundle size.** Supabase Edge Functions are packed as ESZip. The `@octokit/rest` package pulls in a significant dependency graph (15+ sub-packages). For 3 simple REST calls (`GET`, `PUT`, `GET` for list), the overhead is not justified. [VERIFIED: npm registry — `@octokit/rest` v22.0.1 has 15 declared dependencies]

2. **No Deno native support.** While Octokit technically works via `npm:@octokit/rest` or `esm.sh`, the Supabase community has documented issues with esm.sh imports not working reliably for complex packages. Raw `fetch` has zero import friction on Deno.

3. **The Contents API surface is tiny.** This function needs exactly 3 endpoints:
   - `GET /repos/{owner}/{repo}/contents/{path}` (read / list — same endpoint, different path type)
   - `PUT /repos/{owner}/{repo}/contents/{path}` (write)

   These are ~5 lines of typed fetch each. No SDK ergonomics are lost.

4. **Cold start.** Supabase Edge Functions achieve 0–5ms cold starts via ESZip format. Adding Octokit's module graph to the bundle increases ESZip size, adding latency even if marginal. For a latency-sensitive proxy function this matters. [CITED: https://supabase.com/docs/guides/functions/architecture]

5. **Supabase official examples** for GitHub integrations in their function examples repo use raw `fetch`, not Octokit. [CITED: https://github.com/supabase/supabase/blob/master/examples/edge-functions/README.md]

**Sample raw fetch pattern for write:**

```typescript
// Source: GitHub REST API docs https://docs.github.com/en/rest/repos/contents
const GITHUB_API = 'https://api.github.com';

async function githubWrite(
  repo: string, path: string, content: string,
  sha: string | null, message: string, author: { name: string; email: string }
): Promise<{ commit_sha: string; new_sha: string }> {
  const body: Record<string, unknown> = {
    message,
    content: btoa(unescape(encodeURIComponent(content))), // UTF-8 → base64
    branch: 'main',
    author,
    committer: { name: 'nutrition-system-bot', email: 'bot@nutrition-system.local' },
  };
  if (sha) body.sha = sha;

  const res = await fetch(`${GITHUB_API}/repos/${repo}/contents/${path}`, {
    method: 'PUT',
    headers: {
      Authorization: `Bearer ${Deno.env.get('GITHUB_PAT')}`,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  if (!res.ok) throw new Error(`GitHub write failed: ${res.status}`);
  const data = await res.json();
  return { commit_sha: data.commit.sha, new_sha: data.content.sha };
}
```

**Confidence:** MEDIUM-HIGH — based on official Supabase docs, npm registry version inspection, and community patterns. No direct 2026 benchmark comparison between Octokit and fetch was found, but the reasoning from first principles is solid.

---

### Q3: GitHub Contents API Rate Limits and 409 Retry Pattern

**Are we near the limit?**

Not even close. For a 2-user app writing ~10 files/day:

| Limit type | Limit | Our daily usage | Headroom |
|------------|-------|-----------------|----------|
| Primary: requests/hour (authenticated) | 5,000/hr | ~10 writes + ~30 reads = ~40/day | 99.2% unused |
| Secondary: write points/min | 180 write ops/min (each costs 5 points = 36 writes/min) | Writes are manual, never parallel | No risk |
| Secondary: content-generating ops/hr | 500/hr | ~10 writes/day | No risk |

[VERIFIED: https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api]

**409 SHA-conflict retry pattern:**

A 409 occurs when the `sha` supplied in the PUT body does not match the file's current sha on GitHub (another write happened between your read and your write). The correct retry loop:

```typescript
async function writeWithRetry(
  repo: string, path: string, content: string,
  knownSha: string | null, message: string, author: { name: string; email: string },
  maxRetries = 3
): Promise<{ commit_sha: string; new_sha: string }> {
  let sha = knownSha;
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await githubWrite(repo, path, content, sha, message, author);
    } catch (err) {
      if (err.status === 409 && attempt < maxRetries) {
        // Re-fetch current SHA and retry
        const current = await githubRead(repo, path);
        sha = current.sha;
        // Small backoff to avoid hammering
        await new Promise(r => setTimeout(r, 200 * (attempt + 1)));
      } else {
        throw err;
      }
    }
  }
  throw new Error('GitHub write: max retries exceeded');
}
```

**For our 2-user use case:** Two people writing the same file concurrently is extremely unlikely (they have separate `trackers/` directories and rarely edit shared `library/` files simultaneously). Still worth implementing the retry loop — it costs nothing and prevents mysterious failures.

**Important:** The GitHub docs note that parallel writes to the same file via the Contents API (vs Trees API) will conflict. The write path should be serialized per-file. This is already implied by D-19's "one write = one commit" decision. [CITED: https://docs.github.com/en/rest/repos/contents]

**Confidence:** HIGH for rate limits (official docs). MEDIUM for 409 retry pattern (derived from GitHub community discussions and general REST retry best practice; no official "this is how you retry a 409" doc exists).

---

### Q4: Supabase Edge Function JWT Verification

**Confirmed: yes, the gateway rejects unauthenticated requests before the function body runs.**

From official Supabase docs ([Securing Edge Functions](https://supabase.com/docs/guides/functions/auth)):

> "When `verify_jwt` is enabled (the default), the platform inspects the `Authorization` header of every request before your function runs. It expects a valid user JWT. If the header is missing, malformed, or signed with a different key, the platform returns a 401 error, and your code never executes."

**What this means for implementation:**

- No auth code is needed in the function body for the JWT check. Gateway handles it.
- Function body can immediately call `createClient(url, anonKey, { global: { headers: { Authorization: req.headers.get('Authorization') } } })` to get a user-scoped client.
- The default config requires no explicit `verify_jwt` setting — it is `true` by default.

**config.toml pattern (explicit, for clarity):**

```toml
[functions.proxy-anthropic]
verify_jwt = true

[functions.github-fs]
verify_jwt = true
```

**2026 API Key Gotcha:** Supabase introduced new publishable/secret key format (`sb_publishable_...`, `sb_secret_...`) in 2026. These are NOT JWTs. If sent via `Authorization: Bearer`, the gateway rejects them with 401. They must go in the `apikey` header. The app should send:
- `Authorization: Bearer <user-session-jwt>` — for auth
- `apikey: <publishable-key>` — for project identification

This is the correct supabase-js default when calling `supabase.functions.invoke()`. No special handling needed in the function body. [CITED: https://supabase.com/docs/guides/functions/auth, https://github.com/orgs/supabase/discussions/41834]

**Confidence:** HIGH — verified against official docs and confirmed by multiple community issues.

---

### Q5: Profile Auto-Creation Pattern

**Confirmed: the `on_auth_user_created` database trigger is still the recommended 2026 approach.**

From official Supabase docs ([Managing User Data](https://supabase.com/docs/guides/auth/managing-user-data)):

> The guide specifically demonstrates the `on_auth_user_created` trigger pattern as the standard solution.

**Why not auth hooks?** Supabase has a "Before User Created" hook but it fires _before_ the `auth.users` row is inserted, so the user's `id` UUID does not yet exist. You cannot insert into `public.profiles` (which references `auth.users.id` via FK) from a before-hook. A post-user-creation hook has been requested ([discussion #39576](https://github.com/orgs/supabase/discussions/39576)) but as of May 2026 it does not exist. The trigger is the only option. [VERIFIED: Supabase Auth Hooks docs + discussion #39576]

**Implementation matching D-07/D-08:**

```sql
-- In a migration file (e.g., 0002_profiles.sql)
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  tracker_dir text not null check (tracker_dir in ('jonas','farva')),
  is_owner boolean not null default false,
  created_at timestamptz default now()
);

-- Trigger function reads raw_user_meta_data set by seed
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

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

**Warning from official docs:** If the trigger function throws, signup is blocked for that user. Keep the function simple — no network calls, no complex logic. The implementation above is safe.

**Confidence:** HIGH — confirmed against official docs and auth-hooks discussions.

---

### Q6: Local Dev for Edge Functions with Real GitHub Repos

**Recommended pattern: `.env` file passed via `--env-file` to `supabase functions serve`.**

This is the official Supabase CLI approach. No Docker secrets, no direnv required.

**Setup:**

```bash
# backend/supabase/functions/.env (gitignored)
GITHUB_PAT=github_pat_xxx
GITHUB_REPO=jonasockerman/nutrition_system
ANTHROPIC_API_KEY=sk-ant-xxx
```

```bash
# .gitignore
backend/supabase/functions/.env
backend/.env
```

**Run locally:**

```bash
supabase functions serve --env-file ./supabase/functions/.env
```

Or use the shared path that Supabase CLI auto-loads:

```bash
# supabase/functions/.env is auto-loaded when you run:
supabase start
supabase functions serve
```

**Push to prod:**

```bash
supabase secrets set --env-file ./supabase/functions/.env
# Individual override:
supabase secrets set GITHUB_PAT=github_pat_yyy
```

No re-deploy needed after `secrets set` — secrets are available immediately. [VERIFIED: https://supabase.com/docs/guides/functions/secrets]

**Is the PAT ever on disk in plaintext?** Yes — in `supabase/functions/.env` (gitignored). This is the standard pattern. It is equivalent to how `.env` files work in every Node/Deno project. The security boundary is:
- File is gitignored (never committed)
- Production PAT is stored in Supabase secrets (encrypted at rest, never in logs)
- `.env.example` documents required keys with empty values

**No direnv, Docker secrets, or vault needed** for a personal 2-user project. [CITED: https://supabase.com/docs/guides/functions/secrets, https://github.com/supabase/supabase/blob/master/examples/edge-functions/README.md]

**Confidence:** HIGH — verified against official Supabase secrets docs.

---

## Bonus Findings

### Anthropic Model Recommendation for v1.1

The 6 slash commands (`/log-day`, `/prep-today`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal`) are **structured text generation tasks with moderate context** (library files + tracker snippets). They are not agentic loops, do not require extended thinking, and have predictable input sizes (< 50k tokens).

**Recommendation: `claude-sonnet-4-6` as the default.**

| Model | API ID | Input $/MTok | Output $/MTok | Notes |
|-------|--------|-------------|--------------|-------|
| Claude Sonnet 4.6 | `claude-sonnet-4-6` | $3 | $15 | RECOMMENDED — best speed/cost/quality for structured generation |
| Claude Opus 4.7 | `claude-opus-4-7` | $5 | $25 | 1M token context; only needed if full-library prompts grow huge |
| Claude Haiku 4.5 | `claude-haiku-4-5` | $1 | $5 | Faster/cheaper but quality noticeably lower for structured plans |

Decision D-13 says the app sends the model ID; the proxy passes it through. This is correct. Recommend Jonas hard-codes `claude-sonnet-4-6` in the app for v1.1 and upgrades model IDs without a backend deploy when needed.

**Warning:** `claude-sonnet-4` and `claude-opus-4` (the 20250514 IDs) are deprecated and will be retired June 15, 2026. Do not use them. [VERIFIED: https://platform.claude.com/docs/en/about-claude/models/overview]

**Confidence:** HIGH — verified against official Anthropic model overview page.

---

### Streaming `proxy-anthropic` — Architectural Footprint for Future Phase 8

D-11 defers streaming. What does "adding streaming later" require?

**Non-streaming function body (v1.1 / Phase 5):**

```typescript
// Await full response, return JSON
const response = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST', headers: anthropicHeaders, body: JSON.stringify(requestBody),
});
const data = await response.json();
return new Response(JSON.stringify(data), { headers: { 'Content-Type': 'application/json' } });
```

**Streaming upgrade (Phase 8):**

```typescript
// Forward response.body directly with SSE content-type
const response = await fetch('https://api.anthropic.com/v1/messages', {
  method: 'POST',
  headers: { ...anthropicHeaders, 'anthropic-beta': 'messages-2023-06-01' }, // stream header
  body: JSON.stringify({ ...requestBody, stream: true }),
});
return new Response(response.body, {
  headers: { 'Content-Type': 'text/event-stream', ...corsHeaders },
});
```

**The only contract change is `Content-Type: text/event-stream` vs `application/json`.**

Planning implication for now: the `proxy-anthropic` function signature (URL, auth, request body format) does not change. No database schema or RLS changes needed. Phase 8 only touches the function body. The planner does not need to reserve any schema footprint for streaming now. [CITED: https://github.com/orgs/supabase/discussions/13124]

---

### 2026 Supabase / Anthropic SDK Gotchas

| Gotcha | Impact | Mitigation |
|--------|--------|------------|
| New Supabase publishable/secret keys (`sb_publishable_...`) are NOT JWTs | Sending them via `Authorization: Bearer` → 401 at gateway | Use `apikey` header for project key, `Authorization: Bearer` only for user JWTs |
| `claude-sonnet-4-20250514` and `claude-opus-4-20250514` deprecated, retiring June 15 2026 | Requests will break | Use `claude-sonnet-4-6` and `claude-opus-4-7` |
| `auth.identities` requires `provider_id` field (added silently) | SQL seed missing this field → user can't sign in despite account existing | Always include `auth.identities` insert in seed; admin SDK handles this automatically |
| Edge Function `verify_jwt` — 2026 ES256 key rotation issue | Projects using new asymmetric JWT keys may see 401 from gateway | Check Supabase dashboard signing key settings; use legacy HS256 or ensure gateway is on latest runtime |
| `supabase functions serve` does NOT auto-pick up root `.env` | Secrets missing locally → function crashes | Pass `--env-file supabase/functions/.env` explicitly, or place `.env` at `supabase/functions/.env` |

---

## Standard Stack

### Core

| Library/Tool | Version | Purpose | Notes |
|---|---|---|---|
| Supabase CLI | 2.98.2 | Local dev, migrations, function deploy | [VERIFIED: npm registry] |
| Deno (Edge Runtime) | Supabase-managed | TypeScript runtime for Edge Functions | [CITED: supabase.com/docs/guides/functions] |
| pgcrypto | built-in | Password hashing in seed SQL | Pre-enabled in all Supabase projects |
| GitHub REST API | 2022-11-28 | Contents API for file CRUD | Use `X-GitHub-Api-Version: 2022-11-28` header |

### No External Libraries Needed for `github-fs`

Use raw `fetch` (Deno built-in). No Octokit, no esm.sh dependency.

### Anthropic API

Call `https://api.anthropic.com/v1/messages` directly via `fetch` from the Edge Function. No SDK needed for the proxy pattern — the proxy just forwards the body verbatim.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JWT verification | Custom token parsing | Supabase gateway `verify_jwt = true` | Gateway handles it before your code runs |
| Password hashing | Custom bcrypt/sha | `crypt(..., gen_salt('bf'))` via pgcrypto OR admin SDK | pgcrypto is audited; salt handling is non-trivial |
| Auth identity linking | Custom email-provider table | `auth.identities` + `auth.users` via admin SDK | Supabase's internal schema is versioned and evolves |
| Rate limiting per user | Redis / external counter | `api_usage` Postgres table (D-25) | For 2 users, a table row is perfectly sufficient |

---

## Common Pitfalls

### Pitfall 1: Seeding `auth.users` via plain SQL INSERT

**What goes wrong:** Password is stored as plaintext in `encrypted_password`, authentication fails with "Invalid credentials".
**Why it happens:** `encrypted_password` must be a bcrypt hash. Postgres doesn't auto-hash on insert.
**How to avoid:** Use `crypt(password, gen_salt('bf'))` from pgcrypto, or use the admin SDK.
**Warning signs:** User account appears in Supabase Studio but sign-in always returns 400.

### Pitfall 2: Missing `auth.identities` row

**What goes wrong:** User exists in `auth.users`, password is correct, but Supabase returns "Invalid login credentials".
**Why it happens:** Supabase added a requirement that every email-provider user has a row in `auth.identities`.
**How to avoid:** Always insert the corresponding `auth.identities` row when seeding. Admin SDK does this automatically.
**Warning signs:** Sign-in fails despite correct password and confirmed email.

### Pitfall 3: Sending Supabase API key as Bearer token

**What goes wrong:** Edge Function returns 401 even though the key is correct.
**Why it happens:** Publishable/secret keys (`sb_publishable_...`) are not JWTs. The gateway JWT check rejects them when sent in `Authorization: Bearer`.
**How to avoid:** Send user session JWT in `Authorization: Bearer`; send project key in `apikey` header.
**Warning signs:** 401 in local functions serve works fine but production fails (or vice versa due to different key formats).

### Pitfall 4: Profiles trigger throwing on seed-time insert

**What goes wrong:** The `on_auth_user_created` trigger fires when the seed inserts into `auth.users`. If the profiles table doesn't exist yet (migration ordering issue), the trigger fails.
**Why it happens:** Migrations run before the seed. If the trigger migration runs before the profiles table migration, it will reference a non-existent table.
**How to avoid:** Ensure migration order puts `CREATE TABLE profiles` before `CREATE TRIGGER on_auth_user_created`. With lexicographic ordering (`0001_initial`, `0002_profiles`, `0003_api_usage`) this is natural.
**Warning signs:** `supabase db reset` fails with "relation public.profiles does not exist".

### Pitfall 5: GitHub write returns 409 because app cached stale SHA

**What goes wrong:** Write fails with 409 Conflict on first attempt after a different device wrote the same file.
**Why it happens:** The app cached the SHA from a previous read; another write invalidated it.
**How to avoid:** Implement the 3-retry re-fetch loop documented in Q3. Return the new SHA in the write response so the app can update its cache.
**Warning signs:** Sporadic 409s that succeed on retry.

---

## Architecture Patterns

### Recommended `backend/` Directory Layout

```
backend/
  .env.example              # documents required env vars (no values)
  .gitignore                # ignores .env
  supabase/
    config.toml
    migrations/
      0001_initial.sql      # enable extensions (pgcrypto, uuid-ossp)
      0002_profiles.sql     # profiles table + trigger + RLS
      0003_api_usage.sql    # api_usage table
    functions/
      proxy-anthropic/
        index.ts
        deno.json
      github-fs/
        index.ts
        deno.json
      _shared/
        github.ts           # typed fetch wrappers for Contents API
        usage.ts            # api_usage read/increment helpers
    seed.sql                # idempotent: inserts Jonas + Farva (reads from env)
    functions/.env          # gitignored; GITHUB_PAT, ANTHROPIC_API_KEY, etc.
    functions/.env.example  # committed; empty values for documentation
  scripts/
    seed-users.ts           # post-deploy admin SDK script (Approach B, recommended)
    smoke/
      proxy-anthropic.sh    # happy-path + 401-path curl tests
      github-fs-read.sh
      github-fs-write.sh
  README.md                 # backend dev setup guide
```

### Migration Ordering

Lexicographic (`0001`, `0002`, `0003`) is the correct and boring convention. Matches Supabase CLI behavior on `db reset`. No gaps between numbers needed for Phase 5 since all three migrations are created together.

### Smoke Test Script Style

Bash + curl is the right choice (D-26). It requires no runtime setup, works everywhere, and is immediately readable by Jonas. Deno fetch scripts would require Deno installed locally and are more complex to compose.

```bash
#!/usr/bin/env bash
# scripts/smoke/proxy-anthropic.sh
set -euo pipefail
source "$(dirname "$0")/../../.env"

JWT=$(curl -s -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"jonas@nutrition-system.local\",\"password\":\"$JONAS_PASSWORD\"}" \
  | jq -r '.access_token')

echo "=== Happy path ==="
curl -s -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
  -H "Authorization: Bearer $JWT" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":50,"messages":[{"role":"user","content":"say hi"}]}' \
  | jq .

echo "=== No JWT → expect 401 ==="
curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}'
```

### Health Edge Function

A minimal `health` function (`GET /functions/v1/health` → `{"status":"ok"}`) with `verify_jwt = false` is a useful addition. It lets the Flutter app do a connectivity check without requiring a signed-in session. Costs nothing to implement (< 5 lines). Recommend the planner include it as an optional Wave 1 or Wave 0 task.

---

## Decisions the Researcher Recommends Locking

These were listed as "Claude's Discretion" but research now has clear answers:

| Decision | Recommendation | Basis |
|----------|---------------|-------|
| Migration naming | `0001_initial.sql`, `0002_profiles.sql`, `0003_api_usage.sql` | Lexicographic order is Supabase CLI default; no gaps needed |
| User seeding approach | Post-deploy TypeScript script using admin SDK (`scripts/seed-users.ts`) | Avoids `auth.identities` schema fragility; idiomatic; explicitly recommended by community |
| Octokit vs raw fetch | Raw `fetch` | Simpler, no bundle overhead, 3 endpoints is too small to justify an SDK |
| Smoke test style | Bash + curl | No runtime dependency; readable; standard for backend smoke tests |
| Health function | Add it | Trivial cost, useful for Flutter connectivity checks |

---

## Open Risks

| Risk | Severity | Notes |
|------|----------|-------|
| Supabase internal `auth.users` schema evolves again (e.g., new required column) | LOW | Admin SDK wraps this; only relevant if using direct SQL seed |
| ES256 JWT rotation bug in gateway (issues #42244, #42810, #42534) | MEDIUM | If new Supabase project generates ES256 keys by default, `verify_jwt = true` may 401 valid sessions. Monitor on first deploy; fallback is legacy HS256 config. |
| `supabase db reset` runs `seed.sql` and re-fires the profiles trigger | LOW | Idempotent seed with `ON CONFLICT DO NOTHING` + idempotent trigger (INSERT into profiles) prevents double rows. Document this in README. |
| GitHub fine-grained PAT scope — `contents:write` on private repo | LOW | Must be created by Jonas, scoped to `nutrition_system` repo only. Needs documentation in `backend/README.md`. |
| Rate limit on Anthropic API (soft cap in D-15) | LOW | 100 req/day counter prevents runaway usage. Counter must be checked before forwarding, not after. |

---

## Environment Availability

| Dependency | Required By | Available | Notes |
|------------|------------|-----------|-------|
| Supabase CLI | All backend tasks | Verify at phase start | Install: `npm install -g supabase` |
| Docker Desktop | `supabase start` (local Postgres) | Likely installed (dev machine) | Required for local Supabase stack |
| Deno | Local function testing (optional) | Not required — `supabase functions serve` bundles its own Deno | No separate install needed |
| jq | Smoke test scripts | Standard macOS tool | Pre-installed on macOS |
| GitHub fine-grained PAT | `github-fs` function | Must be created by Jonas | Scope: `contents:write` on `nutrition_system` repo |
| Anthropic API key | `proxy-anthropic` function | Jonas already has one | Store in `supabase secrets set` |
| Supabase project (cloud) | All backend work | Not yet created | Create at supabase.com; free tier sufficient |

---

## Validation Architecture

Per config: `workflow.nyquist_validation` not set to false — treating as enabled.

D-26 specifies manual curl smoke tests only (no automated framework). The test map below reflects this.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | Manual bash + curl scripts |
| Config file | none (scripts in `backend/scripts/smoke/`) |
| Quick run command | `bash backend/scripts/smoke/proxy-anthropic.sh` |
| Full suite command | `bash backend/scripts/smoke/proxy-anthropic.sh && bash backend/scripts/smoke/github-fs-read.sh && bash backend/scripts/smoke/github-fs-write.sh` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Command | File Exists? |
|--------|----------|-----------|---------|-------------|
| BE-01 | Jonas can sign in | manual-smoke | `supabase auth sign-in --email jonas@nutrition-system.local` | Wave 0 |
| BE-01 | Farva can sign in | manual-smoke | `supabase auth sign-in --email farva@nutrition-system.local` | Wave 0 |
| BE-01 | Profile row exists for each user | manual-inspect | Supabase Studio → `profiles` table | — |
| BE-02 | Authenticated POST → 200 + Anthropic response | manual-smoke | `bash scripts/smoke/proxy-anthropic.sh` | Wave 0 |
| BE-02 | Unauthenticated POST → 401 | manual-smoke | Included in smoke script | Wave 0 |
| BE-02 | Over-cap → 429 | manual-smoke | Manual: insert 100 rows in `api_usage`, then call | — |
| BE-03 | `github-fs` read → file content + SHA | manual-smoke | `bash scripts/smoke/github-fs-read.sh` | Wave 0 |
| BE-03 | `github-fs` write → commit on `main` | manual-smoke | `bash scripts/smoke/github-fs-write.sh` | Wave 0 |
| BE-03 | `github-fs` write with wrong SHA → 409 | manual-smoke | Included in write smoke script | Wave 0 |
| BE-03 | `github-fs` path with `..` → 400 | manual-smoke | Negative path in write smoke script | Wave 0 |
| BE-04 | `profiles` auto-populated on seed | manual-inspect | Supabase Studio after seed runs | — |
| BE-04 | RLS: user can only select own row | manual-smoke | Sign in as Jonas, attempt to read Farva's row | — |

### Wave 0 Gaps

- [ ] `backend/scripts/smoke/proxy-anthropic.sh` — covers BE-02 happy + 401 paths
- [ ] `backend/scripts/smoke/github-fs-read.sh` — covers BE-03 read + list
- [ ] `backend/scripts/smoke/github-fs-write.sh` — covers BE-03 write + 409 + path validation
- [ ] `backend/scripts/seed-users.ts` — covers BE-01 (seed invocation)
- [ ] `backend/README.md` — documents full local setup so smoke tests can be run by Jonas

---

## Security Domain

`security_enforcement` not set to false in config — treating as enabled.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | Yes | Supabase Auth (email + password, bcrypt-hashed) |
| V3 Session Management | Yes | Supabase JWT (auto-refresh via supabase-js in app) |
| V4 Access Control | Yes | RLS on `profiles`; path validation in `github-fs` |
| V5 Input Validation | Yes | Path sanitization in `github-fs` (D-21: no `..`, no `.git/`) |
| V6 Cryptography | Yes | pgcrypto bcrypt for password hashing; never hand-rolled |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| GitHub PAT exposure via logs | Information Disclosure | Key in Supabase secrets only; `proxy-anthropic` and `github-fs` log count + latency, not headers or keys |
| SSRF via `proxy-anthropic` path | Elevation of Privilege | Only forward to `api.anthropic.com`; hard-code target URL, don't accept it from request body |
| Path traversal in `github-fs` | Tampering | Reject any path containing `..` or starting with `.git/` (D-21) |
| Broken object access on `profiles` | Elevation of Privilege | RLS `auth.uid() = id` on SELECT; update restricted to `display_name` column |
| Over-cap Anthropic spend | Denial of Wallet | `api_usage` counter, 429 on > 100 req/day per user (D-15) |

**Note on SSRF:** D-10 says "forwards request body verbatim" — but the target URL (`api.anthropic.com`) must be hard-coded server-side. Do not accept the target URL from the app request. Confirm this is the implementation intent for Phase 5.

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Supabase free tier is sufficient for 2-user personal use throughout v1.1 | Standard Stack | If free tier has Edge Function invocation limits that affect daily use, upgrade path is straightforward (Pro plan) |
| A2 | Jonas's GitHub account owns the `nutrition_system` repo and can create fine-grained PATs | Q3 / `github-fs` | If repo is under an org, PAT scope rules differ |
| A3 | `supabase functions serve` with `--env-file` works for calling the live GitHub API (no sandboxing) | Q6 | If CLI sandbox mode blocks outbound fetch, tests would fail locally |

All other claims in this research are tagged VERIFIED (from official docs or registry) or CITED (from official documentation pages).

---

## Sources

### Primary (HIGH confidence)
- [Supabase Securing Edge Functions](https://supabase.com/docs/guides/functions/auth) — JWT gateway behavior, `verify_jwt` config
- [Supabase Edge Function Configuration](https://supabase.com/docs/guides/functions/function-configuration) — `config.toml` syntax
- [Supabase Environment Variables / Secrets](https://supabase.com/docs/guides/functions/secrets) — `.env` file location, `supabase secrets set`
- [Supabase Managing User Data](https://supabase.com/docs/guides/auth/managing-user-data) — `on_auth_user_created` trigger pattern
- [Supabase Auth Admin createUser](https://supabase.com/docs/reference/javascript/auth-admin-createuser) — admin SDK seeding
- [GitHub REST API Rate Limits](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api) — 5,000 req/hr primary limit, secondary limits
- [GitHub Repository Contents API](https://docs.github.com/en/rest/repos/contents) — write semantics, SHA requirement
- [Anthropic Models Overview](https://platform.claude.com/docs/en/about-claude/models/overview) — current model IDs, pricing, deprecations
- [Supabase Edge Functions Architecture](https://supabase.com/docs/guides/functions/architecture) — ESZip format, cold start
- npm registry — `@octokit/rest` v22.0.1, `supabase` CLI v2.98.2 [VERIFIED]

### Secondary (MEDIUM confidence)
- [GitHub Discussion #35391: Seeding auth.users](https://github.com/orgs/supabase/discussions/35391) — community consensus on SQL seed fragility
- [GitHub Discussion #1323: How to insert auth.users in seed](https://github.com/orgs/supabase/discussions/1323) — idempotency patterns
- [Supabase Discussion #13124: Client-side SSE](https://github.com/orgs/supabase/discussions/13124) — streaming response shape change
- [Auth Hooks Discussion #39576](https://github.com/orgs/supabase/discussions/39576) — confirmation that post-user-creation hook does not exist yet
- [2026 API Keys Discussion #41834](https://github.com/orgs/supabase/discussions/41834) — new key format gotcha
- [Paul Laros: Seeding users with SQL](https://laros.io/seeding-users-in-supabase-with-a-sql-seed-script) — pgcrypto + `auth.identities` pattern

### Tertiary (LOW confidence — flag for validation)
- WebSearch results on NxCode/tech-insider for model benchmarks — cross-referenced against official Anthropic docs; official docs took precedence

---

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH — all tools verified against registry and official docs
- Seeding pattern: HIGH — multiple sources converge on admin SDK + pgcrypto
- JWT gateway behavior: HIGH — official docs confirm pre-execution rejection
- Architecture patterns: HIGH — all based on official Supabase guides
- GitHub rate limits: HIGH — official GitHub docs
- 409 retry: MEDIUM — no official retry recipe; derived from first principles + community
- Octokit vs fetch: MEDIUM-HIGH — reasoned from bundle evidence; no direct 2026 benchmark

**Research date:** 2026-05-11
**Valid until:** 2026-08-11 (stable ecosystem; Supabase releases are regular but rarely breaking for this surface area)
