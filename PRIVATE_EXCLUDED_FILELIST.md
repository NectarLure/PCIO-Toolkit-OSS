# Private Excluded File List / 私有材料排除清单

Generated for the PCIO Toolkit public release.

## Explicitly excluded private directories / 明确排除的私有目录

| Path | Reason |
|---|---|
| `paper/` | Manuscript drafts, revision notes, private figures, and paper working files are not public website materials. |
| `前期论文/` | Earlier paper drafts and unpublished source materials. |
| `研究提案/` | Research proposal and method-planning documents not intended for public release. |
| `案例数据/` | Enterprise case originals are private and may contain identifiable operational context. |
| `调查问卷以及数据/` | Raw survey files, including `DATA.csv`, are not public. |
| `data/real_cases_T0_anonymized/` | Controlled T0 case files are not included in the public website package. |
| `outputs/` | May contain generated outputs from real or internal runs; excluded unless separately approved. |
| `review_portal/` | Review portal working pages are excluded except blank review forms copied to `downloads/`. |

## Explicitly excluded private or internal files / 明确排除的私有或内部文件

| Path | Reason |
|---|---|
| `submission_readiness_report.md` | Internal submission-readiness assessment. |
| `paper/change_log.md` | Internal manuscript change log. |
| `paper/remaining_weaknesses.md` | Internal risk and weakness tracking. |
| `final_risk_check.md` | Not present in the current root listing, but excluded by policy if present. |
| `paper/manuscript.md` and any `manuscript.md` draft | Manuscript working draft, not a public website asset. |
| `data_manifest.md` | Internal data-governance inventory; not copied because it can disclose private data boundaries. |
| `data_usage_recommendation.md` | Internal data-use planning document; requires author review before publication. |
| `docs/PCIO-Evidence-Register.md` | Replaced by `docs/Evidence-Boundary-Public.md` because the internal register references private source paths. |
| `docs/PCIO-Toolkit-Development-and-User-Guide.md` | Replaced by public user manual; internal guide contains development history and private source references. |
| `scripts/recalculate_legacy_pcio_evidence.py` | Excluded from the public Streamlit ZIP because it refers to legacy raw-data recalculation. |
| `scripts/anonymize_real_t0.py` | Excluded from the public Streamlit ZIP because T0 processing utilities are not needed for public demonstration. |
| Original `site/downloads/PCIO-Toolkit-Streamlit-1.0.0.zip` | Not copied directly; regenerated as a sanitized public package. |

## Needs manual confirmation before future publication / 后续公开前需人工确认

- Any completed expert review response, interview note, or consensus record.
- Any raw or derived enterprise dataset, even if anonymised.
- Any original case narrative, screenshot, process diagram, equipment tag list, customer/supplier detail, address, or tank-area operational record.
- Any unpublished manuscript draft or reviewer response document.
