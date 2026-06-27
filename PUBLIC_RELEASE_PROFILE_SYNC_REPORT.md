# PCIO Toolkit Public Release Profile Sync Report

Date: 2026-06-27

## Scope

This update only touched the `public_release/` public website package. It did not modify the questionnaire structure, PCIO scoring logic, risk matrix, KPI rules, ROI scenario logic, PDCA logic, database tables, RPC definitions, RLS policies, or the remote GitHub repository.

## Files Compared

The current `site/` and `public_release/` versions were compared for the profile-loading feature:

| Area | Source | Public release status |
| --- | --- | --- |
| Supabase client | `site/js/supabase_client.js` | Already identical to `public_release/js/supabase_client.js`; no copy required |
| Main website | `site/index.html` | Profile auto-loading logic already present; public script-loading order updated |
| Project lookup page | `site/project_lookup.html` | Lookup logic already present; public script-loading order updated |
| Supabase configuration | `site/config/supabase_config.js` | Public release changed from disabled placeholder to enabled anon-key configuration |

## Files Updated

| File | Change |
| --- | --- |
| `public_release/config/supabase_config.js` | Enabled database mode with the tested Supabase project URL and anon public key only. |
| `public_release/index.html` | Ensured the database scripts load in this order: config, Supabase SDK, `js/supabase_client.js`. |
| `public_release/project_lookup.html` | Ensured the same script-loading order for project-code result lookup. |

## Files Not Synced

No private data, test logs, raw survey data, paper drafts, expert raw evaluation files, `.env` files, service-role keys, database passwords, or source research folders were copied. No assets or CSS files were copied because no profile-loading related difference required them.

## Supabase Public Configuration

`public_release/config/supabase_config.js` is now enabled:

- `enabled: true`
- Supabase Project URL: `https://kaxqqejhglyydkxejehb.supabase.co`
- Key type: anon public key only
- SDK: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js`

The anon JWT payload was checked locally and contains `role: "anon"`. The full key is intentionally not repeated in this report.

## Profile Auto-Loading Flow

The public site contains the expected workflow:

1. User enters project code and fill code.
2. Front end calls `pcio_find_project_by_access_code`.
3. After validation, front end calls `pcio_get_project_profile`.
4. If the RPC returns `ok: true`, the sanitized `profile_json` is mapped into the company profile form.
5. The page shows the loaded-profile success message and renders the technician survey.
6. If the profile is absent, the page reports that the project profile has not been established.
7. If Supabase is unavailable or not configured, the local manual-fill/import workflow remains available.

## Permission Boundary

The public front end keeps the intended role boundary:

- Fill code: validates project access, reads only the sanitized profile needed for questionnaire filling, and can submit anonymous responses.
- View code: reads the sanitized profile and aggregated `analysis_results`.
- Raw respondent answers are not displayed by `project_lookup.html`.
- No service-role key or database password is present in public front-end configuration.

## GitHub Upload Note

For GitHub Pages, upload the contents of `public_release/` as the repository root, including:

- `index.html`
- `project_lookup.html`
- `assets/`
- `js/`
- `config/`
- `supabase/`
- `README.md`
- `LICENSE`

Do not upload a nested `public_release/public_release/` structure.
