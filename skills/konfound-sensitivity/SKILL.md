---
name: konfound-sensitivity
description: Quantify sensitivity to unmeasured confounding using konfound in Stata or R. Use when you need to assess how much confounding would be needed to invalidate your findings (RIR, ITCV metrics).
---

# Konfound Sensitivity Analysis

A skill for conducting sensitivity analysis to unmeasured confounding using the `konfound` package. Quantifies how strong an omitted variable would need to be to invalidate causal inferences.

## Quick Start

### Stata
```stata
* After regression
svy: regress outcome controls treatment
konfound treatment, indx("IT")
konfound treatment, indx("RIR")
```

### R
```r
library(konfound)
konfound(model, "treatment")
```

## Key Concepts

| Metric | Name | Interpretation |
|--------|------|---------------|
| **ITCV** | Impact Threshold for Confounding Variable | Minimum correlation product (r_OY × r_OX) needed to nullify effect |
| **RIR** | Robustness of Inference to Replacement | % of cases that would need to be replaced to change conclusion |

## Key Patterns

### 1. Basic Sensitivity Analysis (Stata)

```stata
* Run your main model
svy: regress outcome controls treatment

* Impact Threshold (ITCV)
konfound treatment, indx("IT")

* Robustness of Inference to Replacement
konfound treatment, indx("RIR")
```

### 2. Store and Export Results (Stata)

```stata
* Create frames to store results
capture frame drop summary
frame create summary str20 outcome str20 exposure str6 metric ///
    double impact_threshold double rir_cases double rsq

* After running model
svy: regress pace controls treatment
estimates store main_model

* Get ITCV
estimates restore main_model
konfound treatment, indx("IT")
local itcv = r(itcv)
local uncond_itcv = r(unconitcv)
local rsq = r(Rsq)
local r_ycv = r(r_ycv)
local r_xcv = r(r_xcv)

* Get RIR
estimates restore main_model
konfound treatment, indx("RIR")
local rir = r(rir)

* Store in frame
frame summary {
    set obs 1
    replace outcome = "pace" in 1
    replace exposure = "treatment" in 1
    replace metric = "IT" in 1
    replace impact_threshold = `itcv' in 1
    replace rsq = `rsq' in 1
}
```

### 3. Compare with Observed Covariate Impacts (Stata)

```stata
* Define covariates for comparison
local covariates batch_int_2-batch_int_7 leukocytes age race_2 race_3 female educ_2 educ_3

* Identify estimation sample
tempvar sample
svy: regress outcome `covariates' treatment
gen byte `sample' = e(sample)

* Compute correlations between covariates and treatment/outcome
quietly corr `covariates' treatment if `sample' == 1
matrix mat_corrx = r(C)

quietly corr `covariates' outcome if `sample' == 1
matrix mat_corry = r(C)

* Calculate impact for each covariate
local n_cov : word count `covariates'
local col = `n_cov' + 1

forvalues i = 1/`n_cov' {
    local cov : word `i' of `covariates'
    scalar corr_vx = mat_corrx[`i', `col']
    scalar corr_vy = mat_corry[`i', `col']
    local impact = scalar(corr_vx) * scalar(corr_vy)
    display "`cov': r_x = " %6.3f scalar(corr_vx) " r_y = " %6.3f scalar(corr_vy) " impact = " %6.4f `impact'
}
```

### 4. Partial Correlations (Stata)

```stata
* Partial correlations (controlling for other covariates)
quietly pcorr treatment `covariates' if `sample' == 1
matrix mat_partx = r(p_corr)

quietly pcorr outcome `covariates' if `sample' == 1
matrix mat_party = r(p_corr)

* Calculate partial impact
forvalues i = 1/`n_cov' {
    local cov : word `i' of `covariates'
    scalar corr_vx = mat_partx[`i', 1]
    scalar corr_vy = mat_party[`i', 1]
    local impact = scalar(corr_vx) * scalar(corr_vy)
    display "`cov' (partial): impact = " %6.4f `impact'
}
```

### 5. R Implementation

```r
library(konfound)
library(data.table)

# Fit model
model <- lm(outcome ~ treatment + age + race + gender + education, data = dt)

# Sensitivity analysis
sens <- konfound(model, "treatment")

# Get specific metrics
sens$itcv      # Impact threshold
sens$rir       # Robustness of inference to replacement

# Visualize
plot(sens)
```

### 6. For Survey-Weighted Models (R)

```r
library(survey)
library(konfound)

# Create survey design
svy_design <- svydesign(id = ~1, weights = ~weight, data = dt)

# Fit weighted model
model <- svyglm(outcome ~ treatment + controls, design = svy_design)

# Extract coefficients for manual konfound calculation
coef_trt <- coef(model)["treatment"]
se_trt <- sqrt(vcov(model)["treatment", "treatment"])
n <- nrow(model$data)

# Manual ITCV calculation
t_stat <- coef_trt / se_trt
t_crit <- qt(0.975, n - length(coef(model)))
itcv <- (t_stat^2 - t_crit^2) / (t_stat^2 + n - 1)
```

## Complete Example (Stata)

```stata
*------------------------------------------------------------
* Konfound Sensitivity Analysis
*------------------------------------------------------------
version 17
clear all
set more off

use "analysis_data.dta", clear
svyset fips [pweight = wt_final2]

* Create dummy variables for factor variables
tab race3, gen(race3_)
tab educ3, gen(educ3_)
tab marital3, gen(marital3_)
tab batch_int, gen(batch_int_)
gen female = (gender_birth == 2) if !missing(gender_birth)

* Define covariates (dummies, not factors)
local control_var batch_int_2-batch_int_7 leukocytes_ic age ///
                  race3_2 race3_3 female educ3_2 educ3_3 marital3_2 marital3_3

* Create results frames
capture frame drop summary
frame create summary str20 outcome str20 exposure str6 metric ///
    double impact_threshold double unconditional_impact double rir_cases ///
    double rsq double corr_y_ov double corr_x_ov

*--- Outcome: PACE ---
tempvar sample_pace
svy: regress pace `control_var' c.n_size_hassler if !missing(n_size_hassler)
gen byte `sample_pace' = e(sample)
estimates store pace_reg

* ITCV
estimates restore pace_reg
konfound n_size_hassler, indx("IT")
local pace_it = r(itcv)
local pace_uncon = r(unconitcv)
local pace_rsq = r(Rsq)
local pace_rycv = r(r_ycv)
local pace_rxcv = r(r_xcv)

frame summary {
    local newobs = _N + 1
    quietly set obs `newobs'
    replace outcome = "pace" in `newobs'
    replace exposure = "n_size_hassler" in `newobs'
    replace metric = "IT" in `newobs'
    replace impact_threshold = `pace_it' in `newobs'
    replace unconditional_impact = `pace_uncon' in `newobs'
    replace rsq = `pace_rsq' in `newobs'
    replace corr_y_ov = `pace_rycv' in `newobs'
    replace corr_x_ov = `pace_rxcv' in `newobs'
}

* RIR
estimates restore pace_reg
konfound n_size_hassler, indx("RIR")
local pace_rir = r(rir)

frame summary {
    local newobs = _N + 1
    quietly set obs `newobs'
    replace outcome = "pace" in `newobs'
    replace exposure = "n_size_hassler" in `newobs'
    replace metric = "RIR" in `newobs'
    replace rir_cases = `pace_rir' in `newobs'
}

*--- Export ---
frame summary: export delimited using "konfound_results.csv", replace

file open fh using "konfound.ok", write replace
file close fh
```

## Interpretation Guide

### ITCV (Impact Threshold)
- **ITCV = 0.10**: Omitted variable must have r=0.32 with both X and Y
- **ITCV = 0.25**: Omitted variable must have r=0.50 with both X and Y
- Compare ITCV to observed covariate impacts to assess plausibility

### RIR (Robustness of Inference to Replacement)
- **RIR = 50%**: Half the cases would need to be replaced with null-effect cases
- **RIR = 90%**: Very robust; 90% replacement needed to nullify
- Higher RIR = more robust findings

## Required Packages

**Stata:**
```stata
ssc install konfound, replace
```

**R:**
```r
install.packages("konfound")
```

## Tips

- Always report both ITCV and RIR for complete picture
- Compare ITCV to observed covariate impacts for context
- Document the threshold interpretation in your paper
- Consider both raw and partial correlation impacts
- Pre-specify sensitivity thresholds if possible
