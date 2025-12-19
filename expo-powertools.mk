# ------------------------------------------------------------------------------
# React Native / Expo workflow Makefile
#
# Usage examples:
#   make help
#   make install
#   make start
#   make ios
#   make android
#   make web
#
# Override defaults:
#   make start EXPO_ARGS="--tunnel"
# ------------------------------------------------------------------------------

.PHONY: help init install clean start ios android web build-ios build-android lint format test

# ----- Project configuration (override on the CLI or via env) -----------------
# Optional: pass extra args to expo
EXPO_ARGS ?=

# ----- Detect package manager ------------------------------------------------
ifeq ($(wildcard pnpm-lock.yaml),pnpm-lock.yaml)
  PM = pnpm
else ifeq ($(wildcard yarn.lock),yarn.lock)
  PM = yarn
else ifeq ($(wildcard package-lock.json),package-lock.json)
  PM = npm
else
  PM = npm
endif

# Command prefix
ifeq ($(PM),npm)
  RUN = npm run
  EXEC = npx
  INSTALL = npm install
else ifeq ($(PM),yarn)
  RUN = yarn
  EXEC = yarn
  INSTALL = yarn install
else ifeq ($(PM),pnpm)
  RUN = pnpm run
  EXEC = pnpm dlx
  INSTALL = pnpm install
endif

# ----- Help ------------------------------------------------------------------
help:
	@echo ""
	@echo "React Native / Expo Development Targets:"
	@echo ""
	@echo "Setup:"
	@echo "  init           Bootstrap new Expo app with TypeScript"
	@echo "  install        Install dependencies"
	@echo "  clean          Remove cache and temp files"
	@echo ""
	@echo "Development:"
	@echo "  start          Start Expo dev server"
	@echo "  ios            Run on iOS simulator"
	@echo "  android        Run on Android emulator"
	@echo "  web            Run web version"
	@echo ""
	@echo "Build:"
	@echo "  build-ios      Build iOS app (requires EAS)"
	@echo "  build-android  Build Android app (requires EAS)"
	@echo "  prebuild       Generate native projects"
	@echo ""
	@echo "Quality:"
	@echo "  lint           Check code with ESLint"
	@echo "  format         Format code with Prettier"
	@echo "  test           Run tests"
	@echo "  type-check     Check TypeScript types"
	@echo ""
	@echo "Detected package manager: $(PM)"
	@echo ""

# ----- Initialization --------------------------------------------------------
init:
	bash scripts/expo-init.sh || sh ./scripts/expo-init.sh

# ----- Installation ----------------------------------------------------------
install:
	$(INSTALL)

clean:
	rm -rf node_modules .expo .expo-shared
	rm -rf ios/build android/build android/.gradle
	rm -rf .metro-cache

reinstall: clean install

# ----- Development -----------------------------------------------------------
start:
	$(EXEC) expo start $(EXPO_ARGS)

ios:
	$(EXEC) expo start --ios $(EXPO_ARGS)

android:
	$(EXEC) expo start --android $(EXPO_ARGS)

web:
	$(EXEC) expo start --web $(EXPO_ARGS)

# ----- Build -----------------------------------------------------------------
prebuild:
	$(EXEC) expo prebuild

build-ios:
	$(EXEC) eas build --platform ios

build-android:
	$(EXEC) eas build --platform android

build-all:
	$(EXEC) eas build --platform all

# ----- Quality ---------------------------------------------------------------
lint:
	$(RUN) lint || $(EXEC) eslint .

format:
	$(RUN) format || $(EXEC) prettier --write .

test:
	$(RUN) test || $(EXEC) jest

type-check:
	$(EXEC) tsc --noEmit

# Run all checks
check: lint type-check test
	@echo "✅ All checks passed"

# ----- Utilities -------------------------------------------------------------
upgrade:
	$(EXEC) expo upgrade

doctor:
	$(EXEC) expo-doctor

clear-cache:
	$(EXEC) expo start --clear

eject:
	$(EXEC) expo eject
