# Repo Refresh: License, New Presentation, Local Sync, Plan-Based Reframe

**Date:** 2026-06-16
**Status:** Plan — awaiting go-ahead to execute

## Goal

Bring the repo in line with (1) the new talk *"Use Coding Agents as Research Tools: A Plan-Based Workflow for the Age of Generative AI"* (Northwestern QCMW, June 2 2026), (2) updated local skills, and (3) add an MIT license.

## Confirmed decisions (from brainstorming)

| Topic | Decision |
|-------|----------|
| `presentation.md` | **Delete it.** `presentation_ai_workflow.pdf` is the single canonical artifact. Fix all references. |
| Permissions default | **Keep Sandbox Mode** as the real default in `settings.json`; **lead the docs** with `claude --dangerously-skip-permissions` / `codex --yolo` and explain the trade-off honestly. |
| Skills/commands to sync | Update `gemini` + `codex` skills; **add** `plannotator-annotate` + `plannotator-last` commands; **add** `AGENTS.md`. **Exclude** `humanize`/`humanize-redo`. |
| `notebooklm` skill | Leave untracked / undocumented (not selected). Do not commit, do not delete. |
| Docs depth | **Moderate** reframe around "plan-based workflow"; keep existing structure. |

## Workstreams

### 1. MIT License
- Create `LICENSE`: standard MIT, `Copyright (c) 2026 BK Lee`.
- Add a short **License** section to `README.md` and a `LICENSE` line in the repo-structure tree.

### 2. Presentation swap
- Delete `presentation.md`.
- Keep `presentation_ai_workflow.pdf` (not gitignored — will be committed).
- `README.md:481` repo-structure: `presentation.md … Coding Agents for Academic Research` → `presentation_ai_workflow.pdf … Use Coding Agents as Research Tools: A Plan-Based Workflow`.
- Leave `skills/marp-slide/SKILL.md` mentions of `presentation.md` (generic examples, not our file).
- `.gitignore` `presentation.html` line is now orphaned — optional cleanup.

### 3. Skills + commands sync
- `skills/gemini/SKILL.md` ← local version (Antigravity `agy`; flags `-p`, `--add-dir`, `--dangerously-skip-permissions`).
- `skills/codex/SKILL.md` ← local version (GPT-5.5; `--sandbox workspace-write`; `< /dev/null` stdin guard; XML prompt templates; plan-evaluation mode; "STOP after findings" guardrail).
- Add `commands/plannotator-annotate.md` + `commands/plannotator-last.md` (copy from `~/.claude/commands/`).
- Add `AGENTS.md` at repo root mirroring `CLAUDE.md` (agent-agnostic behavioral file for codex/gemini).
- `install.sh`:
  - Command-count echo "5" → "7".
  - **gemini block (OPEN ITEM):** currently installs `@google/gemini-cli` and checks `command -v gemini`. The skill now requires `agy`, whose flags are NOT compatible with `gemini-cli`. Need the canonical `agy` install method (Antigravity). Proposed default: check for `agy`; if missing, warn + link to Antigravity download rather than auto-installing the wrong package.
  - Optionally also install `AGENTS.md` for codex users (e.g. `~/.codex/AGENTS.md`).
- `settings.json`: **unchanged** (Sandbox Mode stays). Personal local entries (vibe-island, superset, nyu-hpc guards, vim, themes, smart-move local path) are deliberately NOT brought over. Optional, low-priority: add `git init` / `git commit` / `mkdir` / `tee` to the allow-list to support the getting-started + `tee`-to-`logs/` flows.

### 4. README + quickstart moderate reframe
- Reframe narrative around **plan-based workflow** as the central concept.
- Update title/venue references to the new talk.
- **Agent-agnostic** framing: codex / claude code / gemini as interchangeable agents; **AGENTS.md** alongside CLAUDE.md.
- Quickstart: lead with `claude --dangerously-skip-permissions` / `codex --yolo`; explain the trade-off and that Sandbox Mode is the safer default they can switch to.
- `/gemini` section → Antigravity `agy` (install/auth, examples).
- `/codex` section → GPT-5.5.
- Add a "why first attempts fail" note: context contamination, lost-in-the-middle, decoder-only → fresh sessions, `/compact`, `/clear`, durable rules in CLAUDE.md/AGENTS.md/napkin.
- Add "tools that support the loop" framing (AskUserQuestion, superpowers, plannotator, discuss-claims, CLAUDE.md/napkin).
- Note skills-for-consistency vs subagents-for-isolation.
- Troubleshooting: `gemini` → `agy`; model versions; command count 5 → 7.
- Verification section: commands 5 → 7.

### 5. Consistency sweep + verify
- Re-grep for stale refs: `presentation.md`, `GPT-5.3`, `gemini-cli`, `"5 commands"`, old talk title.
- Update `MEMORY.md` (counts, gemini→agy, codex GPT-5.5, license, presentation, AGENTS.md, plannotator commands).
- Optional: run codex + gemini reviews in parallel (the confirmed review pattern) on the doc diffs.

## Open item to resolve before/at execution
- **`agy` install command** for `install.sh` (Antigravity). Resolve by: asking you, or a quick `agy`/web lookup during execution.

## Out of scope (explicit)
- `notebooklm`, `humanize`, `humanize-redo`, and all personal local config (hooks, themes, vim, HPC guards).
