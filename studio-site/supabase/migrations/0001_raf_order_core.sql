-- AF GAMER CI / RAFORI FANTASY
-- Initial persistent player platform schema.
-- Apply only to a dedicated Supabase project after reviewing the migration.
create extension if not exists pgcrypto;

create table if not exists public.player_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  player_name text not null unique check (char_length(player_name) between 3 and 24),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.spawn_zones (
  zone_key text primary key,
  display_name text not null,
  capacity integer not null default 24 check (capacity > 0),
  enabled boolean not null default true
);

insert into public.spawn_zones(zone_key, display_name, capacity) values
 ('lisiere-aube','Lisière de l''Aube',24),
 ('val-brume','Val de Brume',24),
 ('plaine-ambre','Plaine d''Ambre',24),
 ('bois-ancien','Bois Ancien',24)
on conflict (zone_key) do nothing;

create table if not exists public.characters (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 2 and 32),
  people text not null check (people in ('humain','elfe','nain','semi-loup')),
  gender text not null check (gender in ('masculin','feminin','autre')),
  level integer not null default 1 check (level >= 1),
  experience bigint not null default 0 check (experience >= 0),
  inventory jsonb not null default '[]'::jsonb,
  equipped jsonb not null default '{}'::jsonb,
  spawn_zone text not null references public.spawn_zones(zone_key),
  spawn_position jsonb not null default '{"x":0,"y":0,"z":0}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists characters_owner_idx on public.characters(owner_id);
create index if not exists characters_spawn_zone_idx on public.characters(spawn_zone);

create table if not exists public.character_saves (
  character_id uuid primary key references public.characters(id) on delete cascade,
  owner_id uuid not null references auth.users(id) on delete cascade,
  save_version integer not null default 1,
  world_state jsonb not null default '{}'::jsonb,
  quest_state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create index if not exists character_saves_owner_idx on public.character_saves(owner_id);

create table if not exists public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 3 and 32),
  leader_id uuid not null references auth.users(id),
  invite_code text not null unique default encode(gen_random_bytes(6), 'hex'),
  max_members smallint not null default 4 check (max_members between 2 and 8),
  created_at timestamptz not null default now()
);

create table if not exists public.team_members (
  team_id uuid not null references public.teams(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('leader','member')),
  joined_at timestamptz not null default now(),
  primary key (team_id, user_id),
  unique (user_id)
);
create index if not exists team_members_user_idx on public.team_members(user_id);

-- SECURITY DEFINER avoids recursive RLS when a member checks their own team.
create or replace function public.is_raf_team_member(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1 from public.team_members
    where team_id = p_team_id and user_id = auth.uid()
  );
$$;

-- Creates a character only for the signed-in user, chooses a zone with free
-- capacity under a row lock, and grants every new character the starter sword.
create or replace function public.create_rafori_character(
  p_display_name text,
  p_people text,
  p_gender text
) returns uuid
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_character uuid;
  v_zone text;
  v_candidate text;
  v_count integer;
  v_capacity integer;
begin
  if v_user is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  if not exists (select 1 from public.player_profiles where user_id = v_user) then
    raise exception 'player_profile_required' using errcode = '23503';
  end if;
  if p_people not in ('humain','elfe','nain','semi-loup') then
    raise exception 'invalid_people';
  end if;
  if p_gender not in ('masculin','feminin','autre') then
    raise exception 'invalid_gender';
  end if;

  for v_candidate in
    select zone_key from public.spawn_zones
    where enabled = true
    order by (select count(*) from public.characters c where c.spawn_zone = spawn_zones.zone_key), random()
  loop
    select zone_key, capacity into v_zone, v_capacity
    from public.spawn_zones
    where zone_key = v_candidate and enabled = true
    for update skip locked;
    if v_zone is not null then
      select count(*) into v_count from public.characters where spawn_zone = v_zone;
      if v_count < v_capacity then
        exit;
      end if;
      v_zone := null;
    end if;
  end loop;

  if v_zone is null then
    raise exception 'all_spawn_zones_full';
  end if;

  insert into public.characters(
    owner_id, display_name, people, gender, spawn_zone, inventory, equipped
  ) values (
    v_user, p_display_name, p_people, p_gender, v_zone,
    jsonb_build_array(jsonb_build_object(
      'id','starter_sword','name','Épée de départ','type','weapon',
      'quantity',1,'bound',true
    )),
    jsonb_build_object('weapon','starter_sword')
  ) returning id into v_character;

  insert into public.character_saves(character_id, owner_id)
  values (v_character, v_user);

  return v_character;
end;
$$;

alter table public.player_profiles enable row level security;
alter table public.characters enable row level security;
alter table public.character_saves enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.spawn_zones enable row level security;

create policy "profile readable by owner" on public.player_profiles
for select to authenticated using (user_id = auth.uid());
create policy "profile insert by owner" on public.player_profiles
for insert to authenticated with check (user_id = auth.uid());
create policy "profile update by owner" on public.player_profiles
for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "characters readable by owner" on public.characters
for select to authenticated using (owner_id = auth.uid());
create policy "saves readable by owner" on public.character_saves
for select to authenticated using (owner_id = auth.uid());

create policy "teams readable by members" on public.teams
for select to authenticated using (public.is_raf_team_member(id));
create policy "team members readable by teammates" on public.team_members
for select to authenticated using (public.is_raf_team_member(team_id));

grant select, insert, update on public.player_profiles to authenticated;
grant select on public.characters, public.character_saves, public.teams, public.team_members to authenticated;
grant execute on function public.create_rafori_character(text,text,text) to authenticated;
grant execute on function public.is_raf_team_member(uuid) to authenticated;

-- Intentionally no client write policy for characters, saves, teams or loot.
-- Privileged server endpoints must validate membership and game state before writes.
-- Never expose the Supabase service-role key in the browser/game client.
