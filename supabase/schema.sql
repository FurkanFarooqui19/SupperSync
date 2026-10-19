-- =============================================================================
-- SupperSync — Complete Supabase Schema
-- Run this in: Supabase Dashboard → SQL Editor → New query → Paste → Run
-- =============================================================================

-- Extensions
create extension if not exists "pgcrypto";

-- =============================================================================
-- PROFILES (extends auth.users)
-- =============================================================================
create table if not exists public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  email         text not null,
  display_name  text not null,
  avatar_url    text,
  bio           text,
  dietary_tags  text[] not null default '{}',
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Auto-create profile on signup (SECURITY DEFINER bypasses RLS)
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

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- =============================================================================
-- SUPPER CLUBS
-- =============================================================================
create or replace function public.generate_invite_code()
returns text
language sql
as $$
  select upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

create table if not exists public.supper_clubs (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  description   text,
  avatar_url    text,
  invite_code   text not null unique default public.generate_invite_code(),
  created_by    uuid not null references public.profiles(id) on delete cascade,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table if not exists public.club_memberships (
  id            uuid primary key default gen_random_uuid(),
  club_id       uuid not null references public.supper_clubs(id) on delete cascade,
  user_id       uuid not null references public.profiles(id) on delete cascade,
  role          text not null default 'member'
                check (role in ('host', 'member', 'guest')),
  joined_at     timestamptz not null default now(),
  unique (club_id, user_id)
);

create index if not exists idx_club_memberships_user on public.club_memberships(user_id);
create index if not exists idx_club_memberships_club on public.club_memberships(club_id);
create index if not exists idx_supper_clubs_invite on public.supper_clubs(invite_code);

-- =============================================================================
-- PANTRY ITEMS
-- =============================================================================
create table if not exists public.pantry_items (
  id            uuid primary key default gen_random_uuid(),
  owner_id      uuid not null references public.profiles(id) on delete cascade,
  club_id       uuid references public.supper_clubs(id) on delete set null,
  name          text not null,
  category      text,
  quantity      numeric not null default 1 check (quantity > 0),
  unit          text not null default 'pieces',
  storage_type  text not null default 'pantry'
                check (storage_type in ('pantry', 'fridge', 'freezer')),
  expiry_date   date,
  visibility    text not null default 'private'
                check (visibility in ('private', 'shared')),
  barcode       text,
  notes         text,
  image_url     text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index if not exists idx_pantry_owner on public.pantry_items(owner_id);
create index if not exists idx_pantry_expiry on public.pantry_items(expiry_date);
create index if not exists idx_pantry_visibility on public.pantry_items(visibility);

-- =============================================================================
-- SUPPER EVENTS
-- =============================================================================
create table if not exists public.supper_events (
  id                uuid primary key default gen_random_uuid(),
  club_id           uuid not null references public.supper_clubs(id) on delete cascade,
  host_id           uuid not null references public.profiles(id) on delete cascade,
  title             text not null,
  description       text,
  event_date        timestamptz not null,
  location          text,
  max_attendees     int,
  status            text not null default 'planning'
                    check (status in ('planning', 'confirmed', 'completed', 'cancelled')),
  theme             text,
  selected_recipes  jsonb not null default '[]'::jsonb,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

create index if not exists idx_events_club on public.supper_events(club_id);
create index if not exists idx_events_date on public.supper_events(event_date);

create table if not exists public.event_attendees (
  id            uuid primary key default gen_random_uuid(),
  event_id      uuid not null references public.supper_events(id) on delete cascade,
  user_id       uuid not null references public.profiles(id) on delete cascade,
  status        text not null default 'invited'
                check (status in ('invited', 'confirmed', 'declined', 'maybe')),
  created_at    timestamptz not null default now(),
  unique (event_id, user_id)
);

create index if not exists idx_attendees_event on public.event_attendees(event_id);
create index if not exists idx_attendees_user on public.event_attendees(user_id);

-- =============================================================================
-- INGREDIENT ASSIGNMENTS
-- =============================================================================
create table if not exists public.ingredient_assignments (
  id                uuid primary key default gen_random_uuid(),
  event_id          uuid not null references public.supper_events(id) on delete cascade,
  assigned_to       uuid references public.profiles(id) on delete set null,
  ingredient_name   text not null,
  quantity          numeric not null default 1,
  unit              text not null default 'pieces',
  status            text not null default 'pending'
                    check (status in ('pending', 'claimed', 'acquired', 'delivered')),
  notes             text,
  created_at        timestamptz not null default now()
);

create index if not exists idx_assignments_event on public.ingredient_assignments(event_id);

-- =============================================================================
-- IMPACT LOGS
-- =============================================================================
create table if not exists public.impact_logs (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles(id) on delete cascade,
  event_id          uuid references public.supper_events(id) on delete set null,
  weight_saved_kg   numeric not null default 0,
  cost_saved        numeric not null default 0,
  carbon_offset_kg  numeric not null default 0,
  created_at        timestamptz not null default now()
);

create index if not exists idx_impact_user on public.impact_logs(user_id);

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_profiles_updated on public.profiles;
create trigger trg_profiles_updated
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists trg_clubs_updated on public.supper_clubs;
create trigger trg_clubs_updated
  before update on public.supper_clubs
  for each row execute function public.set_updated_at();

drop trigger if exists trg_pantry_updated on public.pantry_items;
create trigger trg_pantry_updated
  before update on public.pantry_items
  for each row execute function public.set_updated_at();

drop trigger if exists trg_events_updated on public.supper_events;
create trigger trg_events_updated
  before update on public.supper_events
  for each row execute function public.set_updated_at();

-- =============================================================================
-- ROW LEVEL SECURITY
-- =============================================================================
alter table public.profiles enable row level security;
alter table public.supper_clubs enable row level security;
alter table public.club_memberships enable row level security;
alter table public.pantry_items enable row level security;
alter table public.supper_events enable row level security;
alter table public.event_attendees enable row level security;
alter table public.ingredient_assignments enable row level security;
alter table public.impact_logs enable row level security;

-- Profiles
create policy "Profiles are viewable by authenticated users"
  on public.profiles for select to authenticated using (true);

create policy "Users can update own profile"
  on public.profiles for update to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert to authenticated
  with check (auth.uid() = id);

-- Helper: is club member
create or replace function public.is_club_member(p_club_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.club_memberships
    where club_id = p_club_id and user_id = auth.uid()
  );
$$;

-- Supper clubs
create policy "Members can view their clubs"
  on public.supper_clubs for select to authenticated
  using (
    public.is_club_member(id)
    or created_by = auth.uid()
  );

create policy "Anyone authenticated can find club by invite (for join)"
  on public.supper_clubs for select to authenticated
  using (true);

create policy "Authenticated users can create clubs"
  on public.supper_clubs for insert to authenticated
  with check (created_by = auth.uid());

create policy "Hosts can update their clubs"
  on public.supper_clubs for update to authenticated
  using (
    exists (
      select 1 from public.club_memberships
      where club_id = id and user_id = auth.uid() and role = 'host'
    )
  );

-- Club memberships
create policy "Members can view club memberships"
  on public.club_memberships for select to authenticated
  using (public.is_club_member(club_id) or user_id = auth.uid());

create policy "Users can join clubs"
  on public.club_memberships for insert to authenticated
  with check (user_id = auth.uid());

create policy "Users can leave clubs"
  on public.club_memberships for delete to authenticated
  using (user_id = auth.uid());

-- Pantry items
create policy "Owners can manage own pantry"
  on public.pantry_items for all to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "Club members can view shared pantry items"
  on public.pantry_items for select to authenticated
  using (
    visibility = 'shared'
    and exists (
      select 1 from public.club_memberships cm1
      join public.club_memberships cm2 on cm1.club_id = cm2.club_id
      where cm1.user_id = auth.uid()
        and cm2.user_id = owner_id
    )
  );

-- Events
create policy "Club members can view events"
  on public.supper_events for select to authenticated
  using (public.is_club_member(club_id));

create policy "Club members can create events"
  on public.supper_events for insert to authenticated
  with check (public.is_club_member(club_id) and host_id = auth.uid());

create policy "Hosts can update events"
  on public.supper_events for update to authenticated
  using (host_id = auth.uid());

-- Attendees
create policy "Club members can view attendees"
  on public.event_attendees for select to authenticated
  using (
    exists (
      select 1 from public.supper_events e
      where e.id = event_id and public.is_club_member(e.club_id)
    )
  );

create policy "Users can RSVP themselves"
  on public.event_attendees for insert to authenticated
  with check (user_id = auth.uid());

create policy "Users can update own RSVP"
  on public.event_attendees for update to authenticated
  using (user_id = auth.uid());

create policy "Users can delete own RSVP"
  on public.event_attendees for delete to authenticated
  using (user_id = auth.uid());

-- Ingredient assignments
create policy "Club members can view assignments"
  on public.ingredient_assignments for select to authenticated
  using (
    exists (
      select 1 from public.supper_events e
      where e.id = event_id and public.is_club_member(e.club_id)
    )
  );

create policy "Club members can create assignments"
  on public.ingredient_assignments for insert to authenticated
  with check (
    exists (
      select 1 from public.supper_events e
      where e.id = event_id and public.is_club_member(e.club_id)
    )
  );

create policy "Members can claim/update assignments"
  on public.ingredient_assignments for update to authenticated
  using (
    exists (
      select 1 from public.supper_events e
      where e.id = event_id and public.is_club_member(e.club_id)
    )
  );

-- Impact logs
create policy "Users can view own impact"
  on public.impact_logs for select to authenticated
  using (user_id = auth.uid());

create policy "Users can insert own impact"
  on public.impact_logs for insert to authenticated
  with check (user_id = auth.uid());

-- =============================================================================
-- REALTIME (optional — enable in Dashboard → Database → Replication too)
-- =============================================================================
-- alter publication supabase_realtime add table public.ingredient_assignments;
-- alter publication supabase_realtime add table public.event_attendees;
