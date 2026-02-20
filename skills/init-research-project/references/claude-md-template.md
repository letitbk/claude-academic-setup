# CLAUDE.md Template

Customize this template based on the planning session outputs. Replace all `[bracketed]` items with actual values from the project.

---

```markdown
# CLAUDE.md

## Project Overview

[1-2 sentence description of the research project, based on planning interview]

## Research Questions

1. [RQ1 from analysis plan]
2. [RQ2 from analysis plan]

## Data

- **Source**: [dataset name]
- **Location**: `data/raw/[filename]`
- **Codebook**: `docs/codebook.md`
- **Survey design**: [weights variable, cluster variable, strata variable -- or "N/A"]

## Project Structure

```
scripts/       # Numbered R scripts (01_, 02_, ...)
data/raw/      # Original data (DO NOT MODIFY)
data/processed/# Cleaned datasets
output/figures/# PNG + PDF + companion .md
output/tables/ # CSV + LaTeX + companion .md
docs/          # Codebook, analysis plan
manuscript/    # paper.tex, references.bib
```

## Pipeline

```bash
snakemake -n          # dry run
snakemake --cores 4   # full pipeline
snakemake output/figures/fig1_coefplot.png  # single target
```

## R Environment

- Managed with `renv`
- `renv::restore()` to install dependencies
- Key packages: [list based on analysis plan, e.g., survey, modelsummary, marginaleffects, ggplot2, data.table, haven]

## Relevant Skills

[Curate based on the analysis plan -- only list skills that apply to this project]

- `/datacheck` -- inspect new data files
- `/viz` -- create figures
- `/coefficient-plot` -- coefficient/forest plots
- `/survey-analysis` -- survey-weighted models
- `/finalize-analysis` -- organize outputs
- `/draft-paper` -- write manuscript

## Key Commands

```r
# Load cleaned data
df <- readRDS("data/processed/analysis_data.rds")

# Survey design (if applicable)
library(survey)
des <- svydesign(ids = ~[cluster], strata = ~[strata], weights = ~[weight], data = df)
```

## Conventions

- Scripts: `scripts/NN_description.R` (01_, 02_, etc.)
- Figures: `output/figures/figN_desc.png` + `.pdf` + `.md`
- Tables: `output/tables/tableN_desc.csv` + `.tex` + `.md`
- Data: `data/raw/` (immutable), `data/processed/`
- Config: `config.yaml` for random seeds and parameters
- Every figure/table gets a companion `.md` file documenting data, method, findings
```

---

## Customization Notes

- Remove survey design section if not applicable
- Adjust "Relevant Skills" to only include skills matching the analysis plan
- Fill in actual package names from what was discussed in the planning session
- Add any project-specific conventions (e.g., variable naming, coding standards)
