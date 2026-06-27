# 匿名装备制造企业 PCIO 风险、KPI 与 ROI 摘要
# PCIO Risk, KPI, and ROI Summary

**项目代码 / Project code:** DISC-PILOT-01
**证据边界 / Evidence boundary:** 风险分数和 KPI/ROI 区间用于筛选与立项，不构成安全结论、预算报价或收益承诺。 / Risk scores and KPI/ROI ranges support screening and approval; they are not safety conclusions, price quotes, or benefit guarantees.

## 1. 优先风险 / Priority Risks

| 排名 | ID | 类别 | 风险 / Risk | 概率 | 影响 | 得分 | PDCA |
|---:|---|---|---|---:|---:|---:|---|
| 1 | O03 | 组织 / Organisational | 跨班组或跨部门流程未同步调整 / Cross-shift or cross-department process not changed with the tool | 4 | 3 | 12 | Do/Act |
| 2 | T03 | 技术 / Technical | 设备、批次、工单和异常语义不一致 / Inconsistent asset, batch, work-order, and exception semantics | 4 | 3 | 12 | Plan/Check |
| 3 | E01 | 外部 / External | 供应商锁定、封闭协议或数据不可迁移 / Vendor lock-in, closed protocols, or non-portable data | 4 | 3 | 12 | Plan |
| 4 | H01 | 人力 / Workforce | 一线人员培训、使用能力或参与度不足 / Insufficient frontline training, capability, or participation | 4 | 3 | 12 | Do/Check |
| 5 | O01 | 组织 / Organisational | 试点边界、责任人和异常关闭权责不清 / Unclear pilot boundary, ownership, and exception closure authority | 4 | 3 | 12 | Plan |
| 6 | O02 | 组织 / Organisational | KPI 口径或收益基线不可复算 / Non-reproducible KPI definitions or benefit baseline | 4 | 3 | 12 | Plan/Check |
| 7 | H03 | 人力 / Workforce | 自动建议的授权、确认和安全责任边界不清 / Unclear authority, confirmation, and safety accountability for automated recommendations | 4 | 3 | 12 | Plan/Act |
| 8 | T01 | 技术 / Technical | 关键测点覆盖、校准或数据完整性不足 / Insufficient critical-tag coverage, calibration, or completeness | 4 | 3 | 12 | Plan/Do |
| 9 | T02 | 技术 / Technical | 采集链路中断、延迟或网络隔离不足 / Collection interruption, latency, or inadequate network segregation | 4 | 3 | 12 | Do/Check |
| 10 | E02 | 外部 / External | 本地备件、校准或运维支持响应不足 / Insufficient local spare-parts, calibration, or maintenance response | 3 | 2 | 6 | Plan/Do |

## 2. KPI 建议 / KPI Recommendations

| 排名 | KPI | PCIO | 目标 / Target | 情景说明 / Scenario |
|---:|---|---|---|---|
| 1 | 人工重复记录时间 / Duplicate manual recording time | I | 15-30 % reduction | 数字化上线时同步取消等量重复纸质步骤。 |
| 2 | 返工/缺陷率 / Rework or defect rate | O | 5-10 % reduction | 保持产品组合和检验口径一致。 |
| 3 | 瓶颈设备状态感知覆盖率 / State-sensing coverage for bottleneck assets | P | 90-95 % | 柔性绩效问卷分数试点提升 0.2-0.5/5，须与换产/等待时间交叉验证。 |
| 4 | 关键测点与设备/批次/工单映射完整率 / Completeness of tag-to-asset/batch/work-order mapping | I | 90-95 % | 当前集成能力决定统计结果能否回到具体业务情境。 |
| 5 | 异常闭环按期完成率 / On-time exception closure rate | O | 80-90 % | 优化层先验证规则和行动闭环，再进入高级模型。 |
| 6 | 关键测点有效覆盖率 / Valid coverage of critical tags | P | 90-95 % | 感知层是后续连接、集成和优化的输入门槛。 |
| 7 | 目标岗位任务验证通过率 / Task-based competence pass rate for target roles | H | 90-95 % | 培训完成不等于会用，以真实任务验证人机协同能力。 |
| 8 | 试点数据采集可用率 / Pilot data-acquisition availability | C | 97-99 % | 用链路可用率代替“已联网”这一不可审计描述。 |

## 3. ROI 快速估算 / Rapid ROI Estimate

- 投资 / Investment: CNY 180,000
- 年度可改善价值池 / Annual addressable value: CNY 1,500,000
- 改善假设 / Improvement assumption: 5.0%-10.0%
- 静态回收期 / Simple payback: 18.0-48.0 months
- 说明 / Note: 回收期为简单静态估算，未计税、折旧、资金成本、停产损失或爬坡曲线。 / Payback is a simple static estimate excluding tax, depreciation, cost of capital, downtime, and ramp-up.

## 4. 企业改善操作流程 / Enterprise Improvement Workflow

**当前风险 / Current risks:** O03=12、T03=12、E01=12、H01=12、O01=12、O02=12、H03=12、T01=12、T02=12、E02=6

**当前 KPI 与目标 / Current KPIs and targets:** 人工重复记录时间：成熟度 2.5768 → 15-30 % reduction；返工/缺陷率：成熟度 2.6725 → 5-10 % reduction；瓶颈设备状态感知覆盖率：成熟度 2.7767 → 90-95 %；关键测点与设备/批次/工单映射完整率：成熟度 2.5768 → 90-95 %；异常闭环按期完成率：成熟度 2.6725 → 80-90 %；关键测点有效覆盖率：成熟度 2.7767 → 90-95 %；目标岗位任务验证通过率：成熟度 2.8615 → 90-95 %；试点数据采集可用率：成熟度 2.7857 → 97-99 %

| 情景 / Scenario | 改善率 | 年度毛收益 | 年度净收益 | 静态回收期 | 三年 ROI |
|---|---:|---:|---:|---:|---:|
| 保守 / Conservative | 5.0% | 75,000 | 45,000 | 48.0 months | -25.0% |
| 基准 / Base | 7.5% | 112,500 | 82,500 | 26.2 months | 37.5% |
| 乐观 / Optimistic | 10.0% | 150,000 | 120,000 | 18.0 months | 100.0% |

### Plan（计划） / Plan

1. 按 4×4 得分优先处理 O03=12, T03=12, E01=12, H01=12, O01=12；12-16 分立即处置，8-11 分进入第二波，7 分及以下持续监控。
2. 将试点限定在公司画像的 `pilot_scope`，建议 8-12 周、一条线、一个班组和 3-5 台关键设备。
3. 第一轮建议按 P 40%、C 25%、I 20%、O 15% 配置实施资源，并另行安排培训、校准、安全审查和停机窗口。
4. 为每个 KPI 明确数据源、公式、责任人、基线、3 个月门槛和 6 个月目标。
5. 以保守 ROI 情景作为扩线门槛；未形成可审计的实际净收益前不扩大投资。

Prioritise 12-16 risks immediately, restrict the pilot to one line or cell for 8-12 weeks, define auditable KPI sources and owners, and use the conservative ROI case as the scale gate.

### Do（执行） / Do

- **P - Perception:** 建立关键测点台账；完成校准与现场比对；复用现有 PLC/仪表接口；补齐缺失状态；设置缺失、冻结、漂移和时间戳规则。
- **C - Connectivity:** 绘制网络与数据去向；监测可用率、延迟和丢包；配置边缘缓存与断点续传；实施分区和最小权限；开展断线恢复演练。
- **I - Integration:** 统一设备、工单、批次、单位和 KPI 编码；建立映射表；先做最小接口；按角色共享看板；把异常纳入电子闭环和交接班。
- **O - Optimisation:** 对主要损失做 Pareto；为参数试验设置审批和回退；先规则/趋势后模型；采用小范围对照验证；把有效规则固化为 SOP。

Execute foundation-first actions across P/C/I/O, retain calibration, configuration, training, exception, and financial evidence, and preserve human confirmation and safe rollback.

### Check（检查） / Check

1. 前 12 周每周检查数据缺失、断线、告警、异常关闭、培训参与和试验偏差。
2. **建议在实施后 3 个月进行第一次完整复测**：使用相同问卷版本、计分规则和尽可能相同的岗位结构；12-16 分风险应至少下降 4 分或一个等级，重点成熟度分数建议提高至少 0.20/5。
3. **建议在实施后 6 个月进行第二次复盘测试**：检查风险是否稳定在 7 分及以下、成熟度累计改善是否达到约 0.35/5、KPI 是否持续以及真实收益是否支持基准情景。

Conduct the first full retest at month 3 and the second review at month 6, using consistent instruments and auditable operational and financial evidence.

### Act（改进） / Act

- 达到门槛：固化为 SOP，并仅向一条相邻产线复制。
- 部分达到：复盘人、机、料、法、环和测量系统，调整后再试。
- 未达到或风险上升：停止扩线，执行安全回退并重算 ROI。
- 证据不足：补充基线、日志、校准和样本代表性，不把感知变化直接当作财务收益。
- 将 6 个月结果转为下一轮 Plan，更新风险、KPI、资源和试点边界。

Standardise only verified gains, correct partial results, roll back unsafe or ineffective changes, and feed month-6 evidence into the next PDCA cycle.

## 5. 前五项行动摘要 / Top-Five Action Summary

| 优先级 | 风险 | PCIO | 行动 / Action | 预期效果 / Expected effect | 复测 / Retest |
|---:|---|---|---|---|---|
| 1 | O03=12 | H | 同步修订交接班、纸质记录、异常会议和标准作业，避免数字化与旧流程并行重复。 / Update handover, paper records, exception meetings, and standard work to avoid duplicate old and digital processes. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 2 | T03=12 | I | 建立轻量数据字典、唯一编码和 KPI 公式；每次接口变更执行对账。 / Create a lightweight data dictionary, unique identifiers, and KPI formulas; reconcile every interface change. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 3 | E01=12 | C | 优先开放协议、可导出数据和接口验收条款；保留替代供应商清单。 / Prefer open protocols, exportable data, and interface acceptance clauses; retain alternative suppliers. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 4 | H01=12 | H | 采用岗位化微培训、现场辅导和超级用户机制，培训后用真实任务验证。 / Use role-based micro-training, floor coaching, and super-users; verify learning with real tasks. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 5 | O01=12 | I | 定义单一试点边界、RACI、异常升级路径和联合签字门槛。 / Define one pilot boundary, RACI, escalation path, and joint approval gates. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |

> 简要结论：先处理最高风险并夯实 P/C 基础，再完成 I 的统一口径和 O 的闭环验证；3 个月决定纠偏，6 个月决定标准化和扩线。所有数值仅供参考。

> Summary: address the highest risks and stabilise P/C first, then complete I definitions and O closed-loop validation. Month 3 determines correction; month 6 determines standardisation and scaling. All values are for reference only.
