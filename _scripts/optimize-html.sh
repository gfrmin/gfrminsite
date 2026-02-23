#!/usr/bin/env bash
# Post-render HTML optimizer for Quarto sites.
# Adds 'defer' to render-blocking scripts that aren't needed for initial paint,
# removes dev-only scripts, and applies additional performance optimizations.
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
  'bootstrap\.min\.js'
)

# Scripts to remove entirely (dev-only, not needed in production)
REMOVE_PATTERNS=(
  'axe-check\.js'
)

# Build sed expressions for HTML files
SED_ARGS=()

for pattern in "${DEFER_PATTERNS[@]}"; do
  # Match <script src="...pattern..."> without defer/async/type="module", add defer
  SED_ARGS+=(-e "s|<script src=\"\([^\"]*${pattern}[^\"]*\)\">|<script defer src=\"\1\">|g")
done

for pattern in "${REMOVE_PATTERNS[@]}"; do
  # Remove entire script tag
  SED_ARGS+=(-e "/<script[^>]*${pattern}[^>]*><\/script>/d")
done

# Make dark theme CSS non-render-blocking: change to media="print" with onload swap
# Matches links with class containing both quarto-color-scheme and quarto-color-alternate
SED_ARGS+=(-e 's|<link href="\([^"]*\)" rel="stylesheet"[^>]*class="quarto-color-scheme quarto-color-alternate"[^>]*>|<link href="\1" rel="stylesheet" class="quarto-color-scheme quarto-color-alternate" media="print" onload="this.media='"'"'all'"'"'">|g')

count=0
while IFS= read -r -d '' file; do
  sed -i "${SED_ARGS[@]}" "$file"
  count=$((count + 1))
done < <(find "$OUTPUT_DIR" -name '*.html' -print0)

echo "Optimized $count HTML files in $OUTPUT_DIR"

# --- CSS file optimizations ---

# Strip unused Google Fonts @import from Bootstrap theme CSS
# Flatly/Darkly themes import Lato, but we override all fonts in styles.css
css_count=0
while IFS= read -r -d '' cssfile; do
  sed -i 's/@import"https:\/\/fonts\.googleapis\.com[^"]*";//g' "$cssfile"
  css_count=$((css_count + 1))
done < <(find "$OUTPUT_DIR" -name '*.min.css' -path '*/bootstrap/*' -print0)
echo "Stripped Google Fonts @import from $css_count Bootstrap CSS files"

# Change bootstrap-icons font-display: block → swap
# Prevents 176KB icon font from blocking text rendering
ICONS_CSS="$OUTPUT_DIR/site_libs/bootstrap/bootstrap-icons.css"
if [ -f "$ICONS_CSS" ]; then
  sed -i 's/font-display: block;/font-display: swap;/' "$ICONS_CSS"
  echo "Set font-display: swap in bootstrap-icons.css"
fi
