# 推理服务敏捷路线（Python）

适用对象：负责 `python/`。目标：每个 Sprint（1 周）交付可运行的推理能力切片，4 个 Sprint 完成 MVP。

## Sprint 0（准备与 Spike，0.5 周）
- Spike：模型选型（Ultralytics YOLO 等）、权重体积与依赖评估（CPU 可用性）。
- DoD：FastAPI 启动 `/healthz`；能连接 MinIO/Redis；拉取测试对象成功。

## Sprint 1（本地推理与数据结构）
- 故事：作为开发者，我能在容器内加载模型并完成单张图片推理。
- DoR：`DetectionResult` 字段在 OpenAPI 确认；输入 `asset_key` 与 `params` 约定。
- DoD：模型常驻内存；同步接口 `/infer` 仅供调试；输出字段对齐。

## Sprint 2（异步消费与回写）
- 故事：作为系统，我能消费队列任务并回写结果。
- DoR：队列消息 schema 固化；后端回写接口或内部直写策略选定。
- DoD：Redis 消费者可运行；拉取对象→推理→回写完整链路；失败重试（N 次）。

## Sprint 3（性能与健壮性）
- 故事：作为维护者，我能观察推理 QPS、耗时与失败率，并在模型异常时快速定位。
- DoD：健康探针包含“模型就绪”状态；处理指标导出（日志或 /metrics 预留）；死信队列与超时控制。

## 工程基线
- 结构化日志：含 `task_id`、`request_id`、耗时。
- 配置化：模型名称/版本、阈值、批大小等通过环境变量管理。
- 数据治理：记录 `model_name`, `model_version`, `weights_sha256`，便于追溯。

## 协作清单
- 与后端：统一状态机与错误码；明确回写路径与事务/幂等策略。
- 与前端：结果字段稳定；可视化所需字段尽早确定（bbox/score/label）。
- 与 PM：资源评估（是否需要 GPU）、部署窗口与回滚方案。
