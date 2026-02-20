---
name: finalize-analysis
description: Use when organizing exploratory analyses into a clean reproducible project with publication-ready outputs, or when the user says "clean up", "finalize", "make reproducible", "prepare for publication", or has messy scripts needing structure.
---

# Finalize Analysis

Organize messy exploratory work into a clean reproducible project with Snakemake pipeline and publication-ready outputs. Create one figure or table at a time with user approval.

## Preconditions

Check for `docs/analysis-plan.md` and `docs/codebook.md` (from `/init-research-project`). If found, use them to guide organization. If not found, ask user about research goals and data before proceeding.

## When to Use

- Exploratory analysis done, need clean reproducible outputs
- Messy scripts need organizing into numbered pipeline
- User says "clean up", "finalize", "make reproducible", "prepare for publication"
- Ready to create publication-quality figures and tables

## When NOT to Use

- Starting from scratch with new data (use `/init-research-project`)
- Single plot or table (use `/viz`, `/coefficient-plot`, etc.)
- Already have clean pipeline, just need paper (use `/draft-paper`)

## Workflow

### Step 1: Scope Decision

AskUserQuestion: New directory or restructure existing? What to preserve? What to discard?

**Done when**: User confirms scope choice.

### Step 2: Survey Existing Work

Scan project for scripts, figures, tables, data files. Present inventory as a table. Ask what to keep, drop, or revise.

**Done when**: Keep/drop decisions made for all existing outputs.

### Step 3: Plan Structure

Propose numbered script sequence following the standard pipeline (see `references/project-script-workflow.md`). Confirm with user.

**Done when**: User approves script sequence.

### Step 4: Iterative Output Creation (core loop)

For each figure or table, **one at a time**:

1. **Discuss**: AskUserQuestion about what the output shows, data source, design preferences. Suggest ideas for key tables.
2. **Write script**: Create numbered R script. Chain to `/viz`, `/coefficient-plot`, `/marginaleffects`, `/survey-analysis` as appropriate.
3. **Execute and show**: Run script, display result to user.
4. **Iterate**: Ask for tweaks, loop until approved.
5. **Document**: Write companion .md file (see `references/companion-md-template.md`).
6. **Update pipeline**: Add Snakemake rule. Update data cleaning/measure creation scripts if needed.

**Done when**: User approves the output and companion .md is written.

### Step 5: Output Formats

Every figure saved as PNG (300dpi) + PDF. Every table saved as CSV + LaTeX (`modelsummary`). Optionally Excel. See `references/output-formats.md` for dimensions and code patterns.

### Step 6: Finalize

Update CLAUDE.md with final script list and output inventory. Verify full pipeline:
```bash
snakemake -n          # dry run
snakemake --cores 4   # full run
```

**Done when**: Pipeline runs end-to-end without error.

## Quick Reference

| Analysis Type | Chain to Skill |
|--------------|----------------|
| Descriptive stats | `/survey-analysis` (if weighted) |
| Regression table | `/survey-analysis` or R directly |
| Coefficient plot | `/coefficient-plot` |
| Marginal effects | `/marginaleffects` then `/marginal-effects-plot` |
| Distribution plot | `/distribution-boxplot` or `/viz` |
| Any custom figure | `/viz` |
| Robustness checks | `/robustness-checks` |
| Subgroup analysis | `/heterogeneity-analysis` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Batch-creating all scripts at once | One output at a time with user approval |
| Skipping companion .md files | Every figure and table gets a companion .md |
| Hardcoded file paths | Use `here::here()` or Snakemake input/output paths |
| Only saving PNG | Always save both PNG (300dpi) and PDF |
| Not updating pipeline | Add Snakemake rule after each new script |
| Ignoring existing analysis plan | If `docs/analysis-plan.md` exists, follow it |
