# 匿名装备制造企业 PCIO 实施案例分析报告
# PCIO Implementation Case Analysis for 匿名装备制造企业

**项目代码 / Project code:** DISC-PILOT-01
**样本量 / Valid responses:** n=64
**分析版本 / Analysis version:** 3.0.0
**证据声明 / Evidence statement:** 企业问卷为当前项目数据；±0.5℃、15.3%、29% 和外部 n=52 结果仅供参考，不构成效果承诺。 / Company survey results are current-project data; ±0.5°C, 15.3%, 29%, and the external n=52 findings are references only, not guarantees.

## 1. 执行摘要 / Executive Summary

### 中文
匿名装备制造企业 是一家小型（20-99人）机械加工/装备企业，本次聚焦“机加工与装配单元”。基于 64 份有效技术人员问卷，PCIO 四层平均成熟度处于“局部分散”区间；I 集成层为当前首要瓶颈（2.58/5），C 连接层相对较高（2.79/5）。综合生产绩效感知为 3.06/5。建议先在既定试点范围内补齐基础测量、连接和数据语义，再逐步进入优化模型。

### English
匿名装备制造企业 is a Small (20-99 employees) Machinery / equipment company, with this diagnosis focused on '机加工与装配单元.' Based on 64 valid technician responses, average four-layer PCIO maturity is 'Fragmented'. I Integration is the primary bottleneck (2.58/5), while C Connectivity is relatively stronger (2.79/5). Perceived overall production performance is 3.06/5. The recommended route is to close measurement, connectivity, and data-context gaps within the pilot before advancing to optimisation models.

## 2. 当前状态描述 / Current State

| 层级 / Layer | 当前均值 / Current mean | 理想参考 / Target reference | 差距 / Gap | 状态 / Band |
|---|---:|---:|---:|---|
| P 感知层 / P Perception | 2.78 | 4.2 | 1.42 | 局部分散 / Fragmented |
| C 连接层 / C Connectivity | 2.79 | 4.2 | 1.41 | 局部分散 / Fragmented |
| I 集成层 / I Integration | 2.58 | 4.2 | 1.62 | 局部分散 / Fragmented |
| O 优化层 / O Optimisation | 2.67 | 4.2 | 1.53 | 局部分散 / Fragmented |

**画像 / Profile:** 机加工/多品种小批量 / Job shop / high-mix low-volume; 核心痛点 / Core pain points: 质量缺陷、返工或批次波动、排产、换线或装卸等待时间长、人工抄表、纸质记录或重复录入、跨班组/部门协作不顺 / Defects, rework, or batch variation, Scheduling, changeover, or loading delays, Manual readings, paper records, or duplicate entry, Weak cross-shift or cross-department collaboration.

**数据质量 / Data quality:** 总体 KMO 低于 0.60，因子结构仅可作探索性解释。；KMO 题项层面的样本量与变量数之比低于 5:1。 / Overall KMO is below 0.60; factor-structure interpretation is exploratory.; The KMO item-level sample-to-variable ratio is below 5:1.

**信效度摘要 / Reliability and validity:** Cronbach's α: P=0.982；C=0.961；I=0.981；O=0.974；H=0.964；R=0.539; KMO=0.595, Bartlett χ²=426.925, df=190, p=<0.001. KMO/Bartlett 只评价当前量表相关结构，不证明业务因果。 / KMO and Bartlett evaluate correlation structure, not business causality.

## 3. 主要瓶颈与 PCIO 层级映射 / Main Bottlenecks and PCIO Mapping

| 优先级 | 层级 | 分数 | 至4.2差距 | 诊断与行动 / Diagnosis and action |
|---:|---|---:|---:|---|
| 1 | I | 2.58 | 1.62 | 建立测点、设备、批次/工单、异常和 KPI 数据字典，统一交接班和关闭责任。 / Create a tag, asset, batch/work-order, exception, and KPI dictionary with shared handover and closure ownership. |
| 2 | O | 2.67 | 1.53 | 先用趋势、SPC 和规则报警验证重复问题；数据门槛通过后再进入异常检测、预测维护或 MPC。 / Validate recurring problems with trends, SPC, and rule alerts before anomaly detection, predictive maintenance, or MPC. |
| 3 | P | 2.78 | 1.42 | 复用 PLC 信号采集设备状态、节拍、停机原因和关键质量结果，先覆盖瓶颈设备。 / Reuse PLC signals for state, cycle, downtime reason, and critical quality results, starting with bottleneck assets. |
| 4 | C | 2.79 | 1.41 | 对断线、采集延迟和重复录入建立清单；先打通一个设备到一个看板的数据链。 / List disconnections, collection delays, and duplicate entry; connect one asset-to-dashboard data path first. |

外部区域样本 `n=52` 中，`Sensor_Inf=4.5077` 为四项技术影响均值最高，仅略高于 IoT。因此本报告把可靠感知、校准和数据质量作为高级分析前置条件，不把“传感器最高”解释为安装更多传感器必然产生收益。

In the external regional sample of `n=52`, `Sensor_Inf=4.5077` was the highest of four technology-influence means, only slightly above IoT. The report therefore treats reliable sensing, calibration, and data quality as prerequisites, not as proof that adding sensors automatically creates value.

## 4. 与行业情境及理想 PCIO 水平的对比 / Comparison with Industry Context and Ideal PCIO

本工具包尚无经验证的“机械加工/装备行业总体均值”数据库，因此不伪造行业百分位。本报告采用 4.2/5 作为内部理想运行参考，并结合机加工/多品种小批量的测点、批次/工单和异常闭环要求作定性行业对比。当前最大差距位于 I 集成层，说明行业适配应先解决该层基础，而不是直接复制 AI 或数字孪生方案。

The toolkit does not yet hold a validated population benchmark for the Machinery / equipment sector, so no industry percentile is fabricated. A 4.2/5 internal operating target is used together with qualitative requirements for Job shop / high-mix low-volume. The largest gap is in I Integration; sector adaptation should close this foundation before copying AI or digital-twin solutions.

## 5. 模块化实施路径 / Modular Implementation Route

| 顺序 | PCIO 层 | 低成本行动 / Low-cost action | 技术选型 / Technology option | 试点边界 / Pilot boundary |
|---:|---|---|---|---|
| 1 | P | 复用 PLC 信号采集设备状态、节拍、停机原因和关键质量结果，先覆盖瓶颈设备。 / Reuse PLC signals for state, cycle, downtime reason, and critical quality results, starting with bottleneck assets. | 复用现有 PLC/DCS；必要时增加低成本智能电表、振动或温度传感器。 / Reuse installed PLC/DCS; add low-cost smart meters, vibration, or temperature sensing only where justified. | 仅在“机加工与装配单元”内试点，保留原流程回退。 / Pilot only within '机加工与装配单元', retaining rollback to the existing process. |
| 2 | C | 对断线、采集延迟和重复录入建立清单；先打通一个设备到一个看板的数据链。 / List disconnections, collection delays, and duplicate entry; connect one asset-to-dashboard data path first. | 优先 Modbus TCP/RTU、OPC UA 或 MQTT 边缘网关，并采用断点续传。 / Prefer Modbus TCP/RTU, OPC UA, or an MQTT edge gateway with store-and-forward. | 仅在“机加工与装配单元”内试点，保留原流程回退。 / Pilot only within '机加工与装配单元', retaining rollback to the existing process. |
| 3 | I | 建立测点、设备、批次/工单、异常和 KPI 数据字典，统一交接班和关闭责任。 / Create a tag, asset, batch/work-order, exception, and KPI dictionary with shared handover and closure ownership. | 采用 CSV/API、轻量时序数据库和 Grafana/现有 BI；避免先采购重型 MES。 / Use CSV/API exchange, a lightweight time-series store, and Grafana/existing BI before considering a heavy MES. | 仅在“机加工与装配单元”内试点，保留原流程回退。 / Pilot only within '机加工与装配单元', retaining rollback to the existing process. |
| 4 | O | 先用趋势、SPC 和规则报警验证重复问题；数据门槛通过后再进入异常检测、预测维护或 MPC。 / Validate recurring problems with trends, SPC, and rule alerts before anomaly detection, predictive maintenance, or MPC. | Python/SPC、规则引擎和现有控制器参数整定；模型必须保留人工确认和回退。 / Use Python/SPC, rule engines, and existing controller tuning with human confirmation and rollback. | 仅在“机加工与装配单元”内试点，保留原流程回退。 / Pilot only within '机加工与装配单元', retaining rollback to the existing process. |

实施顺序保持 P→C→I→O。可并行准备人员培训和数据字典，但 O 层模型上线必须通过测量质量、连接稳定性和业务语义三项门槛。

The execution order remains P→C→I→O. Training and data dictionaries may be prepared in parallel, but O-layer deployment must pass measurement-quality, connectivity, and business-context gates.

## 6. 预期量化改善效果 / Expected Quantitative Improvement

| KPI | 个性化筛选情景 / Personalised screening scenario | 证据类型 / Evidence |
|---|---|---|
| 装卸/等待时间 / Loading or waiting time | 筛选情景：减少 14.2%-21.1%；29% 为罐区案例参考。 / Screening scenario: reduce by 14.2%-21.1%; 29% is a tank-farm case reference. | PCIO-E010 (E2) adjusted as P |
| 返工/缺陷率 / Rework or defect rate | 试点情景：降低 5%-10%，须保持产品组合和检验口径一致。 / Pilot scenario: reduce by 5%-10%, holding product mix and inspection definitions constant. | Toolkit planning scenario (P) |
| 人工记录时间 / Manual recording time | 试点情景：降低 15%-30%，前提是同步取消重复纸质流程。 / Pilot scenario: reduce by 15%-30% if duplicate paper steps are retired at the same time. | Toolkit planning scenario (P) |

所有情景值均需用同产品、同班次或经标准化处理的基线验证，并同时报告绝对值、百分比、时间窗和异常事件。案例值仅供参考。

All scenario values require a comparable or standardised baseline and must report absolute values, percentages, time windows, and exceptions. Case values are references only.

## 7. PDCA 实施计划与里程碑 / PDCA Plan and Milestones

| 阶段 | 周期 | 主要工作 / Main work | 通过条件 / Gate |
|---|---|---|---|
| Plan | 第1-2周 / Weeks 1-2 | 冻结试点边界、KPI、测点、责任人和基线口径；完成安全评审。 / Freeze pilot, KPI, tags, owners, baseline, and safety review. | 基线可复算；缺失和校准状态已记录。 / Reproducible baseline with missingness and calibration recorded. |
| Do | 第3-6周 / Weeks 3-6 | 复用现有系统接入最小数据链，建立看板、异常记录和培训。 / Connect the minimum data path using installed systems; deploy dashboard, exception log, and training. | 连续两周数据完整率达到项目门槛，人工回退可用。 / Two weeks above the project completeness threshold with rollback available. |
| Check | 第7-10周 / Weeks 7-10 | 对比基线和试点，检查过程稳定性、收益、误报警和人员负担。 / Compare pilot with baseline; assess stability, benefit, false alerts, and workload. | KPI 计算复核；收益与副作用同时记录。 / KPI independently checked; benefits and side effects recorded. |
| Act | 第11-12周 / Weeks 11-12 | 标准化有效措施，修正无效规则，决定扩展、继续或停止。 / Standardise effective actions, revise ineffective rules, and decide expand/continue/stop. | 业务、技术、数据和安全负责人联合签字。 / Joint approval by business, technical, data, and safety owners. |

## 附录：统计解释边界 / Appendix: Statistical Interpretation Boundaries

- 四层中，I 集成层均值最低（2.58），C 连接层最高（2.79）。
- 综合生产绩效感知均值为 3.06/5，属于“局部分散”区间。
- 与综合绩效关系最强的当前样本维度为 P 感知层 (r=0.595)；相关不等于因果。
- 在 FDR 校正后的综合绩效回归中，P 感知层、I 集成层、O 优化层、人机协同保留统计关联。
- 按是否参与数字化项目、班次和岗位进行的组间检验在 FDR 校正后均未显著；这表示当前样本未发现稳定差异，不等于各组完全相同。
- 外部 n=52 区域样本中 Sensor_Inf=4.5077 为四项技术影响均值最高，但仅略高于 IoT。本项目据此采用“感知与数据质量优先”，不把该结果解释为普遍因果。
- Among the four PCIO layers, I Integration is lowest (2.58) and C Connectivity is highest (2.79).
- Perceived overall production performance is 3.06/5, in the 'Fragmented' band.
- The strongest current-sample association with overall performance is P Perception (r=0.595); correlation does not establish causality.
- In the overall-performance regression after FDR correction, P Perception, I Integration, O Optimisation, Human-machine collaboration retain statistical associations.
- No group difference by digital-project participation, shift, or role remained significant after FDR correction; this is absence of stable evidence, not proof that all groups are identical.
- In the external regional sample of n=52, Sensor_Inf=4.5077 was the highest of four technology-influence means, only slightly above IoT. The toolkit therefore uses a perception-and-data-quality-first rule without claiming universal causality.
- 问卷结果反映人员感知和当前工作实践，应与设备历史数据、质量、能耗和停机记录交叉验证。
- Survey results reflect perceptions and current practice and must be triangulated with asset, quality, energy, and downtime records.
