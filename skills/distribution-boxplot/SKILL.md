---
name: distribution-boxplot
description: Create boxplots with custom statistics by group using R ggplot2. Use for comparing distributions across categories, showing median, quartiles, and range with reference lines.
---

# Distribution Boxplot

A skill for creating custom boxplots in R using ggplot2. Supports manual calculation of box statistics, reference lines, and faceted layouts for comparing distributions across groups.

## Quick Start

```r
library(data.table)
library(ggplot2)

# Calculate statistics manually for custom boxes
stats <- dt[, .(
  xmin = min(value, na.rm = TRUE),
  lower = quantile(value, 0.25, na.rm = TRUE),
  middle = median(value, na.rm = TRUE),
  upper = quantile(value, 0.75, na.rm = TRUE),
  xmax = max(value, na.rm = TRUE)
), by = group]

# Create boxplot
p <- ggplot(stats, aes(y = group)) +
  geom_rect(aes(xmin = lower, xmax = upper, ymin = y - 0.4, ymax = y + 0.4), fill = "grey") +
  geom_segment(aes(x = middle, xend = middle, y = y - 0.4, yend = y + 0.4)) +
  theme_bw()
```

## Complete Template: Horizontal Box with Whiskers

```r
#!/usr/bin/env Rscript
# Purpose: Create boxplots showing distribution by group

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
})

# Load data
dt <- readRDS("data.rds")

# Create grouping variable (e.g., age groups)
dt[, age_group := cut(age, breaks = c(17, 30, 40, 50, 60, 70, 85),
                      include.lowest = TRUE, right = TRUE)]

# Reshape to long format if needed
long_dt <- melt(
  dt[!is.na(age_group), .(id, age_group, var1, var2)],
  id.vars = c("id", "age_group"),
  variable.name = "measure",
  value.name = "value"
)

# Calculate box statistics
stats <- long_dt[, .(
  xmin = min(value, na.rm = TRUE),
  lower = quantile(value, 0.25, na.rm = TRUE),
  middle = median(value, na.rm = TRUE),
  upper = quantile(value, 0.75, na.rm = TRUE),
  xmax = max(value, na.rm = TRUE)
), by = .(age_group, measure)]

# Create y-position for plotting
stats[, y := as.numeric(as.factor(age_group))]

# Create nice labels for measures
stats[, measure := factor(measure,
  levels = c("var1", "var2"),
  labels = c("Variable 1 (units)", "Variable 2 (units)")
)]

# Create the boxplot
p <- ggplot(stats, aes(y = factor(age_group))) +
  # IQR box - left half (Q1 to median)
  geom_rect(
    aes(xmin = lower, xmax = middle, ymin = y - 0.4, ymax = y + 0.4),
    fill = "grey70",
    alpha = 0.7
  ) +
  # IQR box - right half (median to Q3)
  geom_rect(
    aes(xmin = middle, xmax = upper, ymin = y - 0.4, ymax = y + 0.4),
    fill = "grey30",
    alpha = 0.7
  ) +
  # Median line
  geom_segment(aes(x = middle, xend = middle, y = y - 0.4, yend = y + 0.4),
               color = "white", size = 1) +
  # Left whisker (min to Q1)
  geom_segment(aes(x = xmin, xend = lower, y = y, yend = y),
               color = "black") +
  # Right whisker (Q3 to max)
  geom_segment(aes(x = upper, xend = xmax, y = y, yend = y),
               color = "black") +
  # Reference line (e.g., null value, population mean)
  geom_vline(
    data = data.table(
      measure = c("Variable 1 (units)", "Variable 2 (units)"),
      xintercept = c(0, 1)  # Reference values per facet
    ),
    aes(xintercept = xintercept),
    color = "red",
    linetype = "dashed"
  ) +
  # Facet by measure
  facet_wrap(~ measure, scales = "free_x") +
  theme_bw() +
  labs(x = "Value", y = "Age Group")

# Save
ggsave("distribution_boxplot.png", p, width = 8, height = 5, dpi = 300)
```

## Standard ggplot2 Boxplot (Simpler Alternative)

```r
# If you don't need custom statistics, use geom_boxplot directly
p <- ggplot(long_dt, aes(x = value, y = age_group)) +
  geom_boxplot(fill = "grey70", outlier.shape = NA) +
  geom_vline(xintercept = 0, color = "red", linetype = "dashed") +
  facet_wrap(~ measure, scales = "free_x") +
  theme_bw()
```

## Variations

### Vertical Boxplots
```r
# Swap x and y aesthetics
p <- ggplot(stats, aes(x = factor(age_group))) +
  geom_rect(
    aes(ymin = lower, ymax = upper, xmin = x - 0.4, xmax = x + 0.4),
    fill = "grey"
  ) +
  geom_segment(aes(y = middle, yend = middle, x = x - 0.4, xend = x + 0.4))
```

### With Outlier Points
```r
# Calculate outliers separately
outliers <- long_dt[value < quantile(value, 0.25) - 1.5 * IQR(value) |
                    value > quantile(value, 0.75) + 1.5 * IQR(value),
                    .(age_group, measure, value)]

# Add to plot
p <- p +
  geom_point(data = outliers, aes(x = value, y = as.numeric(factor(age_group))),
             shape = 1, size = 1, alpha = 0.5)
```

### Colored by Subgroup
```r
# Add fill aesthetic for subgroups
stats[, subgroup := ifelse(middle > 0, "Above", "Below")]

p <- ggplot(stats, aes(y = factor(age_group))) +
  geom_rect(
    aes(xmin = lower, xmax = upper, ymin = y - 0.4, ymax = y + 0.4, fill = subgroup),
    alpha = 0.7
  ) +
  scale_fill_manual(values = c("Above" = "#2b8cbe", "Below" = "#b2182b"))
```

### With Mean and SD Annotation
```r
# Calculate additional statistics
stats[, mean_val := mean(value, na.rm = TRUE), by = .(age_group, measure)]
stats[, sd_val := sd(value, na.rm = TRUE), by = .(age_group, measure)]

# Add mean point
p <- p + geom_point(aes(x = mean_val, y = y), shape = 18, size = 3, color = "blue")
```

### Violin + Box Combination
```r
p <- ggplot(long_dt, aes(x = value, y = age_group)) +
  geom_violin(fill = "grey90", alpha = 0.5) +
  geom_boxplot(width = 0.2, fill = "white", outlier.shape = NA) +
  theme_bw()
```

## Adding Summary Statistics Text

```r
# Calculate summary for labels
summary_stats <- long_dt[, .(
  n = .N,
  mean = mean(value, na.rm = TRUE),
  median = median(value, na.rm = TRUE)
), by = .(age_group, measure)]

# Add n label
p <- p +
  geom_text(
    data = summary_stats,
    aes(x = Inf, y = as.numeric(factor(age_group)),
        label = paste0("n=", n)),
    hjust = 1.1, size = 3
  )
```

## Reference Lines for Different Facets

```r
# Create data.table with reference values per facet
ref_lines <- data.table(
  measure = c("DunedinPACE", "GrimAge Acceleration"),
  xintercept = c(1, 0)  # Different reference for each measure
)

p <- p +
  geom_vline(
    data = ref_lines,
    aes(xintercept = xintercept),
    color = "red",
    linetype = "dashed"
  )
```

## Themes and Polish

```r
# Publication-ready theme
p <- p +
  theme_bw() +
  theme(
    panel.grid.minor = element_blank(),
    strip.background = element_rect(fill = "grey90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(size = 11),
    axis.text = element_text(size = 10),
    legend.position = "bottom"
  )
```

## Tips

1. **Custom stats**: Calculate quartiles manually when you need non-standard boxplot statistics
2. **Reference lines**: Use `geom_vline()` with a separate data.table for facet-specific references
3. **Free scales**: Use `scales = "free_x"` in facets when measures have different units
4. **Box width**: Adjust the `0.4` in `y - 0.4, y + 0.4` to change box thickness
5. **Color palette**: Use consistent colors - grey scale for boxes, red for reference lines

## Common Issues

### Whiskers Extend Beyond Data Range
```r
# Cap whiskers at 1.5 * IQR
stats[, whisker_low := pmax(xmin, lower - 1.5 * (upper - lower))]
stats[, whisker_high := pmin(xmax, upper + 1.5 * (upper - lower))]
```

### Overlapping Group Labels
```r
# Rotate labels or use abbreviations
theme(axis.text.y = element_text(size = 8))
# Or use shorter labels in the factor levels
```

### Missing Groups
```r
# Ensure all groups appear even if empty
dt[, age_group := factor(age_group, levels = c("[17,30]", "(30,40]", ...))]
```
