# ------------------------------------------------------------------------------
# FastAPI + Jinja2 development workflow Makefile
#
# Usage examples:
#   make help
#   make install
#   make dev
#   make dev-reload
#   make prod
#
# Override defaults:
#   make dev APP=myapp.main:app HOST=0.0.0.0 PORT=8080
# ------------------------------------------------------------------------------

.PHONY: help init install install-dev clean dev dev-reload prod test lint format check-types

# ----- Project configuration (override on the CLI or via env) -----------------
APP ?= main:app                # FastAPI app location (module:app_instance)
HOST ?= 127.0.0.1              # Server host
PORT ?= 8000                   # Server port
WORKERS ?= 4                   # Number of workers for production
LOG_LEVEL ?= info              # Uvicorn log level (debug, info, warning, error)

# Optional: pass extra args to uvicorn
UVICORN_ARGS ?=

# ----- Help ------------------------------------------------------------------
help:
	@echo ""
	@echo "FastAPI + Jinja2 Development Targets:"
	@echo ""
	@echo "Setup:"
	@echo "  init           Bootstrap new FastAPI + Jinja2 + Tailwind project"
	@echo "  install        Install dependencies via uv"
	@echo "  install-dev    Install with dev dependencies"
	@echo "  clean          Remove cache and temp files"
	@echo ""
	@echo "Development:"
	@echo "  dev            Run development server"
	@echo "  dev-reload     Run with auto-reload (watches for changes)"
	@echo "  prod           Run production server with multiple workers"
	@echo ""
	@echo "Quality:"
	@echo "  test           Run tests with pytest"
	@echo "  lint           Check code with ruff"
	@echo "  format         Format code with ruff"
	@echo "  check-types    Type check with mypy"
	@echo ""
	@echo "Config (overridable):"
	@echo "  APP=$(APP)"
	@echo "  HOST=$(HOST)"
	@echo "  PORT=$(PORT)"
	@echo "  WORKERS=$(WORKERS)"
	@echo "  LOG_LEVEL=$(LOG_LEVEL)"
	@echo ""
	@echo "Examples:"
	@echo "  make dev"
	@echo "  make dev-reload APP=api.main:app PORT=3000"
	@echo ""

# ----- Initialization --------------------------------------------------------
init:
	bash scripts/fastapi-jinja-tailwind.sh || sh ./scripts/fastapi-jinja-tailwind.sh

# ----- Installation ----------------------------------------------------------
install:Installation ----------------------------------------------------------
install:
	uv pip install -e .

install-dev:
	uv pip install -e ".[dev]"

clean:
	rm -rf __pycache__ .pytest_cache .mypy_cache .ruff_cache
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete

# ----- Development Server ----------------------------------------------------
dev:
	uv run uvicorn $(APP) --host $(HOST) --port $(PORT) --log-level $(LOG_LEVEL) $(UVICORN_ARGS)

dev-reload:
	uv run uvicorn $(APP) --host $(HOST) --port $(PORT) --reload --log-level $(LOG_LEVEL) $(UVICORN_ARGS)

# ----- Production Server -----------------------------------------------------
prod:
	uv run uvicorn $(APP) --host $(HOST) --port $(PORT) --workers $(WORKERS) --log-level $(LOG_LEVEL) $(UVICORN_ARGS)

# ----- Testing & Quality -----------------------------------------------------
test:
	uv run pytest

test-cov:
	uv run pytest --cov --cov-report=html --cov-report=term

lint:
	uv run ruff check .

format:
	uv run ruff format .

check-types:
	uv run mypy .

# Run all quality checks
check: lint check-types test
	@echo "✅ All checks passed"
