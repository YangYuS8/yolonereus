# 后端敏捷路线（PHP）

适用对象：负责 `backend/`。框架建议 Laravel。目标：每个 Sprint（1 周）交付一条可用的后端能力切片，4 个 Sprint 完成 MVP。

## 通用约束
- 契约优先：任何接口变更先更新 `doc/openapi.yaml`，然后才动代码。
- DoR（就绪定义）：故事需有输入/输出示例、错误码与鉴权规则。
- DoD（完成定义）：通过 Feature 测试，文档与迁移更新，日志可追踪，回滚策略明确。

## Sprint 0（准备，0.5 周）
- 故事：作为维护者，我能拉起后端并通过健康检查。
- DoD：容器启动、`GET /healthz` 返回 200，统一错误响应中间件。
- 任务：项目骨架、连接 PostgreSQL/Redis/MinIO（SDK 初始化）。

## Sprint 1（认证与用户）
- 故事：作为用户，我能登录并获取个人信息。
- DoR：`/auth/login`、`/users/me` 的模型与错误码在 OpenAPI 中定义。
- DoD：JWT 签发/校验中间件；`/users/me` 返回规范字段；基础 RBAC（role 字段驱动）。

## Sprint 2（项目与样本 + 直传）
- 故事1：作为用户，我能创建和查看项目。
- 故事2：作为用户，我能直传对象并创建样本元数据。
- DoR：`Project`、`Sample` 的字段、分页参数与 `presign` 契约明确。
- DoD：`/projects` 列表/创建/详情；`/storage/presign`（MinIO S3 预签名）；`/samples` 列表/创建；输入校验与错误码。

## Sprint 3（任务与状态查询）
- 故事：作为用户，我能发起推理任务并查询进度。
- DoR：队列消息 schema（`task_id`, `sample_id`, `asset_key`, `params`）与状态机定义。
- DoD：`POST /tasks` 入队（Redis）；`GET /tasks/{task_id}` 返回状态；基础幂等（`Idempotency-Key` 头）。

## Sprint 4（结果回写与审计）
- 故事：作为系统，我能接收推理结果并落库展示。
- DoR：`DetectionResult` 模型字段确定；回写路径（内部路由或直写 DB）明确。
- DoD：回写接口或内部服务集成；事务与幂等处理；关键操作审计日志。

## 工程与发布
- 数据库迁移/回滚脚本；种子用户与项目。
- 测试：Feature 覆盖登录、项目/样本、预签名、任务；Mock MinIO/Redis。
- 日志与追踪：`request_id` 注入；错误日志结构化。
- 发布策略：Blue/Green 或最小停机；变更前备份数据库与对象存储配置。

## 协作清单
- 与前端：分页/筛选一致；错误码稳定且可读。
- 与推理：结果字段与阈值统一；失败重试与死信策略同步。
- 与 PM：每周 Demo，阻塞项（如权限或存储策略）提前暴露。
