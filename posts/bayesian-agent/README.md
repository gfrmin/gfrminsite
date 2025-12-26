# Visual Assets Needed for Bayesian Agent Blog Post

This directory contains the blog post for the Bayesian Agent project. The post is complete, but the following visual assets still need to be created:

## Required Assets

### 1. og-image.png (REQUIRED)
- **Purpose**: Social media preview image (Open Graph)
- **Recommendation**: Screenshot of the simulation running in terminal
- **Alternative**: Diagram showing belief distributions converging over time
- **Size**: Suggested 1200×630 pixels for optimal social sharing

**How to create**:
```bash
# Run the simulation
cd ~/git/bayesian-agent
uv run main.py

# Capture a screenshot of the terminal showing:
# - Grid world with agent (@) and foods (●, ■, ▲)
# - Belief summary table
# - Agent stats (energy, steps, etc.)

# Save as og-image.png in this directory
```

### 2. demo.gif (HIGHLY RECOMMENDED)
- **Purpose**: Animated demonstration embedded in the blog post
- **Shows**: Agent moving, eating foods, beliefs updating in real-time
- **Duration**: 10-15 seconds
- **Content**: Watch the agent learn from random wandering to purposeful food selection

**How to create**:
```bash
# Option 1: Use asciinema + agg
asciinema rec -c "cd ~/git/bayesian-agent && uv run main.py" demo.cast
agg demo.cast demo.gif

# Option 2: Use terminalizer
terminalizer record demo
terminalizer render demo -o demo.gif

# Option 3: Screen recording tool
# - Start screen recording
# - Run: cd ~/git/bayesian-agent && uv run main.py
# - Let it run for 10-15 seconds
# - Stop recording and convert to GIF
```

## Optional Assets

### 3. belief-convergence.png (OPTIONAL)
- **Purpose**: Static diagram showing how posterior distributions narrow
- **Shows**: 3-4 panels of a belief distribution before/after observations
- **Example**: Prior N(0, 10) → +1 obs → +5 obs → +20 obs

**How to create** (if desired):
```python
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import norm

fig, axes = plt.subplots(1, 4, figsize=(12, 3))
observations = [0, 1, 5, 20]

for i, n_obs in enumerate(observations):
    # Simulate belief convergence
    if n_obs == 0:
        mean, var = 0.0, 10.0
    else:
        # Simple update assuming observed values around 2.5
        mean = (0.1 * 0.0 + n_obs * 2.5) / (0.1 + n_obs)
        var = 10.0 / (1 + n_obs / 0.1)

    x = np.linspace(mean - 3*np.sqrt(var), mean + 3*np.sqrt(var), 100)
    axes[i].plot(x, norm.pdf(x, mean, np.sqrt(var)))
    axes[i].set_title(f'After {n_obs} obs')
    axes[i].set_xlabel('Energy')

plt.tight_layout()
plt.savefig('belief-convergence.png', dpi=150)
```

## Current Status

- [x] Blog post written (index.qmd)
- [ ] og-image.png created
- [ ] demo.gif created
- [ ] belief-convergence.png created (optional)

## Notes

The blog post references these images:
- `og-image.png` in frontmatter (required for all posts)
- `demo.gif` in "The Demo" section (line ~34 of index.qmd)
- Optional: Could add `belief-convergence.png` in "The Math" section

Once you create the images, just save them in this directory. Quarto will automatically find and include them when rendering the site.
