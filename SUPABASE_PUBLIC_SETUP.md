# Supabase Public Setup

This guide enables the optional database mode for the PCIO Toolkit public website.

## 1. Create a Supabase Project

Create a Supabase project and open the SQL Editor.

Run the SQL files in this order:

```text
supabase/schema.sql
supabase/rls_policies.sql
supabase/test_seed.sql
```

`test_seed.sql` creates only a synthetic test project:

```text
TEST-PCIO-001
FILL-TEST-PCIO-001
VIEW-TEST-PCIO-001
```

No real enterprise data is inserted.

## 2. Configure the Static Website

Edit:

```text
config/supabase_config.js
```

Use the pattern in:

```text
config/supabase_config.example.js
```

Only the anon/publishable browser key should be used. Backend-only credentials must stay outside the public website.

## 3. Validate Project Lookup

After deployment, open:

```text
project_lookup.html
```

Use:

```text
Project code: TEST-PCIO-001
View code: VIEW-TEST-PCIO-001
```

If no analysis has been saved yet, first run the website analysis flow and click "保存汇总到数据库 / Save summary to database".

## 4. Data Boundary

The database mode stores anonymous project codes, anonymous respondent codes, structured item responses, project-level analysis JSON, and basic browser runtime metadata.

It must not be used to store names, private contact details, exact addresses, real enterprise identifiers, customer/supplier identifiers, vehicle plates, or raw production records.

ROI values are scenario estimates for planning, not verified realized returns.
