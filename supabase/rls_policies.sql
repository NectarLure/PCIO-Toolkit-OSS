-- PCIO Toolkit Supabase RLS policies
-- Version: 1.1.0-profile-loading
-- Run after supabase/schema.sql.
--
-- This file intentionally contains no function definitions.
-- Helper/RPC functions are defined in schema.sql so RLS remains a pure
-- permission and policy layer.

alter table public.projects enable row level security;
alter table public.project_access_codes enable row level security;
alter table public.respondents enable row level security;
alter table public.survey_responses enable row level security;
alter table public.analysis_results enable row level security;
alter table public.submission_logs enable row level security;

alter table public.projects force row level security;
alter table public.project_access_codes force row level security;
alter table public.respondents force row level security;
alter table public.survey_responses force row level security;
alter table public.analysis_results force row level security;
alter table public.submission_logs force row level security;

revoke all on table public.projects from anon, authenticated;
revoke all on table public.project_access_codes from anon, authenticated;
revoke all on table public.respondents from anon, authenticated;
revoke all on table public.survey_responses from anon, authenticated;
revoke all on table public.analysis_results from anon, authenticated;
revoke all on table public.submission_logs from anon, authenticated;

grant usage on schema public to anon, authenticated;

revoke execute on function public.pcio_hash_access_code(text) from public, anon, authenticated;
revoke execute on function public.pcio_verify_access_code(text, text) from public, anon, authenticated;
revoke execute on function public.pcio_canonical_code_type(text) from public, anon, authenticated;
revoke execute on function public.pcio_contains_forbidden_text(text) from public, anon, authenticated;
revoke execute on function public.pcio_jsonb_contains_forbidden_text(jsonb) from public, anon, authenticated;
revoke execute on function public.pcio_sanitize_browser_info(jsonb) from public, anon, authenticated;
revoke execute on function public.pcio_sanitize_project_profile(jsonb) from public, anon, authenticated;
revoke execute on function public.pcio_find_project_by_access_code(text, text, text) from public, anon, authenticated;
revoke execute on function public.pcio_save_project_profile(text, text, jsonb, text) from public, anon, authenticated;
revoke execute on function public.pcio_set_updated_at() from public, anon, authenticated;

grant execute on function public.pcio_create_project_with_profile(text, text, text, text, text, jsonb, text)
  to anon, authenticated;
grant execute on function public.pcio_find_project_by_access_code(text, text, text)
  to anon, authenticated;
grant execute on function public.pcio_get_project_profile(text, text, text)
  to anon, authenticated;
grant execute on function public.pcio_submit_survey_response(text, text, text, text, jsonb, jsonb, jsonb)
  to anon, authenticated;
grant execute on function public.pcio_save_analysis_result(text, text, jsonb, integer, text, text)
  to anon, authenticated;
grant execute on function public.pcio_get_analysis_results(text, text)
  to anon, authenticated;
grant execute on function public.pcio_get_project_status(text, text)
  to anon, authenticated;

-- No permissive SELECT/INSERT/UPDATE/DELETE policies are created for anon or
-- authenticated users. The browser must use the granted RPC functions instead
-- of direct table access.
