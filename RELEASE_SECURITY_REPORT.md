# Release Security Report

## Scope

This report covers the `public_release/` folder prepared for GitHub Pages publication.

## Sensitive Directories Not Copied

The following directories or materials were not copied into the public release:

- `paper/`
- manuscript and submission materials
- `前期论文/`
- `案例数据/`
- `研究提案/`
- `调查问卷以及数据/`
- `expert raw data/`
- `raw_data/`
- `private/`
- `drafts/`
- `manuscript/`
- `submission/`
- `review_comments/`
- Supabase privileged credential material
- `.env*`
- raw enterprise outputs
- original case documents
- raw expert evaluation files

## Keyword Scan

Checked terms:

- `service_role`
- `secret`
- `password`
- `DATABASE_URL`
- `SUPABASE_SERVICE_ROLE`
- `JWT_SECRET`
- `OPENAI_API_KEY`
- `github_pat`
- `DATA.csv`
- `真实企业名称`
- `企业全称`
- `联系人`
- `手机号`
- `身份证`
- `详细地址`
- `合同编号`
- `前期论文`
- `研究提案`
- `案例数据`
- `调查问卷以及数据`

## Findings

| Item | Result | Notes |
|---|---|---|
| Supabase service-role credential | PASS | No privileged Supabase credential was found. |
| Database credential string | PASS | No database connection string was found. |
| `.env` files | PASS | No `.env`, `.env.local`, or `.env.production` file was found. |
| `DATA.csv` file | PASS | No `DATA.csv` file was found. |
| JWT-like anon key in release config | PASS | `config/supabase_config.js` is disabled and empty; the example file uses placeholders only. |
| Real enterprise data | PASS | No known raw enterprise dataset or original case file was copied. |
| Manuscript draft | PASS | Manuscript/submission folders were not copied. |
| Raw case material | PASS | Original case materials were not copied. |
| Streamlit ZIP | PASS | The ZIP was rebuilt as a public-safe package; internal scan found no `.env`, `DATA.csv`, credential token, or private directory reference. |
| Privacy-warning terms | DOCUMENTED | Terms such as `手机号`, `身份证`, `详细地址`, and `password` appear only in questionnaire privacy notices, public guidance, or SQL privacy-blocking rules. |

## Supabase Public Configuration

`config/supabase_config.js` is a safe placeholder:

```js
window.PCIO_SUPABASE_CONFIG = {
  enabled: false,
  url: "",
  anonKey: "",
  sdkUrl: "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"
};
```

The public release does not include a privileged backend key. To enable database mode on GitHub Pages, configure only the Supabase anon/publishable key.

## SQL Safety Check

The public SQL package includes:

- `supabase/schema.sql`
- `supabase/rls_policies.sql`
- `supabase/test_seed.sql`

Confirmed:

- RPC parameters use the `input_` naming convention.
- `crypt` and `gen_salt` are schema-qualified as `extensions.crypt` and `extensions.gen_salt`.
- RLS policies do not allow anonymous direct table reads.
- Test seed contains only `TEST-PCIO-001`, `FILL-TEST-PCIO-001`, and `VIEW-TEST-PCIO-001`.

## Publication Decision

Status: PASS

`public_release/` can be uploaded to a GitHub public repository, provided the uploader publishes the contents of the folder as the repository root and does not add private working-directory materials.
