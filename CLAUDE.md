# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog at [gfrm.in](https://gfrm.in), built with **Hugo**. Prose-first (essays on data, AI, Bayesian decision theory, investigations); only one legacy post uses executable code. Bilingual — English default, Hebrew translations with RTL.

Migrated from Quarto to Hugo in March 2026; the Quarto artefacts were removed from the tree in July 2026. If you find a reference to `_quarto.yml`, `*.qmd`, `_freeze/`, R, or `uv`/`pyproject.toml` anywhere, it is stale — the live site is entirely Hugo (`hugo.toml` plus the `layouts/` tree).

## Common Commands

```bash
# Dev server with live reload, including drafts
hugo server -D

# Production build (what CI runs)
hugo --minify

# Pin to the CI-matching Hugo version if the `hugo` on $PATH is newer/older
# CI uses peaceiris/actions-hugo@v3 with hugo-version 0.163.3 extended
```

### Mathematics

Math is rendered to **MathML at build time** via goldmark's passthrough extension and `transform.ToMath` (`layouts/_default/_markup/render-passthrough.html`) — no KaTeX, no JS, no CDN. Delimiters: display is `$$…$$` or `\[…\]`; **inline is `\(…\)` only**. A bare `$` is deliberately *not* an inline delimiter, because the prose is full of dollar amounts (`$200,000`); enabling `$…$` inline would silently turn money into math. When writing math in a post, always use `\(…\)` for inline.

## Architecture

### Content layout

- `content/posts/<slug>/index.md` — one directory per post, with `index.md` holding frontmatter and body. Per-post assets (images, `og-image.png`, demo gifs) live alongside in the same directory — Hugo page bundles, so `image: og-image.png` in frontmatter resolves relative to the post.
- `content/posts/<slug>/index.he.md` — Hebrew translation of a post (Hugo translation-by-filename). The English `index.md` and the Hebrew `index.he.md` are siblings; Hugo links them as translations automatically.
- `content/he/` — Hebrew-language top-level sections (`_index.md`, `posts/`, `projects/`, `contact/`). Translated **posts** use the `index.he.md` sibling pattern above, not a duplicate tree here.
- `content/projects/`, `content/contact/` — non-post sections.
- `drafts/` at the **repo root** (not inside `content/`) is gitignored and used as a staging area for work-in-progress drafts before they're moved into `content/posts/`. This is separate from Hugo's own `draft: true` frontmatter mechanism, which is also used for in-tree posts that aren't yet public.

### URL shape (non-obvious)

Hebrew posts live at `/he/posts/<slug>/` — not `/posts/<slug>/he/`. A recent fix (commit ceb1c3c) corrected this in internal links; preserve the pattern when adding navigation or language-switcher code.

### Templates & styling

- `hugo.toml` — site config (baseURL, languages, taxonomies, menus, markup, outputs, minify).
- `layouts/_default/{baseof,list,single}.html` — base chrome plus list and single-page templates.
- `layouts/partials/` — `header.html`, `footer.html`, `schema.html` (JSON-LD), `share-buttons.html`, `darkmode.html`, `posthog.html`, `skip-link.html`.
- `layouts/shortcodes/callout.html` — callout shortcode.
- `layouts/index.html`, `layouts/404.html` — homepage and 404 overrides.
- `assets/css/main.css` — active stylesheet (Hugo asset pipeline).
- `static/` — served verbatim at the site root (includes `CNAME`, `favicon.ico`, `robots.txt`, `images/` for non-post-bundle images).

### Post frontmatter conventions

Standard keys seen across current posts:

```yaml
---
title: "..."
subtitle: "..."                     # optional, rendered under title
description: "..."                  # used for <meta name="description"> and og:description
author: "Guy Freeman"
date: YYYY-MM-DD
draft: true                         # work-in-progress; hide from production build
categories: [essays, bayesian, ...] # taxonomy; renders at /categories/<cat>/
image: og-image.png                 # optional, relative to page bundle; falls back to site default (layouts/_default/baseof.html:19)
---
```

The site default OG image is configured in `hugo.toml` under `params.ogImage`; omitting `image:` from a post's frontmatter is fine — the template falls back gracefully. The recent batch of April 2026 drafts (`accuracy-paradox`, `alignment-axiom`, etc.) omit `image:` entirely and are a good pattern to copy.

### RTL

Don't set `dir="rtl"` on `<html>`. RTL is scoped to content via CSS class, not the root element — a prior attempt to flip the whole page broke layout (commit af3013e). If touching language/direction code, preserve this.

## Deployment

- Push to `master` → `.github/workflows/publish.yml` runs Hugo and deploys to GitHub Pages.
- Custom domain `www.gfrm.in`, DNS via Cloudflare (CNAME to `gfrmin.github.io`).
- **Cloudflare caches aggressively** — a deploy is not visible until the cache is purged. After confirming the GitHub Actions run succeeds, purge the Cloudflare cache for zone `gfrm.in` (zone ID `a8f9ffe2e792e663242e5e5e7c03d5ff`).
