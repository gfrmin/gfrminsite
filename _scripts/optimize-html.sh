#!/usr/bin/env bash
# Post-render HTML optimizer for Quarto sites.
# Adds 'defer' to render-blocking scripts that aren't needed for initial paint,
# and removes dev-only scripts.
#
# Usage: bash _scripts/optimize-html.sh [output-dir]
#   output-dir defaults to 'public'

set -euo pipefail

OUTPUT_DIR="${1:-public}"

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: output directory '$OUTPUT_DIR' not found" >&2
  exit 1
fi

# Scripts safe to defer (enhance interactivity but not needed for initial render)
DEFER_PATTERNS=(
  'clipboard\.min\.js'
  'autocomplete\.umd\.js'
  'fuse\.min\.js'
  'quarto-search\.js'
  'popper\.min\.js'
  'tippy\.umd\.min\.js'
  'anchor\.min\.js'
)

# Scripts to remove entirely (dev-only, not needed in production)
REMOVE_PATTERNS=(
  'axe-check\.js'
)

# Build sed expressions
SED_ARGS=()

for pattern in "${DEFER_PATTERNS[@]}"; do
  # Match <script src="...pattern..."> without defer/async/type="module", add defer
  SED_ARGS+=(-e "s|<script src=\"\([^\"]*${pattern}[^\"]*\)\">|<script defer src=\"\1\">|g")
done

for pattern in "${REMOVE_PATTERNS[@]}"; do
  # Remove entire script tag
  SED_ARGS+=(-e "/<script[^>]*${pattern}[^>]*><\/script>/d")
done

count=0
while IFS= read -r -d '' file; do
  sed -i "${SED_ARGS[@]}" "$file"
  count=$((count + 1))
done < <(find "$OUTPUT_DIR" -name '*.html' -print0)

echo "Optimized $count HTML files in $OUTPUT_DIR"
