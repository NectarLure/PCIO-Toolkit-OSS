# Public Release Risk Check / 公开发布风险检查

## Automated scan results / 自动扫描结果

| Check | Result | Notes |
|---|---|---|
| Absolute Windows paths | PASS | No C:/ or C:\\ matches in public_release content. |
| DATA.csv | PASS | No DATA.csv matches in public_release content or the sanitized ZIP. |
| Private manuscript/internal filenames | PASS | No manuscript draft, submission report, change log, weakness log, or final risk check copied as release content. |
| Private Chinese source directories | PASS | No 前期论文, 研究提案, 案例数据, or 调查问卷以及数据 references remain in release content. |
| Sanitized Streamlit ZIP | PASS | Public ZIP is rebuilt from a minimal allowlist and excludes legacy raw-data and T0 utilities. |
| ROI wording | PASS with boundary notes | Mentions of ROI verification appear only as negative boundary statements in the README or blank expert-review forms. |
| Expert review entry | PASS | New internal page links first to `expert_review_invitation.html`; the external review site opens with `target="_blank"` and `rel="noopener noreferrer"`. |

## Forbidden-pattern scan output / 禁止项扫描输出

No forbidden-pattern matches found in public release content.

No forbidden-pattern matches found inside the sanitized ZIP content.

No risky filenames found inside the sanitized ZIP.

## Boundary-word scan / 边界词扫描

The following matches are retained because they explicitly state non-publication, non-verification, or ROI-scenario boundaries:
- C:\Users\A\Documents\PCIO\public_release\README.md:19:本公开版不包含论文私有材料、真实问卷数据、T0 原始文件、企业案例原文、员工信息、设备编号、客户/供应商细节、地址或罐区敏感记录。ROI 输出仅为情景估算，不代表真实收益验证。
- C:\Users\A\Documents\PCIO\public_release\downloads\expert_review_instruction.md:75:- 真实案例不能用于证明部署后改善、因果效果、真实ROI实现或长期运行稳定性。
- C:\Users\A\Documents\PCIO\public_release\downloads\expert_review_instruction.md:78:- ROI 模块仅用于情景估算和方案比较，不代表真实收益验证。
- C:\Users\A\Documents\PCIO\public_release\downloads\expert_review_form.csv:22:boundary,B3,ROI情景边界,我理解 ROI 模块为情景估算工具，不代表真实收益验证,,
- C:\Users\A\Documents\PCIO\public_release\downloads\expert_review_form.md:18:- ROI 模块仅为情景估算工具，不代表真实收益验证。
- C:\Users\A\Documents\PCIO\public_release\downloads\expert_review_form.md:62:| 我理解 ROI 模块为情景估算工具，不代表真实收益验证。 |  |

## Overall conclusion / 总体结论

The public_release directory remains suitable as a public website package under the current automated checks. The expert-review entry adds only an internal invitation page and the requested explicit external review link; existing toolkit functions are unchanged.
