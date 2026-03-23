#!/usr/bin/env python3
"""
WCAG 2.1 AA Color Contrast Audit for gfrm.in
Uses Playwright to extract computed colors from all visible text elements
on a mobile viewport in both light and dark mode.
"""

import json
import os
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

from playwright.sync_api import sync_playwright

# ---------------------------------------------------------------------------
# Color math (pure functions)
# ---------------------------------------------------------------------------

def parse_color(css: str) -> tuple[float, float, float, float]:
    """Parse a CSS computed color string to (r, g, b, a) with 0-255 range for rgb, 0-1 for a."""
    if not css or css == "transparent":
        return (0, 0, 0, 0.0)
    m = re.match(r"rgba?\(\s*([\d.]+),\s*([\d.]+),\s*([\d.]+)(?:,\s*([\d.]+))?\s*\)", css)
    if m:
        r, g, b = float(m.group(1)), float(m.group(2)), float(m.group(3))
        a = float(m.group(4)) if m.group(4) is not None else 1.0
        return (r, g, b, a)
    # hex fallback
    m = re.match(r"#([0-9a-fA-F]{6})", css)
    if m:
        h = m.group(1)
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 1.0)
    return (0, 0, 0, 1.0)


def composite(fg_rgba: tuple, bg_rgb: tuple) -> tuple[float, float, float]:
    """Alpha-composite fg over opaque bg. Returns (r, g, b) in 0-255."""
    fr, fg, fb, fa = fg_rgba
    br, bg_, bb = bg_rgb
    return (
        fr * fa + br * (1 - fa),
        fg * fa + bg_ * (1 - fa),
        fb * fa + bb * (1 - fa),
    )


def _linearize(c: float) -> float:
    """sRGB channel (0-1) to linear."""
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def relative_luminance(r: float, g: float, b: float) -> float:
    """WCAG 2.1 relative luminance from sRGB 0-255 values."""
    rl, gl, bl = _linearize(r / 255), _linearize(g / 255), _linearize(b / 255)
    return 0.2126 * rl + 0.7152 * gl + 0.0722 * bl


def contrast_ratio(c1: tuple, c2: tuple) -> float:
    """Contrast ratio between two (r, g, b) colors."""
    l1 = relative_luminance(*c1)
    l2 = relative_luminance(*c2)
    lighter, darker = max(l1, l2), min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def is_large_text(font_size_px: float, font_weight: int) -> bool:
    """WCAG large text: >=18pt (24px) or >=14pt (18.66px) and bold (>=700)."""
    return font_size_px >= 24 or (font_size_px >= 18.66 and font_weight >= 700)


def wcag_aa_threshold(large: bool) -> float:
    return 3.0 if large else 4.5


# ---------------------------------------------------------------------------
# JavaScript DOM extractor
# ---------------------------------------------------------------------------

EXTRACT_JS = """
() => {
    const results = [];
    const seen = new Set();

    function getEffectiveBg(el) {
        let node = el;
        const layers = [];
        while (node && node !== document.documentElement) {
            const style = getComputedStyle(node);
            const bg = style.backgroundColor;
            if (bg && bg !== 'transparent' && bg !== 'rgba(0, 0, 0, 0)') {
                const m = bg.match(/rgba?\\(\\s*([\\d.]+),\\s*([\\d.]+),\\s*([\\d.]+)(?:,\\s*([\\d.]+))?\\s*\\)/);
                if (m) {
                    const a = m[4] !== undefined ? parseFloat(m[4]) : 1.0;
                    layers.push({ r: parseFloat(m[1]), g: parseFloat(m[2]), b: parseFloat(m[3]), a });
                    if (a >= 1.0) break;
                }
            }
            node = node.parentElement;
        }
        // Fallback: page root bg from <body> or <html>
        if (layers.length === 0 || layers[layers.length - 1].a < 1.0) {
            const bodyBg = getComputedStyle(document.body).backgroundColor;
            const m = bodyBg.match(/rgba?\\(\\s*([\\d.]+),\\s*([\\d.]+),\\s*([\\d.]+)/);
            if (m) {
                layers.push({ r: parseFloat(m[1]), g: parseFloat(m[2]), b: parseFloat(m[3]), a: 1.0 });
            } else {
                layers.push({ r: 253, g: 251, b: 247, a: 1.0 }); // --bg-page light fallback
            }
        }
        // Composite bottom-up
        let base = layers[layers.length - 1];
        let cur = { r: base.r, g: base.g, b: base.b };
        for (let i = layers.length - 2; i >= 0; i--) {
            const fg = layers[i];
            cur = {
                r: fg.r * fg.a + cur.r * (1 - fg.a),
                g: fg.g * fg.a + cur.g * (1 - fg.a),
                b: fg.b * fg.a + cur.b * (1 - fg.a),
            };
        }
        return `rgb(${Math.round(cur.r)}, ${Math.round(cur.g)}, ${Math.round(cur.b)})`;
    }

    function buildSelector(el) {
        const parts = [];
        let node = el;
        for (let depth = 0; depth < 4 && node && node !== document.body; depth++) {
            let s = node.tagName.toLowerCase();
            if (node.id) { s += '#' + node.id; parts.unshift(s); break; }
            if (node.className && typeof node.className === 'string') {
                const cls = node.className.trim().split(/\\s+/).slice(0, 3).join('.');
                if (cls) s += '.' + cls;
            }
            parts.unshift(s);
            node = node.parentElement;
        }
        return parts.join(' > ');
    }

    // Walk all elements with text
    const walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null);
    while (walker.nextNode()) {
        const textNode = walker.currentNode;
        const text = textNode.textContent.trim();
        if (!text || text.length < 2) continue;

        const el = textNode.parentElement;
        if (!el) continue;

        // Dedup by element
        if (seen.has(el)) continue;
        seen.add(el);

        const style = getComputedStyle(el);
        if (style.display === 'none' || style.visibility === 'hidden' || parseFloat(style.opacity) === 0) continue;

        const rect = el.getBoundingClientRect();
        if (rect.width === 0 || rect.height === 0) continue;

        const fgColor = style.color;
        const bgColor = getEffectiveBg(el);
        const fontSize = parseFloat(style.fontSize);
        const fontWeight = parseInt(style.fontWeight) || 400;
        const hasBgImage = style.backgroundImage !== 'none' &&
                          !style.backgroundImage.startsWith('radial-gradient(rgba(255');

        // Check ancestors for bg images too
        let ancestorBgImage = false;
        let p = el.parentElement;
        for (let i = 0; i < 5 && p; i++) {
            const ps = getComputedStyle(p);
            if (ps.backgroundImage !== 'none' && !ps.backgroundImage.startsWith('radial-gradient(rgba(255')) {
                // Check if this ancestor has position and covers the element
                const pRect = p.getBoundingClientRect();
                if (pRect.width > 0 && pRect.height > 0) {
                    ancestorBgImage = true;
                    break;
                }
            }
            p = p.parentElement;
        }

        results.push({
            selector: buildSelector(el),
            text: text.substring(0, 80),
            tag: el.tagName.toLowerCase(),
            fg_color: fgColor,
            bg_color: bgColor,
            font_size_px: fontSize,
            font_weight: fontWeight,
            has_bg_image: hasBgImage || ancestorBgImage,
        });
    }
    return results;
}
"""

# ---------------------------------------------------------------------------
# Audit orchestration
# ---------------------------------------------------------------------------

BASE_URL = os.environ.get("AUDIT_BASE_URL", "https://gfrm.in")

PAGES = [
    (f"{BASE_URL}/", "home"),
    (f"{BASE_URL}/posts/", "posts-listing"),
    (f"{BASE_URL}/posts/velotix-investigation/", "post-velotix"),
    (f"{BASE_URL}/posts/bayesian-agent/", "post-bayesian"),
    (f"{BASE_URL}/posts/hanukkah-of-code/", "post-hanukkah"),
    (f"{BASE_URL}/contact/", "contact"),
]

VIEWPORT = {"width": 390, "height": 844}


def audit_page(page, url: str, mode: str) -> list[dict]:
    """Audit a single page in a given color mode. Returns list of findings."""
    page.goto(url, wait_until="networkidle", timeout=30000)
    page.wait_for_timeout(500)

    if mode == "dark":
        # Quarto's JS toggle doesn't work reliably in headless mode.
        # Directly swap stylesheets and set dark mode classes/attributes.
        page.evaluate("""() => {
            // Enable alternate (dark) stylesheets
            document.querySelectorAll('link.quarto-color-alternate').forEach(l => {
                l.rel = 'stylesheet';
                l.disabled = false;
            });
            // Disable primary (light) stylesheets
            document.querySelectorAll('link.quarto-color-scheme:not(.quarto-color-alternate):not(.quarto-color-scheme-extra)').forEach(l => {
                l.rel = 'disabled-stylesheet';
                l.disabled = true;
            });
            // Set Bootstrap dark theme attribute
            document.documentElement.dataset.bsTheme = 'dark';
            // Swap body classes
            document.body.classList.remove('quarto-light');
            document.body.classList.add('quarto-dark');
        }""")
        page.wait_for_timeout(800)

    elements = page.evaluate(EXTRACT_JS)
    findings = []

    for el in elements:
        fg = parse_color(el["fg_color"])
        bg = parse_color(el["bg_color"])

        # Composite fg alpha over bg (fg from computed style can have alpha)
        fg_rgb = composite(fg, (bg[0], bg[1], bg[2])) if fg[3] < 1.0 else (fg[0], fg[1], fg[2])
        bg_rgb = (bg[0], bg[1], bg[2])

        ratio = contrast_ratio(fg_rgb, bg_rgb)
        large = is_large_text(el["font_size_px"], el["font_weight"])
        threshold = wcag_aa_threshold(large)
        passes = ratio >= threshold

        findings.append({
            "selector": el["selector"],
            "text": el["text"],
            "tag": el["tag"],
            "fg_color": el["fg_color"],
            "bg_color": el["bg_color"],
            "font_size_px": el["font_size_px"],
            "font_weight": el["font_weight"],
            "is_large_text": large,
            "has_bg_image": el["has_bg_image"],
            "contrast_ratio": round(ratio, 2),
            "required_ratio": threshold,
            "passes_aa": passes,
        })

    return findings


def run_audit():
    out_dir = Path("audit_screenshots")
    out_dir.mkdir(exist_ok=True)

    all_results = []

    with sync_playwright() as p:
        browser = p.chromium.launch()

        context = browser.new_context(
            viewport=VIEWPORT,
            device_scale_factor=3,
            user_agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1",
        )
        page = context.new_page()

        for mode in ("light", "dark"):
            for url, slug in PAGES:
                print(f"\n--- Auditing {url} ({mode}) ---")
                try:
                    findings = audit_page(page, url, mode)
                except Exception as e:
                    print(f"  ERROR: {e}")
                    continue

                # Screenshot
                ss_path = out_dir / f"{slug}-{mode}.png"
                page.screenshot(path=str(ss_path), full_page=True)

                failures = [f for f in findings if not f["passes_aa"] and not f["has_bg_image"]]
                manual = [f for f in findings if f["has_bg_image"]]
                passing = [f for f in findings if f["passes_aa"] and not f["has_bg_image"]]

                print(f"  {len(findings)} elements | {len(passing)} pass | {len(failures)} FAIL | {len(manual)} need manual review")

                for f in sorted(failures, key=lambda x: x["contrast_ratio"]):
                    print(f"  FAIL {f['contrast_ratio']:4.1f}:1 (need {f['required_ratio']}:1)  "
                          f"fg={f['fg_color']}  bg={f['bg_color']}  "
                          f"\"{f['text'][:50]}\"")

                all_results.append({
                    "url": url,
                    "slug": slug,
                    "mode": mode,
                    "screenshot": str(ss_path),
                    "total_elements": len(findings),
                    "passing": len(passing),
                    "failing": len(failures),
                    "manual_review": len(manual),
                    "failures": failures,
                    "manual_review_items": manual,
                })

        context.close()

        browser.close()

    # Summary
    total_failures = sum(r["failing"] for r in all_results)
    total_elements = sum(r["total_elements"] for r in all_results)

    # Deduplicate failures by color pair to find patterns
    color_pairs = {}
    for r in all_results:
        for f in r["failures"]:
            key = (f["fg_color"], f["bg_color"])
            if key not in color_pairs:
                color_pairs[key] = {"count": 0, "ratio": f["contrast_ratio"], "examples": []}
            color_pairs[key]["count"] += 1
            if len(color_pairs[key]["examples"]) < 3:
                color_pairs[key]["examples"].append(f"{r['mode']}:{r['slug']} \"{f['text'][:40]}\"")

    print(f"\n{'='*60}")
    print(f"SUMMARY: {total_failures} failures across {total_elements} elements on {len(all_results)} page/mode combos")
    print(f"{'='*60}")

    if color_pairs:
        print("\nMost common failing color pairs:")
        for (fg, bg), info in sorted(color_pairs.items(), key=lambda x: -x[1]["count"]):
            print(f"  {info['count']:3d}x  fg={fg}  bg={bg}  ratio={info['ratio']}:1")
            for ex in info["examples"]:
                print(f"        {ex}")

    # Save JSON
    report = {
        "audit_date": datetime.now(timezone.utc).isoformat(),
        "viewport": VIEWPORT,
        "total_failures": total_failures,
        "total_elements": total_elements,
        "color_pair_summary": {
            f"{fg} on {bg}": {
                "count": info["count"],
                "contrast_ratio": info["ratio"],
                "examples": info["examples"],
            }
            for (fg, bg), info in color_pairs.items()
        },
        "pages": all_results,
    }

    with open("audit_results.json", "w") as f:
        json.dump(report, f, indent=2)

    print(f"\nResults saved to audit_results.json")
    print(f"Screenshots saved to {out_dir}/")

    return total_failures


if __name__ == "__main__":
    failures = run_audit()
    sys.exit(1 if failures > 0 else 0)
