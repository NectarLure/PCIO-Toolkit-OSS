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
begin
  insert into public.projects (
    project_code,
    project_name_alias,
    case_type,
    schema_version,
    toolkit_version,
    profile_json,
    status,
    allow_open_text
  )
  values (
    'TEST-PCIO-001',
    'Synthetic PCIO Test Project',
    'demo',
    '3.0.0',
    '1.1.0',
    jsonb_build_object(
      'notice', 'Synthetic test project only. No real enterprise data.',
      'industry', 'test',
      'production_type', 'test',
      'data_boundary', 'synthetic'
    ),
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
    status = excluded.status,
    allow_open_text = excluded.allow_open_text,
    updated_at = now()
  returning id into v_project_id;

  update public.project_access_codes
     set is_active = false
   where project_id = v_project_id
     and public.pcio_canonical_code_type(code_type) in ('fill_code', 'view_code');

  insert into public.project_access_codes (
    project_id,
    code_type,
    code_hash,
    code_label,
    is_active
  )
  values (
    v_project_id,
    'fill_code',
    public.pcio_hash_access_code('FILL-TEST-PCIO-001'),
    'Synthetic fill code for database-mode testing',
    true
  );

  insert into public.project_access_codes (
    project_id,
    code_type,
    code_hash,
    code_label,
    is_active
  )
  values (
    v_project_id,
    'view_code',
    public.pcio_hash_access_code('VIEW-TEST-PCIO-001'),
    'Synthetic view code for database-mode testing',
    true
  );
end $$;
