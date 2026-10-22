# Skill trigger scenarios

Use these prompts when manually testing the bundled skills in Claude Code or Codex. A passing result uses the named skill and stays within its boundary; a failing result ignores the skill, invokes unrelated workflows, or performs destructive or external actions without approval.

| Skill | Test prompt | Expected behavior |
|---|---|---|
| `napkin` | “We learned that this repository always uses `make verify`, not `make test`. Remember that correction for future sessions.” | Records one concise, project-specific lesson without turning the napkin into a transcript. |
| `plain-writing` | “Rewrite this setup paragraph for a researcher who has never used a coding agent.” | Uses direct language, preserves meaning, and removes jargon or explains it. |
| `datacheck` | “I just received `survey.csv`. Inspect it before we begin analysis.” | Profiles structure, missingness, duplicates, ranges, labels, and join keys before modeling. |
| `viz` | “Plot the distribution of age by treatment group and save a publication-ready figure.” | Clarifies the comparison, chooses an appropriate chart, renders it, and checks the output visually. |
| `codex` | “Ask Codex to review my uncommitted changes for correctness.” | Runs a read-only Codex review and reports findings without applying them. |
| `clean-survey-data` | “Clean these survey exports and preserve their value labels.” | Audits first, documents missing-value and recode decisions, and keeps a reproducible raw-to-clean path. |
| `marginaleffects` | “Report average marginal effects from this logistic regression with confidence intervals.” | Chooses the estimand and scale explicitly, computes uncertainty, and keeps reference categories clear. |
| `survey-analysis` | “Estimate a weighted mean and regression from this complex survey.” | Defines the survey design before analysis and uses design-aware estimates and standard errors. |
| `qualtrics-survey` | “Add a question to my Qualtrics survey through the API.” | Inspects the survey and confirms the target before mutation, without exposing the API token. |
| `journal-figures` | “Check whether `figure.pdf` meets ASR submission requirements.” | Runs the bundled validator, inspects the rendered figure, and distinguishes automated checks from visual judgment. |
| `journal-tables` | “Turn these model estimates into an ASR-style regression table.” | Produces and inspects a typeset table plus an editable source, rather than returning only CSV or Markdown. |

## Boundary checks

- Asking for an ordinary code edit should not trigger a research skill.
- `datacheck` should inspect a new dataset but should not silently clean or model it.
- `viz` should build a chart; `journal-figures` should format or validate a finished chart.
- `marginaleffects` should compute effects; `journal-tables` should typeset the results.
- The `codex` skill is present only in the Claude installation.
- Research skills should mention missing external dependencies instead of installing them automatically.
