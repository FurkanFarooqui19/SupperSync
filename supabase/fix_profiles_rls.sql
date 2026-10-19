-- =============================================================================
-- Fix: profiles RLS 42501 on signup
-- Run once in: Supabase Dashboard → SQL Editor → New query → Run
-- =============================================================================

-- Ensure trigger function bypasses RLS (creates profile on auth.users insert)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(
      new.raw_user_meta_data->>'display_name',
      split_part(coalesce(new.email, 'user'), '@', 1)
    )
  )
  on conflict (id) do update
    set
      email = excluded.email,
      display_name = coalesce(
        nullif(excluded.display_name, ''),
        public.profiles.display_name
      ),
      updated_at = now();
  return new;
end;
$$;

-- Make sure the trigger exists
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Recreate profile policies cleanly
drop policy if exists "Profiles are viewable by authenticated users" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Users can insert own profile" on public.profiles;

alter table public.profiles enable row level security;

create policy "Profiles are viewable by authenticated users"
  on public.profiles for select
  to authenticated
  using (true);

-- UPDATE needs both USING and WITH CHECK for upserts/updates
create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- INSERT only when logged in as that user (backup if trigger missed)
create policy "Users can insert own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

-- Backfill profiles for any auth users missing a row
insert into public.profiles (id, email, display_name)
select
  u.id,
  coalesce(u.email, ''),
  coalesce(
    u.raw_user_meta_data->>'display_name',
    split_part(coalesce(u.email, 'user'), '@', 1)
  )
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null
on conflict (id) do nothing;
