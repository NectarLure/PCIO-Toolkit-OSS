(function () {
  const PLACEHOLDER_URL = "https://YOUR-PROJECT-REF.supabase.co";
  const PLACEHOLDER_KEY = "YOUR_SUPABASE_ANON_OR_PUBLISHABLE_KEY";
  const PRIVILEGED_KEY_MARKER = ["service", "role"].join("_");
  let clientPromise = null;

  function getConfig() {
    return window.PCIO_SUPABASE_CONFIG || {};
  }

  function isConfigured() {
    const cfg = getConfig();
    return Boolean(
      cfg.enabled &&
      cfg.url &&
      cfg.anonKey &&
      cfg.url !== PLACEHOLDER_URL &&
      cfg.anonKey !== PLACEHOLDER_KEY &&
      !new RegExp(PRIVILEGED_KEY_MARKER, "i").test(String(cfg.anonKey))
    );
  }

  function status() {
    const cfg = getConfig();
    if (!cfg.enabled) return { configured: false, reason: "disabled" };
    if (!cfg.url || !cfg.anonKey) return { configured: false, reason: "missing_url_or_anon_key" };
    if (cfg.url === PLACEHOLDER_URL || cfg.anonKey === PLACEHOLDER_KEY) return { configured: false, reason: "placeholder_config" };
    if (new RegExp(PRIVILEGED_KEY_MARKER, "i").test(String(cfg.anonKey))) return { configured: false, reason: "privileged_key_rejected" };
    return { configured: true, reason: "ready" };
  }

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const existing = document.querySelector(`script[data-pcio-supabase-sdk="${src}"]`);
      if (existing) {
        existing.addEventListener("load", resolve, { once: true });
        existing.addEventListener("error", reject, { once: true });
        if (window.supabase && window.supabase.createClient) resolve();
        return;
      }
      const script = document.createElement("script");
      script.src = src;
      script.async = true;
      script.dataset.pcioSupabaseSdk = src;
      script.onload = resolve;
      script.onerror = () => reject(new Error("Supabase SDK could not be loaded."));
      document.head.appendChild(script);
    });
  }

  async function getClient() {
    if (!isConfigured()) {
      const state = status();
      throw new Error(`Supabase is not configured: ${state.reason}`);
    }
    if (!clientPromise) {
      clientPromise = (async () => {
        const cfg = getConfig();
        if (!window.supabase || !window.supabase.createClient) {
          await loadScript(cfg.sdkUrl || "https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js");
        }
        if (!window.supabase || !window.supabase.createClient) {
          throw new Error("Supabase SDK is unavailable after loading.");
        }
        return window.supabase.createClient(cfg.url, cfg.anonKey, {
          auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
        });
      })();
    }
    return clientPromise;
  }

  function cleanBrowserInfo(info) {
    const viewport = info && info.viewport ? info.viewport : {};
    return {
      browser: info && info.browser ? String(info.browser).slice(0, 40) : "browser",
      browser_version: info && info.browser_version ? String(info.browser_version).slice(0, 20) : "",
      language: navigator.language || "",
      timezone_offset_minutes: new Date().getTimezoneOffset(),
      viewport: {
        width: Number(viewport.width || window.innerWidth || 0),
        height: Number(viewport.height || window.innerHeight || 0)
      },
      platform: navigator.platform || "",
      app_version: info && info.app_version ? String(info.app_version).slice(0, 40) : "pcio-web"
    };
  }

  async function rpc(name, params) {
    const client = await getClient();
    const { data, error } = await client.rpc(name, params);
    if (error) {
      const safeError = {
        message: error.message || String(error),
        details: error.details || "",
        hint: error.hint || "",
        code: error.code || ""
      };
      console.error(`[PCIO Supabase RPC error] ${name}`, {
        ...safeError,
        param_keys: Object.keys(params || {})
      });
      const detailText = [safeError.message, safeError.details, safeError.hint, safeError.code]
        .filter(Boolean)
        .join(" | ");
      const wrapped = new Error(detailText || "Supabase RPC failed.");
      wrapped.supabase = safeError;
      throw wrapped;
    }
    return data;
  }

  async function submitSurveyResponse(payload) {
    return rpc("pcio_submit_survey_response", {
      input_project_code: payload.projectCode,
      input_fill_code: payload.fillCode,
      input_respondent_code: payload.respondentCode,
      input_role_group: payload.roleGroup || payload.respondentMeta?.role || payload.respondentMeta?.role_group || "",
      input_profile_json: payload.profileJson || payload.respondentMeta || {},
      input_response_json: payload.responseJson || payload.answers || [],
      input_browser_info: cleanBrowserInfo(payload.browserInfo || {})
    });
  }

  async function findProjectByAccessCode(payload) {
    return rpc("pcio_find_project_by_access_code", {
      input_project_code: payload.projectCode,
      input_access_code: payload.accessCode,
      input_code_type: payload.codeType
    });
  }

  async function getProjectProfile(payload) {
    return rpc("pcio_get_project_profile", {
      input_project_code: payload.projectCode,
      input_access_code: payload.accessCode,
      input_code_type: payload.codeType
    });
  }

  async function createProjectWithProfile(payload) {
    return rpc("pcio_create_project_with_profile", {
      input_project_code: payload.projectCode,
      input_fill_code: payload.fillCode,
      input_view_code: payload.viewCode,
      input_project_name_alias: payload.projectNameAlias || "",
      input_case_type: payload.caseType || "self_service",
      input_profile_json: payload.profileJson || {},
      input_profile_version: payload.profileVersion || "web-profile-v1"
    });
  }

  async function saveAnalysisResult(payload) {
    const params = {
      input_project_code: payload.projectCode,
      input_view_code: payload.viewCode,
      input_result_json: payload.resultJson || {},
      input_respondent_count: payload.responseCount || payload.respondentCount || 0,
      input_analysis_type: payload.analysisType || "baseline",
      input_build_version: payload.buildVersion || payload.analysisVersion || "pcio-web-1.0.0"
    };
    console.info("[PCIO Supabase RPC request] pcio_save_analysis_result", {
      project_code: params.input_project_code,
      has_view_code: Boolean(params.input_view_code),
      respondent_count: params.input_respondent_count,
      analysis_type: params.input_analysis_type,
      build_version: params.input_build_version,
      param_keys: Object.keys(params)
    });
    return rpc("pcio_save_analysis_result", params);
  }

  async function getAnalysisResults(payload) {
    return rpc("pcio_get_analysis_results", {
      input_project_code: payload.projectCode,
      input_view_code: payload.viewCode
    });
  }

  async function getProjectStatus(payload) {
    return rpc("pcio_get_project_status", {
      input_project_code: payload.projectCode,
      input_view_code: payload.viewCode
    });
  }

  window.PCIOSupabase = {
    getConfig,
    isConfigured,
    status,
    cleanBrowserInfo,
    createProjectWithProfile,
    findProjectByAccessCode,
    getProjectProfile,
    submitSurveyResponse,
    saveAnalysisResult,
    getAnalysisResults,
    getProjectStatus
  };
})();
