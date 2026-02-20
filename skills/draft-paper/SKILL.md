---
name: draft-paper
description: Use when writing a research paper draft from completed analysis results, or when the user says "write paper", "draft manuscript", "start writing", or wants to turn analysis outputs into a publication-ready document with literature review.
---

# Draft Paper

Write a research paper from analysis results, companion .md files, and iterative user input. Covers literature review, all manuscript sections, and LaTeX assembly.

## Preconditions

Check for companion .md files in `output/figures/` and `output/tables/` (from `/finalize-analysis`). If found, use them as the basis for data/methods/results sections. If not found, read raw output files and ask user to describe findings for each.

## When to Use

- Analysis complete, want to write up results
- User says "write paper", "draft manuscript", "start writing"
- Turning completed figures and tables into a publication
- Need literature review integrated with findings

## When NOT to Use

- Analysis still ongoing (use `/finalize-analysis`)
- Single section in isolation (just write it directly)
- Editing an existing draft (just edit directly)

## Workflow

### Phase 1: Synthesize Findings

Scan `output/` for companion .md files. If none exist, read output files directly and ask user to describe each. Summarize all findings in a structured overview.

**Done when**: User confirms the summary captures the key results.

### Phase 2: Abstract Drafting

AskUserQuestion about most significant findings, preferred framing, contribution to the field. Write 150-250 word abstract. Get approval.

**Done when**: User approves the abstract draft.

### Phase 3: Literature Review Planning

Enter Plan mode. Ask user about preferred structure (thematic, theoretical, gap-driven). Identify search topics from findings. Ask detailed questions about theoretical framework, comparison studies, methodological precedents. Create search plan. See `references/literature-review-workflow.md`.

**Done when**: Search plan written with topics and user approves.

### Phase 4: Execute Literature Review

**Primary — `/gemini`**: Invoke `/gemini` for each search topic to discover papers. If `/gemini` is unavailable, use WebSearch tool directly. For each paper found, extract key claims, methods, sample, relevance.

**Secondary — Zotero MCP**: Search the user's Zotero library using `zotero_search_items` and `zotero_semantic_search` to find papers already collected on each topic. For Zotero hits, use `zotero_get_item_metadata` with `format: bibtex` to export citations directly. Use `zotero_get_item_fulltext` for deeper reading when needed.

**Build .bib incrementally**: Export BibTeX from Zotero when available; hand-write entries (cite key: `firstauthorYYYYkeyword`) for papers found only via `/gemini`. Build literature matrix (see `references/literature-review-workflow.md`).

**Done when**: All topics searched, literature matrix complete, .bib has entries.

### Phase 5: Analyze Literature vs Findings

Map findings against literature: knowledge gaps, methodological implications, theoretical implications, mechanisms/theories explaining discovered patterns.

**Done when**: Gap analysis documented and user confirms framing.

### Phase 6: Write Introduction + Literature Review

Draft both sections. Invoke `/codex` for review (or ask user to review if unavailable). Ask user for feedback. Iterate.

**Done when**: User approves both sections.

### Phase 7: Write Data/Methods/Results

Rewrite from companion .md files. AskUserQuestion about presentation level (technical vs accessible), emphasis, what to highlight or downplay, what to include or exclude from appendix.

**Done when**: User approves these sections.

### Phase 8: Write Discussion + Conclusion

Connect findings to literature. AskUserQuestion about policy implications, limitations the user wants to acknowledge, future research directions.

**Done when**: User approves.

### Phase 9: Revise Abstract + Assemble LaTeX

Update abstract to reflect final paper. Create `manuscript/paper.tex` using the ASR/Science-style template (see `references/latex-template.md`): title page, author bios, all sections, `\input{}` for tables, `\includegraphics{}` for figures, BibTeX references. Copy `asr.bst` and `scicite.sty` from skill `assets/` to `manuscript/`. Compile with pdflatex + bibtex.

**Done when**: LaTeX compiles without errors.

## Quick Reference

| Phase | Produces | Skills Used |
|-------|----------|-------------|
| Synthesize | Findings summary | -- |
| Abstract | 150-250 word draft | -- |
| Lit review plan | Search topics | `/brainstorming` patterns |
| Execute lit review | .bib entries, lit matrix | `/gemini`, Zotero MCP, WebSearch |
| Analyze gaps | Gap analysis doc | -- |
| Intro + lit review | Manuscript sections | `/codex` for review |
| Data/methods/results | Manuscript sections | -- |
| Discussion | Manuscript sections | -- |
| Assemble | `manuscript/paper.tex` | -- |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Writing without reading companion .md files | Always read output/*.md files first |
| Skipping lit review planning | Plan search topics before searching |
| One-shot writing without user input | Ask user between each section |
| Building .bib at the end | Add entries incrementally during lit review |
| Generic discussion not tied to results | Connect every discussion point to a specific finding |
| Forgetting to update abstract | Revise abstract after all sections written |
