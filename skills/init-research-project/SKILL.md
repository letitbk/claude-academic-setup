---
name: init-research-project
description: Use when starting a new research project from data files and optionally a questionnaire, or when the user says "new project", "init project", "set up research", or provides raw data to begin analysis planning.
---

# Init Research Project

Set up a new research project from data files. Inspect data, generate codebook, conduct interactive research planning, scaffold project structure with reproducible pipeline.

## When to Use

- Starting fresh with a new dataset (CSV, .dta, .rds)
- User says "new project", "init project", "set up research", "start analysis"
- User provides raw data files and wants to begin planning
- Setting up a new research directory from scratch

## When NOT to Use

- Returning to an existing project (use `/catch-up`)
- One-off data inspection (use `/datacheck`)
- Already have clean scripts and want to finalize (use `/finalize-analysis`)

## Workflow

### Phase 1: Data Inspection

Run `/datacheck` on each data file provided. Additionally for .dta files, extract variable and value labels with `haven`. For CSV files, profile with `data.table::fread`.

Generate codebook to `docs/codebook.md`. See `references/codebook-generation.md` for format and R code.

**Done when**: Codebook written to `docs/codebook.md` and user confirms variable descriptions look correct.

### Phase 2: Questionnaire Cross-Reference (if provided)

Parse the questionnaire document. Match questionnaire items to data variables using labels and name patterns. Flag any unmatched variables or questionnaire items.

**Done when**: All variables matched or unmatched ones documented in the codebook.

### Phase 3: Research Planning Interview

Use AskUserQuestion (following `/brainstorming` patterns) for multiple rounds:

1. **Round 1**: Research question, contribution, what's new
2. **Round 2**: Key DV/IV, planned analyses, survey design elements (weights, clusters, strata)
3. **Round 3**: Target audience/journal, envisioned figures and tables
4. **Round 4+**: Clarifications until user says "that's enough" or questions become redundant

**Done when**: User indicates sufficient information gathered.

### Phase 4: Analysis Plan

Enter Plan mode. Write a living document to `docs/analysis-plan.md` with evolving specs for each expected output. Script numbering matches analysis step numbering. See `references/analysis-plan-template.md`.

**Done when**: Plan written and user approves the overall structure.

### Phase 5: External Review

Invoke `/codex` and `/gemini` to review the analysis plan. If either skill is unavailable, ask user to review manually or skip. Incorporate feedback.

**Done when**: Feedback incorporated and user confirms final plan.

### Phase 6: Scaffold Project

Create directory structure:
```
project/
├── data/raw/          # immutable original data
├── data/processed/
├── scripts/           # 01_cleaning.R, 02_measures.R, ...
├── output/figures/
├── output/tables/
├── docs/              # codebook.md, analysis-plan.md
├── manuscript/
├── config.yaml        # random seeds, parameters
├── CLAUDE.md          # project instructions (see references/claude-md-template.md)
└── .gitignore
```

Run `git init`, generate `.gitignore` (R/data patterns), create `CLAUDE.md` from template customized with planning session outputs. Optionally invoke `/setup-snakemake-pipeline`. Create `config.yaml` with random seeds. Initialize `renv`.

**Done when**: Directory structure exists, CLAUDE.md written, pipeline runnable.

## Quick Reference

| Output | Location |
|--------|----------|
| Codebook | `docs/codebook.md` |
| Analysis plan | `docs/analysis-plan.md` |
| Project instructions | `CLAUDE.md` |
| Config | `config.yaml` |
| Raw data | `data/raw/` (immutable) |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Skip raw byte inspection | Always run `/datacheck` first -- catches encoding, BOM, CR issues |
| Write plan without Q&A | MUST do interactive interview before writing analysis plan |
| Rigid specs instead of living document | Analysis plan should evolve -- mark items as tentative |
| Forget survey weights | Ask about survey design in Round 2 of planning interview |
| Skip git init | Always `git init` + `.gitignore` during scaffold phase |
| Skip questionnaire cross-reference | If questionnaire provided, always match to data variables |
