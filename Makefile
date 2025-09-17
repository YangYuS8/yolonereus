# Makefile for yolonereus
# 使用说明（示例）：
#   make up                 # 开发环境：构建并启动
#   make down               # 开发环境：停止并清理容器
#   make up-prod            # 生产环境：构建并启动（占位）
#   make logs svc=backend   # 查看指定服务日志（不指定 svc 则查看全部）

SHELL := /bin/sh
PROJECT := yolonereus

DEV_COMPOSE := docker-compose.dev.yml
PROD_COMPOSE := docker-compose.prod.yml

# 环境变量文件优先级：本地 .env.* 存在则优先，否则回退到 *.example
DEV_ENV := $(if $(wildcard .env.dev),.env.dev,.env.dev.example)
PROD_ENV := $(if $(wildcard .env.prod),.env.prod,.env.prod.example)

# 默认帮助目标
.PHONY: help
help:
	@echo "可用目标 Targets:"
	@echo "  up              - 开发：构建并启动 (-d --build)"
	@echo "  down            - 开发：停止并清理容器"
	@echo "  rebuild         - 开发：不使用缓存重建镜像"
	@echo "  ps              - 开发：查看服务状态"
	@echo "  logs            - 开发：查看日志（可选 svc=<name>）"
	@echo "  exec            - 开发：进入容器（需 svc=<name>，可选 cmd=sh）"
	@echo "  clean           - 开发：删除开发命名卷（需确认）"
	@echo "  up-prod         - 生产：构建并启动 (-d --build)"
	@echo "  down-prod       - 生产：停止并清理容器"
	@echo "  ps-prod         - 生产：查看服务状态"
	@echo "  logs-prod       - 生产：查看日志（可选 svc=<name>）"
	@echo "  exec-prod       - 生产：进入容器（需 svc=<name>，可选 cmd=sh)"

# -------------------- 开发环境 DEV --------------------

.PHONY: up
up:
	# 使用 dev compose 与 env 文件启动整个开发编排
	@echo "[DEV] env=$(DEV_ENV)" && \
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) up -d --build

.PHONY: down
down:
	# 停止开发编排并移除容器（保留卷）
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) down

.PHONY: rebuild
rebuild:
	# 无缓存地重建所有开发镜像
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) build --no-cache

.PHONY: ps
ps:
	# 查看开发服务状态
	docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) ps

.PHONY: logs
logs:
	# 查看日志；若提供 svc 变量，则仅查看该服务
	@if [ -n "$(svc)" ]; then \
		docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) logs -f $(svc); \
	else \
		docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) logs -f; \
	fi

.PHONY: exec
exec:
	# 进入某个开发服务容器执行命令：make exec svc=<service> [cmd=sh]
	@if [ -z "$(svc)" ]; then echo "Usage: make exec svc=<service> [cmd=sh]"; exit 1; fi
	@docker compose -f $(DEV_COMPOSE) --env-file $(DEV_ENV) exec $(svc) ${cmd-sh}

.PHONY: clean
clean:
	@echo "将删除开发环境命名卷：pgdata_dev, redisdata_dev, minio_dev"
	@read -p "Continue? [y/N] " a; if [ "$$a" = "y" ] || [ "$$a" = "Y" ]; then \
		docker volume rm $$(docker volume ls -q | grep -E '$(PROJECT).*|pgdata_dev|redisdata_dev|minio_dev' || true); \
	else echo "Skipped"; fi

# -------------------- 生产环境 PROD --------------------

.PHONY: up-prod
up-prod:
	# 使用 prod compose 与 env 文件启动生产编排（占位）
	@echo "[PROD] env=$(PROD_ENV)" && \
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) up -d --build

.PHONY: down-prod
down-prod:
	# 停止生产编排并移除容器（保留卷）
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) down

.PHONY: ps-prod
ps-prod:
	# 查看生产服务状态
	docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) ps

.PHONY: logs-prod
logs-prod:
	# 查看生产日志；若提供 svc 变量，则仅查看该服务
	@if [ -n "$(svc)" ]; then \
		docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) logs -f $(svc); \
	else \
		docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) logs -f; \
	fi

.PHONY: exec-prod
exec-prod:
	# 进入某个生产服务容器执行命令：make exec-prod svc=<service> [cmd=sh]
	@if [ -z "$(svc)" ]; then echo "Usage: make exec-prod svc=<service> [cmd=sh]"; exit 1; fi
	@docker compose -f $(PROD_COMPOSE) --env-file $(PROD_ENV) exec $(svc) ${cmd-sh}
