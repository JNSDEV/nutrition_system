#!/usr/bin/env ts-node
/**
 * seed-users.ts
 * Idempotent: checks if email already exists before creating.
 * Safe to re-run after `supabase db reset` or against a fresh cloud project.
 * Passwords read from env — never committed to git.
 *
 * Usage:
 *   cd backend
 *   set -a && source .env && set +a
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
    email_confirm: true, // skip confirmation email — direct admin seed
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
