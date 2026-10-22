---
name: claude
description: Use when the user invokes /claude or asks Codex to get a Claude review, plan critique, second opinion, or multi-agent perspective on code, diffs, implementation plans, architecture, or research in the current repo.
---

# Claude Review

## Overview

Use the local Claude Code CLI as an independent reviewer while working in Codex. Claude should critique plans, code, diffs, and approaches; Codex remains responsible for summarizing the result and deciding next steps with the user.

## When to Use

- The user explicitly writes `/claude`.
- The user asks for a Claude review, Claude agent, second opinion, plan evaluation, or external critique.
- The user wants multiple reviewer perspectives before Codex implements.
- Do not use this when the user simply asks Codex to implement or explain something and does not request Claude.

## Guardrails

- Default to read-only review: do not let Claude edit files unless the user explicitly asks for a Claude implementation agent.
- Prefer Claude for independent judgment; do not substitute Codex subagents when the request names Claude.
- After presenting Claude findings, stop. Ask which findings to act on before making code or prose changes.
- Run Claude from the repo root. If the repo requires evidence logs, save output with `tee logs/YYYY-MM-DD_HH-MM-SS_claude_review.log`.
- If `claude` is unavailable or unauthenticated, report the exact blocker and the smallest setup command, usually `claude auth`.

## Core Pattern

1. Determine the scope: plan text, uncommitted diff, files, branch comparison, or general question.
2. Pick one mode:
   - Plan or architecture critique: `claude --print` with a read-only reviewer agent.
   - Code review of a branch or PR: `claude ultrareview` when appropriate.
   - Multiple perspectives: run separate Claude reviewer agents with distinct prompts.
3. Give Claude an XML-tagged prompt with task, scope, output contract, and grounding rules.
4. Save the output, summarize only material findings, and stop for user direction.

## Commands

Plan review:

```bash
mkdir -p logs
ts=$(date +%Y-%m-%d_%H-%M-%S)
claude --print --model sonnet --effort high --permission-mode plan \
  --disallowedTools "Edit,MultiEdit,Write,NotebookEdit" \
  --agents '{"plan-reviewer":{"description":"Reviews implementation plans without editing files","prompt":"You are a critical implementation-plan reviewer. Inspect repository context as needed. Identify feasibility problems, missing steps, risks, and unsupported assumptions. Do not edit files."}}' \
  --agent plan-reviewer \
  "<task>Evaluate this plan against the repo.</task>
<scope>PLAN_OR_FILES_HERE</scope>
<output_contract>Return findings ordered by severity, evidence, suggested improvements, and open questions.</output_contract>
<grounding_rules>Ground claims in repo context or label them as inferences. Do not invent unsupported issues.</grounding_rules>" \
  2>&1 | tee "logs/${ts}_claude_review.log"
```

Code review with Claude's hosted multi-agent reviewer:

```bash
mkdir -p logs
ts=$(date +%Y-%m-%d_%H-%M-%S)
claude ultrareview main --timeout 30 2>&1 | tee "logs/${ts}_claude_ultrareview.log"
```

## Prompt Templates

Plan evaluation:

```xml
<task>
Evaluate this implementation plan for feasibility, completeness, sequencing, and risk.
</task>
<plan>
PLAN_CONTENT_HERE
</plan>
<output_contract>
Return: 1. blockers, 2. missing steps, 3. risky assumptions, 4. recommended revisions, 5. open questions.
</output_contract>
<grounding_rules>
Ground every claim in repository context when possible. Label inferences. Do not suggest fixes unless they follow from evidence.
</grounding_rules>
```

Code or diff review:

```xml
<task>
Review this change for correctness, regressions, missing tests, and integration risks.
</task>
<scope>
FILES_OR_DIFF_SCOPE_HERE
</scope>
<output_contract>
Return findings first, ordered by severity, with file/line evidence where available.
</output_contract>
<verification_loop>
Before finalizing, discard speculative or low-impact issues.
</verification_loop>
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| Asking Claude to "take a look" | Give a concrete scope and output contract. |
| Letting Claude edit during review | Use `--permission-mode plan` and disallow write tools. |
| Reporting a wall of Claude output | Summarize material findings and link/log the saved output. |
| Fixing immediately after review | Stop and ask what the user wants changed. |
