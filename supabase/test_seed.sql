-- PCIO Toolkit Supabase test seed
-- Purpose: create one synthetic test project for end-to-end database-mode checks.
-- No real enterprise, respondent, or production data is inserted.
--
-- Test project code: TEST-PCIO-001
-- Fill code: FILL-TEST-PCIO-001
-- View code: VIEW-TEST-PCIO-001

do $$
declare
  v_project_id uuid;
  v_fill_access_id uuid;
  v_view_access_id uuid;
begin
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
    'TEST-PCIO-001',
    'Synthetic PCIO Test Project',
    'synthetic',
    '3.0.0',
    '1.1.0',
    jsonb_build_object(
      'notice', 'Synthetic test project only. No real enterprise data.',
      'project_name_alias', 'Test Manufacturing Project',
      'case_type', 'synthetic',
      'industry', 'machinery',
      'industry_label', 'discrete manufacturing',
      'enterprise_size', 'SME',
      'company_size', 'medium',
      'production_mode', 'mixed',
      'production_type', 'mixed',
      'line_name', 'Synthetic mixed production cell',
      'existing_systems', jsonb_build_array('excel', 'plc'),
      'current_systems', jsonb_build_array('excel', 'plc'),
      'digitalisation_stage', 'local',
      'automation_level', 'local',
      'main_pain_points', jsonb_build_array('manual_records', 'data_silos', 'quality_defects'),
      'pain_points', jsonb_build_array('manual_records', 'data_silos', 'quality_defects'),
      'selected_modules', jsonb_build_array('survey', 'analysis', 'risk_matrix', 'kpi_roi', 'pdca'),
      'questionnaire_language', 'zh-CN',
      'pilot_scope', 'Synthetic pilot cell for database-mode testing',
      'data_boundary', 'synthetic'
    ),
    'test-v1',
    now(),
    'active',
    false
  )
  on conflict (project_code)
  do update set
    project_name_alias = excluded.project_name_alias,
    case_type = excluded.case_type,
    schema_version = excluded.schema_version,
    toolkit_version = excluded.toolkit_version,
    profile_json = excluded.profile_json,
    profile_version = excluded.profile_version,
    profile_updated_at = now(),
    status = excluded.status,
    allow_open_text = excluded.allow_open_text,
    updated_at = now()
  returning id into v_project_id;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) in ('fill', 'view')
     and coalesce(code_label, '') not in (
       'Synthetic fill code for database-mode testing',
       'Synthetic view code for database-mode testing'
     );

  select id
    into v_fill_access_id
  from public.project_access_codes
  where project_id = v_project_id
    and code_label = 'Synthetic fill code for database-mode testing'
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
      public.pcio_hash_access_code('FILL-TEST-PCIO-001'),
      'Synthetic fill code for database-mode testing',
      true
    )
    returning id into v_fill_access_id;
  else
    update public.project_access_codes
       set code_type = 'fill',
           code_hash = public.pcio_hash_access_code('FILL-TEST-PCIO-001'),
           is_active = true,
           expires_at = null
     where id = v_fill_access_id;
  end if;

  select id
    into v_view_access_id
  from public.project_access_codes
  where project_id = v_project_id
    and code_label = 'Synthetic view code for database-mode testing'
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
      public.pcio_hash_access_code('VIEW-TEST-PCIO-001'),
      'Synthetic view code for database-mode testing',
      true
    )
    returning id into v_view_access_id;
  else
    update public.project_access_codes
       set code_type = 'view',
           code_hash = public.pcio_hash_access_code('VIEW-TEST-PCIO-001'),
           is_active = true,
           expires_at = null
     where id = v_view_access_id;
  end if;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) = 'fill'
     and id <> v_fill_access_id;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) = 'view'
     and id <> v_view_access_id;
end $$;
