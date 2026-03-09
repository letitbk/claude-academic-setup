# Claude Code + Cursor Setup for Academic Researchers

AI-powered research workstation for social scientists using R, Stata, and Python. This setup configures Claude Code CLI and Cursor IDE with skills, plugins, and workflows designed for the academic research lifecycle.

---

## Quick Start

### Prerequisites

| Tool | Install | Notes |
|------|---------|-------|
| Homebrew (macOS) | https://brew.sh/ | Package manager — makes everything below easier |
| Node.js 18+ | `brew install node` or https://nodejs.org/ | Required for Claude Code CLI and plugins |
| Python 3.10+ | `brew install python` or https://www.python.org/ | Required for analysis packages |
| jq | `brew install jq` | JSON processing |
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` | [Docs](https://docs.anthropic.com/en/docs/claude-code) |

**Windows users:** Install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) first, then follow the Linux instructions inside WSL.

Optional (install skips gracefully if absent): [Cursor](https://cursor.com/), [R 4.3+](https://cran.r-project.org/), [Stata 17+](https://www.stata.com/), [Quarto](https://quarto.org/docs/get-started/), pandoc (`brew install pandoc`), latexmk (`brew install --cask mactex-no-gui`).

### Install

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup
bash install.sh
```

This installs 12 core skills, 13 plugins, 5 slash commands, 1 hook, settings, global CLAUDE.md, Gemini CLI + Codex CLI, 14 Cursor extensions, and Python/R packages. For 10 additional skills, run `bash install-optional.sh` after.

> **Permissions mode:** The default settings use **Sandbox Mode** — Claude runs all commands inside an OS-level sandbox that restricts filesystem and network access. Commands execute without prompting because the sandbox itself provides the safety boundary. If you're new to Claude Code, consider starting with **Guided Mode** until you're comfortable: `cp settings-safe.json ~/.claude/settings.json`. In Guided Mode, Claude asks before running shell commands. You can check your current mode with `/permissions` inside a session.

New to Claude Code? See the **[15-Minute Quickstart](docs/quickstart.md)** to get from zero to your first research session.

---

## How Claude Code Works (and Why This Setup Exists)

Claude Code is not a chatbot. It is an autonomous agent that **runs in your terminal**. You can also use it inside IDEs — [Cursor](https://cursor.com/), [VS Code](https://code.visualstudio.com/), [Windsurf](https://windsurf.com/), and others — via the Claude Code extension. Unlike conversation-based LLMs where you copy-paste code back and forth, Claude Code reads your files, writes code, executes it, checks the output, and iterates — all without you switching windows. Think of it as a research assistant that can read your data dictionary, write an R script, run it, check the diagnostics, and report the results.

**How it works — the agentic loop.** Claude gathers context (reads files, searches code) → takes action (writes code, runs commands) → verifies results (checks output, fixes errors) → repeats until the task is done. This is fundamentally different from asking a chatbot to generate code that you then manually run and debug.

### CLAUDE.md — Your Lab Notebook

Claude's context window is working memory — it resets every session. CLAUDE.md is persistent memory that Claude reads at the start of every session. There are two levels:

- **Global** (`~/.claude/CLAUDE.md`) — applies to ALL projects. This setup installs one with behavioral guidelines (think before coding, simplicity first, surgical changes).
- **Project** (`your-project/CLAUDE.md`) — applies to ONE project. This is your lab notebook for that specific research project.

Every research project should have its own project-level CLAUDE.md. Here's an example:

```markdown
# Project: Parental Education and Child Health

## Research Question
Effect of parental education on children's self-rated health,
using NHIS 2024 data.

## Data Files
- data/nhis_2024.csv — Main dataset (N=12,847, cleaned)
- data/codebook.xlsx — Variable definitions and coding

## Pipeline Status
| Step | Status | Output |
|------|--------|--------|
| Data cleaning | Done | scripts/01_clean.R |
| Descriptives | Done | output/table1.docx |
| Main regression | In progress | scripts/03_ologit.R |
| Robustness checks | Not started | — |

## Conventions
- Missing values: coded as NA (recoded from 97/98/99)
- All models use survey weights (svyset already configured)
- Tables export to Word via modelsummary
- Standard errors clustered by region
```

### Skills, Plugins, and Commands

This setup installs three types of components. They work differently:

| | **Skills** | **Plugins** | **Commands** |
|---|---|---|---|
| **Think of it as** | Verbs — actions you take | Nouns — capabilities Claude has | Shortcuts — predefined prompts |
| **How invoked** | `/skill-name` or triggered automatically by what you say | Work in the background automatically | `/command-name` |
| **Example** | `/datacheck` inspects a data file | `playwright` lets Claude control a browser | `/updates-git` commits and updates docs |
| **Can you create your own?** | Yes — use `/skill-creator` and Claude helps you write it | Yes — use `/create-plugin` | Yes — add `.md` files to `~/.claude/commands/` |

**Skills trigger automatically.** You don't always need to type `/skill-name`. If you say "review my data file," Claude activates the `datacheck` skill. If you say "let's brainstorm research questions," Claude activates `brainstorming`. Explicit invocation (`/datacheck`) always works too.

**Plugins work silently.** Once installed, plugins add capabilities that Claude uses when needed. You don't invoke them — Claude just has more abilities (browser automation, GitHub integration, desktop notifications, etc.).

### Independent Verification Tools: /codex and /gemini

These skills send your work to other AI systems for independent review — like getting a second opinion from a different expert.

**`/codex`** — Sends your code or plan to OpenAI's GPT-5.3 for independent code review.
- **Best for:** Reviewing code changes, checking analysis logic, getting a second opinion on implementation
- **Install:** `npm install -g @openai/codex` ([GitHub](https://github.com/openai/codex))
- **Auth:** Run `codex` in terminal and sign in with your OpenAI account

**`/gemini`** — Uses Google's Gemini CLI for web search and URL analysis.
- **Best for:** Finding recent papers, checking facts, verifying claims against web sources, analyzing URLs
- **Install:** `npm install -g @google/gemini-cli` ([GitHub](https://github.com/google-gemini/gemini-cli))
- **Auth:** Run `gemini` in terminal and sign in with your Google account

**When to use which:** Use `/codex` for code review. Use `/gemini` for web research. Use both on important plans for maximum coverage — they catch different things. Both are installed automatically by `install.sh`; you only need to authenticate.

### Other Key Concepts

**Hooks** are event-driven automation — they run automatically when certain things happen. The included hook checks whether documentation needs updating when Claude finishes a task. Hooks can also send desktop notifications or validate file syntax after edits.

**Working across multiple projects.** Claude Code works project-by-project. Context doesn't carry across projects automatically. The upside: while Claude works autonomously on one project, you can review results from another. The downside: you need good documentation habits (CLAUDE.md + `/catch-up`) to maintain continuity. This setup includes skills specifically for this.

For a comprehensive beginner's guide to Claude Code, see [CC101](https://cc101.axwith.com) (toggle to EN for English; [GitHub](https://github.com/fivetaku/cc101)).

---

## The Research Lifecycle with Claude Code

### Phase 1: Research Design & Planning

Always start by planning. Tell Claude WHAT you want to do and WHY — not HOW. If you have ideas about methods, share them, but also ask Claude to explore alternatives. Use Plan Mode (`Shift+Tab`) for complex tasks so you can review Claude's approach before it executes anything.

Ask Claude to ask YOU questions back. This produces better results than writing a long prompt upfront — Claude identifies what it needs to know and you provide precise answers.

Review plans with `/codex` or `/gemini` for independent second opinions from GPT-5.3 or Gemini. Use superpowers + plannotator for multi-round detailed planning. Revise until all issues are resolved and you have a clear test framework.

**Plannotator: structured plan review.** After Claude generates a plan, the plannotator plugin opens an interactive review UI where you can annotate specific parts, leave comments, and request changes. This is the structured review step between planning and execution — it ensures you've examined every part of the plan before Claude starts writing code.

**What makes a good plan.** The more detail in your plan, the less you'll need to correct later. Spend 30% of your time planning. A good plan has:

1. **Clear scope** — what's in and what's out
2. **Specific steps** — not "analyze data" but "run ordered logistic regression on `self_rated_health ~ parent_education + controls`"
3. **Verification at each step** — how will you know each step succeeded?
4. **Edge cases identified** — missing data handling, outlier treatment, model convergence
5. **Dependencies** — which steps must complete before others can start

You can tell Claude: "Review this task and provide a plan that meets all five criteria above."

**Example — vague plan (bad):**

> 1. Clean the data
> 2. Run the regression
> 3. Make a table

**Example — detailed plan (good):**

> 1. Load `data/survey_2024.csv`, check encoding, inspect missing value codes (97/98/99). Recode as NA. → *verify: no coded missings remain in key variables*
> 2. Run ordered logistic regression: `self_rated_health ~ parent_education + household_income + age + gender + region` using `polr()`. → *verify: model converges, proportional odds assumption tested via `brant()` test*
> 3. Compute average marginal effects via `marginaleffects::avg_slopes()`. → *verify: AMEs have reasonable signs and magnitudes*
> 4. Export table via `modelsummary()` to `output/table1_ologit.docx` with 3 decimal places and stars. → *verify: table renders correctly in Word*

### Phase 2: Execution & Data Wrangling

Use ralph-loop for autonomous iteration — Claude works through your analysis step by step until completion. The default configuration uses Sandbox Mode — Claude executes commands freely within an OS-level sandbox that restricts filesystem and network access. For a more cautious mode where Claude asks before each command, copy `settings-safe.json` to `~/.claude/settings.json`.

Claude works like a research assistant through the agentic loop: reads your data, writes analysis code, runs it, checks diagnostics, and fixes issues — all without you intervening at each step.

### Phase 3: Validation & Interpretation

After analysis, ask Claude to produce a review document covering motivation, method, results, interpretation, limitations, and next steps. This creates a record of what was done and why, and helps you catch issues before they become problems.

You can ask Claude for detailed explanations of any part of the analysis — walk through the model specification, explain coefficient interpretations, or justify methodological choices. This works interactively: ask follow-up questions, request alternative explanations, or have Claude trace through what it actually did step by step.

Build validation skills with `/skill-creator` for checks you run repeatedly (e.g., specific diagnostic tests, robustness check sequences).

You can use `/discuss-claims` to create GitHub issues for structured review of your empirical claims. This is useful for collaborators who can comment directly on specific findings.

### Phase 4: Audit Trail & Reproducibility

The `/napkin` skill automatically tracks per-project learnings: mistakes made, corrections applied, patterns that work. This accumulates institutional knowledge within each project.

Keep CLAUDE.md and README updated — this is how Claude (and you) remembers what has been done and what comes next. If you repeat something three or more times, turn it into a skill with `/skill-creator`.

If you use git, use `/updates-git` after each analysis step — it commits changes and updates documentation (README, CLAUDE.md, napkin) in one pass. This creates a granular audit trail that meets open science requirements.

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
- **Always verify citations.** If you use Claude for literature-related work, verify every citation against the original source. The `lit-review` and `citation-verification` skills use API-based search (not LLM memory), but manual verification remains essential.

---

## Useful Commands

Commands you'll use daily. Full reference: [CC101](https://cc101.axwith.com) (toggle to EN).

### Terminal (before starting Claude)

| Command | What it does |
|---------|--------------|
| `claude` | Start interactive session in current directory |
| `claude -c` | Continue your last session (preserves full context) |
| `claude --resume` | Resume a named session — use with `/rename` to bookmark important sessions |
| `claude "do X"` | One-shot: ask a question and exit |
| `claude doctor` | Check installation health (plugins, permissions, hooks) |
| `claude update` | Update Claude Code to latest version |

### Inside a Session

| Command | What it does |
|---------|--------------|
| `/init` | Generate a CLAUDE.md for the current project — essential first step in any new repo |
| `/compact` | Compress conversation history to reclaim context window. Use when Claude starts forgetting things or after long debugging sessions |
| `/clear` | Full context reset. Use when switching to an unrelated topic |
| `/model` | Switch between Sonnet (fast, cheap), Opus (deep reasoning), Haiku (simple tasks) |
| `/memory` | Open and edit the project's CLAUDE.md directly |
| `/context` | Show how much of the context window is used — helps you decide when to `/compact` |
| `/plan` | Enter Plan Mode (same as `Shift+Tab`). Claude plans without executing |
| `/rename [name]` | Label the current session for easy `/resume` later |
| `/permissions` | View and manage what Claude can do (read, write, execute) |
| `/plugin` | Manage installed plugins |
| `/mcp` | Manage MCP server connections |

### Keyboard Shortcuts

| Shortcut | What it does |
|----------|--------------|
| `Shift+Tab` | Toggle Plan Mode — Claude plans without executing. Essential before complex tasks |
| `Esc Esc` | Rewind to the previous state — undo Claude's last action |
| `Shift+Enter` | Line break in your input (for multi-line prompts) |
| `Ctrl+C` | Cancel the current task |
| `Ctrl+D` | Exit Claude Code |

---

## Post-Install Setup

Plugins are installed automatically by `install.sh`. Authenticate the AI review tools:

```bash
gemini   # Sign in with Google account
codex    # Sign in with OpenAI account
```

---

## Core Components

### Core Skills (12)

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
| `brainstorming` | Idea-to-design sessions | Structured hypothesis generation with feedback loops |
| `datacheck` | Inspect data files | First step before any analysis — encoding, structure, values |

### Core Plugins (13)

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
| [`pyright-lsp`](https://github.com/anthropics/claude-plugins-official) | Python type checking and IntelliSense |

---

## Optional Skills (10)

Install with `bash install-optional.sh`. These supplement the 12 core skills but are not required for the base workflow.

### Data Analysis & Workflow

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `marginaleffects` | Compute marginal effects, comparisons, and predictions using the R marginaleffects package (AMEs, factor contrasts, continuous contrasts, predicted values). | Computing average marginal effects or factor contrasts from regression models in R. |
| `clean-survey-data` | Clean survey data in R with missing value handling, variable recoding, and Stata label conversion to R factors. | Processing raw survey or health study data with coded missing values (91/92/97/98). |
| `survey-analysis` | Design-based survey analysis in R using the survey package: survey design setup, weighted descriptives, svyglm regression, raking, and calibration. | Running weighted survey analysis with complex survey designs in R. |
| `dataverse-sync` | Sync local repository with a Harvard Dataverse dataset using the Native API (upload, replace, delete files). | Uploading or updating files in a Dataverse dataset programmatically. |
| `qualtrics-survey` | Manage Qualtrics surveys via API — list blocks/questions, create/update questions, add JavaScript, manage embedded data and display logic. | Programmatically modifying an existing Qualtrics survey with LLM-powered features. |

### Visualization

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `viz` | Create any publication-ready data visualization using ggplot2 in R, with upfront visual requirement gathering. | Creating any chart, figure, or plot — or refining an existing visualization. |

### Writing & Docs

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `humanizer` | Detect and remove signs of AI-generated writing based on Wikipedia's "Signs of AI writing" guide, covering 24 pattern categories. | Editing text to make it sound more natural and less like AI-generated prose. |
| `marp-slide` | Create professional Marp presentation slides with 7 built-in themes (default, minimal, colorful, dark, gradient, tech, business). | Building a slide deck for a talk, lecture, or seminar. |
| `stop-slop` | Eliminate predictable AI writing patterns from prose — filler phrases, formulaic structures, and metronomic rhythm. | Drafting or editing prose and want to strip out obvious AI tells. |

### Security

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `security-best-practices` | Perform language- and framework-specific security reviews for Python, JavaScript/TypeScript, and Go, with vulnerability reporting and fix suggestions. | Requesting a security review, vulnerability report, or secure-by-default coding guidance. |

---

## Cursor Extensions (14)

Installed by `install.sh`. All extensions reviewed as of 2026-03-02 with no known security concerns.

| Extension | Publisher | What It Does | For Researchers |
|---|---|---|---|
| `anthropic.claude-code` | Anthropic (official) | Claude AI integration in IDE | Essential |
| `shd101wyy.markdown-preview-enhanced` | Individual (Yiyi Wang) | Advanced markdown preview with LaTeX, Mermaid, pandoc | Recommended |
| `bierner.markdown-mermaid` | Individual (Matt Bierner) | Mermaid diagram support in markdown | Recommended |
| `mechatroner.rainbow-csv` | Individual, 19M+ downloads | Rainbow CSV highlighting + SQL queries | Essential for data work |
| `grapecity.gc-excelviewer` | GrapeCity (commercial) | Read-only Excel/CSV viewer | Recommended for data work |
| `redhat.vscode-yaml` | Red Hat (official) | YAML validation and completion | Recommended for config files |
| `streetsidesoftware.code-spell-checker` | Street Side Software, 11M+ installs | Spell checking in code/docs | Recommended for academic writing |
| `pkief.material-icon-theme` | Individual (Philipp Kief) | File icon theme | Optional (cosmetic) |
| `james-yu.latex-workshop` | Individual (James Yu) | LaTeX build, preview, SyncTeX | Essential for LaTeX users |
| `ltex-plus.vscode-ltex-plus` | Open source community | Grammar/spell check for LaTeX/Markdown (offline) | Essential for academic writing |
| `quarto.quarto` | Quarto project (official) | Quarto document support | Essential for Quarto users |
| `REditorSupport.r` | R community (open source) | R language support, IntelliSense, terminal | Essential for R users |
| `ms-python.python` | Microsoft (official) | Python IntelliSense, debugging, linting | Essential for Python users |
| `ms-toolsai.jupyter` | Microsoft (official) | Jupyter notebook support | Recommended for interactive analysis |

---

## Configuration

### Sandbox Mode vs Guided Mode

| Setting | Default (Sandbox) | Safe (Guided) |
|---------|---------|------|
| `sandbox.enabled` | `true` | `true` |
| `sandbox.autoAllowBashIfSandboxed` | `true` | `false` |
| `sandbox.allowUnsandboxedCommands` | `false` | `false` |

- **Sandbox Mode** — Claude runs all commands inside an OS-level sandbox that restricts filesystem and network access. Commands auto-execute because the sandbox itself provides the safety boundary — Claude can only read/write within the project directory and cannot access secrets, credentials, or the network beyond allowed hosts. This is the recommended default.
- **Guided Mode** — Claude reads and edits files freely but asks before running any shell commands. The sandbox is still active for added security. Recommended if you're new to Claude Code.

If you're new, start with Guided Mode:

```bash
cp settings-safe.json ~/.claude/settings.json
```

To switch to Sandbox Mode: `cp settings.json ~/.claude/settings.json`

Check your current mode with `/permissions` inside a session.

### Settings Deep Dive

**`sandbox`** — OS-level isolation that restricts filesystem and network access. Commands can only read/write within the project directory and allowed paths. Network access is limited to allowed hosts. This is the primary security boundary — even if a command is in the allow list, the sandbox prevents it from accessing secrets or writing outside the project.

**`permissions.allow`** — Pre-approved tool patterns: file ops (`Read`, `Edit`, `Write`), Node/JS (`npm`, `npx`, `node`), git (status, diff, log, add, commit, push), shell reads (`ls`, `cat`, `find`, `grep`), Python (`python3`, `pip install`), R (`Rscript`, `R CMD`, `renv::`), Stata (`stata`, `stata-mp`), build tools (`make`, `snakemake`, `docker`), publishing (`quarto`, `pandoc`, `latexmk`), and web fetch for select domains.

**`permissions.deny`** — Additional blocks that override allow: secrets (`.ssh/*`, `.env`, `*credentials*`, `*.pem`), destructive commands (`sudo`, `rm -rf /`, `dd`, `mkfs`, `shutdown`, `chmod 777`), dangerous git (`push --force`), Docker cleanup.

**`hooks`** — Two hooks configured: (1) Stop hook (`check-docs-update.sh`) runs after Claude finishes responding, prompts to update documentation. (2) PostToolUse hook validates `.json`, `.R`, and `.yml` files after every write/edit.

**`alwaysThinkingEnabled`** — Extended thinking (chain-of-thought) for every response. Improves quality on complex reasoning but uses more tokens.

### Context Management

- **`/compact`** — Compress conversation history, reclaim working memory. Use when Claude starts forgetting earlier context.
- **`/clear`** — Full reset. Use when switching to an unrelated topic.
- **Model selection:** Sonnet for most tasks (fast, cost-effective). Opus for complex multi-step reasoning. Haiku for simple lookups.
- **Token monitoring:** [ccusage CLI](https://github.com/ryoppippi/ccusage) or [Claude Code Usage Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor).
- **Start new sessions for unrelated tasks.** Context from a data analysis session will confuse a paper-writing session.
- **CLAUDE.md is persistent memory.** Conversation context resets each session; CLAUDE.md persists.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `command not found: claude` | Install Claude Code: `npm install -g @anthropic-ai/claude-code` |
| `command not found: Rscript` | Install R from https://cran.r-project.org/ or add to PATH |
| `command not found: stata` / `stata-mp` | Stata must be installed separately and in PATH. Check: `which stata-mp` |
| `command not found: quarto` | Install from https://quarto.org/docs/get-started/ |
| `command not found: gemini` | Run `npm install -g @google/gemini-cli` then `gemini` to authenticate |
| `command not found: codex` | Run `npm install -g @openai/codex` then `codex` to authenticate |
| `pip install` permission error | Use `pip3 install --user` or set up a virtual environment: `python3 -m venv .venv && source .venv/bin/activate` |
| R packages fail to install | Open R directly and run `install.packages("package_name")` to see detailed error messages |
| Claude seems confused or slow | Use `/compact` to clear old context, or `/clear` + start a new session |
| Claude won't run a command | Check if the command pattern is in `permissions.allow` in `~/.claude/settings.json` |
| Cursor extensions not installing | Ensure `cursor` is in PATH: open Cursor → `Shell Command: Install 'cursor' command in PATH` |
| Plugin install fails | Run `claude plugin install plugin-name@marketplace` from terminal, or `/install plugin-name@marketplace` inside a Claude session |
| `npm install -g` permission error | Use `sudo npm install -g` or configure npm to use a user directory: `npm config set prefix ~/.npm-global` |
| `command not found: brew` (macOS) | Install Homebrew: `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| `command not found: node` | macOS: `brew install node`. Linux: see https://github.com/nodesource/distributions |

---

## FAQ

**What's the difference between CLAUDE.md and a plan?**
CLAUDE.md is persistent memory that Claude reads every session — your project description, conventions, pipeline status. A plan is a one-time document Claude creates for a specific task. Plans live under `~/.claude/plans/` and are always recoverable. Think of CLAUDE.md as your lab notebook and plans as scratch paper.

**What's the difference between skills, commands, and plugins?**
Skills are rich workflows with logic (e.g., `/datacheck` runs a multi-step data inspection). Commands are simple prompts (e.g., `/updates-git` runs a predefined update script). Plugins add capabilities to Claude itself (e.g., `playwright` lets Claude control a browser). Skills and commands are invoked with `/name`; plugins work automatically in the background. See the [comparison table](#skills-plugins-and-commands) above.

**Do I need to invoke skills manually?**
Not always. Skills trigger automatically based on what you say. If you say "review my data file," Claude activates the `datacheck` skill. You can also invoke them explicitly with `/datacheck`.

**Can Claude overwrite my files?**
In Guided Mode, Claude asks before running shell commands — you approve each one. In Sandbox Mode, Claude executes commands freely but within an OS-level sandbox that restricts filesystem and network access. See [Sandbox Mode vs Guided Mode](#sandbox-mode-vs-guided-mode).

**How do I track token usage and costs?**
Claude Code uses Anthropic API credits (separate from a Claude Pro subscription). Monitor usage with [ccusage](https://github.com/ryoppippi/ccusage) CLI or [Claude Code Usage Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor). Check billing at your [Anthropic Console](https://console.anthropic.com/). Sonnet is cheapest; Opus costs more but handles complex reasoning.

**What model should I use?**
Sonnet for most tasks (fast, cost-effective). Opus for complex multi-step reasoning. Haiku for simple lookups. Switch with `/model`.

**Where are conversations saved?**
Under `~/.claude/` — all conversations, plans, and session history are stored locally and recoverable.

**Is my data sent to train the model?**
No. Claude Code uses the Anthropic API, which does not use your data for model training. Your code and data stay between you and the API. Important for IRB-sensitive research — but still avoid sending PII or protected data in prompts when possible.

**How do I know the code Claude writes is correct?**
Claude runs code and checks output through the agentic loop — but it can still make mistakes. Always review output, check diagnostics, and verify results against known benchmarks. Use `/codex` or `/gemini` for independent second opinions on critical code.

**When should I use /codex vs /gemini?**
Use `/codex` for code review and implementation feedback (GPT-5.3). Use `/gemini` for web research, finding papers, and fact-checking. Use both on important plans for maximum coverage. See [Independent Verification Tools](#independent-verification-tools-codex-and-gemini).

---

## Verification

After install, check counts:

```bash
ls -d ~/.claude/skills/*/  | wc -l   # 12 (core) or 22 (with optional)
ls ~/.claude/commands/*.md  | wc -l   # 5
python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d.get('enabledPlugins', {})))"  # 13
```

---

## Repo Structure

```
claude-academic-setup/
├── README.md                    # This file
├── CLAUDE.md                    # AI behavioral guidelines
├── presentation.md              # Marp slide deck: Coding Agents for Academic Research
├── install.sh                   # Core install (12 skills, 14 extensions)
├── install-optional.sh          # Optional add-ons (10 skills)
├── settings.json                # Default settings (sandbox mode)
├── settings-safe.json           # Safe mode (guided, asks before commands)
├── docs/
│   └── quickstart.md            # 15-minute quickstart guide
├── skills/                      # 22 skill directories
├── commands/                    # 5 command files
└── hooks/                       # 1 hook script
```

---

## Credits

- [CC101](https://cc101.axwith.com) (toggle to EN for English; [GitHub](https://github.com/fivetaku/cc101)) — comprehensive Claude Code tutorial. Core concepts in this README draw from their guide.
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
