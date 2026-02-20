---
name: datacheck
description: Use when starting work with a new data file, before any analysis or visualization. Also use when encountering parsing errors, unexpected values, or when the user says "check this data" or "what's in this file".
---

# Data Check

Inspect and validate a data file before analysis. Report findings with suggested fixes. Do not auto-fix.

## When to Use

- Before any analysis or visualization on a new data file
- When parsing errors or unexpected values appear
- When switching to a different dataset mid-session
- User says "check", "inspect", "what's in this", "profile" a data file

## When NOT to Use

- File has already been checked in this session and nothing changed
- User just wants to read a specific value (use Read tool directly)

## Workflow

### Step 1: Raw File Inspection

**Before loading into R/Stata**, check the raw file:

```bash
file <filename>                          # encoding detection
head -c 500 <filename> | cat -v          # hidden chars: ^M (CR), BOM, non-UTF8
wc -l <filename>                         # row count sanity check
head -3 <filename>                       # peek at delimiter and header
```

Flag these issues:
| Symptom | Meaning |
|---------|---------|
| `^M` at line ends | Classic Mac `\r` or Windows `\r\n` line endings |
| `\xEF\xBB\xBF` at start | UTF-8 BOM marker |
| Only 1 line from `wc -l` | Entire file on one line (wrong line endings) |
| Mixed delimiters | Inconsistent separator characters |

### Step 2: Load and Summarize

**R-first.** Use Stata only when the file is `.dta` and project context is Stata-based.

**For CSV files:**
```r
df <- read.csv("file.csv", stringsAsFactors = FALSE)
```

**For Stata .dta files:**
```r
library(haven)
df <- read_dta("file.dta")
```

Report this table:

| Item | Value |
|------|-------|
| Dimensions | rows x cols |
| Column names | list all |
| Column types | numeric, character, factor, labelled, date |
| Total missing | count and % |

Then per column:
```
Column          Type        Missing   Unique   Example Values
─────────────────────────────────────────────────────────────
age             numeric     12 (2%)   45       18, 25, 34, 67, 89
gender          labelled    0 (0%)    3        1=Male, 2=Female, 3=Other
weight_var      numeric     0 (0%)    847      0.23, 1.05, 2.11
```

### Step 3: Stata .dta Specific Checks

When the file is `.dta`, also report:

1. **Variable labels**: Show all variable descriptions from Stata metadata
2. **Value labels**: For each labelled variable, show the label-to-value mapping
3. **Survey weight variables**: Flag any variables with names matching `*weight*`, `*wt*`, `pw`, `fw`, `iw` or that have `pweight`/`fweight` characteristics
4. **Stata extended missings**: Check for `.a` through `.z` missing types (preserved by haven as tagged NAs)

### Step 4: Coded Missing Values

Scan ALL numeric columns for values that are likely coded missings, not real data:

| Pattern | Convention |
|---------|------------|
| 97, 98, 99 | Not applicable / Don't know / Refused |
| -1, -9, -99 | Various missing types |
| 991-999, 9991-9999 | Extended missing codes (scaled by # digits) |
| `.a` through `.z` | Stata extended missing values |

**Detection method:** For each numeric column, check if values 97-99 (or -1, -9) appear AND the variable's main range is much lower (e.g., 1-5 scale with some 98s).

Report as:
```
POSSIBLE CODED MISSINGS:
  income_cat: values {97, 98, 99} found (n=45). Main range: 1-12. Likely coded missing.
  age: value {99} found (n=2). Main range: 18-95. Ambiguous - could be real age.
```

### Step 5: Light Profiling

After the structural check:

1. **Numeric columns**: Correlation matrix (top 10 strongest pairs if many columns)
2. **Categorical columns**: Frequency tables (top 10 levels per variable, flag if >50 unique levels)
3. **Flag**: Numeric columns stored as character (likely parsing issue), zero-variance columns, duplicate rows

### Step 6: Report Summary

Present a concise summary with three sections:

**Clean:** Variables ready for analysis (no issues)

**Needs attention:** Variables with potential coded missings, encoding issues, or type problems. Include suggested fix code but do NOT execute.

```r
# SUGGESTED FIX for income_cat coded missings:
df$income_cat[df$income_cat %in% c(97, 98, 99)] <- NA
```

**Notes:** Observations about the data structure (survey weights detected, panel structure, etc.)

## Quick Reference

| File type | Load with | Extra checks |
|-----------|-----------|-------------|
| `.csv` | `read.csv()` | encoding, delimiter, line endings |
| `.tsv` | `read.delim()` | encoding, line endings |
| `.dta` | `haven::read_dta()` | value labels, variable labels, weights, extended missings |
| `.rds` | `readRDS()` | just structure check |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Loading .dta without haven | Always `library(haven); read_dta()`, never `foreign::read.dta()` |
| Ignoring labelled class | Report label mappings; suggest `as_factor()` or manual recode |
| Assuming 99 = missing | Check if 99 is in the real data range first |
| Skipping raw byte check | ALWAYS run `file` and `cat -v` before loading. Mac CR issues are silent killers |
| Auto-fixing without asking | Report + suggest. Never auto-recode missing values |
