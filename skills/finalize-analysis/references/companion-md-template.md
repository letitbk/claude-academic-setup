# Companion .md File Templates

Every figure and table gets a companion .md file placed alongside the output. These files document what the output shows, how it was created, and what it means -- enabling `/draft-paper` to write data/methods/results sections directly from them.

## Naming Convention

```
output/figures/fig1_coefplot.png
output/figures/fig1_coefplot.pdf
output/figures/fig1_coefplot.md    <- companion file

output/tables/table1_descriptives.csv
output/tables/table1_descriptives.tex
output/tables/table1_descriptives.md   <- companion file
```

## Figure Companion Template

```markdown
# Figure N: [Descriptive Title]

## Data Source
- **Input file**: `data/processed/analysis_data.rds`
- **Variables**: [list variables used in the plot]
- **Sample**: [N observations, any exclusions applied]
- **Weights**: [weight variable used, or "unweighted"]

## Method
- **Model**: [e.g., OLS with clustered SE at state level]
- **Specification**: [DV ~ IV + controls]
- **Packages**: [e.g., ggplot2, marginaleffects, broom]
- **Error bars**: [95% CI / SE / none]

## Key Findings
- [Bullet 1: main pattern]
- [Bullet 2: notable comparison]
- [Bullet 3: any surprises]

## Interpretation
[1-2 sentences for a non-technical reader: what does this figure show and why does it matter?]

## Script
`scripts/07_figures.R` (lines XX-YY)
```

## Table Companion Template

```markdown
# Table N: [Descriptive Title]

## Data Source
- **Input file**: `data/processed/analysis_data.rds`
- **Sample**: [N observations, any exclusions]
- **Weights**: [weight variable, or "unweighted"]

## Model Details
- **Dependent variable**: [name and description]
- **Independent variables**: [list with descriptions]
- **Controls**: [list]
- **Standard errors**: [robust / clustered / survey-design-based]
- **Estimator**: [OLS / logit / svyglm / etc.]

## Key Findings
- [Bullet 1: main result]
- [Bullet 2: effect size and significance]
- [Bullet 3: notable pattern across specifications]

## Interpretation
[1-2 sentences: what do these results mean substantively?]

## Script
`scripts/04_main_analysis.R`
```

## Descriptive Table Companion (variant)

For balance tables, summary statistics, or frequency tables:

```markdown
# Table N: [Descriptive Title]

## Data Source
- **Input file**: `data/processed/analysis_data.rds`
- **Sample**: [N, subgroups if applicable]
- **Weights**: [weight variable, or "unweighted"]

## Contents
- **Variables shown**: [list]
- **Statistics**: [mean, SD, median, range, N]
- **Grouping**: [by treatment/demographic/none]

## Key Patterns
- [Bullet 1]
- [Bullet 2]

## Script
`scripts/03_descriptives.R`
```
