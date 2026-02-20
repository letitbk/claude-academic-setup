---
name: codex
description: Get code reviews and second opinions using OpenAI Codex CLI (GPT-5.3). Use for reviewing code changes, getting alternative perspectives on implementations, or validating approaches with another AI model.
---

# Codex Review & Second Opinion Skill

Use OpenAI's Codex CLI to get code reviews and second opinions. This provides an independent AI perspective using GPT-5.3 or o3 models.

## When to Use This Skill

Trigger when user:
- Uses `/codex` command explicitly
- Asks for a "code review"
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

## Workflow

### Step 1: Determine What to Review

**ALWAYS ask the user what they want reviewed:**

Use AskUserQuestion to clarify:
1. **Scope**: What should be reviewed?
   - Uncommitted changes (staged/unstaged)
   - Specific file(s)
   - Changes against a branch
   - A specific commit
   - General approach/implementation question

2. **Model**: Which model to use?
   - `gpt-5.3-codex` - Fast, good quality (default)

### Step 2: Execute Review

**IMPORTANT: Always use `--full-auto` to avoid confirmation prompts.**

#### Mode 1: Review Uncommitted Changes
```bash
codex review --full-auto --uncommitted -m MODEL "CUSTOM_INSTRUCTIONS"
```

#### Mode 2: Review Against Branch
```bash
codex review --full-auto --base BRANCH -m MODEL "CUSTOM_INSTRUCTIONS"
```

#### Mode 3: Review Specific Commit
```bash
codex review --full-auto --commit SHA -m MODEL "CUSTOM_INSTRUCTIONS"
```

#### Mode 4: Second Opinion on Specific Files
```bash
codex exec --full-auto -m MODEL "Review these files for issues, improvements, and best practices: FILE1 FILE2"
```

#### Mode 5: General Second Opinion
```bash
codex exec --full-auto -m MODEL "I need a second opinion on: USER_QUESTION"
```

### Step 3: Save Output

After review completes, save output to markdown file:
- Location: Same directory as reviewed code or current working directory
- Filename pattern: `codex_review_YYYYMMDD_HHMMSS.md`

## Command Reference

### Code Review Commands
```bash
# Review uncommitted changes (no confirmations)
codex review --full-auto --uncommitted -m gpt-5.3-codex

# Review with custom instructions
codex review --full-auto --uncommitted -m gpt-5.3-codex "Focus on security vulnerabilities and performance"

# Review against main branch
codex review --full-auto --base main -m gpt-5.3-codex

# Review specific commit
codex review --full-auto --commit abc123 -m gpt-5.3-codex

# Review with title context
codex review --full-auto --uncommitted --title "Add user authentication" -m gpt-5.3-codex
```

### Second Opinion Commands
```bash
# Ask about specific code
codex exec --full-auto -m gpt-5.3-codex "Review this implementation approach and suggest improvements"

# Get opinion on architecture
codex exec --full-auto -m o3 "Evaluate this architecture decision: USER_CONTEXT"

# Review specific files
codex exec --full-auto -m gpt-5.3-codex -C /path/to/project "Review src/auth.py for security issues"
```

### Output Capture
```bash
# Save last message to file (preferred method)
codex exec --full-auto -m gpt-5.3-codex -o review_output.md "Review prompt here"

# Or capture full output
codex review --full-auto --uncommitted -m gpt-5.3-codex 2>&1 | tee review.md
```

## Usage Examples

### Example 1: Review Before Commit
```
User: Review my changes before I commit

Claude asks: What model? (gpt-5.3-codex / o3)
User: gpt-5.3-codex

Claude executes:
codex review --full-auto --uncommitted -m gpt-5.3-codex -o codex_review_20260111_140000.md

Reports: Review saved to codex_review_20260111_140000.md
```

### Example 2: Second Opinion on Approach
```
User: Get a second opinion on my authentication implementation

Claude asks: Which files? What specific concerns?
User: src/auth.py - is my JWT handling secure?

Claude executes:
codex exec --full-auto -m gpt-5.3-codex -o codex_review_auth.md "Review src/auth.py focusing on JWT security. Is the implementation secure? Any vulnerabilities?"
```

### Example 3: Compare with Main
```
User: Review my feature branch against main

Claude executes:
codex review --full-auto --base main -m gpt-5.3-codex -o codex_review_feature.md "Review all changes for code quality and potential bugs"
```

## Available Models

| Model | Best For | Speed |
|-------|----------|-------|
| `gpt-5.3-codex` | General reviews, quick feedback | Fast |
| `o3` | Deep analysis, complex reasoning | Slower |

## AskUserQuestion Template

When triggered, ask:

```
Question 1: "What would you like Codex to review?"
Options:
- Uncommitted changes (git working tree)
- Changes against a branch
- Specific file(s)
- General question/second opinion

Question 2: "Which model should I use?"
Options:
- gpt-5.3-codex (faster)
- o3 (more thorough)
```

## Output Handling

1. Use `-o filename.md` to save output directly (cleaner than tee)
2. Save to: `codex_review_YYYYMMDD_HHMMSS.md` in current directory
3. Report file location to user after completion
4. Display key findings summary

## Error Handling

| Error | Solution |
|-------|----------|
| Not logged in | Run `codex login` |
| Not in git repo | Use `-C /path` or `--skip-git-repo-check` |
| Model not available | Fall back to `gpt-5.3-codex` |
| Timeout | Try with smaller scope or faster model |

## Tips

1. **Be specific**: Provide context about what to focus on
2. **Review incrementally**: Review smaller changes more frequently
3. **Custom instructions**: Add focus areas like "security", "performance", "readability"
4. **Working directory**: Codex needs to be run from the project directory
5. **Always use --full-auto**: Prevents interactive confirmation prompts

## Limitations

- Requires internet connection and OpenAI API access
- Rate limits may apply
- Large codebases may need scoped reviews
- Cannot review files outside git repository by default

## Non-Git Directories

When running outside a git repository, use `--skip-git-repo-check`:

```bash
codex exec --full-auto --skip-git-repo-check -m gpt-5.3-codex "Your prompt here"
```

This is useful for:
- Reviewing standalone scripts
- Getting opinions on code snippets
- General programming questions

## Alternative: Codex MCP Server

For tighter integration without shell overhead, Codex can run as an MCP server.
See the `codex-mcp` MCP server configuration for native tool integration.
