# ------------------------------------------------------------------------------
# OpenAPI client generation (generic)
#
# Assumes:
#   - You have a `bootstrap` target (possibly from magic-make or your own)
#   - The generated client lives in $(CLIENT_DIR)
#   - Your package manager can run scripts (npm/yarn/pnpm/bun)
#
# Usage examples:
#   make openapi-bootstrap
#   make openapi-generate
#   make openapi-gen OPENAPI=https://example.com/openapi.json CLIENT_DIR=my-client
#
# Overrides:
#   make openapi-gen STACK=nextjs-api-client APP=myapp PM=npm \
#     OPENAPI=https://api.m2c2kit.com/openapi.json CLIENT_DIR=m2c2-ts \
#     GENERATE_SCRIPT=generate:api
# ------------------------------------------------------------------------------

.PHONY: openapi-bootstrap openapi-generate openapi-gen

# ----- Defaults (override on CLI) ---------------------------------------------
STACK ?= nextjs-api-client
APP ?= openapi-client
PM ?= npm

# Where the generated project lives after bootstrap
CLIENT_DIR ?= $(APP)

# OpenAPI spec URL or local file path
OPENAPI ?= https://example.com/openapi.json

# Script name inside package.json (or equivalent)
GENERATE_SCRIPT ?= generate:api

# ----- Helper: run package-manager scripts -----------------------------------
# Supports: npm, yarn, pnpm, bun (add more if you want)
define PM_RUN
	@if [ "$(PM)" = "npm" ]; then \
		npm run $(1); \
	elif [ "$(PM)" = "yarn" ]; then \
		yarn $(1); \
	elif [ "$(PM)" = "pnpm" ]; then \
		pnpm run $(1); \
	elif [ "$(PM)" = "bun" ]; then \
		bun run $(1); \
	else \
		echo "Unsupported PM: $(PM). Use PM=npm|yarn|pnpm|bun"; \
		exit 2; \
	fi
endef

# ----- Targets ----------------------------------------------------------------
openapi-bootstrap:
	@echo "Bootstrapping OpenAPI client..."
	@echo "  STACK=$(STACK)"
	@echo "  APP=$(APP)"
	@echo "  PM=$(PM)"
	@echo "  OPENAPI=$(OPENAPI)"
	@$(MAKE) bootstrap STACK=$(STACK) APP=$(APP) PM=$(PM) OPENAPI=$(OPENAPI)

openapi-generate:
	@echo "Generating OpenAPI client..."
	@echo "  CLIENT_DIR=$(CLIENT_DIR)"
	@echo "  PM=$(PM)"
	@echo "  OPENAPI=$(OPENAPI)"
	@echo "  SCRIPT=$(GENERATE_SCRIPT)"
	@cd $(CLIENT_DIR) && OPENAPI="$(OPENAPI)" $(call PM_RUN,$(GENERATE_SCRIPT))

# One-shot: bootstrap then generate
openapi-gen: openapi-bootstrap openapi-generate
