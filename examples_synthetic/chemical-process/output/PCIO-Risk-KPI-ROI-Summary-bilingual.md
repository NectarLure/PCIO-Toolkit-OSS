# 匿名流程制造企业 PCIO 风险、KPI 与 ROI 摘要
# PCIO Risk, KPI, and ROI Summary

**项目代码 / Project code:** CHEM-PILOT-01
**证据边界 / Evidence boundary:** 风险分数和 KPI/ROI 区间用于筛选与立项，不构成安全结论、预算报价或收益承诺。 / Risk scores and KPI/ROI ranges support screening and approval; they are not safety conclusions, price quotes, or benefit guarantees.

## 1. 优先风险 / Priority Risks

| 排名 | ID | 类别 | 风险 / Risk | 概率 | 影响 | 得分 | PDCA |
|---:|---|---|---|---:|---:|---:|---|
| 1 | T04 | 技术 / Technical | 基础数据未达门槛即上线高级优化 / Advanced optimisation deployed before foundation gates are met | 4 | 4 | 16 | Plan/Act |
| 2 | T01 | 技术 / Technical | 关键测点覆盖、校准或数据完整性不足 / Insufficient critical-tag coverage, calibration, or completeness | 4 | 4 | 16 | Plan/Do |
| 3 | H03 | 人力 / Workforce | 自动建议的授权、确认和安全责任边界不清 / Unclear authority, confirmation, and safety accountability for automated recommendations | 4 | 4 | 16 | Plan/Act |
| 4 | T02 | 技术 / Technical | 采集链路中断、延迟或网络隔离不足 / Collection interruption, latency, or inadequate network segregation | 4 | 4 | 16 | Do/Check |
| 5 | O02 | 组织 / Organisational | KPI 口径或收益基线不可复算 / Non-reproducible KPI definitions or benefit baseline | 4 | 3 | 12 | Plan/Check |
| 6 | E02 | 外部 / External | 本地备件、校准或运维支持响应不足 / Insufficient local spare-parts, calibration, or maintenance response | 4 | 3 | 12 | Plan/Do |
| 7 | H02 | 人力 / Workforce | 报警过多、误报或新增记录负担导致弃用 / Alert overload, false positives, or added recording burden causes abandonment | 4 | 3 | 12 | Check/Act |
| 8 | T03 | 技术 / Technical | 设备、批次、工单和异常语义不一致 / Inconsistent asset, batch, work-order, and exception semantics | 3 | 3 | 9 | Plan/Check |
| 9 | E03 | 外部 / External | 网络安全、合规或区域基础设施约束 / Cybersecurity, compliance, or regional infrastructure constraints | 3 | 3 | 9 | Plan/Check |
| 10 | O01 | 组织 / Organisational | 试点边界、责任人和异常关闭权责不清 / Unclear pilot boundary, ownership, and exception closure authority | 3 | 2 | 6 | Plan |

## 2. KPI 建议 / KPI Recommendations

| 排名 | KPI | PCIO | 目标 / Target | 情景说明 / Scenario |
|---:|---|---|---|---|
| 1 | 非计划停机时间 / Unplanned downtime | O | 5-12 % reduction | 以统一停机原因和连续基线验证规则报警价值。 |
| 2 | 关键工艺参数波动幅度 / Critical process-parameter variation | P | 10-20 % reduction | ±0.5℃仅作为基础门槛通过后的挑战参考。 |
| 3 | 单位产品蒸汽/能源消耗 / Steam or energy consumption per unit | P | 7.56-11.24 % reduction | 以分项计量和同产品基线验证能源改善。 |
| 4 | 关键测点与设备/批次/工单映射完整率 / Completeness of tag-to-asset/batch/work-order mapping | I | 90-95 % | 当前集成能力决定统计结果能否回到具体业务情境。 |
| 5 | 异常闭环按期完成率 / On-time exception closure rate | O | 80-90 % | 优化层先验证规则和行动闭环，再进入高级模型。 |
| 6 | 关键测点有效覆盖率 / Valid coverage of critical tags | P | 90-95 % | 感知层是后续连接、集成和优化的输入门槛。 |
| 7 | 试点数据采集可用率 / Pilot data-acquisition availability | C | 97-99 % | 用链路可用率代替“已联网”这一不可审计描述。 |
| 8 | 目标岗位任务验证通过率 / Task-based competence pass rate for target roles | H | 90-95 % | 培训完成不等于会用，以真实任务验证人机协同能力。 |

## 3. ROI 快速估算 / Rapid ROI Estimate

- 投资 / Investment: CNY 300,000
- 年度可改善价值池 / Annual addressable value: CNY 2,400,000
- 改善假设 / Improvement assumption: 7.6%-11.2%
- 静态回收期 / Simple payback: 16.1-26.2 months
- 说明 / Note: 回收期为简单静态估算，未计税、折旧、资金成本、停产损失或爬坡曲线。 / Payback is a simple static estimate excluding tax, depreciation, cost of capital, downtime, and ramp-up.

## 4. 企业改善操作流程 / Enterprise Improvement Workflow

**当前风险 / Current risks:** T04=16、T01=16、H03=16、T02=16、O02=12、E02=12、H02=12、T03=9、E03=9、O01=6

**当前 KPI 与目标 / Current KPIs and targets:** 非计划停机时间：成熟度 2.8551 → 5-12 % reduction；关键工艺参数波动幅度：成熟度 2.9150 → 10-20 % reduction；单位产品蒸汽/能源消耗：成熟度 2.9150 → 7.56-11.24 % reduction；关键测点与设备/批次/工单映射完整率：成熟度 2.8472 → 90-95 %；异常闭环按期完成率：成熟度 2.8551 → 80-90 %；关键测点有效覆盖率：成熟度 2.9150 → 90-95 %；试点数据采集可用率：成熟度 3.2830 → 97-99 %；目标岗位任务验证通过率：成熟度 3.1092 → 90-95 %

| 情景 / Scenario | 改善率 | 年度毛收益 | 年度净收益 | 静态回收期 | 三年 ROI |
|---|---:|---:|---:|---:|---:|
| 保守 / Conservative | 7.6% | 182,400 | 137,400 | 26.2 months | 37.4% |
| 基准 / Base | 9.4% | 225,600 | 180,600 | 19.9 months | 80.6% |
| 乐观 / Optimistic | 11.2% | 268,800 | 223,800 | 16.1 months | 123.8% |

### Plan（计划） / Plan

1. 按 4×4 得分优先处理 T04=16, T01=16, H03=16, T02=16, O02=12；12-16 分立即处置，8-11 分进入第二波，7 分及以下持续监控。
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
| 1 | T04=16 | O | 把数据完整率、连接稳定性、语义一致性和人工回退设为模型上线门槛。 / Make completeness, connectivity, semantics, and human rollback mandatory model-deployment gates. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 2 | T01=16 | P | 冻结关键测点清单，记录量程、单位、校准、缺失和责任人；先补瓶颈设备。 / Freeze the critical-tag list and record range, unit, calibration, missingness, and ownership; start with bottleneck assets. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 3 | H03=16 | O | 明确建议、批准、执行、回退和审计责任；安全相关动作必须由合格人员确认。 / Define recommendation, approval, execution, rollback, and audit ownership; qualified personnel confirm safety actions. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 4 | T02=16 | C | 建立断点续传、链路健康监控和网络分区；保留人工回退与本地缓存。 / Use store-and-forward, link-health monitoring, and network segmentation with manual fallback and local buffering. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |
| 5 | O02=12 | I | 冻结基线时间窗、产品组合、分母、异常剔除和财务确认规则。 / Freeze the baseline window, product mix, denominator, exclusions, and finance sign-off rules. | 风险降至 7 分及以下或至少下降 4 分 / Reduce to 7 or below or by at least 4 points | 3 个月首次完整复测；6 个月第二次复盘 / Months 3 and 6 |

> 简要结论：先处理最高风险并夯实 P/C 基础，再完成 I 的统一口径和 O 的闭环验证；3 个月决定纠偏，6 个月决定标准化和扩线。所有数值仅供参考。

> Summary: address the highest risks and stabilise P/C first, then complete I definitions and O closed-loop validation. Month 3 determines correction; month 6 determines standardisation and scaling. All values are for reference only.
