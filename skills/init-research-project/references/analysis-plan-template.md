# Analysis Plan Template

Use this structure for `docs/analysis-plan.md`. This is a **living document** -- items should be marked as tentative, confirmed, or revised as the project evolves.

---

```markdown
# Analysis Plan: [Project Title]

**Last updated**: [date]
**Status**: Draft / In Progress / Final

## Research Questions

1. [RQ1]: ...
2. [RQ2]: ...

## Data

- **Source**: [dataset name, version, citation]
- **N**: [total observations, expected analytic N after exclusions]
- **Key variables**: [DV, IV, controls, moderators -- reference codebook]
- **Survey design**: [weights, clusters, strata -- or "N/A"]
- **Quality notes**: [known issues from /datacheck, coded missings, exclusion criteria]

## Analysis Steps

Each step maps to a numbered script. Update status as work progresses.

| Step | Script | Input | Output | Operations | Status |
|------|--------|-------|--------|------------|--------|
| 1 | `scripts/01_data_cleaning.R` | `data/raw/*.dta` | `data/processed/clean.rds` | Recode missings, apply labels, create factors | Tentative |
| 2 | `scripts/02_create_measures.R` | `data/processed/clean.rds` | `data/processed/analysis_data.rds` | Construct scales, indices, derived variables | Tentative |
| 3 | `scripts/03_descriptives.R` | `data/processed/analysis_data.rds` | `output/tables/table1_descriptives.csv` | Sample descriptives, balance table | Tentative |
| 4 | `scripts/04_main_analysis.R` | `data/processed/analysis_data.rds` | `output/tables/table2_regression.tex` | Main regression models | Tentative |
| 5 | `scripts/05_figures.R` | Model objects | `output/figures/fig1_coefplot.png` | Coefficient plot | Tentative |
| ... | ... | ... | ... | ... | ... |

## Expected Outputs

### Tables

| Table | Description | Script | Status |
|-------|-------------|--------|--------|
| Table 1 | Sample descriptives / balance | 03 | Tentative |
| Table 2 | Main regression results | 04 | Tentative |
| ... | ... | ... | ... |

### Figures

| Figure | Description | Script | Status |
|--------|-------------|--------|--------|
| Figure 1 | Coefficient plot of main effects | 05 | Tentative |
| ... | ... | ... | ... |

## Statistical Methods

- **Primary**: [e.g., OLS with clustered SE, survey-weighted logistic regression]
- **Robustness**: [e.g., alternative specifications, different controls, sensitivity analysis]
- **Software**: R [packages: survey, modelsummary, marginaleffects, ggplot2]

## Notes

- [Design decisions, theoretical justifications, reviewer feedback, open questions]
- [Mark items with ⚠️ for unresolved decisions]
```

---

## Key Principles

- **Script numbering matches step numbering**: Step 3 -> `scripts/03_*.R`
- **Living document**: Update status column as scripts are written and outputs created
- **Evolving specs**: Mark early items as "Tentative"; change to "Confirmed" after user approval, "Done" after execution
- **Trace every output**: Each table/figure must map to a specific script and analysis step
