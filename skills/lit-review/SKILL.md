---
name: lit-review
description: |
  Conduct structured literature reviews using Zotero MCP and paper-search-mcp.
  Search academic databases, screen abstracts, extract findings, and synthesize
  into thematic reviews with citation keys and evidence tables.
author: BK
version: 1.0.0
date: 2026-02-20
---

# Literature Review

Conduct structured literature reviews by searching academic databases, screening
abstracts, and synthesizing findings into organized reviews with proper citations.

## When to Use This Skill

Trigger when user:
- Says "literature review", "find papers", "search literature"
- Asks "what does the research say about..."
- Wants to "review the evidence on..."
- Needs a "systematic search" or "scoping review"
- Says "find relevant papers" or "search for studies"

## Prerequisites

- **Zotero MCP:** Must be configured in mcpServers (for library search, metadata, fulltext, annotations)
- **paper-search-mcp:** Must be configured (for PubMed, arXiv, Semantic Scholar queries)
- Zotero desktop app should be running for full-text access

## Workflow

### Phase 1: Define Search Strategy

Use AskUserQuestion to clarify:
1. **Topic:** What specific research question or topic?
2. **Scope:** Systematic review, scoping review, or quick survey?
3. **Databases:** Which to search? (PubMed, arXiv, Semantic Scholar, Zotero library)
4. **Inclusion criteria:** Date range, study type, population, language
5. **Exclusion criteria:** What should be filtered out?

### Phase 2: Search Databases

1. Search user's Zotero library first (using Zotero MCP search tools — exact tool names depend on installed server)
2. Search external databases via paper-search-mcp
3. Deduplicate results across sources
4. Present initial hit counts by database

### Phase 3: Screen Abstracts

1. Retrieve abstracts for all hits
2. Apply inclusion/exclusion criteria
3. Present screening summary:
   - Total found: N
   - After deduplication: N
   - After screening: N
   - Excluded (with reasons): N

### Phase 4: Extract and Synthesize

1. For included papers, retrieve full text where available (via Zotero MCP fulltext tools)
2. Extract key findings into an evidence table:

| Author (Year) | Study Design | Sample | Key Finding | Relevance |
|---------------|-------------|--------|-------------|-----------|

3. Group findings by theme
4. Identify convergent and divergent findings
5. Note gaps in the literature

### Phase 5: Write Review

Output a structured markdown review:

```markdown
# Literature Review: [Topic]

## Search Strategy
- Databases searched: ...
- Search terms: ...
- Date range: ...
- Inclusion/exclusion criteria: ...

## Results
- N papers identified, N included after screening

## Thematic Findings

### Theme 1: [Name]
[Synthesis of findings with citations]

### Theme 2: [Name]
[Synthesis of findings with citations]

## Gaps and Future Directions
[What questions remain unanswered]

## Evidence Summary Table
[Table from Phase 4]

## References
[Citation keys from Zotero]
```

## Key Principles

- Always start with the user's existing Zotero library before searching externally
- Use citation keys that match the user's Zotero library format
- Present screening decisions transparently (not just final counts)
- Distinguish between what evidence says vs. what is absent from the literature
- For systematic reviews, follow PRISMA-style reporting where possible
