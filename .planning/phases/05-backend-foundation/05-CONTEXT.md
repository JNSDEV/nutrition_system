---
title: Phase 5 — Backend Foundation Context
category: planning
phase: 05
milestone: v1.1
source: <requirements-derived>
last_updated: 2026-05-10
---

# Phase 5: Backend Foundation - Context

**Gathered:** 2026-05-10
**Status:** Ready for research → planning
**Source:** Derived from REQUIREMENTS.md (BE-01..BE-04) + v1.1 milestone discussion. No discuss-phase needed — milestone scope already settled.

<domain>
## Phase Boundary

Stand up the Supabase backend that Phases 6–10 will depend on. This phase ships **no UI** — only backend infrastructure verified via `curl`/Supabase Studio:

| Deliverable | What it is |
|------|------|
| Supabase project (cloud + local CLI workflow) | Provisioned project; CLI-managed migrations and Edge Function deploys |
| `auth.users` + 2 seeded accounts | Jonas + Farva can sign in; passwords known to Jonas |
| `profiles` table | Linked to `auth.users` via FK; auto-populated on signup; columns: `id`, `display_name`, `tracker_dir`, `is_owner`, `created_at` |
| Edge Function `proxy-anthropic` | Authenticated POST → forwards to `api.anthropic.com/v1/messages` with server-held Anthropic key; streams response back |
| Edge Function `github-fs` | Authenticated requests: `read` (path → file content), `list` (dir → entries), `write` (path + content → commit with user attribution); server-held GitHub fine-grained PAT |
| RLS policies | `profiles` table: user can read/update only their own row; nobody can delete profiles or change `is_owner` |

**NOT in this phase:** Flutter app (Phase 6), chat UI (Phase 7), command dispatcher Edge Function (Phase 8), multi-profile write restrictions (Phase 9), TestFlight (Phase 10), `proxy-anthropic` streaming if it complicates the MVP — explicitly punt to Phase 8 if needed.

</domain>

<decisions>
## Implementation Decisions

### Project shape
- **D-01:** **Supabase cloud (free tier) + Supabase CLI local dev.** Backend code lives in a top-level `backend/` directory of this same `nutrition_system` repo (single-repo monorepo style). Subfolders: `backend/supabase/` (CLI-tracked migrations + functions), `backend/.env.example` for local dev secrets. Not a separate git repo — the markdown system and the backend ship together.
- **D-02:** **Edge Functions run on Deno** (Supabase default; Deno 1.x). TypeScript only. Use `supabase functions serve` for local dev; `supabase functions deploy` for prod.
- **D-03:** **Migrations are version-controlled** under `backend/supabase/migrations/`. Every schema change = a new migration file. Local dev applies them via `supabase db reset`.

### Auth (BE-01)
- **D-04:** **Email + password** for v1.1. Magic link adds onboarding friction for a 2-user app where Jonas hands Farva a password. Revisit in v1.2 if needed.
- **D-05:** **Seed the 2 users via a migration**, not via Supabase Studio UI. Migration inserts into `auth.users` using Supabase's admin API call (`auth.admin.create_user`) so passwords are hashed by Supabase, not committed in plaintext. The actual password values are NOT in the migration — they live in `backend/.env` (gitignored) and the migration reads them at apply-time. Production seed runs once manually with envs set; the migration is idempotent (skip if email exists).
- **D-06:** **No signup endpoint exposed.** v1.1 has exactly 2 accounts; signup is admin-only. The Flutter app's auth screen has sign-in only, no "create account" link.

### Profiles table (BE-04)
- **D-07:** **Schema:**
  ```sql
  create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    display_name text not null,
    tracker_dir text not null check (tracker_dir in ('jonas','farva')),
    is_owner boolean not null default false,
    created_at timestamptz default now()
  );
  ```
- **D-08:** **Auto-populate via Postgres trigger** on `auth.users` insert. Trigger function reads `raw_user_meta_data` (set by the seed migration) for `display_name` and `tracker_dir`; defaults `is_owner` from `display_name = 'Jonas'`.
- **D-09:** **RLS:**
  - `select`: authenticated users can select their own row only (`auth.uid() = id`).
  - `update`: authenticated users can update `display_name` only on their own row. `tracker_dir` and `is_owner` are admin-only (no policy = blocked).
  - `insert` / `delete`: blocked (only trigger inserts; nobody deletes).

### proxy-anthropic Edge Function (BE-02)
- **D-10:** **POST `/functions/v1/proxy-anthropic`.** Verifies the JWT (Supabase Edge Functions do this automatically via `Authorization: Bearer <jwt>`). Reads request body, forwards to `https://api.anthropic.com/v1/messages` with `x-api-key: $ANTHROPIC_API_KEY` (server env). Returns the Anthropic response verbatim.
- **D-11:** **Non-streaming first.** v1.1 Phase 5 returns the full response in one shot. Streaming can come in Phase 8 if `/log-day` UX demands it. Defer to keep this phase scope tight.
- **D-12:** **Anthropic key lives in Supabase Edge Function secrets** (`supabase secrets set ANTHROPIC_API_KEY=…`). Not in DB. Not in `.env` committed to git. Local dev uses `backend/.env` (gitignored).
- **D-13:** **No model selection logic** — accept whatever `model` the app sends. The app is the one choosing (research will recommend Sonnet/Opus tier for v1.1).
- **D-14:** **Logging:** request count + latency only, no body content. Supabase Logs default is fine.
- **D-15:** **Cost guardrail:** soft cap of 100 requests/day per user via a simple counter table; over the cap returns 429 with a friendly message. Catches a buggy app loop early.

### github-fs Edge Function (BE-03)
- **D-16:** **Three verbs, one function.** POST `/functions/v1/github-fs` with body `{ verb: "read" | "list" | "write", path: string, content?: string, message?: string }`. Single function for the trio rather than three functions — same auth, same client, easier to maintain.
- **D-17:** **GitHub fine-grained PAT** with `contents:write` scope on the single `nutrition_system` repo. Stored as `GITHUB_PAT` in Edge Function secrets. Owner of the PAT = Jonas's GitHub account; the repo is private and lives under his namespace. Repo URL is a `GITHUB_REPO` env var (`owner/repo` format).
- **D-18:** **Commit attribution:** the Edge Function reads the profile of the authenticated user (`display_name`, plus a derived email like `farva@nutrition-system.local` since we don't collect real emails for commit attribution). Commits are made via the GitHub Contents API with `author: { name: display_name, email: derived_email }` and `committer: { name: "nutrition-system-bot", email: "bot@nutrition-system.local" }`. This way git blame shows "Farva" on Farva's commits.
- **D-19:** **One write = one commit.** No batching in this phase. A future Phase 8 command-dispatch may write 2 files (Jonas + Farva daily logs) — at that point we can either commit each separately or use the Trees API for one commit. Decision deferred to Phase 8.
- **D-20:** **Branch: `main` only** for v1.1. No PRs, no branch protection beyond GitHub defaults. Personal use.
- **D-21:** **Path validation:** path must be relative, must not contain `..`, must not start with `.git/`. Backend rejects on violation. Phase 9 will add per-profile path restrictions (MP-01..03); Phase 5 enforces only the generic security guard.
- **D-22:** **List verb returns:** array of `{ name, type: "file" | "dir", size }` for direct children. No recursive listing.
- **D-23:** **Read returns:** `{ path, content (UTF-8 string), sha }`. SHA is needed for subsequent writes (GitHub API conditional update).
- **D-24:** **Write semantics:** if file exists, the request must include the previous `sha` to overwrite; if absent, write creates a new file. Conflicts (sha mismatch) return 409. App handles re-fetch + retry.

### Cost-guardrail counter table
- **D-25:** **Schema:**
  ```sql
  create table public.api_usage (
    user_id uuid references auth.users(id) on delete cascade,
    day date not null,
    proxy_anthropic_calls int not null default 0,
    github_writes int not null default 0,
    primary key (user_id, day)
  );
  ```
  Used by D-15 (Anthropic cap) and a future GitHub write cap if abuse emerges.

### Testing & verification
- **D-26:** **Smoke tests** for this phase = manual `curl` scripts in `backend/scripts/smoke/`. Each Edge Function gets one happy-path script and one negative-path script (e.g. missing JWT → 401). No automated test framework — overkill for v1.1 personal-use backend.
- **D-27:** **Supabase Studio** is acceptable for inspecting `auth.users`, `profiles`, and `api_usage` rows during development.

### Claude's Discretion (planner picks)
- Migration file ordering and naming (`0001_initial.sql`, `0002_profiles.sql`, etc.) — convention up to planner.
- Exact shape of the seed-users migration (Postgres function vs psql `\set` vs `select auth.admin.create_user(...)`) — research should clarify the canonical 2026 pattern.
- Whether `github-fs` uses Octokit (`@octokit/rest`) or raw `fetch` — Octokit adds a dep but is more ergonomic.
- Smoke-test script style (bash + curl vs deno + fetch) — pick one and stick with it.
- Whether to add a `health` Edge Function for ping-style checks — small bonus, planner discretion.

</decisions>

<canonical_refs>
## Canonical References

**Project intent & milestone:**
- `.planning/PROJECT.md` — v1.1 stack and goal
- `.planning/REQUIREMENTS.md` — BE-01, BE-02, BE-03, BE-04 in scope
- `.planning/ROADMAP.md` — Phase 5 success criteria 1–4
- `CLAUDE.md` — project conventions
- `library/cal-02-contract.md` — referenced by future command dispatcher in Phase 8 (not used in Phase 5 directly)

**External docs (research targets):**
- Supabase Edge Functions guide (https://supabase.com/docs/guides/functions)
- Supabase Auth admin API (https://supabase.com/docs/reference/javascript/auth-admin-createuser)
- Supabase migrations (https://supabase.com/docs/guides/cli/local-development#database-migrations)
- GitHub Contents API (https://docs.github.com/en/rest/repos/contents)
- GitHub fine-grained PAT scopes

**Inputs to read (not edited):**
- Existing repo structure: this phase introduces `backend/` directory; nothing existing is touched.

**Frozen — do NOT edit:**
- `.planning/milestones/v1.0-*` (v1.0 archive)
- `.planning/phases/0[1-4]*` and `04.1-*` (v1.0 historical artifacts)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- None. v1.0 is markdown-only; Phase 5 is the first phase to introduce executable code.

### Established Patterns
- This phase establishes the backend conventions for v1.1: monorepo `backend/` directory, Supabase CLI workflow, Deno + TypeScript Edge Functions, version-controlled migrations.
- Secrets pattern: `.env` for local dev (gitignored), `supabase secrets set` for prod. Never commit secrets.

### Integration Points
- Phase 6 (Flutter app) will call `proxy-anthropic` directly during scaffold smoke tests.
- Phase 7 (chat UI) will use `proxy-anthropic` for raw chat (no command logic yet).
- Phase 8 (`/log-day` MVP slice) will introduce a `command-dispatch` Edge Function that orchestrates `github-fs` + `proxy-anthropic`.
- Phase 9 (multi-profile writes) will add a write-path policy check to `github-fs` (currently generic; D-21 mentions this).

</code_context>

<specifics>
## Specific Ideas

### Suggested `backend/` directory layout (D-01 hint)

```
backend/
  .env.example
  .gitignore                  # ignores .env
  supabase/
    config.toml
    migrations/
      0001_initial.sql
      0002_profiles.sql
      0003_api_usage.sql
      0004_seed_users.sql     # idempotent; reads env at apply-time
    functions/
      proxy-anthropic/
        index.ts
        deno.json
      github-fs/
        index.ts
        deno.json
      _shared/
        auth.ts               # JWT helpers
        github.ts             # github client (Octokit or fetch)
        usage.ts              # api_usage counter helper
  scripts/
    smoke/
      proxy-anthropic.sh
      github-fs-read.sh
      github-fs-write.sh
  README.md                   # backend dev setup
```

### Edge Function request/response shapes (D-10, D-16 hint)

**`proxy-anthropic`:** body is forwarded verbatim. Header `Authorization: Bearer <supabase-jwt>` is required.

**`github-fs`:**
```json
// read
{ "verb": "read", "path": "library/meals.md" }
// → { "path": "...", "content": "...", "sha": "..." }

// list
{ "verb": "list", "path": "trackers/jonas/daily/" }
// → { "entries": [{"name":"2026-05-10.md","type":"file","size":1234}, ...] }

// write
{ "verb": "write", "path": "trackers/jonas/daily/2026-05-10.md", "content": "...", "sha": "...prev sha or null...", "message": "log: 2026-05-10" }
// → { "commit_sha": "...", "path": "...", "new_sha": "..." }
```

### Smoke-test happy-path (D-26 hint)

```bash
# proxy-anthropic
JWT=$(supabase auth sign-in --email jonas@... --password ...)
curl -s -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-sonnet-4-6","max_tokens":100,"messages":[{"role":"user","content":"say hi"}]}'
# expect: 200 + valid Anthropic response

# github-fs read
curl -s -X POST "$SUPABASE_URL/functions/v1/github-fs" \
  -H "Authorization: Bearer $JWT" \
  -d '{"verb":"read","path":"library/meals.md"}'
# expect: 200 + content + sha
```

### Open research questions (to be answered before planning)

1. **What is the canonical Supabase 2026 pattern for seeding users via migration** without committing passwords? Specifically: can `auth.admin.create_user` be called from a SQL migration, or must it be a `supabase functions invoke` script run at deploy time?
2. **Octokit vs raw fetch** for `github-fs` — what does the Supabase community recommend on Deno?
3. **GitHub Contents API rate limits** for a 2-user app — at our expected volume (~10 writes/day), are we anywhere near a limit?
4. **How does Supabase handle Edge Function JWT verification automatically?** Confirm that incoming requests without a valid Bearer token never reach the function body.
5. **Best practice for trigger-based profile insertion in Supabase** — is the `on_auth_user_created` trigger pattern still the recommended approach, or did Supabase introduce a higher-level mechanism (e.g. webhooks, declarative auth metadata)?
6. **Local dev workflow:** what's the recommended way to test Edge Functions locally against a real GitHub repo while keeping the PAT off disk in plaintext? (Docker secrets? `direnv` + `.env.local`?)

These questions are the researcher's brief.

</specifics>

<deferred>
## Deferred Ideas

- **Streaming responses from `proxy-anthropic`** — Phase 8 if `/log-day` UX benefits.
- **Trees API for multi-file commits** — Phase 8 (`/log-day` writes both Jonas + Farva).
- **GitHub webhook → Supabase** to invalidate caches when laptop pushes — v1.2 (no caches yet).
- **Real-time subscriptions** (Postgres → app) for cross-device sync notifications — v1.2.
- **Magic-link auth** — D-04 picks password. Reconsider if password hand-off proves clunky in real use.
- **Branch protection / PR-only writes** — v1.2 if more users.
- **Admin signup endpoint** — D-06 says no. Reconsider only if user count grows past 2.
- **Per-profile write restrictions in `github-fs`** — Phase 9 (MP-01..03), not Phase 5.
- **Automated test framework for Edge Functions** — D-26 says smoke scripts. Revisit if Edge Function complexity grows.

</deferred>

---

*Phase: 05-backend-foundation*
*Context derived: 2026-05-10 from REQUIREMENTS.md + v1.1 milestone discussion*
