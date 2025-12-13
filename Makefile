# ------------------------------------------------------------------------------
# Generic Python packaging + uv workflow Makefile
#
# Usage examples:
#   make help
#   make install
#   make build
#   make publish-test PKG=my-package
#   make publish PKG=my-package
#   make run CLI=mycli ARGS="--help"
#
# Override defaults:
#   make PKG=lab-cli CLI=clicli
# ------------------------------------------------------------------------------

.PHONY: help install clean build check publish-test publish bump bump-patch bump-minor bump-major run tree tests

# ----- Project configuration (override on the CLI or via env) -----------------
PKG ?= $(notdir $(CURDIR))     # default: folder name (often matches package)
CLI ?= $(PKG)                  # default: same as PKG (override if different)
PYPI_REPO_TEST ?= testpypi
TEST_PYPI_INDEX ?= https://test.pypi.org/simple/
PYPI_FALLBACK_INDEX ?= https://pypi.org/simple/

# Optional: pass args to "make run"
ARGS ?=

# If your egg-info name differs, you can override this too
EGG_INFO_GLOB ?= *.egg-info

# ----- Help ------------------------------------------------------------------
help:
	@echo ""
	@echo "Targets:"
	@echo "  install        Install in editable mode (uv)"
	@echo "  clean          Remove build artifacts"
	@echo "  build          Build sdist+wheel"
	@echo "  check          Twine check dist/*"
	@echo "  publish-test   Clean -> build -> check -> upload to TestPyPI -> install from TestPyPI"
	@echo "  publish        Clean -> build -> check -> upload to PyPI"
	@echo "  bump           Bump patch version (default)"
	@echo "  bump-patch     Bump patch version"
	@echo "  bump-minor     Bump minor version"
	@echo "  bump-major     Bump major version"
	@echo "  run            Run CLI via uv (ARGS=...)"
	@echo "  tree           Write repo tree to pretty_tree.txt"
	@echo ""
	@echo "Config (overridable):"
	@echo "  PKG=$(PKG)"
	@echo "  CLI=$(CLI)"
	@echo ""

# ----- Dev workflow ----------------------------------------------------------
install:
	uv pip install -e .

clean:
	rm -rf dist build $(EGG_INFO_GLOB)

build: clean
	uv tool run --from build python -m build

check:
	uv tool run --from twine python -m twine check dist/*

# ----- Publishing ------------------------------------------------------------
publish-test: build check
	uv tool run --from twine python -m twine upload --repository $(PYPI_REPO_TEST) dist/*
	uv pip install -i $(TEST_PYPI_INDEX) --extra-index-url $(PYPI_FALLBACK_INDEX) $(PKG)

publish: build check
	uv tool run --from twine python -m twine upload dist/*

# ----- Version bumping -------------------------------------------------------
bump-patch:
	uv run python scripts/bump_version.py patch

bump-minor:
	uv run python scripts/bump_version.py minor

bump-major:
	uv run python scripts/bump_version.py major

bump: bump-patch

# ----- Convenience -----------------------------------------------------------
run:
	uv run $(CLI) $(ARGS)

tree:
	tree -I __pycache__ > pretty_tree.txt

# Example "tests" target: avoid committing secrets; uses env var if present
tests:
	@echo "Set SLACK_TOKEN in your environment before running this target."
	@test -n "$$SLACK_TOKEN" || (echo "ERROR: SLACK_TOKEN is not set" && exit 1)
	uv run $(CLI) get-links C0123456789
