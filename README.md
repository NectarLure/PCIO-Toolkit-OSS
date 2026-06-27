# PCIO Toolkit Public Release

This folder is the GitHub Pages-ready public release of the PCIO Toolkit.

PCIO Toolkit is a bilingual, low-cost, modular decision-support artifact for smart manufacturing diagnosis. It includes a 305-item production-technician questionnaire, browser-side aggregation, rapid PCIO analysis, risk matrix, KPI suggestions, ROI scenario estimates, and a PDCA improvement workflow.

## Quick Start

1. Open `index.html` in a browser or deploy this folder to GitHub Pages.
2. Create or load a company profile using an anonymized project code.
3. Let production technicians complete the questionnaire anonymously.
4. Run the rapid analysis in the "04 综合分析 / Analysis" section.
5. Export local results or optionally save aggregated results to Supabase.

## Supabase Database Mode

Database mode is optional and disabled by default in:

```text
config/supabase_config.js
```

To enable it, copy the pattern from:

```text
config/supabase_config.example.js
```

Use only a Supabase anon/publishable key. Do not place privileged backend credentials in frontend code.

Run the SQL files in this order:

```text
supabase/schema.sql
supabase/rls_policies.sql
supabase/test_seed.sql
```

The synthetic test project is:

```text
Project code: TEST-PCIO-001
Fill code: FILL-TEST-PCIO-001
View code: VIEW-TEST-PCIO-001
```

## GitHub Pages Deployment

Upload the contents of this folder as the repository root. The repository root should contain `index.html`, `assets/`, `js/`, `config/`, `project_lookup.html`, `supabase/`, `README.md`, and `LICENSE`.

Do not upload the parent folder as `public_release/public_release/index.html`.

## Evidence Boundary

Synthetic examples and ROI outputs are for planning and demonstration only. They are not evidence of realized enterprise performance improvement or verified financial return.
