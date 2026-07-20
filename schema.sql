-- Planwise — Supabase schema (v8: multiple plans per user + feedback inbox)
-- Safe to re-run: uses IF EXISTS / IF NOT EXISTS throughout.
-- UPGRADING from the original schema? Just run this whole file again.

create table if not exists public.plans (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references auth.users (id) on delete cascade,
  name         text not null default 'My plan',
  data         jsonb,                -- plain storage (server-readable)
  is_encrypted boolean not null default false,
  ciphertext   text,                 -- zero-knowledge: base64 salt||iv||ciphertext
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- v8: users can now keep MANY plans (what-ifs, multiple jobs, year history)
drop index if exists plans_one_per_user;

alter table public.plans enable row level security;
drop policy if exists "Users can read own plans"   on public.plans;
drop policy if exists "Users can insert own plans" on public.plans;
drop policy if exists "Users can update own plans" on public.plans;
drop policy if exists "Users can delete own plans" on public.plans;
create policy "Users can read own plans"   on public.plans for select using (auth.uid() = user_id);
create policy "Users can insert own plans" on public.plans for insert with check (auth.uid() = user_id);
create policy "Users can update own plans" on public.plans for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Users can delete own plans" on public.plans for delete using (auth.uid() = user_id);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;
drop trigger if exists plans_touch on public.plans;
create trigger plans_touch before update on public.plans
  for each row execute function public.touch_updated_at();

-- ============ FEEDBACK INBOX ============
-- Anyone (even signed-out visitors) can WRITE feedback; nobody can read it
-- through the public API. You read it in the Supabase dashboard:
-- Table Editor -> feedback (or SQL: select * from feedback order by created_at desc).
create table if not exists public.feedback (
  id         uuid primary key default gen_random_uuid(),
  category   text,
  message    text not null,
  email      text,
  context    text,                    -- app version / plan year, no personal numbers
  user_id    uuid default auth.uid(), -- null for signed-out visitors
  created_at timestamptz not null default now()
);
alter table public.feedback enable row level security;
drop policy if exists "Anyone can send feedback" on public.feedback;
create policy "Anyone can send feedback" on public.feedback
  for insert to anon, authenticated with check (true);
-- no select/update/delete policies: the public API cannot read the inbox.
