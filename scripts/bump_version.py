import sys
from pathlib import Path
import tomlkit

def bump_version(version_str, part):
    major, minor, patch = map(int, version_str.split("."))
    if part == "patch":
        patch += 1
    elif part == "minor":
        minor += 1
        patch = 0
    elif part == "major":
        major += 1
        minor = patch = 0
    else:
        raise ValueError("Must specify one of: patch, minor, major")
    return f"{major}.{minor}.{patch}"

def main():
    if len(sys.argv) != 2:
        print("Usage: python bump_version.py [patch|minor|major]")
        sys.exit(1)

    bump_type = sys.argv[1]
    pyproject_path = Path("pyproject.toml")
    doc = tomlkit.parse(pyproject_path.read_text())

    current_version = doc["project"]["version"]
    new_version = bump_version(current_version, bump_type)
    doc["project"]["version"] = new_version

    pyproject_path.write_text(tomlkit.dumps(doc))
    print(f"Bumped version: {current_version} → {new_version}")

if __name__ == "__main__":
    main()
