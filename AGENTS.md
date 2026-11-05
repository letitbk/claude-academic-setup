# AGENTS.md

**Precedence:** system/developer constraints > explicit user request > project AGENTS.md > this file.
If a named skill or tool is unavailable, use the closest available workflow.

## 1. Use Skills When Relevant

When starting a new task, check for clearly relevant skills and use them first. Key triggers:
- Session start -> `napkin`
- New data -> `datacheck`
- Plots -> `viz`
- Prose -> `plain-writing`. Default for docs and general-audience prose. For expert or academic writing, keep field terms and stay concise.
- Creative work -> `brainstorming`

Use `request_user_input` for structured questions when that tool is available. Fall back to concise plain-text questions otherwise.

## 2. Think Before Coding

- State assumptions.
- If uncertain, ask.
- Multiple interpretations -> present them, don't pick silently.
- If a simpler approach exists, say so.

## 3. Simplicity First

- No features, abstractions, or error handling beyond what's needed.
- Prefer concise solutions. If it looks overcomplicated, simplify.

## 4. Surgical Changes

- Don't improve, refactor, or reformat code you weren't asked to change.
- Match existing style. Assume the worktree may be dirty.
- Remove only orphans created by your own changes.
- Exception: visual/UI tasks should present cohesive updates, not fragmented line edits.

## 5. Reproducible Evidence

When running substantive analysis, not one-liners or sanity checks:
- Capture output via `tee` to `logs/YYYY-MM-DD_HH-MM-SS_<description>.log`.
- Keep `logs/` in `.gitignore`. Never commit logs.
- Never report results without evidence the code actually ran, such as a log, notebook output, or test report.

## 6. Git

- Inspect status and diffs before changing or committing files.
- Do not discard work you did not create.
- Never include `Co-Authored-By` in commit messages.

## 7. Prose & Markdown Line Breaks

- Never hard-wrap prose. Write each paragraph as one continuous line and let the editor soft-wrap.
- Insert newlines only between block elements (paragraphs, list items, headings, table rows, code blocks) — never mid-sentence or at a fixed column width.
- Applies to all `.md`, `.txt`, and general prose output. Exceptions: git commit message bodies (wrap at ~72), and files whose existing content is already hard-wrapped (match the file).
- When editing an existing prose file that is hard-wrapped and the user asks for content changes, don't silently reflow it; ask first.

## 8. Independent Review

- For important plans or results, get a review from a different model with `$claude` or `$agy`.
- Present the findings and wait for approval before changing files.
