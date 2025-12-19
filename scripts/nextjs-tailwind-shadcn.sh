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
#   ./init.sh . pnpm        -> in-place setup using pnpm
APP="${1:-}"
PM="${2:-}"

if [[ -z "${APP}" ]]; then
  read -rp "App directory name [my-app]: " APP
  APP="${APP:-my-app}"
fi

if [[ -z "${PM}" ]]; then
  read -rp "Package manager (npm|pnpm) [npm]: " PM
  PM="${PM:-npm}"
fi

# Normalize pm to lowercase
PM="$(printf '%s' "$PM" | tr '[:upper:]' '[:lower:]')"

# Support in-place mode if APP="."
if [[ "$APP" == "." ]]; then
  APP_DIR="."
  IN_PLACE=1
  bold "Running in-place in current directory."
else
  APP_DIR="$APP"
  IN_PLACE=0
fi

# -----------------------------
# shadcn starter components
# -----------------------------
#SHADCN_COMPONENTS=("button" "card" "input" "textarea")
SHADCN_COMPONENTS=(
  "button"
  "card"
  "input"
  "textarea"
  "label"
  "checkbox"
  "radio-group"
  "switch"
  "slider"
  "select"
  "badge"
  "avatar"
  "alert"
  "alert-dialog"
  "dialog"
  "tabs"
  "accordion"
  "popover"
  "tooltip"
  "dropdown-menu"
  "separator"
  "scroll-area"
  "progress"
  "skeleton"
  "sheet"
  "table"
  "pagination"
  "breadcrumb"
)


# -----------------------------
# Package-manager shims
# -----------------------------
case "$PM" in
  npm)
    CREATE=(npx create-next-app@latest "$APP" --ts --eslint --app --src-dir --no-tailwind --yes)
    ADD_DEV=(npm install -D)
    ADD=(npm install)
    EXEC=(npx)
    RUN_DEV="npm run dev"
    ;;
  pnpm)
    CREATE=(pnpm create next-app "$APP" --ts --eslint --app --src-dir --no-tailwind --yes)
    ADD_DEV=(pnpm add -D)
    ADD=(pnpm add)
    EXEC=(pnpm dlx)
    RUN_DEV="pnpm dev"
    ;;
  *)
    error "Unsupported package manager: $PM (use npm or pnpm)"
    exit 1
    ;;
esac

bold "Next.js + Tailwind v4 + shadcn/ui init"
info "App: $APP_DIR"
info "Package manager: $PM"
[[ $IN_PLACE -eq 1 ]] && warn "In-place mode: skipping create-next-app."

# -----------------------------
# Create app (unless in-place)
# -----------------------------
if [[ $IN_PLACE -eq 0 ]]; then
  if [[ -d "$APP_DIR" ]]; then
    warn "Directory '$APP_DIR' already exists."
    read -rp "Continue and use this directory anyway? [y/N]: " CONT
    case "${CONT:-}" in
      y|Y) info "Using existing directory '$APP_DIR'." ;;
      *)   error "Aborting."; exit 1 ;;
    esac
  fi

  info "Initializing Next.js app..."
  "${CREATE[@]}"
else
  # Basic sanity check in in-place mode
  if [[ ! -f package.json ]]; then
    error "No package.json found in current directory. In-place mode expects an existing Next.js app."
    exit 1
  fi
fi

pushd "$APP_DIR" >/dev/null

# -----------------------------
# Dependencies
# -----------------------------
info "Installing Tailwind v4 + tooling..."
"${ADD_DEV[@]}" tailwindcss @tailwindcss/postcss postcss autoprefixer

info "Installing app deps..."
"${ADD[@]}" tesseract.js chrono-node ics file-saver lucide-react \
  clsx class-variance-authority tailwind-merge tailwind-animate

# -----------------------------
# PostCSS config for Tailwind v4
# -----------------------------
info "Writing postcss.config.mjs..."
cat > postcss.config.mjs <<'POSTCSS'
export default {
  plugins: {
    '@tailwindcss/postcss': {},
  },
}
POSTCSS

# -----------------------------
# Tailwind v4 entry (globals.css)
# -----------------------------
info "Configuring Tailwind entry in src/app/globals.css..."
mkdir -p src/app
printf '@import "tailwindcss";\n' > src/app/globals.css

# -----------------------------
# Ensure layout imports globals
# -----------------------------
info "Patching src/app/layout.tsx to import globals.css (if needed)..."
node <<'NODE'
const fs = require('fs');
const p = 'src/app/layout.tsx';
if (fs.existsSync(p)) {
  let s = fs.readFileSync(p,'utf8');
  if (!/globals\.css/.test(s)) {
    s = `import './globals.css';\n` + s;
  }
  fs.writeFileSync(p, s);
}
NODE

# -----------------------------
# tsconfig paths alias '@/*'
# -----------------------------
info "Adding '@/*' path alias to tsconfig.json..."
node <<'NODE'
const fs = require('fs');
const p = 'tsconfig.json';
if (!fs.existsSync(p)) process.exit(0);
const j = JSON.parse(fs.readFileSync(p,'utf8'));
j.compilerOptions = Object.assign({}, j.compilerOptions, {
  baseUrl: '.',
  paths: Object.assign({}, (j.compilerOptions||{}).paths, { '@/*': ['./src/*'] })
});
fs.writeFileSync(p, JSON.stringify(j,null,2));
NODE

# -----------------------------
# shadcn/ui init + components
# -----------------------------
info "Initializing shadcn/ui..."
"${EXEC[@]}" shadcn@latest init -y

info "Adding shadcn/ui components: ${SHADCN_COMPONENTS[*]}..."
"${EXEC[@]}" shadcn@latest add "${SHADCN_COMPONENTS[@]}"

# -----------------------------
# Demo page (if missing)
# -----------------------------
if [[ ! -f src/app/page.tsx ]]; then
  info "Creating src/app/page.tsx demo page..."
  mkdir -p src/app
  cat > src/app/page.tsx <<'PAGE'
import { Card } from "@/components/ui/card"
import { Button } from "@/components/ui/button"

export default function Page() {
  return (
    <main className="min-h-dvh flex items-center justify-center p-8">
      <Card className="max-w-md w-full p-6 space-y-4 text-center">
        <h1 className="text-3xl font-bold tracking-tight">
          Next.js + Tailwind v4 + shadcn/ui
        </h1>
        <p className="text-muted-foreground">
          You&apos;re ready to start building. Edit <code>src/app/page.tsx</code> to get going.
        </p>
        <Button size="lg">Let&apos;s build</Button>
      </Card>
    </main>
  );
}
PAGE
fi

# -----------------------------
# .env example (optional nicety)
# -----------------------------
if [[ ! -f .env.example ]]; then
  info "Creating .env.example..."
  cat > .env.example <<'ENV'
# Copy this file to .env.local and fill values as needed
# NEXT_PUBLIC_API_URL=
ENV
fi

popd >/dev/null

cat <<MSG

====================================================
✅ Setup complete.

To get started:

  cd $APP_DIR
  $RUN_DEV

Tips:
  - Re-run this script with APP="." to apply Tailwind v4 + shadcn/ui
    to an existing Next.js app in the current directory:
        ./init.sh . $PM

  - Use the generated Makefile:
        make dev
        make build
        make lint
====================================================
MSG
