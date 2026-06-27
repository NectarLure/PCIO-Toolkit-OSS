# Public Release Cross-Device Sync Report

Date: 2026-06-27

## Scope

This report records the synchronization of the tested cross-device Supabase project-profile workflow into `public_release/`. The update keeps the existing PCIO questionnaire, scoring, risk matrix, KPI, ROI scenario, and PDCA logic unchanged.

## Files Synchronized From `site/`

- `index.html`
  - Added the public company-profile workflow that can save locally and, when selected, save a sanitized project profile to Supabase.
  - Added the `Also save to database` / `同时保存到数据库` option near the existing company-profile save action.
  - Added project access-code display after successful database save: project code, fill code, and view code.
  - Preserved JSON export/import and local browser storage behavior.
- `js/supabase_client.js`
  - Added `createProjectWithProfile(payload)`.
  - Preserved the existing profile load, survey submit, analysis save, analysis lookup, and project status RPC wrappers.
  - All browser-facing RPC parameters use the `input_` prefix.
- `config/supabase_config.js`
  - Public release configuration is enabled and uses only the Supabase anon/publishable key.
  - No service-role key, database password, JWT secret, or database connection string is stored.
- `project_lookup.html`
  - Kept the project-code/view-code result lookup page.
  - Lookup displays aggregated `analysis_results` only and does not expose individual respondent answers.

## Supabase Files Retained In `public_release/supabase/`

- `schema.sql`
- `rls_policies.sql`
- `test_seed.sql`
- `CROSS_DEVICE_PROJECT_CREATE.sql`
- `README.md`

Historical hotfix files were not retained in the public Supabase folder. Current deployment guidance directs new databases to run `schema.sql` and `rls_policies.sql`, and existing databases to run `CROSS_DEVICE_PROJECT_CREATE.sql` when the cross-device project-profile RPC is not yet installed.

## Public Database Configuration

- `public_release/config/supabase_config.js` has `enabled: true`.
- The configured project URL is `https://kaxqqejhglyydkxejehb.supabase.co`.
- The key is an anon/publishable key only.
- The SDK URL remains `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js`.

## Local Public-Release Checks

Static server and HTTP checks were run from `public_release/` on port `8001`.

| Check | Result |
|---|---|
| `index.html` served locally | PASS |
| `config/supabase_config.js` served locally | PASS |
| Supabase CDN SDK reachable | PASS |
| `js/supabase_client.js` served locally | PASS |
| `project_lookup.html` served locally | PASS |
| Public SQL files served locally | PASS |

Direct anon-key RPC checks against the configured Supabase project were also performed:

| Workflow | Result |
|---|---|
| `TEST-PCIO-001` + `FILL-TEST-PCIO-001` loads sanitized project profile | PASS |
| `TEST-PCIO-001` + `VIEW-TEST-PCIO-001` loads aggregated result | PASS |
| Fill code cannot read summary result through view-code lookup | PASS |
| Direct anonymous `survey_responses` select is blocked | PASS |
| New synthetic project profile can be created through controlled RPC | PASS |
| Newly created synthetic profile can be loaded back with fill code | PASS |

Browser-console inspection was not claimed as a separate manual browser test in this report. The checks above verify file serving, script availability, Supabase configuration, RPC behavior, access-code separation, and RLS blocking of raw response reads.

## Functional Boundary

The public release supports cross-device project profile creation and lookup for sanitized project metadata. It does not publish raw survey data, real company data, service-role credentials, or private research materials. ROI remains a scenario-estimation tool rather than a verified financial outcome.
