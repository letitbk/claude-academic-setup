---
name: marginal-effects-plot
description: Visualize marginal effects from regression models with factor level parsing, reference category labeling, and multi-panel layouts using R ggplot2. Use when plotting AMEs from Stata margins or R marginaleffects output.
---

# Marginal Effects Plot

A skill for creating publication-ready marginal effects plots in R using ggplot2. Handles factor variable parsing (e.g., "2.race3" → base_var="race3", level="2"), reference category labeling, and multi-panel layouts.

## Quick Start

```r
library(data.table)
library(ggplot2)
library(haven)

# Read marginal effects (e.g., from Stata margins export)
effects <- as.data.table(import("marginal_effects.csv"))

# Create plot with facets
p <- ggplot(effects, aes(x = estimate, y = label)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_pointrange(aes(xmin = conf_low, xmax = conf_high, color = color_label)) +
  facet_grid(category ~ panel, scales = "free_y", space = "free_y") +
  theme_bw()
```

## Required Data Structure

| Column | Description |
|--------|-------------|
| `estimate` | Marginal effect point estimate |
| `conf_low` | Lower confidence bound |
| `conf_high` | Upper confidence bound |
| `p_value` | P-value |
| `term` | Variable name (may include factor notation like "2.race3") |
| `base_var` | Base variable name (extracted from factor notation) |
| `level` | Factor level (extracted from factor notation) |
| `base_flag` | Indicator for reference category (1 = reference) |

## Complete Template

```r
#!/usr/bin/env Rscript
# Purpose: Plot marginal effects from regression models

suppressPackageStartupMessages({
  library(data.table)
  library(ggplot2)
  library(rio)
  library(haven)
})

# Read marginal effects
effects <- as.data.table(import("marginal_effects.csv"))
setnames(effects, tolower(names(effects)))

# Read original data to get value labels (if from Stata)
dt_labels <- as.data.table(haven::read_dta("data.dta"))

# Function to extract value labels from Stata data
get_value_labels <- function(df, var) {
  lbl <- attr(df[[var]], "labels")
  if (is.null(lbl)) return(NULL)
  setNames(names(lbl), as.character(unname(lbl)))
}

# Get labels for your factor variables
value_labels <- list(
  race3 = get_value_labels(dt_labels, "race3"),
  gender = get_value_labels(dt_labels, "gender"),
  educ3 = get_value_labels(dt_labels, "educ3")
)

# Variable display labels
var_labels <- c(
  age_sd = "Age (per 1 SD)",
  race3 = "Race/Ethnicity",
  gender = "Gender",
  educ3 = "Education",
  income_sd = "Income (per 1 SD)"
)

# Variable categories for faceting
var_categories <- c(
  age_sd = "Demographics",
  race3 = "Demographics",
  gender = "Demographics",
  educ3 = "Socioeconomic",
  income_sd = "Socioeconomic"
)

category_levels <- c("Demographics", "Socioeconomic")

# Prepare labels function
prep_labels <- function(dt) {
  dt[, level_label := as.character(level_label)]
  dt[, ref_label := as.character(ref_label)]
  dt[, base_var := fifelse(!is.na(base_var), base_var, term)]
  dt[, var_label := var_labels[base_var]]
  dt[is.na(var_label), var_label := base_var]
  dt[, level := as.character(level)]

  # Function to look up labels
  label_lookup <- function(bv, lvl) {
    lab <- value_labels[[bv]]
    if (is.null(lab) || is.na(lvl) || lvl == "") return("")
    if (lvl %in% names(lab)) lab[[lvl]] else ""
  }

  # Apply level labels
  dt[, level_label := fifelse(level_label != "" & !is.na(level_label),
    level_label,
    mapply(label_lookup, base_var, level)
  )]

  # Derive reference label per factor
  ref_map <- dt[
    base_flag == 1 & level != "" & !is.na(level),
    .(ref_level = level[1]),
    by = base_var
  ]
  dt[, ref_by_var := ""]
  dt[ref_map, on = .(base_var), ref_by_var := mapply(label_lookup, base_var, i.ref_level)]

  # Remove base/reference rows
  dt <- dt[!(base_flag == 1 & level != "" & !is.na(level))]

  # Create contrast labels
  dt[, contrast_label := fifelse(level_label == "" | is.na(level_label), "", level_label)]
  dt[, label := fifelse(
    contrast_label == "",
    var_label,
    paste0(var_label, ": ", contrast_label,
           fifelse(ref_by_var != "" & !is.na(ref_by_var), paste0(" vs ", ref_by_var), ""))
  )]

  # Add category
  dt[, category := factor(var_categories[base_var], levels = category_levels)]

  # Significance coloring
  dt[, signif := fifelse(p_value < 0.05, "Significant (p < 0.05)", "Not significant")]
  dt[p_value < 0.1 & p_value >= 0.05, signif := 'Significant (p < 0.1)']

  dt[, effect_dir := fifelse(estimate > 0, "Positive", "Negative")]
  dt[, color_label := ifelse(signif == "Significant (p < 0.05)", paste(effect_dir, "sig (p < 0.05)"),
                      ifelse(signif == "Significant (p < 0.1)",  paste(effect_dir, "sig (p < 0.1)"),
                                                                paste(effect_dir, "insig (p >= 0.1)")))]
  dt[, color_label := factor(color_label, levels = c(
    "Positive sig (p < 0.05)", "Negative sig (p < 0.05)",
    "Positive sig (p < 0.1)", "Negative sig (p < 0.1)",
    "Positive insig (p >= 0.1)", "Negative insig (p >= 0.1)"
  ))]

  dt
}

effects <- prep_labels(effects)

# Order labels consistently
order_labels <- function(dt) {
  dt[, term_order := frank(base_var, ties.method = "dense")]
  setorder(dt, category, term_order, contrast_label, label)
  label_levels <- unique(dt$label)
  dt[, label := factor(label, levels = rev(label_levels))]
  dt
}

effects <- order_labels(effects)

# Create the plot
plot_me <- function(dt, title_text = NULL) {
  ggplot(dt, aes(x = estimate, y = label)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
    geom_pointrange(
      aes(xmin = conf_low, xmax = conf_high, color = color_label, linetype = signif)
    ) +
    facet_grid(category ~ ., scales = "free_y", space = "free_y") +
    scale_color_manual(
      values = c(
        "Positive sig (p < 0.05)" = "#2b8cbe",
        "Negative sig (p < 0.05)" = "#b2182b",
        "Positive sig (p < 0.1)" = "#a6cee3",
        "Negative sig (p < 0.1)" = "#fbb4b9",
        "Positive insig (p >= 0.1)" = "grey50",
        "Negative insig (p >= 0.1)" = "grey50"
      ),
      name = "Direction & significance"
    ) +
    scale_linetype_manual(
      values = c("Significant (p < 0.05)" = "solid",
                 "Significant (p < 0.1)" = "dashed",
                 "Not significant" = "dotted"),
      name = "Significance level"
    ) +
    theme_bw() +
    labs(x = "Average marginal effect", y = NULL, title = title_text) +
    theme(
      legend.position = "bottom",
      axis.text.y = element_text(color = "black")
    )
}

p <- plot_me(effects)
ggsave("marginal_effects.png", p, width = 10, height = 6, dpi = 300)
```

## Parsing Stata Factor Notation

Stata exports factor variables as "2.race3" (level 2 of race3). Parse these:

```r
# Parse factor notation from term column
parse_factor_term <- function(term) {
  if (grepl("^[0-9]+\\.", term)) {
    parts <- strsplit(term, "\\.")[[1]]
    list(level = parts[1], base_var = parts[2])
  } else {
    list(level = "", base_var = term)
  }
}

# Apply to data
dt[, c("level", "base_var") := {
  parsed <- lapply(term, parse_factor_term)
  list(sapply(parsed, `[[`, "level"), sapply(parsed, `[[`, "base_var"))
}]
```

## Multi-Panel Layout (e.g., ZIP model components)

```r
# For models with multiple components (count + inflation)
dt[, panel := factor(panel,
  levels = c("Panel A: Pr(0)", "Panel B: Expected count"),
  labels = c("Panel A: Probability of Zero", "Panel B: Conditional Count")
)]

p <- ggplot(dt, aes(x = estimate, y = label)) +
  geom_pointrange(...) +
  facet_grid(category ~ panel, scales = "free_y", space = "free_y") +
  theme_bw()
```

## Integration with Stata margins Output

In Stata, export margins results for R plotting:

```stata
* Run regression
svy: regress outcome i.treatment controls

* Calculate AMEs
margins, dydx(*) post

* Export to CSV
esttab using "margins_results.csv", ///
    cells(b(star fmt(3)) se(par fmt(3)) ci_l(fmt(3)) ci_u(fmt(3)) p(fmt(4))) ///
    csv replace noobs
```

## Integration with R marginaleffects Package

```r
library(marginaleffects)

# Fit model
model <- lm(outcome ~ treatment + controls, data = df)

# Calculate AMEs
ames <- avg_slopes(model)

# Convert to data.table for plotting
dt <- as.data.table(ames)
setnames(dt, c("term", "estimate", "std.error", "conf.low", "conf.high", "p.value"),
             c("term", "estimate", "se", "conf_low", "conf_high", "p_value"))
```

## Tips

1. **Reference categories**: Always indicate what the comparison group is (e.g., "College vs High School")
2. **Continuous variables**: Note the scale (e.g., "per 1 SD increase")
3. **Panel order**: Use `factor(..., levels = ...)` to control facet ordering
4. **Long labels**: Use `\n` for line breaks in labels, or increase plot width
5. **Multiple models**: Use `facet_wrap(~ model)` or separate plots

## Common Issues

### Missing Labels
```r
# If value labels are missing, create them manually
value_labels$race3 <- c("1" = "White", "2" = "Black", "3" = "Hispanic")
```

### Factor Level Ordering
```r
# Ensure factors are ordered correctly
dt[, label := factor(label, levels = rev(unique(label)))]
```

### Overlapping Text
```r
# Adjust theme for more space
theme(
  axis.text.y = element_text(size = 8),
  strip.text = element_text(size = 9)
)
```
