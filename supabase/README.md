# PCIO Toolkit Supabase Database Pack

This folder contains the public SQL package for the optional PCIO Toolkit database mode. The database mode is an implementation/deployment enhancement: it allows project-code based profile loading, anonymous survey submission, aggregated result lookup, and cross-device project reuse. It does not change the local analysis, PCIO scoring, risk matrix, KPI, ROI scenario, or PDCA logic.

## Public Files

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the tables, helper functions, privacy checks, and browser-facing RPC functions. |
| `rls_policies.sql` | Enables Row Level Security, blocks direct anonymous table access, and grants only controlled RPC execution. |
| `CROSS_DEVICE_PROJECT_CREATE.sql` | Hotfix/upgrade script for an existing database that already has the earlier schema but lacks cross-device project creation. |
| `test_seed.sql` | Inserts one synthetic test project only: `TEST-PCIO-001`, `FILL-TEST-PCIO-001`, `VIEW-TEST-PCIO-001`. |

Historical one-off hotfixes have been merged into `schema.sql` or superseded by `CROSS_DEVICE_PROJECT_CREATE.sql` and are not required for a fresh public deployment.

## Installation Order

For a new Supabase database, run:

1. `schema.sql`
2. `rls_policies.sql`
3. Optional: `test_seed.sql`

For an existing PCIO Toolkit database that already ran an older schema, run:

1. `CROSS_DEVICE_PROJECT_CREATE.sql`
2. Optional: `test_seed.sql`

Do not run obsolete hotfix files from older development snapshots.

## Front-End Configuration

Use only the Supabase anon/publishable key in browser code:

```js
window.PCIO_SUPABASE_CONFIG = {
  enabled: true,
  url: "https://YOUR-PROJECT-REF.supabase.co",
  anonKey: "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY",
  sdkUrl: "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"
};
```

Never put a `service_role` key, database password, JWT secret, GitHub token, OpenAI key, or database connection string into frontend JavaScript.

## Privacy Boundary

The database is designed for anonymous, project-code based collection. Do not store:

- real names;
- phone numbers, WeChat IDs, identity-card numbers, passport numbers, or email addresses;
- detailed addresses;
- legal enterprise names;
- customer or supplier names;
- social credit codes;
- contract numbers;
- vehicle plates;
- real equipment IDs or real production-line IDs;
- raw enterprise source data.

`project_code` is a grouping code, not a public enterprise identity. `respondent_code` is an anonymous respondent identifier. ROI values in `analysis_results.result_json` are scenario estimates, not verified financial returns.

## Controlled RPC Pattern

The public website uses RPC functions rather than direct table access:

- `pcio_create_project_with_profile`: creates or safely updates a sanitized project profile and hashed fill/view access codes.
- `pcio_find_project_by_access_code`: validates project code plus fill/view code.
- `pcio_get_project_profile`: returns only sanitized project-profile fields.
- `pcio_submit_survey_response`: submits anonymous responses after fill-code validation.
- `pcio_save_analysis_result`: saves aggregated analysis after view-code validation.
- `pcio_get_analysis_results`: returns aggregated analysis after view-code validation.
- `pcio_get_project_status`: returns project-level status after view-code validation.

The browser is not granted direct anonymous `SELECT`, `INSERT`, `UPDATE`, or `DELETE` access to `projects`, `project_access_codes`, `respondents`, `survey_responses`, or `analysis_results`.

## Test Project

After `test_seed.sql`, the synthetic test project is:

- Project code: `TEST-PCIO-001`
- Fill code: `FILL-TEST-PCIO-001`
- View code: `VIEW-TEST-PCIO-001`

This seed is synthetic only and contains no real enterprise, respondent, or production data.
