# gfrm.in

Source for my personal blog at [gfrm.in](https://gfrm.in) — essays on data, AI, Bayesian decision theory, and the occasional investigation. Built with [Hugo](https://gohugo.io). Bilingual: English by default, Hebrew translations with RTL.

## Local development

Requires Hugo **extended**, at the version in `.hugo-version` — the publish workflow
reads that file and asserts the binary it installed matches, so dev and prod build
with the same Hugo. `hugo.toml` carries the same version as a `[module.hugoVersion]`
floor, which warns on every build if your local Hugo is older. Bump both together.

```bash
git clone git@github.com:gfrmin/gfrminsite.git
cd gfrminsite

hugo server -D    # dev server with live reload, drafts included
hugo --minify     # production build, exactly what CI runs
```

## Structure

```
content/posts/<slug>/index.md      one directory per post (Hugo page bundle);
                                   images and og-image.png live alongside it
content/posts/<slug>/index.he.md   Hebrew translation of that post
content/he/                        Hebrew top-level sections
content/research/, projects/, contact/
data/projects.yaml                 single source of truth for project cards
layouts/                           templates, partials, shortcodes
assets/css/main.css                the stylesheet (Hugo asset pipeline)
static/                            served verbatim at the site root
drafts/                            gitignored staging area for work in progress
```

Posts carry `draft: true` until they're ready. Mathematics is written as `\(inline\)` and `$$display$$`, rendered to MathML at build time — note that a bare `$` is *not* a math delimiter, since the prose is full of dollar amounts.

## Deployment

Push to `master`; `.github/workflows/publish.yml` builds with Hugo and deploys to GitHub Pages. The custom domain `www.gfrm.in` resolves via Cloudflare, which caches aggressively — a deploy is not visible until the cache is purged.

## License

Prose is licensed [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0).

## Contact

- GitHub: [@gfrmin](https://github.com/gfrmin)
- Twitter: [@gfrm_in](https://twitter.com/gfrm_in)
