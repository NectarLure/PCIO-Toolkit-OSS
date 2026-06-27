# PCIO Framework Public Brief / PCIO 四层框架公开说明

PCIO describes a staged smart-manufacturing transformation logic for resource-constrained manufacturing SMEs: **Perception, Connectivity, Integration, and Optimisation**.

PCIO 用于描述制造业中小企业面向智能制造转型的分层逻辑：**感知、连接、集成、优化**。

| Layer | Design role | Public interpretation |
|---|---|---|
| Perception | Capture credible production-state data | Sensors, manual checks, calibration, data completeness |
| Connectivity | Move data reliably | Local networks, edge buffering, protocol conversion, latency control |
| Integration | Convert isolated data into shared operational context | Dashboards, work-order links, exception workflow, common KPI definitions |
| Optimisation | Support evidence-based improvement | Rules, statistical analysis, decision support, planning scenarios |

The framework assumes dependency between layers. Optimisation should not bypass weak sensing, connectivity, or integration foundations. The public release explains the artifact design and provides synthetic examples only.

该框架强调层间依赖关系：感知、连接或集成基础薄弱时，不应直接跳入高级优化。本公开版仅说明人工制品设计并提供合成示例。
