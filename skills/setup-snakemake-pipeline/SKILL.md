---
name: setup-snakemake-pipeline
description: Initialize Snakemake workflows with R and Stata integration for reproducible research pipelines. Use when setting up multi-language data processing and analysis workflows.
---

# Setup Snakemake Pipeline

A skill for creating reproducible research pipelines using Snakemake with R and Stata integration. Covers project structure, rule patterns, logging, and best practices for multi-language workflows.

## Quick Start

```python
# Snakefile
rule all:
    input:
        "output/final_results.csv"

rule clean_data:
    input:
        raw="data/raw/input.csv"
    output:
        cleaned="data/processed/cleaned.rds"
    script:
        "scripts/clean_data.R"

rule analyze:
    input:
        data="data/processed/cleaned.rds"
    output:
        results="output/final_results.csv"
    script:
        "scripts/analysis.R"
```

## Project Structure

```
project/
├── Snakefile              # Master workflow (optional)
├── code/
│   ├── Snakefile          # Main Snakefile
│   ├── config_paths.R     # R path configuration
│   ├── config_paths.do    # Stata path configuration
│   ├── 1_data-cleaning/
│   │   ├── run_data_cleaning.smk
│   │   ├── 0_clean_*.R
│   │   └── logs/
│   └── 2_analysis/
│       ├── run_analysis.smk
│       ├── *.R
│       ├── *.do
│       └── logs/
├── data/
│   ├── raw/
│   └── processed/
└── output/
```

## Complete Template: Master Snakefile

```python
# Snakefile - Master pipeline orchestrating sub-workflows
from pathlib import Path

# Configuration
CLEANED_DATA = "/path/to/processed/data.dta"

rule all:
    input:
        "2_analysis/logs/pipeline.done"

rule run_data_cleaning:
    """Execute the data-cleaning workflow."""
    output:
        cleaned=CLEANED_DATA
    threads: 1
    shell:
        r'''
        cd 1_data-cleaning
        snakemake -s run_data_cleaning.smk --cores {threads} "{output.cleaned}"
        '''

rule run_analysis:
    """Run the analysis workflow after cleaning."""
    input:
        cleaned=CLEANED_DATA
    output:
        sentinel="2_analysis/logs/pipeline.done"
    threads: 1
    shell:
        r'''
        cd 2_analysis
        snakemake -s run_analysis.smk --cores {threads}
        mkdir -p logs
        touch logs/pipeline.done
        '''
```

## R Script Rules

```python
from os.path import join

# Path configuration
dir_data_raw = '/path/to/raw/data'
dir_data_processed = '/path/to/processed'

# Output targets
df_cleaned = join(dir_data_processed, 'cleaned_data.rds')

rule clean_data:
    input:
        raw=join(dir_data_raw, 'raw_data.dta')
    output:
        cleaned=df_cleaned
    log:
        join("logs", "clean_data.log")
    script:
        "0_clean_data.R"
```

### R Script Template (Snakemake-compatible)

```r
#!/usr/bin/env Rscript
# Purpose: Clean raw data

suppressPackageStartupMessages({
  library(data.table)
  library(haven)
})

# Path configuration - supports both Snakemake and standalone
if (exists("snakemake")) {
  # Running via Snakemake
  input_path <- snakemake@input[["raw"]]
  output_path <- snakemake@output[["cleaned"]]
  log_file <- snakemake@log[[1]]
} else {
  # Running standalone
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) >= 2) {
    input_path <- args[[1]]
    output_path <- args[[2]]
  } else {
    source("../config_paths.R")
    input_path <- get_raw_path("raw_data.dta")
    output_path <- get_processed_path("cleaned_data.rds")
  }
}

# Your processing code here
dt <- as.data.table(read_dta(input_path))
# ... cleaning steps ...
saveRDS(dt, output_path)
```

## Stata Rules

```python
import os

# Stata executable path
STATA = "/Applications/Stata/StataMP.app/Contents/MacOS/stata-mp"
# Or for Windows: STATA = "C:/Program Files/Stata17/StataMP-64.exe"
# Or for Linux: STATA = "/usr/local/stata17/stata-mp"

# Path configuration
CODE_PATH = os.path.dirname(os.path.abspath(workflow.snakefile))
LOG_DIR = os.path.join(CODE_PATH, "logs")

rule stata_analysis:
    input:
        script=join(CODE_PATH, "analysis.do"),
        data=CLEANED_DATA
    output:
        results=join(OUTPUT_DIR, "results.csv"),
        ok=join(OUTPUT_DIR, "analysis.ok")
    shell:
        '''
        mkdir -p "{LOG_DIR}" && \
        cd "{LOG_DIR}" && \
        DATA_PATH="{input.data}" \
        RESULTS_PATH="{output.results}" \
        OK_PATH="{output.ok}" \
        "{STATA}" -b do "{input.script}"
        '''
```

### Stata Script Template (Snakemake-compatible)

```stata
* analysis.do - Snakemake-compatible Stata script
version 17
clear all
set more off

* Get paths from environment variables (set by Snakemake)
local data_path : env DATA_PATH
local results_path : env RESULTS_PATH
local ok_path : env OK_PATH

* If running standalone, use defaults
if "`data_path'" == "" {
    do "../config_paths.do"
    local data_path "${processed_path}/data.dta"
    local results_path "${output_path}/results.csv"
    local ok_path "${output_path}/analysis.ok"
}

* Load data
use "`data_path'", clear

* Your analysis code here
regress outcome treatment controls
esttab using "`results_path'", csv replace

* Create sentinel file to signal completion
file open ok using "`ok_path'", write replace
file write ok "done"
file close ok
```

## Configuration Files

### config_paths.R

```r
# config_paths.R - Central path configuration for R scripts

# Base paths (customize for your environment)
PROJECT_PATH <- "/path/to/project"
RAW_PATH <- file.path(PROJECT_PATH, "data", "raw")
PROCESSED_PATH <- file.path(PROJECT_PATH, "data", "processed")
OUTPUT_PATH <- file.path(PROJECT_PATH, "output")

# Helper functions
get_raw_path <- function(filename) file.path(RAW_PATH, filename)
get_processed_path <- function(filename) file.path(PROCESSED_PATH, filename)
get_output_path <- function(filename) file.path(OUTPUT_PATH, filename)
```

### config_paths.do

```stata
* config_paths.do - Central path configuration for Stata scripts

global project_path "/path/to/project"
global raw_path "${project_path}/data/raw"
global processed_path "${project_path}/data/processed"
global output_path "${project_path}/output"
```

## Multi-Output Rules

```python
rule combine_all:
    input:
        data1=df_cleaned1,
        data2=df_cleaned2,
        data3=df_cleaned3
    output:
        combined_rds=join(dir_data_processed, "combined.rds"),
        combined_dta=join(dir_data_processed, "combined.dta")
    log:
        join("logs", "combine_all.log")
    script:
        "1_combine_datafile.R"
```

## Logging Best Practices

```python
# Central log directory
LOG_DIR = os.path.join(CODE_PATH, "logs")

# R script with logging
rule r_with_log:
    input:
        data="data.rds"
    output:
        results="results.csv"
    log:
        join(LOG_DIR, "r_script.log")
    script:
        "script.R"

# Stata with log handling
rule stata_with_log:
    input:
        script="analysis.do",
        data="data.dta"
    output:
        results="results.csv"
    log:
        join(LOG_DIR, "stata_analysis.log")
    shell:
        r'''
        mkdir -p "{LOG_DIR}" && \
        cd "{LOG_DIR}" && \
        DATA_PATH="{input.data}" "{STATA}" -b do "{input.script}"
        # Move Stata's default log to specified location
        mv "analysis.log" {log} 2>/dev/null || true
        '''
```

## Dependency Chains

```python
# Data cleaning produces intermediate files
rule clean_step1:
    output: step1="processed/step1.rds"
    script: "0_clean_step1.R"

rule clean_step2:
    input: step1="processed/step1.rds"
    output: step2="processed/step2.rds"
    script: "0_clean_step2.R"

# Analysis depends on cleaned data
rule analyze:
    input:
        data="processed/step2.rds",
        script="analysis.do"
    output: "output/results.csv"
    shell: "..."
```

## Running the Pipeline

```bash
# Dry run (show what would be executed)
snakemake -n

# Run with N cores
snakemake --cores 4

# Run specific target
snakemake output/results.csv

# Force re-run of a rule
snakemake --forcerun clean_data

# Generate DAG visualization
snakemake --dag | dot -Tpng > dag.png
```

## Tips

1. **Environment variables**: Pass paths via env vars for Stata (shell rules)
2. **Sentinel files**: Use `.ok` files to mark successful completion of rules with multiple outputs
3. **Relative paths**: Use `os.path` functions for cross-platform compatibility
4. **Stata logs**: Stata creates logs in the CWD; use `cd` in shell to control location
5. **R script objects**: Access inputs/outputs via `snakemake@input`, `snakemake@output`

## Common Issues

### Stata Path with Spaces
```python
# Use raw strings and proper quoting
shell:
    r'''
    "{STATA}" -b do "{input.script}"
    '''
```

### R Script Not Finding Snakemake Object
```r
# Check if running via Snakemake
if (exists("snakemake")) {
  # Snakemake mode
} else {
  # Standalone mode
}
```

### Circular Dependencies
```python
# Ensure outputs don't feed back into earlier rules
# Use separate directories for raw, processed, output
```

### Missing Inputs
```bash
# Check what's missing
snakemake --summary
```
