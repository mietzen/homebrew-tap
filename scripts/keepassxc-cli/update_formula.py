#!/usr/bin/env python3
"""Update the keepassxc-cli Homebrew formula with a new version.

Resolves all transitive Python dependencies via the PyPI JSON API,
fetches sdist URLs and sha256 hashes, and regenerates the formula
from a Jinja template.

Usage:
    python3 scripts/keepassxc-cli/update_formula.py <version>
"""

from __future__ import annotations

import hashlib
import json
import sys
import urllib.request
from dataclasses import dataclass
from pathlib import Path

from jinja2 import Environment, FileSystemLoader
from packaging.requirements import Requirement
from packaging.specifiers import SpecifierSet
from packaging.version import Version

FORMULA_PATH = Path("Formula/keepassxc-cli.rb")
TEMPLATE_DIR = Path(__file__).parent
TEMPLATE_NAME = "formula.rb.j2"
PACKAGE_NAME = "keepassxc-cli"


@dataclass
class Resource:
    name: str
    url: str
    sha256: str


def pypi_json(package: str, version: str | None = None) -> dict:
    """Fetch package metadata from the PyPI JSON API."""
    if version:
        api_url = f"https://pypi.org/pypi/{package}/{version}/json"
    else:
        api_url = f"https://pypi.org/pypi/{package}/json"
    with urllib.request.urlopen(api_url) as resp:
        return json.load(resp)


def get_sdist(package: str, version: str) -> Resource:
    """Get sdist URL and sha256 for a specific package version."""
    data = pypi_json(package, version)
    for file_info in data["urls"]:
        if file_info["packagetype"] == "sdist":
            sdist_url = file_info["url"]
            with urllib.request.urlopen(sdist_url) as resp:
                content = resp.read()
            sha256 = hashlib.sha256(content).hexdigest()
            return Resource(
                name=package.lower(),
                url=sdist_url,
                sha256=sha256,
            )
    raise RuntimeError(f"No sdist found for {package}=={version}")


def latest_version(package: str, specifier: SpecifierSet) -> str:
    """Find the latest version of a package matching a specifier set."""
    data = pypi_json(package)
    versions = [
        Version(v)
        for v in data["releases"]
        if not Version(v).is_prerelease and specifier.contains(Version(v))
    ]
    if not versions:
        raise RuntimeError(
            f"No version of {package} matches {specifier}"
        )
    return str(max(versions))


def resolve_dependencies(
    package: str,
    version: str,
    resolved: dict[str, str] | None = None,
) -> dict[str, str]:
    """Recursively resolve transitive dependencies via the PyPI JSON API.

    Returns a dict mapping normalized package names to pinned versions.
    Skips dependencies with extras markers or non-install conditions.
    """
    if resolved is None:
        resolved = {}

    data = pypi_json(package, version)
    requires_dist = data["info"].get("requires_dist") or []

    for req_str in requires_dist:
        req = Requirement(req_str)

        # Skip optional/extra dependencies (e.g. dev, test)
        if req.marker and not req.marker.evaluate({"extra": ""}):
            continue

        normalized = req.name.lower().replace("-", "_")

        # Skip already resolved (handles circular deps)
        if normalized in resolved:
            continue

        dep_version = latest_version(req.name, req.specifier)
        resolved[normalized] = dep_version
        print(f"  Resolved {req.name} {req.specifier} -> {dep_version}")

        # Recurse into transitive dependencies
        resolve_dependencies(req.name, dep_version, resolved)

    return resolved


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]

    # Resolve dependency tree via PyPI API
    print(f"Resolving dependencies for {PACKAGE_NAME}=={version}...")
    deps = resolve_dependencies(PACKAGE_NAME, version)
    print(f"Resolved {len(deps)} dependencies: {deps}")

    # Fetch sdist info for main package and all dependencies
    print(f"\nFetching sdist for {PACKAGE_NAME}=={version}...")
    main_sdist = get_sdist(PACKAGE_NAME, version)

    resources = []
    for dep_name, dep_version in sorted(deps.items()):
        print(f"Fetching sdist for {dep_name}=={dep_version}...")
        resources.append(get_sdist(dep_name, dep_version))

    # Render formula from Jinja template
    env = Environment(
        loader=FileSystemLoader(TEMPLATE_DIR),
        keep_trailing_newline=True,
    )
    template = env.get_template(TEMPLATE_NAME)
    formula = template.render(
        url=main_sdist.url,
        sha256=main_sdist.sha256,
        resources=resources,
    )

    FORMULA_PATH.write_text(formula)
    print(f"\nFormula updated to version {version}")


if __name__ == "__main__":
    main()
