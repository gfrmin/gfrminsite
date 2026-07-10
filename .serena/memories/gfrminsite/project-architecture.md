# gfrminsite Project Architecture

## Directory Structure

### Root Configuration Files
- `hugo.toml` — site config (baseURL, languages, taxonomies, menus, markup, outputs, minify)
- `CLAUDE.md` — development guidelines and conventions
- `README.md` — project description and overview

### Content
- `content/posts/<slug>/index.md` — one directory per post (Hugo page bundle); frontmatter + body, with per-post assets (images, `og-image.png`) alongside.
- `content/posts/<slug>/index.he.md` — Hebrew translation (Hugo translation-by-filename); sibling of the English `index.md`.
- `content/he/` — Hebrew top-level sections (`_index.md`, `posts/`, `projects/`, `contact/`).
- `content/research/`, `content/projects/`, `content/contact/` — non-post sections (`_index.md` prose pages).
- `data/projects.yaml` — single source of truth for project cards.
- `drafts/` at the repo root — gitignored staging area for work-in-progress drafts (separate from Hugo's `draft: true`).

### Templates & Layouts
- `layouts/_default/{baseof,list,single}.html` — base chrome, list and single-page templates.
- `layouts/index.html`, `layouts/404.html` — homepage and 404 overrides.
- `layouts/partials/` — `header`, `footer`, `schema` (JSON-LD), `share-buttons`, `darkmode`, `posthog`, `skip-link`.
- `layouts/shortcodes/callout.html` — the callout shortcode (`{{< callout type="note" >}}`).
- `layouts/partials/project-card.html` — renders one `data/projects.yaml` entry.
- `layouts/_default/_markup/render-passthrough.html` — math → MathML at build time.

### Assets & Static
- `assets/css/main.css` — the stylesheet (Hugo asset pipeline).
- `static/` — served verbatim at the site root (`CNAME`, `favicon.ico`, `robots.txt`, `images/`).

### Build Output
- `public/` — generated static site (gitignored; GitHub Pages deployment source).

## Deployment Architecture
- Source: GitHub repository (`master` branch).
- Build: `.github/workflows/publish.yml` runs Hugo (extended, pinned version) → `public/`.
- Deployment: GitHub Pages; custom domain gfrm.in via Cloudflare (which caches aggressively — purge after deploy).
- Framework: static site, no backend.

## History
Migrated from Quarto to Hugo (March 2026); Quarto artefacts removed from the tree July 2026.
