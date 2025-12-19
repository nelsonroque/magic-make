# magic-make: Copilot Instructions

## Project Overview

**magic-make** is a collection of composable, language-agnostic Makefile patterns for build, test, and release workflows. It treats Make as the orchestration layer while logic lives in language-specific scripts.

### Key Design Principles

1. **Make is the interface** - Universal, CI-friendly, composable
2. **Logic lives elsewhere** - Python scripts for Python logic, shell scripts for setup, Make wires them together
3. **No opinionated naming** - Everything is runtime-configurable via Make variables
4. **Override-friendly** - All defaults can be overridden: `make publish PKG=foo CLI=bar`

## Architecture

### Core Components

- **`py-powertools.mk`** - Python packaging with `uv` (build, publish, version bumping)
- **`fastapi-powertools.mk`** - FastAPI + Jinja2 development server workflows
- **`frontend-powertools.mk`** - Next.js/React workflows (dev, build, shadcn utilities)
- **`expo-powertools.mk`** - React Native/Expo mobile development workflows
- **`openapi-powertools.mk`** - OpenAPI client generation (supports npm/yarn/pnpm/bun)
- **`scripts/`** - Python and shell scripts that contain actual logic

### Why This Structure?

Makefiles orchestrate, scripts implement. This separation allows:
- Easy testing of logic independent of Make
- Language-specific tooling stays in language-specific files
- Make remains the universal entrypoint for all workflows

## Critical Workflows

### Python Packaging (`py-powertools.mk`)

**Key variables (override at runtime):**
- `PKG` - Package name (defaults to folder name)
- `CLI` - CLI entrypoint (defaults to `PKG`)
- `ARGS` - Arguments for `make run`

**Common commands:**
```bash
make install                           # Editable install via uv
make publish-test PKG=my-package       # Publish to TestPyPI
make publish PKG=my-package            # Publish to PyPI
make bump-minor                        # Version bumping (patch/minor/major)
make run CLI=mycli ARGS="--help"       # Run CLI via uv
```

**Version bumping:** Uses `scripts/bump_version.py` which parses `pyproject.toml` with `tomlkit` and updates the `project.version` field.

### FastAPI Server (`fastapi-powertools.mk`)

**Key variables (override at runtime):**
- `APP` - FastAPI app location (defaults to `main:app`)
- `HOST` - Server host (defaults to `127.0.0.1`)
- `PORT` - Server port (defaults to `8000`)
- `WORKERS` - Number of workers for production
- `LOG_LEVEL` - Uvicorn log level

**Common commands:**
```bash
make init                              # Bootstrap FastAPI + Jinja2 + Tailwind
make install                           # Install via uv
make dev                               # Start dev server
make dev-reload                        # Auto-reload on file changes
make prod WORKERS=8                    # Production with 8 workers
make test                              # Run pytest
make lint                              # Check with ruff
```

**Init script:** `scripts/fastapi-jinja-tailwind.sh` creates a complete FastAPI project with Jinja2 templates, Tailwind CSS (via CDN), and proper project structure. Generates `main.py`, templates, static assets, and `pyproject.toml`.

**Pattern:** Uses `uv run uvicorn` for consistent environment isolation. Separates dev (single process) from prod (multi-worker) workflows.

### Frontend (`frontend-powertools.mk`)

**Auto-detects package manager:** Checks for `pnpm-lock.yaml` → `package-lock.json` → defaults to npm

**Key commands:**
```bash
make init                              # Bootstrap Next.js + Tailwind + shadcn
make dev                               # Start dev server
make shadcn-add button card            # Add shadcn components
make export-config                     # Export project config to ./export/
```

**Init script:** `scripts/nextjs-tailwind-shadcn.sh` sets up complete Next.js project with Tailwind CSS and shadcn/ui components. Supports in-place mode (`./init.sh . pnpm`) or new directory.

### Expo/React Native (`expo-powertools.mk`)

**Auto-detects package manager:** Checks for `pnpm-lock.yaml` → `yarn.lock` → `package-lock.json` → defaults to npm

**Key commands:**
```bash
make init                              # Bootstrap Expo + TypeScript + Navigation
make start                             # Start Expo dev server
make ios                               # Run iOS simulator
make android                           # Run Android emulator
make web                               # Run in web browser
make build-ios                         # Build with EAS
```

**Init script:** `scripts/expo-init.sh` creates complete React Native/Expo project with TypeScript, React Navigation, path aliases (`@components`, `@screens`, etc.), ESLint, Prettier, and proper project structure.

**Pattern:** Generates `src/` directory structure with screens, components, navigation, hooks, and utils. Configures Babel for module resolution.

### OpenAPI Client Generation (`openapi-powertools.mk`)

**Variables:**
- `OPENAPI` - Spec URL or file path
- `CLIENT_DIR` - Where generated client lives
- `PM` - Package manager (npm/yarn/pnpm/bun)
- `GENERATE_SCRIPT` - Script name in package.json

**Pattern:** Uses `define PM_RUN` macro to support multiple package managers uniformly.

## Project Conventions

### Make Patterns

- **`.PHONY` declarations** - All targets are phony (don't represent files)
- **Help targets** - Every Makefile includes `make help` with documentation
- **Variable defaults** - `VAR ?= default` pattern allows CLI overrides
- **Clean separation** - `clean` removes artifacts, `build` is clean by default

### Python Scripts

- **CLI arguments via `sys.argv`** - Simple, direct (see `bump_version.py`)
- **tomlkit for TOML parsing** - Preserves formatting when updating `pyproject.toml`
- **Exit codes matter** - Scripts exit non-zero on failure for Make integration

### Shell Scripts

- **Strict mode**: `set -euo pipefail` (exit on error, undefined vars, pipe failures)
- **Interactive when needed** - Falls back to prompts if args missing
- **Pretty output** - Color-coded info/warn/error functions

## Integration Points

- **uv for Python** - Package manager, tool runner (`uv tool run`), virtual environments
- **TestPyPI → PyPI** - Two-stage publishing with `publish-test` for validation
- **shadcn/ui** - Component system, uses `npx shadcn@latest` commands
- **No external CI config** - Makefiles are CI-ready but don't assume specific platform

## When Modifying

- **Adding new ecosystem?** Create `{ecosystem}-powertools.mk` following the pattern
- **New Python script?** Add to `scripts/`, call via `uv run` in Makefile
- **New Make variable?** Add to help target, use `?=` for defaults
- **Supporting new package manager?** Update `PM_RUN` macro in relevant Makefile

## What This Project Does NOT Do

- No hard-coded project names or paths
- No build logic in Make (delegated to scripts/tools)
- No Docker implementation yet (planned)
- No testing framework included (project-specific)
