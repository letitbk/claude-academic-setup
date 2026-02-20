# Literature Review Workflow

## Table of Contents

- [Structure Options](#structure-options)
- [Topic Generation](#topic-generation)
- [Search Execution](#search-execution)
- [BibTeX Conventions](#bibtex-conventions)
- [Literature Matrix](#literature-matrix)
- [Gap Analysis Framework](#gap-analysis-framework)
- [Integration Mapping](#integration-mapping)

---

## Structure Options

Ask the user which structure fits their paper:

| Structure | When to Use | Organization |
|-----------|-------------|--------------|
| Thematic | Multiple distinct themes in findings | Group by theme (e.g., "Social media & well-being", "Platform differences") |
| Theoretical | Strong theoretical framework | Organize around theory, hypotheses, predictions |
| Gap-driven | Filling a clear hole in literature | What we know -> What we don't -> How this paper fills the gap |
| Methodological | Novel method or data | Prior methods -> Limitations -> This paper's approach |
| Chronological | Evolving field | Historical development -> Current state -> Open questions |

Most social science papers use **thematic** or **gap-driven**.

## Topic Generation

Generate search topics from the project's findings and analysis plan:

1. **Core constructs**: Each DV and key IV is a topic (e.g., "social media use and political polarization")
2. **Mechanisms**: Theorized pathways between IV and DV (e.g., "echo chambers", "algorithmic curation")
3. **Methods**: Prior work using similar methods (e.g., "survey experiments on media effects")
4. **Context**: Population or setting (e.g., "political attitudes among young adults")
5. **Contrasts**: Findings that differ from expectations (e.g., "null effects of social media on...")

Aim for 5-8 topics. Each becomes a search query.

## Search Execution

### 1. Primary: Using `/gemini`

For each topic, invoke `/gemini` with a prompt like:

```
Find recent academic research (2015-2025) on [TOPIC]. For each relevant paper, provide:
1. Full citation (authors, year, title, journal)
2. Key finding relevant to [TOPIC]
3. Method and sample
4. How it relates to [our research question]

Focus on peer-reviewed journal articles. Include seminal/foundational papers even if older.
```

If `/gemini` is unavailable, use WebSearch with queries like:
- `"[topic]" site:scholar.google.com`
- `"[topic]" journal article [year range]`
- `"[topic]" systematic review OR meta-analysis`

### 2. Secondary: Using Zotero MCP

Search the user's Zotero library to find papers already collected on each topic. This supplements `/gemini` by surfacing papers the user has previously read and organized.

**Keyword search** — broad text match:
```
zotero_search_items(query="[TOPIC]", qmode="everything", limit=20)
```

**Semantic search** — finds conceptually related papers even without keyword overlap:
```
zotero_semantic_search(query="[TOPIC]", limit=10)
```

**Export BibTeX** — for each relevant hit, get citation directly:
```
zotero_get_item_metadata(item_key="[KEY]", format="bibtex")
```

**Deep reading** — get full text when you need to understand a paper's argument:
```
zotero_get_item_fulltext(item_key="[KEY]")
```

**Browse by tag or collection** — if the user organizes by topic:
```
zotero_search_by_tag(tag=["[TAG]"], limit=20)
zotero_get_collection_items(collection_key="[KEY]", limit=50)
```

### Per-source extraction

For each paper found (from any source), record:
- Full citation
- Key claims (1-2 sentences)
- Method and sample size
- Relevance to this project (1 sentence)

## BibTeX Conventions

### Cite Key Format

`firstauthorYYYYkeyword`

Examples:
- `smith2022polarization`
- `gonzalez2019social`
- `chen2021survey`

### Entry Format

```bibtex
@article{smith2022polarization,
  author  = {Smith, John A. and Doe, Jane B.},
  title   = {Social Media and Political Polarization: A Panel Study},
  journal = {Journal of Communication},
  year    = {2022},
  volume  = {72},
  number  = {3},
  pages   = {415--438},
  doi     = {10.1093/joc/jqac012}
}
```

Add entries to `manuscript/references.bib` incrementally as papers are found. Do not wait until the end.

**Prefer Zotero export**: When a paper is in the user's Zotero library, use `zotero_get_item_metadata(item_key, format="bibtex")` to get the citation. The cite key will come from Zotero's export (or Better BibTeX if configured). Only hand-write BibTeX entries for papers found exclusively via `/gemini` or WebSearch.

## Literature Matrix

Build a matrix to track all sources:

```markdown
| Citation | Key Finding | Method | Sample | Relevance |
|----------|-------------|--------|--------|-----------|
| Smith et al. (2022) | Social media increases affective polarization | Panel survey, 2 waves | N=2,400 US adults | Direct comparison to our DV |
| Gonzalez (2019) | No effect on issue polarization | Cross-sectional survey | N=5,000 | Contrasts with our finding |
| Chen et al. (2021) | Echo chamber effects moderated by age | Experiment + survey | N=800 students | Supports our heterogeneity result |
```

Store the matrix in `manuscript/lit_matrix.md` for reference during writing.

## Gap Analysis Framework

After completing the literature search, analyze gaps:

### Knowledge Gaps
- What questions remain unanswered in the literature?
- What populations or contexts are understudied?
- Where do findings conflict?

### Methodological Gaps
- What methods haven't been applied to this question?
- What data limitations exist in prior work?
- What design improvements does this paper offer?

### Population Gaps
- Which groups are underrepresented in prior research?
- Does this paper study a novel population?

### Mechanism Gaps
- What causal pathways are proposed but untested?
- What mediators or moderators are unexplored?

## Integration Mapping

Map each of your findings to the literature:

```markdown
| Our Finding | Confirms | Contradicts | Extends |
|-------------|----------|-------------|---------|
| Main effect of X on Y | Smith (2022), Lee (2020) | Gonzalez (2019) | New population |
| Moderating role of Z | Chen (2021) | -- | Stronger design |
| Null effect of W | -- | Jones (2018) | Different measurement |
```

This mapping directly feeds the Discussion section: each row becomes a paragraph connecting your result to prior work.
