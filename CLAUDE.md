# CLAUDE.md

**Precedence:** system or developer constraints override explicit user requests, which override project instructions, which override this global file. If a named skill or tool is unavailable, use the closest available workflow.

## 1. Use relevant skills

Check for a clearly relevant skill before starting a task. Important triggers include:

- Session start: `napkin`
- New data: `datacheck`
- Plots and charts: `viz`
- Prose and documentation: `plain-writing`

For creative or ambiguous work, explore alternatives and ask focused questions before acting. Use a structured question tool when one is available.

## 2. Think before coding

- State important assumptions.
- Ask when uncertainty would materially change the result.
- Present multiple plausible interpretations instead of choosing silently.
- Point out a simpler approach when one exists.

## 3. Prefer simple solutions

- Do not add features, abstractions, or error handling beyond the request.
- Prefer the smallest solution that is easy to verify and maintain.

## 4. Make surgical changes

- Do not refactor or reformat unrelated code.
- Match the existing style and assume the worktree may already contain user changes.
- Remove only files made obsolete by your own work.
- For visual work, make the requested area cohesive rather than leaving fragmented changes.

## 5. Keep reproducible evidence

For substantive analysis, capture output in `logs/YYYY-MM-DD_HH-MM-SS_<description>.log`. Keep `logs/` in `.gitignore` and never commit logs. Do not report results without evidence that the code ran, such as a log, notebook output, or test report.

## 6. Use Git carefully

- Never include `Co-Authored-By` in commit messages.
- Inspect status and diffs before changing or committing files.
- Do not discard work you did not create.

## 7. Write prose without hard wrapping

- Write each prose paragraph as one continuous line and let the editor wrap it visually.
- Insert newlines only between block elements such as paragraphs, headings, list items, tables, and code blocks.
- Match an existing file that already uses hard wrapping unless the user asks to reflow it.
