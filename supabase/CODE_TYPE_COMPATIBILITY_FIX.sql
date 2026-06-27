-- PCIO Toolkit Supabase code-type compatibility fix
-- Purpose:
-- - Create the missing public.pcio_canonical_code_type(text) helper.
-- - Standardize canonical database access-code types to fill/view.
-- - Keep fill_code/view_code accepted as legacy input aliases.
-- - Update the project_access_codes.code_type check constraint safely.
--
-- This file is safe to rerun and does not delete project, respondent,
-- survey-response, analysis-result, profile, or access-code rows.

begin;

create or replace function public.pcio_canonical_code_type(input text)
returns text
language sql
immutable
as $$
  select case lower(btrim(coalesce(input, '')))
    when 'fill' then 'fill'
    when 'fill_code' then 'fill'
    when 'view' then 'view'
    when 'view_code' then 'view'
    else lower(btrim(coalesce(input, '')))
  end;
$$;

alter table public.project_access_codes
  drop constraint if exists project_access_codes_code_type_check;

alter table public.project_access_codes
  add constraint project_access_codes_code_type_check
    check (public.pcio_canonical_code_type(code_type) in ('fill', 'view'))
    not valid;

comment on column public.project_access_codes.code_type is
  'Canonical values are fill and view; fill_code/view_code are accepted as legacy input aliases.';

revoke execute on function public.pcio_canonical_code_type(text)
  from public, anon, authenticated;

commit;

-- Verification queries.
select public.pcio_canonical_code_type('fill') as fill_check;
select public.pcio_canonical_code_type('fill_code') as fill_code_alias_check;
select public.pcio_canonical_code_type('view') as view_check;
select public.pcio_canonical_code_type('view_code') as view_code_alias_check;

select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  pg_get_function_result(p.oid) as result_type,
  l.lanname as language,
  p.provolatile as volatility,
  p.prosecdef as security_definer
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
join pg_language l on l.oid = p.prolang
where n.nspname = 'public'
  and p.proname = 'pcio_canonical_code_type';

select
  conname,
  convalidated,
  pg_get_constraintdef(oid) as constraint_definition
from pg_constraint
where conrelid = 'public.project_access_codes'::regclass
  and conname = 'project_access_codes_code_type_check';
