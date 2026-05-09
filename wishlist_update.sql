-- Kinderfest: Wunschliste-Feature
-- Im Supabase SQL Editor ausführen (zusätzlich zu setup.sql)

create table wishlist (
  id             uuid    primary key default gen_random_uuid(),
  year           integer not null default extract(year from now())::integer,
  item           text    not null,
  quantity_needed integer not null,
  created_at     timestamptz default now()
);

create index on wishlist(year);

alter table wishlist enable row level security;

create policy "public_read"   on wishlist for select using (true);
create policy "public_insert" on wishlist for insert with check (true);
create policy "public_update" on wishlist for update using (true);
create policy "public_delete" on wishlist for delete using (true);

grant select, insert, update, delete on wishlist to anon;

-- Verknüpfung: Beitrag kann einem Wunschlisten-Eintrag zugeordnet sein
alter table contributions
  add column wishlist_item_id uuid references wishlist(id) on delete set null;
