# gfrminsite Code Style and Conventions

## Quarto Code Block Conventions

### Posts Configuration
- **freeze: true** - Ensures posts render with fixed/cached output for reproducibility
- **code-fold: true** - Code blocks are folded by default, user can expand to read
- **code-tools: true** - Enables code tools like copying and viewing source

### Execute Settings
- freeze: auto (automatic freeze management in root _quarto.yml)
- cache: true (enable caching for faster re-renders)

## R/Data Analysis Conventions
- Project-local R library at `.R/library/` (configured via .Rprofile)
- Uses Quarto's native R support for code chunks
- Reproducible research patterns with cache/freeze

## Python Conventions
- Managed via uv dependency manager
- Dependencies specified in pyproject.toml
- Python >=3.13 required
- Jupyter notebooks supported via jupyter and jupyter-cache

## CSS Styling
- Custom styles defined in styles.css
- Integrated with Quarto's theme system
- Light theme: flatly
- Dark theme: darkly + custom dark theme CSS
