---
name: survey-regression-stata
description: Run survey-weighted regression in Stata with svyset, margins for average marginal effects (AMEs), and esttab export. Use for complex survey analysis with sampling weights in Stata.
---

# Survey Regression in Stata

A skill for running survey-weighted regression analysis in Stata, including setting up the survey design, running models, computing marginal effects, and exporting results.

## Quick Start

```stata
* Set survey design
svyset cluster_id [pweight = sampling_weight], strata(stratum)

* Run weighted regression
svy: regress outcome treatment_var control1 control2

* Get average marginal effects
margins, dydx(*)

* Export results
esttab using "results.csv", csv se
```

## Key Patterns

### 1. Set Survey Design

```stata
* Basic: weight only
svyset [pweight = wt_final]

* With cluster (PSU)
svyset cluster_id [pweight = wt_final]

* With stratification
svyset cluster_id [pweight = wt_final], strata(stratum_var)

* Using FIPS codes as clusters (common in health surveys)
svyset fips [pweight = wt_final2]
```

### 2. Survey-Weighted Regression

```stata
* Define control variables
local control_var i.batch_int leukocytes age i.race3 i.gender_birth i.educ3 i.marital3

* Linear regression
svy: regress outcome `control_var' treatment_var

* Logistic regression
svy: logit binary_outcome `control_var' treatment_var

* Poisson regression
svy: poisson count_outcome `control_var' treatment_var

* Zero-inflated Poisson
svy: zip count_outcome `control_var' treatment_var, inflate(constant)

* Ordered logit
svy: ologit ordinal_outcome `control_var' treatment_var
```

### 3. Compute Marginal Effects

```stata
* After running svy: regression...

* Average marginal effects for all variables
margins, dydx(*)

* AME for specific variable
margins, dydx(treatment_var)

* Predicted probabilities at specific values
margins, at(age=(30 40 50 60))

* Marginal effects by group
margins race3, dydx(treatment_var)

* Store marginal effects for export
margins, dydx(*) post
estimates store model1_margins
```

### 4. Factor Variables

```stata
* Categorical variables use i. prefix
svy: regress outcome i.race3 i.gender_birth age

* Continuous variables use c. prefix (explicit)
svy: regress outcome c.age c.income

* Interactions
svy: regress outcome c.treatment##i.group

* Polynomial terms
svy: regress outcome c.age##c.age
```

### 5. Store and Compare Models

```stata
estimates clear

* Model 1: Base
svy: regress outcome `control_var' treatment
estimates store m1

* Model 2: Add confounder
svy: regress outcome `control_var' treatment confounder
estimates store m2

* Model 3: Full model
svy: regress outcome `control_var' treatment confounder1 confounder2
estimates store m3

* Compare models
estimates table m1 m2 m3, star stats(N r2)
```

### 6. Export Results

```stata
* Export to CSV
esttab m1 m2 m3 using "results.csv", csv se nogap label replace ///
    star(+ 0.1 * 0.05 ** 0.01)

* Export to LaTeX
esttab m1 m2 m3 using "results.tex", tex se nogap label replace ///
    star(+ 0.1 * 0.05 ** 0.01)

* Export with specific statistics
esttab m1 m2 m3 using "results.csv", csv ///
    cells(b(star fmt(3)) se(par fmt(3))) ///
    stats(N r2_a, fmt(%9.0g %9.3f) labels("Observations" "Adjusted R²")) ///
    star(+ 0.1 * 0.05 ** 0.01) ///
    nogap label replace
```

### 7. Marginal Effects for Visualization

Export marginal effects in a format suitable for R plotting:

```stata
* Run model
svy: regress outcome `control_var' c.treatment

* Compute and post margins
margins, dydx(*) post

* Export for R visualization
esttab using "marginal_effects.csv", csv se ///
    cells(b(fmt(4)) se(fmt(4)) p(fmt(4)) ci_l(fmt(4)) ci_u(fmt(4))) ///
    nogap label replace

* Alternative: manual export with more control
putexcel set "margins.xlsx", replace
putexcel A1 = "variable" B1 = "estimate" C1 = "se" D1 = "p" E1 = "ci_low" F1 = "ci_high"
```

## Complete Example

```stata
*------------------------------------------------------------
* Survey-Weighted Analysis Template
*------------------------------------------------------------
version 17
clear all
set more off

* Load data
use "analysis_data.dta", clear

* Set survey design
svyset fips [pweight = wt_final2]

* Define control variables
local control_var i.batch_int leukocytes_ic age i.race3 i.gender_birth ///
                  i.educ3 i.marital3 i.n_size_all

* Clear previous estimates
estimates clear

*------------------------------------------------------------
* Model 1: Main effect
*------------------------------------------------------------
svy: regress pace `control_var' n_size_hassler
estimates store pace_m1

* Get marginal effects
margins, dydx(n_size_hassler) post
estimates store pace_m1_margins

*------------------------------------------------------------
* Model 2: Add potential confounders
*------------------------------------------------------------
svy: regress pace `control_var' n_size_hassler covid health_insurance
estimates store pace_m2

margins, dydx(n_size_hassler) post
estimates store pace_m2_margins

*------------------------------------------------------------
* Model 3: Add health controls
*------------------------------------------------------------
svy: regress pace `control_var' n_size_hassler cci_charlson any_encounter_3years
estimates store pace_m3

margins, dydx(n_size_hassler) post
estimates store pace_m3_margins

*------------------------------------------------------------
* Export results
*------------------------------------------------------------

* Marginal effects table
esttab pace_m1_margins pace_m2_margins pace_m3_margins ///
    using "pace_margins.csv", csv se ///
    mtitle("Base" "+ COVID/Ins" "+ Health") ///
    nogap label replace star(+ 0.1 * 0.05 ** 0.01)

* Full coefficient table
esttab pace_m1 pace_m2 pace_m3 ///
    using "pace_coefficients.csv", csv se ///
    mtitle("Base" "+ COVID/Ins" "+ Health") ///
    nogap label replace star(+ 0.1 * 0.05 ** 0.01)

* Create completion sentinel
file open fh using "analysis_complete.ok", write replace
file close fh
```

## Required Stata Packages

```stata
* Install if needed
ssc install estout, replace   // For esttab
ssc install outreg2, replace  // Alternative export
```

## Common Stata Survey Commands

| Command | Description |
|---------|-------------|
| `svyset` | Define survey design |
| `svy:` | Prefix for survey-weighted estimation |
| `margins` | Post-estimation marginal effects |
| `estimates store` | Save estimation results |
| `esttab` | Export results to file |
| `svy: regress` | Linear regression |
| `svy: logit` | Logistic regression |
| `svy: poisson` | Poisson regression |
| `svy: zip` | Zero-inflated Poisson |

## Tips

- Always use `svy:` prefix for weighted analysis
- Use `i.` prefix for categorical variables, `c.` for continuous
- Store both full model and margins for complete documentation
- The `post` option in `margins` replaces estimation results for export
- Use `dydx(*)` for all AMEs, or specify variables for specific AMEs
- Check survey design with `svydescribe` before analysis
