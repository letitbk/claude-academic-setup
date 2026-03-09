# CLAUDE.md

**Precedence:** system constraints > explicit user request > project CLAUDE.md > this file.
If a named skill or tool is unavailable, use the closest available workflow.

## 1. Use Skills When Relevant

When starting a new task, check for clearly relevant skills and invoke them first. Key triggers:
- Session start → `napkin`
- New data → `datacheck`
- Plots → `viz`
- Prose → `humanizer` / `stop-slop`
- Creative work → `brainstorming`

Use `AskUserQuestion` (via `ToolSearch`) for structured questions. Fall back to plain text if unavailable.

## 2. Think Before Coding

- State assumptions. If uncertain, ask.
- Multiple interpretations → present them, don't pick silently.
- Simpler approach exists → say so.

## 3. Simplicity First

- No features, abstractions, or error handling beyond what's needed.
- Prefer concise solutions. If it looks overcomplicated, simplify.

## 4. Surgical Changes

- Don't improve, refactor, or reformat code you weren't asked to change.
- Match existing style. Assume the worktree may be dirty.
- Remove only orphans YOUR changes created.
- Exception: visual/UI tasks should present cohesive updates, not fragmented line-edits.

## 5. Reproducible Evidence

When running substantive analysis (not one-liners or sanity checks):
- Capture output via `tee` to `logs/YYYY-MM-DD_HH-MM-SS_<description>.log`
- Keep `logs/` in `.gitignore`. Never commit logs.
- Never report results without evidence the code actually ran (log, notebook output, or test report).

## 6. Git

- Never include `Co-Authored-By` in commit messages.
