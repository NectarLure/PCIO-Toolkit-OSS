-- PCIO Toolkit Supabase schema
-- Version: 1.0.0-final
-- Purpose: lightweight optional database route for anonymous project-code based survey storage,
-- aggregated analysis retrieval, and project-code lookup.
--
-- Privacy boundary:
-- - Do not store real names, phone numbers, WeChat IDs, identity-card numbers,
--   exact addresses, customer/supplier names, vehicle plates, or sensitive equipment IDs.
-- - project_code is a grouping code, not a public enterprise identity.
-- - respondent_code is an anonymous respondent identifier.
-- - Access codes are stored as hashes only; raw fill/view codes must never be stored.

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

create or replace function public.pcio_normalize_code(input text)
returns text
language sql
immutable
as $$
  select upper(regexp_replace(coalesce(input, ''), '\s+', '', 'g'));
$$;

create or replace function public.pcio_canonical_code_type(input_code_type text)
returns text
language sql
immutable
as $$
  select case lower(coalesce(input_code_type, ''))
    when 'fill' then 'fill_code'
    when 'fill_code' then 'fill_code'
    when 'view' then 'view_code'
    when 'view_code' then 'view_code'
    else null
  end;
$$;

create or replace function public.pcio_hash_access_code(raw_code text)
returns text
language sql
strict
security definer
set search_path = public, extensions
as $$
  select extensions.crypt(public.pcio_normalize_code(raw_code), extensions.gen_salt('bf', 10));
$$;

create or replace function public.pcio_verify_access_code(raw_code text, code_hash text)
returns boolean
language sql
strict
security definer
set search_path = public, extensions
as $$
  select extensions.crypt(public.pcio_normalize_code(raw_code), code_hash) = code_hash;
$$;

create table if not exists public.projects (
  id uuid primary key default extensions.gen_random_uuid(),
  project_code text not null unique,
  project_name_alias text,
  case_type text not null default 'baseline',
  schema_version text not null default '3.0.0',
  toolkit_version text not null default '1.1.0',
  profile_json jsonb not null default '{}'::jsonb,
  status text not null default 'active',
  allow_open_text boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  closed_at timestamptz,
  expires_at timestamptz,
  constraint projects_code_format
    check (
      project_code = public.pcio_normalize_code(project_code)
      and project_code ~ '^[A-Z0-9_-]{3,80}$'
    ),
  constraint projects_profile_is_object
    check (jsonb_typeof(profile_json) = 'object')
);

alter table public.projects
  add column if not exists project_name_alias text,
  add column if not exists case_type text not null default 'baseline',
  add column if not exists status text not null default 'active',
  add column if not exists allow_open_text boolean not null default false,
  add column if not exists closed_at timestamptz,
  add column if not exists expires_at timestamptz;

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'projects'
      and column_name = 'project_alias'
  ) then
    execute 'update public.projects
                set project_name_alias = project_alias
              where project_name_alias is null
                and project_alias is not null';
  end if;
end $$;

update public.projects set status = 'active' where status is null;
update public.projects set case_type = 'baseline' where case_type is null;

alter table public.projects
  drop constraint if exists projects_status_check,
  add constraint projects_status_check
    check (status in ('active', 'closed', 'archived'));

alter table public.projects
  drop constraint if exists projects_case_type_check,
  add constraint projects_case_type_check
    check (case_type in ('baseline', 'demo', 'pilot', 'expert_review', 'training', 'other'));

comment on table public.projects is
  'Anonymous PCIO project groups. Do not store legal company names, exact addresses, customer/supplier names, or other sensitive identifiers.';
comment on column public.projects.project_code is
  'Non-identifying project grouping code used by respondents and authorized viewers.';
comment on column public.projects.project_name_alias is
  'Optional anonymized project alias, for example Process Demo A. Do not store a legal enterprise name.';
comment on column public.projects.case_type is
  'Broad project category such as baseline, demo, pilot, expert_review, training, or other.';
comment on column public.projects.profile_json is
  'Sanitized broad company profile only, for example size band, industry category, production type, and non-sensitive pain-point categories.';

create table if not exists public.project_access_codes (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  code_type text not null,
  code_hash text not null,
  code_label text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  expires_at timestamptz,
  last_used_at timestamptz,
  constraint project_access_codes_code_type_check
    check (public.pcio_canonical_code_type(code_type) in ('fill_code', 'view_code'))
);

alter table public.project_access_codes
  drop constraint if exists project_access_codes_code_type_check,
  add constraint project_access_codes_code_type_check
    check (public.pcio_canonical_code_type(code_type) in ('fill_code', 'view_code'));

drop index if exists public.uq_project_access_codes_one_active;
create unique index uq_project_access_codes_one_active
  on public.project_access_codes(project_id, public.pcio_canonical_code_type(code_type))
  where is_active;

create index if not exists idx_project_access_codes_project_type
  on public.project_access_codes(project_id, code_type, is_active);

comment on table public.project_access_codes is
  'Hashed fill/view access-code records. Raw codes must never be stored.';
comment on column public.project_access_codes.code_type is
  'Supports fill/view aliases and canonical fill_code/view_code values.';
comment on column public.project_access_codes.code_hash is
  'Cryptographic hash generated with pcio_hash_access_code(raw_code).';

create table if not exists public.respondents (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  respondent_code text not null,
  respondent_meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint respondents_unique_code_per_project
    unique (project_id, respondent_code),
  constraint respondents_code_format
    check (
      respondent_code = public.pcio_normalize_code(respondent_code)
      and respondent_code ~ '^[A-Z0-9_-]{1,80}$'
    ),
  constraint respondents_meta_is_object
    check (jsonb_typeof(respondent_meta) = 'object')
);

comment on table public.respondents is
  'Anonymous respondent registry. respondent_code must not contain real names, phone numbers, or personal identifiers.';
comment on column public.respondents.respondent_meta is
  'Optional non-sensitive metadata, such as role group, tenure band, shift type, and digital exposure level.';

create table if not exists public.survey_responses (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  respondent_id uuid references public.respondents(id) on delete set null,
  respondent_code text not null,
  submission_id text not null,
  item_code text not null,
  pcio_layer text not null
    check (pcio_layer in ('P', 'C', 'I', 'O', 'H', 'B', 'R', 'PROFILE', 'META', 'OTHER')),
  answer_value jsonb not null default 'null'::jsonb,
  answer_type text not null default 'unknown',
  schema_version text not null default '3.0.0',
  created_at timestamptz not null default now(),
  constraint survey_responses_unique_item_per_submission
    unique (project_id, submission_id, item_code),
  constraint survey_responses_item_code_format
    check (item_code ~ '^[A-Za-z0-9_:-]{1,80}$'),
  constraint survey_responses_respondent_code_format
    check (
      respondent_code = public.pcio_normalize_code(respondent_code)
      and respondent_code ~ '^[A-Z0-9_-]{1,80}$'
    )
);

create index if not exists idx_survey_responses_project_respondent
  on public.survey_responses(project_id, respondent_code);

create index if not exists idx_survey_responses_project_layer
  on public.survey_responses(project_id, pcio_layer);

create index if not exists idx_survey_responses_item_code
  on public.survey_responses(item_code);

comment on table public.survey_responses is
  'Item-level questionnaire answers. Raw table reads are blocked by RLS; use approved RPC functions only.';
comment on column public.survey_responses.answer_value is
  'Likert, multiple-choice, ranking, or sanitized value. Open text is disabled by default at project level.';

create table if not exists public.analysis_results (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  project_code text not null,
  result_json jsonb not null default '{}'::jsonb,
  respondent_count integer not null default 0 check (respondent_count >= 0),
  analysis_type text not null default 'baseline',
  build_version text not null default 'pcio-web-1.0.0',
  created_at timestamptz not null default now(),
  constraint analysis_results_result_is_object
    check (jsonb_typeof(result_json) = 'object'),
  constraint analysis_results_project_code_format
    check (
      project_code = public.pcio_normalize_code(project_code)
      and project_code ~ '^[A-Z0-9_-]{3,80}$'
    )
);

alter table public.analysis_results
  add column if not exists project_code text,
  add column if not exists result_json jsonb not null default '{}'::jsonb,
  add column if not exists respondent_count integer not null default 0,
  add column if not exists analysis_type text not null default 'baseline',
  add column if not exists build_version text not null default 'pcio-web-1.0.0',
  add column if not exists created_at timestamptz not null default now();

do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'analysis_results'
      and column_name = 'response_count'
  ) then
    execute 'update public.analysis_results
                set respondent_count = greatest(coalesce(respondent_count, 0), coalesce(response_count, 0))';
  end if;

  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'analysis_results'
      and column_name = 'analysis_version'
  ) then
    execute 'update public.analysis_results
                set analysis_type = coalesce(nullif(analysis_type, ''''), nullif(analysis_version, ''''), ''baseline'')';
  end if;
end $$;

update public.analysis_results ar
   set project_code = p.project_code
  from public.projects p
 where ar.project_id = p.id
   and (ar.project_code is null or ar.project_code = '');

alter table public.analysis_results
  alter column project_code set not null,
  alter column respondent_count set not null,
  alter column analysis_type set not null,
  alter column build_version set not null;

alter table public.analysis_results
  drop constraint if exists analysis_results_respondent_count_check,
  add constraint analysis_results_respondent_count_check
    check (respondent_count >= 0);

alter table public.analysis_results
  drop constraint if exists analysis_results_result_is_object,
  add constraint analysis_results_result_is_object
    check (jsonb_typeof(result_json) = 'object');

alter table public.analysis_results
  drop constraint if exists analysis_results_project_code_format,
  add constraint analysis_results_project_code_format
    check (
      project_code = public.pcio_normalize_code(project_code)
      and project_code ~ '^[A-Z0-9_-]{3,80}$'
    );

create index if not exists idx_analysis_results_project_created
  on public.analysis_results(project_id, created_at desc);

create index if not exists idx_analysis_results_project_code_created
  on public.analysis_results(project_code, created_at desc);

comment on table public.analysis_results is
  'Project-level summary analysis output. result_json stores aggregated results, not raw personal or enterprise-sensitive data.';
comment on column public.analysis_results.result_json is
  'Aggregated PCIO maturity, risk, KPI, ROI scenario estimates, and report summaries. ROI is scenario planning, not verified financial return.';
comment on column public.analysis_results.analysis_type is
  'Analysis category, for example baseline, followup_3m, followup_6m, demo, or test.';
comment on column public.analysis_results.build_version is
  'Frontend/toolkit build version that generated the result.';

create table if not exists public.submission_logs (
  id uuid primary key default extensions.gen_random_uuid(),
  project_id uuid references public.projects(id) on delete set null,
  respondent_code text,
  submission_id text,
  submitted_at timestamptz not null default now(),
  browser_info jsonb not null default '{}'::jsonb,
  submit_status text not null
    check (submit_status in ('accepted', 'rejected', 'duplicate', 'error')),
  message_code text,
  created_at timestamptz not null default now(),
  constraint submission_logs_browser_is_object
    check (jsonb_typeof(browser_info) = 'object')
);

create index if not exists idx_submission_logs_project_time
  on public.submission_logs(project_id, submitted_at desc);

create index if not exists idx_submission_logs_status
  on public.submission_logs(submit_status);

comment on table public.submission_logs is
  'Submission audit log with only basic browser/runtime information. Do not store IP addresses, full user-agent strings, names, phone numbers, addresses, or enterprise-sensitive identifiers.';

create or replace function public.pcio_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_projects_set_updated_at on public.projects;
create trigger trg_projects_set_updated_at
before update on public.projects
for each row execute function public.pcio_set_updated_at();

create or replace function public.pcio_contains_forbidden_text(input_text text)
returns boolean
language sql
immutable
as $$
  with source as (
    select coalesce(input_text, '') as s
  )
  select
    s ~* '[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}'
    or s ~ '(\+?86[- ]?)?1[3-9][0-9]{9}'
    or s ~ '(^|[^0-9])([0-9]{17}[0-9Xx]|[0-9]{15})([^0-9]|$)'
    or s ~* '(身份证|居民身份证|护照号|银行卡号|微信号|手机号|手机号码|联系电话|电子邮箱|邮箱|id card|identity card|passport number|bank card|wechat id|mobile phone|phone number|email address)'
    or s ~* '(详细地址|家庭住址|注册地址|办公地址|门牌号|楼栋号|经纬度|street address|home address|registered address|exact address|latitude|longitude)'
    or s ~* '([一-龥A-Za-z0-9（）()·&.-]{2,80}(有限公司|有限责任公司|股份有限公司|集团有限公司|公司全称))'
    or s ~* '([A-Za-z0-9&.,'' -]{2,80}\s+(Inc\.|LLC|Ltd\.|Limited|Corporation|Corp\.|Company Limited))'
    or s ~* '([京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼][A-Z][A-Z0-9]{5})'
  from source;
$$;

create or replace function public.pcio_jsonb_contains_forbidden_text(payload jsonb)
returns boolean
language sql
immutable
as $$
  with recursive walk(value) as (
    select coalesce(payload, 'null'::jsonb)
    union all
    select child.value
    from walk w
    cross join lateral (
      select value
      from jsonb_array_elements(
        case when jsonb_typeof(w.value) = 'array' then w.value else '[]'::jsonb end
      )
      union all
      select value
      from jsonb_each(
        case when jsonb_typeof(w.value) = 'object' then w.value else '{}'::jsonb end
      )
    ) child
  )
  select exists (
    select 1
    from walk
    where jsonb_typeof(value) = 'string'
      and public.pcio_contains_forbidden_text(value #>> '{}')
  );
$$;

create or replace function public.pcio_sanitize_browser_info(payload jsonb)
returns jsonb
language sql
immutable
as $$
  select jsonb_strip_nulls(jsonb_build_object(
    'browser', left(coalesce(payload ->> 'browser', ''), 40),
    'browser_version', left(coalesce(payload ->> 'browser_version', ''), 20),
    'language', left(coalesce(payload ->> 'language', ''), 20),
    'timezone_offset_minutes', payload ->> 'timezone_offset_minutes',
    'viewport', payload -> 'viewport',
    'platform', left(coalesce(payload ->> 'platform', ''), 40),
    'app_version', left(coalesce(payload ->> 'app_version', ''), 40)
  ));
$$;

drop function if exists public.pcio_get_project_status(text, text);
drop function if exists public.pcio_get_analysis_results(text, text);
drop function if exists public.pcio_save_analysis_result(text, text, jsonb, integer, text, text);
drop function if exists public.pcio_submit_survey_response(text, text, text, text, jsonb, jsonb, jsonb);
drop function if exists public.pcio_find_project_by_access_code(text, text, text);

create or replace function public.pcio_find_project_by_access_code(
  input_project_code text,
  input_access_code text,
  input_code_type text
)
returns uuid
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_code_type text;
begin
  v_code_type := public.pcio_canonical_code_type(input_code_type);

  if v_code_type is null then
    return null;
  end if;

  if coalesce(input_project_code, '') = '' or coalesce(input_access_code, '') = '' then
    return null;
  end if;

  select p.id
    into v_project_id
  from public.projects p
  join public.project_access_codes ac
    on ac.project_id = p.id
  where p.project_code = public.pcio_normalize_code(input_project_code)
    and public.pcio_canonical_code_type(ac.code_type) = v_code_type
    and ac.is_active = true
    and (ac.expires_at is null or ac.expires_at > now())
    and (p.expires_at is null or p.expires_at > now())
    and (
      (v_code_type = 'fill_code' and p.status = 'active')
      or (v_code_type = 'view_code' and p.status in ('active', 'closed', 'archived'))
    )
    and public.pcio_verify_access_code(input_access_code, ac.code_hash)
  limit 1;

  if v_project_id is not null then
    update public.project_access_codes
       set last_used_at = now()
     where project_id = v_project_id
       and public.pcio_canonical_code_type(code_type) = v_code_type
       and is_active = true;
  end if;

  return v_project_id;
end;
$$;

create or replace function public.pcio_submit_survey_response(
  input_project_code text,
  input_fill_code text,
  input_respondent_code text,
  input_role_group text,
  input_profile_json jsonb,
  input_response_json jsonb,
  input_browser_info jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_project_allows_open_text boolean;
  v_respondent_id uuid;
  v_respondent_code text;
  v_submission_id text;
  v_answer jsonb;
  v_answers jsonb;
  v_item_code text;
  v_layer text;
  v_answer_type text;
  v_answer_value jsonb;
  v_meta jsonb;
  v_saved_count integer := 0;
begin
  v_project_id := public.pcio_find_project_by_access_code(
    input_project_code,
    input_fill_code,
    'fill_code'
  );

  v_submission_id := replace(extensions.gen_random_uuid()::text, '-', '');
  v_respondent_code := public.pcio_normalize_code(
    coalesce(nullif(trim(input_respondent_code), ''), 'R-' || left(extensions.gen_random_uuid()::text, 8))
  );

  if v_respondent_code !~ '^[A-Z0-9_-]{1,80}$' then
    v_respondent_code := 'R-' || left(extensions.gen_random_uuid()::text, 8);
  end if;

  if v_project_id is null then
    insert into public.submission_logs (
      respondent_code,
      submission_id,
      browser_info,
      submit_status,
      message_code
    )
    values (
      v_respondent_code,
      v_submission_id,
      public.pcio_sanitize_browser_info(coalesce(input_browser_info, '{}'::jsonb)),
      'rejected',
      'invalid_project_or_fill_code'
    );

    return jsonb_build_object(
      'ok', false,
      'message_code', 'invalid_project_or_fill_code'
    );
  end if;

  select allow_open_text
    into v_project_allows_open_text
  from public.projects
  where id = v_project_id;

  if input_profile_json is not null
     and jsonb_typeof(input_profile_json) <> 'object' then
    return jsonb_build_object(
      'ok', false,
      'message_code', 'profile_json_must_be_object'
    );
  end if;

  if public.pcio_jsonb_contains_forbidden_text(coalesce(input_profile_json, '{}'::jsonb)) then
    return jsonb_build_object(
      'ok', false,
      'message_code', 'forbidden_sensitive_metadata'
    );
  end if;

  v_answers := case
    when input_response_json is null then null
    when jsonb_typeof(input_response_json) = 'array' then input_response_json
    when jsonb_typeof(input_response_json) = 'object'
      and jsonb_typeof(input_response_json -> 'answers') = 'array'
      then input_response_json -> 'answers'
    else null
  end;

  if v_answers is null then
    insert into public.submission_logs (
      project_id,
      respondent_code,
      submission_id,
      browser_info,
      submit_status,
      message_code
    )
    values (
      v_project_id,
      v_respondent_code,
      v_submission_id,
      public.pcio_sanitize_browser_info(coalesce(input_browser_info, '{}'::jsonb)),
      'rejected',
      'response_json_must_be_array'
    );

    return jsonb_build_object(
      'ok', false,
      'message_code', 'response_json_must_be_array'
    );
  end if;

  v_meta := coalesce(input_profile_json, '{}'::jsonb)
    || jsonb_build_object('role_group', coalesce(nullif(trim(input_role_group), ''), 'unspecified'));

  insert into public.respondents (
    project_id,
    respondent_code,
    respondent_meta
  )
  values (
    v_project_id,
    v_respondent_code,
    v_meta
  )
  on conflict (project_id, respondent_code)
  do update set respondent_meta = excluded.respondent_meta
  returning id into v_respondent_id;

  for v_answer in select * from jsonb_array_elements(v_answers)
  loop
    v_item_code := coalesce(v_answer ->> 'item_code', '');
    v_layer := upper(coalesce(v_answer ->> 'pcio_layer', 'OTHER'));
    v_answer_type := coalesce(v_answer ->> 'answer_type', 'unknown');
    v_answer_value := coalesce(v_answer -> 'answer_value', 'null'::jsonb);

    if v_item_code !~ '^[A-Za-z0-9_:-]{1,80}$' then
      continue;
    end if;

    if v_layer not in ('P', 'C', 'I', 'O', 'H', 'B', 'R', 'PROFILE', 'META', 'OTHER') then
      v_layer := 'OTHER';
    end if;

    if v_answer_type in ('open_text', 'textarea', 'free_text') then
      if not v_project_allows_open_text then
        continue;
      end if;
    end if;

    if public.pcio_jsonb_contains_forbidden_text(v_answer_value) then
      v_answer_value := to_jsonb('[redacted_by_database_policy]'::text);
    end if;

    insert into public.survey_responses (
      project_id,
      respondent_id,
      respondent_code,
      submission_id,
      item_code,
      pcio_layer,
      answer_value,
      answer_type
    )
    values (
      v_project_id,
      v_respondent_id,
      v_respondent_code,
      v_submission_id,
      v_item_code,
      v_layer,
      v_answer_value,
      v_answer_type
    )
    on conflict (project_id, submission_id, item_code)
    do update set
      respondent_id = excluded.respondent_id,
      respondent_code = excluded.respondent_code,
      pcio_layer = excluded.pcio_layer,
      answer_value = excluded.answer_value,
      answer_type = excluded.answer_type;

    v_saved_count := v_saved_count + 1;
  end loop;

  insert into public.submission_logs (
    project_id,
    respondent_code,
    submission_id,
    browser_info,
    submit_status,
    message_code
  )
  values (
    v_project_id,
    v_respondent_code,
    v_submission_id,
    public.pcio_sanitize_browser_info(coalesce(input_browser_info, '{}'::jsonb)),
    'accepted',
    'survey_saved'
  );

  return jsonb_build_object(
    'ok', true,
    'project_code', public.pcio_normalize_code(input_project_code),
    'respondent_code', v_respondent_code,
    'submission_id', v_submission_id,
    'saved_count', v_saved_count
  );
exception
  when others then
    insert into public.submission_logs (
      project_id,
      respondent_code,
      submission_id,
      browser_info,
      submit_status,
      message_code
    )
    values (
      v_project_id,
      v_respondent_code,
      coalesce(v_submission_id, replace(extensions.gen_random_uuid()::text, '-', '')),
      public.pcio_sanitize_browser_info(coalesce(input_browser_info, '{}'::jsonb)),
      'error',
      'submission_error'
    );

    return jsonb_build_object(
      'ok', false,
      'message_code', 'submission_error'
    );
end;
$$;

create or replace function public.pcio_save_analysis_result(
  input_project_code text,
  input_view_code text,
  input_result_json jsonb,
  input_respondent_count integer default 0,
  input_analysis_type text default 'baseline',
  input_build_version text default 'pcio-web-1.0.0'
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_id uuid;
  v_project_code text;
  v_result_id uuid;
  v_created_at timestamptz;
begin
  v_project_id := public.pcio_find_project_by_access_code(
    input_project_code,
    input_view_code,
    'view_code'
  );

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

  if input_result_json is null or jsonb_typeof(input_result_json) <> 'object' then
    return jsonb_build_object(
      'ok', false,
      'message_code', 'result_json_must_be_object'
    );
  end if;

  if public.pcio_jsonb_contains_forbidden_text(input_result_json) then
    return jsonb_build_object(
      'ok', false,
      'message_code', 'result_json_contains_forbidden_sensitive_text'
    );
  end if;

  select project_code
    into v_project_code
  from public.projects
  where id = v_project_id;

  insert into public.analysis_results (
    project_id,
    project_code,
    result_json,
    respondent_count,
    analysis_type,
    build_version
  )
  values (
    v_project_id,
    v_project_code,
    input_result_json,
    greatest(coalesce(input_respondent_count, 0), 0),
    coalesce(nullif(trim(input_analysis_type), ''), 'baseline'),
    coalesce(nullif(trim(input_build_version), ''), 'pcio-web-1.0.0')
  )
  returning id, created_at into v_result_id, v_created_at;

  insert into public.submission_logs (
    project_id,
    browser_info,
    submit_status,
    message_code
  )
  values (v_project_id, '{}'::jsonb, 'accepted', 'analysis_result_saved');

  return jsonb_build_object(
    'ok', true,
    'project_code', v_project_code,
    'result_id', v_result_id,
    'created_at', v_created_at
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
  v_project_id := public.pcio_find_project_by_access_code(
    input_project_code,
    input_view_code,
    'view_code'
  );

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
    'profile_json', p.profile_json,
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
  v_project_id := public.pcio_find_project_by_access_code(
    input_project_code,
    input_view_code,
    'view_code'
  );

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
