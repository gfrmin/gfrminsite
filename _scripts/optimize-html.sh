#!/usr/bin/env bash
# Post-render HTML optimizer for Quarto sites.
# Defers render-blocking scripts/CSS, replaces Bootstrap Icons with inline SVGs,
# optimizes the LCP image, and optionally runs PurgeCSS on Bootstrap.
#
# Usage: bash _scripts/optimize-html.sh [output-dir]
#   output-dir defaults to 'public'

set -euo pipefail

OUTPUT_DIR="${1:-public}"

if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: output directory '$OUTPUT_DIR' not found" >&2
  exit 1
fi

# ============================================================
# Phase 1: sed-based HTML optimizations (single pass per file)
# ============================================================

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
  'quarto-nav\.js'
  'headroom\.min\.js'
  'list\.min\.js'
  'quarto-listing\.js'
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

# Defer ALL dark/alternate theme CSS (both Bootstrap and syntax highlighting)
SED_ARGS+=(-e 's|<link href="\([^"]*\)" rel="stylesheet"[^>]*class="quarto-color-scheme quarto-color-alternate"[^>]*>|<link href="\1" rel="stylesheet" class="quarto-color-scheme quarto-color-alternate" media="print" onload="this.media='"'"'all'"'"'">|g')

# Remove duplicate "-extra" stylesheet copies (Quarto adds these for theme switching; not needed for initial render)
SED_ARGS+=(-e '/<link[^>]*class="quarto-color-scheme-extra"[^>]*>/d')

# Note: primary Bootstrap CSS loads synchronously (90KB after PurgeCSS is acceptable).
# Deferring it causes a double-render that hurts LCP.

# Defer tippy.css (tooltip styles not needed for initial paint)
SED_ARGS+=(-e 's|<link href="\([^"]*tippy\.css\)" rel="stylesheet">|<link href="\1" rel="stylesheet" media="print" onload="this.media='"'"'all'"'"'">|g')

# Remove bootstrap-icons.css link (replaced by inline SVGs below)
SED_ARGS+=(-e '/<link[^>]*bootstrap-icons\.css[^>]*>/d')

# Inject minimal CSS for bi-caret-down-fill (used by Quarto code-fold buttons,
# normally provided by bootstrap-icons.css which we removed)
BI_FALLBACK_CSS='<style>.bi-caret-down-fill::before{content:"";display:inline-block;width:.5em;height:.5em;border-left:.3em solid transparent;border-right:.3em solid transparent;border-top:.4em solid currentColor;vertical-align:.1em}</style>'
SED_ARGS+=(-e "s|</head>|${BI_FALLBACK_CSS}</head>|")

# Swap profile image to WebP, add fetchpriority and dimensions for LCP
SED_ARGS+=(-e 's|<img src="profile\.jpg"|<img src="profile.webp" fetchpriority="high" width="270" height="270"|g')

# Add dimensions to listing thumbnail placeholders (prevents CLS, fixes Lighthouse audit)
SED_ARGS+=(-e 's|<img loading="lazy" src="" class="thumbnail-image">|<img loading="lazy" src="" class="thumbnail-image" width="200" height="130">|g')

count=0
while IFS= read -r -d '' file; do
  sed -i "${SED_ARGS[@]}" "$file"
  count=$((count + 1))
done < <(find "$OUTPUT_DIR" -name '*.html' -print0)

echo "Optimized $count HTML files in $OUTPUT_DIR"

# ============================================================
# Phase 2: Replace Bootstrap Icons with inline SVGs
# ============================================================
# Uses perl for reliable multi-line matching (icon tags span 2 lines in
# Quarto's navbar/footer output). Preserves role="img" and aria-label attrs.

ICON_SCRIPT=$(mktemp)
cat > "$ICON_SCRIPT" << 'PERL_EOF'
#!/usr/bin/perl
use strict;
use warnings;

my %icons = (
  'twitter' => '<path d="M5.026 15c6.038 0 9.341-5.003 9.341-9.334q.002-.211-.006-.422A6.7 6.7 0 0 0 16 3.542a6.7 6.7 0 0 1-1.889.518 3.3 3.3 0 0 0 1.447-1.817 6.5 6.5 0 0 1-2.087.793A3.286 3.286 0 0 0 7.875 6.03a9.32 9.32 0 0 1-6.767-3.429 3.29 3.29 0 0 0 1.018 4.382A3.3 3.3 0 0 1 .64 6.575v.045a3.29 3.29 0 0 0 2.632 3.218 3.2 3.2 0 0 1-.865.115 3 3 0 0 1-.614-.057 3.28 3.28 0 0 0 3.067 2.277A6.6 6.6 0 0 1 .78 13.58a6 6 0 0 1-.78-.045A9.34 9.34 0 0 0 5.026 15"/>',
  'mastodon' => '<path d="M11.19 12.195c2.016-.24 3.77-1.475 3.99-2.603.348-1.778.32-4.339.32-4.339 0-3.47-2.286-4.488-2.286-4.488C12.062.238 10.083.017 8.027 0h-.05C5.92.017 3.942.238 2.79.765c0 0-2.285 1.017-2.285 4.488l-.002.662c-.004.64-.007 1.35.011 2.091.083 3.394.626 6.74 3.78 7.57 1.454.383 2.703.463 3.709.408 1.823-.1 2.847-.647 2.847-.647l-.06-1.317s-1.303.41-2.767.36c-1.45-.05-2.98-.156-3.215-1.928a4 4 0 0 1-.033-.496s1.424.346 3.228.428c1.103.05 2.137-.064 3.188-.189zm1.613-2.47H11.13v-4.08c0-.859-.364-1.295-1.091-1.295-.804 0-1.207.517-1.207 1.541v2.233H7.168V5.89c0-1.024-.403-1.541-1.207-1.541-.727 0-1.091.436-1.091 1.296v4.079H3.197V5.522q0-1.288.66-2.046c.456-.505 1.052-.764 1.793-.764.856 0 1.504.328 1.933.983L8 4.39l.417-.695c.429-.655 1.077-.983 1.934-.983.74 0 1.336.259 1.791.764q.662.757.661 2.046z"/>',
  'github' => '<path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8"/>',
  'linkedin' => '<path d="M0 1.146C0 .513.526 0 1.175 0h13.65C15.474 0 16 .513 16 1.146v13.708c0 .633-.526 1.146-1.175 1.146H1.175C.526 16 0 15.487 0 14.854zm4.943 12.248V6.169H2.542v7.225zm-1.2-8.212c.837 0 1.358-.554 1.358-1.248-.015-.709-.52-1.248-1.342-1.248S2.4 3.226 2.4 3.934c0 .694.521 1.248 1.327 1.248zm4.908 8.212V9.359c0-.216.016-.432.08-.586.173-.431.568-.878 1.232-.878.869 0 1.216.662 1.216 1.634v3.865h2.401V9.25c0-2.22-1.184-3.252-2.764-3.252-1.274 0-1.845.7-2.165 1.193v.025h-.016l.016-.025V6.169h-2.4c.03.678 0 7.225 0 7.225z"/>',
  'rss' => '<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2z"/><path d="M5.5 12a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0m-3-8.5a1 1 0 0 1 1-1c5.523 0 10 4.477 10 10a1 1 0 1 1-2 0 8 8 0 0 0-8-8 1 1 0 0 1-1-1m0 4a1 1 0 0 1 1-1 6 6 0 0 1 6 6 1 1 0 1 1-2 0 4 4 0 0 0-4-4 1 1 0 0 1-1-1"/>',
  'database' => '<path d="M4.318 2.687C5.234 2.271 6.536 2 8 2s2.766.27 3.682.687C12.644 3.125 13 3.627 13 4c0 .374-.356.875-1.318 1.313C10.766 5.729 9.464 6 8 6s-2.766-.27-3.682-.687C3.356 4.875 3 4.373 3 4c0-.374.356-.875 1.318-1.313M13 5.698V7c0 .374-.356.875-1.318 1.313C10.766 8.729 9.464 9 8 9s-2.766-.27-3.682-.687C3.356 7.875 3 7.373 3 7V5.698c.271.202.58.378.904.525C4.978 6.711 6.427 7 8 7s3.022-.289 4.096-.777A5 5 0 0 0 13 5.698M14 4c0-1.007-.875-1.755-1.904-2.223C11.022 1.289 9.573 1 8 1s-3.022.289-4.096.777C2.875 2.245 2 2.993 2 4v9c0 1.007.875 1.755 1.904 2.223C4.978 15.71 6.427 16 8 16s3.022-.289 4.096-.777C13.125 14.755 14 14.007 14 13zm-1 4.698V10c0 .374-.356.875-1.318 1.313C10.766 11.729 9.464 12 8 12s-2.766-.27-3.682-.687C3.356 10.875 3 10.373 3 10V8.698c.271.202.58.378.904.525C4.978 9.71 6.427 10 8 10s3.022-.289 4.096-.777A5 5 0 0 0 13 8.698m0 3V13c0 .374-.356.875-1.318 1.313C10.766 14.729 9.464 15 8 15s-2.766-.27-3.682-.687C3.356 13.875 3 13.373 3 13v-1.302c.271.202.58.378.904.525C4.978 12.71 6.427 13 8 13s3.022-.289 4.096-.777c.324-.147.633-.323.904-.525"/>',
  'cpu' => '<path d="M5 0a.5.5 0 0 1 .5.5V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2h1V.5a.5.5 0 0 1 1 0V2A2.5 2.5 0 0 1 14 4.5h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14v1h1.5a.5.5 0 0 1 0 1H14a2.5 2.5 0 0 1-2.5 2.5v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14h-1v1.5a.5.5 0 0 1-1 0V14A2.5 2.5 0 0 1 2 11.5H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2v-1H.5a.5.5 0 0 1 0-1H2A2.5 2.5 0 0 1 4.5 2V.5A.5.5 0 0 1 5 0m-.5 3A1.5 1.5 0 0 0 3 4.5v7A1.5 1.5 0 0 0 4.5 13h7a1.5 1.5 0 0 0 1.5-1.5v-7A1.5 1.5 0 0 0 11.5 3zM5 6.5A1.5 1.5 0 0 1 6.5 5h3A1.5 1.5 0 0 1 11 6.5v3A1.5 1.5 0 0 1 9.5 11h-3A1.5 1.5 0 0 1 5 9.5zM6.5 6a.5.5 0 0 0-.5.5v3a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-.5-.5z"/>',
  'chat-dots' => '<path d="M5 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0m4 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0m3 1a1 1 0 1 0 0-2 1 1 0 0 0 0 2"/><path d="m2.165 15.803.02-.004c1.83-.363 2.948-.842 3.468-1.105A9 9 0 0 0 8 15c4.418 0 8-3.134 8-7s-3.582-7-8-7-8 3.134-8 7c0 1.76.743 3.37 1.97 4.6a10.4 10.4 0 0 1-.524 2.318l-.003.011a11 11 0 0 1-.244.637c-.079.186.074.394.273.362a22 22 0 0 0 .693-.125m.8-3.108a1 1 0 0 0-.287-.801C1.618 10.83 1 9.468 1 8c0-3.192 3.004-6 7-6s7 2.808 7 6-3.004 6-7 6a8 8 0 0 1-2.088-.272 1 1 0 0 0-.711.074c-.387.196-1.24.57-2.634.893a11 11 0 0 0 .398-2"/>',
  'people' => '<path d="M15 14s1 0 1-1-1-4-5-4-5 3-5 4 1 1 1 1zm-7.978-1L7 12.996c.001-.264.167-1.03.76-1.72C8.312 10.629 9.282 10 11 10c1.717 0 2.687.63 3.24 1.276.593.69.758 1.457.76 1.72l-.008.002-.014.002zM11 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4m3-2a3 3 0 1 1-6 0 3 3 0 0 1 6 0M6.936 9.28a6 6 0 0 0-1.23-.247A7 7 0 0 0 5 9c-4 0-5 3-5 4q0 1 1 1h4.216A2.24 2.24 0 0 1 5 13c0-1.01.377-2.042 1.09-2.904.243-.294.526-.569.846-.816M4.92 10A5.5 5.5 0 0 0 4 13H1c0-.26.164-1.03.76-1.724.545-.636 1.492-1.256 3.16-1.275ZM1.5 5.5a3 3 0 1 1 6 0 3 3 0 0 1-6 0m3-2a2 2 0 1 0 0 4 2 2 0 0 0 0-4"/>',
);

for my $file (@ARGV) {
  open(my $fh, '<', $file) or do { warn "Cannot open $file: $!"; next };
  my $content = do { local $/; <$fh> };
  close($fh);

  my $changed = 0;
  for my $name (keys %icons) {
    my $svg_inner = $icons{$name};
    # Match <i class="bi bi-NAME" ...optional attrs...>...whitespace...</i>
    # Captures extra attributes (role="img", aria-label, etc.) to preserve them
    if ($content =~ s/<i class="bi bi-\Q$name\E"([^>]*)>\s*<\/i>/<svg class="bi"$1 width="1em" height="1em" fill="currentColor" viewBox="0 0 16 16">$svg_inner<\/svg>/gs) {
      $changed = 1;
    }
  }

  if ($changed) {
    open(my $out, '>', $file) or do { warn "Cannot write $file: $!"; next };
    print $out $content;
    close($out);
  }
}
PERL_EOF

icon_count=0
html_files=()
while IFS= read -r -d '' file; do
  html_files+=("$file")
done < <(find "$OUTPUT_DIR" -name '*.html' -print0)

if [ ${#html_files[@]} -gt 0 ]; then
  perl "$ICON_SCRIPT" "${html_files[@]}"
  icon_count=${#html_files[@]}
fi
rm -f "$ICON_SCRIPT"
echo "Replaced Bootstrap Icons with inline SVGs across $icon_count HTML files"

# ============================================================
# Phase 3: LCP image optimization
# ============================================================

# Copy WebP profile image to output (JPEG kept for OG/Twitter meta tags)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$SCRIPT_DIR/profile.webp" ]; then
  cp "$SCRIPT_DIR/profile.webp" "$OUTPUT_DIR/profile.webp"
  echo "Copied profile.webp to output"
fi

# Add LCP image preload to index.html only (not every page)
if [ -f "$OUTPUT_DIR/index.html" ]; then
  sed -i 's|</head>|<link rel="preload" href="profile.webp" as="image" type="image/webp">\n</head>|' "$OUTPUT_DIR/index.html"
  echo "Added LCP image preload to index.html"
fi

# ============================================================
# Phase 4: CSS file optimizations
# ============================================================

# Strip unused Google Fonts @import from Bootstrap theme CSS
css_count=0
while IFS= read -r -d '' cssfile; do
  sed -i 's/@import"https:\/\/fonts\.googleapis\.com[^"]*";//g' "$cssfile"
  css_count=$((css_count + 1))
done < <(find "$OUTPUT_DIR" -name '*.min.css' -path '*/bootstrap/*' -print0)
echo "Stripped Google Fonts @import from $css_count Bootstrap CSS files"

# Remove bootstrap-icons CSS and font files (no longer needed)
rm -f "$OUTPUT_DIR"/site_libs/bootstrap/bootstrap-icons.css
rm -f "$OUTPUT_DIR"/site_libs/bootstrap/bootstrap-icons.woff
echo "Removed bootstrap-icons CSS and font files"

# ============================================================
# Phase 5: PurgeCSS (optional — set SKIP_PURGECSS=1 to disable)
# ============================================================

if [ "${SKIP_PURGECSS:-0}" = "1" ]; then
  echo "Skipping PurgeCSS (SKIP_PURGECSS=1)"
elif ! command -v npx &>/dev/null; then
  echo "Warning: npx not found, skipping PurgeCSS"
else
  PURGECSS_CONFIG=$(mktemp --suffix=.cjs)
  cat > "$PURGECSS_CONFIG" << 'PURGE_EOF'
module.exports = {
  safelist: {
    standard: [
      'show', 'showing', 'fade', 'collapse', 'collapsing', 'collapsed',
      'active', 'disabled', 'visually-hidden',
      'headroom', 'headroom--not-bottom', 'headroom--not-top',
      'headroom--top', 'headroom--bottom', 'headroom--pinned', 'headroom--unpinned',
    ],
    deep: [/data-bs-theme/, /data-bs-popper/],
  },
};
PURGE_EOF

  purge_count=0
  while IFS= read -r -d '' cssfile; do
    original_size=$(wc -c < "$cssfile")
    css_dir=$(dirname "$cssfile")
    css_name=$(basename "$cssfile")

    npx --yes purgecss \
      --config "$PURGECSS_CONFIG" \
      --css "$cssfile" \
      --content "$OUTPUT_DIR/**/*.html" \
      --output "$css_dir" 2>/dev/null

    new_size=$(wc -c < "$cssfile")
    saved=$(( original_size - new_size ))
    echo "PurgeCSS: $css_name ${original_size}B → ${new_size}B (−${saved}B)"
    purge_count=$((purge_count + 1))
  done < <(find "$OUTPUT_DIR" -name '*.min.css' -path '*/bootstrap/bootstrap*' -not -name '*icons*' -print0)

  rm -f "$PURGECSS_CONFIG"
  echo "PurgeCSS processed $purge_count Bootstrap CSS files"
fi

echo "Done."
