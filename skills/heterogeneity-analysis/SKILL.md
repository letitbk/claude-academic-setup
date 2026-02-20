---
name: heterogeneity-analysis
description: Subgroup and heterogeneity analysis in Stata using interaction models and stratified regression. Use when examining if treatment effects vary across groups (age, gender, race, etc.).
---

# Heterogeneity Analysis

A skill for conducting subgroup and heterogeneity analyses in Stata, testing whether treatment effects differ across population subgroups.

## Quick Start

```stata
* Interaction model
svy: regress outcome controls c.treatment##i.group
margins group, dydx(treatment)

* Stratified analysis
levelsof group, local(groups)
foreach g of local groups {
    svy: regress outcome controls treatment if group == `g'
    estimates store model_g`g'
}
```

## Key Patterns

### 1. Interaction Model Approach

Test whether treatment effects vary by group using interactions:

```stata
* Define controls
local control_var i.batch leukocytes age i.race i.gender i.education

* Interaction model: treatment × age group
svy: regress outcome `control_var' c.treatment##i.age_group
estimates store interaction_model

* Get treatment effect at each level of age_group
margins age_group, dydx(treatment) post
estimates store margins_by_age
```

### 2. Stratified Regression

Run separate models for each subgroup:

```stata
local control_var i.batch leukocytes i.race i.gender i.education

* Get unique values of grouping variable
levelsof age_group, local(age_groups)

* Loop through groups
foreach g of local age_groups {
    * Run model for this subgroup
    quietly svy: regress outcome `control_var' c.treatment if age_group == `g'
    estimates store reg_age`g'

    * Get marginal effect
    quietly margins, dydx(treatment) post
    estimates store margins_age`g'

    * Get group label for export
    local lbl: label (age_group) `g'
    if "`lbl'" == "" {
        local lbl "Group `g'"
    }
}
```

### 3. Complete Heterogeneity Template

```stata
*------------------------------------------------------------
* Heterogeneity Analysis by Age Group
*------------------------------------------------------------
version 17
clear all

use "analysis_data.dta", clear
svyset cluster [pweight = weight]

* Create age groups if needed
cap drop age_group
gen age_cap = min(age, 85)
egen age_group = cut(age_cap), at(18 30 40 50 60 70 85) icodes
label define agegrp 0 "18-29" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-85"
label values age_group agegrp

* Controls (exclude age since we're stratifying by it)
local control_var i.batch leukocytes i.race i.gender i.education i.marital

estimates clear

*--- Interaction model ---
svy: regress outcome `control_var' c.treatment##i.age_group
estimates store interaction

* Marginal effects by age group
margins age_group, dydx(treatment) post
estimates store interaction_margins

*--- Stratified models ---
local margin_models "interaction_margins"
local reg_models "interaction"

levelsof age_group, local(age_groups)
foreach g of local age_groups {
    * Regression
    quietly svy: regress outcome `control_var' c.treatment ///
        if age_group == `g' & !missing(treatment)
    estimates store reg_age`g'

    * Margins
    quietly margins, dydx(treatment) post
    estimates store margins_age`g'

    * Add to lists
    local margin_models "`margin_models' margins_age`g'"
    local reg_models "`reg_models' reg_age`g'"
}

*--- Export ---
esttab `margin_models' using "heterogeneity_age_margins.csv", csv se ///
    nogap label replace star(+ 0.1 * 0.05 ** 0.01)

esttab `reg_models' using "heterogeneity_age_coeffs.csv", csv se ///
    nogap label replace star(+ 0.1 * 0.05 ** 0.01)
```

### 4. Test for Heterogeneity

```stata
* Fit interaction model
svy: regress outcome controls c.treatment##i.group

* Test if interaction terms are jointly significant
testparm i.group#c.treatment

* Store p-value for reporting
local p_interaction = r(p)
display "Interaction p-value: `p_interaction'"

* Test specific contrasts
contrast i.group#c.treatment, effects
```

### 5. Multiple Moderators

```stata
estimates clear

* By age
svy: regress outcome `control_var' c.treatment##i.age_group
margins age_group, dydx(treatment) post
estimates store by_age

* By gender
svy: regress outcome `control_var' c.treatment##i.gender
margins gender, dydx(treatment) post
estimates store by_gender

* By race
svy: regress outcome `control_var' c.treatment##i.race
margins race, dydx(treatment) post
estimates store by_race

* By education
svy: regress outcome `control_var' c.treatment##i.education
margins education, dydx(treatment) post
estimates store by_education

* Export all
esttab by_age by_gender by_race by_education using "all_moderators.csv", ///
    csv se nogap label replace star(+ 0.1 * 0.05 ** 0.01)
```

### 6. Continuous Moderator

```stata
* Interaction with continuous moderator
svy: regress outcome `control_var' c.treatment##c.age

* Marginal effects at representative values
margins, dydx(treatment) at(age=(30 40 50 60 70))

* Plot (in Stata 17+)
marginsplot, recast(line) recastci(rarea)
```

### 7. Triple Interaction

```stata
* Three-way interaction
svy: regress outcome `control_var' c.treatment##i.gender##i.age_group

* Marginal effects for each combination
margins gender#age_group, dydx(treatment)

* Or specific contrasts
margins, dydx(treatment) at(gender=(1 2) age_group=(0 1 2 3 4 5))
```

## Complete Example

```stata
*------------------------------------------------------------
* Heterogeneity Analysis: Hasslers × Age/Gender/Spouse Status
*------------------------------------------------------------
version 17
clear all
set more off

use "analysis_data.dta", clear
svyset fips [pweight = wt_final2]

* Create age groups
cap drop age_group
gen age_cap = min(age, 85)
egen age_group = cut(age_cap), at(18 30 40 50 60 70 85) icodes
label define agegrp 0 "18-29" 1 "30-39" 2 "40-49" 3 "50-59" 4 "60-69" 5 "70-85"
label values age_group agegrp

* Controls
local control_var i.batch_int leukocytes i.race3 i.gender_birth i.educ3

*============================================================
* PART 1: Heterogeneity by Age
*============================================================
estimates clear

* Interaction model
svy: regress pace `control_var' c.n_size_hassler##i.age_group
estimates store pace_age_inter
margins age_group, dydx(n_size_hassler) post
estimates store pace_age_margins

* Stratified models
levelsof age_group, local(age_groups)
foreach g of local age_groups {
    quietly svy: regress pace `control_var' c.n_size_hassler if age_group == `g'
    estimates store pace_strat`g'
    quietly margins, dydx(n_size_hassler) post
    estimates store pace_strat`g'_m
}

*============================================================
* PART 2: Heterogeneity by Gender
*============================================================
svy: regress pace `control_var' c.n_size_hassler##i.gender_birth
estimates store pace_gender_inter
margins gender_birth, dydx(n_size_hassler) post
estimates store pace_gender_margins

*============================================================
* PART 3: Heterogeneity by Marital Status
*============================================================
svy: regress pace `control_var' c.n_size_hassler##i.marital3
estimates store pace_marital_inter
margins marital3, dydx(n_size_hassler) post
estimates store pace_marital_margins

*============================================================
* Export Results
*============================================================
esttab pace_age_margins pace_gender_margins pace_marital_margins ///
    using "heterogeneity_summary.csv", csv se ///
    mtitle("By Age" "By Gender" "By Marital") ///
    nogap label replace star(+ 0.1 * 0.05 ** 0.01)

* Completion flag
file open fh using "heterogeneity.ok", write replace
file close fh
```

## Interpretation

| Pattern | Interpretation |
|---------|---------------|
| Non-significant interaction | Effect is similar across groups |
| Significant interaction | Effect varies by group |
| Effect in one group only | Targeted intervention potential |
| Opposing effects | Complex mechanism |

## Tips

- Always report both interaction models AND stratified models
- Test interaction terms formally with `testparm`
- Consider multiple testing corrections when testing many moderators
- Plot marginal effects for continuous moderators
- Be cautious about power in small subgroups
- Pre-register heterogeneity analyses to avoid p-hacking
