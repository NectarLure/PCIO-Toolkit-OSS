-- PCIO Toolkit cross-device project profile creation RPC
-- Purpose:
-- - Allow the public website to save a sanitized company profile to Supabase.
-- - Create or safely update the project and hashed fill/view access codes.
-- - Keep direct table access blocked by RLS.
--
-- Run this file in Supabase SQL Editor after the base schema/RLS files.

begin;

create schema if not exists extensions;
create extension if not exists pgcrypto with schema extensions;

drop function if exists public.pcio_create_project_with_profile(text, text, text, text, text, jsonb, text);

create or replace function public.pcio_create_project_with_profile(
  input_project_code text,
  input_fill_code text,
  input_view_code text,
  input_project_name_alias text,
  input_case_type text,
  input_profile_json jsonb,
  input_profile_version text default 'v1'
)
returns jsonb
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_project_code text;
  v_fill_code text;
  v_view_code text;
  v_alias text;
  v_case_type text;
  v_profile_version text;
  v_clean_profile jsonb;
  v_project_id uuid;
  v_existing_project_id uuid;
  v_fill_access_id uuid;
  v_view_access_id uuid;
  v_fill_matches boolean := false;
  v_view_matches boolean := false;
  v_created_count integer := 0;
begin
  v_project_code := public.pcio_normalize_code(input_project_code);
  v_fill_code := public.pcio_normalize_code(input_fill_code);
  v_view_code := public.pcio_normalize_code(input_view_code);
  v_alias := nullif(left(trim(coalesce(input_project_name_alias, '')), 120), '');
  v_case_type := left(
    coalesce(
      nullif(lower(regexp_replace(coalesce(input_case_type, 'self_service'), '[^a-zA-Z0-9_-]+', '_', 'g')), ''),
      'self_service'
    ),
    80
  );
  v_profile_version := coalesce(nullif(trim(input_profile_version), ''), 'web-profile-v1');

  if v_project_code = '' or v_project_code !~ '^[A-Z0-9_-]{3,80}$' then
    return jsonb_build_object('ok', false, 'message_code', 'invalid_project_code');
  end if;

  if v_fill_code = '' or v_fill_code !~ '^[A-Z0-9_-]{8,120}$' then
    return jsonb_build_object('ok', false, 'message_code', 'invalid_fill_code');
  end if;

  if v_view_code = '' or v_view_code !~ '^[A-Z0-9_-]{8,120}$' then
    return jsonb_build_object('ok', false, 'message_code', 'invalid_view_code');
  end if;

  if v_fill_code = v_view_code then
    return jsonb_build_object('ok', false, 'message_code', 'fill_view_code_must_differ');
  end if;

  if input_profile_json is null or jsonb_typeof(input_profile_json) <> 'object' then
    return jsonb_build_object('ok', false, 'message_code', 'profile_json_must_be_object');
  end if;

  if public.pcio_contains_forbidden_text(coalesce(input_project_name_alias, ''))
     or public.pcio_jsonb_contains_forbidden_text(input_profile_json) then
    return jsonb_build_object('ok', false, 'message_code', 'forbidden_sensitive_text');
  end if;

  v_clean_profile := public.pcio_sanitize_project_profile(
    input_profile_json ||
    jsonb_build_object(
      'project_name_alias', coalesce(v_alias, input_profile_json ->> 'project_name_alias', 'Project ' || v_project_code),
      'case_type', v_case_type,
      'data_boundary', coalesce(input_profile_json ->> 'data_boundary', 'sanitized')
    )
  );

  if public.pcio_jsonb_contains_forbidden_text(v_clean_profile) then
    return jsonb_build_object('ok', false, 'message_code', 'forbidden_sensitive_text');
  end if;

  select p.id
    into v_existing_project_id
  from public.projects p
  where p.project_code = v_project_code
  for update;

  if v_existing_project_id is not null then
    select exists (
      select 1
      from public.project_access_codes ac
      where ac.project_id = v_existing_project_id
        and public.pcio_canonical_code_type(ac.code_type) = 'fill'
        and ac.is_active
        and (ac.expires_at is null or ac.expires_at > now())
        and public.pcio_verify_access_code(v_fill_code, ac.code_hash)
    )
      into v_fill_matches;

    select exists (
      select 1
      from public.project_access_codes ac
      where ac.project_id = v_existing_project_id
        and public.pcio_canonical_code_type(ac.code_type) = 'view'
        and ac.is_active
        and (ac.expires_at is null or ac.expires_at > now())
        and public.pcio_verify_access_code(v_view_code, ac.code_hash)
    )
      into v_view_matches;

    if not (v_fill_matches and v_view_matches) then
      return jsonb_build_object('ok', false, 'message_code', 'project_code_exists');
    end if;

    update public.projects
       set project_name_alias = coalesce(v_clean_profile ->> 'project_name_alias', project_name_alias),
           case_type = v_case_type,
           profile_json = v_clean_profile,
           profile_version = v_profile_version,
           profile_updated_at = now(),
           status = 'active',
           updated_at = now()
     where id = v_existing_project_id
     returning id into v_project_id;
  else
    select count(*)
      into v_created_count
    from public.projects
    where created_at >= now() - interval '1 hour';

    if v_created_count >= 200 then
      return jsonb_build_object('ok', false, 'message_code', 'rate_limited');
    end if;

    insert into public.projects (
      project_code,
      project_name_alias,
      case_type,
      schema_version,
      toolkit_version,
      profile_json,
      profile_version,
      profile_updated_at,
      status,
      allow_open_text
    )
    values (
      v_project_code,
      coalesce(v_clean_profile ->> 'project_name_alias', 'Project ' || v_project_code),
      v_case_type,
      coalesce(input_profile_json ->> 'schema_version', '3.0.0'),
      coalesce(input_profile_json ->> 'toolkit_version', '1.1.0'),
      v_clean_profile,
      v_profile_version,
      now(),
      'active',
      false
    )
    returning id into v_project_id;
  end if;

  select id
    into v_fill_access_id
  from public.project_access_codes
  where project_id = v_project_id
    and public.pcio_canonical_code_type(code_type) = 'fill'
    and is_active
  order by created_at
  limit 1;

  if v_fill_access_id is null then
    insert into public.project_access_codes (
      project_id,
      code_type,
      code_hash,
      code_label,
      is_active
    )
    values (
      v_project_id,
      'fill',
      public.pcio_hash_access_code(v_fill_code),
      'Self-service fill code',
      true
    )
    returning id into v_fill_access_id;
  else
    update public.project_access_codes
       set code_type = 'fill',
           code_hash = public.pcio_hash_access_code(v_fill_code),
           code_label = coalesce(code_label, 'Self-service fill code'),
           is_active = true,
           expires_at = null
     where id = v_fill_access_id;
  end if;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) = 'fill'
     and id <> v_fill_access_id;

  select id
    into v_view_access_id
  from public.project_access_codes
  where project_id = v_project_id
    and public.pcio_canonical_code_type(code_type) = 'view'
    and is_active
  order by created_at
  limit 1;

  if v_view_access_id is null then
    insert into public.project_access_codes (
      project_id,
      code_type,
      code_hash,
      code_label,
      is_active
    )
    values (
      v_project_id,
      'view',
      public.pcio_hash_access_code(v_view_code),
      'Self-service view code',
      true
    )
    returning id into v_view_access_id;
  else
    update public.project_access_codes
       set code_type = 'view',
           code_hash = public.pcio_hash_access_code(v_view_code),
           code_label = coalesce(code_label, 'Self-service view code'),
           is_active = true,
           expires_at = null
     where id = v_view_access_id;
  end if;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) = 'view'
     and id <> v_view_access_id;

  return jsonb_build_object(
    'ok', true,
    'message_code', 'project_profile_saved',
    'project_code', v_project_code,
    'fill_code', v_fill_code,
    'view_code', v_view_code,
    'project_name_alias', coalesce(v_clean_profile ->> 'project_name_alias', 'Project ' || v_project_code),
    'profile_version', v_profile_version
  );
end;
$$;

grant usage on schema public to anon, authenticated;

grant execute on function public.pcio_create_project_with_profile(text, text, text, text, text, jsonb, text)
  to anon, authenticated;
grant execute on function public.pcio_find_project_by_access_code(text, text, text)
  to anon, authenticated;
grant execute on function public.pcio_get_project_profile(text, text, text)
  to anon, authenticated;

revoke execute on function public.pcio_save_project_profile(text, text, jsonb, text)
  from public, anon, authenticated;

commit;

-- Verification queries. They do not expose raw access-code hashes or response data.
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments,
  has_function_privilege('anon', p.oid, 'EXECUTE') as anon_can_execute,
  has_function_privilege('authenticated', p.oid, 'EXECUTE') as authenticated_can_execute
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and p.proname in (
    'pcio_create_project_with_profile',
    'pcio_find_project_by_access_code',
    'pcio_get_project_profile',
    'pcio_save_project_profile'
  )
order by p.proname, identity_arguments;

select
  has_schema_privilege('anon', 'public', 'USAGE') as anon_has_public_schema_usage,
  has_schema_privilege('authenticated', 'public', 'USAGE') as authenticated_has_public_schema_usage;
