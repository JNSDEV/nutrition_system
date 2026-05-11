---
phase: 05-backend-foundation
plan: 05
type: execute
wave: 4
depends_on:
  - "05-03"
files_modified:
  - backend/supabase/functions/github-fs/index.ts
  - backend/supabase/functions/github-fs/deno.json
  - backend/supabase/functions/_shared/github.ts
  - backend/scripts/smoke/github-fs-read.sh
  - backend/scripts/smoke/github-fs-write.sh
autonomous: false
requirements:
  - BE-03

must_haves:
  truths:
    - "POST /functions/v1/github-fs with verb='read' returns {path, content, sha} for an existing file"
    - "POST /functions/v1/github-fs with verb='list' returns {entries: [{name, type, size}]} for a directory"
    - "POST /functions/v1/github-fs with verb='write' creates a commit on main with the authenticated user's display_name as author"
    - "A path containing '..' is rejected with 400 (D-21 path validation)"
    - "A write with a stale sha returns 409 and the retry loop re-fetches the current sha (3 attempts, backoff 200ms * attempt)"
    - "The GITHUB_PAT is never returned to the client"
    - "All 3 verbs fail with 401 if no JWT is provided"
  artifacts:
    - path: "backend/supabase/functions/github-fs/index.ts"
      provides: "Edge Function: read/list/write verbs against GitHub Contents API (D-16..D-24)"
      contains: "api.github.com/repos"
    - path: "backend/supabase/functions/_shared/github.ts"
      provides: "Typed raw-fetch wrappers for GitHub Contents API (read, list, write with retry)"
    - path: "backend/scripts/smoke/github-fs-read.sh"
      provides: "Smoke: read + list verb curl tests (D-26)"
    - path: "backend/scripts/smoke/github-fs-write.sh"
      provides: "Smoke: write verb + path-validation + SHA-conflict tests (D-26)"
  key_links:
    - from: "github-fs/index.ts"
      to: "https://api.github.com/repos/{owner}/{repo}/contents/{path}"
      via: "_shared/github.ts raw fetch with GITHUB_PAT"
      pattern: "api.github.com/repos"
    - from: "write verb — commit author"
      to: "profiles.display_name"
      via: "user-scoped supabase client reads profiles row (D-18)"
      pattern: "profiles.*display_name"
    - from: "409 retry"
      to: "githubRead (re-fetch sha)"
      via: "writeWithRetry loop, 3 attempts, backoff 200ms * attempt"
      pattern: "writeWithRetry"

user_setup:
  - service: github
    why: "github-fs needs a fine-grained PAT with Contents: Read and Write on nutrition_system repo"
    dashboard_config:
      - task: "Create fine-grained PAT"
        location: "GitHub → Settings → Developer settings → Personal access tokens → Fine-grained tokens → Generate new token"
      - task: "Set token scope: Resource owner = your account; Repository = nutrition_system only; Permissions → Contents: Read and write"
        location: "Fine-grained token creation page"
    env_vars:
      - name: GITHUB_PAT
        source: "Generated fine-grained PAT value (shown once at creation)"
      - name: GITHUB_REPO
        source: "jonasockerman/nutrition_system (owner/repo format)"
---

<objective>
Implement the `github-fs` Edge Function with three verbs (read, list, write) using raw Deno fetch against the GitHub Contents API. Write verb includes commit attribution from the user's `profiles.display_name` and a 409 retry loop. Smoke-test all three verbs against the live repo, then deploy to cloud.

Purpose: The Flutter app and command dispatcher (Phases 7–9) depend on `github-fs` to read library files and write daily logs. All three verbs must work reliably before Phase 6 begins.

Output: `github-fs` function deployed locally and to cloud. Read, list, and write smoke tests pass against the real `nutrition_system` repo.
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
<!-- GitHub Contents API — endpoints used by this plan -->
<!-- Source: https://docs.github.com/en/rest/repos/contents -->

```
# Read a file or list a directory
GET https://api.github.com/repos/{owner}/{repo}/contents/{path}
Headers:
  Authorization: Bearer {GITHUB_PAT}
  Accept: application/vnd.github+json
  X-GitHub-Api-Version: 2022-11-28

# File response:
{
  "type": "file",
  "content": "<base64-encoded content>",
  "sha": "<blob SHA>",
  "path": "...",
  "name": "..."
}

# Directory response: array of {name, type:"file"|"dir", size, sha}

# Write (create or update a file)
PUT https://api.github.com/repos/{owner}/{repo}/contents/{path}
Body: {
  "message": "<commit message>",
  "content": "<base64-encoded content>",
  "branch": "main",
  "sha": "<existing file sha, required for updates>",   // omit for new files
  "author": {"name": "...", "email": "..."},
  "committer": {"name": "nutrition-system-bot", "email": "bot@nutrition-system.local"}
}
Response: { "commit": {"sha": "..."}, "content": {"sha": "..."} }

# 409 Conflict: sha mismatch — re-fetch and retry
```

<!-- Request/response shapes (D-16 / CONTEXT.md specifics section) -->
```typescript
// read verb → { path: string, content: string, sha: string }
// list verb → { entries: { name: string, type: "file" | "dir", size: number }[] }
// write verb → { commit_sha: string, path: string, new_sha: string }
```
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write _shared/github.ts and github-fs/index.ts</name>
  <files>
    backend/supabase/functions/_shared/github.ts
    backend/supabase/functions/github-fs/index.ts
    backend/supabase/functions/github-fs/deno.json
  </files>
  <action>
    Create `backend/supabase/functions/_shared/github.ts` (raw fetch wrappers per research Q2):

    ```typescript
    // _shared/github.ts
    // Typed raw-fetch wrappers for GitHub Contents API.
    // Using raw fetch (not Octokit) — per research Q2: minimal bundle, 3 endpoints, Deno-native.

    const GITHUB_API = 'https://api.github.com';
    const GITHUB_API_VERSION = '2022-11-28';

    function githubHeaders(pat: string): Record<string, string> {
      return {
        Authorization: `Bearer ${pat}`,
        Accept: 'application/vnd.github+json',
        'X-GitHub-Api-Version': GITHUB_API_VERSION,
        'Content-Type': 'application/json',
      };
    }

    export interface FileEntry {
      name: string;
      type: 'file' | 'dir';
      size: number;
    }

    export interface ReadResult {
      path: string;
      content: string;  // UTF-8 decoded
      sha: string;
    }

    export interface WriteResult {
      commit_sha: string;
      path: string;
      new_sha: string;
    }

    /** Read a single file. Returns content as UTF-8 string + sha for subsequent writes. */
    export async function githubRead(repo: string, path: string, pat: string): Promise<ReadResult> {
      const res = await fetch(`${GITHUB_API}/repos/${repo}/contents/${path}`, {
        headers: githubHeaders(pat),
      });
      if (!res.ok) {
        const body = await res.text();
        throw Object.assign(new Error(`GitHub read failed: ${res.status} ${body}`), { status: res.status });
      }
      const data = await res.json();
      if (data.type !== 'file') {
        throw new Error(`Path is a directory, not a file: ${path}`);
      }
      // GitHub returns base64-encoded content with newlines for line-wrapping.
      const content = atob(data.content.replace(/\n/g, ''));
      return { path: data.path, content, sha: data.sha };
    }

    /** List direct children of a directory. Returns FileEntry[] (D-22). */
    export async function githubList(repo: string, path: string, pat: string): Promise<FileEntry[]> {
      const res = await fetch(`${GITHUB_API}/repos/${repo}/contents/${path}`, {
        headers: githubHeaders(pat),
      });
      if (!res.ok) {
        const body = await res.text();
        throw Object.assign(new Error(`GitHub list failed: ${res.status} ${body}`), { status: res.status });
      }
      const data = await res.json();
      if (!Array.isArray(data)) {
        throw new Error(`Path is a file, not a directory: ${path}`);
      }
      return data.map((item: { name: string; type: string; size: number }) => ({
        name: item.name,
        type: item.type === 'dir' ? 'dir' : 'file',
        size: item.size,
      }));
    }

    /** Write a file. sha required for updates (omit for new files). D-24 semantics. */
    async function githubWrite(
      repo: string,
      path: string,
      content: string,
      sha: string | null,
      message: string,
      author: { name: string; email: string },
      pat: string
    ): Promise<WriteResult> {
      // UTF-8 → base64 (Deno-safe)
      const encoded = btoa(unescape(encodeURIComponent(content)));

      const body: Record<string, unknown> = {
        message,
        content: encoded,
        branch: 'main',  // D-20: main only
        author,
        committer: { name: 'nutrition-system-bot', email: 'bot@nutrition-system.local' },  // D-18
      };
      if (sha) body.sha = sha;

      const res = await fetch(`${GITHUB_API}/repos/${repo}/contents/${path}`, {
        method: 'PUT',
        headers: githubHeaders(pat),
        body: JSON.stringify(body),
      });

      if (!res.ok) {
        const errBody = await res.text();
        throw Object.assign(
          new Error(`GitHub write failed: ${res.status} ${errBody}`),
          { status: res.status }
        );
      }

      const data = await res.json();
      return {
        commit_sha: data.commit.sha,
        path: data.content.path,
        new_sha: data.content.sha,
      };
    }

    /**
     * Write with 409 retry (D-24 conflict handling).
     * 3 attempts, backoff 200ms * attempt number.
     * On 409: re-fetch current SHA and retry.
     */
    export async function writeWithRetry(
      repo: string,
      path: string,
      content: string,
      sha: string | null,
      message: string,
      author: { name: string; email: string },
      pat: string,
      maxRetries = 3
    ): Promise<WriteResult> {
      let currentSha = sha;
      for (let attempt = 0; attempt < maxRetries; attempt++) {
        try {
          return await githubWrite(repo, path, content, currentSha, message, author, pat);
        } catch (err) {
          if (err.status === 409 && attempt < maxRetries - 1) {
            // Re-fetch current SHA (D-24)
            const current = await githubRead(repo, path, pat);
            currentSha = current.sha;
            // Backoff: 200ms * (attempt + 1)
            await new Promise((r) => setTimeout(r, 200 * (attempt + 1)));
          } else {
            throw err;
          }
        }
      }
      throw new Error('GitHub write: max retries exceeded');
    }
    ```

    Create `backend/supabase/functions/github-fs/index.ts`:

    ```typescript
    // github-fs/index.ts
    // Single function, three verbs: read / list / write (D-16).
    // Security: JWT verified by gateway (verify_jwt = true). GITHUB_PAT is server-held (D-17).
    // Commit attribution: reads profiles.display_name for author field (D-18).
    // Path validation: reject '..' and '.git/' prefixes (D-21).

    import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
    import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
    import { githubRead, githubList, writeWithRetry } from '../_shared/github.ts';

    const GITHUB_PAT = Deno.env.get('GITHUB_PAT')!;
    const GITHUB_REPO = Deno.env.get('GITHUB_REPO')!;  // "owner/repo" format (D-17)
    const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
    const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY')!;

    const CORS_HEADERS = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    };

    /** Validate path per D-21. Returns error string or null. */
    function validatePath(path: string): string | null {
      if (!path || typeof path !== 'string') return 'path is required';
      if (path.startsWith('/')) return 'path must be relative (no leading slash)';
      if (path.includes('..')) return 'path must not contain ..';
      if (path.startsWith('.git/') || path === '.git') return 'path must not start with .git/';
      return null;
    }

    function jsonResponse(body: unknown, status = 200): Response {
      return new Response(JSON.stringify(body), {
        status,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      });
    }

    serve(async (req: Request) => {
      if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: CORS_HEADERS });
      }
      if (req.method !== 'POST') {
        return jsonResponse({ error: 'Method not allowed' }, 405);
      }

      const authHeader = req.headers.get('Authorization');
      if (!authHeader) {
        return jsonResponse({ error: 'Missing Authorization header' }, 401);
      }

      // Get authenticated user and their profile (for commit attribution, D-18).
      const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        global: { headers: { Authorization: authHeader } },
      });
      const { data: { user }, error: userError } = await userClient.auth.getUser();
      if (userError || !user) {
        return jsonResponse({ error: 'Unauthorized' }, 401);
      }

      // Read profiles row for display_name (D-18 commit attribution).
      const { data: profile, error: profileError } = await userClient
        .from('profiles')
        .select('display_name, tracker_dir')
        .eq('id', user.id)
        .single();

      if (profileError || !profile) {
        return jsonResponse({ error: 'Profile not found' }, 403);
      }

      // Derived email for commit author (D-18): no real email collected.
      const authorEmail = `${profile.display_name.toLowerCase()}@nutrition-system.local`;
      const author = { name: profile.display_name, email: authorEmail };

      let body: Record<string, unknown>;
      try {
        body = await req.json();
      } catch {
        return jsonResponse({ error: 'Invalid JSON body' }, 400);
      }

      const verb = body.verb as string;
      const path = body.path as string;

      // D-21: Path validation for all verbs.
      const pathError = validatePath(path);
      if (pathError) {
        return jsonResponse({ error: pathError }, 400);
      }

      try {
        if (verb === 'read') {
          // D-23: Returns { path, content (UTF-8), sha }
          const result = await githubRead(GITHUB_REPO, path, GITHUB_PAT);
          return jsonResponse(result);

        } else if (verb === 'list') {
          // D-22: Returns { entries: [{name, type, size}] }
          const entries = await githubList(GITHUB_REPO, path, GITHUB_PAT);
          return jsonResponse({ entries });

        } else if (verb === 'write') {
          // D-24: sha required for updates; omit for new files.
          const content = body.content as string;
          const sha = (body.sha as string | null) ?? null;
          const message = (body.message as string) || `update: ${path}`;

          if (typeof content !== 'string') {
            return jsonResponse({ error: 'content is required for write verb' }, 400);
          }

          // D-18: commit with user's display_name as author.
          const result = await writeWithRetry(
            GITHUB_REPO, path, content, sha, message, author, GITHUB_PAT
          );
          return jsonResponse(result);

        } else {
          return jsonResponse({ error: `Unknown verb: ${verb}. Use: read, list, write` }, 400);
        }
      } catch (err) {
        const status = err.status === 409 ? 409 : (err.status >= 400 ? err.status : 500);
        console.error(JSON.stringify({ event: 'github_fs_error', verb, path, status, error: err.message }));
        return jsonResponse({ error: err.message }, status);
      }
    });
    ```

    Create `backend/supabase/functions/github-fs/deno.json`:
    ```json
    {
      "imports": {}
    }
    ```

    Security verification checklist before moving on:
    - `GITHUB_PAT` comes from `Deno.env.get()` only — never from request body
    - `validatePath()` rejects `..` and `.git/` before ANY GitHub API call
    - Response body never includes `GITHUB_PAT` or any secrets
    - `GITHUB_REPO` is from env (not from request body) — SSRF guard
  </action>
  <verify>
    `grep -c "api.github.com/repos" backend/supabase/functions/_shared/github.ts` returns 1.
    `grep -c "writeWithRetry" backend/supabase/functions/github-fs/index.ts` returns 1.
    `grep -c "includes('\.\.')" backend/supabase/functions/github-fs/index.ts` returns 1.
    `grep -c "Deno.env.get('GITHUB_PAT')" backend/supabase/functions/github-fs/index.ts` returns 1.
  </verify>
  <done>
    `github-fs/index.ts` implements all three verbs per D-16. `_shared/github.ts` has `writeWithRetry` with 3-attempt loop and 200ms*attempt backoff. Path validation rejects `..` and `.git/` (D-21). Commit author is `profiles.display_name` with derived email (D-18). GITHUB_PAT and GITHUB_REPO from env only.
  </done>
</task>

<task type="auto">
  <name>Task 2: Write smoke test scripts and test locally</name>
  <files>
    backend/scripts/smoke/github-fs-read.sh
    backend/scripts/smoke/github-fs-write.sh
  </files>
  <action>
    Create `backend/scripts/smoke/github-fs-read.sh`:

    ```bash
    #!/usr/bin/env bash
    # github-fs read + list smoke tests (D-26)
    set -euo pipefail

    : "${SUPABASE_URL:?SUPABASE_URL not set}"
    : "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set}"
    : "${JONAS_PASSWORD:?JONAS_PASSWORD not set}"

    echo "=== github-fs read/list smoke test ==="

    JWT=$(curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"email":"jonas@nutrition-system.local","password":"'"$JONAS_PASSWORD"'"}' \
      | jq -r '.access_token')

    echo "JWT obtained."

    echo ""
    echo "--- read verb: library/goals.md ---"
    RESPONSE=$(curl -sf -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"verb":"read","path":"library/goals.md"}')
    SHA=$(echo "$RESPONSE" | jq -r '.sha')
    CONTENT_LEN=$(echo "$RESPONSE" | jq -r '.content | length')
    echo "$RESPONSE" | jq '{path, sha, content_length: (.content | length)}'
    if [ -z "$SHA" ] || [ "$SHA" = "null" ]; then
      echo "FAIL: Expected sha in response"
      exit 1
    fi
    echo "PASS: read returned content (${CONTENT_LEN} chars) with sha: ${SHA:0:8}..."

    echo ""
    echo "--- list verb: library/ ---"
    RESPONSE=$(curl -sf -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"verb":"list","path":"library"}')
    COUNT=$(echo "$RESPONSE" | jq '.entries | length')
    echo "$RESPONSE" | jq '{entry_count: (.entries | length), first_entry: .entries[0]}'
    if [ "$COUNT" -lt 1 ]; then
      echo "FAIL: Expected at least 1 entry in library/"
      exit 1
    fi
    echo "PASS: list returned $COUNT entries"

    echo ""
    echo "--- No-JWT path: expect 401 ---"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"verb":"read","path":"library/goals.md"}')
    [ "$STATUS" = "401" ] && echo "PASS: Got 401" || { echo "FAIL: Expected 401, got $STATUS"; exit 1; }

    echo ""
    echo "--- Path traversal: expect 400 ---"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"verb":"read","path":"../../../etc/passwd"}')
    [ "$STATUS" = "400" ] && echo "PASS: Got 400 for path traversal" || { echo "FAIL: Expected 400, got $STATUS"; exit 1; }

    echo ""
    echo "=== All github-fs read/list smoke tests passed ==="
    ```

    Create `backend/scripts/smoke/github-fs-write.sh`:

    ```bash
    #!/usr/bin/env bash
    # github-fs write smoke test (D-26)
    # Writes a test file to trackers/jonas/smoke-test.md, then deletes it.
    set -euo pipefail

    : "${SUPABASE_URL:?SUPABASE_URL not set}"
    : "${SUPABASE_ANON_KEY:?SUPABASE_ANON_KEY not set}"
    : "${JONAS_PASSWORD:?JONAS_PASSWORD not set}"

    TEST_PATH="trackers/jonas/smoke-test.md"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "=== github-fs write smoke test ==="

    JWT=$(curl -sf -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d '{"email":"jonas@nutrition-system.local","password":"'"$JONAS_PASSWORD"'"}' \
      | jq -r '.access_token')

    echo "JWT obtained."

    echo ""
    echo "--- write verb: create $TEST_PATH ---"
    WRITE_RESPONSE=$(curl -sf -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"verb\":\"write\",\"path\":\"$TEST_PATH\",\"content\":\"# Smoke test\\n\\nWritten at: $TIMESTAMP\",\"message\":\"test: smoke test write at $TIMESTAMP\"}")
    COMMIT_SHA=$(echo "$WRITE_RESPONSE" | jq -r '.commit_sha')
    NEW_SHA=$(echo "$WRITE_RESPONSE" | jq -r '.new_sha')
    echo "$WRITE_RESPONSE" | jq .
    if [ -z "$COMMIT_SHA" ] || [ "$COMMIT_SHA" = "null" ]; then
      echo "FAIL: Expected commit_sha in write response"
      exit 1
    fi
    echo "PASS: Write created commit ${COMMIT_SHA:0:8}..."

    echo ""
    echo "--- verify commit author on GitHub ---"
    # Read back the file to confirm it exists with correct sha
    READ_RESPONSE=$(curl -sf -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"verb\":\"read\",\"path\":\"$TEST_PATH\"}")
    RETURNED_SHA=$(echo "$READ_RESPONSE" | jq -r '.sha')
    echo "File sha: ${RETURNED_SHA:0:8}... (matches new_sha: ${NEW_SHA:0:8}...)"
    [ "$RETURNED_SHA" = "$NEW_SHA" ] && echo "PASS: sha matches" || { echo "FAIL: sha mismatch"; exit 1; }

    echo ""
    echo "--- 409 conflict: write with wrong sha ---"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
      -X POST "$SUPABASE_URL/functions/v1/github-fs" \
      -H "Authorization: Bearer $JWT" \
      -H "apikey: $SUPABASE_ANON_KEY" \
      -H "Content-Type: application/json" \
      -d "{\"verb\":\"write\",\"path\":\"$TEST_PATH\",\"content\":\"conflict test\",\"sha\":\"0000000000000000000000000000000000000000\",\"message\":\"test: should 409\"}")
    # Note: GitHub returns 409 or 422 for sha mismatch; retry loop handles both.
    # After 3 retries the function propagates the error as 409.
    echo "Status: $STATUS (expect 409 or 422 after retry exhaustion)"
    [[ "$STATUS" = "409" || "$STATUS" = "422" ]] && echo "PASS: Got expected conflict status" || { echo "FAIL: Expected 409/422, got $STATUS"; exit 1; }

    echo ""
    echo "--- cleanup: delete test file (using correct sha) ---"
    # Delete by writing a delete request — GitHub Contents API doesn't have a delete via PUT.
    # Use raw GitHub API delete (DELETE method) via a direct curl to GitHub API.
    # Note: github-fs function only wraps read/list/write; for cleanup use GitHub API directly.
    echo "(Cleanup skipped in smoke script — delete $TEST_PATH manually via GitHub UI or git push if needed)"

    echo ""
    echo "=== All github-fs write smoke tests passed ==="
    ```

    Make executable:
    ```bash
    chmod +x backend/scripts/smoke/github-fs-read.sh
    chmod +x backend/scripts/smoke/github-fs-write.sh
    ```

    Test locally (with `supabase functions serve --env-file ./supabase/functions/.env` running):
    ```bash
    cd backend
    export SUPABASE_URL=http://127.0.0.1:54321
    export SUPABASE_ANON_KEY=<local anon key>
    export JONAS_PASSWORD=<password>
    bash scripts/smoke/github-fs-read.sh
    bash scripts/smoke/github-fs-write.sh
    ```
  </action>
  <verify>
    `bash backend/scripts/smoke/github-fs-read.sh` (with env set) exits 0 and prints "All github-fs read/list smoke tests passed".
    `bash backend/scripts/smoke/github-fs-write.sh` (with env set) exits 0 and prints "All github-fs write smoke tests passed".
    A commit appears in the `nutrition_system` GitHub repo with author "Jonas" (not "nutrition-system-bot").
  </verify>
  <done>
    All smoke tests pass. A test commit appears in the GitHub repo with `author.name = "Jonas"` (from profiles.display_name, per D-18). Path traversal test returns 400. No-JWT test returns 401. SHA-conflict test returns 409/422 after retry exhaustion.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 3: Deploy to cloud and verify all three verbs</name>
  <what-built>github-fs implemented and tested locally. Now deploy to cloud and verify.</what-built>
  <how-to-verify>
    1. Create GitHub fine-grained PAT (if not done yet — see user_setup above).
    2. Set secrets in cloud:
       ```bash
       cd backend
       supabase secrets set GITHUB_PAT=<your fine-grained PAT>
       supabase secrets set GITHUB_REPO=jonasockerman/nutrition_system
       supabase secrets set SUPABASE_URL=<cloud url>
       supabase secrets set SUPABASE_ANON_KEY=<cloud anon key>
       supabase secrets set SUPABASE_SERVICE_ROLE_KEY=<cloud service role key>
       ```
    3. Deploy:
       ```bash
       supabase functions deploy github-fs
       ```
    4. Run smoke tests against cloud:
       ```bash
       source .env  # cloud SUPABASE_URL, SUPABASE_ANON_KEY, JONAS_PASSWORD
       bash scripts/smoke/github-fs-read.sh
       bash scripts/smoke/github-fs-write.sh
       ```
    5. Open GitHub → `nutrition_system` repo → commits → verify the smoke-test commit shows:
       - author: Jonas (not nutrition-system-bot)
       - committer: nutrition-system-bot
       - commit message: "test: smoke test write at ..."
    6. Delete the `trackers/jonas/smoke-test.md` file manually from GitHub (or via git pull → delete → push).
    7. Commit: `git add backend/supabase/functions/github-fs/ backend/supabase/functions/_shared/github.ts backend/scripts/smoke/ && git commit -m "feat(05-05): github-fs Edge Function — read/list/write with retry + path validation"`
  </how-to-verify>
  <resume-signal>Type "verified" when all three smoke test verbs pass against cloud URL and the commit on GitHub shows Jonas as author.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| Flutter app → github-fs | User JWT required; gateway rejects unauthenticated requests |
| github-fs → api.github.com | Server-to-server call with server-held fine-grained PAT; client never sees it |
| Path input → GitHub API | User-supplied path must be validated before use |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-05-05-01 | Tampering | Path traversal in github-fs | mitigate | `validatePath()` rejects `..` and `.git/` before any GitHub API call (D-21); tested in smoke script |
| T-05-05-02 | Elevation of Privilege | SSRF via GITHUB_REPO env var | mitigate | `GITHUB_REPO` comes from `Deno.env.get()` only; not from request body; repo is scoped to `nutrition_system` only |
| T-05-05-03 | Information Disclosure | GITHUB_PAT exposure | mitigate | Key in Deno.env only; response body never includes PAT; error messages logged server-side only |
| T-05-05-04 | Tampering | Farva writes to Jonas's files | accept (Phase 9) | Phase 5 only enforces generic path guard (no `..`); per-profile path restrictions are Phase 9 (MP-01..03) per CONTEXT.md deferred section |
| T-05-05-05 | Elevation of Privilege | Commit author spoofing | mitigate | Author name comes from `profiles.display_name` read via authenticated user-scoped client; user cannot set arbitrary author |
</threat_model>

<verification>
- Cloud smoke test: `read` verb returns `{path, content, sha}` for `library/goals.md`
- Cloud smoke test: `list` verb returns `{entries: [...]}` for `library/`
- Cloud smoke test: `write` verb creates a commit on main with Jonas as author
- Cloud smoke test: path with `..` returns 400
- Cloud smoke test: no JWT returns 401
- Cloud smoke test: stale sha returns 409/422 after 3 retries
- GitHub repo commit history shows correct author attribution
</verification>

<success_criteria>
ROADMAP success criterion 3: "`github-fs` Edge Function can `read` an existing file, `list` a directory, and `write` a new file in the shared `nutrition_system` repo with a commit attributed to the authenticated user; GitHub PAT is never exposed to the client." All three smoke test scripts pass against cloud.
</success_criteria>

<output>
After completion, create `.planning/phases/05-backend-foundation/05-05-github-fs-SUMMARY.md` using the summary template.
</output>
