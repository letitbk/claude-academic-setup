# Skill trigger scenarios

Use these prompts when manually testing the bundled skills in Claude Code or Codex. A passing result uses the named skill and stays within its boundary; a failing result ignores the skill, invokes unrelated workflows, or performs destructive or external actions without approval.

| Skill | Test prompt | Expected behavior |
|---|---|---|
| `napkin` | “We learned that this repository always uses `make verify`, not `make test`. Remember that correction for future sessions.” | Records one concise, project-specific lesson without turning the napkin into a transcript. |
| `plain-writing` | “Rewrite this setup paragraph for a researcher who has never used a coding agent.” | Uses direct language, preserves meaning, and removes jargon or explains it. |
| `datacheck` | “I just received `survey.csv`. Inspect it before we begin analysis.” | Profiles structure, missingness, duplicates, ranges, labels, and join keys before modeling. |
| `viz` | “Plot the distribution of age by treatment group and save a publication-ready figure.” | Clarifies the comparison, chooses an appropriate chart, renders it, and checks the output visually. |
| `codex` | “Ask Codex to review my uncommitted changes for correctness.” | Runs a read-only Codex review and reports findings without applying them. |
| `agy` | “Get a Gemini second opinion on this plan with agy.” | Runs one `agy -p` review, reports findings, and stops without applying them. |
| `claude` | In Codex: “Ask Claude to critique this implementation plan.” | Runs a read-only Claude review and reports findings without applying them. |

## Boundary checks

- Asking for an ordinary code edit should not trigger a review skill.
- `datacheck` should inspect a new dataset but should not silently clean or model it.
- The `codex` skill is present only in the Claude installation, and the `claude` skill only in the Codex installation.
- A review skill should report a missing CLI instead of installing it automatically.
