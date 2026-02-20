---
name: marginaleffects
description: Computation of marginal effects, comparisons, and predictions using the marginaleffects R package. Use when computing AMEs, factor contrasts, continuous contrasts, or predicted values from regression models. NOT for plotting (use /marginal-effects-plot or /coefficient-plot).
---

# marginaleffects

Compute marginal effects, comparisons, and predictions in R. This skill covers computation only — for plotting, use `/marginal-effects-plot` or `/coefficient-plot`.

Reference: https://marginaleffects.com/

## Three Core Functions

| Function | What it computes | When to use |
|----------|-----------------|-------------|
| `avg_slopes()` / `slopes()` | Partial derivatives (instantaneous rate of change) | Continuous variables: "effect of a 1-unit increase" |
| `avg_comparisons()` / `comparisons()` | Discrete changes (finite differences) | Factor contrasts OR custom continuous contrasts |
| `avg_predictions()` / `predictions()` | Predicted values at observed or specified data | "What's the predicted outcome for group X?" |

The `avg_*` versions average across observations (AMEs). The non-`avg_` versions return observation-level estimates.

## Quick Start

```r
library(marginaleffects)
library(data.table)

model <- glm(y ~ x1 + x2 + factor(group), data = df, family = binomial)

# Average marginal effects (continuous vars = slopes, factors = contrasts)
avg_slopes(model, type = "response")

# Pairwise factor contrasts
avg_comparisons(model, variables = list(group = "pairwise"), type = "response")

# Predicted probabilities by group
avg_predictions(model, by = "group", type = "response")
```

## Patterns by Model Type

### OLS: lm()

```r
model <- lm(y ~ x1 + x2 + factor(treatment), data = df)

# AMEs — straightforward, no type argument needed
avg_slopes(model)

# Factor contrasts (pairwise)
avg_comparisons(model, variables = list(treatment = "pairwise"))

# Contrast against reference level (default behavior)
avg_comparisons(model, variables = list(treatment = "reference"))

# Robust SEs
avg_slopes(model, vcov = "HC3")
```

### Logit/Probit: glm()

```r
model <- glm(y ~ x1 + factor(treatment), data = df, family = binomial)

# AMEs on probability scale — ALWAYS specify type = "response"
avg_slopes(model, type = "response")

# Factor contrasts on probability scale
avg_comparisons(model, variables = list(treatment = "pairwise"), type = "response")

# Predictions on probability scale
avg_predictions(model, by = "treatment", type = "response")

# Clustered SEs
avg_slopes(model, type = "response", vcov = ~cluster_id)
```

### Survey-weighted: svyglm()

```r
library(survey)
# Set up design first (see /survey-analysis)
des <- svydesign(~1, weights = ~wt, data = df)
model <- svyglm(y ~ x1 + factor(group), design = des, family = quasibinomial)

# AMEs — svyglm handles variance correctly, no extra vcov needed
avg_slopes(model, type = "response")

# Factor contrasts
avg_comparisons(model, variables = list(group = "pairwise"), type = "response")
```

### Fixed effects: fixest

```r
library(fixest)
model <- feols(y ~ x1 + x2 | state + year, data = df)

# AMEs with clustered SEs — use vcov from the model
avg_slopes(model)  # inherits feols default vcov

# Override vcov explicitly
avg_slopes(model, vcov = ~state)

# feglm (logit with FE)
model_logit <- feglm(y ~ x1 | state, data = df, family = binomial)
avg_slopes(model_logit, type = "response")
```

## Comparisons: Factor Contrasts

```r
# Pairwise: every level vs every other level
avg_comparisons(model, variables = list(treatment = "pairwise"))

# Reference: every level vs reference (base) level
avg_comparisons(model, variables = list(treatment = "reference"))

# Sequential: each level vs previous level
avg_comparisons(model, variables = list(treatment = "sequential"))

# Specific contrast: level "B" minus level "A"
avg_comparisons(model, variables = list(treatment = c("A", "B")))
```

## Comparisons: Continuous Contrasts

```r
# 1 SD change
avg_comparisons(model, variables = list(age = "sd"))

# Custom change: +10 units
avg_comparisons(model, variables = list(age = 10))

# IQR change
avg_comparisons(model, variables = list(age = "iqr"))

# Mean +/- 0.5 SD
avg_comparisons(model, variables = list(age = "2sd"))

# Custom function: from 25th to 75th percentile
avg_comparisons(model, variables = list(
  age = \(x) data.frame(low = quantile(x, 0.25), high = quantile(x, 0.75))
))
```

## Subgroup Effects

```r
# AMEs by subgroup
avg_slopes(model, by = "gender")

# Comparisons by subgroup
avg_comparisons(model, variables = list(treatment = "pairwise"), by = "age_group")

# Predictions by two grouping variables
avg_predictions(model, by = c("treatment", "gender"))
```

## Hypothesis Tests

```r
# Test if AME of x1 equals AME of x2
avg_slopes(model, hypothesis = "x1 = x2")

# Test if AME differs from specific value
avg_slopes(model, hypothesis = "x1 = 0.5")
```

## Output Handling

```r
# Default output is a data.frame — convert to data.table
ames <- as.data.table(avg_slopes(model, type = "response"))

# Key columns: term, estimate, std.error, conf.low, conf.high, p.value

# Prepare for /marginal-effects-plot or /coefficient-plot
setnames(ames, c("conf.low", "conf.high", "p.value"),
               c("conf_low", "conf_high", "p_value"))
```

## Common Mistakes

1. **Forgetting `type = "response"` for logit/probit** — without it, you get effects on the log-odds scale
2. **Wrong vcov for fixest** — `feols` default is clustered by first FE; override with `vcov = "HC1"` if you want heteroskedasticity-robust instead
3. **Confusing slopes vs comparisons** — `slopes` = derivatives (for continuous); `comparisons` = discrete changes (for factors AND custom continuous contrasts)
4. **Not specifying contrast type for factors** — default is "reference"; use "pairwise" if you want all pairs
5. **Using `datagrid()` when you don't need it** — `avg_slopes` and `avg_comparisons` average over observed data by default, which is usually what you want (AMEs)

## Cross-Skill Integration

- After computing effects → use `/marginal-effects-plot` or `/coefficient-plot` to visualize
- For survey-weighted models → use `/survey-analysis` to set up svydesign first
- For IPW/propensity weights → use `/compute-survey-weights`
