"""Insert Hugo's book <head> fragment, and per-page share-card tags, into every
page of the built book.

Usage:
  python3 -I scripts/inject-book-head.py <fragment.html> <book-dir> [--base-url URL]
  python3 -I scripts/inject-book-head.py --check <book-dir>

The book is built by mdBook from gfrmin/agent-court in publish.yml's `book` job.
The insert runs in the `build` job, on static files only, so no code from that
repository runs where the Pages deploy rights are. Inserting into the built pages,
rather than handing mdBook a theme/head.hbs, also leaves any head.hbs that
agent-court adds intact.

Per page (#51), the script also writes og:title, og:description, og:url and a
canonical link, taken from the page's own <title> and <meta name="description">
and its path under the base URL. mdBook has a book-wide description only, so the
description is the same on every page; the title is the chapter's. The tags that
are the same on every page (og:image, og:type, twitter:card) are in the fragment,
layouts/index.bookhead.html.

--check runs in the `book` job, with the same tests the insert makes, so a book
that cannot take the fragment, or a page with no title or description to build a
card from, fails there. The `build` job then falls back to the last good book
instead of failing the blog deploy.

toc.html is skipped: mdBook loads it only inside <noscript>, where neither script
in the fragment could run. 404.html also gets a robots noindex, because the root
404 sends a missing /book/ page there and GitHub Pages serves it with status 200,
and it gets no canonical or og:url for the same reason. print.html is the whole
book on one page; it takes the fragment and the tags like any other.
"""
import html
import pathlib
import re
import sys

NOINDEX = '<meta name="robots" content="noindex">'
BASE_URL = "https://gfrm.in/book/"
TITLE_RE = re.compile(r"<title>(.*?)</title>", re.S)
DESC_RE = re.compile(r'<meta\s+name="description"\s+content="([^"]*)"', re.S)


def pages(book_dir: str) -> list[pathlib.Path]:
    found = [p for p in sorted(pathlib.Path(book_dir).rglob("*.html")) if p.name != "toc.html"]
    if not found:
        sys.exit(f"inject-book-head: no pages under {book_dir}")
    return found


def problem(page: pathlib.Path) -> str | None:
    text = page.read_text(encoding="utf-8")
    n = text.count("</head>")
    if n != 1:
        return f"{page} has {n} </head> tags, expected 1"
    if not TITLE_RE.search(text):
        return f"{page} has no <title> to build og:title from"
    if not DESC_RE.search(text):
        return f"{page} has no <meta name=\"description\"> to build og:description from"
    return None


def check(book_dir: str) -> None:
    found = pages(book_dir)
    problems = [p for p in map(problem, found) if p]
    if problems:
        sys.exit("inject-book-head: " + "; ".join(problems))
    print(f"inject-book-head: {len(found)} pages can take the fragment and the card tags")


def card_tags(page: pathlib.Path, text: str, rel: str, base_url: str) -> str:
    title = html.unescape(TITLE_RE.search(text).group(1)).strip()
    desc = html.unescape(DESC_RE.search(text).group(1)).strip()
    url = base_url + ("" if rel == "index.html" else rel)
    tags = [
        f'<meta property="og:title" content="{html.escape(title, quote=True)}">',
        f'<meta property="og:description" content="{html.escape(desc, quote=True)}">',
        f'<meta name="twitter:title" content="{html.escape(title, quote=True)}">',
        f'<meta name="twitter:description" content="{html.escape(desc, quote=True)}">',
    ]
    if page.name != "404.html":
        tags.append(f'<meta property="og:url" content="{url}">')
        tags.append(f'<link rel="canonical" href="{url}">')
    return "".join(tags)


def inject(page: pathlib.Path, fragment: str, book_dir: str, base_url: str) -> None:
    if (msg := problem(page)):
        sys.exit(f"inject-book-head: {msg}")
    extra = NOINDEX if page.name == "404.html" else ""
    text = page.read_text(encoding="utf-8")
    rel = page.relative_to(book_dir).as_posix()
    tags = card_tags(page, text, rel, base_url)
    page.write_text(text.replace("</head>", extra + tags + fragment + "</head>", 1), encoding="utf-8")


def main(argv: list[str]) -> None:
    if argv[:1] == ["--check"]:
        return check(*argv[1:])
    base_url = BASE_URL
    if "--base-url" in argv:
        i = argv.index("--base-url")
        base_url = argv[i + 1].rstrip("/") + "/"
        argv = argv[:i] + argv[i + 2:]
    fragment_path, book_dir = argv
    fragment = pathlib.Path(fragment_path).read_text(encoding="utf-8").strip()
    if not fragment:
        sys.exit(f"inject-book-head: {fragment_path} is empty")
    found = pages(book_dir)
    for page in found:
        inject(page, fragment, book_dir, base_url)
    print(f"inject-book-head: {len(found)} pages")


if __name__ == "__main__":
    main(sys.argv[1:])
