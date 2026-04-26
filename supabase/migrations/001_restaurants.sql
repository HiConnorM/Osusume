-- ============================================================
-- Osusume! — Core database schema
-- Run via: supabase db push  (or paste into Supabase SQL editor)
-- ============================================================

-- Enable PostGIS for geo queries
create extension if not exists postgis;

-- ============================================================
-- RESTAURANTS
-- ============================================================
create table if not exists restaurants (
  id                  uuid primary key default gen_random_uuid(),
  google_place_id     text unique,
  yelp_id             text,
  foursquare_id       text,

  -- Names
  name_en             text not null,
  name_ja             text,

  -- Classification
  cuisine_type        text,
  price_level         int check (price_level between 1 and 4),

  -- Location
  address             text,
  city                text default 'Tokyo',
  neighborhood        text,
  latitude            double precision not null,
  longitude           double precision not null,
  location            geography(Point, 4326)
    generated always as (st_makepoint(longitude, latitude)) stored,

  -- Contact
  phone               text,
  website             text,
  google_maps_url     text,

  -- Scores (from Google / Yelp)
  google_rating       numeric(2,1),
  google_review_count int,
  yelp_rating         numeric(2,1),
  yelp_review_count   int,

  -- Hours (jsonb array of {open: "HH:MM", close: "HH:MM", day: 0-6})
  opening_hours       jsonb,
  is_open_now         boolean,
  hours_last_synced   timestamptz,

  -- Status
  is_active           boolean default true,
  source_status       text default 'pending',  -- pending | verified | flagged
  last_synced_at      timestamptz,
  created_at          timestamptz default now(),
  updated_at          timestamptz default now()
);

-- Spatial index for proximity queries
create index if not exists restaurants_location_idx
  on restaurants using gist(location);

-- ============================================================
-- FOREIGNER FACTORS (one-to-one with restaurants)
-- ============================================================
create table if not exists restaurant_foreigner_factors (
  restaurant_id           uuid primary key references restaurants(id) on delete cascade,

  english_menu            boolean,
  english_staff_likely    boolean,
  card_payment            boolean,
  suica_payment           boolean,
  reservation_required    boolean,
  walk_in_friendly        boolean,
  allergy_friendly        boolean,
  vegetarian_options      boolean,
  vegan_options           boolean,
  halal_options           boolean,
  solo_friendly           boolean,
  kid_friendly            boolean,
  smoking_section         boolean,
  has_table_charge        boolean,   -- otoshi

  ease_score              int check (ease_score between 0 and 100),
  tourist_trap_risk       int check (tourist_trap_risk between 0 and 10),
  local_gem_score         int check (local_gem_score between 0 and 10),

  what_to_order           text,
  how_to_book             text,
  etiquette_notes         text,
  foreigner_tip           text,

  verified_by             text,
  verified_at             timestamptz,
  created_at              timestamptz default now(),
  updated_at              timestamptz default now()
);

-- ============================================================
-- PHOTOS
-- ============================================================
create table if not exists restaurant_photos (
  id                    uuid primary key default gen_random_uuid(),
  restaurant_id         uuid not null references restaurants(id) on delete cascade,

  -- Source tracking
  source                text not null,    -- google | yelp | foursquare | user | owner | editorial
  source_photo_ref      text,             -- Google photo_reference or equivalent
  display_url           text not null,

  -- Attribution (required by Google Places ToS)
  attribution_text      text,
  attribution_url       text,

  -- Metadata
  width                 int,
  height                int,
  is_primary            boolean default false,
  sort_order            int default 0,

  -- Lifecycle
  license_type          text default 'api',   -- api | cc0 | editorial | user
  expires_at            timestamptz,           -- Google URLs expire; refresh needed
  created_at            timestamptz default now()
);

create index if not exists photos_restaurant_idx on restaurant_photos(restaurant_id);
create index if not exists photos_primary_idx on restaurant_photos(restaurant_id, is_primary);

-- ============================================================
-- USERS & PREFERENCES
-- ============================================================
create table if not exists user_profiles (
  id                    uuid primary key references auth.users(id) on delete cascade,
  display_name          text,
  home_country          text,
  current_city          text default 'Tokyo',
  subscription_status   text default 'free',  -- free | plus | concierge
  created_at            timestamptz default now()
);

create table if not exists user_preferences (
  user_id               uuid primary key references user_profiles(id) on delete cascade,
  budget_min            int,
  budget_max            int,
  favorite_cuisines     text[],
  dietary_restrictions  text[],
  allergies             text[],
  adventurous_level     int check (adventurous_level between 1 and 3),  -- 1=easy 2=moderate 3=adventurous
  english_menu_required boolean default false,
  card_required         boolean default false,
  solo_friendly_req     boolean default false,
  hidden_gems_preferred boolean default false,
  updated_at            timestamptz default now()
);

-- ============================================================
-- SAVED PLACES & LISTS
-- ============================================================
create table if not exists trip_lists (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null references user_profiles(id) on delete cascade,
  name          text not null,
  emoji         text default '📍',
  city          text,
  start_date    date,
  end_date      date,
  is_default    boolean default false,
  created_at    timestamptz default now()
);

create table if not exists saved_places (
  user_id         uuid not null references user_profiles(id) on delete cascade,
  restaurant_id   uuid not null references restaurants(id) on delete cascade,
  list_id         uuid references trip_lists(id) on delete set null,
  notes           text,
  created_at      timestamptz default now(),
  primary key (user_id, restaurant_id)
);

-- ============================================================
-- MENU TRANSLATIONS
-- ============================================================
create table if not exists menu_translations (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid references user_profiles(id) on delete set null,
  restaurant_id     uuid references restaurants(id) on delete set null,

  image_url         text,
  extracted_text    text,
  translated_json   jsonb,   -- [{nameJa, nameEn, description, price, allergens, spiceLevel}]

  model_used        text,
  tokens_used       int,
  created_at        timestamptz default now()
);

-- ============================================================
-- RESERVATION REQUESTS
-- ============================================================
create table if not exists reservation_requests (
  id                        uuid primary key default gen_random_uuid(),
  user_id                   uuid references user_profiles(id) on delete set null,
  restaurant_id             uuid references restaurants(id) on delete set null,

  party_size                int not null,
  requested_date            date not null,
  requested_time            time not null,
  allergies                 text[],
  special_notes             text,

  generated_ja_message      text,
  generated_en_message      text,

  status                    text default 'draft',  -- draft | sent | confirmed | cancelled
  created_at                timestamptz default now()
);

-- ============================================================
-- USER REPORTS (crowd-sourced foreigner data)
-- ============================================================
create table if not exists user_reports (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references user_profiles(id) on delete set null,
  restaurant_id   uuid not null references restaurants(id) on delete cascade,
  report_type     text not null,   -- english_menu | card_payment | solo_friendly | etc.
  value           text not null,   -- yes | no | unknown
  notes           text,
  verified        boolean default false,
  created_at      timestamptz default now()
);

-- ============================================================
-- Row-Level Security
-- ============================================================
alter table user_profiles enable row level security;
alter table user_preferences enable row level security;
alter table trip_lists enable row level security;
alter table saved_places enable row level security;
alter table menu_translations enable row level security;
alter table reservation_requests enable row level security;
alter table user_reports enable row level security;

-- Restaurants and photos are public-read
alter table restaurants enable row level security;
alter table restaurant_foreigner_factors enable row level security;
alter table restaurant_photos enable row level security;

create policy "Restaurants are public" on restaurants for select using (true);
create policy "Factors are public" on restaurant_foreigner_factors for select using (true);
create policy "Photos are public" on restaurant_photos for select using (true);

create policy "Users manage own profile" on user_profiles
  for all using (auth.uid() = id);
create policy "Users manage own preferences" on user_preferences
  for all using (auth.uid() = user_id);
create policy "Users manage own lists" on trip_lists
  for all using (auth.uid() = user_id);
create policy "Users manage own saved" on saved_places
  for all using (auth.uid() = user_id);
create policy "Users manage own translations" on menu_translations
  for all using (auth.uid() = user_id);
create policy "Users manage own reservations" on reservation_requests
  for all using (auth.uid() = user_id);
create policy "Users manage own reports" on user_reports
  for all using (auth.uid() = user_id);

-- ============================================================
-- Helpers
-- ============================================================

-- Find restaurants within radius_m metres of a point
create or replace function restaurants_near(
  lat double precision,
  lng double precision,
  radius_m int default 2000,
  result_limit int default 30
)
returns setof restaurants
language sql stable as $$
  select r.*
  from restaurants r
  where st_dwithin(
    r.location,
    st_makepoint(lng, lat)::geography,
    radius_m
  )
  and r.is_active = true
  order by r.location <-> st_makepoint(lng, lat)::geography
  limit result_limit;
$$;
