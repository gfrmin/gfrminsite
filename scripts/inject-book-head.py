"""Insert Hugo's book <head> fragment into every page of the built book.

Usage: python3 -I scripts/inject-book-head.py <fragment.html> <book-dir>

The book is built by mdBook from gfrmin/agent-court in its own job; this runs in
the build job, on static files only, so no code from that repository runs where
the Pages deploy rights are. Inserting into the built pages (rather than handing
mdBook a theme/head.hbs) also leaves any head.hbs agent-court adds intact.

toc.html is skipped: mdBook loads it only inside <noscript>, where neither
script in the fragment could run. Fails if any other page has no </head>.
"""
import pathlib
import sys


def inject(page: pathlib.Path, fragment: str) -> None:
    html = page.read_text(encoding="utf-8")
    if html.count("</head>") != 1:
        sys.exit(f"inject-book-head: {page} has {html.count('</head>')} </head> tags, expected 1")
    page.write_text(html.replace("</head>", fragment + "</head>", 1), encoding="utf-8")


def main(fragment_path: str, book_dir: str) -> None:
    fragment = pathlib.Path(fragment_path).read_text(encoding="utf-8").strip()
    if not fragment:
        sys.exit(f"inject-book-head: {fragment_path} is empty")
    pages = [p for p in sorted(pathlib.Path(book_dir).rglob("*.html")) if p.name != "toc.html"]
    if not pages:
        sys.exit(f"inject-book-head: no pages under {book_dir}")
    for page in pages:
        inject(page, fragment)
    print(f"inject-book-head: {len(pages)} pages")


if __name__ == "__main__":
    main(*sys.argv[1:])
