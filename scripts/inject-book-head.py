"""Insert Hugo's book <head> fragment into every page of the built book.

Usage:
  python3 -I scripts/inject-book-head.py <fragment.html> <book-dir>
  python3 -I scripts/inject-book-head.py --check <book-dir>

The book is built by mdBook from gfrmin/agent-court in publish.yml's `book` job.
The insert runs in the `build` job, on static files only, so no code from that
repository runs where the Pages deploy rights are. Inserting into the built pages,
rather than handing mdBook a theme/head.hbs, also leaves any head.hbs that
agent-court adds intact.

--check runs in the `book` job, with the same test the insert makes, so a book
that cannot take the fragment fails there. The `build` job then falls back to the
last good book instead of failing the blog deploy.

toc.html is skipped: mdBook loads it only inside <noscript>, where neither script
in the fragment could run. 404.html also gets a robots noindex, because the root
404 sends a missing /book/ page there and GitHub Pages serves it with status 200.
"""
import pathlib
import sys

NOINDEX = '<meta name="robots" content="noindex">'


def pages(book_dir: str) -> list[pathlib.Path]:
    found = [p for p in sorted(pathlib.Path(book_dir).rglob("*.html")) if p.name != "toc.html"]
    if not found:
        sys.exit(f"inject-book-head: no pages under {book_dir}")
    return found


def problem(page: pathlib.Path) -> str | None:
    n = page.read_text(encoding="utf-8").count("</head>")
    return None if n == 1 else f"{page} has {n} </head> tags, expected 1"


def check(book_dir: str) -> None:
    found = pages(book_dir)
    problems = [p for p in map(problem, found) if p]
    if problems:
        sys.exit("inject-book-head: " + "; ".join(problems))
    print(f"inject-book-head: {len(found)} pages can take the fragment")


def inject(page: pathlib.Path, fragment: str) -> None:
    if (msg := problem(page)):
        sys.exit(f"inject-book-head: {msg}")
    extra = NOINDEX if page.name == "404.html" else ""
    html = page.read_text(encoding="utf-8")
    page.write_text(html.replace("</head>", extra + fragment + "</head>", 1), encoding="utf-8")


def main(argv: list[str]) -> None:
    if argv[:1] == ["--check"]:
        return check(*argv[1:])
    fragment_path, book_dir = argv
    fragment = pathlib.Path(fragment_path).read_text(encoding="utf-8").strip()
    if not fragment:
        sys.exit(f"inject-book-head: {fragment_path} is empty")
    found = pages(book_dir)
    for page in found:
        inject(page, fragment)
    print(f"inject-book-head: {len(found)} pages")


if __name__ == "__main__":
    main(sys.argv[1:])
