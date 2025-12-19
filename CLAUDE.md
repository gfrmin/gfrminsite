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
quarto render posts/hanukkah-of-code/index.qmd

# Install Python dependencies
uv sync

# Install R package to project-local library
R -e "install.packages('packagename')"
```

## Architecture

- **`_quarto.yml`**: Main site configuration (theme, navbar, site URL)
- **`posts/`**: Blog posts, each in its own subdirectory with an `index.qmd` file
- **`posts/_metadata.yml`**: Default settings for all posts (freeze enabled, code-fold on)
- **`projects/`**: Project showcases (similar structure to posts)
- **`public/`**: Generated output for GitLab Pages (gitignored)
- **`.gitlab-ci.yml`**: CI/CD pipeline for GitLab Pages deployment
- **`.Rprofile`**: Configures project-local R library at `.R/library/`

## Key Conventions

- Posts use `freeze: true` by default - computational output is cached and not re-run unless explicitly requested
- Code blocks have `code-fold: true` (collapsible) and `code-tools: true` (copy button)
- Data files (CSV, xlsx, rds) are gitignored but stored locally in post directories
- Python managed via `uv` with dependencies in `pyproject.toml`
- R packages installed to project-local `.R/library/` directory (tidyverse, ggplot2, dplyr, readr commonly used)

## Writing New Posts

Create a new directory under `posts/` with:
1. `index.qmd` - the post content with YAML frontmatter (title, date, categories)
2. Any data files needed for the analysis

## Deployment

Site deploys to GitLab Pages with custom domain `www.gfrm.in`:
- CI pipeline uses `rocker/verse:latest` image with R and Quarto
- Push to `master` triggers automatic deployment
- DNS managed via Cloudflare
