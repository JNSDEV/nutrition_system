---
phase: 05-backend-foundation
plan: 04
type: execute
wave: 4
depends_on:
  - "05-03"
files_modified:
  - backend/supabase/functions/proxy-anthropic/index.ts
  - backend/supabase/functions/proxy-anthropic/deno.json
  - backend/supabase/functions/_shared/usage.ts
  - backend/scripts/smoke/proxy-anthropic.sh
autonomous: false
requirements:
  - BE-02
last_updated: 2026-05-11

must_haves:
  truths:
    - "POST /functions/v1/proxy-anthropic with a valid JWT returns a valid Anthropic API response"
    - "POST without a JWT returns 401 (gateway enforces D-10)"
    - "The ANTHROPIC_API_KEY is never returned to the client"
    - "The target URL is hard-coded server-side (not from request body) — SSRF guard"
    - "Every forwarded request increments the counter — valid requests, invalid model names, malformed bodies all count toward the cap (D-15)"
    - "A request over 100/day per user returns 429 with a friendly message (D-15)"
    - "Only request count + latency are logged — no body content (D-14)"
  artifacts:
    - path: "backend/supabase/functions/proxy-anthropic/index.ts"
      provides: "Edge Function: JWT-authenticated Anthropic proxy with 100-req/day cap"
      contains: "api.anthropic.com/v1/messages"
    - path: "backend/supabase/functions/_shared/usage.ts"
      provides: "api_usage read/increment helpers used by proxy-anthropic (and future github-fs)"
    - path: "backend/scripts/smoke/proxy-anthropic.sh"
      provides: "Happy-path + 401-path curl smoke tests (D-26)"
  key_links:
    - from: "proxy-anthropic/index.ts"
      to: "https://api.anthropic.com/v1/messages"
      via: "server-side fetch with ANTHROPIC_API_KEY from Deno.env"
      pattern: "api.anthropic.com/v1/messages"
    - from: "proxy-anthropic/index.ts"
      to: "public.api_usage"
      via: "usage.ts incrementProxyCalls → supabase.rpc('increment_proxy_calls', ...)"
      pattern: "incrementProxyCalls"
    - from: "supabase.rpc('increment_proxy_calls')"
      to: "public.increment_proxy_calls SQL function"
      via: "migration 0004_rpc_increment_proxy_calls.sql (plan 05-02)"
      pattern: "increment_proxy_calls"
---

<objective>
Implement the `proxy-anthropic` Edge Function: authenticated POST endpoint that forwards requests to Anthropic's API using a server-held key, enforces a 100-request/day per-user cap via `api_usage`, and returns the Anthropic response verbatim. Smoke-test locally, then deploy to cloud.

Purpose: This is the core capability that Phases 7–9 depend on for all Claude interactions. The SSRF guard (hard-coded target URL) and cost cap (D-15) must be in place from the start.

Output: `proxy-anthropic` function deployed locally and to cloud. `proxy-anthropic.sh` smoke test passes against the cloud URL with a real Anthropic API call.
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
<!-- Supabase Edge Function boilerplate — Deno + TypeScript -->
```typescript
// Standard Supabase Edge Function entry point
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  // req.headers.get('Authorization') → 'Bearer <user-jwt>'
  // Gateway has already verified JWT at this point (verify_jwt = true in config.toml)
  return new Response(JSON.stringify({ ok: true }), {
    headers: { 'Content-Type': 'application/json' },
  })
})
```

<!-- api_usage table schema (from 05-02) -->
```sql
-- public.api_usage
-- primary key: (user_id, day)
-- columns: user_id uuid, day date, proxy_anthropic_calls int, github_writes int

-- increment_proxy_calls Postgres function (from migration 0004, plan 05-02):
-- create or replace function public.increment_proxy_calls(p_user_id uuid, p_day date)
-- returns void language sql security definer as $$
--   insert into public.api_usage (user_id, day, proxy_anthropic_calls) values (p_user_id, p_day, 1)
--   on conflict (user_id, day) do update set proxy_anthropic_calls = api_usage.proxy_anthropic_calls + 1;
-- $$;
```
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write _shared/usage.ts and proxy-anthropic/index.ts</name>
  <files>
    backend/supabase/functions/_shared/usage.ts
    backend/supabase/functions/proxy-anthropic/index.ts
    backend/supabase/functions/proxy-anthropic/deno.json
  </files>
  <action>
    Create `backend/supabase/functions/_shared/usage.ts`:

    The `increment_proxy_calls` Postgres function is guaranteed to exist via migration
    `0004_rpc_increment_proxy_calls.sql` (plan 05-02). No fallback path is needed — call
    the RPC directly. The RPC uses an atomic `INSERT ... ON CONFLICT DO UPDATE SET ... + 1`
    so there is no read-then-write race condition.

    ```typescript
    // _shared/usage.ts
    // api_usage table helpers.
    // Uses service-role client to bypass RLS (Edge Functions write to api_usage as admin).
    import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

    function adminClient() {
      return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
        auth: { autoRefreshToken: false, persistSession: false },
      });
    }

    /** Returns current proxy_anthropic_calls for (userId, today). */
    export async function getProxyCallsToday(userId: string): Promise<number> {
      const supabase = adminClient();
      const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
      const { data, error } = await supabase
        .from('api_usage')
        .select('proxy_anthropic_calls')
        .eq('user_id', userId)
        .eq('day', today)
        .maybeSingle();
      if (error) throw error;
      return data?.proxy_anthropic_calls ?? 0;
    }

    /**
     * Atomically increments proxy_anthropic_calls by 1 for (userId, today).
     * Creates the row if absent. Uses the increment_proxy_calls Postgres function
     * (migration 0004) which performs an atomic INSERT ... ON CONFLICT DO UPDATE.
     */
    export async function incrementProxyCalls(userId: string): Promise<void> {
      const supabase = adminClient();
      const today = new Date().toISOString().slice(0, 10);
      const { error } = await supabase.rpc('increment_proxy_calls', {
        p_user_id: userId,
        p_day: today,
      });
      if (error) throw error;
    }
    ```

    Create `backend/supabase/functions/proxy-anthropic/index.ts`:

    IMPORTANT counter-increment placement: `incrementProxyCalls` is called UNCONDITIONALLY
    after the Anthropic fetch completes — regardless of `anthropicResponse.ok`. The counter
    measures forwarded requests, not successful ones. This prevents a cap-bypass where a user
    sends intentionally-invalid requests (bad model name, malformed body) to get unlimited
    Anthropic 4xx responses without consuming quota.

    ```typescript
    // proxy-anthropic/index.ts
    // Authenticated Anthropic API proxy (D-10, D-11, D-12, D-13, D-14, D-15).
    //
    // Security: JWT verified by Supabase gateway (verify_jwt = true in config.toml).
    // SSRF guard: target URL is hard-coded — never read from request body (D-10).
    // Cost cap: 100 requests/day per user returns 429 (D-15).
    //   Counter increments on EVERY forwarded request (not just successful ones) so
    //   intentionally-invalid requests (bad model, malformed body) still consume quota.
    // Logging: request count + latency only — no body content logged (D-14).

    import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
    import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
    import { getProxyCallsToday, incrementProxyCalls } from '../_shared/usage.ts';

    // Hard-coded — never accept this from the request body (SSRF prevention).
    const ANTHROPIC_API_URL = 'https://api.anthropic.com/v1/messages';
    const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY')!;
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
    const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;
    const DAILY_CAP = 100;

    const CORS_HEADERS = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    };

    serve(async (req: Request) => {
      // Handle CORS preflight
      if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: CORS_HEADERS });
      }

      if (req.method !== 'POST') {
        return new Response(JSON.stringify({ error: 'Method not allowed' }), {
          status: 405,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }

      const startMs = Date.now();

      try {
        // Extract user identity from JWT (gateway already validated the token).
        // Create user-scoped client to get the authenticated user's ID.
        const authHeader = req.headers.get('Authorization');
        if (!authHeader) {
          return new Response(JSON.stringify({ error: 'Missing Authorization header' }), {
            status: 401,
            headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
          });
        }

        const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
          global: { headers: { Authorization: authHeader } },
        });
        const { data: { user }, error: userError } = await userClient.auth.getUser();
        if (userError || !user) {
          return new Response(JSON.stringify({ error: 'Unauthorized' }), {
            status: 401,
            headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
          });
        }

        // D-15: Cost cap — check before forwarding.
        const callsToday = await getProxyCallsToday(user.id);
        if (callsToday >= DAILY_CAP) {
          return new Response(
            JSON.stringify({
              error: `Daily limit reached (${DAILY_CAP} requests). Try again tomorrow.`,
            }),
            {
              status: 429,
              headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
            }
          );
        }

        // Read request body verbatim.
        const requestBody = await req.json();

        // D-10: Forward to hard-coded Anthropic URL. Target never comes from request.
        const anthropicResponse = await fetch(ANTHROPIC_API_URL, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'x-api-key': ANTHROPIC_API_KEY,
            'anthropic-version': '2023-06-01',
          },
          body: JSON.stringify(requestBody),
        });

        const responseBody = await anthropicResponse.json();
        const latencyMs = Date.now() - startMs;

        // D-15: Increment usage counter UNCONDITIONALLY after forwarding to Anthropic.
        // Counter measures forwarded requests, not successful ones. Incrementing regardless
        // of anthropicResponse.ok prevents cap-bypass via intentionally-invalid requests.
        await incrementProxyCalls(user.id);

        // D-14: Log count + latency only. No body content.
        console.log(
          JSON.stringify({
            event: 'proxy_anthropic_call',
            user_id: user.id,
            status: anthropicResponse.status,
            latency_ms: latencyMs,
          })
        );

        return new Response(JSON.stringify(responseBody), {
          status: anthropicResponse.status,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      } catch (err) {
        const latencyMs = Date.now() - startMs;
        console.error(JSON.stringify({ event: 'proxy_anthropic_error', error: err.message, latency_ms: latencyMs }));
        return new Response(JSON.stringify({ error: 'Internal server error' }), {
          status: 500,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
        });
      }
    });
    ```

    Create `backend/supabase/functions/proxy-anthropic/deno.json`:
    ```json
    {
      "imports": {}
    }
    ```

    CRITICAL security checks to verify before moving on:
    - `ANTHROPIC_API_URL` is a string constant, not derived from any request field
    - `ANTHROPIC_API_KEY` comes from `Deno.env.get()`, never from request body
    - `incrementProxyCalls` is called AFTER the fetch, BEFORE returning — no early return skips it
    - The response body does NOT include any headers from the Anthropic response that might expose the key
  </action>
  <verify>
    `grep -c "api.anthropic.com/v1/messages" backend/supabase/functions/proxy-anthropic/index.ts` returns 1.
    `grep -c "Deno.env.get('ANTHROPIC_API_KEY')" backend/supabase/functions/proxy-anthropic/index.ts` returns 1.
    Confirm `incrementProxyCalls` call is NOT inside an `if (anthropicResponse.ok)` block:
    `grep -c "if (anthropicResponse.ok)" backend/supabase/functions/proxy-anthropic/index.ts` returns 0.
    Confirm `incrementProxyCalls` is called unconditionally after the fetch:
    `grep -c "await incrementProxyCalls" backend/supabase/functions/proxy-anthropic/index.ts` returns 1.
    Confirm no fallback upsert path in usage.ts (RPC is the only path):
    `grep -c "upsert" backend/supabase/functions/_shared/usage.ts` returns 0.
    Confirm no line in index.ts reads from `req.body` to construct the target URL:
    `grep -c "requestBody.*url\|req.*url" backend/supabase/functions/proxy-anthropic/index.ts` returns 0.
  </verify>
  <done>
    `proxy-anthropic/index.ts` implements D-10 (JWT required), D-11 (non-streaming), D-12 (server-held key), D-13 (model from app), D-14 (count+latency logging), D-15 (100 req/day cap — counter increments unconditionally on every forwarded request). SSRF guard: target URL hard-coded. `_shared/usage.ts` calls `supabase.rpc('increment_proxy_calls', ...)` with no fallback; the function is guaranteed by migration 0004.
  </done>
</task>

<task type="auto">
  <name>Task 2: Write smoke test script and test locally</name>
  <files>backend/scripts/smoke/proxy-anthropic.sh</files>
  <action>
    Create `backend/scripts/smoke/proxy-anthropic.sh`:

    ```bash
    #!/usr/bin/env bash
    # proxy-anthropic smoke test (D-26)
    # Tests: happy path (200 + Anthropic response), no-JWT path (401).
    # Usage: source backend/.env && bash backend/scripts/smoke/proxy-anthropic.sh
    set -euo pipefail

    : "${SUPABASE_URL:?SUPABASE_URL not set}"
    : "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set}"
    : "${JONAS_PASSWORD:?JONAS_PASSWORD not set}"

    echo "=== proxy-anthropic smoke test ==="
    echo "Target: $SUPABASE_URL"

    # Step 1: Sign in as Jonas to get a JWT.
    echo ""
    echo "--- Obtaining JWT for jonas@nutrition-system.local ---"
    JWT=$(curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"jonas@nutrition-system.local\",\"password\":\"$JONAS_PASSWORD\"}" \
      | jq -r '.access_token')

    if [ -z "$JWT" ] || [ "$JWT" = "null" ]; then
      echo "FAIL: Could not obtain JWT. Check credentials and Supabase project."
      exit 1
    fi
    echo "JWT obtained (length: ${#JWT})"

    # Step 2: Happy path — POST with valid JWT and a tiny prompt.
    echo ""
    echo "--- Happy path: POST with valid JWT ---"
    RESPONSE=$(curl -sf -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"model":"claude-sonnet-4-6","max_tokens":20,"messages":[{"role":"user","content":"Reply with just: pong"}]}')

    echo "$RESPONSE" | jq .
    CONTENT=$(echo "$RESPONSE" | jq -r '.content[0].text // empty')
    if [ -z "$CONTENT" ]; then
      echo "FAIL: Expected Anthropic response with content[0].text"
      exit 1
    fi
    echo "PASS: Got response: $CONTENT"

    # Step 3: No JWT — expect 401.
    echo ""
    echo "--- No-JWT path: expect 401 ---"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$SUPABASE_URL/functions/v1/proxy-anthropic" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"model":"claude-sonnet-4-6","max_tokens":10,"messages":[{"role":"user","content":"hi"}]}')

    if [ "$STATUS" = "401" ]; then
      echo "PASS: Got 401 as expected"
    else
      echo "FAIL: Expected 401, got $STATUS"
      exit 1
    fi

    echo ""
    echo "=== All proxy-anthropic smoke tests passed ==="
    ```

    Make executable: `chmod +x backend/scripts/smoke/proxy-anthropic.sh`

    Test locally:
    1. Ensure local Supabase is running (`supabase start`) and the function environment is set up.
    2. In a separate terminal: `cd backend && supabase functions serve --env-file ./supabase/functions/.env`
    3. Set local vars: `export SUPABASE_URL=http://127.0.0.1:54321 SUPABASE_ANON_KEY=<local anon key> JONAS_PASSWORD=<password>`
    4. Run: `bash backend/scripts/smoke/proxy-anthropic.sh`
    5. Verify both PASS lines appear.

    NOTE: Local function serve will hit the real Anthropic API (tiny 20-token prompt, minimal cost).
  </action>
  <verify>
    `ls backend/scripts/smoke/proxy-anthropic.sh` exits 0.
    `bash backend/scripts/smoke/proxy-anthropic.sh` (with env set) exits 0 and prints "All proxy-anthropic smoke tests passed".
  </verify>
  <done>
    `proxy-anthropic.sh` smoke test exists and passes locally: 200 + Anthropic response text on happy path, 401 on missing JWT.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: Deploy to cloud and verify</name>
  <what-built>proxy-anthropic Edge Function implemented and tested locally. Now deploy to cloud.</what-built>
  <how-to-verify>
    1. Set function secrets in cloud:
       ```bash
       cd backend
       supabase secrets set ANTHROPIC_API_KEY=<your key>
       supabase secrets set SUPABASE_URL=<cloud url>
       supabase secrets set SUPABASE_ANON_KEY=<cloud anon key>
       supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<cloud service role key>
       ```
    2. Deploy the function:
       ```bash
       supabase functions deploy proxy-anthropic
       supabase functions deploy  # deploys all functions including _shared
       ```
    3. Run smoke test against cloud:
       ```bash
       source .env  # loads cloud SUPABASE_URL, SUPABASE_ANON_KEY, JONAS_PASSWORD
       bash scripts/smoke/proxy-anthropic.sh
       ```
    4. Verify in Supabase Dashboard → Edge Functions → proxy-anthropic → Logs:
       - Should see a log entry with `event: proxy_anthropic_call`, status 200, and a latency_ms
       - Should NOT see any body content, API keys, or request payloads in logs
    5. Verify the counter incremented: Dashboard → Table Editor → api_usage → confirm a row exists for Jonas with proxy_anthropic_calls = 1.
    6. Commit: `git add backend/supabase/functions/ backend/scripts/smoke/proxy-anthropic.sh && git commit -m "feat(05-04): proxy-anthropic Edge Function with cost cap + SSRF guard"`
  </how-to-verify>
  <resume-signal>Type "verified" when smoke test passes against cloud URL and logs show count+latency only.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Flutter app → proxy-anthropic | App sends user JWT; gateway verifies before function runs |
| proxy-anthropic → api.anthropic.com | Server-to-server call with server-held key; client never sees the key |
| proxy-anthropic → public.api_usage | Service-role write via usage.ts; user cannot manipulate counter directly |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-04-01 | Elevation of Privilege | SSRF — proxy-anthropic target URL | mitigate | `ANTHROPIC_API_URL` is a string constant in index.ts; never read from request body (D-10). Verified by grep in Task 1. |
| T-05-04-02 | Information Disclosure | ANTHROPIC_API_KEY in Edge Function | mitigate | Key read from `Deno.env.get()` only; stored in Supabase secrets; response body is Anthropic JSON, not the key |
| T-05-04-03 | Information Disclosure | Logging body content | mitigate | Only `user_id`, `status`, `latency_ms` logged (D-14); request body and Anthropic response body never logged |
| T-05-04-04 | Denial of Wallet | Unbounded Anthropic API spend | mitigate | 100-req/day per user cap (D-15); over-cap returns 429 before forwarding to Anthropic; counter increments on ALL forwarded requests (valid and invalid) so cap cannot be bypassed via intentionally-bad requests |
| T-05-04-05 | Tampering | User manipulates api_usage counter | mitigate | api_usage writes use service-role client via atomic RPC; user-scoped client has select-only RLS policy on api_usage |
</threat_model>

<verification>
- Cloud smoke test: POST with Jonas JWT → 200 + Anthropic response with `content[0].text`
- Cloud smoke test: POST without JWT → 401
- Supabase Dashboard logs show `event`, `status`, `latency_ms` only — no API key or request body
- `grep "api.anthropic.com/v1/messages" backend/supabase/functions/proxy-anthropic/index.ts` shows hard-coded constant
- `grep "if (anthropicResponse.ok)" backend/supabase/functions/proxy-anthropic/index.ts` returns no matches (counter is unconditional)
- `api_usage` table has a row for Jonas after smoke test run (confirm in Studio)
- Function is deployed: Supabase Dashboard → Edge Functions → proxy-anthropic → Status: Active
</verification>

<success_criteria>
ROADMAP success criterion 2: "`proxy-anthropic` Edge Function returns a successful response when called with a valid JWT and a small test prompt; Anthropic key is never exposed to the client." The smoke test confirms both the happy path and the 401 path. Logs confirm no key exposure. The cost cap counter increments on every forwarded request (not just successful ones).
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-04-proxy-anthropic-SUMMARY.md` using the summary template.
</output>
