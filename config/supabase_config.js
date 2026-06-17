// PCIO Toolkit public GitHub Pages configuration.
// Database mode is disabled by default for the public release.
// To enable Supabase, copy config/supabase_config.example.js values here and use
// only the Supabase anon/publishable key. Never place privileged keys here.

window.PCIO_SUPABASE_CONFIG = {
  enabled: false,
  url: "",
  anonKey: "",
  sdkUrl: "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js"
};
