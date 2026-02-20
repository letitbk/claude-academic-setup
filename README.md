# Claude Code + Cursor Setup for Academic Researchers

AI-executable setup guide. An LLM agent can clone this repo and run the install script to configure a complete academic research workstation with Claude Code CLI + Cursor.

**Target user:** Social science researcher (survey research, causal inference, panel data). Uses R, Stata, Python. Bilingual Korean + English.

**What this installs:** 15-22 Cursor extensions, 16 Claude Code plugins, 43 custom skills, 32 custom agents, 6 slash commands, 1 hook, global CLAUDE.md instructions, multi-AI tools (Gemini CLI + Codex CLI), and Python/R packages.

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup

# 2. Run the install script
bash install.sh
```

---

## Prerequisites

### Required
| Tool | Install |
|------|---------|
| Claude Code CLI | `npm install -g @anthropic-ai/claude-code` |
| Node.js 18+ | https://nodejs.org/ |
| Python 3.10+ | https://www.python.org/ |
| jq | `brew install jq` |

### Optional (guarded — install skips gracefully if absent)
| Tool | Install | Used for |
|------|---------|----------|
| Cursor | https://cursor.com/ | IDE extensions |
| R 4.3+ | https://cran.r-project.org/ | Survey analysis, marginaleffects |
| Stata 17+ | https://www.stata.com/ | Survey regression, panel data |
| Quarto | https://quarto.org/docs/get-started/ | Reproducible documents (.qmd) |
| pandoc | `brew install pandoc` | Document conversion |
| latexmk | `brew install --cask mactex-no-gui` | LaTeX compilation |

---

## Manual Steps After Install

### 1. Install Claude Code Plugins (inside CLI)

Open Claude Code and run each command:

```
/install superpowers@obra
/install context7@claude-plugins-official
/install github@claude-plugins-official
/install feature-dev@claude-plugins-official
/install playwright@claude-plugins-official
/install code-review@claude-plugins-official
/install commit-commands@claude-plugins-official
/install plannotator@plannotator
/install ralph-loop@claude-plugins-official
/install claude-notifications-go@claude-notifications-go
/install code-simplifier@claude-plugins-official
/install clangd-lsp@claude-plugins-official
/install pyright-lsp@claude-plugins-official
/install figma@claude-plugins-official
/install plugin-dev@claude-plugins-official
/install frontend-design@claude-code-plugins
```

### 2. Set Up MCP Servers

**Zotero MCP** (for literature management):
- Install Zotero desktop app and keep it running
- Set up API key: see https://github.com/kujenga/zotero-mcp

**paper-search-mcp** (for PubMed/arXiv/Semantic Scholar):
- Add to mcpServers config or run via `npx -y paper-search-mcp`

### 3. Authenticate AI Tools

```bash
gemini   # Sign in with Google account
codex    # Sign in with OpenAI account
```

---

## What's Included

### Skills (43)

#### Data Analysis (8)
| Skill | Description |
|-------|-------------|
| `datacheck` | Inspect data files before analysis |
| `finalize-analysis` | Organize exploratory analyses into clean reproducible projects |
| `heterogeneity-analysis` | Subgroup and interaction models in Stata |
| `init-research-project` | Initialize new research project from data files |
| `konfound-sensitivity` | Sensitivity analysis for unmeasured confounding |
| `marginaleffects` | Marginal effects computation in R |
| `robustness-checks` | Sequential robustness checks in Stata |
| `analyze-ego-network` | Ego-centric social network analysis in R |

#### Visualization (5)
| Skill | Description |
|-------|-------------|
| `coefficient-plot` | Publication-ready coefficient plots in R |
| `distribution-boxplot` | Boxplots with custom statistics in R |
| `marginal-effects-plot` | Marginal effects visualizations in R |
| `viz` | General data visualization (plotnine, plotly) |
| `imagegen` | AI image generation via OpenAI API |

#### Writing & Docs (8)
| Skill | Description |
|-------|-------------|
| `brainstorming` | Interactive idea-to-design sessions |
| `discuss-claims` | Create GitHub issues for empirical claim discussion |
| `doc` | Read/create/edit .docx documents |
| `draft-paper` | Draft research papers from analysis results |
| `humanizer` | Remove AI writing patterns from text |
| `marp-slide` | Create Marp presentation slides (7 themes) |
| `pdf` | Read/create/review PDF files |
| `stop-slop` | Remove predictable AI tells from prose |

#### Research Workflow (10)
| Skill | Description |
|-------|-------------|
| `catch-up` | Resume work after time away from a project |
| `clean-survey-data` | Clean survey data with missing values and recoding |
| `compute-survey-weights` | Calculate participation-adjusted survey weights |
| `dataverse-sync` | Sync data with Harvard Dataverse |
| `dataverse-upload-zip` | Upload zipped data to Dataverse |
| `qualtrics-survey` | Manage Qualtrics surveys via API |
| `setup-snakemake-pipeline` | Initialize Snakemake workflows for reproducible research |
| `survey-analysis` | Design-based survey analysis in R |
| `survey-regression-stata` | Survey-weighted regression in Stata |
| `napkin` | Per-repo learning tracker (always active) |

#### Academic (5 new)
| Skill | Description |
|-------|-------------|
| `lit-review` | Structured literature reviews via Zotero + paper-search MCP |
| `citation-verification` | Cross-check citations against Zotero and Crossref |
| `grant-writing` | NSF/NIH grant section drafting |
| `research-ideation` | Hypothesis generation from literature gaps |
| `irb-protocol` | Draft IRB protocols (survey, interview, secondary data) |

#### Utilities (6)
| Skill | Description |
|-------|-------------|
| `codex` | Code review via OpenAI Codex CLI |
| `gemini` | Web search via Gemini CLI |
| `notebooklm` | Query Google NotebookLM notebooks |
| `playwright` | Browser automation from terminal |
| `screenshot` | Desktop screenshots |
| `skill-creator` | Create new skills |

#### Security (1)
| Skill | Description |
|-------|-------------|
| `security-best-practices` | Security review and recommendations |

### Agents (32)

Specialized subagents for research tasks:

| Category | Agents |
|----------|--------|
| **Writing** | abstract-and-title-crafter, introduction-writer, methods-writer, results-writer, paper-drafter, response-to-reviewers, grant-writer |
| **Analysis** | statistical-analyst, causal-inference, panel-data-econometrician, time-series-analyst, ml-engineer, feature-engineer, hyperparameter-tuner, model-diagnostics |
| **Data** | data-wrangling, survey-methodologist, text-analysis-specialist, qualitative-analyst |
| **Research** | literature-scout, literature-synthesizer, domain-specific-expert, research-planner, study-design, experimental-design |
| **Review** | code-reviewer, data-science-code-reviewer, consistency-checker, results-interpreter |
| **Output** | presentation-builder, visualization-designer, reproducibility-engineer |

### Commands (6)

| Command | Description |
|---------|-------------|
| `/analyze-function` | Line-by-line function analysis |
| `/page` | Session history dump with citations |
| `/search-prompts` | Search conversation history |
| `/plannotator-review` | Interactive code review |
| `/lit-search [query]` | Search academic papers across databases |
| `/zotero-review [collection]` | Analyze a Zotero collection |

### Hook (1)

| Hook | Trigger | Purpose |
|------|---------|---------|
| `check-docs-update.sh` | Stop | Verify documentation is updated |

---

## Repo Structure

```
claude-academic-setup/
├── README.md
├── install.sh
├── .gitignore
├── settings.json
├── CLAUDE.md
├── skills/               # 43 skill directories
│   ├── datacheck/
│   ├── lit-review/       # NEW
│   ├── citation-verification/  # NEW
│   ├── grant-writing/    # NEW
│   ├── research-ideation/  # NEW
│   ├── irb-protocol/     # NEW
│   └── ... (38 more)
├── agents/               # 32 agent files
├── commands/             # 6 command files
└── hooks/                # 1 hook script
```

---

## Cursor Extensions

### Core (15 — verified on Open VSX)
anthropic.claude-code, google.gemini-cli-vscode-ide-companion, openai.chatgpt, shd101wyy.markdown-preview-enhanced, bierner.markdown-mermaid, hediet.vscode-drawio, mechatroner.rainbow-csv, grapecity.gc-excelviewer, redhat.vscode-yaml, eamodio.gitlens, streetsidesoftware.code-spell-checker, usernamehw.errorlens, oderwat.indent-rainbow, alefragnani.project-manager, pkief.material-icon-theme

### Academic (4 — Open VSX, verify at install)
james-yu.latex-workshop, ltex-plus.vscode-ltex-plus, quarto.quarto, REditorSupport.r

### Optional (3 — may need manual VSIX)
ms-python.python, ms-toolsai.jupyter, DeepEcon.stata-mcp

---

## Verification

After install, check counts:

```bash
# Expected output
ls -d ~/.claude/skills/*/  | wc -l   # 43+
ls ~/.claude/agents/*.md   | wc -l   # 32+
ls ~/.claude/commands/*.md | wc -l   # 6+
python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d['enabledPlugins']))"  # 16
```
