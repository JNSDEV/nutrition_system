# Backend — Nutrition System

Supabase-backed API layer for the v1.1 mobile app.

## Prerequisites

- [Supabase CLI](https://supabase.com/docs/guides/cli) v2.x (`npm install -g supabase`)
- Docker Desktop (running)
- `jq` (for smoke test scripts)
- Node.js v20+ (for seed-users.ts)

## First-time Setup

1. Copy `.env.example` → `.env` and fill in all values.
2. Copy `supabase/functions/.env.example` → `supabase/functions/.env` and fill in API keys.
3. Link CLI to cloud project: `supabase link --project-ref <PROJECT_REF>`
4. Start local stack: `supabase start`
5. Apply migrations: `supabase db reset`
6. Seed users (first time, or after reset): `npx ts-node scripts/seed-users.ts`

## Local Development

```bash
# Start local Supabase stack (Postgres + Auth + Studio)
supabase start

# Serve Edge Functions locally with secrets
supabase functions serve --env-file ./supabase/functions/.env

# Reset DB and re-apply all migrations (destructive!)
supabase db reset
```

## Deploying to Cloud

```bash
# Push migrations
supabase db push

# Deploy a single function
supabase functions deploy proxy-anthropic
supabase functions deploy github-fs
supabase functions deploy health

# Set/update secrets
supabase secrets set --env-file ./supabase/functions/.env
```

## Smoke Tests

```bash
# Source .env first
source .env

bash scripts/smoke/proxy-anthropic.sh
bash scripts/smoke/github-fs-read.sh
bash scripts/smoke/github-fs-write.sh
```

## GitHub Fine-Grained PAT Setup

The `github-fs` function needs a fine-grained PAT with **Contents: Read and Write** on the
`nutrition_system` repo only.

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Generate new token: resource owner = your account, repository = `nutrition_system`, permissions = Contents: Read and write
3. Copy the token → paste into `supabase/functions/.env` as `GITHUB_PAT`
4. Push to cloud: `supabase secrets set GITHUB_PAT=<token>`

## ES256 JWT Verification (if you see 401 errors after deploy)

Supabase introduced ES256 JWT signing by default in 2026. If Edge Functions return 401 for
valid sessions, check: Supabase Dashboard → Settings → Auth → JWT Settings → Signing algorithm.
If set to ES256 and functions fail, temporarily switch to HS256 (legacy) OR ensure your CLI is on
v2.98.2+ which includes the ES256 fix.
