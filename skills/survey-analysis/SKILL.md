---
name: survey-analysis
description: Design-based survey analysis in R using the survey package. Use for survey design setup, weighted descriptives, svyglm regression, raking, and calibration. NOT for IPW/propensity scores (use /compute-survey-weights).
---

# Survey Analysis

Design-based survey inference in R using the `survey` package. Covers setup, descriptives, regression, and raking. For IPW/propensity score weighting, use `/compute-survey-weights`.

## Survey Design Setup

### Simple weights only

```r
library(survey)
des <- svydesign(~1, weights = ~wt, data = df)
```

### Strata + weights

```r
des <- svydesign(~1, strata = ~strat, weights = ~wt, data = df)
```

### Full complex design (PSU + strata + weights)

```r
des <- svydesign(~psu, strata = ~strat, weights = ~wt, nest = TRUE, data = df)
```

### Always set this option

```r
# Handle singleton strata (one PSU per stratum)
options(survey.lonely.psu = "adjust")
```

## Common Survey Datasets

| Survey | Design |
|--------|--------|
| TESS | `svydesign(~1, weights = ~weight, data = df)` |
| GSS | `svydesign(~vpsu, strata = ~vstrat, weights = ~wtssall, nest = TRUE, data = df)` |
| NHIS | `svydesign(~psu_p, strata = ~strat_p, weights = ~wtfa_sa, nest = TRUE, data = df)` |
| BRFSS | `svydesign(~1, strata = ~_ststr, weights = ~_llcpwt, data = df)` |
| ACS/PUMS | `svrepdesign(weights = ~PWGTP, repweights = "PWGTP[0-9]+", type = "JK1", scale = 4/80, data = df)` |

For custom surveys: start with simple weights. Add strata/PSU only if the codebook documents them.

## Weighted Descriptives

### Means and proportions

```r
# Weighted mean + SE
svymean(~continuous_var, design = des, na.rm = TRUE)

# Weighted proportion (factor variable)
svymean(~factor(categorical_var), design = des, na.rm = TRUE)

# Confidence intervals
confint(svymean(~continuous_var, design = des, na.rm = TRUE))
```

### Totals and quantiles

```r
# Weighted total
svytotal(~continuous_var, design = des, na.rm = TRUE)

# Weighted quantiles
svyquantile(~continuous_var, design = des, quantiles = c(0.25, 0.5, 0.75), na.rm = TRUE)
```

### Subgroup estimates

```r
# Mean by group (like Stata: svy: mean var, over(group))
svyby(~outcome, ~group, design = des, FUN = svymean, na.rm = TRUE)

# Proportion by group
svyby(~factor(binary_var), ~group, design = des, FUN = svymean, na.rm = TRUE)

# Confidence intervals for subgroup estimates
confint(svyby(~outcome, ~group, design = des, FUN = svymean, na.rm = TRUE))
```

### Cross-tabulations

```r
# Weighted cross-tab (counts)
svytable(~var1 + var2, design = des)

# Chi-squared test
svychisq(~var1 + var2, design = des)
```

## Weighted Regression

### Linear regression

```r
fit <- svyglm(outcome ~ treatment + age + factor(race), design = des)
summary(fit)
```

### Logistic regression

```r
# Use quasibinomial (not binomial) with survey data
fit <- svyglm(binary_outcome ~ treatment + age + factor(race),
              design = des, family = quasibinomial)
summary(fit)
```

### Ordinal/multinomial

```r
library(svrepdesign)  # or use replicate weights
# For ordinal: svyolr() from survey package
fit <- svyolr(ordered_outcome ~ x1 + x2, design = des)
```

### Model comparison

```r
# Wald test for nested models (equivalent to Stata's testparm)
fit_full <- svyglm(y ~ x1 + x2 + x3, design = des)
regTermTest(fit_full, ~x2 + x3)

# Compare models
fit_reduced <- svyglm(y ~ x1, design = des)
anova(fit_reduced, fit_full)
```

### Pass to marginaleffects

```r
library(marginaleffects)

# AMEs from survey-weighted model (see /marginaleffects)
fit <- svyglm(y ~ x1 + factor(group), design = des, family = quasibinomial)
avg_slopes(fit, type = "response")
avg_comparisons(fit, variables = list(group = "pairwise"), type = "response")
```

## Raking and Calibration

### anesrake (preferred for iterative raking)

```r
library(anesrake)

# Define population margins
# Each target is a named numeric vector that sums to 1
targets <- list(
  gender = c("Male" = 0.48, "Female" = 0.52),
  age_group = c("18-29" = 0.21, "30-44" = 0.26, "45-59" = 0.25, "60+" = 0.28),
  race = c("White" = 0.60, "Black" = 0.13, "Hispanic" = 0.19, "Other" = 0.08)
)

# Variables must be factors with levels matching target names
df$gender <- factor(df$gender, levels = names(targets$gender))
df$age_group <- factor(df$age_group, levels = names(targets$age_group))
df$race <- factor(df$race, levels = names(targets$race))

# Rake
raked <- anesrake(
  inputter = targets,
  dataframe = df,
  caseid = df$id,
  cap = 5,           # max weight ratio (default 5)
  type = "nolim"     # "nolim", "pctlim", or "cap"
)

# Extract weights
df$raked_weight <- raked$weightvec

# Check convergence
summary(raked)
```

### autumn (alternative)

```r
library(autumn)

# Define margins as data.frames
margins <- list(
  data.frame(gender = c("Male", "Female"), Freq = c(0.48, 0.52)),
  data.frame(age_group = c("18-29", "30-44", "45-59", "60+"), Freq = c(0.21, 0.26, 0.25, 0.28))
)

# Rake
result <- harvest(df, margins)
df$raked_weight <- result$weights
```

### Weight trimming after raking

```r
# Trim at percentiles
q01 <- quantile(df$raked_weight, 0.01)
q99 <- quantile(df$raked_weight, 0.99)
df$trimmed_weight <- pmin(pmax(df$raked_weight, q01), q99)

# Or cap at X times the median
median_wt <- median(df$raked_weight)
df$capped_weight <- pmin(df$raked_weight, 5 * median_wt)
```

### Diagnostics after raking

```r
# Compare weighted vs target distributions
des_raked <- svydesign(~1, weights = ~raked_weight, data = df)

# Check each margin
svymean(~gender, design = des_raked)      # should match targets$gender
svymean(~age_group, design = des_raked)   # should match targets$age_group
svymean(~race, design = des_raked)        # should match targets$race

# Weight distribution
summary(df$raked_weight)
sd(df$raked_weight) / mean(df$raked_weight)  # CV — lower is better

# Design effect
deff <- 1 + var(df$raked_weight) / mean(df$raked_weight)^2
cat("Design effect:", round(deff, 2), "\n")

# Effective sample size
n_eff <- sum(df$raked_weight)^2 / sum(df$raked_weight^2)
cat("Effective N:", round(n_eff), "of", nrow(df), "\n")
```

## Common Mistakes

1. **Forgetting `nest = TRUE`** — required when PSU IDs restart within strata (e.g., PSU 1 in stratum A is different from PSU 1 in stratum B)
2. **Using `glm()` instead of `svyglm()`** — `glm()` ignores the survey design; SEs will be wrong
3. **Using `family = binomial` with `svyglm()`** — use `quasibinomial` to avoid warnings about non-integer weights
4. **Not setting `survey.lonely.psu`** — singleton strata cause errors; set `options(survey.lonely.psu = "adjust")` at the top of every script
5. **Applying weights before creating the design** — don't multiply weights into the data manually; let `svydesign()` handle it
6. **Using `survey::rake()` instead of `anesrake`** — `survey::rake()` works but `anesrake` has better diagnostics and convergence handling

## Cross-Skill Integration

- After `svyglm()` → use `/marginaleffects` for AMEs and contrasts
- For IPW/propensity weighting → use `/compute-survey-weights`
- For plotting results → use `/coefficient-plot` or `/viz`
- For cleaning raw survey data → use `/clean-survey-data`
