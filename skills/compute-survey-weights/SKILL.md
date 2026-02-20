---
name: compute-survey-weights
description: Calculate participation-adjusted survey weights using logistic regression. Use when you need to adjust sampling weights for selection bias, non-response, or create IPW (inverse probability weights) for survey data.
---

# Compute Survey Weights

A skill for calculating participation-adjusted survey weights using propensity score methods in R.

## Quick Start

```r
library(data.table)
library(survey)

# Define survey design
sdata <- svydesign(
  id = ~1,
  weights = ~base_weight,
  data = dt[!is.na(base_weight)]
)

# Predict participation
fit <- svyglm(participated ~ age + race + gender + education,
              design = sdata,
              family = quasibinomial(link = "logit"))

# Create adjusted weights
dt$pred_prob <- predict(fit, type = "response", newdata = dt)
dt$adjusted_weight <- dt$base_weight / dt$pred_prob
```

## Key Patterns

### 1. Basic Participation Weight Adjustment

Adjust weights when a subset of the sample participated in an additional component (e.g., biomarker collection):

```r
library(data.table)
library(survey)

# Assume: base_weight exists, participated is 0/1 indicator
predictors <- c("age", "race", "gender", "education", "income")

# Create analysis dataset (complete cases for predictors)
adata <- dt[, c("id", predictors, "participated", "base_weight"), with = FALSE]
adata <- na.omit(adata)

# Remove refused/don't know factor levels if present
for (var in predictors) {
  if (is.factor(adata[[var]])) {
    adata[[var]] <- factor(adata[[var]],
      levels = levels(adata[[var]])[!levels(adata[[var]]) %in% c("REFUSED", "DON'T KNOW")])
  }
}

# Set up survey design with base weights
sdata <- svydesign(
  id = ~1,
  weights = ~base_weight,
  data = adata[!is.na(base_weight)]
)

# Fit participation model
formula_str <- paste("participated ~", paste(predictors, collapse = " + "))
fit <- svyglm(as.formula(formula_str),
              design = sdata,
              family = quasibinomial(link = "logit"))

# Compute predicted participation probability
adata$participation_pred <- c(predict(fit, type = "response", newdata = adata))

# Create adjusted weight (IPW)
adata[, adjusted_weight := base_weight * (1 / participation_pred)]
```

### 2. With Cluster/Stratification

When the survey has a complex design:

```r
# Complex survey design
sdata <- svydesign(
  id = ~cluster_id,           # Primary sampling unit
  strata = ~stratum,          # Stratification variable
  weights = ~base_weight,     # Sampling weight
  data = adata,
  nest = TRUE                 # Clusters nested within strata
)

# Fit propensity model
fit <- svyglm(participated ~ age_group + race + gender + region,
              design = sdata,
              family = quasibinomial())

# Get predicted probabilities
adata$prop_score <- fitted(fit)

# Create final adjusted weight
adata[, final_weight := base_weight / prop_score]
```

### 3. Weight Trimming

Avoid extreme weights that can inflate variance:

```r
# Calculate percentiles for trimming
q01 <- quantile(adata$adjusted_weight, 0.01, na.rm = TRUE)
q99 <- quantile(adata$adjusted_weight, 0.99, na.rm = TRUE)

# Trim at 1st and 99th percentiles
adata[, trimmed_weight := pmin(pmax(adjusted_weight, q01), q99)]

# Alternative: Cap at X times the median
median_wt <- median(adata$adjusted_weight, na.rm = TRUE)
adata[, capped_weight := pmin(adjusted_weight, 5 * median_wt)]
```

### 4. Weight Diagnostics

Check the quality of your weights:

```r
# Summary statistics
summary(adata$adjusted_weight)

# Design effect (DEFF)
deff <- 1 + var(adata$adjusted_weight) / mean(adata$adjusted_weight)^2
cat("Design effect:", round(deff, 2), "\n")

# Effective sample size
n_eff <- sum(adata$adjusted_weight)^2 / sum(adata$adjusted_weight^2)
cat("Effective N:", round(n_eff), "of", nrow(adata), "\n")

# Check balance after weighting
library(cobalt)
bal.tab(participated ~ age + race + gender + education,
        data = adata,
        weights = adata$adjusted_weight,
        method = "weighting")
```

### 5. Normalize Weights

Rescale weights to sum to sample size:

```r
# Normalize to sum to N
adata[, normalized_weight := adjusted_weight * .N / sum(adjusted_weight)]

# Verify
sum(adata$normalized_weight)  # Should equal nrow(adata)
```

## Complete Example

```r
library(data.table)
library(survey)

# Load data
dt <- fread("survey_data.csv")

# Indicator for biomarker collection participation
dt[, in_biomarker := fifelse(!is.na(biomarker_value), 1L, 0L)]

# Predictors for participation model
xx <- c("race", "gender", "age", "age_group", "education")
yy <- "in_biomarker"
weight_var <- "sampling_weight"

# Create analysis dataset
adata <- dt[, c("id", xx, yy, weight_var), with = FALSE]
adata <- na.omit(adata)

# Clean factor levels
for (var in xx) {
  if (is.factor(adata[[var]])) {
    adata[[var]] <- factor(adata[[var]],
      levels = levels(adata[[var]])[!levels(adata[[var]]) %in% c("REFUSED", "DON'T KNOW")])
  }
}

# Survey design
sdata <- svydesign(
  id = ~1,
  weights = as.formula(paste0("~", weight_var)),
  data = adata[!is.na(get(weight_var))]
)

# Participation model
fit_formula <- as.formula(paste0(yy, " ~ ", paste0(xx, collapse = " + ")))
fit <- svyglm(formula = fit_formula, design = sdata, family = quasibinomial(link = "logit"))

# Predict participation probability
adata$participation_pred <- c(predict(fit, type = "response", newdata = adata))

# Create participation-adjusted weight
adata[, adjusted_weight := get(weight_var) * (1 / participation_pred)]

# Trim extreme weights
q99 <- quantile(adata$adjusted_weight, 0.99, na.rm = TRUE)
adata[adjusted_weight > q99, adjusted_weight := q99]

# Merge back to original data
dt <- merge(dt, adata[, .(id, adjusted_weight)], by = "id", all.x = TRUE)

# Save
saveRDS(dt, "survey_data_weighted.rds")
```

## Required Packages

```r
install.packages(c("data.table", "survey"))
# Optional for diagnostics:
install.packages(c("cobalt", "ggplot2"))
```

## Tips

- Always check for propensity scores near 0 or 1 (extreme weights)
- Include variables predictive of both participation and the outcome
- Consider weight trimming if design effect is very large (>3)
- Document the participation model for reproducibility
- Validate weights by checking covariate balance
