---
name: coefficient-plot
description: Create publication-ready coefficient plots with significance coloring and category faceting in R ggplot2. Use when visualizing regression results, marginal effects, or any estimates with confidence intervals.
---

# Coefficient Plot

A skill for creating coefficient plots in R using ggplot2. These plots display point estimates with confidence intervals, colored by significance and direction, with optional faceting by outcome category.

## Quick Start

```r
library(data.table)
library(ggplot2)

# Your data should have: estimate, conf_low, conf_high, p_value, label, category
p <- ggplot(dt, aes(x = estimate, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = conf_low, xmax = conf_high, color = color_label)) +
  facet_grid(category ~ ., scales = "free_y", space = "free_y") +
  theme_bw()
```

## Required Data Structure

Your data.table/data.frame should contain:

| Column | Description |
|--------|-------------|
| `estimate` | Point estimate (coefficient, marginal effect) |
| `conf_low` | Lower bound of confidence interval |
| `conf_high` | Upper bound of confidence interval |
| `p_value` | P-value for significance testing |
| `label` | Display label for the variable/outcome |
| `category` | (Optional) Category for faceting |

## Complete Template

```r
#!/usr/bin/env Rscript
# Purpose: Create coefficient plot for regression results

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(rio)
})

# Read the marginal effects/coefficients
dt <- as.data.table(import("your_results.csv"))
setnames(dt, tolower(names(dt)))

# Create nice labels for outcomes (customize as needed)
outcome_labels <- c(
  var1 = "Variable 1 Label",
  var2 = "Variable 2 Label",
  var3 = "Variable 3 Label"
)

# Create outcome categories for grouping (customize as needed)
outcome_categories <- c(
  var1 = "Category A",
  var2 = "Category A",
  var3 = "Category B"
)

# Define category ordering
category_levels <- c("Category A", "Category B")

# Add labels and categories
dt[, label := outcome_labels[outcome]]
dt[, category := factor(outcome_categories[outcome], levels = category_levels)]

# Create significance and direction indicators
dt[, signif := fifelse(p_value < 0.05, "Significant", "Not significant")]
dt[, effect_dir := fifelse(estimate > 0, "Positive", "Negative")]
dt[, color_label := fifelse(
  signif == "Significant",
  paste(effect_dir, "sig"),
  paste(effect_dir, "insig")
)]
dt[, color_label := factor(
  color_label,
  levels = c("Positive sig", "Negative sig", "Positive insig", "Negative insig")
)]

# Order outcomes by category and effect size within category
setorder(dt, category, -estimate)
label_levels <- unique(dt$label)
dt[, label := factor(label, levels = rev(label_levels))]

# Create the coefficient plot
p <- ggplot(dt, aes(x = estimate, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(
    aes(
      xmin = conf_low,
      xmax = conf_high,
      color = color_label,
      linetype = signif
    ),
    size = 0.6
  ) +
  facet_grid(category ~ ., scales = "free_y", space = "free_y") +
  scale_color_manual(
    values = c(
      "Positive sig" = "#2b8cbe",
      "Negative sig" = "#b2182b",
      "Positive insig" = "#a6cee3",
      "Negative insig" = "#fbb4b9"
    ),
    name = "Direction & significance"
  ) +
  scale_linetype_manual(
    values = c("Significant" = "solid", "Not significant" = "dotted"),
    name = "p < 0.05"
  ) +
  theme_bw() +
  labs(
    x = "Effect size (units)",
    y = NULL
  ) +
  theme(
    legend.position = "bottom",
    axis.text.y = element_text(color = "black", size = 10),
    strip.text.y = element_text(angle = 0, hjust = 0),
    strip.background = element_rect(fill = "grey90"),
    panel.spacing = unit(0.5, "lines")
  )

# Save the plot
ggsave("coefficient_plot.png", p, width = 8, height = 7, dpi = 300)
```

## Color Schemes

### Standard Blue/Red Scheme (Positive = Blue, Negative = Red)
```r
scale_color_manual(
  values = c(
    "Positive sig" = "#2b8cbe",      # Strong blue
    "Negative sig" = "#b2182b",      # Strong red
    "Positive insig" = "#a6cee3",    # Light blue
    "Negative insig" = "#fbb4b9"     # Light red
  )
)
```

### Three-Level Significance (p < 0.05, p < 0.1, NS)
```r
# Create 6-level color label
dt[, color_label := ifelse(p_value < 0.05, paste(effect_dir, "sig (p < 0.05)"),
                    ifelse(p_value < 0.1,  paste(effect_dir, "sig (p < 0.1)"),
                                           paste(effect_dir, "insig (p >= 0.1)")))]

scale_color_manual(
  values = c(
    "Positive sig (p < 0.05)" = "#2b8cbe",
    "Negative sig (p < 0.05)" = "#b2182b",
    "Positive sig (p < 0.1)" = "#a6cee3",
    "Negative sig (p < 0.1)" = "#fbb4b9",
    "Positive insig (p >= 0.1)" = "grey50",
    "Negative insig (p >= 0.1)" = "grey50"
  )
)
```

## Common Variations

### Without Facets (Single Panel)
```r
p <- ggplot(dt, aes(x = estimate, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = conf_low, xmax = conf_high, color = color_label)) +
  scale_color_manual(values = c("Positive sig" = "#2b8cbe", ...)) +
  theme_bw()
```

### Multiple Model Comparison
```r
# If you have multiple models, use facet_wrap
p <- ggplot(dt, aes(x = estimate, y = label)) +
  geom_pointrange(aes(xmin = conf_low, xmax = conf_high, color = color_label)) +
  facet_wrap(~ model, ncol = 2) +
  theme_bw()
```

### Horizontal Coefficient Plot
```r
# Flip coordinates for horizontal layout
p <- p + coord_flip()
```

## Export Options

```r
# PNG (for presentations)
ggsave("plot.png", p, width = 8, height = 7, dpi = 300)

# PDF (for publications)
ggsave("plot.pdf", p, width = 8, height = 7)

# High-resolution for journals
ggsave("plot.tiff", p, width = 8, height = 7, dpi = 600)
```

## Integration with Stata Output

If your coefficients come from Stata's `esttab`:

```r
# Read CSV exported from Stata
dt <- fread("stata_results.csv")

# Stata esttab typically outputs: b, se, t, pvalue, ll, ul (or ci_l, ci_u)
# Rename to standard column names
setnames(dt, c("b", "ci_l", "ci_u", "pvalue"),
             c("estimate", "conf_low", "conf_high", "p_value"))
```

## Tips

1. **Order matters**: Use `setorder()` to arrange outcomes logically before creating factor levels
2. **Reference line**: Always include `geom_vline(xintercept = 0)` for null hypothesis reference
3. **Free scales**: Use `scales = "free_y", space = "free_y"` in `facet_grid()` for proportional spacing
4. **Legend position**: `legend.position = "bottom"` works best for vertical coefficient plots
5. **Font size**: Adjust `axis.text.y = element_text(size = ...)` based on number of outcomes
