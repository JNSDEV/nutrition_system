---
phase: 05-backend-foundation
plan: 06
type: execute
wave: 5
depends_on:
  - "05-04"
  - "05-05"
files_modified:
  - backend/supabase/functions/health/index.ts
  - backend/supabase/functions/health/deno.json
autonomous: false
requirements:
  - BE-01
  - BE-02
  - BE-03
  - BE-04

must_haves:
  truths:
    - "GET /functions/v1/health returns {status:'ok'} with no JWT required"
    - "All four ROADMAP Phase 5 success criteria are verified against the cloud project"
    - "ES256 JWT signing behavior is confirmed (or HS256 fallback documented)"
    - "Both Jonas and Farva can sign in against the cloud Supabase project"
    - "The backend/ directory is fully committed with no secrets"
  artifacts:
    - path: "backend/supabase/functions/health/index.ts"
      provides: "Minimal health-check Edge Function for Phase 6 Flutter connectivity checks"
  key_links:
    - from: "health function"
      to: "Flutter app (Phase 6)"
      via: "GET /functions/v1/health with no auth required"
      pattern: "verify_jwt = false"
---

<objective>
Implement the minimal `health` Edge Function (no auth, returns `{status:'ok'}`), deploy it to cloud, and run the full Phase 5 E2E verification against the cloud project. Confirm all four ROADMAP success criteria, check JWT signing algorithm, and close out the phase.

Purpose: `health` is the Flutter app's first call in Phase 6 (connectivity check before sign-in). The E2E check ensures all five functions (proxy-anthropic, github-fs, health) are live and all four success criteria are satisfied before Phase 6 begins.

Output: `health` function deployed. Full E2E smoke test against cloud passes. Phase 5 is complete and committed.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/05-backend-foundation/05-CONTEXT.md
@.planning/phases/05-backend-foundation/05-RESEARCH.md
@.planning/ROADMAP.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Write and deploy health Edge Function</name>
  <files>
    backend/supabase/functions/health/index.ts
    backend/supabase/functions/health/deno.json
  </files>
  <action>
    Create `backend/supabase/functions/health/index.ts`:

    ```typescript
    // health/index.ts
    // Minimal health-check endpoint for Flutter connectivity verification (Phase 6).
    // verify_jwt = false (config.toml) — no auth required.
    import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

    serve((_req: Request) => {
      return new Response(
        JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }),
        { headers: { 'Content-Type': 'application/json' } }
      );
    });
    ```

    Create `backend/supabase/functions/health/deno.json`:
    ```json
    {
      "imports": {}
    }
    ```

    Deploy to cloud:
    ```bash
    cd backend
    supabase functions deploy health
    ```

    Verify:
    ```bash
    curl -s "$SUPABASE_URL/functions/v1/health" | jq .
    # Expected: {"status":"ok","timestamp":"2026-05-11T..."}
    # No Authorization header needed — verify_jwt = false
    ```
  </action>
  <verify>
    `curl -s "$SUPABASE_URL/functions/v1/health" | jq '.status'` returns `"ok"` without any Authorization header.
    Supabase Dashboard → Edge Functions → health → Status: Active.
  </verify>
  <done>
    `health` function deployed and returns `{status:'ok'}` without JWT. `config.toml` has `verify_jwt = false` for health (set in plan 05-01).
  </done>
</task>

<task type="auto">
  <name>Task 2: ES256 JWT signing verification</name>
  <files></files>
  <action>
    Verify JWT signing algorithm to catch the ES256 issue flagged in research before Phase 6 Flutter integration begins.

    Steps:
    1. Sign in as Jonas and inspect the JWT header:
       ```bash
       cd backend
       source .env  # cloud credentials

       JWT=$(curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
         -H "apikey: $SUPABASE_ANON_KEY" \
         -H "Content-Type: application/json" \
         -d '{"email":"jonas@nutrition-system.local","password":"'"$JONAS_PASSWORD"'"}' \
         | jq -r '.access_token')

       # Decode JWT header (base64url decode the first segment)
       echo "$JWT" | cut -d. -f1 | base64 -d 2>/dev/null | jq .
       # Expected output: {"alg":"HS256","typ":"JWT"} or {"alg":"ES256","typ":"JWT"}
       ```

    2. Call `proxy-anthropic` with the JWT to verify the gateway accepts it:
       ```bash
       STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
         -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
         -H "Authorization: Bearer $JWT" \
         -H "apikey: $SUPABASE_ANON_KEY" \
         -H "Content-Type: application/json" \
         -d '{"model":"claude-sonnet-4-6","max_tokens":10,"messages":[{"role":"user","content":"ping"}]}')
       echo "Gateway JWT check: $STATUS"
       ```

    3. CONDITIONAL: If STATUS is 401:
       - Check Supabase Dashboard → Settings → Auth → JWT Settings → Signing Algorithm
       - If showing ES256: change to HS256 (legacy) and re-test
       - Document the finding in `backend/README.md` under the ES256 section already written in plan 05-01
       - If changing to HS256 resolves it: note in the SUMMARY that this project uses HS256 and why

    4. If STATUS is 200: record that JWT signing algorithm is working correctly.
       Note the algorithm (HS256 or ES256) in the SUMMARY.
  </action>
  <verify>
    JWT obtained from sign-in is accepted by `proxy-anthropic` gateway (returns 200 or 4xx from Anthropic, NOT 401 from gateway).
    JWT header algorithm is recorded in plan SUMMARY.
  </verify>
  <done>
    JWT signing algorithm is known and documented. If ES256 caused issues, HS256 fallback is applied and noted. The gateway accepts Jonas's JWT for Edge Function calls.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: Full Phase 5 E2E verification against cloud</name>
  <what-built>health function deployed, JWT signing verified. Run full E2E check against all four ROADMAP success criteria.</what-built>
  <how-to-verify>
    Run these checks in order. Each maps to a ROADMAP success criterion.

    **Criterion 1: Auth — Jonas and Farva can sign in**
    ```bash
    source backend/.env
    # Jonas sign-in
    curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" -H "Content-Type: application/json" \
      -d '{"email":"jonas@nutrition-system.local","password":"'"$JONAS_PASSWORD"'"}' \
      | jq '.user.email'
    # Expected: "jonas@nutrition-system.local"

    # Farva sign-in
    curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" -H "Content-Type: application/json" \
      -d '{"email":"farva@nutrition-system.local","password":"'"$FARVA_PASSWORD"'"}' \
      | jq '.user.email'
    # Expected: "farva@nutrition-system.local"
    ```

    **Criterion 2: proxy-anthropic returns Anthropic response**
    ```bash
    bash backend/scripts/smoke/proxy-anthropic.sh
    # Expected: "All proxy-anthropic smoke tests passed"
    ```

    **Criterion 3: github-fs read/list/write work end-to-end**
    ```bash
    bash backend/scripts/smoke/github-fs-read.sh
    bash backend/scripts/smoke/github-fs-write.sh
    # Expected: both print "All ... smoke tests passed"
    ```

    **Criterion 4: profiles table auto-populated**
    - Open Supabase Dashboard (cloud) → Table Editor → profiles
    - Confirm 2 rows: Jonas (is_owner=true, tracker_dir='jonas') and Farva (is_owner=false, tracker_dir='farva')

    **health function**
    ```bash
    curl -s "$SUPABASE_URL/functions/v1/health" | jq .status
    # Expected: "ok" (no auth header needed)
    ```

    **Final commit**
    ```bash
    git add backend/supabase/functions/health/
    git commit -m "feat(05-06): health Edge Function + Phase 5 complete"
    ```

    Update ROADMAP.md: change `- [ ] Phase 5: Backend Foundation` to `- [x] Phase 5: Backend Foundation`.
    Update the Plans count: `**Plans:** 6 plans`.
  </how-to-verify>
  <resume-signal>Type "phase5-complete" when all four success criteria pass and the final commit is made.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Flutter app (unauthenticated) → health | Public endpoint; no secrets; no auth required by design |
| JWT algorithm (HS256 vs ES256) | Gateway behavior depends on Supabase project's signing key setting |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-06-01 | Information Disclosure | health endpoint — public, no auth | accept | Returns only `{status:'ok', timestamp}`; no project internals, no user data, no secrets. Low-value target. |
| T-05-06-02 | Spoofing | JWT algorithm mismatch (ES256 vs HS256) | mitigate | Task 2 explicitly verifies gateway accepts Jonas's JWT; ES256 fallback documented in README and SUMMARY |
| T-05-06-03 | Denial of Service | health endpoint abuse | accept | No rate-limiting needed for a simple ping endpoint; Supabase platform provides basic DDoS protection |
</threat_model>

<verification>
All four ROADMAP Phase 5 success criteria verified against cloud:
1. Both Jonas and Farva sign in successfully via email + password
2. proxy-anthropic smoke test passes (200 + Anthropic response, 401 on missing JWT)
3. github-fs smoke tests pass for all three verbs (read, list, write with attribution)
4. profiles table shows 2 rows auto-populated by trigger
5. health function returns {status:'ok'} without JWT
6. JWT signing algorithm documented in SUMMARY
</verification>

<success_criteria>
Phase 5 is complete when all four ROADMAP success criteria are verified against the cloud Supabase project. The `health` function is deployed and publicly accessible. The `backend/` directory is fully committed with no secrets. Phase 6 can begin.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-06-health-deploy-e2e-SUMMARY.md` using the summary template.

Also update `.planning/ROADMAP.md`:
- Change `- [ ] Phase 5: Backend Foundation` to `- [x] Phase 5: Backend Foundation`
- Update `**Plans:** TBD` to `**Plans:** 6 plans`
- Add plan list under Phase 5:
  ```
  Plans:
  - [x] 05-01-repo-bootstrap-PLAN.md — backend/ skeleton, CLI link
  - [x] 05-02-schema-migrations-PLAN.md — profiles + api_usage migrations
  - [x] 05-03-user-seeding-PLAN.md — Jonas + Farva accounts + trigger verification
  - [x] 05-04-proxy-anthropic-PLAN.md — Anthropic proxy Edge Function
  - [x] 05-05-github-fs-PLAN.md — GitHub FS Edge Function (read/list/write)
  - [x] 05-06-health-deploy-e2e-PLAN.md — health function + E2E verification
  ```

Update `.planning/STATE.md` to mark Phase 5 as complete and set focus to Phase 6.
</output>
