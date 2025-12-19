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
#   ./init.sh               -> prompts for app
#   ./init.sh my-app        -> creates my-app/
#   ./init.sh .             -> in-place setup
APP="${1:-}"

if [[ -z "${APP}" ]]; then
  read -rp "App directory name [my-fastapi-app]: " APP
  APP="${APP:-my-fastapi-app}"
fi

# Support in-place mode if APP="."
if [[ "$APP" == "." ]]; then
  APP_DIR="."
  IN_PLACE=1
  bold "Running in-place in current directory."
else
  APP_DIR="$APP"
  IN_PLACE=0
fi

bold "FastAPI + Jinja2 + Tailwind CSS init"
info "App: $APP_DIR"

# -----------------------------
# Create directory structure
# -----------------------------
if [[ $IN_PLACE -eq 0 ]]; then
  if [[ -d "$APP_DIR" ]]; then
    warn "Directory '$APP_DIR' already exists."
    read -rp "Continue and use this directory anyway? [y/N]: " CONT
    case "${CONT:-}" in
      y|Y) info "Using existing directory '$APP_DIR'." ;;
      *)   error "Aborting."; exit 1 ;;
    esac
  else
    mkdir -p "$APP_DIR"
  fi
fi

pushd "$APP_DIR" >/dev/null

# -----------------------------
# Create directory structure
# -----------------------------
info "Creating project structure..."
mkdir -p static/css static/js
mkdir -p templates
mkdir -p app

# -----------------------------
# pyproject.toml
# -----------------------------
info "Creating pyproject.toml..."
cat > pyproject.toml <<'PYPROJECT'
[project]
name = "my-fastapi-app"
version = "0.1.0"
description = "FastAPI app with Jinja2 and Tailwind CSS"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.32.0",
    "jinja2>=3.1.4",
    "python-multipart>=0.0.12",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.3.0",
    "pytest-cov>=6.0.0",
    "ruff>=0.7.0",
    "mypy>=1.13.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "N", "W"]

[tool.mypy]
python_version = "3.11"
strict = true
PYPROJECT

# -----------------------------
# Main FastAPI app
# -----------------------------
info "Creating main.py..."
cat > main.py <<'MAIN'
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

app = FastAPI(title="FastAPI + Jinja2 + Tailwind")

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Templates
templates = Jinja2Templates(directory="templates")


@app.get("/", response_class=HTMLResponse)
async def home(request: Request):
    """Home page with Tailwind CSS."""
    return templates.TemplateResponse(
        "index.html",
        {
            "request": request,
            "title": "FastAPI + Jinja2 + Tailwind",
            "message": "Welcome to your new FastAPI app!",
        },
    )


@app.get("/health")
async def health():
    """Health check endpoint."""
    return {"status": "healthy"}
MAIN

# -----------------------------
# Base template with Tailwind
# -----------------------------
info "Creating templates/base.html..."
cat > templates/base.html <<'BASE'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{% block title %}FastAPI App{% endblock %}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="{{ url_for('static', path='/css/styles.css') }}">
</head>
<body class="bg-gray-50 min-h-screen">
    <nav class="bg-white shadow-sm border-b">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between h-16 items-center">
                <div class="flex-shrink-0">
                    <h1 class="text-xl font-bold text-gray-900">FastAPI</h1>
                </div>
                <div class="flex space-x-4">
                    <a href="/" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
                        Home
                    </a>
                    <a href="/health" class="text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium">
                        Health
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {% block content %}{% endblock %}
    </main>

    <footer class="bg-white border-t mt-auto">
        <div class="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
            <p class="text-center text-gray-500 text-sm">
                Built with FastAPI + Jinja2 + Tailwind CSS
            </p>
        </div>
    </footer>
</body>
</html>
BASE

# -----------------------------
# Home page template
# -----------------------------
info "Creating templates/index.html..."
cat > templates/index.html <<'INDEX'
{% extends "base.html" %}

{% block title %}{{ title }}{% endblock %}

{% block content %}
<div class="px-4 py-6 sm:px-0">
    <div class="flex items-center justify-center min-h-[60vh]">
        <div class="max-w-2xl w-full">
            <div class="bg-white shadow-lg rounded-lg p-8 space-y-6">
                <div class="text-center">
                    <h1 class="text-4xl font-bold text-gray-900 mb-2">
                        {{ title }}
                    </h1>
                    <p class="text-lg text-gray-600">
                        {{ message }}
                    </p>
                </div>

                <div class="border-t border-gray-200 pt-6">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="bg-blue-50 p-4 rounded-lg">
                            <h3 class="font-semibold text-blue-900 mb-2">⚡ FastAPI</h3>
                            <p class="text-sm text-blue-700">Modern, fast web framework</p>
                        </div>
                        <div class="bg-green-50 p-4 rounded-lg">
                            <h3 class="font-semibold text-green-900 mb-2">🎨 Jinja2</h3>
                            <p class="text-sm text-green-700">Powerful templating engine</p>
                        </div>
                        <div class="bg-purple-50 p-4 rounded-lg">
                            <h3 class="font-semibold text-purple-900 mb-2">🎯 Tailwind</h3>
                            <p class="text-sm text-purple-700">Utility-first CSS framework</p>
                        </div>
                    </div>
                </div>

                <div class="text-center pt-4">
                    <a href="/docs" 
                       class="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                        View API Docs
                    </a>
                </div>

                <div class="bg-gray-50 rounded-lg p-4 text-sm text-gray-600">
                    <p class="font-semibold mb-2">Quick start:</p>
                    <code class="block bg-gray-900 text-gray-100 p-3 rounded">
                        make dev-reload
                    </code>
                </div>
            </div>
        </div>
    </div>
</div>
{% endblock %}
INDEX

# -----------------------------
# Custom CSS (optional)
# -----------------------------
info "Creating static/css/styles.css..."
cat > static/css/styles.css <<'CSS'
/* Custom styles to extend Tailwind */

/* Smooth scrolling */
html {
    scroll-behavior: smooth;
}

/* Custom animations */
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

.animate-fade-in {
    animation: fadeIn 0.5s ease-in;
}
CSS

# -----------------------------
# .gitignore
# -----------------------------
if [[ ! -f .gitignore ]]; then
  info "Creating .gitignore..."
  cat > .gitignore <<'GITIGNORE'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Virtual environments
venv/
ENV/
env/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~

# Testing
.pytest_cache/
.coverage
htmlcov/
.mypy_cache/
.ruff_cache/

# Environment
.env
.env.local
GITIGNORE
fi

# -----------------------------
# README
# -----------------------------
if [[ ! -f README.md ]]; then
  info "Creating README.md..."
  cat > README.md <<'README'
# FastAPI + Jinja2 + Tailwind CSS

A modern FastAPI application with server-side Jinja2 templates and Tailwind CSS.

## Quick Start

```bash
# Install dependencies
make install

# Run development server with auto-reload
make dev-reload

# Run production server
make prod
```

Visit http://localhost:8000

## Development

```bash
# Run tests
make test

# Lint code
make lint

# Format code
make format

# Type check
make check-types

# Run all checks
make check
```

## Project Structure

```
.
├── main.py              # FastAPI application
├── templates/           # Jinja2 templates
│   ├── base.html       # Base template
│   └── index.html      # Home page
├── static/             # Static assets
│   ├── css/
│   └── js/
└── pyproject.toml      # Python dependencies
```

## API Documentation

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
README
fi

# -----------------------------
# Copy Makefile if it exists
# -----------------------------
if [[ -f ../fastapi-powertools.mk && $IN_PLACE -eq 0 ]]; then
  info "Copying Makefile..."
  cp ../fastapi-powertools.mk Makefile
elif [[ -f fastapi-powertools.mk ]]; then
  info "Copying Makefile..."
  cp fastapi-powertools.mk Makefile
fi

popd >/dev/null

cat <<MSG

====================================================
✅ FastAPI + Jinja2 + Tailwind setup complete!

To get started:

  cd $APP_DIR
  make install          # Install dependencies
  make dev-reload       # Start dev server with auto-reload

Then visit:
  http://localhost:8000      - Your app
  http://localhost:8000/docs - API documentation

Tips:
  - Edit templates/ to customize pages
  - Add routes in main.py
  - Extend Tailwind with static/css/styles.css
  - Use 'make help' to see all available commands
====================================================
MSG
