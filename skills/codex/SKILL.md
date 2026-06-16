---
name: codex
description: Get code reviews, plan evaluations, and second opinions using OpenAI Codex CLI (GPT-5.5). Use for reviewing code changes, evaluating implementation plans, getting alternative perspectives, or validating approaches with another AI model.
---

# Codex Review & Second Opinion Skill

Use OpenAI's Codex CLI to get code reviews, plan evaluations, and second opinions. This provides an independent AI perspective using GPT-5.5 or o3 models.

## When to Use This Skill

Trigger when user:
- Uses `/codex` command explicitly
- Asks for a "code review"
- Wants to "evaluate a plan" or "check my implementation plan"
- Wants a "second opinion" on code or approach
- Says "review this", "check this code", "validate this"
- Asks "what do you think about this implementation"
- Wants to "double check" code changes
- Requests "another perspective" on code

## Prerequisites

Codex CLI must be installed and authenticated:
```bash
# Check installation
which codex

# Login if needed
codex login
```

## Prompt Rules

Follow these when constructing Codex prompts. Better prompts beat higher reasoning effort.

1. **Use XML-tagged prompt blocks** — give Codex a `<task>`, an output contract, and grounding rules instead of bare string instructions.
2. **Don't be vague** — "take a look at this" produces vague output. State what you want evaluated and what shape the answer should take.
3. **Don't mix unrelated jobs** — review in one run, fix in another, docs in a third. One clear task per Codex invocation.
4. **Don't ask for "more reasoning"** — tighten the output contract or add a `<verification_loop>` instead of saying "think harder."
5. **Separate facts from inferences** — always include `<grounding_rules>` so Codex labels speculation explicitly.
6. **Specify output shape** — tell Codex exactly what sections to return. Structured output is easier to act on.

## Guardrail

**After presenting Codex findings, STOP.** Do not make any code changes. Do not fix any issues. Ask the user which issues, if any, they want fixed before touching a single file. Auto-applying fixes from a review is strictly forbidden, even if the fix is obvious.

## Workflow

### Step 1: Determine What to Review

**ALWAYS ask the user what they want reviewed:**

Use AskUserQuestion to clarify:
1. **Scope**: What should be reviewed?
   - Uncommitted changes (staged/unstaged)
   - Specific file(s)
   - Changes against a branch
   - A specific commit
   - An implementation plan
   - General approach/implementation question

2. **Model**: Which model to use?
   - `gpt-5.5` - Fast, good quality (default)
   - `o3` - Deep analysis, complex reasoning (slower)

### Step 2: Build the Prompt

Use the prompt templates below to construct a structured prompt. Pick the closest template, fill in the specifics, and trim anything unnecessary.

### Step 3: Execute

**IMPORTANT: Always use `--sandbox workspace-write` (NOT `--full-auto`, which is deprecated and triggers a warning).**

**CRITICAL: Pass the prompt as a direct string argument, NOT via heredoc or command substitution.** Using `$(cat <<'EOF' ... EOF)` or piping causes Codex to hang waiting for stdin. Always pass the prompt inline as a quoted string argument to the command.

**CRITICAL: Always close stdin with `< /dev/null`.** When Codex is launched by an agent harness (Claude Code Bash tool, especially in background mode), the parent's stdin remains attached. Codex then sits indefinitely waiting for stdin input — 0% CPU, 0 bytes of output, never finishes. Append ` < /dev/null` to every `codex exec` and `codex review` invocation. Without this, expect 30+ minute hangs.

See [Execution Modes](#execution-modes) and [Prompt Templates](#prompt-templates) below.

### Step 4: Save Output

After review completes, save output to markdown file:
- Location: Same directory as reviewed code or current working directory
- Filename pattern: `codex_review_YYYYMMDD_HHMMSS.md`
- `codex exec` saves directly with `-o filename.md`; `codex review` has no `-o`, so redirect its stdout to a file (`… < /dev/null > filename.md`)

## Execution Modes

### Mode 1: Review Uncommitted Changes
```bash
codex review --uncommitted -c model="MODEL" < /dev/null
```

### Mode 2: Review Against Branch
```bash
codex review --base BRANCH -c model="MODEL" < /dev/null
```

### Mode 3: Review Specific Commit
```bash
codex review --commit SHA -c model="MODEL" < /dev/null
```

> **`codex review` flags differ from `codex exec`.** It sets the model via `-c model="…"` (no `-m`), is read-only (no `--sandbox`), and has no `-o` (redirect stdout to save). The scope flags (`--uncommitted` / `--base` / `--commit`) are **mutually exclusive with a custom prompt** — to add review focus, drop the scope flag and pass instructions as a prompt: `codex review -c model="MODEL" "Review the uncommitted changes, focusing on X" < /dev/null`.

### Mode 4: Second Opinion on Specific Files
```bash
codex exec --sandbox workspace-write -m MODEL "STRUCTURED_PROMPT" < /dev/null
```

### Mode 5: Evaluate Implementation Plan
```bash
codex exec --sandbox workspace-write -m MODEL "STRUCTURED_PROMPT" < /dev/null
```

### Mode 6: General Second Opinion
```bash
codex exec --sandbox workspace-write -m MODEL "STRUCTURED_PROMPT" < /dev/null
```

## Prompt Templates

Use these XML-tagged templates as the prompt string passed to Codex. Copy the closest template, fill in specifics, and trim what you don't need.

### Plan Evaluation

Use for evaluating implementation plans, architecture decisions, or multi-step proposals.

```xml
<task>
Evaluate this implementation plan against the codebase for feasibility, completeness, and risks.

Plan:
PLAN_CONTENT_HERE
</task>

<structured_output_contract>
Return:
1. feasibility issues (ordered by severity)
2. missing steps or edge cases
3. risks and tradeoffs
4. suggested improvements
5. open questions
</structured_output_contract>

<grounding_rules>
Ground every claim in the repository context or tool outputs.
If a point is an inference, label it clearly.
Do not invent problems that are not supported by the codebase.
</grounding_rules>

<verification_loop>
Before finalizing, verify that each concern is material and actionable, not speculative.
</verification_loop>
```

### Code Review

Use for reviewing diffs, uncommitted changes, or specific files.

```xml
<task>
Review this change for material correctness and regression risks.
Focus areas: FOCUS_AREAS_HERE
</task>

<structured_output_contract>
Return:
1. findings ordered by severity
2. supporting evidence for each finding
3. brief next steps
</structured_output_contract>

<grounding_rules>
Ground every claim in the repository context or tool outputs.
If a point is an inference, label it clearly.
</grounding_rules>

<dig_deeper_nudge>
Check for second-order failures, empty-state handling, retries, stale state, and rollback paths before finalizing.
</dig_deeper_nudge>

<verification_loop>
Before finalizing, verify that each finding is material and actionable.
</verification_loop>
```

### Architecture / Research Opinion

Use for "should we use X or Y" or "evaluate this approach" questions.

```xml
<task>
Research the available options and recommend the best path.
Context: CONTEXT_HERE
</task>

<structured_output_contract>
Return:
1. observed facts
2. reasoned recommendation
3. tradeoffs
4. open questions
</structured_output_contract>

<research_mode>
Separate observed facts, reasoned inferences, and open questions.
Prefer breadth first, then go deeper only where the evidence changes the recommendation.
</research_mode>

<citation_rules>
Back important claims with explicit references to the sources you inspected.
Prefer primary sources.
</citation_rules>
```

### Diagnosis

Use when something is broken and you want Codex to find the root cause.

```xml
<task>
Diagnose why the failing test or command is breaking in this repository.
Failure: FAILURE_DESCRIPTION_HERE
</task>

<compact_output_contract>
Return:
1. most likely root cause
2. evidence
3. smallest safe next step
</compact_output_contract>

<default_follow_through_policy>
Keep going until you have enough evidence to identify the root cause confidently.
Only stop to ask questions when a missing detail changes correctness materially.
</default_follow_through_policy>

<verification_loop>
Before finalizing, verify that the proposed root cause matches the observed evidence.
</verification_loop>

<missing_context_gating>
Do not guess missing repository facts.
If required context is absent, state exactly what remains unknown.
</missing_context_gating>
```

## Command Reference

Every command below appends `< /dev/null`. Do not omit it — see "Prompt Rules" above for why.

### Code Review Commands
```bash
# Review uncommitted changes
codex review --uncommitted -c model="gpt-5.5" < /dev/null

# Review with a custom focus (prompt mode — no scope flag)
codex review -c model="gpt-5.5" "Review the uncommitted changes. <xml-tagged prompt>" < /dev/null

# Review against main branch
codex review --base main -c model="gpt-5.5" < /dev/null

# Review specific commit
codex review --commit abc123 -c model="gpt-5.5" < /dev/null

# Review with title context
codex review --uncommitted --title "Add user authentication" -c model="gpt-5.5" < /dev/null
```

### Plan Evaluation & Second Opinion Commands
```bash
# Evaluate an implementation plan
codex exec --sandbox workspace-write -m gpt-5.5 "<plan evaluation prompt>" < /dev/null

# Get architecture opinion
codex exec --sandbox workspace-write -m o3 "<research opinion prompt>" < /dev/null

# Review specific files
codex exec --sandbox workspace-write -m gpt-5.5 -C /path/to/project "<code review prompt>" < /dev/null
```

### Output Capture
```bash
# Save output to file (preferred)
codex exec --sandbox workspace-write -m gpt-5.5 -o review_output.md "<prompt>" < /dev/null

# Or capture full output (codex review has no -o; redirect or tee)
codex review --uncommitted -c model="gpt-5.5" < /dev/null > review.md 2>&1
```

## Usage Examples

### Example 1: Evaluate Implementation Plan
```
User: Evaluate my plan for adding auth

Claude asks: Which model? What specific concerns?
User: gpt-5.5, focus on security

Claude builds XML prompt with plan content, executes:
codex exec --sandbox workspace-write -m gpt-5.5 -o codex_review_20260111_140000.md "<plan eval prompt>" < /dev/null

Reports findings. STOPS. Asks user what to act on.
```

### Example 2: Review Before Commit
```
User: Review my changes before I commit

Claude asks: What model? Any focus areas?
User: gpt-5.5

Claude executes:
codex review --uncommitted -c model="gpt-5.5" < /dev/null > codex_review_20260111_140000.md

Reports findings. STOPS. Asks user what to fix.
```

### Example 3: Compare with Main
```
User: Review my feature branch against main

Claude executes:
codex review --base main -c model="gpt-5.5" < /dev/null > codex_review_feature.md

Reports findings. STOPS. Asks user what to act on.
```

## Available Models

| Model | Best For | Speed |
|-------|----------|-------|
| `gpt-5.5` | General reviews, quick feedback | Fast |
| `o3` | Deep analysis, complex reasoning | Slower |

## AskUserQuestion Template

When triggered, ask:

```
Question 1: "What would you like Codex to evaluate?"
Options:
- Uncommitted changes (git working tree)
- Changes against a branch
- Specific file(s)
- An implementation plan
- General question/second opinion

Question 2: "Which model should I use?"
Options:
- gpt-5.5 (faster, default)
- o3 (more thorough)
```

## Error Handling

| Error | Solution |
|-------|----------|
| Not logged in | Run `codex login` |
| Not in git repo | Use `-C /path` or `--skip-git-repo-check` |
| Model not available | Fall back to `gpt-5.5` |
| Timeout | Try with smaller scope or faster model |
| Hangs / "Reading additional input from stdin" | Prompt was passed via heredoc or `$(cat ...)`. Pass it as a direct inline string argument instead. |
| Hangs silently with 0% CPU, 0-byte output, no error | Stdin not closed. Append ` < /dev/null` to the invocation. This is the most common hang when codex is launched by an agent harness in background mode. |
| `--full-auto is deprecated` warning | Use `--sandbox workspace-write` instead (already updated in this skill). |

## Non-Git Directories

When running outside a git repository, use `--skip-git-repo-check`:

```bash
codex exec --sandbox workspace-write --skip-git-repo-check -m gpt-5.5 "<prompt>" < /dev/null
```

## Tips

1. **Use XML prompt templates**: Always use the structured templates above instead of bare string instructions
2. **Be specific**: Fill in the template placeholders with concrete context
3. **One task per run**: Don't mix review + fix + docs in a single invocation
4. **Review incrementally**: Review smaller changes more frequently
5. **Always use `--sandbox workspace-write`**: Prevents interactive confirmation prompts (`--full-auto` is deprecated)
6. **Working directory**: Codex needs to be run from the project directory
7. **Never use heredocs for prompts**: Pass prompts as direct string arguments. Heredocs (`$(cat <<'EOF' ... EOF)`) and command substitution cause Codex to hang waiting for stdin
8. **Always close stdin with `< /dev/null`**: Without it, codex hangs indefinitely (0% CPU, 0-byte output) when launched by an agent harness, especially in background mode. This is the single most common cause of "codex is stuck"

## Limitations

- Requires internet connection and OpenAI API access
- Rate limits may apply
- Large codebases may need scoped reviews
- Cannot review files outside git repository by default
