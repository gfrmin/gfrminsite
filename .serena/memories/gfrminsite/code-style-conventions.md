# gfrminsite Code Style and Conventions

## Post Frontmatter
Standard YAML keys across current posts:
- `title`, `subtitle` (optional, rendered under the title), `description` (used for `<meta name="description">` and `og:description`)
- `author: "Guy Freeman"`, `date: YYYY-MM-DD`
- `draft: true` — work-in-progress; hidden from the production build
- `categories: [essays, bayesian, ...]` — taxonomy; renders at `/categories/<cat>/`. Reuse existing terms rather than inventing new ones.
- `image: og-image.png` — optional, relative to the page bundle; falls back to `params.ogImage` in `hugo.toml` if omitted.

## Content Conventions
- One directory per post: `content/posts/<slug>/index.md`, assets alongside (page bundle).
- Hebrew translation is a sibling `index.he.md`; Hebrew posts resolve to `/he/posts/<slug>/`.
- RTL is scoped to content via a CSS class — never set `dir="rtl"` on `<html>`.
- The only custom shortcode is `{{< callout type="note" >}} … {{< /callout >}}`.

## Mathematics
- Rendered to MathML at build time (goldmark passthrough + `transform.ToMath`); no KaTeX/JS.
- Inline: `\(…\)`. Display: `$$…$$` or `\[…\]`.
- A bare `$` is NOT a delimiter — prose contains dollar amounts (`$200,000`). Always use `\(…\)` for inline math.

## Styling
- Single stylesheet: `assets/css/main.css` (Hugo asset pipeline).
- Light/dark mode via `layouts/partials/darkmode.html` + CSS custom properties.

## Project Cards
- Edit `data/projects.yaml`; each entry is rendered by `layouts/partials/project-card.html`.
- Descriptions are plain prose (not markdown-parsed), conventionally ending with the tech stack. `hero: true` = homepage feature (exactly one), `featured: true` = homepage grid, `weight` orders `/projects/`.
