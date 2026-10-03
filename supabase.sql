-- Квантовое волонтёрство: таблица добрых дел для Supabase.
-- Выполнить один раз: Supabase → SQL Editor → вставить весь файл → Run.

create table if not exists public.deeds (
  id          text primary key check (id ~ '^[A-Z0-9]{6}$'),
  chain_id    text not null,
  parent_id   text references public.deeds(id),
  position    int  not null default 1 check (position between 1 and 1000),
  text        text not null check (char_length(text) between 3 and 140),
  amount      int  not null default 0 check (amount between 0 and 100000),
  status      text not null default 'waiting' check (status in ('waiting', 'reserved', 'claimed')),
  created_at  timestamptz not null default now(),
  reserved_at timestamptz,
  claimed_at  timestamptz
);

alter table public.deeds enable row level security;

-- Читать могут все: цепочки публичные, имён в них нет.
drop policy if exists "deeds read" on public.deeds;
create policy "deeds read" on public.deeds for select to anon using (true);

-- Добавлять можно только новые, ещё не полученные дела.
drop policy if exists "deeds insert" on public.deeds;
create policy "deeds insert" on public.deeds for insert to anon with check (status = 'waiting');

-- Менять можно только статус и только у ещё не полученных дел.
drop policy if exists "deeds update" on public.deeds;
create policy "deeds update" on public.deeds for update to anon using (status <> 'claimed') with check (true);

revoke update, delete, truncate on public.deeds from anon;
grant select, insert on public.deeds to anon;
grant update (status, reserved_at, claimed_at) on public.deeds to anon;
