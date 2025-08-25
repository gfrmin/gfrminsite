# Guy Freeman's Data Science Blog

A personal blog showcasing data analysis projects, statistical insights, and coding adventures. Built with Quarto for reproducible research and beautiful presentations.

## About

This repository contains the source code for my personal data science blog. I'm a data scientist with a PhD in statistics who has worked across various domains and locations (Israel, England, Hong Kong).

## Features

- **Quarto-powered**: Modern, reproducible research with R and Python
- **Data Analysis Posts**: Election analysis, puzzle solutions, and statistical insights
- **Interactive Elements**: Code folding, data tables, and dynamic visualizations
- **Responsive Design**: Clean, professional layout that works on all devices

## Recent Posts

- **Israel's Election for the 25th Knesset**: Analysis of the 2022 Israeli election results
- **Hanukkah of Data 5783**: Solving data puzzles in R (alternative to Advent of Code)

## Technology Stack

- **Quarto**: Static site generator for technical content
- **R**: Primary language for data analysis and visualization
- **Python**: Supporting language for data processing
- **CSS**: Custom styling for enhanced presentation

## Local Development

To run this blog locally:

1. **Install Quarto**: Download from https://quarto.org/docs/get-started/
2. **Install R**: Download from https://cran.r-project.org/
3. **Install Python dependencies**: This project uses `uv` for Python package management
   ```bash
   uv sync
   ```
4. **Clone this repository**:
   ```bash
   git clone git@gitlab.com:gfrmin/blog-quarto.git
   cd blog-quarto
   ```
5. **Start the development server**:
   ```bash
   quarto preview
   ```
6. **Build the site**:
   ```bash
   quarto render
   ```

## Project Structure

```
blog-quarto/
├── _quarto.yml           # Quarto configuration file
├── index.qmd             # Homepage content
├── about.qmd             # About page
├── posts/                # Blog posts directory
│   ├── _metadata.yml     # Posts metadata
│   ├── bechirot/         # Election analysis post
│   └── hanukkah-of-code/ # Data puzzles post
├── docs/                 # Documentation directory
│   └── memory-bank/      # Memory bank documentation
├── styles.css            # Custom CSS styling
├── profile.jpg           # Profile image
├── main.py               # Python utility script
├── pyproject.toml        # Python project configuration
├── uv.lock               # Python dependency lock file
├── _site/                # Generated site (gitignored)
├── _freeze/              # Quarto cache (gitignored)
```

## Dependencies

### Python Dependencies
Managed via `pyproject.toml` and `uv`:
- `jupyter>=1.1.1` - Jupyter notebook support
- `matplotlib>=3.10.3` - Plotting library
- `plotly>=6.1.2` - Interactive visualizations

### R Dependencies
Install required R packages:
```r
install.packages(c("tidyverse", "ggplot2", "dplyr", "readr"))
```

## Contributing

This is a personal blog, but suggestions and feedback are welcome! Feel free to:
- Open issues for bugs or suggestions
- Submit pull requests for improvements
- Reach out with questions about the analysis

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

- **GitHub**: [@gfrmin](https://github.com/gfrmin)
- **Twitter**: [@gfrmin](https://twitter.com/gfrmin)

---

*Built with ❤️ using Quarto*
