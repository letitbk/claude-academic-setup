---
name: viz
description: Use when creating or revising any chart, plot, figure, or data visualization, including requests to graph, visualize, make a figure, or improve an existing chart.
---

# Data visualization

Build a figure that answers a clear question, matches the text it supports, and survives inspection of the exported file.

## Before plotting

- Confirm the audience, the comparison, the output format, and any journal or slide constraints. Ask once about all the visual choices you cannot infer, e.g., layout, interval type, and size, instead of fixing them one draft at a time.
- Run `datacheck` first if the data is new.
- Write down the sample, the N, and the quantity each panel shows. Check that they match what the text and caption claim, e.g., one study arm rather than all arms pooled.
- When you revise a figure, keep the user's chart type. Offer a different design as a separate option file and let the user choose.

Choose the simplest chart that matches the task:

| Question | Good default |
|---|---|
| Compare categories | Ordered point or bar chart |
| Show a distribution | Histogram, density, violin, or box plot |
| Show change over time | Line chart |
| Show association | Scatterplot with an appropriate fit |
| Show estimates | Dot and whisker or forest plot, with small multiples for many groups |
| Show composition | Stacked bars only when part-to-whole comparison is clear |

## Build

- Make every figure from a script in the project that saves it to disk. Do not leave a figure only in a notebook or plot pane.
- Make each axis title and annotation name the statistic actually plotted, e.g., odds ratios on an odds ratio axis, and r rather than R². State the direction of any difference and use it in every figure.
- Use the survey item's wording or a plain label, never a raw variable name.
- Use one shared theme and one shared scale for each paper, so each group keeps the same color and shape in every panel and figure. Set category order once, on the full data.
- Show every category in every figure. Mark sparse cells instead of dropping them.
- Show uncertainty when the estimate has uncertainty, and say which interval it is. When significance matters, show it with fill or line type as well as the interval.
- Make the figure readable in grayscale and for colorblind readers. Pair color with shape or line type.
- Avoid 3D effects, dual axes, and decorative backgrounds unless the user asks for them.

Unless the project sets other defaults, use R with ggplot2 and `theme_minimal(base_size = 12)`. Save a vector PDF and a 300 dpi PNG preview at the final size, e.g., one journal column wide.

## Export

- Use a device that works without a display, such as `ragg` or `cairo`, with a white background, not a transparent one. Embed fonts in PDFs, e.g., with `cairo_pdf`.
- Use plain ASCII hyphens and minus signs in labels unless you have checked that the font renders the others.
- Long labels become short names, and the full wording goes in the caption. Keep legends to a few breaks.

## Verify after every change

- Open the exported file at its final size, not the plot pane. Check for clipped or overlapping text, crowded legends, wrong category order, empty groups, and missing fonts.
- Run `pdftotext` on a PDF and search it for raw variable names or other internal labels.
- Compare a few plotted values with the summary table they come from.
- If a document embeds the figure, rebuild the figure, then render the document again. Check that the document shows the new version, that every saved figure is used, and that captions are not duplicated. In pandoc, leave the image alt text empty when a separate caption exists.

Report the source data, the script, the output files, and the checks you ran. Use `journal-figures`, from the journal-style repository, when a finished figure must meet a journal's submission rules.
