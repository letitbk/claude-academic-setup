---
name: clean-survey-data
description: Clean survey data with missing value handling, variable recoding, and Stata label conversion to R factors. Use when processing raw survey/health study data, handling coded missing values (91/92/97/98), or converting Stata labels in R.
---

# Clean Survey Data

A skill for cleaning survey data in R, handling common patterns like missing value codes, variable recoding, and Stata label conversion.

## Quick Start

```r
library(data.table)
library(rio)
library(haven)

# Load data
dt <- as.data.table(import("data.dta"))
names(dt) <- tolower(names(dt))
```

## Key Patterns

### 1. Convert Stata Labels to R Factors

Use this function to extract value labels from Stata variables and convert them to proper R factors:

```r
attach_label_to_variable <- function(x, na_exclude = TRUE) {
  var_lab <- attr(x, 'labels')
  if (na_exclude) {
    # Remove common missing value codes
    var_lab <- var_lab[!var_lab %in% c(91, 92, 97, 98)]
  }
  if (!is.null(var_lab)) {
    x <- factor(x, levels = var_lab, labels = names(var_lab))
  }
  return(x)
}

# Usage
dt[, education := attach_label_to_variable(education)]
dt[, marital_status := attach_label_to_variable(marital_status)]
```

### 2. Handle Missing Value Codes

Survey data often uses special codes for missing values (e.g., 91=refused, 92=don't know, 97=not applicable, 98=skip):

```r
# Single variable
dt[variable %in% c(91, 92, 97, 98), variable := NA]

# Multiple variables at once
missing_codes <- c(91, 92, 97, 98)
vars_to_clean <- c("var1", "var2", "var3")
for (var in vars_to_clean) {
  dt[get(var) %in% missing_codes, (var) := NA]
}

# Using data.table syntax for all numeric columns
dt[, (numeric_vars) := lapply(.SD, function(x) {
  ifelse(x %in% c(91, 92, 97, 98), NA, x)
}), .SDcols = numeric_vars]
```

### 3. Recode Categorical Variables

Create meaningful categories from coded responses:

```r
# Race/ethnicity recoding from multiple binary indicators
dt[, race_single := NA_character_]
dt[race_white == 1, race_single := "White"]
dt[race_black == 1, race_single := "Black"]
dt[race_asian == 1, race_single := "Asian"]
dt[ethnicity_hispanic == 1, race_single := "Hispanic"]

dt[, race_single := factor(race_single,
    levels = c("White", "Black", "Hispanic", "Asian", "Other"))]

# Age groups
dt[, age_group := cut(age,
    breaks = c(0, 30, 40, 50, 60, 70, 80, 110),
    include.lowest = TRUE,
    labels = c("18-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+"))]
```

### 4. Collapse Categories

Reduce granular categories into broader groups:

```r
# Education: 5 levels -> 3 levels
dt[, educ3 := fcase(
    education %in% c("Less than HS", "HS diploma"), "HS or less",
    education %in% c("Some college", "Associate"), "Some college",
    education %in% c("Bachelor's", "Graduate"), "Bachelor's+"
)]

# Marital status: 6 levels -> 3 levels
dt[, marital3 := fcase(
    marital_status %in% c("Married", "Living with partner"), "Partnered",
    marital_status %in% c("Widowed", "Divorced", "Separated"), "Prev married",
    marital_status == "Never married", "Never married"
)]
```

### 5. Create Composite Scores

Sum or average across multiple items:

```r
# Sum score with missing handling
items <- c("item1", "item2", "item3", "item4", "item5")
dt[, sum_score := rowSums(.SD, na.rm = TRUE), .SDcols = items]

# Standardize the score
dt[, sum_score_std := scale(sum_score)[, 1]]

# Count non-missing items (for validity check)
dt[, n_valid := rowSums(!is.na(.SD)), .SDcols = items]
dt[n_valid < 3, sum_score := NA]  # Require at least 3 valid items
```

### 6. Date and Time Processing

```r
# Convert interview timestamp
dt[, interview_date := as.Date(interview_starttime)]

# Calculate age from DOB
dt[, age := year(interview_date) - year(dob_date)]

# Create COVID indicator
dt[, covid_era := fifelse(interview_date >= as.Date("2020-04-01"), 1L, 0L)]
```

## Complete Example

```r
library(data.table)
library(rio)

# Load and standardize names
dt <- as.data.table(import("survey_data.dta"))
names(dt) <- tolower(names(dt))

# Define label conversion function
attach_label_to_variable <- function(x, na_exclude = TRUE) {
  var_lab <- attr(x, 'labels')
  if (na_exclude) {
    var_lab <- var_lab[!var_lab %in% c(91, 92, 97, 98)]
  }
  if (!is.null(var_lab)) {
    x <- factor(x, levels = var_lab, labels = names(var_lab))
  }
  return(x)
}

# Clean missing values
for (var in c("income", "health_status", "satisfaction")) {
  dt[get(var) %in% c(91, 92, 97, 98), (var) := NA]
}

# Convert labeled variables
dt[, gender := attach_label_to_variable(gender)]
dt[, education := attach_label_to_variable(education)]
dt[, marital := attach_label_to_variable(marital)]

# Create derived variables
dt[, age := year(interview_date) - year(dob)]
dt[, age_group := cut(age, breaks = c(17, 35, 50, 65, 100),
                      labels = c("18-34", "35-49", "50-64", "65+"))]

# Select and save cleaned variables
keep_vars <- c("id", "gender", "age", "age_group", "education", "marital")
dt_clean <- dt[, ..keep_vars]
saveRDS(dt_clean, "cleaned_data.rds")
```

## Required Packages

```r
install.packages(c("data.table", "rio", "haven"))
```

## Tips

- Always standardize column names to lowercase first
- Document missing value codes specific to your survey
- Create a data dictionary mapping original codes to cleaned values
- Test label conversion on a small sample before applying to full dataset
- Use `fcase()` for complex recoding (faster than nested `ifelse`)
