---
name: research-ideation
description: |
  Structured hypothesis generation from literature gaps. Maps existing research,
  identifies unanswered questions, generates citation-backed hypotheses, and
  assesses feasibility using a rubric (data, timeline, funding, methods).
author: BK
version: 1.0.0
date: 2026-02-20
---

# Research Ideation

Generate research ideas grounded in existing literature. Identifies gaps,
formulates testable hypotheses, and evaluates feasibility.

## When to Use This Skill

Trigger when user:
- Says "research ideas", "what should I study next"
- Asks for "hypothesis generation" or "gap analysis"
- Wants to "brainstorm research questions"
- Says "what's missing in the literature on..."
- Needs ideas for a "dissertation topic" or "new project"

## Prerequisites

- **Zotero MCP:** For searching user's existing library
- **WebSearch:** For discovering recent work beyond Zotero

## Workflow

### Phase 1: Scope the Domain

Use AskUserQuestion to clarify:
1. **Field/topic:** What broad area? (e.g., "social media and political polarization")
2. **Existing knowledge:** What do you already know? What have you published?
3. **Constraints:** Methods you can use, data you can access, timeline
4. **Goal:** Dissertation, journal article, grant proposal, pilot study?

### Phase 2: Map the Literature

1. Search user's Zotero library for existing collections in this area
2. Search externally for recent work (last 2-3 years)
3. Identify:
   - **Established findings:** What is well-documented and replicated?
   - **Active debates:** Where do researchers disagree?
   - **Methodological gaps:** What methods haven't been applied to this question?
   - **Population gaps:** Who hasn't been studied?
   - **Temporal gaps:** What time periods or contexts are missing?

### Phase 3: Generate Hypotheses

For each identified gap, generate:

```markdown
## Research Idea [N]: [Title]

**Research Question:** [Specific, testable question]

**Hypothesis:** [Directional prediction with theoretical justification]

**Grounded in:**
- [Citation 1]: Found X, but did not examine Y
- [Citation 2]: Called for future research on Z

**Proposed Method:** [Brief approach — survey, experiment, secondary data, etc.]

**Expected Contribution:** [What this would add to the field]
```

Generate 3-5 ideas, ranging from incremental to ambitious.

### Phase 4: Feasibility Assessment

Score each idea on a rubric:

| Criterion | Score (1-5) | Notes |
|-----------|-------------|-------|
| **Data availability** | | Existing data? Need to collect? |
| **Method feasibility** | | Do you have the skills/tools? |
| **Timeline fit** | | Can it be done in available time? |
| **Funding fit** | | Matches available/target funding? |
| **Publication potential** | | Which journals? How competitive? |
| **Novelty** | | How original relative to existing work? |

### Phase 5: Recommend Next Steps

For the top-rated idea(s):
1. Suggest a concrete first step (pilot study, data exploration, lit review)
2. Identify 2-3 key papers to read closely
3. Suggest potential co-authors or collaborators if relevant
4. Outline a rough timeline

## Key Principles

- Every hypothesis must be backed by specific citations showing the gap
- Distinguish between "nobody has studied this" and "nobody has studied this well"
- Prioritize feasibility over novelty — a doable study beats a brilliant one that can't be executed
- Be honest about limitations (data access, method constraints)
- Generate a range: some safe/incremental ideas and some high-risk/high-reward ones
