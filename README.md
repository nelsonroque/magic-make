# 🪄 magic-make

**`magic-make`** is a **collection of reusable Makefile patterns** for common build, test, and release workflows — designed to be **language-agnostic**, **override-friendly**, and **safe by default**.

It starts with Python + `uv` packaging, but is intentionally structured to grow into **Docker**, **Node/NPM**, **TypeScript**, and other ecosystems without rewriting everything from scratch.

---

## ✨ Goals

- Minimal boilerplate  
- No hardcoded project names  
- Environment-override friendly  
- Composable targets  
- Works locally and in CI  
- Extensible across languages  

Think of this as *“Makefiles, but civilized.”*

---

## 📦 Current Support

| Ecosystem | Status |
|----------|--------|
| Python (`uv`, PyPI) | ✅ Implemented |
| Docker | 🔜 Planned |
| Node / npm | 🔜 Planned |
| TypeScript | 🔜 Planned |
| Monorepos | 🔜 Planned |

---

## 🚀 Quick Start (Python)

```bash
git clone https://github.com/your-org/magic-make
cd magic-make
make help
````

By default:

* `PKG` = repo directory name
* `CLI` = same as `PKG`

You can override **everything** at runtime.

---

## 🛠️ Configuration (Overrides)

All config is done via Make variables — no edits required.

```bash
make publish-test PKG=lab-cli CLI=clicli
```

### Common Variables

| Variable         | Purpose             | Default          |
| ---------------- | ------------------- | ---------------- |
| `PKG`            | PyPI package name   | repo folder name |
| `CLI`            | CLI entrypoint      | `$(PKG)`         |
| `ARGS`           | Arguments for CLI   | empty            |
| `PYPI_REPO_TEST` | Test PyPI repo name | `testpypi`       |

---

## 📋 Available Targets (Python)

### Development

```bash
make install      # Editable install via uv
make clean        # Remove build artifacts
make build        # Build sdist + wheel
make check        # Twine check dist/*
```

---

### 📦 Publishing

#### Publish to TestPyPI

```bash
make publish-test PKG=my-package
```

Runs:

1. Clean
2. Build
3. Twine check
4. Upload to TestPyPI
5. Install from TestPyPI

#### Publish to PyPI

```bash
make publish PKG=my-package
```

---

### 🔢 Version Bumping

```bash
make bump         # patch (default)
make bump-patch
make bump-minor
make bump-major
```

Uses:

```
scripts/bump_version.py
```

---

### ▶️ Running the CLI

```bash
make run CLI=mycli ARGS="--help"
```

Equivalent to:

```bash
uv run mycli --help
```

---

### 🌳 Repo Tree Snapshot

```bash
make tree
```

Outputs:

```
pretty_tree.txt
```

Useful for documentation, debugging, or LLM context.

---

## 🧠 Design Philosophy

### 1. Make Is the Interface

Make is ubiquitous, composable, and CI-friendly.
This repo treats Make as the **orchestration layer**, not the logic layer.

### 2. Logic Lives Elsewhere

* Python scripts handle Python logic
* Dockerfiles handle Docker logic
* Make wires them together

### 3. No Opinionated Naming

Everything is runtime-configurable:

```bash
make PKG=foo CLI=bar publish
```

---

## 🔮 Roadmap

Planned additions:

### 🐳 Docker

```makefile
docker-build
docker-push
docker-run
```

### 📦 Node / npm

```makefile
npm-install
npm-build
npm-publish
```

### 🧪 TypeScript

```makefile
ts-build
ts-typecheck
ts-test
```

### 🧩 Modular Includes

```makefile
include make/common.mk
include make/python.mk
include make/docker.mk
include make/node.mk
```

---

## 🤝 Who This Is For

* Researchers shipping tools
* Labs standardizing workflows
* Indie devs tired of rewriting Makefiles
* Anyone juggling **multiple languages in one repo**

---

## 🧪 Example Usage

```bash
make publish-test PKG=lab-cli CLI=clicli
make run CLI=clicli ARGS="get-links C0123456789"
```

---

## 📜 License

GNU AGPLv3