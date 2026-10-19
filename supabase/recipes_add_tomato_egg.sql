-- Extra recipes that match common pantry items (tomato, egg, etc.)
-- Safe to re-run (skips if ids already exist)

insert into public.recipes (id, title, image_url, ready_in_minutes, servings, dietary_tags, instructions)
values
  (
    'a1000000-0000-4000-8000-000000000006'::uuid,
    'Simple Tomato Scramble',
    null,
    15,
    2,
    array['Vegetarian','Gluten Free']::text[],
    'Scramble eggs with chopped tomato. Season and serve.'
  ),
  (
    'a1000000-0000-4000-8000-000000000007'::uuid,
    'Tomato Egg Stir Fry',
    null,
    20,
    3,
    array['Vegetarian','Gluten Free']::text[],
    'Stir-fry tomatoes, add beaten eggs, finish with seasoning.'
  )
on conflict (id) do nothing;

insert into public.recipe_ingredients (recipe_id, name, amount, unit)
select v.recipe_id, v.name, v.amount, v.unit
from (values
  ('a1000000-0000-4000-8000-000000000006'::uuid, 'egg', 3::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000006'::uuid, 'tomato', 2::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000006'::uuid, 'butter', 1::numeric, 'tbsp'),
  ('a1000000-0000-4000-8000-000000000006'::uuid, 'salt', 1::numeric, 'tsp'),
  ('a1000000-0000-4000-8000-000000000007'::uuid, 'tomato', 3::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000007'::uuid, 'egg', 4::numeric, 'pieces'),
  ('a1000000-0000-4000-8000-000000000007'::uuid, 'garlic', 2::numeric, 'cloves'),
  ('a1000000-0000-4000-8000-000000000007'::uuid, 'soy sauce', 1::numeric, 'tbsp')
) as v(recipe_id, name, amount, unit)
where not exists (
  select 1 from public.recipe_ingredients ri
  where ri.recipe_id = v.recipe_id and lower(ri.name) = lower(v.name)
);
