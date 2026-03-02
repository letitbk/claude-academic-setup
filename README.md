# Claude Code + Cursor Setup for Academic Researchers

AI-powered research workstation for social scientists using R, Stata, and Python. This setup configures Claude Code CLI and Cursor IDE with skills, plugins, and workflows designed for the academic research lifecycle.

---

## Quick Start

### Prerequisites

| Tool | Install |
|------|---------|
| Claude Code CLI | `curl -fsSL https://claude.ai/install.sh | bash` |
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

This installs 13 core skills, 7 slash commands, 1 hook, settings, global CLAUDE.md, Gemini CLI + Codex CLI, 14 core Cursor extensions, and Python/R packages. For the full toolkit (30 additional skills + 8 more extensions), run `bash install-optional.sh` after.

> **Security note:** The default settings use `bypassPermissions` mode — Claude executes all pre-approved commands (git, Python, R, Stata, etc.) without asking. Dangerous operations (SSH keys, credentials, `sudo`, `rm -rf /`, force push) are still blocked by the deny list. For a more cautious mode, copy the safe settings: `cp settings-safe.json ~/.claude/settings.json`

New to Claude Code? See the **[15-Minute Quickstart](docs/quickstart.md)** to get from zero to your first research session.

---

## How Claude Code Works (and Why This Setup Exists)

Claude Code is not a chatbot. It is an autonomous agent that runs in your terminal and IDE. Unlike conversation-based LLMs where you copy-paste code back and forth, Claude Code reads your files, writes code, executes it, checks the output, and iterates — all without you switching windows. Think of it as a research assistant that can read your data dictionary, write an R script, run it, check the diagnostics, and report the results.

**How it works — the agentic loop.** Claude gathers context (reads files, searches code) → takes action (writes code, runs commands) → verifies results (checks output, fixes errors) → repeats until the task is done. This is fundamentally different from asking a chatbot to generate code that you then manually run and debug.

**CLAUDE.md is your lab notebook.** Claude's context window is working memory — it resets every session. CLAUDE.md is persistent memory that Claude reads at the start of every session. Put your project description, analysis pipeline status, conventions, and key decisions here. This is how Claude remembers what happened last week.

**Skills, plugins, and permissions.** Skills are saved workflows that you invoke with `/skill-name` — they encode expertise so Claude knows how to run a survey analysis or review literature. Plugins add capabilities (GitHub integration, browser automation, notifications). Permissions are guardrails — the default config lets Claude run pre-approved commands automatically while blocking dangerous operations.

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

Use ralph-loop for autonomous iteration — Claude works through your analysis step by step until completion. The default configuration uses `bypassPermissions` mode — Claude executes pre-approved commands without asking. Dangerous operations are still blocked. For a more cautious mode where Claude asks before each command, copy `settings-safe.json` to `~/.claude/settings.json`.

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
/install pyright-lsp@claude-plugins-official
```

### 2. Connect Your Literature Tools

[**Zotero MCP**](https://github.com/54yyyu/zotero-mcp) (for literature management — highly recommended for social scientists):

1. Install [Zotero desktop app](https://www.zotero.org/download/) and keep it running
2. Get an API key from https://www.zotero.org/settings/keys
3. Find your user ID on the same page
4. Add to `~/.claude/settings.json`:

```json
"mcpServers": {
  "zotero": {
    "command": "npx",
    "args": ["-y", "zotero-mcp"],
    "env": {
      "ZOTERO_API_KEY": "YOUR_KEY",
      "ZOTERO_USER_ID": "YOUR_ID"
    }
  }
}
```

Once configured, Claude gains tools like `zotero_search_items`, `zotero_semantic_search`, `zotero_get_annotations`, and `zotero_get_item_fulltext`. The `lit-review` and `citation-verification` skills use these.

[**paper-search-mcp**](https://github.com/openags/paper-search-mcp) (for PubMed/arXiv/Semantic Scholar):

```json
"mcpServers": {
  "paper-search": {
    "command": "npx",
    "args": ["-y", "paper-search-mcp"]
  }
}
```

No API keys needed for basic usage.

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

## Optional Skills (30)

Install with `bash install-optional.sh`. These supplement the 13 core skills but are not required for the base workflow.

### Data Analysis

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `init-research-project` | Set up a new research project from data files: inspect data, generate codebook, conduct interactive research planning, and scaffold project structure with a reproducible pipeline. | Starting fresh with a new dataset and want structured project scaffolding from day one. |
| `finalize-analysis` | Organize messy exploratory work into a clean reproducible project with Snakemake pipeline and publication-ready outputs, one figure or table at a time. | Exploratory analysis is done and you need to clean up scripts into a numbered, reproducible pipeline. |
| `heterogeneity-analysis` | Subgroup and heterogeneity analysis in Stata using interaction models and stratified regression. | Examining whether treatment effects vary across groups (age, gender, race, etc.). |
| `konfound-sensitivity` | Quantify sensitivity to unmeasured confounding using the konfound package in Stata or R (ITCV and RIR metrics). | Assessing how much confounding would be needed to invalidate your causal findings. |
| `marginaleffects` | Compute marginal effects, comparisons, and predictions using the R marginaleffects package (AMEs, factor contrasts, continuous contrasts, predicted values). | Computing average marginal effects or factor contrasts from regression models in R. |
| `robustness-checks` | Sequential robustness checks with confounder blocks in Stata, showing how estimates change as potential confounders are added. | Running sensitivity analysis to demonstrate estimate stability across model specifications. |
| `analyze-ego-network` | Analyze ego-centric social networks to extract network size, composition, tie strength, and multiplexity using R egor package. | Working with personal network data, social support analysis, or network-health research. |

### Visualization

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `coefficient-plot` | Create publication-ready coefficient plots with significance coloring and category faceting in R ggplot2. | Visualizing regression results, marginal effects, or any estimates with confidence intervals. |
| `distribution-boxplot` | Create boxplots with custom statistics by group using R ggplot2, with reference lines and faceted layouts. | Comparing distributions across categories with median, quartiles, and range. |
| `marginal-effects-plot` | Visualize marginal effects from regression models with factor level parsing, reference category labeling, and multi-panel layouts in R ggplot2. | Plotting AMEs from Stata margins output or R marginaleffects output. |
| `viz` | Create any publication-ready data visualization using ggplot2 in R, with upfront visual requirement gathering. | Creating any chart, figure, or plot — or refining an existing visualization. |
| `imagegen` | Generate or edit images via the OpenAI Image API using a bundled CLI for deterministic, reproducible runs. | Generating concept art, product shots, diagrams, or editing existing images (inpainting, background removal). |

### Writing & Docs

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `draft-paper` | Write a research paper from completed analysis results, companion .md files, and iterative user input, covering all manuscript sections and literature review. | Analysis is complete and you want to write up results into a publication-ready manuscript. |
| `humanizer` | Detect and remove signs of AI-generated writing based on Wikipedia's "Signs of AI writing" guide, covering 24 pattern categories. | Editing text to make it sound more natural and less like AI-generated prose. |
| `marp-slide` | Create professional Marp presentation slides with 7 built-in themes (default, minimal, colorful, dark, gradient, tech, business). | Building a slide deck for a talk, lecture, or seminar. |
| `stop-slop` | Eliminate predictable AI writing patterns from prose — filler phrases, formulaic structures, and metronomic rhythm. | Drafting or editing prose and want to strip out obvious AI tells. |
| `grant-writing` | Draft grant proposal sections for NSF, NIH, and other agencies, covering Specific Aims, Significance, Innovation, Approach, Timeline, and Budget Justification. | Writing a competitive grant proposal with agency-specific formatting. |

### Research Workflow

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `clean-survey-data` | Clean survey data in R with missing value handling, variable recoding, and Stata label conversion to R factors. | Processing raw survey or health study data with coded missing values (91/92/97/98). |
| `compute-survey-weights` | Calculate participation-adjusted survey weights using logistic regression and inverse probability weighting in R. | Adjusting sampling weights for selection bias, non-response, or creating IPW weights. |
| `dataverse-sync` | Sync local repository with a Harvard Dataverse dataset using the Native API (upload, replace, delete files). | Uploading or updating files in a Dataverse dataset programmatically. |
| `dataverse-upload-zip` | Upload files to Harvard Dataverse via ZIP archive to bypass AWS WAF restrictions on .R and .do files. | Direct Dataverse uploads of R or Stata code files are failing with 403 Forbidden. |
| `qualtrics-survey` | Manage Qualtrics surveys via API — list blocks/questions, create/update questions, add JavaScript, manage embedded data and display logic. | Programmatically modifying an existing Qualtrics survey with LLM-powered features. |
| `setup-snakemake-pipeline` | Initialize Snakemake workflows with R and Stata integration for reproducible research pipelines. | Setting up a multi-language (R + Stata) reproducible data processing and analysis pipeline. |
| `survey-analysis` | Design-based survey analysis in R using the survey package: survey design setup, weighted descriptives, svyglm regression, raking, and calibration. | Running weighted survey analysis with complex survey designs in R. |
| `survey-regression-stata` | Run survey-weighted regression in Stata with svyset, margins for AMEs, and esttab export. | Running complex survey regression analysis with sampling weights in Stata. |

### Academic

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `citation-verification` | Cross-check manuscript citations against Zotero library and Crossref to catch wrong years, missing references, orphaned entries, and formatting inconsistencies. | Auditing your bibliography before submission to catch citation errors. |
| `research-ideation` | Structured hypothesis generation from literature gaps — maps existing research, identifies unanswered questions, and assesses feasibility with a rubric. | Brainstorming research questions or looking for what to study next in a given field. |
| `irb-protocol` | Draft IRB protocol documents from research descriptions, covering study purpose, procedures, risks/benefits, informed consent, and data security. | Preparing an IRB application for survey, interview, or secondary data research. |
| `notebooklm` | Query Google NotebookLM notebooks from Claude Code for source-grounded, citation-backed answers with browser automation and persistent auth. | Querying your uploaded documents in NotebookLM for answers grounded exclusively in your sources. |

### Security

| Skill | Description | When you need it |
|-------|-------------|------------------|
| `security-best-practices` | Perform language- and framework-specific security reviews for Python, JavaScript/TypeScript, and Go, with vulnerability reporting and fix suggestions. | Requesting a security review, vulnerability report, or secure-by-default coding guidance. |

---

## Cursor Extensions

This setup installs 22 Cursor/VS Code extensions. Core extensions (14) are installed by `install.sh`; optional extensions (8) by `install-optional.sh`. All extensions reviewed as of 2026-03-02 with no known security concerns.

### Core Extensions (14)

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

### Optional Extensions (8)

| Extension | Publisher | What It Does | For Researchers |
|---|---|---|---|
| `google.gemini-cli-vscode-ide-companion` | Google (official) | Gemini CLI companion for IDE | Optional AI assistant |
| `openai.chatgpt` | OpenAI (official) | Codex/ChatGPT integration | Optional AI assistant |
| `hediet.vscode-drawio` | Individual, open source | Draw.io diagram editor | Recommended for diagrams |
| `eamodio.gitlens` | GitKraken, 40M+ downloads | Git blame, history, authorship | Recommended for collaboration |
| `usernamehw.errorlens` | Individual, open source | Inline error/warning display | Optional for debugging |
| `oderwat.indent-rainbow` | Individual, open source | Color-coded indentation | Optional (readability) |
| `alefragnani.project-manager` | Individual (Alessandro Fragnani) | Multi-project management | Optional for multi-project work |
| `DeepEcon.stata-mcp` | DeepEcon.ai, MIT licensed | Stata MCP integration | Essential for Stata users |

---

## Configuration

### Default vs Safe Mode

The default `settings.json` uses `bypassPermissions` mode — Claude executes all pre-approved commands without asking. The `permissions.deny` list blocks dangerous operations.

For a more cautious mode, copy the safe settings:

```bash
cp settings-safe.json ~/.claude/settings.json
```

| Setting | Default | Safe |
|---------|---------|------|
| `defaultMode` | `bypassPermissions` | `acceptEdits` |
| `skipDangerousModePermissionPrompt` | `true` | `false` |

- **`bypassPermissions`** — Claude executes all allowed operations without confirmation. Practical for daily research workflows.
- **`acceptEdits`** — Claude reads and edits files freely but asks before running shell commands not in the allow list.

To switch back: `cp settings.json ~/.claude/settings.json`

### Settings Deep Dive

**`permissions.allow`** — Pre-approved tool patterns: file ops (`Read`, `Edit`, `Write`), Node/JS (`npm`, `npx`, `node`), git (status, diff, log, add, commit, push), shell reads (`ls`, `cat`, `find`, `grep`), Python (`python3`, `pip install`), R (`Rscript`, `R CMD`, `renv::`), Stata (`stata`, `stata-mp`), build tools (`make`, `snakemake`, `docker`), publishing (`quarto`, `pandoc`, `latexmk`), and web fetch for select domains.

**`permissions.deny`** — Hard blocks that override allow: secrets (`.ssh/*`, `.env`, `*credentials*`, `*.pem`), destructive commands (`sudo`, `rm -rf /`, `dd`, `mkfs`, `shutdown`, `chmod 777`), dangerous git (`push --force`), Docker cleanup.

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
| Zotero MCP not connecting | Ensure Zotero desktop app is running, API key is correct, and user ID is set in `mcpServers` config |
| `pip install` permission error | Use `pip3 install --user` or set up a virtual environment: `python3 -m venv .venv && source .venv/bin/activate` |
| R packages fail to install | Open R directly and run `install.packages("package_name")` to see detailed error messages |
| Claude seems confused or slow | Use `/compact` to clear old context, or `/clear` + start a new session |
| Claude won't run a command | Check if the command pattern is in `permissions.allow` in `~/.claude/settings.json` |
| Cursor extensions not installing | Ensure `cursor` is in PATH: open Cursor → `Shell Command: Install 'cursor' command in PATH` |
| Plugin install fails | Plugins require Claude Code CLI. Run `/install plugin-name@registry` inside a Claude session |
| `npm install -g` permission error | Use `sudo npm install -g` or configure npm to use a user directory: `npm config set prefix ~/.npm-global` |

---

## Verification

After install, check counts:

```bash
ls -d ~/.claude/skills/*/  | wc -l   # 13 (core) or 43+ (with optional)
ls ~/.claude/commands/*.md  | wc -l   # 7
python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d.get('enabledPlugins', {})))"  # 13
```

---

## Repo Structure

```
claude-academic-setup/
├── README.md                    # This file
├── CLAUDE.md                    # AI behavioral guidelines
├── install.sh                   # Core install (13 skills, 14 extensions)
├── install-optional.sh          # Optional add-ons (30 skills, 8 extensions)
├── settings.json                # Default settings (bypassPermissions mode)
├── settings-safe.json           # Safe mode (acceptEdits, asks before commands)
├── docs/
│   └── quickstart.md            # 15-minute quickstart guide
├── skills/                      # 43 skill directories
├── commands/                    # 7 command files
└── hooks/                       # 1 hook script
```

---

## Credits

- [CC101](https://cc101.axwith.com) (toggle to EN for English; [GitHub](https://github.com/fivetaku/cc101)) — comprehensive Claude Code tutorial. Core concepts in this README draw from their guide.
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
