# gfrminsite Project Overview

## Project Purpose
Personal data science blog built with Quarto static site generator. Showcases analysis projects, election analysis, and statistical insights. Deployed to custom domain gfrm.in via GitHub Pages.

## Site Configuration
- **Title**: Guy Freeman
- **Domain**: https://gfrm.in
- **Output Directory**: public/
- **Site Type**: Quarto website

## Navigation Structure
- Home
- Posts
- Projects
- Contact

## Theme Configuration
- Light theme: flatly
- Dark theme: darkly (with custom dark theme CSS)
- Custom styling via: styles.css

## Core Technologies
- **Primary Language**: R (data analysis and visualization)
- **Secondary Language**: Python (data processing)
- **Python Manager**: uv (with pyproject.toml configuration)
- **Static Site Generator**: Quarto
- **Styling**: CSS (custom styles.css)
- **Deployment**: GitHub Pages with custom domain

## Key Concept: Reproducible Research
Uses Quarto's freeze/cache functionality to ensure reproducible analyses:
- freeze: auto (default behavior)
- cache: true (enabled for performance)

## Project-Local R Library
Configured via `.Rprofile` at `.R/library/` for isolated R package management
