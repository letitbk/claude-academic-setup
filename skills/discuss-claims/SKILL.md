---
name: discuss-claims
description: Use when the user wants to create GitHub issues for internal team discussion of core empirical claims in a research paper, or when the user says "post issues", "create claim issues", "set up GitHub discussion", or "discuss findings on GitHub".
---

# Discuss Claims

Post self-contained GitHub issues for internal team discussion of core empirical claims. Each issue covers one claim: motivation, methods, findings (with inline figure/table links), interpretation, implications, and limitations.

## When to Use

- User wants to share analysis findings with co-authors via GitHub Issues
- User says "post issues", "create claim issues", "discuss on GitHub", "set up review"
- Analysis pipeline is complete and output files exist

## When NOT to Use

- User wants a formal reviewer template with feedback/decision boxes (this skill creates discussion threads, not review forms)
- Repo is public and findings are embargoed
- Output files have not been generated yet

## Workflow

### Phase 0: Pre-flight

Run these checks before touching GitHub. Fix any failures before proceeding.

```bash
# 1. Issues enabled?
gh repo view OWNER/REPO --json hasIssuesEnabled

# 2. Existing [DISCUSS] issues?
gh issue list --state open | grep "\[DISCUSS\]"

# 3. Find untracked output files and auto-commit them
git ls-files --others --exclude-standard output/
# If any exist: git add output/ && git commit -m "Add output files for co-author review" && git push
```

**CRITICAL — broken links are the #1 failure mode**: GitHub blob links return 404 if the file is not committed and pushed. Always verify with `git ls-files --error-unmatch <file>` for at least a sample of referenced figures/tables before creating any issue.

### Phase 1: Collect Project Metadata

Infer from git or ask the user:
- GitHub repo: `owner/repo` (infer from `git remote get-url origin`)
- Branch: `master` or `main` (infer from `git symbolic-ref refs/remotes/origin/HEAD`)
- Output directories: where figures and tables live (default: `output/figures/`, `output/tables/`)

Construct the base blob URL:
```
https://github.com/OWNER/REPO/blob/BRANCH/PATH/TO/file.png
```

### Phase 2: Discover Output Files

Scan the output directories and build a menu for the user to pick from per claim:

```bash
ls output/figures/*.png   # PNG only — PDFs do NOT render inline on GitHub
ls output/tables/*.csv
ls output/reports/*.md
ls code/                  # analysis scripts
```

**PNG rule**: Always link `.png` files, never `.pdf`. GitHub renders PNG inline; PDFs show as download links only.

### Phase 3: Collect Claim Content (interactive, repeat N times)

Ask the user how many claims there are. Then for each claim, collect via `AskUserQuestion` or open-ended prompts:

1. **1-sentence claim statement** (becomes the issue title: `[DISCUSS] Claim N: ...`)
2. **Motivation**: Why this analysis? What gap or puzzle does it address?
3. **Method**: What is the estimand? What design/scripts were used?
4. **Key numbers**: The 3–5 most important statistics
5. **Figures + tables**: User picks from the discovered file list (Phase 2)
6. **Interpretation**: What does the finding mean substantively?
7. **Implications**: Why does it matter for the paper's contribution?
8. **Limitations** (optional): Caveats and open questions

### Phase 4: Create Master Tracker (Issue #1)

Always create this first so it gets the lowest issue number. Body contains:
- One-paragraph project description
- Navigation table: `| Issue | Claim | One-line summary |`
- Links to findings report, scripts dir, figures dir, tables dir

No labels. No milestone. No reviewer instructions.

### Phase 5: Create Claim Issues (Issues #2 onward)

For each claim, create one issue using this structure:

```markdown
## Motivation
[Why this analysis / what gap it fills]

## Data & Method
[Estimand, design, identification strategy]
**Scripts**: [script1.R](blob-url) · [script2.R](blob-url)

## Findings
[Key numbers in a table or bullets]

**Figures**:
- [figXX.png](blob-url) — [what to look at]

**Tables**: [tabXX.csv](blob-url) · ...
**Script reports**: [report.md](blob-url) · ...

## Interpretation
[What the pattern means]

## Implications
[Why it matters for the paper]

## Limitations & Open Questions
[Caveats, future directions — optional but encouraged]
```

**Never include**: labels, milestones, reviewer feedback sections, decision boxes, or tagging conventions like `[SUBSTANTIVE]`.

### Phase 6: Output

1. Print a summary table of all created issues with URLs.
2. Open the tracker in the browser: `gh issue view 1 --repo OWNER/REPO --web`

## Quick Reference

| Step | Command |
|------|---------|
| Check Issues enabled | `gh repo view OWNER/REPO --json hasIssuesEnabled` |
| Find untracked outputs | `git ls-files --others --exclude-standard output/` |
| Auto-commit outputs | `git add output/ && git commit -m "Add output files" && git push` |
| Verify file tracked | `git ls-files --error-unmatch output/figures/fig.png` |
| Create issue | `gh issue create --repo OWNER/REPO --title "..." --body "..."` |
| Remove labels if present | `gh issue edit N --repo OWNER/REPO --remove-label "label1,label2"` |
| Open in browser | `gh issue view N --repo OWNER/REPO --web` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Link to untracked files → 404 | `git ls-files --error-unmatch` on sample files; auto-commit output/ first |
| Use PDF links | Switch to `.png` — PDFs don't render inline on GitHub |
| Include reviewer structure | This skill makes discussion threads: no feedback boxes, no decision fields |
| Create claim issues before tracker | Tracker must be first to get the lowest issue number |
| Add labels | Never add labels — always create clean, unlabeled issues |
| Use `raw` GitHub URLs | Use `blob` URLs — renders PNG inline and CSV as formatted table |
