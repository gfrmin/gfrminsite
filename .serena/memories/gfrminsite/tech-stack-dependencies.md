# gfrminsite Technology Stack and Dependencies

## Project Configuration Files

### pyproject.toml
- **Project Name**: blog-quarto
- **Version**: 0.1.0
- **Python Requirement**: >=3.13
- **Dependency Manager**: uv

### Python Dependencies
- jupyter>=1.1.1 (Jupyter notebook support)
- jupyter-cache>=1.0.0 (Code cell caching)
- matplotlib>=3.10.3 (Plotting)
- plotly>=6.1.2 (Interactive visualizations)

### _quarto.yml
Main site configuration with:
- Project type: website
- Output directory: public/
- Execute settings: freeze: auto, cache: true
- Format: HTML with custom CSS (styles.css)
- Theme configuration (light/dark modes)
- Navigation menu structure
- Filter plugins configuration

## NOT Present
- package.json (This is NOT a Node.js/TypeScript project)
- TypeScript or JavaScript dependencies
- Node.js tooling

## Language Distribution
- **R**: Primary language for data analysis and visualization
- **Python**: Secondary language for data processing
- **CSS**: Custom styling
- **Markdown/Quarto**: Content and configuration
