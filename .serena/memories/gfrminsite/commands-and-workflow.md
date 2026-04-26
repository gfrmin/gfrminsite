# gfrminsite Common Commands and Workflow

## Development Commands

### Quarto Commands
- **quarto preview** - Start local development server with hot reload (primary development command)
- **quarto render** - Full production build, outputs to public/ directory
- **quarto check** - Validate Quarto setup and installation

### Python Dependency Management
- **uv sync** - Install/sync Python dependencies from pyproject.toml

## Development Workflow

1. **Edit Content**: Modify .qmd files in posts/, projects/, or other content directories
2. **Preview**: Run `quarto preview` to view changes locally
3. **Test**: Use Python dependencies (jupyter, matplotlib, plotly) as needed
4. **Render**: Run `quarto render` for production build
5. **Deploy**: Commit to GitHub, automatic deployment to GitHub Pages (gfrm.in)

## Build Output
- All rendered HTML output goes to: public/ directory
- Static site is deployed from public/ to GitHub Pages
- Custom domain configured: https://gfrm.in

## Freeze/Cache Strategy
- freeze: auto enables automatic cache management
- cache: true caches code execution results
- These settings ensure reproducible research patterns and faster rebuilds
