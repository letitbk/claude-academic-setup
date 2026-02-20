---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation. Also use when user says 'ask me questions', 'interview me', or needs help clarifying requirements."
---

# Brainstorming Ideas Into Designs

## Overview

Help turn ideas into fully formed designs and specs through structured, interactive questioning using the **AskUserQuestion tool**.

Start by understanding the current project context, then conduct **multiple rounds of questioning** to deeply understand requirements before proposing designs.

## The Process

### Phase 1: Interactive Questioning (MANDATORY)

**Use the AskUserQuestion tool repeatedly** to conduct an interview-style session. This is not optional - always use this tool for questioning.

#### Question Categories

Use a mix of these question types across rounds:

**Problem Understanding**
- What problem are you actually trying to solve? (not what you asked for)
- What would "success" look like? How will you know this worked?
- What have you already tried? What didn't work?

**Constraints & Boundaries**
- What are the non-negotiables vs nice-to-haves?
- What are the boundaries (time, scope, resources)?
- What should this explicitly NOT do?

**Context & Stakeholders**
- Who else is affected by this? Who are the stakeholders?
- What's the broader context this fits into?
- What happens before and after this?

**Edge Cases & Risks**
- What's the weirdest/hardest case this needs to handle?
- What could go wrong? What are you worried about?
- What assumptions might be wrong?

**Preferences & Style**
- What's your style preference? (verbose vs minimal, etc.)
- What similar things do you like/dislike?
- What tradeoffs are acceptable?

**"Why" Questions**
- Why this approach vs alternatives?
- Why now? What triggered this?
- Why does this matter?

#### AskUserQuestion Tool Usage

Each round should use:
- **2-4 questions maximum** - Don't overwhelm
- **Clear, specific options** when choices exist
- **multiSelect: true** when multiple answers make sense

#### Typical Flow

**Round 1: Core Problem**
- What are you trying to accomplish?
- Why is this needed now?

**Round 2: Constraints & Context**
- What are the hard constraints?
- Who/what else is involved?

**Round 3: Preferences & Edge Cases**
- What's your preferred approach/style?
- What edge cases matter?

**Round 4+: Clarifications**
- Address any ambiguities from earlier answers
- Continue until clarity is achieved

#### When to Stop Questioning

Stop when:
- User explicitly says they've given enough info
- User says "that's all" or "let's proceed"
- Questions become circular or redundant
- You have clear, actionable understanding

### Phase 2: Summarize Understanding

**Always provide a summary** before proposing designs:

```
## What I Understand

**Goal**: [summary]
**Constraints**: [list]
**Preferences**: [list]
**Key Considerations**: [list]

Is this accurate?
```

### Phase 3: Exploring Approaches

After confirmation:
- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

### Phase 4: Presenting the Design

Once approach is selected:
- Present the design in small sections (200-300 words)
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

## After the Design

**Documentation:**
- Write the validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Commit the design document to git

**Implementation (if continuing):**
- Ask: "Ready to set up for implementation?"
- Use superpowers:using-git-worktrees to create isolated workspace
- Use superpowers:writing-plans to create detailed implementation plan

## Key Principles

- **Use AskUserQuestion tool** - MANDATORY for all questioning
- **Multiple rounds** - Don't stop after 1-2 rounds unless user indicates enough
- **Ask non-conventional questions** - Go beyond the obvious, probe assumptions
- **Be genuinely curious** - Ask "why" questions, explore edge cases
- **Adapt based on answers** - Each round builds on previous responses
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design in sections, validate each
