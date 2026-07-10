# gfrminsite Common Commands and Workflow

## Development Commands

- **`hugo server -D`** — local dev server with live reload, drafts included (primary development command)
- **`hugo --minify`** — full production build (exactly what CI runs); outputs to `public/`
- Pin the local `hugo` to the CI-matching extended version if `hugo` on `$PATH` differs (see `.github/workflows/publish.yml`).

## Development Workflow

1. **Edit Content**: modify `content/posts/<slug>/index.md` (or `_index.md` section files). Work-in-progress posts carry `draft: true`, or stage them under the gitignored `drafts/` at the repo root.
2. **Preview**: run `hugo server -D` to view changes (including drafts) locally.
3. **Build**: run `hugo --minify` to confirm a clean production build before pushing.
4. **Deploy**: commit and push to `master`; `.github/workflows/publish.yml` builds with Hugo and deploys to GitHub Pages.
5. **Purge**: after a green Actions run, purge the Cloudflare cache for zone gfrm.in — the deploy is not visible until then.

## Build Output
- Rendered HTML goes to `public/` (gitignored), deployed to GitHub Pages.
- Custom domain: https://gfrm.in (Cloudflare in front, caches aggressively).

## Mathematics
- Rendered to MathML at build time; no JS. Inline is `\(…\)`, display is `$$…$$` or `\[…\]`.
- A bare `$` is deliberately not a math delimiter (prose contains dollar amounts).
