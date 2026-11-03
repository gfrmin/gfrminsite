#!/usr/bin/env bash
# Print the build-id.txt GitHub Pages is serving for gfrm.in, or nothing.
#
# Usage: scripts/origin-build-id.sh <cache-buster>
#
# Reads the origin directly, past Cloudflare, whose copy may be the stale thing
# being asked about. --resolve pins gfrm.in to a GitHub Pages address
# (https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site),
# and -k is needed because Pages holds no certificate for a domain Cloudflare
# proxies; nothing secret is sent. The cache-buster must be unique per request
# (e.g. "<run id>-<attempt>"): Pages' own CDN caches for ~10 minutes per URL.
# Used by publish.yml's build job (nightly skip) and purge job (wait for deploy).
set -uo pipefail
curl -fsSk --max-time 20 -H 'Cache-Control: no-cache' \
  --resolve gfrm.in:443:185.199.108.153 "https://gfrm.in/build-id.txt?$1" 2>/dev/null || true
