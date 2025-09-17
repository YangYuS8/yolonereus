# API 规范概述

本项目采用前后端分离，所有对外业务 API 由 PHP 后端统一提供，Python 推理服务仅对内使用（容器内网或消息队列）。本规范用于约束接口风格、通用参数与错误模型，具体接口定义见 `openapi.yaml`。

## 基本约定
- 协议与域名：HTTPS，统一前缀建议 `/api`。
- 版本管理：在 URL 前缀携带版本，如 `/api/v1/...`；重大变更以 v2+ 新前缀提供。
- 数据格式：请求与响应使用 JSON（除文件上传直传等特殊场景）。
- 时区与时间：一律使用 ISO 8601（UTC），如 `2025-09-17T08:00:00Z`。
- 编码：UTF-8。

## 认证与授权
- 认证：采用 Bearer Token（JWT）放在 `Authorization: Bearer <token>` 头。
- 鉴权：RBAC，按用户/角色/项目维度控制资源访问。
- 会话：Token 建议短有效期 + 刷新机制。

## 分页与筛选
- 标准分页参数：`page`（默认 1），`page_size`（默认 20，最大 100）。
- 列表接口统一返回：
  ```json
  {
    "data": [...],
    "page": 1,
    "page_size": 20,
    "total": 123
  }
  ```
- 支持通用筛选：`q`（关键词）、`sort`（`field:asc|desc`），按资源补充专有过滤字段。

## 错误处理
- HTTP 状态码语义：
  - 2xx 成功；4xx 客户端错误；5xx 服务端错误。
- 统一错误响应：
  ```json
  {
    "error": {
      "code": "SOME_CODE",
      "message": "人类可读错误",
      "details": { "field": "why" }
    }
  }
  ```
- 典型错误码：`VALIDATION_FAILED`、`UNAUTHORIZED`、`FORBIDDEN`、`NOT_FOUND`、`CONFLICT`、`RATE_LIMITED`。

## 幂等性与重试
- 对于创建/任务触发等需要防重复的操作，支持 `Idempotency-Key` 请求头。
- 服务端对网络抖动导致的重试需保证幂等（若可识别同一键则返回相同结果）。

## 速率限制（可选）
- 提供全局与按用户/Token 的速率限制，超限返回 `429 Too Many Requests`，并在响应头包含 `Retry-After`。

## 文件上传策略
- 大文件（图片/视频）采用 S3 直传：后端签发预签名 URL，前端直传到 MinIO；完成后回调/确认以落库元数据。
- 小文件（JSON/标注）可走后端直传。

## 任务与回调
- 推理等长耗时操作统一采用异步：
  - 触发任务返回 `202 Accepted` + `task_id`。
  - 客户端轮询 `GET /api/v1/tasks/{task_id}` 或订阅 WebSocket/SSE 获取进度。

## 一致性与可观测性
- 所有接口记录 `request_id`（如 `X-Request-Id`），便于链路追踪。
- 响应可选返回 `trace_id`/`span_id`，与日志/监控系统对接。

## 安全最佳实践
- 严格 CORS 策略；避免向前端泄漏服务内部信息。
- 输入输出验证（后端为准）；文件类型/大小校验，必要时做病毒扫描。

---

详细接口见同目录 `openapi.yaml`，内部推理服务接口见 `ml-internal-api.yaml`。
