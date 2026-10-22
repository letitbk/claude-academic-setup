---
name: agy
description: Get code reviews, plan evaluations, and second opinions from Google's Gemini via the Antigravity CLI (agy). Use for the /agy command, reviewing code changes, evaluating implementation plans, or getting an independent cross-model perspective. Counterpart to /codex (OpenAI) for review.
---

# agy Review & Second Opinion Skill

Use Google's Antigravity CLI (`agy`) to get code reviews, plan evaluations, and second opinions from Gemini (or other models `agy` exposes). This provides an independent AI perspective from a different model family than Claude Code itself.

> For an OpenAI second opinion instead, use `/codex`.

## When to Use This Skill

Trigger when user:
- Uses `/agy` command explicitly
- Asks for a "code review" or "second opinion" **from Gemini / agy / a non-OpenAI model**
- Wants to "evaluate a plan" or "check my implementation plan" with agy
- Says "review this with agy/Gemini", "what does Gemini think", "cross-model review"
- Wants to "double check" code changes with a different model family

If the user just says "code review" with no model preference, ask whether they want `/agy` (Gemini), `/codex` (OpenAI), or Claude Code's own `/code-review`.

## Prerequisites

Antigravity CLI (`agy`) must be installed and authenticated:
```bash
which agy            # confirm installed
agy --version        # confirms the binary runs
agy models           # lists available models only when authenticated
```
If `agy models` errors or returns nothing, run `agy` interactively once to complete OAuth login (see Error Handling).

## How Reviews Work (No Native Git Mode)

**`agy` has no git-aware `review` subcommand** — there is no built-in diff mode. Reviews are driven entirely through `-p` prompts, and **`agy` inspects the repository itself** — it runs `git diff`, `git show`, and reads files using its own tools. So every review:

1. Runs from inside the target repo (or adds it with `--add-dir`).
2. Uses `--dangerously-skip-permissions` so `agy` can run `git` and read files without interactive prompts.
3. Tells `agy` in the prompt exactly which git scope to inspect (uncommitted / branch / commit / files).

## Why This Skill Bypasses Permissions

Most of this setup keeps permission prompts on. This skill is the one deliberate exception. `agy -p` runs without a terminal to answer prompts, so without `--dangerously-skip-permissions` it stops at the first `git diff` or file read. The flag lets it run commands and read files on its own.

The flag does not make `agy` read-only. The prompts below only ask for review text, and the guardrail forbids edits, but nothing enforces that. Before a review, commit or stash your work so that `git status` shows any change `agy` makes. Run reviews only in a repository you trust.

## Prompt Rules

Better prompts beat higher reasoning effort.

1. **Use XML-tagged prompt blocks** — give `agy` a `<task>`, an output contract, and grounding rules instead of bare instructions.
2. **Tell agy what to inspect** — name the exact git command or files (e.g. "run `git diff` for uncommitted changes"). It will not guess your intended scope.
3. **One task per run** — review in one run, fix in another. Never mix review + fix + docs.
4. **Don't ask for "more reasoning"** — tighten the output contract or add a `<verification_loop>` instead.
5. **Separate facts from inferences** — always include `<grounding_rules>` so speculation is labeled.
6. **Specify output shape** — name the exact sections to return.

## Guardrail

**After presenting agy's findings, STOP.** Do not make any code changes. Do not fix any issues. Ask the user which issues, if any, they want fixed before touching a single file. Auto-applying fixes from a review is strictly forbidden, even if the fix is obvious. (The review prompts below only ask agy to *review*, never to edit — keep it that way.)

## Workflow

### Step 1: Determine Scope

Use AskUserQuestion to clarify **what** to review:
- Uncommitted changes (staged + unstaged)
- Changes against a branch
- A specific commit
- Specific file(s)
- An implementation plan
- General approach / second-opinion question

### Step 2: Choose Model

Default: **`Gemini 3.1 Pro (High)`** (deepest reasoning). Offer the menu from `agy models`:

| Model string (pass verbatim to `--model`) | Best for | Speed |
|--------------------------------------------|----------|-------|
| `Gemini 3.1 Pro (High)` | Thorough reviews, complex reasoning (default) | Slower |
| `Gemini 3.1 Pro (Low)` | Balanced depth vs speed | Medium |
| `Gemini 3.5 Flash (High)` | Fast incremental reviews | Fast |
| `Gemini 3.5 Flash (Medium)` / `(Low)` | Quick sanity checks | Fastest |
| `Claude Opus 4.6 (Thinking)` | Different-family cross-check (still Claude) | Slower |
| `Claude Sonnet 4.6 (Thinking)` | Cheaper Claude cross-check | Medium |
| `GPT-OSS 120B (Medium)` | Open-weight perspective | Medium |

> Always re-run `agy models` if a model string is rejected — the exact display names can change between CLI versions. Pass the string **verbatim**, including the parenthetical (e.g. `--model "Gemini 3.1 Pro (High)"`).

### Step 3: Build the Prompt

Pick the closest XML template under [Prompt Templates](#prompt-templates), fill in the specifics, and prepend the git-scope instruction that tells `agy` what to inspect.

### Step 4: Execute

Run from inside the repo. Core invocation shape:

```bash
cd /path/to/repo
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "SCOPE_INSTRUCTION + STRUCTURED_PROMPT" < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

**CRITICAL — pass the prompt as a direct quoted string argument.** Do NOT use heredocs (`$(cat <<'EOF' ... EOF)`) or pipes; they can leave the CLI waiting on stdin.

**CRITICAL — always close stdin with `< /dev/null`.** When `agy` is launched by an agent harness (Claude Code Bash tool, especially in background mode), the parent's stdin stays attached and print mode can hang. Append `< /dev/null` to every invocation.

**Set `--print-timeout` generously** (default is 5m). Thorough Pro reviews of large diffs can exceed 5 minutes; use `--print-timeout 20m` (or more) so the wait doesn't cut the response off.

**`agy` has no `-o` flag** — redirect stdout to save (`> agy_review_*.md`).

### Step 5: Save & Report

- Save to `agy_review_YYYYMMDD_HHMMSS.md` in the repo / current directory (via stdout redirect above).
- Report the findings to the user, then **STOP** per the Guardrail.

## Execution Modes

Each mode is the same base command with a different **scope instruction** prepended to the XML prompt. `MODEL` defaults to `Gemini 3.1 Pro (High)`.

### Mode 1: Review Uncommitted Changes
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "In this repository, run \`git status\`, \`git diff\`, and \`git diff --staged\` to see all uncommitted (staged and unstaged) changes, then review them. <CODE REVIEW TEMPLATE>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

### Mode 2: Review Against a Branch
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "In this repository, run \`git diff BASE...HEAD\` to see how the current branch differs from BASE, then review those changes. <CODE REVIEW TEMPLATE>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

### Mode 3: Review a Specific Commit
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "In this repository, run \`git show SHA\` to see this commit, then review it. <CODE REVIEW TEMPLATE>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

### Mode 4: Review Specific Files
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "Read these files in the repository: path/a.py, path/b.py. Then review them. <CODE REVIEW TEMPLATE>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

### Mode 5: Evaluate an Implementation Plan
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "Explore the relevant parts of this repository to ground your assessment. <PLAN EVALUATION TEMPLATE with plan pasted in>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

### Mode 6: General Second Opinion / Architecture
```bash
agy --dangerously-skip-permissions --model "MODEL" --print-timeout 20m \
  -p "<ARCHITECTURE / RESEARCH OPINION TEMPLATE>" \
  < /dev/null > agy_review_YYYYMMDD_HHMMSS.md
```

> **Optional hardening:** since these prompts only ask `agy` to *review*, it will not edit files. For extra safety you can add `--sandbox` (terminal restrictions). Test it on your repo first — terminal restrictions may block the `git` commands `agy` needs to read the diff. If git access breaks, drop `--sandbox` and rely on the review-only prompt + the Guardrail.

## Prompt Templates

XML-tagged templates to drop in after the scope instruction. Copy the closest one, fill in specifics, trim what you don't need.

### Code Review
```xml
<task>
Review this change for material correctness and regression risks.
Focus areas: FOCUS_AREAS_HERE
</task>

<structured_output_contract>
Return:
1. findings ordered by severity
2. supporting evidence (file:line) for each finding
3. brief next steps
</structured_output_contract>

<grounding_rules>
Ground every claim in the repository context or tool outputs.
If a point is an inference, label it clearly.
Do not invent problems that are not supported by the code.
</grounding_rules>

<dig_deeper_nudge>
Check for second-order failures, empty-state handling, retries, stale state, and rollback paths before finalizing.
</dig_deeper_nudge>

<verification_loop>
Before finalizing, verify that each finding is material and actionable.
</verification_loop>
```

### Plan Evaluation
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
</grounding_rules>

<verification_loop>
Before finalizing, verify that each concern is material and actionable, not speculative.
</verification_loop>
```

### Architecture / Research Opinion
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
```

### Diagnosis
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

<missing_context_gating>
Do not guess missing repository facts.
If required context is absent, state exactly what remains unknown.
</missing_context_gating>

<verification_loop>
Before finalizing, verify that the proposed root cause matches the observed evidence.
</verification_loop>
```

## Command Reference

Every command appends `< /dev/null`. Do not omit it.

```bash
# Review uncommitted changes (default model)
agy --dangerously-skip-permissions --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Run git diff and git diff --staged in this repo, then review the changes. <template>" \
  < /dev/null > agy_review_$(date +%Y%m%d_%H%M%S).md

# Faster pass with Flash
agy --dangerously-skip-permissions --model "Gemini 3.5 Flash (High)" --print-timeout 10m \
  -p "Run git diff in this repo, then review. <template>" < /dev/null > agy_review.md

# Review against main
agy --dangerously-skip-permissions --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Run git diff main...HEAD, then review the branch changes. <template>" \
  < /dev/null > agy_review.md

# Add an extra directory to the workspace
agy --dangerously-skip-permissions --add-dir /path/to/other --model "Gemini 3.1 Pro (High)" \
  -p "<prompt referencing files in both dirs>" < /dev/null > agy_review.md

# Cross-model second opinion
agy --dangerously-skip-permissions --model "Claude Opus 4.6 (Thinking)" --print-timeout 20m \
  -p "<plan evaluation template>" < /dev/null > agy_review.md
```

## Usage Examples

### Example 1: Review Before Commit
```
User: /agy — review my changes before I commit

Claude asks: Scope? Model?
User: Uncommitted changes, Gemini 3.1 Pro (High)

Claude runs (from the repo):
agy --dangerously-skip-permissions --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Run git status, git diff, and git diff --staged in this repo, then review the changes. <code review template>" \
  < /dev/null > agy_review_20260623_150000.md

Reports findings. STOPS. Asks the user what to fix.
```

### Example 2: Compare Against main
```
User: review my feature branch against main with Gemini

Claude runs:
agy --dangerously-skip-permissions --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Run git diff main...HEAD in this repo, then review the branch changes. <code review template>" \
  < /dev/null > agy_review_feature.md

Reports findings. STOPS.
```

### Example 3: Evaluate an Implementation Plan
```
User: /agy — evaluate my auth plan, focus on security

Claude asks: Model?
User: Gemini 3.1 Pro (High)

Claude runs:
agy --dangerously-skip-permissions --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Explore the relevant parts of this repo to ground your assessment. <plan evaluation template, plan pasted in, focus areas: security>" \
  < /dev/null > agy_review_20260623_150000.md

Reports findings. STOPS. Asks the user what to act on.
```

## AskUserQuestion Template

When triggered, ask:

```
Question 1: "What would you like agy (Gemini) to review?"
Options:
- Uncommitted changes (git working tree)
- Changes against a branch
- A specific commit
- Specific file(s)
- An implementation plan
- General question / second opinion

Question 2: "Which model should I use?"
Options:
- Gemini 3.1 Pro (High) — thorough (default)
- Gemini 3.5 Flash (High) — fast
- Claude Opus 4.6 (Thinking) — different-family cross-check
- (other from `agy models`)
```

## Error Handling

| Error | Solution |
|-------|----------|
| Not authenticated / `agy models` empty | Run `agy` interactively once to complete OAuth login into the keyring; `/logout` then relaunch to re-auth |
| Hangs silently, 0 output | Stdin not closed — append `< /dev/null`. This is the most common hang under an agent harness |
| Hangs / waiting for input | Prompt was passed via heredoc or `$(cat ...)`. Pass it as a direct inline quoted string instead |
| Response cut off / `print-timeout` reached | Increase `--print-timeout` (e.g. `30m`) or narrow the scope |
| `--model` string rejected | Re-run `agy models` and copy the exact display name verbatim (including the parenthetical) |
| agy can't see the diff | Make sure you're inside the repo (or used `--add-dir`) and that `--dangerously-skip-permissions` is set so it can run `git` |
| `--sandbox` blocks git reads | Drop `--sandbox`; rely on the review-only prompt + Guardrail for safety |
| Rate limited | Wait and retry, or switch to a Flash model |

## Non-Git Directories

`agy` doesn't require a git repo at all (there is no `--skip-git-repo-check` flag because none is needed). To review code that isn't under version control — or to review loose files — skip the git-scope instruction and point `agy` at the files directly with `--add-dir`:

```bash
agy --dangerously-skip-permissions --add-dir /path/to/code --model "Gemini 3.1 Pro (High)" --print-timeout 20m \
  -p "Read these files: /path/to/code/a.py, /path/to/code/b.py. Then review them. <code review template>" \
  < /dev/null > agy_review.md
```

## Tips

1. **Use the XML templates** — structured prompts beat bare instructions.
2. **Name the git scope** — tell agy the exact `git` command to run; it won't infer your intent.
3. **One task per run** — never mix review + fix + docs.
4. **Default to Gemini 3.1 Pro (High)** for depth; drop to Flash for quick incremental passes.
5. **Always `< /dev/null`** and a generous `--print-timeout`.
6. **Run from the repo directory** so agy's git/file tools resolve paths correctly.
7. **For a true outside opinion**, prefer the Gemini models over the Claude options (Claude Code is already Claude).

## Limitations

- Requires internet connection and Google AI (Antigravity) access.
- No native git review mode — relies on agy running `git` itself via `--dangerously-skip-permissions`.
- Large diffs may need scoped reviews (by file or by commit).
- Rate limits apply (check your Google AI quota).
- Model display names can change between `agy` versions — verify with `agy models`.
