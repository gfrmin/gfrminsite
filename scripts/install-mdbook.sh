#!/usr/bin/env bash
# Install the pinned mdBook into the current directory as ./mdbook, for the book
# job in .github/workflows/publish.yml.
#
# The version is .mdbook-version and the sha256 of the x86_64 Linux release
# tarball is .mdbook-sha256, both at this repository's root; bump them together.
# Get the hash from GitHub's own record of the asset:
#   gh api repos/rust-lang/mdBook/releases/tags/v<ver> \
#     --jq '.assets[]|select(.name|test("x86_64-unknown-linux-gnu"))|.digest'
# The pin lives here, not in gfrmin/agent-court, so this site's build runs no
# script from another repository. The workflow warns if agent-court pins a
# different version.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version="$(tr -d '[:space:]' < "$root/.mdbook-version")"
sha256="$(tr -d '[:space:]' < "$root/.mdbook-sha256")"
tarball="mdbook-v${version}-x86_64-unknown-linux-gnu.tar.gz"

curl -fsSL --retry 3 -o "$tarball" \
  "https://github.com/rust-lang/mdBook/releases/download/v${version}/${tarball}"
echo "${sha256}  ${tarball}" | sha256sum -c -
tar xzf "$tarball"
rm "$tarball"
./mdbook --version
