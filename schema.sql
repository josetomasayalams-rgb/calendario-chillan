-- =====================================================================
--  Reservas · Departamento Chillán — esquema Supabase
--  Pega esto en: Supabase → SQL Editor → New query → Run
-- =====================================================================

create table if not exists reservations (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null,
  start_date  date not null,
  end_date    date not null,
  note        text,
  created_at  timestamptz default now()
);

-- Índice para buscar reservas por rango de fechas rápido
create index if not exists reservations_dates_idx
  on reservations (start_date, end_date);

-- Restricción: la fecha de término no puede ser anterior a la de inicio
alter table reservations
  add constraint reservations_dates_chk check (end_date >= start_date);

-- Seguridad a nivel de fila (RLS)
alter table reservations enable row level security;

drop policy if exists "public read" on reservations;
drop policy if exists "public write" on reservations;
create policy "public read"  on reservations for select using (true);
create policy "public write" on reservations for all
  using (true) with check (true);

-- Tiempo real: que los cambios se reflejen en todos los dispositivos
alter publication supabase_realtime add table reservations;
