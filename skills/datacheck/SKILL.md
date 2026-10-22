---
name: datacheck
description: Use when starting work with a new data file, before analysis or visualization, when parsing fails, when values look unexpected, or when the user asks what a dataset contains.
---

# Data check

Inspect before analyzing. Do not modify the source file.

## Check

1. Identify the format, size, encoding, delimiter or workbook sheets, and the tool needed to read it.
2. Report row and column counts, names, inferred types, and a small safe preview.
3. Measure missingness, duplicate rows or identifiers, constant columns, and parse failures.
4. For numeric fields, inspect ranges and impossible values. For categorical fields, inspect levels and rare or blank values. For dates, inspect coverage and failed conversions.
5. Look for labels, codebooks, weight variables, strata, clusters, identifier fields, and special missing-value codes.
6. State what is known, what needs confirmation, and what must be fixed before analysis.

Use the file's native ecosystem when practical, such as `readr` or `haven` in R, `pandas` in Python, or a read-only workbook inspection for Excel. Sample very large files before loading everything.

Never assume that values such as `9`, `99`, or `999` mean missing. Confirm them from labels, a codebook, or the user. Do not expose direct identifiers or sensitive values in the report.

## Output

Return a compact report with:

- file and structure;
- quality findings;
- variables that need clarification;
- recommended next step;
- the command or logged evidence used for the inspection.
