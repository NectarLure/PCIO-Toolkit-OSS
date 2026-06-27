-- PCIO Toolkit Supabase project-profile UUID assignment fix
-- Purpose:
-- - Adapt RPC callers to the current composite-row return of
--   public.pcio_find_project_by_access_code(text, text, text).
-- - Do not change function signatures, return types, tables, RLS, or data.
-- - Do not rerun test_seed.

begin;

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
  select result.project_id
    into v_project_id
  from public.pcio_find_project_by_access_code(
    input_project_code,
    input_fill_code,
    'fill'
  ) as result
  limit 1;

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
    return jsonb_build_object(
      'ok', false,
      'message_code', 'project_or_access_code_invalid'
    );
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
    return jsonb_build_object(
      'ok', false,
      'message_code', 'project_profile_not_found'
    );
  end if;

  return v_payload;
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

commit;

-- Verification query requested for the fixed project-profile RPC.
select *
from public.pcio_get_project_profile(
  'TEST-PCIO-001',
  'FILL-TEST-PCIO-001',
  'fill'
);

-- Function metadata checks for the affected RPCs.
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
  and p.proname in (
    'pcio_submit_survey_response',
    'pcio_get_project_profile',
    'pcio_save_analysis_result',
    'pcio_get_analysis_results',
    'pcio_get_project_status'
  )
order by p.proname;
