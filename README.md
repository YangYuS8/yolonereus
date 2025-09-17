# Yolo-Nereus

海洋生态巡检样本管理系统（骨架版）。本仓库暂不包含业务代码，只提供服务边界约定、目录结构、环境变量样例与可直接启动的开发/生产 Docker 编排。

## 架构与职责

- `Next.js`（`frontend/`）：纯前端（UI/路由/SSR 可选），不直接承载业务 API。
- `PHP` 后端（`backend-php/`）：统一业务 API（认证、样本/任务/权限等）。
- `Python` 推理（`ml-python/`）：仅用于 YOLO 等模型推理，对内暴露接口或消费队列。
- 数据层：PostgreSQL（结构化/元数据）、MinIO（对象存储：图片/视频/模型权重）、Redis（缓存与任务队列）。
- 反向代理：不集成在本项目，由外部服务器统一接入与证书管理。

简化数据流（MVP）：

```
Frontend (Next.js)
		↓ REST/GraphQL
Backend  ——(enqueue)——>  Redis Queue  ——(consume)——>  Python
		↘───────────────(read/write)──────────────↙
			PostgreSQL  &  MinIO
```

## 目录结构

```
.
├─ frontend/              # Next.js 前端（占位，未含业务代码）
│  ├─ Dockerfile.dev
│  └─ Dockerfile.prod
├─ backend/           # PHP 后端（占位，未含业务代码）
│  ├─ Dockerfile.dev
│  └─ Dockerfile.prod
├─ python/             # Python 推理服务（占位，未含业务代码）
│  ├─ requirements.txt
│  ├─ Dockerfile.dev
│  └─ Dockerfile.prod
├─ docker-compose.dev.yml # 开发环境编排（挂载源码、开放端口、便于调试）
├─ docker-compose.prod.yml# 生产环境编排（最小暴露、命名卷、内部网络）
├─ .env.dev.example       # 开发环境变量样例
└─ .env.prod.example      # 生产环境变量样例
```

> 提示：当前镜像均可启动但不会提供实际业务接口，`CMD` 使用占位命令防止容器退出。待代码就绪后再替换为真实启动命令。

## 环境变量（关键项）

应用容器使用下列变量（见示例文件）：

- 数据库
  - `POSTGRES_HOST`/`POSTGRES_PORT`/`POSTGRES_DB`/`POSTGRES_USER`/`POSTGRES_PASSWORD`
- Redis/队列
  - `REDIS_HOST`/`REDIS_PORT`/`REDIS_PASSWORD`（可为空）
- MinIO（S3 兼容）
  - `MINIO_ENDPOINT`（如 `minio:9000`）/`MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD`
  - 应用侧访问：`S3_ENDPOINT`/`S3_ACCESS_KEY`/`S3_SECRET_KEY`/`S3_BUCKET`
- 前端
  - `NEXT_PUBLIC_API_BASE_URL`（指向 PHP 后端对外地址）

将 `.env.dev.example` 或 `.env.prod.example` 复制为 `.env`（或通过 `--env-file` 指定）并按需修改。

## 开发环境：启动与停止

前置：安装 Docker 与 Docker Compose 插件。

```bash
# 启动（首次建议构建）
docker compose -f docker-compose.dev.yml --env-file .env.dev.example up -d --build

# 查看状态
docker compose -f docker-compose.dev.yml ps

# 查看日志
docker compose -f docker-compose.dev.yml logs -f

# 停止
docker compose -f docker-compose.dev.yml down
```

默认映射端口：

- Frontend: `http://localhost:3000`
- PHP Backend (dev 内置服务器): `http://localhost:8000`
- ML Python (占位): `http://localhost:8001`
- Postgres: `localhost:5432`
- Redis: `localhost:6379`
- MinIO S3: `http://localhost:9000`，Console: `http://localhost:9001`

### 使用 Makefile（推荐）

已经提供便捷的 `Makefile`，自动选择 `.env.dev`（或回退到 `.env.dev.example`）。

```bash
# 启动/停止（dev）
make up
make ps
make logs              # 或 make logs svc=backend
make down

# 重建镜像（dev）
make rebuild

# 进入容器（dev）
make exec svc=backend            # 默认 cmd=sh
make exec svc=postgres cmd=bash  # 指定命令

# 生产环境（仅占位）
make up-prod
make ps-prod
make logs-prod
make down-prod
```

## 生产环境：启动与要点

```bash
docker compose -f docker-compose.prod.yml --env-file .env.prod.example up -d --build
```

原则：

- 默认不对外暴露数据库/Redis/MinIO 端口，仅内部网络访问。
- 应用服务由外部反向代理接入（TLS/域名/限流/鉴权）。
- 使用命名卷持久化数据（Postgres、MinIO），升级/迁移时请先备份。

## 后续集成（建议但非当前范围）

- 反向代理：Nginx/Traefik 在外部服务器配置路由与证书。
- CI/CD：GitHub Actions 构建推送镜像、Compose/K8s 部署；保护 `main` 分支。
- 监控与日志：后期引入 Prometheus/Grafana 或 Loki/ELK；先以 `docker logs` 为主。
- 数据/模型追踪：可评估 DVC/MLflow；推理服务记录 `model_name`、`model_version`。

## 常见问题

- 首次启动失败：请确认 `.env` 中的密码复杂度满足 Postgres/MinIO 要求，端口未被占用。
- 前端无法访问后端：开发模式下检查 `NEXT_PUBLIC_API_BASE_URL` 是否指向 `http://localhost:8000`。
- 容器秒退：当前无业务代码，容器以占位命令常驻；替换 CMD 后若秒退，请查看 `logs`。
