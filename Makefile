# ==============================================================================
# magic-make: Universal Development Workflow Dispatcher
# ==============================================================================
# This Makefile provides easy access to all magic-make powertools.
#
# Quick Start:
#   make help                    # Show this help
#   make expo-init               # Bootstrap Expo/React Native app
#   make fastapi-init            # Bootstrap FastAPI + Jinja2 app
#   make frontend-init           # Bootstrap Next.js + Tailwind app
#
# Or use powertools directly:
#   make -f expo-powertools.mk init
#   make -f fastapi-powertools.mk init
#   make -f py-powertools.mk install
# ==============================================================================

.PHONY: help

help:
	@echo ""
	@echo "🪄 magic-make: Composable Development Workflows"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Bootstrap New Projects:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  make expo-init          Create Expo/React Native app"
	@echo "  make fastapi-init       Create FastAPI + Jinja2 + Tailwind app"
	@echo "  make frontend-init      Create Next.js + Tailwind + shadcn app"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Available Powertools:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  py-powertools.mk        Python packaging (uv, PyPI, version bump)"
	@echo "  fastapi-powertools.mk   FastAPI development (uvicorn, test, lint)"
	@echo "  frontend-powertools.mk  Next.js/React (dev, build, shadcn)"
	@echo "  expo-powertools.mk      React Native/Expo (iOS, Android, web)"
	@echo "  openapi-powertools.mk   OpenAPI client generation"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "Usage Examples:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  # Use powertools directly:"
	@echo "  make -f expo-powertools.mk help"
	@echo "  make -f py-powertools.mk install"
	@echo ""
	@echo "  # Bootstrap with custom args:"
	@echo "  bash scripts/expo-init.sh my-mobile-app pnpm"
	@echo "  bash scripts/fastapi-jinja-tailwind.sh my-api"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""

# ==============================================================================
# Bootstrap Shortcuts
# ==============================================================================

.PHONY: expo-init fastapi-init frontend-init

expo-init:
	@bash scripts/expo-init.sh

fastapi-init:
	@bash scripts/fastapi-jinja-tailwind.sh

frontend-init:
	@bash scripts/nextjs-tailwind-shadcn.sh

# ==============================================================================
# Powertools Help (Quick Access)
# ==============================================================================

.PHONY: py-help fastapi-help frontend-help expo-help openapi-help

py-help:
	@make -f py-powertools.mk help

fastapi-help:
	@make -f fastapi-powertools.mk help

frontend-help:
	@make -f frontend-powertools.mk help

expo-help:
	@make -f expo-powertools.mk help

openapi-help:
	@make -f openapi-powertools.mk help
