#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Pretty output helpers
# -----------------------------
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }
info()  { printf '\033[34m[info]\033[0m %s\n' "$*"; }
warn()  { printf '\033[33m[warn]\033[0m %s\n' "$*"; }
error() { printf '\033[31m[err ]\033[0m %s\n' "$*" >&2; }

# -----------------------------
# Args / interactive prompts
# -----------------------------
# Allow:
#   ./init.sh               -> prompts for app + pm
#   ./init.sh my-app        -> prompts for pm
#   ./init.sh my-app npm    -> creates with npm
APP="${1:-}"
PM="${2:-}"

if [[ -z "${APP}" ]]; then
  read -rp "App directory name [my-expo-app]: " APP
  APP="${APP:-my-expo-app}"
fi

if [[ -z "${PM}" ]]; then
  read -rp "Package manager (npm|yarn|pnpm) [npm]: " PM
  PM="${PM:-npm}"
fi

# Normalize pm to lowercase
PM="$(printf '%s' "$PM" | tr '[:upper:]' '[:lower:]')"

bold "React Native / Expo + TypeScript init"
info "App: $APP"
info "Package manager: $PM"

# -----------------------------
# Package-manager shims
# -----------------------------
case "$PM" in
  npm)
    CREATE=(npx create-expo-app "$APP" --template blank-typescript)
    ADD=(npm install --legacy-peer-deps)
    ADD_DEV=(npm install -D --legacy-peer-deps)
    ;;
  yarn)
    CREATE=(yarn create expo-app "$APP" --template blank-typescript)
    ADD=(yarn add)
    ADD_DEV=(yarn add -D)
    ;;
  pnpm)
    CREATE=(pnpm create expo-app "$APP" --template blank-typescript)
    ADD=(pnpm add)
    ADD_DEV=(pnpm add -D)
    ;;
  *)
    error "Unsupported package manager: $PM (use npm, yarn, or pnpm)"
    exit 1
    ;;
esac

# -----------------------------
# Create Expo app
# -----------------------------
if [[ -d "$APP" ]]; then
  warn "Directory '$APP' already exists."
  read -rp "Continue and use this directory anyway? [y/N]: " CONT
  case "${CONT:-}" in
    y|Y) info "Using existing directory '$APP'." ;;
    *)   error "Aborting."; exit 1 ;;
  esac
else
  info "Creating Expo app..."
  "${CREATE[@]}"
fi

pushd "$APP" >/dev/null

# -----------------------------
# Install additional dependencies
# -----------------------------
info "Installing additional dependencies..."
"${ADD[@]}" \
  @react-navigation/native \
  @react-navigation/native-stack \
  react-native-safe-area-context \
  react-native-screens \
  expo-status-bar

# -----------------------------
# Dev dependencies
# -----------------------------
info "Installing dev dependencies..."
"${ADD_DEV[@]}" \
  @types/react \
  @typescript-eslint/eslint-plugin \
  @typescript-eslint/parser \
  prettier \
  jest \
  @testing-library/react-native

# -----------------------------
# ESLint config
# -----------------------------
info "Creating .eslintrc.js..."
cat > .eslintrc.js <<'ESLINT'
module.exports = {
  extends: [
    'expo',
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  rules: {
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
  },
};
ESLINT

# -----------------------------
# Prettier config
# -----------------------------
info "Creating .prettierrc..."
cat > .prettierrc <<'PRETTIER'
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "tabWidth": 2
}
PRETTIER

# -----------------------------
# tsconfig updates
# -----------------------------
info "Updating tsconfig.json..."
node <<'NODE'
const fs = require('fs');
const p = 'tsconfig.json';
if (fs.existsSync(p)) {
  const config = JSON.parse(fs.readFileSync(p, 'utf8'));
  config.compilerOptions = Object.assign({}, config.compilerOptions, {
    strict: true,
    baseUrl: '.',
    paths: {
      '@/*': ['./src/*'],
      '@components/*': ['./src/components/*'],
      '@screens/*': ['./src/screens/*'],
      '@hooks/*': ['./src/hooks/*'],
      '@utils/*': ['./src/utils/*'],
    }
  });
  fs.writeFileSync(p, JSON.stringify(config, null, 2));
}
NODE

# -----------------------------
# Create src structure
# -----------------------------
info "Creating project structure..."
mkdir -p src/{components,screens,hooks,utils,navigation}

# -----------------------------
# Sample screen
# -----------------------------
info "Creating HomeScreen.tsx..."
cat > src/screens/HomeScreen.tsx <<'SCREEN'
import { StyleSheet, Text, View } from 'react-native';
import { StatusBar } from 'expo-status-bar';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Welcome to Expo!</Text>
      <Text style={styles.subtitle}>React Native + TypeScript</Text>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  subtitle: {
    fontSize: 18,
    color: '#666',
  },
});
SCREEN

# -----------------------------
# Navigation setup
# -----------------------------
info "Creating navigation..."
cat > src/navigation/AppNavigator.tsx <<'NAV'
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import HomeScreen from '@screens/HomeScreen';

export type RootStackParamList = {
  Home: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen 
          name="Home" 
          component={HomeScreen}
          options={{ title: 'Expo App' }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
NAV

# -----------------------------
# Update App.tsx
# -----------------------------
info "Updating App.tsx..."
cat > App.tsx <<'APP'
import AppNavigator from './src/navigation/AppNavigator';

export default function App() {
  return <AppNavigator />;
}
APP

# -----------------------------
# babel.config.js with path aliases
# -----------------------------
info "Updating babel.config.js..."
cat > babel.config.js <<'BABEL'
module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          root: ['./src'],
          extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
          alias: {
            '@': './src',
            '@components': './src/components',
            '@screens': './src/screens',
            '@hooks': './src/hooks',
            '@utils': './src/utils',
            '@navigation': './src/navigation',
          },
        },
      ],
    ],
  };
};
BABEL

# Need babel-plugin-module-resolver
# Need babel-plugin-module-resolver
info "Installing babel-plugin-module-resolver..."
"${ADD_DEV[@]}" babel-plugin-module-resolver
# -----------------------------
# Package.json scripts
# -----------------------------
info "Adding npm scripts..."
node <<'NODE'
const fs = require('fs');
const p = 'package.json';
const pkg = JSON.parse(fs.readFileSync(p, 'utf8'));
pkg.scripts = Object.assign({}, pkg.scripts, {
  lint: 'eslint .',
  format: 'prettier --write .',
  'type-check': 'tsc --noEmit'
});
fs.writeFileSync(p, JSON.stringify(pkg, null, 2));
NODE

# -----------------------------
# .gitignore additions
# -----------------------------
info "Updating .gitignore..."
cat >> .gitignore <<'GITIGNORE'

# Metro cache
.metro-cache/

# EAS
.eas/
eas.json

# Testing
coverage/
GITIGNORE

# -----------------------------
# README
# -----------------------------
info "Creating README.md..."
cat > README.md <<'README'
# Expo React Native App

A React Native app built with Expo and TypeScript.

## Quick Start

```bash
# Install dependencies
make install

# Start development server
make start

# Run on iOS simulator
make ios

# Run on Android emulator
make android

# Run on web
make web
```

## Development

```bash
# Lint code
make lint

# Format code
make format

# Type check
make type-check

# Run tests
make test

# Run all checks
make check
```

## Project Structure

```
.
├── App.tsx
├── src/
│   ├── components/     # Reusable components
│   ├── screens/        # Screen components
│   ├── navigation/     # Navigation setup
│   ├── hooks/          # Custom hooks
│   └── utils/          # Utility functions
└── package.json
```

## Path Aliases

```typescript
import Component from '@components/Component';
import HomeScreen from '@screens/HomeScreen';
import useCustomHook from '@hooks/useCustomHook';
```

## Building

```bash
# Install EAS CLI
npm install -g eas-cli

# Configure EAS
eas build:configure

# Build for iOS
make build-ios

# Build for Android
make build-android
```
README

# -----------------------------
# Copy Makefile if it exists
# -----------------------------
if [[ -f ../expo-powertools.mk ]]; then
  info "Copying Makefile..."
  cp ../expo-powertools.mk Makefile
elif [[ -f expo-powertools.mk ]]; then
  info "Copying Makefile..."
  cp expo-powertools.mk Makefile
fi

popd >/dev/null

cat <<MSG

====================================================
✅ Expo + React Native + TypeScript setup complete!

To get started:

  cd $APP
  make install          # Install remaining dependencies
  make start            # Start Expo dev server

Then:
  - Press 'i' for iOS simulator
  - Press 'a' for Android emulator  
  - Press 'w' for web browser
  - Scan QR code with Expo Go app on your phone

Tips:
  - Edit src/screens/ to add new screens
  - Use path aliases: @components, @screens, @hooks
  - Run 'make help' to see all available commands
  - Install Expo Go app on your phone for testing
====================================================
MSG
