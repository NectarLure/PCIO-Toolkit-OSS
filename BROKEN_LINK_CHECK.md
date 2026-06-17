# Broken Link Check / 链接检查

Scope: root-level HTML files and site.webmanifest inside public_release. Fragment-only links, generated blob downloads, and explicit external HTTPS links are treated as non-local links.

| Source | Link | Status | Notes |
|---|---|---|---|
| expert_review_invitation.html | `assets/pcio-mark.svg` | OK | Local target exists. |
| expert_review_invitation.html | `index.html` | OK | Local target exists. |
| expert_review_invitation.html | `index.html` | OK | Local target exists. |
| expert_review_invitation.html | `https://nectarlure.github.io/PCIO-Toolkit-EE/` | Skipped | Non-local or fragment/generated link. |
| expert_review_invitation.html | `https://nectarlure.github.io/PCIO-Toolkit-EE/` | Skipped | Non-local or fragment/generated link. |
| expert_review_invitation.html | `index.html` | OK | Local target exists. |
| index.html | `assets/pcio-mark.svg` | OK | Local target exists. |
| index.html | `site.webmanifest` | OK | Local target exists. |
| index.html | `#workspace` | Skipped | Non-local or fragment/generated link. |
| index.html | `#home` | Skipped | Non-local or fragment/generated link. |
| index.html | `expert_review_invitation.html` | OK | Local target exists. |
| index.html | `downloads/PCIO-Toolkit-Streamlit-1.0.0.zip` | OK | Local target exists. |
| index.html | `expert_review_invitation.html` | OK | Local target exists. |
| index.html | `downloads/PCIO-Toolkit-Streamlit-1.0.0.zip` | OK | Local target exists. |
| index.html | `downloads/PCIO-Toolkit-Streamlit-1.0.0.zip` | OK | Local target exists. |
| site.webmanifest | `assets/pcio-mark.svg` | OK | Icon target exists. |

Summary: 0 broken local link(s) found.
