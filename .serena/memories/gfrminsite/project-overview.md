# gfrminsite Project Overview

## Project Purpose
Personal blog at gfrm.in, built with the **Hugo** static site generator. Prose-first: essays on data, AI, Bayesian decision theory, and investigations (only one legacy post uses executable code). Bilingual — English by default, Hebrew translations with RTL. Deployed to the custom domain gfrm.in via GitHub Pages.

## Site Configuration
- **Title**: Guy Freeman
- **Domain**: https://gfrm.in
- **Config**: `hugo.toml` (baseURL, languages, taxonomies, menus, markup, outputs, minify)
- **Output Directory**: `public/` (gitignored)
- **Static Site Generator**: Hugo (extended)

## Navigation Structure
- Home, Posts, Research, Projects, Contact (defined in `hugo.toml` `[menu]`)

## Bilingual / RTL
- English is the default language; Hebrew (`he`) is a second language with `direction = "rtl"`.
- Translated posts use the `index.he.md` sibling-file pattern; Hebrew posts live at `/he/posts/<slug>/`.
- RTL is scoped to content via a CSS class, **not** `dir="rtl"` on `<html>` (a prior attempt to flip the whole page broke layout).

## Core Technologies
- **Static Site Generator**: Hugo (extended), CI-pinned via `.github/workflows/publish.yml`
- **Styling**: `assets/css/main.css` (Hugo asset pipeline)
- **Math**: rendered to MathML at build time (goldmark passthrough + `transform.ToMath`); no JS/KaTeX
- **Analytics**: PostHog (`layouts/partials/posthog.html`)
- **Deployment**: GitHub Pages with custom domain, Cloudflare in front

## History
Migrated from Quarto to Hugo in March 2026; the Quarto artefacts (`_quarto.yml`, `*.qmd`, `_freeze/`, R, `uv`/`pyproject.toml`, `styles.css`) were removed from the tree in July 2026. Any reference to them elsewhere is stale.
