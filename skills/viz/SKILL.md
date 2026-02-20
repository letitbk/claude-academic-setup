---
name: viz
description: Use when creating any data visualization, chart, figure, or plot. Also use when the user asks to "plot", "graph", "visualize", "make a figure", or refine an existing chart.
---

# Data Visualization

Create publication-ready figures using ggplot2 in R. Validate data and gather all visual requirements before generating the first plot.

## When to Use

- Creating any chart, figure, or plot
- Refining an existing visualization (spacing, labels, colors, layout)
- User says "plot", "graph", "visualize", "figure", "chart"

## When NOT to Use

- Quick exploratory `plot()` or `hist()` for debugging (just do it)
- User explicitly asks for base R graphics

## Core Rule

**Ask about ALL visual elements upfront before generating the first plot.** Do not produce a draft and iterate one tweak at a time.

## Workflow

### Step 1: Validate Data

Before any plotting code, confirm:

1. **Read the data** and print column names, types, and 3-5 sample rows
2. **Confirm column mappings** with the user: which columns map to x, y, color, facet, etc.
3. **Check for issues**: NAs in plot variables, unexpected factor levels, wrong types

Do NOT guess column mappings silently. If ambiguous, ask.

### Step 2: Gather Visual Requirements

Ask about ALL of these before the first plot:

| Element | Ask about | Default if not specified |
|---------|-----------|------------------------|
| Chart type | bar, coef/forest, line, network, other | Infer from data structure |
| Layout | single panel, faceted, multi-panel | Single panel |
| Axes | labels, limits, breaks, log scale | Auto with clear labels |
| Colors | palette, specific mappings | Colorblind-safe, clean |
| Error bars | SE, 95% CI, none | 95% CI when applicable |
| Legend | position, title, label text | Right side, auto title |
| Separators | lines between groups | None unless grouped |
| Text | title, subtitle, caption, annotations | Minimal |
| Dimensions | width x height in inches | 7 x 5 |

### Step 3: Build the Plot

**Language:** R with ggplot2. Always.

**Theme baseline:**
```r
theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    strip.text = element_text(face = "bold"),
    legend.position = "bottom"
  )
```

**Color palette:** Colorblind-safe. No strong default - pick appropriate per chart:
- Categorical (2-8 groups): `scale_color_brewer(palette = "Set2")` or similar
- Sequential: `scale_fill_viridis_c()`
- Diverging: `scale_fill_distiller(palette = "RdBu")`

**Multi-panel approach:**
- Same chart type across panels: `facet_wrap()` / `facet_grid()`
- Different chart types combined: `patchwork` package

### Step 4: Chart-Specific Patterns

#### Bar Charts
```r
ggplot(df, aes(x = group, y = estimate, fill = condition)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                position = position_dodge(width = 0.8), width = 0.2) +
  # 95% CI error bars by default
```

#### Coefficient / Forest Plots
```r
ggplot(df, aes(x = estimate, y = reorder(term, estimate))) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 2) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high), height = 0.2)
```

Input sources (handle all three):
- **R model objects**: Use `broom::tidy(conf.int = TRUE)` or `marginaleffects::avg_slopes()`
- **Stata margins output**: Parse CSV/text from `margins` or `esttab` export
- **Pre-computed CSV**: Expect columns: `term`, `estimate`, `ci_low`, `ci_high`

#### Line / Time Series
```r
ggplot(df, aes(x = time, y = value, color = group)) +
  geom_line(linewidth = 0.8) +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high, fill = group), alpha = 0.15)
```

#### Network Graphs
Use **igraph** base plotting (not ggraph):
```r
library(igraph)
plot(g,
     vertex.size = degree(g) * 2,
     vertex.label.cex = 0.7,
     vertex.color = V(g)$color,
     edge.arrow.size = 0.3,
     layout = layout_with_fr(g))
```

### Step 5: Stata-to-R Pipeline

When combining Stata models with R visualization:

1. **In Stata**: Export estimates with `esttab using "estimates.csv", csv ci`
   or: `margins, post` then `matrix list e(b)`, `matrix list r(table)`
2. **In R**: Parse the CSV, clean column names, build ggplot

```r
# Parse Stata esttab CSV output
est <- read.csv("estimates.csv", skip = 1)  # skip header row
# Clean: remove significance stars, convert to numeric
est$estimate <- as.numeric(gsub("[*]", "", est$estimate))
```

### Step 6: Save Output

Always save both formats:
```r
ggsave("figure.png", width = 7, height = 5, dpi = 300)
ggsave("figure.pdf", width = 7, height = 5)
```

Adjust dimensions based on content:
- Single panel: 7 x 5
- Two panels side by side: 10 x 5
- Tall coefficient plot (many terms): 7 x 8
- Network graph: 7 x 7

## Quick Reference

| Chart type | Key geom | Error bars | Default |
|------------|----------|------------|---------|
| Bar | `geom_col` + `position_dodge` | `geom_errorbar` (95% CI) | Dodged, 0.7 width |
| Coefficient | `geom_point` + `geom_errorbarh` | Built-in (CI) | Horizontal, ref line at 0 |
| Line | `geom_line` + `geom_ribbon` | `geom_ribbon` (CI band) | 0.15 alpha ribbon |
| Network | `igraph::plot()` | N/A | Fruchterman-Reingold layout |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Guessing column names | Always read data first, confirm with user |
| Iterating one tweak at a time | Ask about ALL visual elements before first plot |
| Using `theme_gray()` default | Always start with `theme_minimal(base_size = 12)` |
| Forgetting `position_dodge` on error bars | Error bars must match bar dodge width exactly |
| Network plots with ggraph when user expects igraph | Default to igraph base `plot()` |
| Not saving both PNG and PDF | Always `ggsave()` both formats |
| Wrong dimensions for multi-panel | Scale width with number of panels |
| Parsing Stata output without cleaning stars | Strip `*`, `**`, `***` before `as.numeric()` |
