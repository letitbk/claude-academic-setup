---
name: skill-creator
description: Use when creating new skills, editing existing skills, scaffolding skill directories, packaging skills for distribution, or verifying skills work before deployment. Combines Anthropic's official skill authoring guide with TDD methodology.
---

# Skill Creator

Create effective skills using TDD methodology with scaffolding scripts.

## Overview

**Skills are TDD applied to process documentation.** Write test cases (pressure scenarios), watch them fail (baseline behavior), write the skill, watch tests pass, and refactor.

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

## Quick Start

```bash
# Initialize new skill
scripts/init_skill.py my-skill --path ~/.claude/skills

# Validate skill structure
scripts/quick_validate.py ~/.claude/skills/my-skill

# Package for distribution
scripts/package_skill.py ~/.claude/skills/my-skill
```

## Skill Structure

```
skill-name/
├── SKILL.md              # Main reference (required)
├── scripts/              # Executable code (optional)
├── references/           # Documentation loaded as needed (optional)
└── assets/               # Templates, images, fonts (optional)
```

## SKILL.md Frontmatter

Only `name` and `description` fields. Max 1024 chars total.

```yaml
---
name: hyphen-case-name
description: Use when [specific triggering conditions]. Start with "Use when..."
---
```

**CRITICAL:** Description = when to use, NOT what skill does. Testing revealed that workflow summaries in descriptions cause agents to skip reading the full skill.

```yaml
# ❌ BAD: Summarizes workflow
description: Use when executing plans - dispatches subagent with code review between tasks

# ✅ GOOD: Just triggers
description: Use when executing implementation plans with independent tasks
```

## SKILL.md Body Structure

```markdown
# Skill Name

## Overview
Core principle in 1-2 sentences.

## When to Use
Symptoms and use cases (bullets). When NOT to use.

## Core Pattern
Before/after or key workflow.

## Quick Reference
Table or bullets for scanning.

## Common Mistakes
What goes wrong + fixes.
```

## Creation Process (TDD)

### 1. Understand with Examples

Ask: "What functionality should this skill support?" "Can you give usage examples?"

### 2. RED: Baseline Test

Run pressure scenario WITHOUT skill. Document:
- What choices did agent make?
- What rationalizations (verbatim)?
- Which pressures triggered violations?

### 3. GREEN: Write Minimal Skill

Address those specific rationalizations. Don't add hypothetical content.

Run scenarios WITH skill. Agent should comply.

### 4. REFACTOR: Close Loopholes

New rationalization found? Add explicit counter. Re-test until bulletproof.

See `references/tdd-testing.md` for full testing methodology.

## Token Efficiency

**Target word counts:**
- Frequently-loaded skills: <200 words
- Other skills: <500 words

**Techniques:**
- Move details to `--help` in scripts
- Cross-reference other skills instead of repeating
- Compress examples

## Progressive Disclosure

1. **Metadata** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed (unlimited)

For skills with variants (frameworks, providers), keep core in SKILL.md, move variant details to references/:

```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

## Bundled Resources

### scripts/
Deterministic code for fragile or repeated operations. May execute without loading into context.

### references/
Documentation loaded on-demand. For 100+ line files, include table of contents.

### assets/
Templates, images, fonts used in output (not loaded into context).

## CSO (Claude Search Optimization)

**Rich description:** Include concrete triggers, symptoms, situations. Write in third person.

**Keywords:** Error messages, symptoms, synonyms, tool names.

**Naming:** Verb-first, hyphen-case: `creating-skills` not `skill-creation`.

## Anti-Patterns

| Anti-Pattern | Why Bad |
|--------------|---------|
| Narrative example ("In session 2025-10-03...") | Too specific, not reusable |
| Multi-language examples | Mediocre quality, maintenance burden |
| Code in flowcharts | Can't copy-paste |
| Generic labels (step1, helper2) | Labels need semantic meaning |

## Flowchart Usage

Use ONLY for:
- Non-obvious decision points
- Process loops where you might stop early
- "When to use A vs B" decisions

Never for: Reference material, code examples, linear instructions.

## The Iron Law

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to NEW skills AND EDITS. Write skill before testing? Delete it. Start over.

## Checklist

**RED Phase:**
- [ ] Create pressure scenarios
- [ ] Run WITHOUT skill, document baseline verbatim
- [ ] Identify rationalization patterns

**GREEN Phase:**
- [ ] Name: hyphen-case, letters/numbers/hyphens only
- [ ] Description: starts with "Use when...", no workflow summary
- [ ] Address specific baseline failures
- [ ] Run WITH skill, verify compliance

**REFACTOR Phase:**
- [ ] Identify NEW rationalizations
- [ ] Add explicit counters
- [ ] Re-test until bulletproof

**Quality:**
- [ ] Flowchart only if decision non-obvious
- [ ] Quick reference table
- [ ] Common mistakes section
- [ ] No narrative storytelling

**Deploy:**
- [ ] Run quick_validate.py
- [ ] Package with package_skill.py (optional)
