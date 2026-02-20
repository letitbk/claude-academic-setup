---
name: citation-verification
description: |
  Cross-check citations in a manuscript against Zotero library and Crossref.
  Verify author names, years, titles, journals, DOIs. Flag mismatches,
  missing citations, orphaned references, and formatting inconsistencies.
author: BK
version: 1.0.0
date: 2026-02-20
---

# Citation Verification

Cross-check all citations in a manuscript against the user's Zotero library
and external sources (Crossref) to catch errors before submission.

## When to Use This Skill

Trigger when user:
- Says "check citations", "verify references", "bibliography check"
- Asks to "audit my citations" or "check my bibliography"
- Wants to verify "all references are correct" before submission
- Says "find missing citations" or "check for orphaned references"

## Prerequisites

- **Zotero MCP:** Must be configured for library matching
- **WebFetch:** For Crossref API DOI verification (https://api.crossref.org/)
- Manuscript file (markdown, .tex, or .docx) accessible in working directory

## Workflow

### Phase 1: Parse Manuscript

1. Read the manuscript file
2. Detect citation style from context:
   - **APA:** (Author, Year) or Author (Year)
   - **Chicago:** Footnote/endnote style
   - **BibTeX/natbib:** \cite{key}, \citep{key}, \citet{key}
3. Extract all in-text citations and bibliography entries
4. Report: "Found N in-text citations and M bibliography entries"

### Phase 2: Match Against Zotero

For each bibliography entry:
1. Search Zotero library by title, author, year (using `zotero_search_items`)
2. Compare fields:
   - Author names (first/last, ordering, et al. usage)
   - Publication year
   - Article/chapter title
   - Journal/book title
   - Volume, issue, pages
3. Score match confidence: HIGH (exact match), MEDIUM (minor differences), LOW (significant mismatch), NONE (not in Zotero)

### Phase 3: Verify DOIs

For entries with DOIs:
1. Query Crossref API: `https://api.crossref.org/works/{doi}`
2. Compare returned metadata against manuscript bibliography
3. Flag discrepancies (wrong year, different title, retracted status)

### Phase 4: Cross-Reference Check

1. **Orphaned references:** In bibliography but never cited in text
2. **Missing references:** Cited in text but not in bibliography
3. **Duplicate entries:** Same work listed multiple times with different keys
4. **Inconsistent formatting:** Mixed citation styles within the document

### Phase 5: Generate Report

```markdown
# Citation Audit Report

## Summary
- In-text citations: N
- Bibliography entries: M
- Verified against Zotero: X matches
- DOI-verified: Y entries
- Issues found: Z

## Issues

### Critical (must fix)
- [ ] Missing reference: "Smith (2023)" cited on p.5 but not in bibliography
- [ ] Wrong year: Bibliography says 2022, Crossref confirms 2023 for DOI:xxx

### Warning (review recommended)
- [ ] Author name mismatch: "J. Smith" in text vs "John Smith" in bibliography
- [ ] Orphaned reference: "Jones et al. (2021)" in bibliography but never cited

### Info (style consistency)
- [ ] Mixed "et al." threshold: some citations use et al. at 3+ authors, others at 6+

## Verified Entries (no issues)
[List of clean citations]
```

## Key Principles

- Report false positives with LOW confidence rather than suppressing them
- Distinguish critical errors (missing/wrong citations) from style issues
- Always check both directions: text→bibliography and bibliography→text
- For DOI verification, respect Crossref rate limits (polite pool: 50 req/sec with mailto header)
- Do not modify the manuscript — only report findings
