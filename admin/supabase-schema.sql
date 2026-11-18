-- The Data Lens: initial Supabase schema
-- Run in Supabase SQL Editor after creating your project.
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.admin_users enable row level security;
drop policy if exists "Admin can read own allow-list row" on public.admin_users;
create policy "Admin can read own allow-list row" on public.admin_users
for select to authenticated using (user_id = auth.uid());

create or replace function public.is_data_lens_admin()
returns boolean language sql stable security definer
set search_path = public
as $$ select exists (select 1 from public.admin_users where user_id = auth.uid()); $$;
revoke all on function public.is_data_lens_admin() from public;
grant execute on function public.is_data_lens_admin() to authenticated;

create table if not exists public.articles (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  geography text,
  summary text,
  body text not null default '',
  source_url text,
  reporting_period text,
  status text not null default 'draft' check (status in ('draft','scheduled','published','archived')),
  scheduled_at timestamptz,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  published_at timestamptz
);
create table if not exists public.article_versions (
  id uuid primary key default gen_random_uuid(),
  article_id uuid not null references public.articles(id) on delete cascade,
  version_data jsonb not null,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.datasets (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null,
  geography text,
  source_url text,
  reporting_period text,
  file_path text not null,
  file_name text not null,
  mime_type text,
  row_count integer not null default 0,
  column_names text[] not null default '{}',
  parsed_data jsonb not null default '[]',
  quality_report jsonb not null default '[]',
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);
create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references auth.users(id),
  action text not null,
  entity_type text,
  entity_id uuid,
  details jsonb not null default '{}',
  created_at timestamptz not null default now()
);

alter table public.articles enable row level security;
alter table public.article_versions enable row level security;
alter table public.datasets enable row level security;
alter table public.audit_logs enable row level security;

drop policy if exists "Public reads published articles" on public.articles;
create policy "Public reads published articles" on public.articles
for select to anon, authenticated using (status = 'published');
drop policy if exists "Admins manage articles" on public.articles;
create policy "Admins manage articles" on public.articles
for all to authenticated using (public.is_data_lens_admin()) with check (public.is_data_lens_admin());

drop policy if exists "Admins manage article versions" on public.article_versions;
create policy "Admins manage article versions" on public.article_versions
for all to authenticated using (public.is_data_lens_admin()) with check (public.is_data_lens_admin());

drop policy if exists "Admins manage datasets" on public.datasets;
create policy "Admins manage datasets" on public.datasets
for all to authenticated using (public.is_data_lens_admin()) with check (public.is_data_lens_admin());

drop policy if exists "Admins read audit logs" on public.audit_logs;
create policy "Admins read audit logs" on public.audit_logs
for select to authenticated using (public.is_data_lens_admin());
drop policy if exists "Admins add audit logs" on public.audit_logs;
create policy "Admins add audit logs" on public.audit_logs
for insert to authenticated with check (public.is_data_lens_admin());

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('research-files','research-files',false,52428800,
array['text/csv','application/json','application/pdf','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet','application/vnd.ms-excel','image/png','image/jpeg','image/webp','image/svg+xml'])
on conflict (id) do nothing;

drop policy if exists "Admins upload own research files" on storage.objects;
create policy "Admins upload own research files" on storage.objects
for insert to authenticated with check (bucket_id = 'research-files' and (storage.foldername(name))[1] = auth.uid()::text and public.is_data_lens_admin());
drop policy if exists "Admins read research files" on storage.objects;
create policy "Admins read research files" on storage.objects
for select to authenticated using (bucket_id = 'research-files' and public.is_data_lens_admin());
drop policy if exists "Admins update research files" on storage.objects;
create policy "Admins update research files" on storage.objects
for update to authenticated using (bucket_id = 'research-files' and public.is_data_lens_admin()) with check (bucket_id = 'research-files' and public.is_data_lens_admin());
drop policy if exists "Admins delete research files" on storage.objects;
create policy "Admins delete research files" on storage.objects
for delete to authenticated using (bucket_id = 'research-files' and public.is_data_lens_admin());

-- After creating your user in Supabase Authentication, add that user's UUID:
-- insert into public.admin_users (user_id) values ('YOUR-AUTH-USER-UUID');
