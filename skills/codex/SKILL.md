---
name: codex
description: Use when the user asks Claude Code to get a Codex code review, plan evaluation, second opinion, or independent cross-model check.
---

# Codex review

Use the Codex CLI as an independent reviewer. Reviews are read-only unless the user separately approves implementation.

## Prepare

1. Confirm `codex --version` works and the current directory is the intended repository.
2. Inspect `git status` and choose one scope: uncommitted changes, a base branch, a commit, named files, or a written plan.
3. Ask for a review focus only when it is not clear from the request.

## Run a code review

Use one scope flag. Do not combine a scope flag with a custom prompt.

```bash
codex review --uncommitted \
  -c model="gpt-5.6-sol" \
  -c model_reasoning_effort="xhigh" < /dev/null

codex review --base main \
  -c model="gpt-5.6-sol" \
  -c model_reasoning_effort="xhigh" < /dev/null

codex review --commit SHA \
  -c model="gpt-5.6-sol" \
  -c model_reasoning_effort="xhigh" < /dev/null
```

For a custom focus, omit the scope flag and state the intended scope in the prompt.

## Review a plan or named files

Use a read-only, ephemeral run. Tell Codex to inspect the repository, report prioritized findings with file references, and stop without editing.

```bash
codex exec --sandbox read-only --ephemeral \
  -m gpt-5.6-sol \
  -c model_reasoning_effort="xhigh" \
  "Review the plan in PATH. Report concrete risks and missing decisions. Do not modify files." \
  < /dev/null
```

Use the user's configured model when they request one. The GPT-5.6 model names above are current defaults, not permanent requirements.

## Return findings

Summarize the review in priority order, distinguish Codex findings from your own judgment, and note any disagreement. Stop after the findings. Do not implement suggestions until the user chooses what to accept.
