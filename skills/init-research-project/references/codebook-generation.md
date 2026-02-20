# Codebook Generation Reference

## Table of Contents

- [Stata .dta Label Extraction](#stata-dta-label-extraction)
- [CSV Profiling](#csv-profiling)
- [Output Format](#output-format)
- [Questionnaire Cross-Referencing](#questionnaire-cross-referencing)

---

## Stata .dta Label Extraction

```r
library(haven)
library(data.table)

df <- read_dta("data/raw/filename.dta")

# Variable labels
var_labels <- sapply(df, function(x) {
  lbl <- attr(x, "label")
  if (is.null(lbl)) NA_character_ else lbl
})

# Value labels for each labelled variable
val_labels <- lapply(df, function(x) {
  if (is.labelled(x)) {
    lbls <- val_labels(x)
    if (length(lbls) > 0) {
      paste(paste0(lbls, " = ", names(lbls)), collapse = "; ")
    } else NA_character_
  } else NA_character_
})

# Survey weight detection
weight_pattern <- "weight|wt$|^pw$|^fw$|^iw$|pweight|fweight|wgt"
weight_vars <- grep(weight_pattern, names(df), ignore.case = TRUE, value = TRUE)

# Extended missing values (tagged NAs)
tagged_missing <- sapply(df, function(x) {
  if (is.numeric(x)) {
    tags <- tagged_na_tag(x[is_tagged_na(x)])
    if (length(tags) > 0) paste(unique(tags), collapse = ", ") else NA_character_
  } else NA_character_
})
```

## CSV Profiling

```r
library(data.table)

df <- fread("data/raw/filename.csv")

# Per-column profile
profile <- data.table(
  variable = names(df),
  type = sapply(df, class),
  n_missing = sapply(df, function(x) sum(is.na(x))),
  pct_missing = sapply(df, function(x) round(100 * mean(is.na(x)), 1)),
  n_unique = sapply(df, uniqueN),
  example_values = sapply(df, function(x) {
    vals <- na.omit(unique(x))
    paste(head(vals, 5), collapse = ", ")
  }),
  min = sapply(df, function(x) if (is.numeric(x)) min(x, na.rm = TRUE) else NA),
  max = sapply(df, function(x) if (is.numeric(x)) max(x, na.rm = TRUE) else NA)
)
```

## Output Format

Write `docs/codebook.md` with this structure:

```markdown
# Codebook: [Dataset Name]

**Source**: [filename]
**Dimensions**: [rows] x [cols]
**Generated**: [date]

## Summary

| Item | Value |
|------|-------|
| Total variables | N |
| Total observations | N |
| Missing cells | N (%) |
| Survey weight variables | [list or "none detected"] |

## Variables

### variable_name

- **Label**: [from .dta metadata or inferred]
- **Type**: numeric / character / labelled / date
- **Missing**: N (%)
- **Unique values**: N
- **Range**: [min] - [max] (numeric) or [top 10 levels] (categorical)
- **Value labels**: 1 = Label1; 2 = Label2; ... (if labelled)
- **Notes**: [coded missings detected, weight variable, etc.]

### [next variable...]
```

Repeat the variable section for every variable in the dataset. Group related variables under subheadings if the questionnaire or variable naming suggests sections.

## Questionnaire Cross-Referencing

When a questionnaire is provided:

1. **Parse questionnaire**: Extract item numbers, question text, response options
2. **Match strategies** (try in order):
   - Exact variable name match (e.g., `Q1` -> `q1`)
   - Label text overlap (fuzzy match question text to variable labels)
   - Response option match (questionnaire scale matches value labels)
   - Name pattern (e.g., `q1a`, `q1b` -> Question 1 sub-items)
3. **Report in codebook**: Add `Questionnaire item:` field to matched variables
4. **Flag unmatched**:
   - Variables with no questionnaire match -> "Derived or administrative variable"
   - Questionnaire items with no data variable -> "NOT FOUND IN DATA" warning

```markdown
### variable_name

- **Label**: How often do you use social media?
- **Questionnaire item**: Q12 (Section B: Media Use)
- **Type**: labelled
- **Value labels**: 1 = Never; 2 = Rarely; 3 = Sometimes; 4 = Often; 5 = Always
- **Coded missings**: {97: "Not applicable", 98: "Don't know", 99: "Refused"}
```

### Unmatched Items Section

Add at end of codebook:

```markdown
## Unmatched Items

### Variables without questionnaire match
- `caseid`: Administrative ID variable
- `weight`: Survey weight

### Questionnaire items without data match
- Q15 (What is your occupation?): NOT FOUND IN DATA
```
