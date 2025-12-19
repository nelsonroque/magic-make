# ---------------------------------------------
# Detect package manager
# ---------------------------------------------
# If lockfiles exist, prefer pnpm > npm
ifeq ($(wildcard pnpm-lock.yaml),pnpm-lock.yaml)
  PM = pnpm
else ifeq ($(wildcard package-lock.json),package-lock.json)
  PM = npm
else
  PM = npm
endif

# Command prefix (npm run / pnpm run)
RUN = $(PM) run

# ---------------------------------------------
# Core dev tasks
# ---------------------------------------------
init:
	bash scripts/nextjs-tailwind-shadcn.sh || sh ./scripts/nextjs-tailwind-shadcn.sh

dev:
	$(RUN) dev

build:
	$(RUN) build

start:
	$(RUN) start

lint:
	$(RUN) lint

format:
	$(RUN) format || npx prettier . --write

clean:
	rm -rf .next node_modules

reinstall:
	rm -rf node_modules && $(PM) install

# ---------------------------------------------
# shadcn utilities
# ---------------------------------------------
shadcn-add:
	npx shadcn@latest add $(filter-out $@,$(MAKECMDGOALS))

shadcn-init:
	npx shadcn@latest init -y

# ---------------------------------------------
# Tailwind utility for debugging
# ---------------------------------------------
tailwind-scan:
	npx tailwindcss -i ./src/app/globals.css -o /dev/null --config tailwind.config.ts --watch

# ---------------------------------------------
# Export project configuration
# ---------------------------------------------
export-config:
	mkdir -p ./export
	cp package.json ./export/
	cp tsconfig.json ./export/
	cp postcss.config.mjs ./export/
	find src -type f -name "*.ts" -o -name "*.tsx" > ./export/file-list.txt
	echo "Project configuration exported to ./export/"

# Required so `make shadcn-add button` works
%:
	@:


# Makefile for Next.js static export workflow
# Usage:
#   make build
#   make check
#   make serve
#   make preview

# Root-level Makefile

APP_DIR=app
REPO_NAME=nextjs-shadcn-tailwind-template
PORT=3000

build:
	@echo "🔨 Building Next.js static export..."
	cd $(APP_DIR) && npm run build

check:
	@if [ -d "$(APP_DIR)/out" ]; then \
		echo "📁 'out/' directory exists."; \
		ls -l $(APP_DIR)/out; \
	else \
		echo "❌ 'out/' directory NOT found. Run 'make build'"; \
		exit 1; \
	fi

serve: check
	@echo "🚀 Starting server at http://localhost:$(PORT)/$(REPO_NAME)/"
	cd $(APP_DIR) && npx serve out -l $(PORT)

preview:
	@echo "🌐 Visit:"
	@echo "http://localhost:$(PORT)/$(REPO_NAME)/"
