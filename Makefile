SHELL := /bin/bash

# Environment
ENV_FILE ?= .env
COMPOSE ?= docker compose

.PHONY: help
help:
	@echo "Common targets:"
	@echo "  make up              # Start all services (reads .env)"
	@echo "  make down            # Stop all services"
	@echo "  make restart         # Restart services"
	@echo "  make pull            # Pull images"
	@echo "  make reset           # Down + remove volumes, then pull"
	@echo "  make check-answers   # Verify answers.md paths exist"
 
	@echo "  make test            # Run repository tests"
	@echo "  make release-exam3   # Build/push exam3 images (disabled)"

.PHONY: up
up:
	$(COMPOSE) up -d

.PHONY: down
down:
	$(COMPOSE) down

.PHONY: restart
restart: down up

.PHONY: pull
pull:
	$(COMPOSE) pull

.PHONY: reset
reset:
	$(COMPOSE) down -v || true
	$(COMPOSE) pull

.PHONY: reset-up
reset-up: reset up

.PHONY: check-answers
check-answers:
	bash scripts/check_answers.sh

# Usage: DOCKERHUB_NAMESPACE=<ns> VERSION=<tag> make release-exam3
.PHONY: build-and-push
build-and-push:
	@echo "Build/push disabled. Use prebuilt images via .env (CKX_IMAGE_NS/CKX_VERSION)."

# Keep target for docs compatibility; delegates to build-and-push (no-op)
.PHONY: release-exam3
release-exam3: build-and-push
	@echo "release-exam3 finished (no-op). To use prebuilt images, set CKX_IMAGE_NS/CKX_VERSION in .env and run 'make up'."

.PHONY: test
test:
	bash tests/run_all.sh
