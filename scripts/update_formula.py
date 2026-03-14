#!/usr/bin/env python3
"""Update the keepassxc-ssh-agent Homebrew formula with a new version.

Resolves all transitive Python dependencies via pip, fetches sdist URLs
and sha256 hashes from PyPI, and regenerates the formula file.

Usage:
    python3 scripts/update_formula.py <version>
"""

from __future__ import annotations

import hashlib
import json
import subprocess
import sys
import tempfile
import textwrap
import urllib.request

FORMULA_PATH = "Formula/keepassxc-ssh-agent.rb"
PACKAGE_NAME = "keepassxc-ssh-agent"


def get_sdist_url_and_hash(package: str, version: str) -> tuple[str, str]:
    """Get sdist URL and sha256 for a specific package version from PyPI."""
    url = f"https://pypi.org/pypi/{package}/{version}/json"
    with urllib.request.urlopen(url) as resp:
        data = json.load(resp)

    for file_info in data["urls"]:
        if file_info["packagetype"] == "sdist":
            sdist_url = file_info["url"]
            with urllib.request.urlopen(sdist_url) as resp:
                content = resp.read()
            sha256 = hashlib.sha256(content).hexdigest()
            return sdist_url, sha256

    raise RuntimeError(f"No sdist found for {package}=={version}")


def resolve_dependencies(version: str) -> dict[str, str]:
    """Install the package in a temp venv and return frozen dependencies."""
    with tempfile.TemporaryDirectory() as tmpdir:
        venv_dir = f"{tmpdir}/venv"
        subprocess.check_call(
            [sys.executable, "-m", "venv", venv_dir],
            stdout=subprocess.DEVNULL,
        )
        pip = f"{venv_dir}/bin/pip"

        subprocess.check_call(
            [pip, "install", f"{PACKAGE_NAME}=={version}"],
            stdout=subprocess.DEVNULL,
        )
        result = subprocess.check_output([pip, "freeze"], text=True)

    dependencies = {}
    for line in result.strip().splitlines():
        if "==" in line:
            pkg, ver = line.split("==", 1)
            pkg_lower = pkg.lower().replace("-", "_")
            if pkg_lower != PACKAGE_NAME.replace("-", "_"):
                dependencies[pkg] = ver

    return dependencies


def generate_formula(version: str) -> str:
    """Generate the complete Homebrew formula for the given version."""
    # Resolve dependencies
    dependencies = resolve_dependencies(version)
    print(f"Resolved dependencies: {dependencies}")

    # Get main package sdist info
    main_url, main_sha = get_sdist_url_and_hash(PACKAGE_NAME, version)
    print(f"Main package: {main_url}")

    # Get dependency sdist info and build resource blocks
    resource_blocks = ""
    for pkg, ver in sorted(dependencies.items()):
        url, sha = get_sdist_url_and_hash(pkg, ver)
        name = pkg.lower()
        print(f"  {pkg}=={ver}: {url}")
        resource_blocks += f"""
  resource "{name}" do
    url "{url}"
    sha256 "{sha}"
  end
"""

    formula = textwrap.dedent(f"""\
        class KeepassxcSshAgent < Formula
          include Language::Python::Virtualenv

          desc "SSH IdentityAgent proxy that triggers KeePassXC database unlock via TouchID"
          homepage "https://github.com/mietzen/keepassxc-ssh-agent"
          url "{main_url}"
          sha256 "{main_sha}"
          license "MIT"

          depends_on "libsodium"
          depends_on :macos
          depends_on "python@3.13"
        {resource_blocks}
          def install
            ENV["SODIUM_INSTALL"] = "system"
            virtualenv_install_with_resources
          end

          def post_uninstall
            opoo "To remove configuration files, run: rm -rf ~/.keepassxc"
          end

          def caveats
            <<~EOS
              To associate with KeePassXC (browser integration must be enabled):

                keepassxc-ssh-agent install --register-only

              Then start the background service:

                brew services start keepassxc-ssh-agent
            EOS
          end

          service do
            run [opt_bin/"keepassxc-ssh-agent", "run"]
            keep_alive true
            log_path var/"log/keepassxc-ssh-agent/out.log"
            error_log_path var/"log/keepassxc-ssh-agent/err.log"
          end

          test do
            assert_match "keepassxc-ssh-agent", shell_output("#{{bin}}/keepassxc-ssh-agent --help")
            assert_match "status", shell_output("#{{bin}}/keepassxc-ssh-agent --help")
          end
        end
    """)

    return formula


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <version>", file=sys.stderr)
        sys.exit(1)

    version = sys.argv[1]
    formula = generate_formula(version)

    with open(FORMULA_PATH, "w") as f:
        f.write(formula)

    print(f"Formula updated to version {version}")


if __name__ == "__main__":
    main()
