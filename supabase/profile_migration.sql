-- PCIO Toolkit Supabase profile-loading migration
-- Version: 1.1.0-profile-loading
-- Run after the previously tested schema.sql and rls_policies.sql.
--
-- Purpose:
-- - Store a sanitized project profile in projects.profile_json.
-- - Allow respondents/viewers to load only the sanitized profile through RPC.
-- - Keep profile updates restricted to service-role/backend administration.

begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

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

alter table public.projects
  add column if not exists profile_json jsonb not null default '{}'::jsonb,
  add column if not exists profile_version text not null default 'v1',
  add column if not exists profile_updated_at timestamptz not null default now();

update public.projects set profile_json = '{}'::jsonb where profile_json is null;
update public.projects set profile_version = 'v1' where profile_version is null or profile_version = '';
update public.projects set profile_updated_at = coalesce(updated_at, created_at, now()) where profile_updated_at is null;

alter table public.projects
  drop constraint if exists projects_case_type_check;

comment on column public.projects.case_type is
  'Optional short non-identifying classification. Detailed industry, enterprise size, and production mode belong in profile_json.';

comment on column public.projects.profile_json is
  'Sanitized broad company profile only, for example size band, industry category, production type, and non-sensitive pain-point categories.';
comment on column public.projects.profile_version is
  'Sanitized profile schema or release marker. This is not an enterprise identifier.';
comment on column public.projects.profile_updated_at is
  'Timestamp of the latest sanitized project-profile update.';

create or replace function public.pcio_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  if tg_table_name = 'projects'
     and (
       new.profile_json is distinct from old.profile_json
       or new.profile_version is distinct from old.profile_version
     ) then
    new.profile_updated_at = now();
  end if;
  return new;
end;
$$;

drop trigger if exists trg_projects_set_updated_at on public.projects;
create trigger trg_projects_set_updated_at
before update on public.projects
for each row execute function public.pcio_set_updated_at();

create or replace function public.pcio_sanitize_project_profile(input_profile_json jsonb)
returns jsonb
language sql
immutable
as $$
  select jsonb_strip_nulls(jsonb_build_object(
    'project_name_alias', nullif(left(coalesce(input_profile_json ->> 'project_name_alias', input_profile_json ->> 'company_name', ''), 120), ''),
    'case_type', nullif(left(coalesce(input_profile_json ->> 'case_type', ''), 40), ''),
    'industry', nullif(left(coalesce(input_profile_json ->> 'industry', ''), 80), ''),
    'industry_label', nullif(left(coalesce(input_profile_json ->> 'industry_label', ''), 120), ''),
    'enterprise_size', nullif(left(coalesce(input_profile_json ->> 'enterprise_size', input_profile_json ->> 'company_size', ''), 40), ''),
    'company_size', nullif(left(coalesce(input_profile_json ->> 'company_size', ''), 40), ''),
    'production_mode', nullif(left(coalesce(input_profile_json ->> 'production_mode', input_profile_json ->> 'production_type', ''), 80), ''),
    'production_type', nullif(left(coalesce(input_profile_json ->> 'production_type', ''), 80), ''),
    'line_name', nullif(left(coalesce(input_profile_json ->> 'line_name', input_profile_json ->> 'line_scope', ''), 120), ''),
    'existing_systems', coalesce(input_profile_json -> 'existing_systems', input_profile_json -> 'current_systems'),
    'current_systems', input_profile_json -> 'current_systems',
    'digitalisation_stage', nullif(left(coalesce(input_profile_json ->> 'digitalisation_stage', input_profile_json ->> 'automation_level', ''), 80), ''),
    'automation_level', nullif(left(coalesce(input_profile_json ->> 'automation_level', ''), 80), ''),
    'main_pain_points', coalesce(input_profile_json -> 'main_pain_points', input_profile_json -> 'pain_points'),
    'pain_points', input_profile_json -> 'pain_points',
    'selected_modules', input_profile_json -> 'selected_modules',
    'questionnaire_language', nullif(left(coalesce(input_profile_json ->> 'questionnaire_language', ''), 20), ''),
    'pilot_scope', nullif(left(coalesce(input_profile_json ->> 'pilot_scope', ''), 240), ''),
    'data_boundary', nullif(left(coalesce(input_profile_json ->> 'data_boundary', 'sanitized'), 80), ''),
    'notice', nullif(left(coalesce(input_profile_json ->> 'notice', ''), 240), '')
  ));
$$;

create or replace function public.pcio_contains_forbidden_text(input text)
returns boolean
language sql
immutable
as $$
  with source as (
    select coalesce($1, '') as s
  )
  select
    s ~* '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
    or s ~ '(\+?86[- ]?)?1[3-9][0-9]{9}'
    or s ~ '(^|[^0-9])([0-9]{17}[0-9Xx]|[0-9]{15})([^0-9]|$)'
    or s ~* '(身份证号|居民身份证|护照号|银行卡号|微信号|手机号|手机号码|联系电话|电子邮箱|邮箱|id card|identity card|passport number|bank card|wechat id|mobile phone|phone number|email address)'
    or s ~* '((详细地址|家庭住址|注册地址|办公地址|street address|home address|registered address|exact address)[:： ]+.{4,})'
    or s ~* '([一-龥A-Za-z0-9（）()?&.-]{2,80}(有限公司|有限责任公司|股份有限公司|集团有限公司))'
    or s ~* '([A-Za-z0-9&.,'' -]{2,80}\s+(Inc\.|LLC|Ltd\.|Limited|Corporation|Corp\.|Company Limited))'
    or s ~* '(统一社会信用代码|social credit code)[:： ]*[0-9A-Z]{18}'
    or s ~* '(合同编号|contract number)[:： ]*[A-Za-z0-9_-]{6,}'
    or s ~* '(真实设备编号|真实产线编号|车牌号|license plate)[:： ]*[A-Za-z0-9_-]{4,}'
  from source;
$$;

create or replace function public.pcio_contains_forbidden_text(input text)
returns boolean
language sql
immutable
as $$
  with source as (
    select coalesce($1, '') as s
  )
  select
    s ~* '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
    or s ~ '(\+?86[- ]?)?1[3-9][0-9]{9}'
    or s ~ '(^|[^0-9])([0-9]{17}[0-9Xx]|[0-9]{15})([^0-9]|$)'
    or s ~* '(身份证号|居民身份证|护照号|银行卡号|微信号|手机号|手机号码|联系电话|电子邮箱|邮箱|id card|identity card|passport number|bank card|wechat id|mobile phone|phone number|email address)'
    or s ~* '((详细地址|家庭住址|注册地址|办公地址|street address|home address|registered address|exact address)[:： ]+.{4,})'
    or s ~* '([一-龥A-Za-z0-9（）()?&.-]{2,80}(有限公司|有限责任公司|股份有限公司|集团有限公司))'
    or s ~* '([A-Za-z0-9&.,'' -]{2,80}\s+(Inc\.|LLC|Ltd\.|Limited|Corporation|Corp\.|Company Limited))'
    or s ~* '(统一社会信用代码|social credit code)[:： ]*[0-9A-Z]{18}'
    or s ~* '(合同编号|contract number)[:： ]*[A-Za-z0-9_-]{6,}'
    or s ~* '(真实设备编号|真实产线编号|车牌号|license plate)[:： ]*[A-Za-z0-9_-]{4,}'
  from source;
$$;

-- Final compatibility override for existing Supabase projects.
-- PostgreSQL does not allow CREATE OR REPLACE FUNCTION to rename an existing
-- input parameter, so this definition preserves the original parameter name:
-- public.pcio_contains_forbidden_text(input text). The function body uses $1
-- to avoid any ambiguity with the parameter name.
create or replace function public.pcio_contains_forbidden_text(input text)
returns boolean
language sql
immutable
as $$
  with source as (
    select coalesce($1, '') as s
  )
  select
    s ~* '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
    or s ~ '(\+?86[- ]?)?1[3-9][0-9]{9}'
    or s ~ '(^|[^0-9])([0-9]{17}[0-9Xx]|[0-9]{15})([^0-9]|$)'
    or s ~* '(身份证号|居民身份证|护照号|银行卡号|微信号|手机号|手机号码|联系电话|电子邮箱|邮箱|id card|identity card|passport number|bank card|wechat id|mobile phone|phone number|email address)'
    or s ~* '((详细地址|家庭住址|注册地址|办公地址|street address|home address|registered address|exact address)[:： ]+.{4,})'
    or s ~* '([一-龥A-Za-z0-9（）()?&.-]{2,80}(有限公司|有限责任公司|股份有限公司|集团有限公司))'
    or s ~* '([A-Za-z0-9&.,'' -]{2,80}\s+(Inc\.|LLC|Ltd\.|Limited|Corporation|Corp\.|Company Limited))'
    or s ~* '(统一社会信用代码|social credit code)[:： ]*[0-9A-Z]{18}'
    or s ~* '(合同编号|contract number)[:： ]*[A-Za-z0-9_-]{6,}'
    or s ~* '(真实设备编号|真实产线编号|车牌号|license plate)[:： ]*[A-Za-z0-9_-]{4,}'
  from source;
$$;

drop function if exists public.pcio_save_project_profile(text, text, jsonb, text);
drop function if exists public.pcio_get_project_profile(text, text, text);

create or replace function public.pcio_get_project_profile(
  input_project_code text,
  input_access_code text,
  input_code_type text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_payload jsonb;
  v_code_type text;
begin
  v_code_type := public.pcio_canonical_code_type(input_code_type);
  select result.project_id
    into v_project_id
  from public.pcio_find_project_by_access_code(
    input_project_code,
    input_access_code,
    v_code_type
  ) as result
  limit 1;

  if v_project_id is null then
    return jsonb_build_object('ok', false, 'message_code', 'project_or_access_code_invalid');
  end if;

  select jsonb_build_object(
    'ok', true,
    'project_code', p.project_code,
    'project_name_alias', p.project_name_alias,
    'case_type', p.case_type,
    'status', p.status,
    'access_role', case v_code_type when 'fill' then 'fill' else 'view' end,
    'profile_json', public.pcio_sanitize_project_profile(p.profile_json),
    'profile_version', p.profile_version,
    'profile_updated_at', p.profile_updated_at
  )
    into v_payload
  from public.projects p
  where p.id = v_project_id;

  if v_payload is null
     or coalesce(v_payload -> 'profile_json', '{}'::jsonb) = '{}'::jsonb then
    return jsonb_build_object('ok', false, 'message_code', 'project_profile_not_found');
  end if;

  return v_payload;
end;
$$;

create or replace function public.pcio_save_project_profile(
  input_project_code text,
  input_admin_code text,
  input_profile_json jsonb,
  input_profile_version text default 'v1'
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_claim_role text;
  v_project_code text;
  v_clean_profile jsonb;
  v_project_id uuid;
begin
  v_claim_role := coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    current_setting('role', true),
    ''
  );

  if v_claim_role <> 'service_role' then
    return jsonb_build_object('ok', false, 'message_code', 'not_authorized_for_profile_update');
  end if;

  v_project_code := public.pcio_normalize_code(input_project_code);
  if v_project_code = '' or v_project_code !~ '^[A-Z0-9_-]{3,80}$' then
    return jsonb_build_object('ok', false, 'message_code', 'invalid_project_code');
  end if;

  if input_profile_json is null or jsonb_typeof(input_profile_json) <> 'object' then
    return jsonb_build_object('ok', false, 'message_code', 'profile_json_must_be_object');
  end if;

  if public.pcio_jsonb_contains_forbidden_text(input_profile_json) then
    return jsonb_build_object('ok', false, 'message_code', 'profile_json_contains_forbidden_sensitive_text');
  end if;

  v_clean_profile := public.pcio_sanitize_project_profile(input_profile_json);

  insert into public.projects (
    project_code,
    project_name_alias,
    case_type,
    profile_json,
    profile_version,
    profile_updated_at,
    status
  )
  values (
    v_project_code,
    nullif(coalesce(v_clean_profile ->> 'project_name_alias', ''), ''),
    left(
      coalesce(
        nullif(
          lower(regexp_replace(coalesce(v_clean_profile ->> 'case_type', 'baseline'), '[^a-zA-Z0-9_-]+', '_', 'g')),
          ''
        ),
        'baseline'
      ),
      80
    ),
    v_clean_profile,
    coalesce(nullif(trim(input_profile_version), ''), 'v1'),
    now(),
    'active'
  )
  on conflict (project_code)
  do update set
    project_name_alias = excluded.project_name_alias,
    case_type = excluded.case_type,
    profile_json = excluded.profile_json,
    profile_version = excluded.profile_version,
    profile_updated_at = now(),
    updated_at = now()
  returning id into v_project_id;

  return jsonb_build_object(
    'ok', true,
    'project_code', v_project_code,
    'project_id', v_project_id,
    'profile_version', coalesce(nullif(trim(input_profile_version), ''), 'v1')
  );
end;
$$;

create or replace function public.pcio_get_analysis_results(
  input_project_code text,
  input_view_code text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_payload jsonb;
begin
  select result.project_id
    into v_project_id
  from public.pcio_find_project_by_access_code(
    input_project_code,
    input_view_code,
    'view'
  ) as result
  limit 1;

  if v_project_id is null then
    insert into public.submission_logs (
      browser_info,
      submit_status,
      message_code
    )
    values ('{}'::jsonb, 'rejected', 'invalid_project_or_view_code');

    return jsonb_build_object(
      'ok', false,
      'message_code', 'invalid_project_or_view_code'
    );
  end if;

  select jsonb_build_object(
    'ok', true,
    'project_code', p.project_code,
    'project_name_alias', p.project_name_alias,
    'project_alias', p.project_name_alias,
    'case_type', p.case_type,
    'profile_json', public.pcio_sanitize_project_profile(p.profile_json),
    'profile_version', p.profile_version,
    'profile_updated_at', p.profile_updated_at,
    'status', p.status,
    'analysis_type', ar.analysis_type,
    'build_version', ar.build_version,
    'respondent_count', ar.respondent_count,
    'response_count', ar.respondent_count,
    'result_json', ar.result_json,
    'created_at', ar.created_at
  )
    into v_payload
  from public.projects p
  left join lateral (
    select *
    from public.analysis_results ar
    where ar.project_id = p.id
    order by ar.created_at desc
    limit 1
  ) ar on true
  where p.id = v_project_id;

  insert into public.submission_logs (
    project_id,
    browser_info,
    submit_status,
    message_code
  )
  values (v_project_id, '{}'::jsonb, 'accepted', 'analysis_result_viewed');

  return coalesce(v_payload, jsonb_build_object(
    'ok', false,
    'message_code', 'no_project_found'
  ));
end;
$$;

create or replace function public.pcio_get_project_status(
  input_project_code text,
  input_view_code text
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_payload jsonb;
begin
  select result.project_id
    into v_project_id
  from public.pcio_find_project_by_access_code(
    input_project_code,
    input_view_code,
    'view'
  ) as result
  limit 1;

  if v_project_id is null then
    return jsonb_build_object(
      'ok', false,
      'message_code', 'invalid_project_or_view_code'
    );
  end if;

  select jsonb_build_object(
    'ok', true,
    'project_code', p.project_code,
    'project_name_alias', p.project_name_alias,
    'case_type', p.case_type,
    'profile_version', p.profile_version,
    'profile_updated_at', p.profile_updated_at,
    'status', p.status,
    'respondent_count', (
      select count(*) from public.respondents r where r.project_id = p.id
    ),
    'response_item_count', (
      select count(*) from public.survey_responses sr where sr.project_id = p.id
    ),
    'latest_analysis_at', (
      select max(created_at) from public.analysis_results ar where ar.project_id = p.id
    )
  )
    into v_payload
  from public.projects p
  where p.id = v_project_id;

  return v_payload;
end;
$$;

grant execute on function public.pcio_find_project_by_access_code(text, text, text)
  to anon, authenticated;
grant execute on function public.pcio_get_project_profile(text, text, text)
  to anon, authenticated;
revoke execute on function public.pcio_save_project_profile(text, text, jsonb, text)
  from public, anon, authenticated;
revoke execute on function public.pcio_sanitize_project_profile(jsonb)
  from public, anon, authenticated;

commit;

-- Verification queries for pcio_contains_forbidden_text(text).
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
  and p.proname = 'pcio_contains_forbidden_text';

select public.pcio_contains_forbidden_text('normal text') as normal_text_forbidden;
select public.pcio_contains_forbidden_text('phone number: 13800138000') as phone_text_forbidden;
