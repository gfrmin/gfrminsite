"""Draw the site's share cards (1200x630) in its own palette and type.

Usage:
  python3 -I scripts/make-og-cards.py <fonts-dir>

<fonts-dir> holds TTF instances of the site's own woff2 subsets (static/fonts/):
literata-latin.ttf (wght 600, opsz 72), literata-latin-400.ttf and
ibm-plex-sans-latin.ttf (wght 400). They are not committed: regenerate them with
fontTools' instancer from the woff2 files when the type changes.

Writes static/images/og-default.png (the site-wide fallback) and
static/images/og-book.png (the book's card, see layouts/index.bookhead.html).
Both are parchment on ink in the Aug 2026 palette (assets/css/main.css). The old
default was navy and said "Data Science & Software Engineering", a tagline the
site stopped using in 2026.
"""
import pathlib
import sys

from PIL import Image, ImageDraw, ImageFont

W, H = 1200, 630
INK = "#271f19"        # --text-primary (light)
PARCHMENT = "#efe7d9"  # --bg-page (light)
OCHRE = "#8a5619"      # --brand-secondary
TEAL = "#007475"       # --brand-primary
MUTED = "#5c524a"


def card(fonts: pathlib.Path, title: str, sub: str, foot: str, title_size: int, out: pathlib.Path) -> None:
    im = Image.new("RGB", (W, H), PARCHMENT)
    d = ImageDraw.Draw(im)
    display = ImageFont.truetype(str(fonts / "literata-latin.ttf"), title_size)
    body = ImageFont.truetype(str(fonts / "literata-latin-400.ttf"), 34)
    ui = ImageFont.truetype(str(fonts / "ibm-plex-sans-latin.ttf"), 26)
    # The ochre rule the site draws under every h2.
    d.rectangle([96, 96, 96 + 120, 96 + 6], fill=OCHRE)
    # Title, wrapped by hand: two lines at most.
    y = 140
    for line in title.split("\n"):
        d.text((96, y), line, font=display, fill=INK)
        y += int(title_size * 1.12)
    # Subtitle, wrapped to the measure.
    words, lines, cur = sub.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if d.textlength(t, font=body) > W - 192:
            lines.append(cur)
            cur = w
        else:
            cur = t
    lines.append(cur)
    y += 34
    for line in lines[:3]:
        d.text((96, y), line, font=body, fill=MUTED)
        y += 46
    d.text((96, H - 96 - 30), foot, font=ui, fill=TEAL)
    im.save(out, optimize=True)
    print(out, im.size)


def main(argv: list[str]) -> None:
    fonts = pathlib.Path(argv[0])
    images = pathlib.Path(__file__).resolve().parent.parent / "static" / "images"
    card(fonts, "Guy Freeman",
         "AI evaluation and oversight · Bayesian decision theory",
         "gfrm.in", 92, images / "og-default.png")
    card(fonts, "A Court for Agents",
         "Law, scoring and the self-modifying machine. A monograph in first draft, every number recomputable from the court's public record.",
         "Guy Freeman · gfrm.in/book", 84, images / "og-book.png")


if __name__ == "__main__":
    main(sys.argv[1:])
