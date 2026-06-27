# PCIO Toolkit Public Release Security Scan

Date: 2026-06-27

## Summary

The `public_release/` package was scanned after enabling the tested Supabase anon-key configuration. No service-role key, database password, database connection string, `.env` file, `DATA.csv`, raw survey data file, or private research directory was found.

## Configuration Check

| Item | Result | Notes |
| --- | --- | --- |
| Supabase enabled | PASS | `public_release/config/supabase_config.js` has `enabled: true`. |
| Supabase URL | PASS | Uses the tested Supabase project URL. |
| Key type | PASS | JWT payload indicates `role: "anon"`. |
| Service-role key in front end | PASS | No service-role key value found in `config/`, `js/`, or public HTML. |
| Database password | PASS | No database password assignment or connection string found. |
| `.env` files | PASS | No `.env`, `.env.local`, or `.env.production` files found. |
| `DATA.csv` | PASS | No `DATA.csv` found. |
| Raw/private directories | PASS | No `paper/`, `raw_data/`, `private/`, `案例数据/`, `研究提案/`, or `调查问卷以及数据/` directory found inside `public_release/`. |

## Keyword Scan Interpretation

The scan intentionally searched for high-risk keywords, including:

- `service_role`
- `SUPABASE_SERVICE_ROLE`
- `DATABASE_URL`
- `JWT_SECRET`
- `OPENAI_API_KEY`
- `github_pat`
- `password`
- `DATA.csv`
- `手机号`
- `邮箱`
- `身份证`
- `详细地址`
- `合同编号`
- `真实设备编号`
- `真实产线编号`

Observed hits were reviewed and classified as follows:

| Hit type | Classification |
| --- | --- |
| `service_role` in SQL files | Safe role-check text used to restrict admin-only RPC operations; no service-role key is present. |
| Secret-key names in prior public checklist/report files | Documentation text only; no actual secret values. |
| `password` in privacy notices or warnings | User-facing safety guidance only; no database password. |
| Chinese sensitive-data terms in questionnaire notices and SQL privacy rules | Privacy warnings and blocking patterns only; no actual personal data. |
| `Risk-KPI-ROI-Summary` filenames | False positive from broad key-pattern search; not an API key. |

## Actual Secret Scan

No actual value matching these categories was found:

- Supabase service-role key
- Database URL or PostgreSQL connection string
- Database password assignment
- JWT secret
- OpenAI API key
- GitHub personal access token
- `.env` file

## Public Data Boundary

The retained examples are synthetic public examples. The Supabase test project codes are public synthetic test materials:

- `TEST-PCIO-001`
- `FILL-TEST-PCIO-001`
- `VIEW-TEST-PCIO-001`

They do not contain real enterprise identity, employee data, original survey data, detailed address, contract number, real equipment number, or real production-line number.

## Release Decision

The current `public_release/` package is suitable for public GitHub Pages upload from a credential-safety perspective, provided that the repository owner uploads only the contents of `public_release/` and does not add private local folders or `.env` files.
