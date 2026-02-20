---
name: catch-up
description: Use when returning to a project after time away, starting a work session, or recovering from interruption - provides comprehensive project context and recent activity summary
model: sonnet
---

# Catch Up

## Overview

Comprehensive project catch-up that summarizes recent activity, accomplishments, and context. Auto-detects time since last activity and presents relevant information.

## When to Use

- Returning to a project after any time away
- Starting a new work session
- Recovering mid-session after interruption
- User says "catch up" or similar

## Process

### Step 1: Detect Last Activity

Check Claude Code project history for last session timestamp:

```bash
# Get project hash for current directory
PROJECT_DIR=$(pwd)
PROJECT_HASH=$(echo -n "$PROJECT_DIR" | sed 's/\//-/g' | sed 's/^-//')
PROJECT_PATH="$HOME/.claude/projects/$PROJECT_HASH"

# Find most recent session file
ls -t "$PROJECT_PATH"/*.jsonl 2>/dev/null | head -1
```

Calculate time elapsed since last activity.

### Step 2: Confirm Time Range

Use AskUserQuestion to confirm scenario based on detected time:

| Time Elapsed | Suggested Range | Description |
|--------------|-----------------|-------------|
| < 4 hours | Last 4 hours | Mid-session recovery |
| < 24 hours | Last 24 hours | Daily standup |
| < 7 days | Last 7 days | Returning within week |
| < 14 days | Last 30 days | Returning after 1-2 weeks |
| > 14 days | All history | Long absence |

Present with: "You were last here [X time] ago. Show [suggested range]?"

Options:
- Mid-session (4h)
- Daily (24h)
- This week (7d)
- This month (30d)
- Full history

### Step 3: Gather Information (All Sources, Skip Unavailable)

**3a. Project Context (for "What is this project?")**

1. Read CLAUDE.md or README if exists
2. Analyze directory structure for project type
3. Extract project understanding from chat history

**3b. Recently Modified Files**

```bash
# Find files modified in time range, exclude noise
find . -type f -mtime -<DAYS> \
  -not -path "./.git/*" \
  -not -path "./node_modules/*" \
  -not -path "./__pycache__/*" \
  -not -name ".DS_Store" \
  -not -name "*.pyc" \
  2>/dev/null | head -50
```

**3c. Git Commits (if available)**

```bash
git log --oneline --since="<TIME_RANGE>" 2>/dev/null
git diff --stat HEAD~10 2>/dev/null | tail -20
```

**3d. GitHub Activity (if gh CLI available and remote exists)**

```bash
# Check if GitHub remote exists
git remote -v 2>/dev/null | grep github

# If yes, check PRs and issues
gh pr list --state all --limit 10 2>/dev/null
gh issue list --state all --limit 10 2>/dev/null
```

**3e. Claude Code Chat History**

Read from `~/.claude/projects/<project-hash>/` for sessions within time range.
Parse JSONL for conversation summaries and key topics.

### Step 4: Present Summary

Only include sections with actual content:

```markdown
## Project: [name]
[1-2 sentence description from docs or inferred]

## What's Been Accomplished
[Key milestones/features from docs and history]

## Recent Focus (last [time range])
[Only show sections with content:]
- **Files:** X modified, Y created - [highlight largest changes]
- **Commits:** Z commits - [highlight key changes]
- **Conversations:** N sessions - [highlight key topics]
- **GitHub:** M PRs, K issues - [highlight activity]

## Highlights
- [Most significant change #1]
- [Most significant change #2]
- [Most significant change #3]
```

### Step 5: Offer Drill-Down

Use AskUserQuestion with options:
- "Show file changes"
- "Show commit details"
- "Show conversation summaries"
- "Show GitHub activity"
- "I'm caught up"

Loop until user selects "I'm caught up".

## Common Mistakes

- Showing empty sections (GitHub when no remote exists)
- Not detecting project type from code structure
- Missing chat history due to wrong project hash
- Overwhelming with too much detail in initial summary
