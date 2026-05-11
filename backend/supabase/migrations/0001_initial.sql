-- 0001_initial.sql
-- Enable required Postgres extensions.
-- pgcrypto: password hashing for local seed.sql (supabase/seed.sql).
-- uuid-ossp: gen_random_uuid() in case pgcrypto uuid functions are needed.
-- Both are pre-enabled on Supabase cloud but must be declared in migrations
-- for local dev (supabase db reset starts from a clean Postgres instance).

create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";
