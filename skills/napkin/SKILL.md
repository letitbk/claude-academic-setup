---
name: napkin
description: Use at the start of every repository session to load and maintain concise notes about corrections, user preferences, successful patterns, failed approaches, and project facts that should change future behavior.
---

# Napkin

Use `.claude/napkin.md` as small project memory. Read it before other work. If it does not exist, create it with sections for corrections, preferences, useful patterns, failed patterns, and project notes.

Add an entry when:

- the user corrects the agent;
- the agent catches its own mistake;
- a tool or project behaves unexpectedly;
- a method succeeds or fails in a way worth repeating;
- the user states a durable working preference.

Record the lesson and the behavior to use next time. Do not store a transcript, routine progress, credentials, private data, or facts already documented elsewhere.

Keep the file easy to scan. Merge duplicates, remove obsolete notes, and keep it under about 200 lines.

Example:

```markdown
# Napkin

## Corrections
| Date | Source | What happened | Use next time |
|---|---|---|---|

## Preferences
- Keep review findings tied to exact files.

## Useful patterns
- Run the smallest relevant test before the full suite.

## Project notes
- Analysis entry point: `scripts/main.R`.
```
