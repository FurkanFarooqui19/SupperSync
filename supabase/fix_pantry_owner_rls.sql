-- =============================================================================
-- Lock pantry edits to the owner only (others may VIEW shared items)
-- Run in: Supabase Dashboard → SQL Editor → Run
-- =============================================================================

drop policy if exists "Owners can manage own pantry" on public.pantry_items;
drop policy if exists "Club members can view shared pantry items" on public.pantry_items;
drop policy if exists "Users can select own pantry items" on public.pantry_items;
drop policy if exists "Users can insert own pantry items" on public.pantry_items;
drop policy if exists "Users can update own pantry items" on public.pantry_items;
drop policy if exists "Users can delete own pantry items" on public.pantry_items;

alter table public.pantry_items enable row level security;

-- Read: own items OR shared items within a shared club
create policy "Users can select own pantry items"
  on public.pantry_items for select to authenticated
  using (owner_id = auth.uid());

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

-- Write: owner only
create policy "Users can insert own pantry items"
  on public.pantry_items for insert to authenticated
  with check (owner_id = auth.uid());

create policy "Users can update own pantry items"
  on public.pantry_items for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "Users can delete own pantry items"
  on public.pantry_items for delete to authenticated
  using (owner_id = auth.uid());
