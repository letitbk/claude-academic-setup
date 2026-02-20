# Project Script Workflow

## Standard Script Numbering

```
scripts/
├── 01_data_cleaning.R       # Raw -> clean: recode missings, labels, factors
├── 02_create_measures.R     # Clean -> analysis: scales, indices, derived vars
├── 03_descriptives.R        # Sample descriptives, balance tables
├── 04_main_analysis.R       # Primary regression models
├── 05_robustness.R          # Alternative specifications, sensitivity
├── 06_heterogeneity.R       # Subgroup analyses (if applicable)
├── 07_figures.R             # All publication figures (or split per figure)
└── 08_appendix.R            # Supplementary analyses
```

Adjust numbering to match the analysis plan. Split or combine as needed, but maintain the pipeline order: cleaning -> measures -> analysis -> outputs.

## R Script Template (Snakemake-Compatible)

```r
# ============================================================================
# Script: scripts/04_main_analysis.R
# Purpose: [brief description]
# Input:   data/processed/analysis_data.rds
# Output:  output/tables/table2_regression.csv, output/tables/table2_regression.tex
# ============================================================================

library(data.table)
library(modelsummary)
library(survey)

# --- Snakemake integration ---
if (exists("snakemake")) {
  input_file  <- snakemake@input[["data"]]
  output_csv  <- snakemake@output[["csv"]]
  output_tex  <- snakemake@output[["tex"]]
} else {
  input_file  <- here::here("data/processed/analysis_data.rds")
  output_csv  <- here::here("output/tables/table2_regression.csv")
  output_tex  <- here::here("output/tables/table2_regression.tex")
}

# --- Load data ---
df <- readRDS(input_file)

# --- Analysis ---
# [model code here]

# --- Save outputs ---
# [save code here]
```

## Snakefile Rule Pattern

One rule per script. Each rule declares inputs, outputs, and the script.

```python
rule data_cleaning:
    input:
        raw = "data/raw/survey.dta"
    output:
        clean = "data/processed/clean.rds"
    script:
        "scripts/01_data_cleaning.R"

rule create_measures:
    input:
        clean = "data/processed/clean.rds"
    output:
        data = "data/processed/analysis_data.rds"
    script:
        "scripts/02_create_measures.R"

rule main_analysis:
    input:
        data = "data/processed/analysis_data.rds"
    output:
        csv = "output/tables/table2_regression.csv",
        tex = "output/tables/table2_regression.tex"
    script:
        "scripts/04_main_analysis.R"

rule all:
    input:
        expand("output/figures/fig{n}_{desc}.png", zip,
               n=[1,2,3], desc=["coefplot","margins","descriptives"]),
        expand("output/tables/table{n}_{desc}.csv", zip,
               n=[1,2,3], desc=["descriptives","regression","robustness"])
```

## Data Pipeline Diagram

```
data/raw/*.dta, *.csv
        │
        ▼  (01_data_cleaning.R)
data/processed/clean.rds
        │
        ▼  (02_create_measures.R)
data/processed/analysis_data.rds
        │
        ├──▶ (03_descriptives.R) ──▶ output/tables/table1_*
        ├──▶ (04_main_analysis.R) ──▶ output/tables/table2_*
        ├──▶ (05_robustness.R) ──▶ output/tables/table3_*
        ├──▶ (06_heterogeneity.R) ──▶ output/tables/table4_*
        └──▶ (07_figures.R) ──▶ output/figures/fig*
```
