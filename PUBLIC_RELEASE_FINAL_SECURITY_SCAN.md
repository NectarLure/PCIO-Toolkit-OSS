# Public Release Final Security Scan

Date: 2026-06-27

## Summary

`public_release/` was scanned after synchronizing the cross-device Supabase project-profile workflow. The release package is suitable for GitHub Pages publication from a file-content perspective, subject to normal post-deployment verification on the live URL.

## Secret And Private-File Checks

| Item | Result | Notes |
|---|---|---|
| `service_role` key | PASS | No service-role key was found. The literal `service_role` appears only as SQL role-check text or public security guidance. |
| `SUPABASE_SERVICE_ROLE` | PASS | Appears only in warning/checklist text, not as a credential. |
| Database password or connection string | PASS | No password assignment, `DATABASE_URL`, `postgres://`, or `postgresql://` connection string was found. |
| `JWT_SECRET` | PASS | Appears only in warning/checklist text. |
| `OPENAI_API_KEY` | PASS | Appears only in warning/checklist text. |
| GitHub token | PASS | No token value was found. |
| `.env` files | PASS | No `.env`, `.env.local`, or `.env.production` file exists in the public release. |
| `DATA.csv` | PASS | No `DATA.csv` exists in the public release. |
| Private research folders | PASS | No `前期论文/`, `案例数据/`, `研究提案/`, `调查问卷以及数据/`, `raw_data/`, `private/`, or `expert raw data/` directory exists. |

## Supabase Configuration Check

`public_release/config/supabase_config.js` contains:

- `enabled: true`
- Supabase project URL: `https://kaxqqejhglyydkxejehb.supabase.co`
- anon/publishable key only
- Supabase SDK CDN URL

The anon key is allowed in a static browser deployment. Privileged keys are not present.

## Sensitive-Text Scan Interpretation

Terms such as `手机号`, `邮箱`, `身份证`, `详细地址`, `合同编号`, `真实设备编号`, and `真实产线编号` appear in the public package as:

- questionnaire privacy warnings;
- front-end error messages explaining forbidden sensitive text;
- SQL privacy-blocking regular expressions;
- public safety-report wording.

These matches are not real personal data, enterprise identifiers, or raw case records.

## Access-Control Boundary

The public release keeps direct anonymous table reads blocked by RLS and routes browser operations through controlled RPC functions. The public front end can:

- create or update a sanitized project profile through `pcio_create_project_with_profile`;
- load a sanitized profile through `pcio_get_project_profile`;
- submit anonymous responses through `pcio_submit_survey_response`;
- save and read aggregated analysis results through view-code protected RPCs.

The public front end cannot directly read all `projects`, `project_access_codes`, or `survey_responses`, and it is not granted access to `pcio_save_project_profile`.

## Publication Decision

No blocking secret, raw-data, or private-folder issue was found in `public_release/`. The directory contents can be copied to the GitHub Pages repository root; do not upload the `public_release/` folder as a nested directory.
