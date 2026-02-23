#!/usr/bin/env bash
# Creates Cloudflare Cache Rules for long-lived static assets.
# Fonts and hashed site_libs files are immutable and can be cached for 1 year.
#
# Requires:
#   CLOUDFLARE_API_TOKEN — API token with Zone.Cache Rules permission
#   CLOUDFLARE_ZONE_ID  — Zone ID for gfrm.in (found in Cloudflare dashboard)
#
# Usage: bash _scripts/cloudflare-cache-rules.sh

set -euo pipefail

: "${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN env var}"
: "${CLOUDFLARE_ZONE_ID:?Set CLOUDFLARE_ZONE_ID env var}"

API_BASE="https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE_ID}/rulesets"

# Fetch existing cache rulesets to avoid duplicates
echo "Checking existing rulesets..."
existing=$(curl -s -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  "${API_BASE}?phase=http_request_cache_settings")

# Create a cache ruleset with rules for static assets
echo "Creating cache rules..."
curl -s -X POST "${API_BASE}" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "$(cat <<'JSON'
{
  "name": "gfrm.in static asset caching",
  "kind": "zone",
  "phase": "http_request_cache_settings",
  "rules": [
    {
      "description": "Cache fonts for 1 year (immutable)",
      "expression": "(http.request.uri.path matches \"^/fonts/.*\\.woff2$\")",
      "action": "set_cache_settings",
      "action_parameters": {
        "cache": true,
        "browser_ttl": {
          "mode": "override_origin",
          "default": 31536000
        },
        "edge_ttl": {
          "mode": "override_origin",
          "default": 31536000
        }
      }
    },
    {
      "description": "Cache site_libs for 1 year (content-hashed filenames)",
      "expression": "(http.request.uri.path matches \"^/site_libs/.*\")",
      "action": "set_cache_settings",
      "action_parameters": {
        "cache": true,
        "browser_ttl": {
          "mode": "override_origin",
          "default": 31536000
        },
        "edge_ttl": {
          "mode": "override_origin",
          "default": 31536000
        }
      }
    },
    {
      "description": "Cache images for 1 week",
      "expression": "(http.request.uri.path matches \".*\\.(webp|jpg|png|svg|ico)$\")",
      "action": "set_cache_settings",
      "action_parameters": {
        "cache": true,
        "browser_ttl": {
          "mode": "override_origin",
          "default": 604800
        },
        "edge_ttl": {
          "mode": "override_origin",
          "default": 604800
        }
      }
    }
  ]
}
JSON
)" | python3 -m json.tool

echo "Done. Verify rules at: https://dash.cloudflare.com/${CLOUDFLARE_ZONE_ID}/caching/cache-rules"
