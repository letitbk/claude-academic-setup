# Paper Writing Workflow

Detailed guidance for each phase of the `/draft-paper` skill.

## Section Length Guidelines

| Section | Pages | Words (approx) |
|---------|-------|-----------------|
| Abstract | 1 paragraph | 150-250 |
| Introduction | 2-3 | 1000-1500 |
| Literature Review | 5-8 | 2500-4000 |
| Data & Methods | 2-4 | 1000-2000 |
| Results | 3-5 | 1500-2500 |
| Discussion | 3-5 | 1500-2500 |
| Conclusion | 1-2 | 500-1000 |

Adjust based on target journal norms. Some journals combine intro + lit review or discussion + conclusion.

## Phase-by-Phase Guidance

### Phase 1: Synthesize Findings
- Read every companion .md file in `output/figures/` and `output/tables/`
- Build a structured summary: main findings, secondary findings, null results
- Ask user: "Did I miss anything? Are there findings not captured in the outputs?"

### Phase 2: Abstract Drafting
- Ask: What is the single most important finding? What should a reader take away?
- Structure: Background (1-2 sentences) -> Gap -> Method -> Key findings -> Implication
- Keep under 250 words

### Phase 3: Literature Review Planning
- Ask about theoretical framework: What theories explain these patterns?
- Ask about comparison studies: Who has studied similar questions?
- Ask about methodological precedents: Who uses similar methods?
- Create 5-8 search topics from the answers

### Phase 4: Execute Literature Review
- **Primary**: Search each topic using `/gemini` (or WebSearch fallback) to discover new papers
- **Secondary**: Search user's Zotero library via `zotero_search_items` and `zotero_semantic_search` to find papers already collected
- For each relevant paper: extract citation, key finding, method, relevance
- Export BibTeX from Zotero when available; hand-write for `/gemini`-only finds
- Add BibTeX entries to `manuscript/references.bib` immediately
- Build literature matrix (see `references/literature-review-workflow.md`)

### Phase 5: Gap Analysis
- Map: which findings confirm prior work? Contradict? Extend?
- Identify: knowledge gaps, methodological gaps, population gaps
- Ask user to confirm the framing before writing

### Phases 6-8: Writing Sections
- **Iteration pattern**: write section -> invoke `/codex` for review -> ask user for feedback -> revise
- If `/codex` unavailable, present section to user directly for review
- Ask between sections: "Ready for the next section, or changes to this one?"

### Phase 9: Assembly
- Update abstract to reflect final content
- Assemble LaTeX with `\input{}` for tables, `\includegraphics{}` for figures
- Compile and fix any LaTeX errors

## Writing Principles

- Write from companion .md files, not from memory
- Every claim in results must point to a specific table or figure
- Every discussion point must connect to a specific finding AND prior literature
- Ask the user before making framing decisions (e.g., which finding to lead with)
- Use `/stop-slop` patterns: avoid hedging phrases, AI writing tells, empty transitions
