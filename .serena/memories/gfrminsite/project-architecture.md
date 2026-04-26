# gfrminsite Project Architecture

## Directory Structure

### Root Configuration Files
- `_quarto.yml` - Main site configuration (project type, output, theme, navigation)
- `pyproject.toml` - Python project configuration and dependencies
- `CLAUDE.md` - Development guidelines and conventions
- `README.md` - Project description and overview
- `.Rprofile` - R configuration file for project-local library at .R/library/

### Content Directories
- `posts/` - Blog posts (uses freeze: true convention)
- `projects/` - Project showcases
- `contact/` - Contact page
- Other potential content directories following similar structure

### System Directories
- `layouts/` - Custom Quarto layouts
- `_filters/` - Quarto filters for custom processing
- `_includes/` - Reusable HTML/template includes
- `_scripts/` - Build/utility scripts
- `.R/` - R configuration directory (library subdirectory for packages)

### Build Output
- `public/` - Generated static site (GitHub Pages deployment source)

## Configuration Files Explained

### _quarto.yml
Specifies:
- Project type: website
- Output directory: public/
- Website title and metadata
- Navigation menu structure
- Theme configuration
- Execute settings (freeze, cache)
- HTML format with custom CSS (styles.css)
- Filter plugins

### pyproject.toml
Specifies:
- Project metadata (name: blog-quarto, version: 0.1.0)
- Python version requirement: >=3.13
- Dependencies for data science and visualization
- Uses uv as dependency manager

## Deployment Architecture
- Source: GitHub repository
- Build: Quarto render to public/
- Deployment: GitHub Pages
- Custom Domain: gfrm.in
- Framework: Static site (no backend)
