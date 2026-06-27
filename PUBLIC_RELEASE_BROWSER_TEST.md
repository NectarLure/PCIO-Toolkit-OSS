# PCIO Toolkit Public Release Local Test Report

Date: 2026-06-27

## Test Boundary

Playwright or another controllable browser runtime was not available in the current environment. Therefore, this report records local static-server checks, JavaScript syntax checks, network asset checks, and direct Supabase RPC checks. It does not claim a full interactive browser-console test.

## Local Static Server

The public package was served from `public_release/` with:

```powershell
python -m http.server 8001
```

Checked URL:

- `http://127.0.0.1:8001/`

## Network and Asset Checks

| Resource | Result |
| --- | --- |
| `http://127.0.0.1:8001/` | HTTP 200 |
| `http://127.0.0.1:8001/config/supabase_config.js` | HTTP 200 |
| `http://127.0.0.1:8001/js/supabase_client.js` | HTTP 200 |
| `http://127.0.0.1:8001/project_lookup.html` | HTTP 200 |
| Supabase SDK CDN | HTTP 200 |

JavaScript syntax checks passed for:

- `public_release/js/supabase_client.js`
- `public_release/config/supabase_config.js`

## Supabase RPC Checks

The same anon public key configured in `public_release/config/supabase_config.js` was used for direct RPC checks.

| Check | Result |
| --- | --- |
| `pcio_get_project_profile` with `TEST-PCIO-001` + `FILL-TEST-PCIO-001` + `fill` | `ok: true`; sanitized profile returned. |
| Loaded profile alias | `Synthetic PCIO Test Project` |
| Loaded profile industry | `machinery` |
| Invalid project code | `ok: false`; `message_code: project_or_access_code_invalid` |
| `pcio_get_project_profile` with view code | `ok: true`; role returned as `view`. |
| `pcio_get_analysis_results` with `TEST-PCIO-001` + `VIEW-TEST-PCIO-001` | `ok: true`; aggregated result available. |
| `pcio_get_analysis_results` with fill code | `ok: false`; rejected as invalid view code. |
| Direct anon REST select from `survey_responses` | Blocked with HTTP 401. |

## Expected Page Behavior Covered by Static/RPC Checks

The public package includes the front-end code path for:

1. Project-code and fill-code validation.
2. Calling `pcio_get_project_profile`.
3. Mapping sanitized `profile_json` into the company profile form.
4. Showing the loaded-profile message.
5. Falling back to local manual filling/import if Supabase is unavailable.
6. Querying only aggregated results on `project_lookup.html`.

## Not Fully Verified in This Environment

Because no browser automation runtime was available, the following were not directly observed in a rendered browser DOM:

- Visual removal of the red missing-profile hint after successful loading.
- Browser console being free of runtime errors.
- Manual button-click interaction in the rendered page.
- Network panel status display.

The underlying local assets and Supabase RPC endpoints required for those interactions were verified successfully.
