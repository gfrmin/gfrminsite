# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal blog at [gfrm.in](https://gfrm.in), built with **Hugo**. Prose-first (essays on data, AI, Bayesian decision theory, investigations); only one legacy post uses executable code. Bilingual — English default, Hebrew translations with RTL.

Migrated from Quarto to Hugo in March 2026. The July 2026 cleanup missed the repo
root, which kept `contact/index.qmd`, `projects/index.qmd`, `.python-version`, a
`CNAME` contradicting the published one, and byte-identical copies of `static/`'s
`images/`, `fonts/`, `favicon.ico`, `og-default.png` and `profile.jpg`; all of it
was deleted in Aug 2026 and none of it was ever served. If you find a reference to
`_quarto.yml`, `*.qmd`, `_freeze/`, R, or `uv`/`pyproject.toml` anywhere, it is
stale — the live site is entirely Hugo (`hugo.toml` plus the `layouts/` tree).

The published domain comes from `static/CNAME` (`www.gfrm.in`), because the
workflow uploads only `public/`. Note this disagrees with `baseURL` and every
canonical, which say `gfrm.in`; it works because Cloudflare 301s www to the apex.
Changing it is a live GitHub Pages action, not an edit.

## Common Commands

```bash
# Dev server with live reload, including drafts
hugo server -D

# Production build (what CI runs)
hugo --minify

# Hugo version is pinned in `.hugo-version` (currently 0.165.0, extended).
# CI reads that file, installs exactly it, and fails if the two disagree.
# `hugo.toml` repeats it as a [module.hugoVersion] min, which only WARNs.
# Bumping the version means editing .hugo-version AND hugo.toml together.
```

### Mathematics

Math is rendered to **MathML at build time** via goldmark's passthrough extension and `transform.ToMath` (`layouts/_default/_markup/render-passthrough.html`) — no KaTeX, no JS, no CDN. Delimiters: display is `$$…$$` or `\[…\]`; **inline is `\(…\)` only**. A bare `$` is deliberately *not* an inline delimiter, because the prose is full of dollar amounts (`$200,000`); enabling `$…$` inline would silently turn money into math. When writing math in a post, always use `\(…\)` for inline.

## Architecture

### Content layout

- `content/posts/<slug>/index.md` — one directory per post, with `index.md` holding frontmatter and body. Per-post assets (images, `og-image.png`, demo gifs) live alongside in the same directory — Hugo page bundles, so `image: og-image.png` in frontmatter resolves relative to the post.
- `content/posts/<slug>/index.he.md` — Hebrew translation of a post (Hugo translation-by-filename). The English `index.md` and the Hebrew `index.he.md` are siblings; Hugo links them as translations automatically.
- **There is no `content/he/` tree.** Every Hebrew page is an `.he.md` sibling of its English
  counterpart — `content/_index.he.md` (homepage), `content/posts/<slug>/index.he.md` (posts),
  `content/series/<slug>/_index.he.md` and `content/categories/<slug>/_index.he.md` (taxonomy
  display titles) and `content/posts/_index.he.md` (the posts index — without it `/he/posts/`,
  the Hebrew menu's second item, rendered `<h1>Posts</h1>` and the English site bio for its
  meta description, because Hugo falls back to the section name). Hugo pairs them by filename.
  Hebrew currently covers the homepage, the posts index, the five Velotix posts, and the
  taxonomy titles those posts use; `/research/`, `/projects/` and `/contact/` are English-only
  and deliberately absent from the Hebrew menu.
- `content/projects/`, `content/contact/` — non-post sections.
- `drafts/` at the **repo root** (not inside `content/`) is gitignored and used as a staging area for work-in-progress drafts before they're moved into `content/posts/`. This is separate from Hugo's own `draft: true` frontmatter mechanism, which is also used for in-tree posts that aren't yet public.

### Series (post sequences)

Most posts belong to a sequence. Series are a **Hugo taxonomy** (`series` in `hugo.toml`), one value per post, ordered by a separate `series_order` integer:

```yaml
series: [coding-agents]
series_order: 3
```

The frontmatter value is the **slug**; the display title comes from `content/series/<slug>/_index.md` (which also holds the series' intro prose, shown on `/series/<slug>/` and as the description on the `/series/` hub). Hebrew titles go in a sibling `_index.he.md`.

Templates: `layouts/series/taxonomy.html` (the `/series/` hub), `layouts/series/term.html` (one series), and two partials rendered by `single.html` — `series-banner.html` above the body ("Part 3 of 4 in ...") and `series-nav.html` below it (full ordered list plus prev/next).

**Do not hand-maintain cross-links between parts of a series.** Every Velotix post used to carry a "This is Part 3, see Parts 1/2/4/5" callout *and* a trailing italic copy of the same list, in both languages — twenty hand-maintained link sets that had to be edited whenever a part was added. Those were removed in favour of the generated nav. Contextual references inside the prose ("as covered in [Part 1](...)") are fine and were kept.

A post with no `series` simply renders no nav. Seven posts are deliberately standalone.

### Related posts

`layouts/partials/related-posts.html` uses Hugo's built-in `.Site.RegularPages.Related`, configured under `[related]` in `hugo.toml` (categories + date; **series is deliberately not an index**). It then filters out any post in the *same* series, because the series nav already lists those — related exists to reach *across* series. Posts whose only related pages are same-series render nothing, which is correct.

### URL shape (non-obvious)

Hebrew posts live at `/he/posts/<slug>/` — not `/posts/<slug>/he/`. A recent fix (commit ceb1c3c) corrected this in internal links; preserve the pattern when adding navigation or language-switcher code.

### Templates & styling

- `hugo.toml` — site config (baseURL, languages, taxonomies, menus, markup, outputs, minify).
- `layouts/_default/{baseof,list,single}.html` — base chrome plus list and single-page templates.
- `layouts/partials/` — `header.html`, `footer.html`, `schema.html` (JSON-LD), `share-buttons.html`, `darkmode.html`, `posthog.html`, `skip-link.html`.
- `layouts/shortcodes/callout.html` — callout shortcode.
- `layouts/_default/taxonomy.html` — term index (`/categories/`). Terms are not posts; before this existed they fell through to `list.html` and rendered as post cards with a bogus date and "0 min read".
- `i18n/{en,he}.toml` — **every** user-facing string in a template, not just the series chrome:
  nav labels, reading time, share buttons, the 404, the homepage section headings. Anything added
  to a template needs an entry in both files, and the two must stay key-for-key identical — a
  missing Hebrew key silently falls back to English, which is exactly the failure this replaced.
- `layouts/partials/category-tags.html` — the category chips. Centralised because two templates
  had drifted: both printed the raw frontmatter slug (`MACHINE-LEARNING`) instead of the term
  page's display title, and both built the href with `relURL`, which is not language-aware and so
  sent Hebrew readers to the English `/categories/<slug>/`. The partial resolves the term page and
  uses its own `.RelPermalink`.
- `layouts/_default/_markup/render-image.html` — markdown image render hook, adding
  `loading="lazy" decoding="async"` and resolving the destination against the page bundle so `src`
  is an absolute `RelPermalink` rather than a bare filename.
- `layouts/partials/post-card.html`, `layouts/partials/project-card.html` — the two card
  types. Both take a `level` in their dict context which sets the heading tag, because the
  same card renders under a page `<h1>` on a listing (h2) and under a section `<h2>` on the
  homepage (h3). Note that `<{{ $h }}>` does **not** work — Go's contextual autoescaping
  emits a literal `&lt;h2`; the open and close tags are built as whole strings and marked
  `safeHTML`. Post cards were duplicated between `list.html` and `index.html` before this
  and had drifted apart on heading level and thumbnail markup.

  A card thumbnail links to the same URL as the title beside it. When it adds nothing —
  a post's og-image, or one of the five generated gradient cards in `data/projects.yaml`
  that show only the project name — the image is `alt=""` and the whole anchor takes
  `tabindex="-1" aria-hidden="true"`, so the card is one link rather than two and a screen
  reader does not read the title twice. `project-card.html` decides this per entry from
  whether `alt` is empty, so the three real screenshots (kana, docaviv+, Scalibur) keep
  their descriptive alt and stay exposed. **Do not "fix" an empty `alt` by describing the
  image** — for those five there is nothing to describe that the heading does not say.
- `layouts/partials/project-row.html` — the same data as a full-width row: thumbnail beside
  the prose, or prose alone at a 68ch measure when there is no image. `/projects/` uses it for
  all thirteen entries at full length, and the homepage uses it for the single `hero: true`
  entry clipped to 420. The card grid could not carry that page: the descriptions run from 108
  characters to 862, so half of it was ragged and the longest sat in a 45-character column.
  The row links only its title — a separate "View on GitHub" CTA was a second link to the same
  URL, and it was wrong for the five entries that are not on GitHub at all.
- The homepage order is bio, what I do, series, recent posts, **projects last**. Projects used
  to run third, which put roughly 2,000px of grid between the bio and any of the writing.
- `layouts/partials/darkmode-init.html` — sets `data-theme` from a blocking script in
  `<head>`. It has to run before the first paint; when this lived with the toggle wiring at
  the end of `<body>`, dark-mode readers saw the whole page render light and then flip.
  `layouts/partials/darkmode.html` keeps only the click handler, which needs the button in
  the DOM. Which icon shows is CSS off `data-theme`, not inline styles from JS. Every
  `localStorage` access is wrapped — it throws outright in some privacy modes — and a value
  is written only on a real click, so a reader who has never chosen keeps following their OS.
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
series: [coding-agents]             # optional; slug, not display title (see Series above)
series_order: 3                     # required whenever series is set
linkTitle: "Part 3: The Takedown"   # optional; short form used in series nav and related lists
image: og-image.png                 # optional, relative to page bundle; falls back to site default (layouts/_default/baseof.html:19)
---
```

**Frontmatter text is not markdown.** `title`, `subtitle` and `description` are emitted raw into `<h1>`/`<p>`/`<meta>`, so goldmark's typographer never sees them and a literal `---` stays three hyphens on the page and in the OG card. Body prose may use `---`; frontmatter must use a real em-dash (`—`). Ten files were fixed for this in Aug 2026 — do not reintroduce it.

**Categories are kept above a floor of roughly two posts each.** A one-post category is a tag on one thing, not a navigation aid. In Aug 2026 the set was consolidated 30 → 15: near-synonyms were folded into one label (`iot`/`raspberry-pi`/`ble`/`health` → `hardware`) and `regulation`/`dmca`/`privacy` were merged into a single `policy` category rather than deleted. `hardware` is the one deliberate singleton. Category pages are `noindex, follow`, so renaming them carries no SEO cost.

Display titles for categories whose slug reads badly in title case (`ai` → "AI", `machine-learning` → "Machine Learning") come from `content/categories/<slug>/_index.md`.

The site default OG image is configured in `hugo.toml` under `params.ogImage`; omitting `image:` from a post's frontmatter is fine — the template falls back gracefully. The recent batch of April 2026 drafts (`accuracy-paradox`, `alignment-axiom`, etc.) omit `image:` entirely and are a good pattern to copy.

### Bilingual navigation

Menus are defined **per language** (`[languages.en.menu]` / `[languages.he.menu]` in `hugo.toml`),
never as one shared `[menu]` block. A shared block emits the same literal `url` values on both
sides, so every Hebrew nav link pointed at `/posts/`, `/series/` and so on — the English pages —
and a Hebrew reader was thrown out of the Hebrew site by any click. For the same reason the brand
link and the RSS link use `.Site.Home.RelPermalink`, not `"/" | relURL`.

The header carries a permanent language toggle: it resolves to the current page's translation when
one exists and to the other language's homepage otherwise, so it is never a dead link. The old
per-post `translation-link` was removed as a duplicate of it.

Dates use `time.Format ":date_medium"`, not `.Date.Format "Jan 2, 2006"` — the latter is a literal
Go layout and printed English month names on Hebrew pages.

`[languages.he.params]` in `hugo.toml` carries a Hebrew `description`. Without it every Hebrew
page that has no description of its own fell back to the English bio, because a top-level
`[params]` block is shared across languages.

`layouts/_default/rss.xml` exists for one reason: Hugo's internal feed template hardcodes the
channel description as the English string "Recent content on <site title>", which shipped
untranslated inside the Hebrew feed. It reproduces the internal template field for field and
takes the description from the page or the site instead. If you touch it, re-validate every
feed parses — `public/index.xml`, `public/he/index.xml` and each section's.

### CSS: theme-aware alpha colours, logical directions

`--brand-primary` is a different teal per theme, so any `rgba()` built from it must read
`--brand-primary-rgb`, which is defined in both `:root` and `[data-theme="dark"]`. Two
rules were written as a literal `rgba(13, 115, 119, …)` and kept the light-mode teal on
dark backgrounds. Keep the hex and the triple in step when either moves.

RTL is handled by paired `.rtl-content` overrides for physical `margin-`/`padding-`/
`border-left|right`, and every such rule has its pair — except where a **logical**
property is simply correct, as in `.reading-time::before { margin-inline-end }`. Prefer
the logical property in anything new; it needs no pair.

`@media (prefers-reduced-motion: reduce)` must cover `transition-duration` and
`scroll-behavior`, not only `animation-duration` — the stylesheet has 19 transitions
including card lifts and an image zoom, and they all kept running when it did not.

### CSS gotcha: no border-box reset

`assets/css/main.css` has **no** global `box-sizing: border-box`. Anything given an explicit
`width` alongside padding has to set `box-sizing` itself or the page scrolls sideways. `#content`
does exactly this: it needs `width: 100%` because it is a flex item of the sticky-footer `body`
and its `margin: 0 auto` would otherwise shrink it to fit its content.

### RTL

Don't set `dir="rtl"` on `<html>`. RTL is scoped to content via CSS class, not the root element — a prior attempt to flip the whole page broke layout (commit af3013e). If touching language/direction code, preserve this.

The navbar and the footer sit **outside** `.rtl-content`, so they need their own handling and
get it from `html:lang(he) .navbar-container, html:lang(he) .footer-container { direction: rtl }`.
Two things depended on it: a flex row follows `direction`, so the brand moves to the top right
and the copyright to the bottom right without a second `row-reverse` rule; and the footer line
mixes scripts (`© 2026 <name>. <licence> CC BY-SA 4.0`), which in an LTR paragraph the bidi
algorithm reordered into nonsense. Note the nav **links** never needed this — they are inline
boxes of Hebrew text in one bidi run, so the browser already reversed them. Below 768px
`.navbar-menu` is `flex-direction: column`, which `direction` does not disturb.

Type stacks live in `--font-sans` / `--font-serif` rather than as literals, because
`html:lang(he)` overrides them to name real Hebrew faces. Neither Fraunces nor Georgia nor the
Latin subset of IBM Plex Sans carries Hebrew, so every Hebrew glyph used to fall through to
whatever the browser calls `serif`/`sans-serif`. The Latin names stay **first** in the Hebrew
stacks — fallback is per-glyph, so digits and Latin words still set in them. For the same
reason `baseof.html` preloads `fraunces-latin.woff2` on English pages only: Fraunces draws
only headings, and on a Hebrew page the headings are Hebrew.

## Deployment

- Push to `master` → `.github/workflows/publish.yml` runs Hugo and deploys to GitHub Pages.
- Custom domain `www.gfrm.in`, DNS via Cloudflare (CNAME to `gfrmin.github.io`).
- **Cloudflare caches aggressively** — a deploy is not visible until the cache is purged. After confirming the GitHub Actions run succeeds, purge the Cloudflare cache for zone `gfrm.in` (zone ID `a8f9ffe2e792e663242e5e5e7c03d5ff`).
