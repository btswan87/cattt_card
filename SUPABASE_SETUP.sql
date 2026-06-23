-- ================================================================
-- Run this entire file in Supabase → SQL Editor → New Query
-- ================================================================

-- 1. entries table
create table if not exists entries (
  id          uuid primary key default gen_random_uuid(),
  type        text not null check (type in ('photo','text')),
  photo_url   text,                        -- Storage public URL (photos only)
  message     text,                        -- typed message (text entries only)
  font        text,                        -- chosen font family
  contributor text not null default '',    -- "from" name
  wide        boolean not null default false,
  sort_order  int  not null default 0,
  hidden      boolean not null default false,
  created_at  timestamptz default now()
);

-- 2. Row Level Security
alter table entries enable row level security;

-- Public can read visible entries
create policy "public read"
  on entries for select
  using (hidden = false);

-- Public can insert new entries (submissions)
create policy "public insert"
  on entries for insert
  with check (true);

-- Only authenticated users (admin) can update or delete
create policy "admin update"
  on entries for update
  using (auth.role() = 'authenticated');

create policy "admin delete"
  on entries for delete
  using (auth.role() = 'authenticated');

-- 3. Storage bucket  (run in SQL editor — bucket must also be created
--    manually in Storage UI: name = 'card-photos', public = true)
--
--    Then add these policies in Storage → card-photos → Policies:
--
--    SELECT policy (public read):
--      bucket_id = 'card-photos'
--
--    INSERT policy (public upload):
--      bucket_id = 'card-photos'
--
--    That's it — photos are public once uploaded.
