-- =============================================================================
-- Recipes catalog (DB-backed — no mock/fake recipe data in the app)
-- Run in: Supabase Dashboard → SQL Editor → Run
-- =============================================================================

create table if not exists public.recipes (
  id                uuid primary key default gen_random_uuid(),
  title             text not null,
  image_url         text,
  ready_in_minutes  int not null default 30,
  servings          int,
  dietary_tags      text[] not null default '{}',
  instructions      text,
  created_at        timestamptz not null default now()
);

create table if not exists public.recipe_ingredients (
  id          uuid primary key default gen_random_uuid(),
  recipe_id   uuid not null references public.recipes(id) on delete cascade,
  name        text not null,
  amount      numeric not null default 1,
  unit        text not null default 'pieces'
);

create index if not exists idx_recipe_ingredients_recipe
  on public.recipe_ingredients(recipe_id);

alter table public.recipes enable row level security;
alter table public.recipe_ingredients enable row level security;

drop policy if exists "Authenticated users can read recipes" on public.recipes;
create policy "Authenticated users can read recipes"
  on public.recipes for select to authenticated using (true);

drop policy if exists "Authenticated users can read recipe ingredients"
  on public.recipe_ingredients;
create policy "Authenticated users can read recipe ingredients"
  on public.recipe_ingredients for select to authenticated using (true);

-- Seed catalog (skip if already seeded)
insert into public.recipes (id, title, image_url, ready_in_minutes, servings, dietary_tags, instructions)
select * from (values
  (
    'a1000000-0000-4000-8000-000000000001'::uuid,
    'Vegetable Stir Fry',
    null,
    25,
    4,
    array['Vegetarian','Vegan','Gluten Free']::text[],
    'Stir-fry vegetables over high heat. Season and serve.'
  ),
  (
    'a1000000-0000-4000-8000-000000000002'::uuid,
    'Tomato Pasta',
    null,
    30,
    4,
    array['Vegetarian']::text[],
    'Boil pasta. Simmer tomatoes with garlic and oil. Toss together.'
  ),
  (
    'a1000000-0000-4000-8000-000000000003'::uuid,
    'Garden Salad Bowl',
    null,
    15,
    2,
    array['Vegetarian','Vegan','Gluten Free','Dairy Free']::text[],
    'Chop vegetables, toss with oil and seasoning.'
  ),
  (
    'a1000000-0000-4000-8000-000000000004'::uuid,
    'Lentil Soup',
    null,
    45,
    6,
    array['Vegetarian','Vegan','Gluten Free','Dairy Free']::text[],
    'Simmer lentils with vegetables and spices until soft.'
  ),
  (
    'a1000000-0000-4000-8000-000000000005'::uuid,
    'Cheese Omelette',
    null,
    15,
    2,
    array['Vegetarian','Gluten Free']::text[],
    'Whisk eggs, cook in pan, fill with cheese and fold.'
  )
) as v(id, title, image_url, ready_in_minutes, servings, dietary_tags, instructions)
where not exists (select 1 from public.recipes limit 1);

insert into public.recipe_ingredients (recipe_id, name, amount, unit)
select * from (values
  ('a1000000-0000-4000-8000-000000000001'::uuid, 'broccoli', 200::numeric, 'g'),
  ('a1000000-0000-4000-8000-000000000001'::uuid, 'carrot', 2::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000001'::uuid, 'bell pepper', 1::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000001'::uuid, 'garlic', 2::numeric, 'cloves'),
  ('a1000000-0000-4000-8000-000000000001'::uuid, 'soy sauce', 2::numeric, 'tbsp'),
  ('a1000000-0000-4000-8000-000000000002'::uuid, 'pasta', 400::numeric, 'g'),
  ('a1000000-0000-4000-8000-000000000002'::uuid, 'tomato', 4::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000002'::uuid, 'garlic', 3::numeric, 'cloves'),
  ('a1000000-0000-4000-8000-000000000002'::uuid, 'olive oil', 2::numeric, 'tbsp'),
  ('a1000000-0000-4000-8000-000000000002'::uuid, 'onion', 1::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000003'::uuid, 'lettuce', 1::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000003'::uuid, 'tomato', 2::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000003'::uuid, 'cucumber', 1::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000003'::uuid, 'olive oil', 1::numeric, 'tbsp'),
  ('a1000000-0000-4000-8000-000000000004'::uuid, 'lentils', 250::numeric, 'g'),
  ('a1000000-0000-4000-8000-000000000004'::uuid, 'carrot', 2::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000004'::uuid, 'onion', 1::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000004'::uuid, 'garlic', 2::numeric, 'cloves'),
  ('a1000000-0000-4000-8000-000000000004'::uuid, 'tomato', 2::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000005'::uuid, 'eggs', 4::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000005'::uuid, 'cheese', 100::numeric, 'g'),
  ('a1000000-0000-4000-8000-000000000005'::uuid, 'butter', 1::numeric, 'tbsp'),
  ('a1000000-0000-4000-8000-000000000005'::uuid, 'milk', 50::numeric, 'ml')
) as v(recipe_id, name, amount, unit)
where not exists (select 1 from public.recipe_ingredients limit 1);
