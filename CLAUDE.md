# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal data science blog built with Quarto. The site uses R as the primary analysis language with Python for supporting data processing. Posts are written in Quarto markdown (`.qmd` files) combining narrative text with executable code.

## Common Commands

```bash
# Development server with live reload
quarto preview

# Build the site for production
quarto render

# Render a specific post
quarto render posts/bechirot/index.qmd

# Install Python dependencies
uv sync
```

## Architecture

- **`_quarto.yml`**: Main site configuration (theme, navbar, site URL)
- **`posts/`**: Blog posts, each in its own subdirectory with an `index.qmd` file
- **`posts/_metadata.yml`**: Default settings for all posts (freeze enabled, code-fold on)
- **`projects/`**: Project showcases (similar structure to posts)
- **`projects.qmd`**: Projects listing page
- **`_site/`**: Generated output (gitignored)
- **`CNAME`**: Custom domain for GitHub Pages (www.gfrm.in)

## Key Conventions

- Posts use `freeze: true` by default - computational output is cached and not re-run unless explicitly requested
- Code blocks have `code-fold: true` (collapsible) and `code-tools: true` (copy button)
- Data files (CSV, xlsx, rds) are gitignored but stored locally in post directories
- Python managed via `uv` with dependencies in `pyproject.toml`
- R packages installed separately (tidyverse, ggplot2, dplyr, readr commonly used)

## Writing New Posts

Create a new directory under `posts/` with:
1. `index.qmd` - the post content with YAML frontmatter (title, date, categories)
2. Any data files needed for the analysis

## Deployment

Site deploys to GitHub Pages with custom domain `www.gfrm.in`:
- DNS managed via Cloudflare
- Push to `master` triggers deployment
- `quarto publish gh-pages` for manual deployment
