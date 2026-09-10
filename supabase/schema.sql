-- Familia schema — paste into the Supabase SQL editor and run.
-- Safe to re-run: no existing tables are dropped, only additive changes.

-- 1. Deterministic newest-first ordering for restaurants + reviews.
alter table public.restaurants
  add column if not exists created timestamptz not null default now();

alter table public.family_reviews
  add column if not exists created timestamptz not null default now();

-- 2. Family accounts (name + PIN login, members, favorited spots).
create table if not exists public.families (
  name text primary key,
  pin text not null,
  members jsonb not null default '[]'::jsonb,
  favorites text[] not null default '{}'
);

-- 3. Public bucket for restaurant photos uploaded from the app.
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do update set public = true;

drop policy if exists "Public read photos" on storage.objects;
create policy "Public read photos"
  on storage.objects for select
  using (bucket_id = 'photos');

drop policy if exists "Anon upload photos" on storage.objects;
create policy "Anon upload photos"
  on storage.objects for insert
  with check (bucket_id = 'photos');
