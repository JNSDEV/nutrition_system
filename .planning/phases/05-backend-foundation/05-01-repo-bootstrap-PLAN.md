---
phase: 05-backend-foundation
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - backend/.gitignore
  - backend/.env.example
  - backend/supabase/config.toml
  - backend/supabase/functions/.env.example
  - backend/README.md
autonomous: false
requirements:
  - BE-01
  - BE-02
  - BE-03
  - BE-04
last_updated: 2026-05-11

must_haves:
  truths:
    - "backend/ directory exists and is committed to the repo"
    - "supabase init has been run; config.toml exists"
    - "Supabase cloud project is provisioned and CLI is linked to it"
    - "Secrets are gitignored; .env.example documents all required vars"
    - "backend/README.md explains the local dev workflow"
    - "node_modules/ is gitignored from the start so plan 05-03 does not need to add it"
  artifacts:
    - path: "backend/supabase/config.toml"
      provides: "Supabase CLI project config with verify_jwt=true for both functions"
    - path: "backend/.env.example"
      provides: "Template of required env vars (no values)"
    - path: "backend/supabase/functions/.env.example"
      provides: "Template of function secrets (no values)"
    - path: "backend/.gitignore"
      provides: "Gitignore rules covering .env files and node_modules/"
    - path: "backend/README.md"
      provides: "Setup guide: install CLI, link project, apply migrations, run functions"
  key_links:
    - from: "Supabase CLI (local)"
      to: "Supabase cloud project"
      via: "supabase link --project-ref <ref>"
      pattern: "linked to remote project"

user_setup:
  - service: supabase
    why: "Supabase cloud project must exist before CLI can link to it"
    dashboard_config:
      - task: "Create a new Supabase project (free tier) at supabase.com"
        location: "supabase.com → New project → choose region closest to you"
      - task: "Copy the project reference ID (found in Settings → General)"
        location: "Supabase Dashboard → Project → Settings → General → Reference ID"
      - task: "Copy the anon key and service-role key"
        location: "Supabase Dashboard → Project → Settings → API → Project API keys"
      - task: "Copy the database password (set at project creation)"
        location: "Supabase Dashboard → Project → Settings → Database → Database password"
    env_vars:
      - name: SUPABASE_URL
        source: "Supabase Dashboard → Settings → API → Project URL"
      - name: SUPABASE_ANON_KEY
        source: "Supabase Dashboard → Settings → API → anon public"
      - name: SUPABASE_SERVICE_ROLE_KEY
        source: "Supabase Dashboard → Settings → API → service_role secret"
      - name: DATABASE_URL
        source: "Supabase Dashboard → Settings → Database → Connection string (URI mode)"
      - name: JONAS_PASSWORD
        source: "Choose a strong password for Jonas's account"
      - name: FARVA_PASSWORD
        source: "Choose a strong password for Farva's account"
---

<objective>
Bootstrap the `backend/` directory: initialize Supabase CLI, create the directory structure, commit `.gitignore` and `.env.example` files, and link the CLI to the cloud Supabase project Jonas has provisioned.

Purpose: Every subsequent plan in this phase depends on a linked Supabase CLI project with secrets gitignored. This plan creates that foundation before any code is written.

Output: A committed `backend/` skeleton with `config.toml`, `.env.example`, function `.env.example`, `.gitignore` (covering `.env` files and `node_modules/`), and `README.md`. The CLI is linked to the cloud project and `supabase status` reports the project ref.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/phases/05-backend-foundation/05-CONTEXT.md
@.planning/phases/05-backend-foundation/05-RESEARCH.md
</context>

<tasks>

<task type="checkpoint:human-action" gate="blocking">
  <name>Task 0: Provision Supabase cloud project and gather credentials</name>
  <what-built>Nothing yet — this step gathers the credentials Claude cannot create on your behalf.</what-built>
  <how-to-verify>
    1. Go to supabase.com and sign in (create account if needed).
    2. Create a new project (free tier). Choose a region. Save the database password somewhere safe.
    3. Wait for the project to finish provisioning (~2 min).
    4. Go to Settings → General → copy the "Reference ID" (looks like: abcdefghijklmnop).
    5. Go to Settings → API → copy:
       - "Project URL" (SUPABASE_URL)
       - "anon public" key (SUPABASE_ANON_KEY)
       - "service_role" key (SUPABASE_SERVICE_ROLE_KEY) — keep this secret
    6. Go to Settings → Database → Connection string → URI mode → copy the full URL (DATABASE_URL).
    7. Choose passwords for Jonas and Farva (you'll need these for the seed script in plan 05-03).
    8. Verify Supabase CLI is installed: `supabase --version` (should show 2.x). If not: `npm install -g supabase`.
    9. Verify Docker Desktop is running (required for local Supabase stack): `docker info`.
  </how-to-verify>
  <resume-signal>Type "ready" with the project reference ID, e.g. "ready abcdefghijklmnop"</resume-signal>
</task>

<task type="auto">
  <name>Task 1: Create backend/ directory structure and Supabase init</name>
  <files>
    backend/.gitignore
    backend/.env.example
    backend/supabase/config.toml
    backend/supabase/functions/.env.example
  </files>
  <action>
    Run `supabase init` inside the `backend/` directory to generate `supabase/config.toml`. Then create the supporting files.

    Steps:
    1. `mkdir -p backend/supabase/migrations backend/supabase/functions/_shared backend/scripts/smoke`
    2. `cd backend && supabase init` (creates `supabase/config.toml`)
    3. Create `backend/.gitignore` with these rules:
       ```
       .env
       .env.local
       supabase/functions/.env
       node_modules/
       ```
       NOTE: `node_modules/` is included here so plan 05-03 (which installs npm packages for the seed script) does not need to add it separately.
    4. Create `backend/.env.example` with all required env vars documented (no values):
       ```
       # Supabase project
       SUPABASE_URL=
       SUPABASE_ANON_KEY=
       SUPABASE_SERVICE_ROLE_KEY=

       # Database (for seed script)
       DATABASE_URL=

       # User passwords (for seed-users.ts)
       JONAS_PASSWORD=
       FARVA_PASSWORD=
       ```
    5. Create `backend/supabase/functions/.env.example`:
       ```
       # Edge Function secrets (copy to .env, then: supabase secrets set --env-file ./supabase/functions/.env)
       ANTHROPIC_API_KEY=
       GITHUB_PAT=
       GITHUB_REPO=jonasockerman/nutrition_system
       SUPABASE_URL=
       SUPABASE_SERVICE_ROLE_KEY=
       ```
    6. Edit `backend/supabase/config.toml` to add function config sections (append after generated content):
       ```toml
       [functions.proxy-anthropic]
       verify_jwt = true

       [functions.github-fs]
       verify_jwt = true

       [functions.health]
       verify_jwt = false
       ```

    IMPORTANT: The `supabase/functions/.env` file (not the `.env.example`) must be gitignored. Confirm this is in `.gitignore` before proceeding. Also confirm `node_modules/` is in `.gitignore` — this prevents accidentally committing npm dependencies installed by plan 05-03.
  </action>
  <verify>
    `ls backend/supabase/config.toml` exits 0.
    `grep -c "verify_jwt" backend/supabase/config.toml` returns 3.
    `grep -c "supabase/functions/.env" backend/.gitignore` returns 1.
    `grep -c "node_modules" backend/.gitignore` returns 1.
  </verify>
  <done>
    `backend/supabase/config.toml` exists with `verify_jwt = true` for proxy-anthropic and github-fs, and `verify_jwt = false` for health. `.gitignore` covers all `.env` variants and `node_modules/`. `.env.example` documents all required variables.
  </done>
</task>

<task type="auto">
  <name>Task 2: Link CLI to cloud project and write README</name>
  <files>
    backend/README.md
  </files>
  <action>
    Link the Supabase CLI to the cloud project using the reference ID from Task 0.

    Steps:
    1. From the `backend/` directory: `supabase link --project-ref <REF_FROM_TASK_0>`
       (CLI will prompt for the database password — enter the one saved in Task 0)
    2. Verify the link: `supabase status` — should show the project ref and confirm the connection.
    3. Create `backend/README.md` documenting the full local dev setup:

    ```markdown
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
    ```
  </action>
  <verify>
    `supabase status` (from backend/ dir) shows the linked project ref without error.
    `ls backend/README.md` exits 0.
  </verify>
  <done>
    CLI is linked to the cloud Supabase project (`supabase status` confirms). `backend/README.md` exists with setup instructions including the ES256 JWT fallback note and GitHub PAT setup steps (per research-flagged ES256 risk and D-17).
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: Verify cloud project and CLI link</name>
  <what-built>Supabase CLI linked to cloud project; backend/ directory scaffolded and committed.</what-built>
  <how-to-verify>
    1. Run `cd backend && supabase status` — should show your project URL and ref without errors.
    2. Open Supabase Studio (the URL from `supabase status`) → confirm the project dashboard loads.
    3. Run `git status` in the repo root → `backend/` files should appear as untracked (no .env files, no node_modules/).
    4. Check that `backend/supabase/functions/.env` does NOT appear in git status (gitignored).
    5. Check that `backend/.gitignore` contains `node_modules/`.
    6. Commit the backend skeleton: `git add backend/ && git commit -m "feat(05-01): backend/ skeleton — supabase init + gitignore + README"`
  </how-to-verify>
  <resume-signal>Type "verified" when the project is linked and the commit is made.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| developer workstation → Supabase cloud | CLI sends migrations and secrets over HTTPS; project ref and keys must not be committed |
| `.env` files → git | gitignore prevents accidental commit of secrets |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-01-01 | Information Disclosure | backend/.env | mitigate | `.gitignore` covers `.env`, `supabase/functions/.env`, and `node_modules/`; `.env.example` has no values |
| T-05-01-02 | Information Disclosure | Supabase service-role key | mitigate | Key lives in `.env` (gitignored) only; not committed, not in README examples |
| T-05-01-03 | Tampering | supabase/config.toml | accept | Config is committed to git; no secrets in config.toml; verify_jwt settings are public configuration |
</threat_model>

<verification>
- `supabase status` from backend/ reports the correct project ref
- `backend/supabase/config.toml` has `verify_jwt = true` for proxy-anthropic and github-fs
- No `.env` or `.env.local` or `supabase/functions/.env` files appear in `git status`
- `backend/.gitignore` contains `node_modules/` (prevents accidental commit of npm deps from plan 05-03)
- `backend/README.md` covers ES256 JWT fallback (required by research risk register)
</verification>

<success_criteria>
Supabase CLI is linked to a provisioned cloud project. The `backend/` directory structure exists and is committed. Secrets and `node_modules/` are gitignored and `.env.example` files document what is needed. Any developer (including Jonas after a fresh clone) can follow `backend/README.md` to reproduce the local setup.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-01-repo-bootstrap-SUMMARY.md` using the summary template.
</output>
