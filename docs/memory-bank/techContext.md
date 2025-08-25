# Tech Context (Technologies Used)

## Technologies Used
- **Quarto**: Static site generator for technical content, enabling reproducible research with embedded code.
- **R**: Primary language for data analysis and visualization (used within Quarto `.qmd` documents).
- **Python**: Supporting language for data processing (used within Quarto `.qmd` documents).
- **CSS**: For custom styling and enhancing the presentation of the website.

## Development Setup
### Prerequisites
- **Quarto**: Must be installed (download from https://quarto.org/docs/get-started/).
- **R**: Must be installed (download from https://cran.r-project.org/).
- **Python**: A Python environment with specified dependencies.

### Local Development Workflow
1.  **Clone Repository**: `git clone https://github.com/yourusername/blog-quarto.git`
2.  **Navigate to Directory**: `cd blog-quarto`
3.  **Install Python Dependencies**: `uv sync` (uses `uv` for package management)
4.  **Start Development Server**: `quarto preview` (for live preview and development)
5.  **Build Site**: `quarto render` (to generate the static website files)

## Dependencies

### Python Dependencies
Managed via `pyproject.toml` and `uv.lock`.
Key dependencies include:
- `jupyter`: For Jupyter notebook support.
- `matplotlib`: For plotting.
- `plotly`: For interactive visualizations.

### R Dependencies
Required R packages need to be installed manually using `install.packages()`:
- `tidyverse`
- `ggplot2`
- `dplyr`
- `readr`

## Tool Usage Patterns
- **Quarto CLI**: Used for previewing (`quarto preview`) and rendering (`quarto render`) the website.
- **`uv`**: Used for managing Python packages and virtual environments.
- **R Scripting**: Embedded within `.qmd` files for data analysis.
- **Python Scripting**: Embedded within `.qmd` files for data processing and analysis.
