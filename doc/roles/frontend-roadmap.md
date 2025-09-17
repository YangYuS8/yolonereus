# 前端敏捷路线（Next.js）

适用对象：负责 `frontend/`。目标：每个 Sprint（1 周）交付一个可演示的垂直切片，3-4 个 Sprint 达成 MVP。

## Sprint 0（准备，0.5 周）
- 用户故事
  - 作为开发者，我能在本地一条命令启动前端，并连到 Mock/Dev API。
- 任务切片（DoD：本地可启动、有基础路由与布局）
  - 初始化 Next.js（App Router + TS）与 UI（Tailwind 或 AntD）。
  - 全局布局：Header/Sidebar/Content；环境变量接入 `NEXT_PUBLIC_API_BASE_URL`。
  - 接入 React Query/SWR（含全局错误提示与 Loading）。

## Sprint 1（认证与项目列表）
- 用户故事
  - 作为用户，我可以登录并看到我的项目列表。
- 验收标准（DoD）
  - 登录页 + 表单校验；调用 `/auth/login`；Token 安全存放（HttpOnly Cookie 或内存）。
  - 受保护路由守卫；`/users/me` 加载用户信息。
  - `/projects` 列表：分页、排序、搜索（URL 同步）。
- 技术任务
  - 从 `openapi.yaml` 生成 TS 类型与 API 客户端。
  - 基础表格组件与空状态组件。

## Sprint 2（样本上传闭环）
- 用户故事
  - 作为用户，我能上传图片并在样本列表看到它。
- 验收标准（DoD）
  - 向后端请求 `POST /storage/presign` 获取预签名 URL。
  - 前端用 `PUT` 直传 MinIO（展示进度与失败重试）。
  - 提交元数据 `POST /samples`；样本列表支持按项目/巡检筛选。
- 技术任务
  - 上传组件（文件校验、大小限制、取消/重试）。
  - 列表状态缓存、分页与筛选条件记忆。

## Sprint 3（推理与任务进度）
- 用户故事
  - 作为用户，我能对样本发起推理并看到进度与结果。
- 验收标准（DoD）
  - 触发 `POST /tasks`；轮询 `GET /tasks/{task_id}` 到完成/失败。
  - 在样本详情展示 `DetectionResult`（标签、分数、bbox 可视化）。
- 技术任务
  - 任务进度组件（轮询或 SSE 预留）。
  - 结果可视化（Canvas/Overlay）。

## 工程与质量基线（持续执行）
- 代码规范：ESLint + Prettier；单元测试（Vitest/Jest）覆盖登录与列表关键逻辑。
- 可观测：在关键操作埋点（登录、上传、任务轮询），便于复盘性能与失败率。
- 文档即契约：任何接口变更先改 `doc/openapi.yaml`，前端随之更新 SDK 与类型。

## 协作清单
- 与后端：对齐分页/筛选字段与错误码；预签名上传与任务接口参数需先走 PR 修改 OpenAPI。
- 与推理：约定 `DetectionResult` 字段稳定，若变更由后端统一转换，前端不直接依赖内部字段。
- 与 PM：每周 Demo 展示切片；看板维持 3 列（Todo/Doing/Done），限制在制品数（WIP）。
