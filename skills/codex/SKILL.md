---
name: codex
description: Get code reviews, plan evaluations, and second opinions using OpenAI Codex CLI (GPT-6 Astra). Use for reviewing code changes, evaluating implementation plans, getting alternative perspectives, or validating approaches with another AI model.
---

# Codex Review & Second Opinion Skill

Use OpenAI's Codex CLI to get code reviews, plan evaluations, and second opinions. This provides an independent AI perspective using GPT-6 Astra (default) or the GPT-5.6 family (Sol, Terra, Luna).

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

Codex CLI must be installed, current, and authenticated:
```bash
# Check installation and version (gpt-6-astra needs codex-cli >= 0.153.1)
which codex
codex --version

# Upgrade if older
codex update

# Login if needed
codex login

# Diagnose auth, config, or runtime problems
codex doctor
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

Run reviews and second opinions with a **read-only sandbox** so Codex itself cannot write to the workspace either. Note that `codex review` defaults to `workspace-write` and will happily run test suites that write logs into the repo; always pass `-c sandbox_mode="read-only"` (see Step 3).

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
   - `gpt-6-astra` at `xhigh` effort - GPT-6 flagship, deepest analysis (default for reviews)
   - `gpt-5.6-sol` - Previous flagship; strong reviews at lower cost and lighter rate-limit use
   - `gpt-5.6-terra` - Balanced, faster
   - `gpt-5.6-luna` - Fast and cheap, for quick sanity checks
   - Effort `max` / `ultra` - opt-in escalation only when the user explicitly asks to go deeper (`ultra` adds automatic task delegation and has unpredictable runtime)

### Step 2: Build the Prompt

Use the prompt templates below to construct a structured prompt. Pick the closest template, fill in the specifics, and trim anything unnecessary.

### Step 3: Execute

**IMPORTANT: Use a read-only sandbox for reviews and second opinions.** `codex exec` takes `--sandbox read-only`; `codex review` and `codex exec review` have no `--sandbox` flag, so pass `-c sandbox_mode="read-only"`. Use `workspace-write` only when the task genuinely needs Codex to write files (for example running a test suite that writes logs). Never use `--full-auto` (deprecated, triggers a warning).

**Prefer `codex exec review` over `codex review`.** Both run the same review, but `codex exec review` also accepts `-m`, `-o` (final message to a file), `--ephemeral`, and `--skip-git-repo-check`.

**CRITICAL: Pass the prompt as a direct string argument, NOT via heredoc or command substitution.** Using `$(cat <<'EOF' ... EOF)` or piping causes Codex to hang waiting for stdin. Always pass the prompt inline as a quoted string argument to the command.

**CRITICAL: Always close stdin with `< /dev/null`.** When Codex is launched by an agent harness (Claude Code Bash tool, especially in background mode), the parent's stdin remains attached. Codex then sits indefinitely waiting for stdin input — 0% CPU, 0 bytes of output, never finishes. Append ` < /dev/null` to every `codex exec` and `codex review` invocation. Without this, expect 30+ minute hangs. (The line `Reading additional input from stdin...` still prints at startup with `< /dev/null`; that is harmless.)

See [Execution Modes](#execution-modes) and [Prompt Templates](#prompt-templates) below.

### Step 4: Save Output

Codex streams its whole session log to stdout (hooks, every tool call and its output, and the final answer printed twice). Even a 30-line commit review produces a 75–140 KB stream, so never treat stdout as the review.

- Write the final message with `-o codex_review_YYYYMMDD_HHMMSS.md` (works for `codex exec` and `codex exec review`).
- Redirect stdout and stderr to a scratch log outside the project (`> /path/to/scratch/codex_stream.log 2>&1`) in case you need the trace.
- Save the `-o` file next to the reviewed code or in the current working directory.
- Plain `codex review` has no `-o`; if you must use it, redirect stdout to a scratch file and read the tail (`tail -c 30000`).

## Execution Modes

`MODEL` defaults to `gpt-6-astra`, `EFFORT` to `xhigh`.

### Mode 1: Review Uncommitted Changes
```bash
codex exec review --uncommitted -m MODEL -c model_reasoning_effort="EFFORT" -c sandbox_mode="read-only" -o codex_review_YYYYMMDD_HHMMSS.md < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Mode 2: Review Against Branch
```bash
codex exec review --base BRANCH -m MODEL -c model_reasoning_effort="EFFORT" -c sandbox_mode="read-only" -o codex_review_YYYYMMDD_HHMMSS.md < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Mode 3: Review Specific Commit
```bash
codex exec review --commit SHA -m MODEL -c model_reasoning_effort="EFFORT" -c sandbox_mode="read-only" -o codex_review_YYYYMMDD_HHMMSS.md < /dev/null > SCRATCH/codex_stream.log 2>&1
```

> **Review flags.** The scope flags (`--uncommitted` / `--base` / `--commit`) are **mutually exclusive with a custom prompt** — to add review focus, drop the scope flag and pass instructions as a prompt: `codex exec review -m MODEL -c sandbox_mode="read-only" "Review the uncommitted changes, focusing on X" < /dev/null`. `--title "..."` adds a title to the summary. Plain `codex review` takes the same scope flags but only `-c` overrides: `-c model="MODEL" -c model_reasoning_effort="EFFORT" -c sandbox_mode="read-only"`, and no `-o`.

### Mode 4: Second Opinion on Specific Files
```bash
codex exec --sandbox read-only -m MODEL -c model_reasoning_effort="EFFORT" -o codex_review_YYYYMMDD_HHMMSS.md "STRUCTURED_PROMPT" < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Mode 5: Evaluate Implementation Plan
```bash
codex exec --sandbox read-only -m MODEL -c model_reasoning_effort="EFFORT" -o codex_review_YYYYMMDD_HHMMSS.md "STRUCTURED_PROMPT" < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Mode 6: General Second Opinion
```bash
codex exec --sandbox read-only -m MODEL -c model_reasoning_effort="EFFORT" -o codex_review_YYYYMMDD_HHMMSS.md "STRUCTURED_PROMPT" < /dev/null > SCRATCH/codex_stream.log 2>&1
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

Every command below appends `< /dev/null`. Do not omit it — see Step 3 above for why. `SCRATCH` is a directory outside the project for the stdout stream.

### Code Review Commands
```bash
# Review uncommitted changes (default: astra at xhigh)
codex exec review --uncommitted -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_120000.md < /dev/null > SCRATCH/codex_stream.log 2>&1

# Review with a custom focus (prompt mode — no scope flag)
codex exec review -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_120000.md "Review the uncommitted changes. <xml-tagged prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1

# Review against main branch
codex exec review --base main -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_120000.md < /dev/null > SCRATCH/codex_stream.log 2>&1

# Review specific commit
codex exec review --commit abc123 -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_120000.md < /dev/null > SCRATCH/codex_stream.log 2>&1

# Review with title context
codex exec review --uncommitted --title "Add user authentication" -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_120000.md < /dev/null > SCRATCH/codex_stream.log 2>&1

# Plain `codex review` (no -m / -o): same scope flags, overrides only via -c
codex review --uncommitted -c model="gpt-6-astra" -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Plan Evaluation & Second Opinion Commands
```bash
# Evaluate an implementation plan
codex exec --sandbox read-only -m gpt-6-astra -c model_reasoning_effort="xhigh" -o codex_review_20260906_120000.md "<plan evaluation prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1

# Get architecture opinion (cheaper model)
codex exec --sandbox read-only -m gpt-5.6-sol -c model_reasoning_effort="xhigh" -o codex_review_20260906_120000.md "<research opinion prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1

# Review specific files in another project
codex exec --sandbox read-only -m gpt-6-astra -C /path/to/project -o codex_review_20260906_120000.md "<code review prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1

# Let Codex run tests that write files (only when the task needs it)
codex exec --sandbox workspace-write -m gpt-6-astra -o codex_review_20260906_120000.md "<diagnosis prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1
```

### Useful Optional Flags
- `--ephemeral` — do not persist the session (good for throwaway one-off reviews; omit if you may want `codex resume` follow-ups)
- `--output-schema FILE` — force the final message into a JSON Schema shape
- `--json` — emit JSONL events on stdout instead of the text stream
- `-i FILE` — attach an image to a `codex exec` prompt (screenshots, figures)

## Usage Examples

### Example 1: Evaluate Implementation Plan
```
User: Evaluate my plan for adding auth

Claude asks: Which model? What specific concerns?
User: gpt-6-astra, focus on security

Claude builds XML prompt with plan content, executes:
codex exec --sandbox read-only -m gpt-6-astra -c model_reasoning_effort="xhigh" -o codex_review_20260906_140000.md "<plan eval prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1

Reports findings from the -o file. STOPS. Asks user what to act on.
```

### Example 2: Review Before Commit
```
User: Review my changes before I commit

Claude asks: What model? Any focus areas?
User: gpt-6-astra

Claude executes:
codex exec review --uncommitted -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_20260906_140000.md < /dev/null > SCRATCH/codex_stream.log 2>&1

Reports findings. STOPS. Asks user what to fix.
```

### Example 3: Compare with Main
```
User: Review my feature branch against main

Claude executes:
codex exec review --base main -m gpt-6-astra -c model_reasoning_effort="xhigh" -c sandbox_mode="read-only" -o codex_review_feature.md < /dev/null > SCRATCH/codex_stream.log 2>&1

Reports findings. STOPS. Asks user what to act on.
```

## Available Models

Source of truth: `~/.codex/models_cache.json` (the catalog the CLI fetched, with `fetched_at` and `client_version`). Re-check it when a model is missing or a new one lands.

GPT-6 Astra shipped 2026-09-03 (Codex CLI 0.153.1+). The GPT-5.6 family (public since 2026-07-09) remains available. Reasoning efforts are `low` / `medium` / `high` / `xhigh` / `max`, plus `ultra` on Astra, Sol, and Terra (Codex-only; adds automatic task delegation).

| Model | Best For | Speed / Cost |
|-------|----------|--------------|
| `gpt-6-astra` | Reviews, deep analysis, hardest problems (**default for reviews, at `xhigh` effort**) | Slowest, most expensive (about 2x Sol per token; Fast service tier is 2x speed at 2x usage) |
| `gpt-5.6-sol` | Strong reviews when Astra is rate-limited or overkill | Slower, expensive |
| `gpt-5.6-terra` | Balanced everyday second opinions | Medium |
| `gpt-5.6-luna` | Quick sanity checks, high-volume tasks (no `ultra`) | Fast, cheapest |
| `gpt-5.5` | Legacy fallback (effort up to `xhigh`) | Medium |

Context notes: the Codex catalog lists a 272k context window for every model above. Astra's API context is 1.05M tokens, but any request over 272k input tokens is billed at long-context rates (2x input, 1.5x output for the whole request), so keep review scope well under 272k. Astra's default effort in Codex is `medium`; this skill overrides it to `xhigh` for reviews.

Effort notes: `max` is for the hardest problems and is markedly slower; `ultra` adds automatic task delegation (spawns subagent work, unpredictable runtime). Use both only when the user explicitly asks to go deeper than `xhigh`.

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
- gpt-6-astra @ xhigh (thorough, default for reviews)
- gpt-5.6-sol @ xhigh (strong, cheaper, lighter on rate limits)
- gpt-5.6-terra (balanced, faster)
- gpt-5.6-luna (quick sanity check)
```

## Error Handling

| Error | Solution |
|-------|----------|
| Not logged in | Run `codex login`; `codex doctor` for a fuller diagnosis |
| `gpt-6-astra` unknown / not in catalog | `codex --version` must be >= 0.153.1; run `codex update`. Otherwise fall back to `gpt-5.6-sol` |
| Model not available (rate limit, tier) | Fall back to `gpt-5.6-sol`, then `gpt-5.6-terra` |
| Not in git repo | Use `-C /path` or `--skip-git-repo-check` |
| Timeout | Try with smaller scope, lower effort (`high`), or a faster model (`terra`/`luna`) |
| Hangs silently: 0% CPU, output file stops growing, no error | Stdin is still open (missing `< /dev/null`) or the prompt was passed via heredoc / `$(cat ...)`. Close stdin and pass the prompt as an inline string. The startup line `Reading additional input from stdin...` is normal and does not by itself indicate a hang |
| Codex wrote files during a review (logs, caches) | You ran `codex review` without `-c sandbox_mode="read-only"` (its default is `workspace-write`). Delete what it wrote, rerun read-only |
| Review file is huge and the answer appears twice | You redirected stdout instead of using `-o`. Use `-o` for the final message; send stdout to a scratch log |
| `--full-auto is deprecated` warning | Use `--sandbox read-only` (or `workspace-write` when writes are needed) |

## Non-Git Directories

When running outside a git repository, use `--skip-git-repo-check`:

```bash
codex exec --sandbox read-only --skip-git-repo-check -m gpt-6-astra -o codex_review_20260906_120000.md "<prompt>" < /dev/null > SCRATCH/codex_stream.log 2>&1
```

## Tips

1. **Use XML prompt templates**: Always use the structured templates above instead of bare string instructions
2. **Be specific**: Fill in the template placeholders with concrete context
3. **One task per run**: Don't mix review + fix + docs in a single invocation
4. **Review incrementally**: Review smaller changes more frequently; keep total input well under 272k tokens
5. **Read-only by default**: `--sandbox read-only` for `codex exec`, `-c sandbox_mode="read-only"` for reviews. Escalate to `workspace-write` only when the task needs writes (`--full-auto` is deprecated)
6. **Prefer `codex exec review`**: it accepts `-m`, `-o`, `--ephemeral`; plain `codex review` only takes `-c` overrides
7. **Working directory**: Codex needs to be run from the project directory (or pass `-C`)
8. **Never use heredocs for prompts**: Pass prompts as direct string arguments. Heredocs (`$(cat <<'EOF' ... EOF)`) and command substitution cause Codex to hang waiting for stdin
9. **Always close stdin with `< /dev/null`**: Without it, codex hangs indefinitely (0% CPU, 0-byte output) when launched by an agent harness, especially in background mode. This is the single most common cause of "codex is stuck"
10. **Use `-o` for the answer, a scratch log for the stream**: stdout is the full session trace, not the review
11. **macOS has no `timeout`**: use the Bash tool's timeout parameter, or `perl -e 'alarm N; exec @ARGV' codex ...`

## Limitations

- Requires internet connection and OpenAI API access (ChatGPT plan auth is rate-limited, not per-token billed)
- Rate limits may apply; Astra draws down usage faster than Sol
- Large codebases may need scoped reviews
- Cannot review files outside git repository by default
- Astra declines advanced offensive-security tasks unless the account has elevated access
