// PCIO Toolkit Supabase browser configuration example.
// Copy this file to config/supabase_config.js in the deployed GitHub Pages site.
//
// Use only the Supabase anon/publishable key.
// Do not place privileged database keys, JWT signing values, personal access
// tokens, or backend-only credentials in frontend code.

window.PCIO_SUPABASE_CONFIG = {
  enabled: true,
  url: "https://YOUR-PROJECT-REF.supabase.co",
  anonKey: "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY",
  sdkUrl: "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"
};
