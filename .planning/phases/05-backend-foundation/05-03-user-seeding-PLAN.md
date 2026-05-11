---
phase: 05-backend-foundation
plan: 03
type: execute
wave: 3
depends_on:
  - "05-02"
files_modified:
  - backend/scripts/seed-users.ts
  - backend/package.json
autonomous: false
requirements:
  - BE-01
  - BE-04
last_updated: 2026-05-11

must_haves:
  truths:
    - "Jonas (jonas@nutrition-system.local) can sign in via Supabase Auth"
    - "Farva (farva@nutrition-system.local) can sign in via Supabase Auth"
    - "profiles table has exactly 2 rows: one for Jonas (is_owner=true, tracker_dir='jonas'), one for Farva (is_owner=false, tracker_dir='farva')"
    - "Seed script is idempotent — re-running after supabase db reset does not error"
    - "No passwords are committed to git"
    - "Farva's signed-in session cannot read Jonas's profiles row (RLS enforced)"
  artifacts:
    - path: "backend/scripts/seed-users.ts"
      provides: "Idempotent admin SDK seeding script for Jonas and Farva"
      contains: "auth.admin.createUser"
    - path: "backend/package.json"
      provides: "ts-node + @supabase/supabase-js dependencies for seed script"
  key_links:
    - from: "backend/scripts/seed-users.ts"
      to: "Supabase auth.admin.createUser()"
      via: "service-role key from SUPABASE_SERVICE_ROLE_KEY env var"
      pattern: "supabase.auth.admin.createUser"
    - from: "auth.admin.createUser() insert into auth.users"
      to: "public.profiles"
      via: "on_auth_user_created trigger (created in 05-02)"
      pattern: "trigger fires on auth.users insert"

user_setup:
  - service: supabase
    why: "Seed script needs SUPABASE_SERVICE_ROLE_KEY to call auth.admin.createUser"
    env_vars:
      - name: SUPABASE_SERVICE_ROLE_KEY
        source: "Supabase Dashboard → Settings → API → service_role (secret)"
      - name: SUPABASE_URL
        source: "Supabase Dashboard → Settings → API → Project URL"
      - name: JONAS_PASSWORD
        source: "Your chosen password for Jonas (store in backend/.env)"
      - name: FARVA_PASSWORD
        source: "Your chosen password for Farva (store in backend/.env)"
---

<objective>
Write and run `backend/scripts/seed-users.ts` — an idempotent TypeScript script using the Supabase admin SDK that creates the Jonas and Farva accounts. Verify 2 rows in `auth.users`, 2 rows in `profiles` (trigger auto-populated), and that RLS blocks cross-user row access.

Purpose: Plans 05-04 and 05-05 require authenticated JWTs to test Edge Functions. Without seeded users, no JWT can be obtained.

Output: `backend/scripts/seed-users.ts` committed; Jonas and Farva accounts exist in both local and cloud Supabase projects; profiles rows auto-populated by the trigger from plan 05-02.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/05-backend-foundation/05-CONTEXT.md
@.planning/phases/05-backend-foundation/05-RESEARCH.md
</context>

<interfaces>
<!-- Supabase admin SDK — key method used by this plan -->
<!-- Source: https://supabase.com/docs/reference/javascript/auth-admin-createuser -->

```typescript
// supabase.auth.admin.createUser() — requires service-role key
const { data, error } = await supabase.auth.admin.createUser({
  email: string,
  password: string,
  email_confirm: boolean,  // set true to skip confirmation email
  user_metadata: {
    display_name: string,  // read by on_auth_user_created trigger
    tracker_dir: string,   // read by on_auth_user_created trigger
  },
})
// Returns: { data: { user: User }, error: AuthError | null }

// To check if user already exists before creating:
const { data: { users }, error } = await supabase.auth.admin.listUsers()
// Returns list of all users; check users.find(u => u.email === email)
```
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write seed-users.ts and package.json</name>
  <files>
    backend/scripts/seed-users.ts
    backend/package.json
  </files>
  <action>
    Create `backend/package.json` for the seed script dependencies:

    ```json
    {
      "name": "nutrition-backend",
      "version": "1.0.0",
      "private": true,
      "scripts": {
        "seed": "ts-node scripts/seed-users.ts"
      },
      "dependencies": {
        "@supabase/supabase-js": "^2.0.0"
      },
      "devDependencies": {
        "ts-node": "^10.0.0",
        "typescript": "^5.0.0",
        "@types/node": "^20.0.0"
      }
    }
    ```

    Create `backend/scripts/seed-users.ts`:

    ```typescript
    #!/usr/bin/env ts-node
    /**
     * seed-users.ts
     * Idempotent: checks if email already exists before creating.
     * Safe to re-run after `supabase db reset`.
     * Passwords read from env — never committed to git.
     *
     * Usage:
     *   cd backend
     *   source .env
     *   npx ts-node scripts/seed-users.ts
     *
     * Required env vars: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY,
     *                    JONAS_PASSWORD, FARVA_PASSWORD
     */

    import { createClient } from '@supabase/supabase-js';

    const SUPABASE_URL = process.env.SUPABASE_URL;
    const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const JONAS_PASSWORD = process.env.JONAS_PASSWORD;
    const FARVA_PASSWORD = process.env.FARVA_PASSWORD;

    if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !JONAS_PASSWORD || !FARVA_PASSWORD) {
      console.error(
        'Missing required env vars: SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, JONAS_PASSWORD, FARVA_PASSWORD'
      );
      process.exit(1);
    }

    // Admin client requires service-role key (bypasses RLS).
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: { autoRefreshToken: false, persistSession: false },
    });

    interface UserSpec {
      email: string;
      password: string;
      display_name: string;
      tracker_dir: string;
    }

    const USERS: UserSpec[] = [
      {
        email: 'jonas@nutrition-system.local',
        password: JONAS_PASSWORD,
        display_name: 'Jonas',
        tracker_dir: 'jonas',
      },
      {
        email: 'farva@nutrition-system.local',
        password: FARVA_PASSWORD,
        display_name: 'Farva',
        tracker_dir: 'farva',
      },
    ];

    async function seedUser(spec: UserSpec): Promise<void> {
      // Idempotency check: list existing users and look for email match.
      // Using listUsers() because admin.getUserByEmail() is not available in all SDK versions.
      const { data: { users }, error: listError } = await supabase.auth.admin.listUsers();
      if (listError) throw new Error(`listUsers failed: ${listError.message}`);

      const existing = users.find((u) => u.email === spec.email);
      if (existing) {
        console.log(`[SKIP] ${spec.email} already exists (id: ${existing.id})`);
        return;
      }

      const { data, error } = await supabase.auth.admin.createUser({
        email: spec.email,
        password: spec.password,
        email_confirm: true,  // skip confirmation email — direct admin seed
        user_metadata: {
          display_name: spec.display_name,
          tracker_dir: spec.tracker_dir,
        },
      });

      if (error) throw new Error(`createUser failed for ${spec.email}: ${error.message}`);
      console.log(`[OK] Created ${spec.email} (id: ${data.user.id})`);
      console.log(`     Trigger should have auto-created profiles row.`);
    }

    async function main(): Promise<void> {
      console.log('Seeding users...');
      for (const spec of USERS) {
        await seedUser(spec);
      }
      console.log('Done.');
    }

    main().catch((err) => {
      console.error(err.message);
      process.exit(1);
    });
    ```

    Then install dependencies:
    ```bash
    cd backend && npm install
    ```

    NOTE: `node_modules/` is already in `backend/.gitignore` (written by plan 05-01 Task 1).
    Do NOT add it again here.
  </action>
  <verify>
    `ls backend/scripts/seed-users.ts` exits 0.
    `ls backend/package.json` exits 0.
    `grep -c "createUser" backend/scripts/seed-users.ts` returns 1.
    `grep -c "listUsers" backend/scripts/seed-users.ts` returns 1.
    `grep -c "node_modules" backend/.gitignore` returns 1.
  </verify>
  <done>
    `seed-users.ts` exists with idempotent existence check (listUsers → find by email), not ON CONFLICT. `package.json` has required dependencies. `node_modules/` is already gitignored from plan 05-01 (confirm, do not re-add).
  </done>
</task>

<task type="auto">
  <name>Task 2: Run seed script against local Supabase; verify trigger fired</name>
  <files></files>
  <action>
    Run the seed script locally (against the local Supabase stack started in plan 05-02).

    IMPORTANT: Use the LOCAL Supabase URL and keys for this step (not cloud). The local stack is running from `supabase start`.

    ```bash
    cd backend
    # Get local keys from supabase status
    supabase status
    # Outputs local SUPABASE_URL (usually http://127.0.0.1:54321) and ANON/SERVICE keys

    # Set env vars for local run:
    export SUPABASE_URL=<local url from supabase status>
    export SUPABASE_SERVICE_ROLE_KEY=<local service_role key from supabase status>
    export JONAS_PASSWORD=<from backend/.env>
    export FARVA_PASSWORD=<from backend/.env>

    npx ts-node scripts/seed-users.ts
    ```

    Expected output:
    ```
    Seeding users...
    [OK] Created jonas@nutrition-system.local (id: <uuid>)
         Trigger should have auto-created profiles row.
    [OK] Created farva@nutrition-system.local (id: <uuid>)
         Trigger should have auto-created profiles row.
    Done.
    ```

    Verify the trigger fired and profiles rows exist:
    ```bash
    # Using psql with local DATABASE_URL (from supabase status → DB URL)
    psql "$LOCAL_DATABASE_URL" -c "select id, display_name, tracker_dir, is_owner from public.profiles;"
    ```
    Expected: 2 rows — Jonas (is_owner=true, tracker_dir='jonas'), Farva (is_owner=false, tracker_dir='farva').

    Verify idempotency by running the script again:
    ```bash
    npx ts-node scripts/seed-users.ts
    ```
    Expected output: both users show `[SKIP] ... already exists`.

    RLS smoke check (run a query as Jonas that tries to read Farva's row):
    ```bash
    # Sign in as Jonas to get a JWT
    JONAS_JWT=$(curl -s -X POST "http://127.0.0.1:54321/auth/v1/token?grant_type=password" \
      -H "apikey: <local anon key>" \
      -H "Content-Type: application/json" \
      -d '{"email":"jonas@nutrition-system.local","password":"'"$JONAS_PASSWORD"'"}' \
      | jq -r '.access_token')

    # Attempt to read profiles as Jonas — should return ONLY Jonas's row
    curl -s "http://127.0.0.1:54321/rest/v1/profiles" \
      -H "Authorization: Bearer $JONAS_JWT" \
      -H "apikey: <local anon key>" \
      | jq 'length'
    # Expected: 1 (not 2 — RLS filters to own row only)
    ```
  </action>
  <verify>
    `psql "$LOCAL_DATABASE_URL" -c "select count(*) from public.profiles"` returns 2.
    RLS check: profiles query with Jonas JWT returns exactly 1 row (not 2).
    Re-running `npx ts-node scripts/seed-users.ts` exits 0 with [SKIP] for both users.
  </verify>
  <done>
    2 rows in `auth.users` + 2 rows in `profiles`. Jonas has `is_owner=true`, `tracker_dir='jonas'`. Farva has `is_owner=false`, `tracker_dir='farva'`. Script is idempotent. RLS blocks Jonas from reading Farva's profile row.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: Verify in Studio and run seed against cloud project</name>
  <what-built>Local seeding complete with profiles trigger verified. Now run against cloud and commit the script.</what-built>
  <how-to-verify>
    LOCAL VERIFICATION:
    1. Open Supabase Studio (local) → Table Editor → `profiles` → confirm 2 rows with correct data.
    2. Open Table Editor → `auth.users` → confirm 2 rows.
    3. Check RLS is enabled on `profiles` (lock icon visible).

    CLOUD SEED:
    4. Run the seed script against the cloud project:
       ```bash
       cd backend
       source .env   # loads SUPABASE_URL (cloud), SUPABASE_SERVICE_ROLE_KEY (cloud), passwords
       npx ts-node scripts/seed-users.ts
       ```
    5. Open Supabase Dashboard (cloud) → Authentication → Users → confirm Jonas and Farva appear.
    6. Open Table Editor (cloud) → `profiles` → confirm 2 rows with correct data.

    COMMIT:
    7. `git add backend/scripts/ backend/package.json backend/package-lock.json backend/.gitignore`
    8. `git commit -m "feat(05-03): seed-users.ts — idempotent admin SDK seeding for Jonas + Farva"`
    9. Confirm `backend/.env` and `backend/supabase/functions/.env` are NOT staged.
  </how-to-verify>
  <resume-signal>Type "verified" when both local and cloud profiles tables show 2 correct rows.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| seed-users.ts → Supabase admin API | Script uses service-role key; must never run in a user context |
| env vars (passwords) → process | Passwords live in .env (gitignored); process.env access only at runtime |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-03-01 | Information Disclosure | SUPABASE_SERVICE_ROLE_KEY in seed script | mitigate | Key read from env var only; never hardcoded; .env is gitignored |
| T-05-03-02 | Information Disclosure | JONAS_PASSWORD / FARVA_PASSWORD | mitigate | Read from env at runtime; never committed; .env.example has blank values only |
| T-05-03-03 | Elevation of Privilege | seed-users.ts uses service-role key | accept | Script is a local/admin-run tool; not exposed as an endpoint; only Jonas runs it |
| T-05-03-04 | Elevation of Privilege | Broken RLS — user reads another's profile | mitigate | Verified in Task 2: Jonas JWT query returns 1 row (own row only) |
</threat_model>

<verification>
- `backend/scripts/seed-users.ts` committed with no passwords or secrets
- 2 rows in `auth.users` locally and in cloud
- 2 rows in `profiles`: Jonas (is_owner=true, tracker_dir='jonas'), Farva (is_owner=false, tracker_dir='farva')
- Script is idempotent: re-running exits 0 with [SKIP] messages
- RLS test: signed-in Jonas sees only 1 profile row
- Cloud Supabase Dashboard → Authentication → Users shows both accounts
- `node_modules/` gitignore confirmed present (from plan 05-01; NOT added by this plan)
</verification>

<success_criteria>
Jonas and Farva can sign in via Supabase Auth (email + password). The `profiles` table is auto-populated by the `on_auth_user_created` trigger with correct `display_name`, `tracker_dir`, and `is_owner` values. RLS is enforced. The seed script is committed, gitignores secrets, and is idempotent.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-03-user-seeding-SUMMARY.md` using the summary template.
</output>
