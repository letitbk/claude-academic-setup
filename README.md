# Claude Code + Cursor Setup for Academic Researchers

AI-powered research workstation for social scientists using R, Stata, and Python. This setup configures Claude Code CLI and Cursor IDE with skills, plugins, and workflows designed for the academic research lifecycle.

---

## Quick Start

### Prerequisites

| Tool | Install |
|------|---------|
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` |
| Node.js 18+ | https://nodejs.org/ |
| Python 3.10+ | https://www.python.org/ |
| jq | `brew install jq` |

Optional (install skips gracefully if absent): [Cursor](https://cursor.com/), [R 4.3+](https://cran.r-project.org/), [Stata 17+](https://www.stata.com/), [Quarto](https://quarto.org/docs/get-started/), pandoc, latexmk.

### Install

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup
bash install.sh
```

This installs 13 core skills, 7 slash commands, 1 hook, permissive-default settings, global CLAUDE.md, Gemini CLI + Codex CLI, 14 core Cursor extensions, and Python/R packages. For the full toolkit (30 additional skills + 8 more extensions), run `bash install-optional.sh` after.

> **Security note:** The default settings skip the startup warning dialog so Claude works without interruption. Pre-approved commands (git, Python, R, Stata, etc.) run automatically; dangerous operations (SSH keys, credentials, `sudo`, `rm -rf /`, force push) are blocked. If you want a confirmation dialog at each session start, copy the safe settings: `cp settings-safe.json ~/.claude/settings.json`

---

## How Claude Code Works (and Why This Setup Exists)

Claude Code is not a chatbot. It is an autonomous agent that runs in your terminal and IDE. Unlike conversation-based LLMs where you copy-paste code back and forth, Claude Code reads your files, writes code, executes it, checks the output, and iterates — all without you switching windows. Think of it as a research assistant that can read your data dictionary, write an R script, run it, check the diagnostics, and report the results.

**How it works — the agentic loop.** Claude gathers context (reads files, searches code) → takes action (writes code, runs commands) → verifies results (checks output, fixes errors) → repeats until the task is done. This is fundamentally different from asking a chatbot to generate code that you then manually run and debug.

**CLAUDE.md is your lab notebook.** Claude's context window is working memory — it resets every session. CLAUDE.md is persistent memory that Claude reads at the start of every session. Put your project description, analysis pipeline status, conventions, and key decisions here. This is how Claude remembers what happened last week.

**Skills, plugins, and permissions.** Skills are saved workflows that you invoke with `/skill-name` — they encode expertise so Claude knows how to run a survey analysis or review literature. Plugins add capabilities (GitHub integration, browser automation, notifications). Permissions are guardrails — the default config lets Claude edit files and run pre-approved commands (git, Python, R, Stata) automatically, while blocking dangerous operations.

**Hooks** are event-driven automation — they run automatically when certain things happen. The included hook checks whether documentation needs updating when Claude finishes a task. Hooks can also send desktop notifications or validate file syntax after edits.

**Working across multiple projects.** Claude Code works project-by-project. Context doesn't carry across projects automatically. The upside: while Claude works autonomously on one project, you can review results from another. The downside: you need good documentation habits (CLAUDE.md + `/catch-up`) to maintain continuity. This setup includes skills specifically for this.

For a comprehensive beginner's guide to Claude Code, see [CC101](https://cc101.axwith.com) (toggle to EN for English; [GitHub](https://github.com/fivetaku/cc101)).

---

## The Research Lifecycle with Claude Code

### Phase 1: Research Design & Planning

Always start by planning. Tell Claude WHAT you want to do and WHY — not HOW. If you have ideas about methods, share them, but also ask Claude to explore alternatives. Use Plan Mode (`Shift+Tab`) for complex tasks so you can review Claude's approach before it executes anything.

Ask Claude to ask YOU questions back. This produces better results than writing a long prompt upfront — Claude identifies what it needs to know and you provide precise answers.

Review plans with `/codex` or `/gemini` for independent second opinions from GPT-5.3 or Gemini. Use superpowers + plannotator for multi-round detailed planning. Revise until all issues are resolved and you have a clear test framework.

### Phase 2: Execution & Data Wrangling

Use ralph-loop for autonomous iteration — Claude works through your analysis step by step until completion. The default configuration uses permissive permissions — Claude executes pre-approved commands without asking. Dangerous operations are still blocked (see [security details](docs/advanced-config.md)). For a more cautious mode where Claude asks before each command, copy `settings-safe.json` to `~/.claude/settings.json`.

Claude works like a research assistant through the agentic loop: reads your data, writes analysis code, runs it, checks diagnostics, and fixes issues — all without you intervening at each step.

### Phase 3: Validation & Interpretation

After analysis, use `/discuss-claims` to create GitHub issues for structured review of your empirical claims. This is useful for collaborators who can comment directly on specific findings.

Ask Claude to produce a review document covering motivation, method, results, interpretation, limitations, and next steps. This creates a record of what was done and why, and helps you catch issues before they become problems.

You can ask Claude for detailed explanations of any part of the analysis — walk through the model specification, explain coefficient interpretations, or justify methodological choices. This works interactively: ask follow-up questions, request alternative explanations, or have Claude trace through what it actually did step by step.

Build validation skills with `/skill-creator` for checks you run repeatedly (e.g., specific diagnostic tests, robustness check sequences).

### Phase 4: Audit Trail & Reproducibility

Use `/updates-git` after each analysis step — it commits changes and updates documentation (README, CLAUDE.md, napkin) in one pass. This creates a granular audit trail that meets open science requirements.

The `/napkin` skill automatically tracks per-project learnings: mistakes made, corrections applied, patterns that work. This accumulates institutional knowledge within each project.

Keep CLAUDE.md and README updated — this is how Claude (and you) remembers what has been done and what comes next. If you repeat something three or more times, turn it into a skill with `/skill-creator`.

### Phase 5: Project Management & Sustainability

Use `/catch-up` when returning to a project after time away — it rebuilds full project context from documentation, git history, and recent changes.

Use `/compact` when your conversation gets long and filled with irrelevant context (failed attempts, old errors). Use `/clear` when switching topics entirely. Start new sessions for unrelated tasks.

Notifications via claude-notifications-go alert you when Claude finishes a task or needs input — essential when Claude works autonomously.

Monitor token usage with [ccusage](https://github.com/ryoppippi/ccusage) CLI or [Claude Code Usage Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor). Choose the right model: Sonnet for most tasks, Opus for complex reasoning.

---

## Tips & Lessons Learned

- **Plan as much as possible.** Use Plan Mode (`Shift+Tab`) before any non-trivial task. Have Claude outline its approach, review it with `/codex` or `/gemini`, and revise until you're satisfied. Planning is cheap; re-doing analysis is expensive.
- **Specify WHAT and WHY, not HOW.** Let Claude figure out the implementation. If you have ideas about methods, share them as context, but also ask Claude to explore alternatives.
- **Ask Claude to ask you questions back.** The AskUserQuestion pattern produces better results than writing a long prompt upfront.
- **Context is working memory.** Irrelevant context (failed attempts, old errors) degrades performance. Use `/compact` regularly. Start new sessions for unrelated work.
- **Start without custom subagents.** Claude's built-in Task tool handles most multi-step work. Add specific agents only when you hit limitations.
- **Plans are saved automatically.** All plans and conversations are stored locally under `~/.claude/plans` — they're always recoverable. You can also document plans in your project folder.
- **Use GitHub issues for collaboration.** Ask Claude to create issues summarizing completed work so collaborators can comment and review.
- **Create skills for repeated work.** If you do something more than twice, use `/skill-creator` to codify it. Use skills to reference the same resources (packages, databases) consistently.

---

## Post-Install Setup

### 1. Install Claude Code Plugins (inside CLI)

Open Claude Code and run each command:

```
/install superpowers@obra
/install plannotator@plannotator
/install claude-notifications-go@claude-notifications-go
/install ralph-loop@claude-plugins-official
/install playwright@claude-plugins-official
/install code-review@claude-plugins-official
/install github@claude-plugins-official
/install context7@claude-plugins-official
/install feature-dev@claude-plugins-official
/install code-simplifier@claude-plugins-official
/install commit-commands@claude-plugins-official
/install plugin-dev@claude-plugins-official
/install clangd-lsp@claude-plugins-official
/install pyright-lsp@claude-plugins-official
```

### 2. Connect Your Literature Tools

[**Zotero MCP**](https://github.com/54yyyu/zotero-mcp) (for literature management — highly recommended for social scientists):
- Install Zotero desktop app and keep it running
- Get API key from https://www.zotero.org/settings/keys
- See [docs/advanced-config.md](docs/advanced-config.md) for full setup

[**paper-search-mcp**](https://github.com/openags/paper-search-mcp) (for PubMed/arXiv/Semantic Scholar):
- Add to mcpServers config or run via `npx -y paper-search-mcp`

### 3. Authenticate AI Review Tools

```bash
gemini   # Sign in with Google account
codex    # Sign in with OpenAI account
```

---

## Core Components

### Core Skills (13)

| Skill | What | Analytic Value |
|-------|------|----------------|
| `napkin` | Per-repo learning tracker | Lab notebook for project decisions and corrections |
| `catch-up` | Resume after time away | Rebuilds context across multi-project workflows |
| `codex` | Review via OpenAI Codex | Independent second opinion on code and analysis |
| `gemini` | Web search via Gemini | Real-time information and literature verification |
| `discuss-claims` | GitHub issue discussions | Structured review of empirical claims and causal arguments |
| `skill-creator` | Create new skills | Codify repeated analysis workflows for reuse |
| `screenshot` | Desktop screenshots | Visual verification of plots and outputs |
| `playwright` | Browser automation | Web scraping, form filling, survey platform automation |
| `pdf` | Read/create/review PDFs | Paper reading and document preparation |
| `doc` | Read/create/edit .docx | Manuscript and report handling |
| `lit-review` | Literature reviews | Zotero + paper-search integration for systematic reviews |
| `brainstorming` | Idea-to-design sessions | Structured hypothesis generation with feedback loops |
| `datacheck` | Inspect data files | First step before any analysis — encoding, structure, values |

### Core Plugins (14)

| Plugin | Analytic Value |
|--------|----------------|
| [`superpowers`](https://github.com/obra/superpowers) | Extended Claude capabilities for complex multi-step tasks |
| [`plannotator`](https://github.com/backnotprop/plannotator) | Interactive plan annotation and structured review |
| [`claude-notifications-go`](https://github.com/777genius/claude-notifications-go) | Desktop alerts when Claude finishes or needs input |
| [`ralph-loop`](https://github.com/anthropics/claude-plugins-official) | Autonomous task iteration through the full agentic loop |
| [`playwright`](https://github.com/anthropics/claude-plugins-official) | Browser automation from within Claude sessions |
| [`code-review`](https://github.com/anthropics/claude-plugins-official) | Structured code review with actionable feedback |
| [`github`](https://github.com/anthropics/claude-plugins-official) | Git/GitHub integration for issues, PRs, and collaboration |
| [`context7`](https://github.com/upstash/context7) | Up-to-date library documentation lookup during coding |
| [`feature-dev`](https://github.com/anthropics/claude-plugins-official) | Guided feature development with codebase understanding |
| [`code-simplifier`](https://github.com/anthropics/claude-plugins-official) | Reduce code complexity while preserving functionality |
| [`commit-commands`](https://github.com/anthropics/claude-plugins-official) | Streamlined git commit, push, and PR workflows |
| [`plugin-dev`](https://github.com/anthropics/claude-plugins-official) | Create and manage custom plugins |
| [`clangd-lsp`](https://github.com/anthropics/claude-plugins-official) | C/C++ language server for compiled code analysis |
| [`pyright-lsp`](https://github.com/anthropics/claude-plugins-official) | Python type checking and IntelliSense |

---

## Optional Add-ons

For the full toolkit — 30 additional skills for survey analysis, causal inference, visualization, grant writing, and more:

```bash
bash install-optional.sh
```

See:
- [Optional Skills](docs/optional-skills.md) — 30 domain-specific skills organized by category
- [Cursor Extensions](docs/cursor-extensions.md) — all 22 extensions with safety and usefulness info
- [Advanced Configuration](docs/advanced-config.md) — safe mode, MCP servers, settings deep dive

---

## Verification

After install, check counts:

```bash
ls -d ~/.claude/skills/*/  | wc -l   # 13 (core) or 43+ (with optional)
ls ~/.claude/commands/*.md  | wc -l   # 7
python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d.get('enabledPlugins', {})))"  # 14
```

---

## Repo Structure

```
claude-academic-setup/
├── README.md                    # This file
├── CLAUDE.md                    # AI behavioral guidelines
├── install.sh                   # Core install (13 skills, 14 extensions)
├── install-optional.sh          # Optional add-ons (30 skills, 8 extensions)
├── settings.json                # Permissive-default Claude Code settings
├── settings-safe.json           # Safe mode (asks before shell commands)
├── docs/
│   ├── optional-skills.md       # 30 optional skills reference
│   ├── cursor-extensions.md     # All extensions with safety info
│   └── advanced-config.md       # Permissive mode, MCP, settings guide
├── skills/                      # 43 skill directories
├── commands/                    # 7 command files
└── hooks/                       # 1 hook script
```

---

## Credits

- [CC101](https://cc101.axwith.com) (toggle to EN for English; [GitHub](https://github.com/fivetaku/cc101)) — comprehensive Claude Code tutorial. Core concepts in this README draw from their guide.
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
