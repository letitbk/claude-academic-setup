---
name: viz
description: Use when creating or revising any chart, plot, figure, or data visualization, including requests to graph, visualize, make a figure, or improve an existing chart.
---

# Data visualization

Build a figure that answers a clear question and survives visual inspection.

## Before plotting

Confirm the audience, comparison, output format, and any journal or presentation constraints. Ask only for choices that cannot be learned from the data or project. If the data is new, run `datacheck` first.

Choose the simplest chart that matches the task:

| Question | Good default |
|---|---|
| Compare categories | Ordered point or bar chart |
| Show a distribution | Histogram, density, violin, or box plot |
| Show change over time | Line chart |
| Show association | Scatterplot with an appropriate fit |
| Show estimates | Coefficient or interval plot |
| Show composition | Stacked bars only when part-to-whole comparison is clear |

## Build and verify

- Use readable labels and units. Avoid raw variable names in the final figure.
- Show uncertainty when the estimate has uncertainty.
- Do not rely on color alone. Prefer a colorblind-safe palette with shape, line, or label redundancy when needed.
- Avoid 3D effects, dual axes, decorative backgrounds, and legends that make the reader decode the chart.
- Save with explicit dimensions. Prefer vector output for line art and high-resolution raster only when needed.
- Open the exported figure. Check clipping, overlap, ordering, empty groups, legends, fonts, and whether the plotted values match the underlying summary.

Report the source data, code path, output path, and the checks performed. Use `journal-figures` when a finished plot must meet a journal's submission rules.
