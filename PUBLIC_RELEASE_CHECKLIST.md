# Public Release Checklist

## Release Folder

Use the contents of this folder as the GitHub repository root.

Required root-level structure:

- `index.html`
- `project_lookup.html`
- `assets/`
- `js/`
- `config/`
- `downloads/`
- `supabase/`
- `README.md`
- `LICENSE`

Status: PASS

There is no nested `public_release/public_release/index.html` structure.

## Website Files Synced From `site/`

- `index.html`
- `project_lookup.html`
- `expert_review_invitation.html`
- `assets/pcio-mark.svg`
- `js/supabase_client.js`
- `downloads/PCIO-Toolkit-Streamlit-1.0.0.zip`
- `robots.txt`
- `site.webmanifest`
- `.nojekyll`

The main page structure, questionnaire, PCIO scoring logic, KPI, ROI, risk matrix, and PDCA workflow were not redesigned.

## Supabase Database Mode

Included:

- `config/supabase_config.js`
- `config/supabase_config.example.js`
- `js/supabase_client.js`
- `project_lookup.html`
- `supabase/schema.sql`
- `supabase/rls_policies.sql`
- `supabase/test_seed.sql`

`config/supabase_config.js` is a safe disabled placeholder:

```js
enabled: false
url: ""
anonKey: ""
```

To enable database mode, configure only the Supabase anon/publishable key.

## Final Supabase SQL

Confirmed in `supabase/schema.sql`:

- `projects.project_name_alias`
- `projects.case_type`
- `projects.status`
- `analysis_results.project_code`
- `analysis_results.result_json`
- `analysis_results.respondent_count`
- `analysis_results.analysis_type`
- `analysis_results.build_version`
- `analysis_results.created_at`
- `project_access_codes.code_type` supports `fill`, `view`, `fill_code`, and `view_code`
- `extensions.crypt(...)`
- `extensions.gen_salt(...)`

Confirmed RPC functions:

- `pcio_find_project_by_access_code`
- `pcio_submit_survey_response`
- `pcio_save_analysis_result`
- `pcio_get_analysis_results`
- `pcio_get_project_status`

## Synthetic Test Project

`supabase/test_seed.sql` includes only:

- `TEST-PCIO-001`
- `FILL-TEST-PCIO-001`
- `VIEW-TEST-PCIO-001`

No real enterprise data is inserted.

## Excluded From Public Release

The following private or non-public materials were not copied:

- `paper/`
- manuscript drafts and submission materials
- `前期论文/`
- `案例数据/`
- `研究提案/`
- `调查问卷以及数据/`
- `raw_data/`
- `private/`
- `drafts/`
- `.env*`
- raw enterprise outputs
- real enterprise source files
- raw expert evaluation material

## Upload Reminder

Upload the files inside `public_release/`, not the `public_release` folder itself.
