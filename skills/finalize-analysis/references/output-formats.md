# Output Format Specifications

## Figures

Always save both PNG and PDF:

```r
ggsave(output_png, plot = p, width = 7, height = 5, dpi = 300)
ggsave(output_pdf, plot = p, width = 7, height = 5)
```

### Dimension Guidelines

| Layout | Width | Height |
|--------|-------|--------|
| Single panel | 7 | 5 |
| Two panels side-by-side | 10 | 5 |
| Three panels | 12 | 5 |
| Tall coefficient plot (many terms) | 7 | 8 |
| Network graph | 7 | 7 |
| Full-page multi-panel | 10 | 8 |

Adjust height for coefficient plots based on number of terms: roughly 0.3 inches per term + 2 inches for margins.

## Tables

### Regression Tables (modelsummary)

```r
library(modelsummary)

models <- list(
  "Model 1" = m1,
  "Model 2" = m2,
  "Model 3" = m3
)

# CSV output
modelsummary(models, output = output_csv)

# LaTeX output
modelsummary(models,
  output = output_tex,
  stars = c("*" = 0.05, "**" = 0.01, "***" = 0.001),
  gof_omit = "IC|Log|RMSE",
  coef_rename = c(
    "var_name" = "Display Name"
  )
)
```

### Descriptive / Balance Tables

```r
library(modelsummary)

# Balance table by group
datasummary_balance(~ treatment,
  data = df,
  output = output_csv
)

datasummary_balance(~ treatment,
  data = df,
  output = output_tex
)
```

### Custom Tables

```r
library(data.table)

# CSV
fwrite(result_dt, output_csv)

# LaTeX (via kableExtra)
library(kableExtra)
kbl(result_dt, format = "latex", booktabs = TRUE) |>
  kable_styling() |>
  save_kable(output_tex)
```

### Optional Excel Output

```r
library(openxlsx)
write.xlsx(result_dt, output_xlsx)
```

## File Naming

```
output/figures/fig1_coefplot.png
output/figures/fig1_coefplot.pdf
output/figures/fig1_coefplot.md

output/tables/table1_descriptives.csv
output/tables/table1_descriptives.tex
output/tables/table1_descriptives.md
```

Pattern: `{type}{N}_{short_description}.{ext}`
- Figures: `fig1`, `fig2`, ...
- Tables: `table1`, `table2`, ...
- Description: lowercase, underscores, no spaces
