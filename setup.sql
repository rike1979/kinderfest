-- Kinderfest Datenbank-Setup
-- Einmal im Supabase SQL Editor ausführen

create table guests (
  id          uuid    primary key default gen_random_uuid(),
  year        integer not null default extract(year from now())::integer,
  family_name text    not null,
  persons     text,
  arrival     text,
  departure   text,
  kloster     text,
  bedding     text,
  created_at  timestamptz default now()
);

create table contributions (
  id          uuid    primary key default gen_random_uuid(),
  year        integer not null default extract(year from now())::integer,
  family_name text    not null,
  quantity    text,
  item        text    not null,
  created_at  timestamptz default now()
);

create index on guests(year);
create index on contributions(year);

-- Row Level Security (jeder darf lesen & schreiben; Schutz läuft per Familienname im Frontend)
alter table guests        enable row level security;
alter table contributions enable row level security;

create policy "public_read"   on guests for select using (true);
create policy "public_insert" on guests for insert with check (true);
create policy "public_update" on guests for update using (true);
create policy "public_delete" on guests for delete using (true);

create policy "public_read"   on contributions for select using (true);
create policy "public_insert" on contributions for insert with check (true);
create policy "public_update" on contributions for update using (true);
create policy "public_delete" on contributions for delete using (true);
