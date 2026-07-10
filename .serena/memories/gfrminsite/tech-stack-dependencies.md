# gfrminsite Technology Stack and Dependencies

## Build Tool
- **Hugo** (extended) is the only build dependency. No package manager, no runtime deps.
- Version is pinned in `.github/workflows/publish.yml` (`peaceiris/actions-hugo@v3`, extended). Match the local `hugo` to it when versions diverge.

## Configuration
- `hugo.toml` — the single site config: baseURL, `[languages]` (en default, he RTL), `[taxonomies]` (categories), `[menu]`, `[markup]` (goldmark, with math passthrough), `[outputs]` (HTML + RSS), `[minify]`.
- `data/projects.yaml` — data file driving the project cards.

## Rendering Pipeline
- Markdown → HTML via goldmark (`unsafe = true` for raw HTML in content).
- Math → MathML at build time via the passthrough extension + `transform.ToMath` (`layouts/_default/_markup/render-passthrough.html`). No client-side JS.
- CSS via Hugo's asset pipeline from `assets/css/main.css`.

## NOT Present
- No `package.json` / Node tooling. Not a JS/TS project.
- No Python, R, `uv`, `pyproject.toml`, or Quarto — all removed in the July 2026 cleanup after the March 2026 Hugo migration.

## Language Distribution
- **Markdown**: content (`content/**`).
- **Go HTML templates**: `layouts/**`.
- **CSS**: `assets/css/main.css`.
- **YAML/TOML**: config and data.
