# Cursor Extensions

This setup installs 22 Cursor/VS Code extensions for academic research workflows.

- **Core extensions (14)** are installed by `install.sh`
- **Optional extensions (8)** are installed by `install-optional.sh`

All extensions reviewed as of 2026-03-02 with no known security concerns.

## Core Extensions (14)

Installed automatically by `install.sh`. These cover AI integration, academic writing, data work, and language support.

| Extension | Publisher | What It Does | For Researchers | Security |
|---|---|---|---|---|
| `anthropic.claude-code` | Anthropic (official) | Claude AI integration in IDE | Essential | Official publisher, trusted |
| `shd101wyy.markdown-preview-enhanced` | Individual (Yiyi Wang), widely adopted | Advanced markdown preview with LaTeX, Mermaid, pandoc | Recommended | Open source, large user base |
| `bierner.markdown-mermaid` | Individual (Matt Bierner, MS contributor) | Mermaid diagram support in markdown | Recommended | Open source, MS-affiliated maintainer |
| `mechatroner.rainbow-csv` | Individual (mechatroner), 19M+ downloads | Rainbow CSV highlighting + SQL queries | Essential for data work | Open source, very widely used |
| `grapecity.gc-excelviewer` | GrapeCity (commercial company) | Read-only Excel/CSV viewer | Recommended for data work | Commercial publisher, established |
| `redhat.vscode-yaml` | Red Hat (official) | YAML validation and completion | Recommended for config files | Official Red Hat publisher |
| `streetsidesoftware.code-spell-checker` | Street Side Software, 11M+ installs | Spell checking in code/docs | Recommended for academic writing | Open source, very widely used |
| `pkief.material-icon-theme` | Individual (Philipp Kief) | File icon theme | Optional (cosmetic) | Open source, cosmetic only |
| `james-yu.latex-workshop` | Individual (James Yu), most popular LaTeX ext | LaTeX build, preview, SyncTeX | Essential for LaTeX users | Open source, dominant LaTeX extension |
| `ltex-plus.vscode-ltex-plus` | Open source community | Grammar/spell check for LaTeX/Markdown (offline) | Essential for academic writing | Open source, offline processing |
| `quarto.quarto` | Quarto project (official) | Quarto document support | Essential for Quarto users | Official Quarto publisher |
| `REditorSupport.r` | R community (open source) | R language support, IntelliSense, terminal | Essential for R users | Open source, official R community |
| `ms-python.python` | Microsoft (official) | Python IntelliSense, debugging, linting | Essential for Python users | Official Microsoft publisher |
| `ms-toolsai.jupyter` | Microsoft (official) | Jupyter notebook support | Recommended for interactive analysis | Official Microsoft publisher |

## Optional Extensions (8)

Installed by `install-optional.sh`. These add supplementary capabilities for AI, diagrams, git, and editor ergonomics.

| Extension | Publisher | What It Does | For Researchers | Security |
|---|---|---|---|---|
| `google.gemini-cli-vscode-ide-companion` | Google (official) | Gemini CLI companion for IDE | Optional AI assistant | Official Google publisher |
| `openai.chatgpt` | OpenAI (official) | Codex/ChatGPT integration | Optional AI assistant | Official OpenAI publisher |
| `hediet.vscode-drawio` | Individual (Henning Dieterichs), open source | Draw.io diagram editor | Recommended for diagrams | Open source, widely used |
| `eamodio.gitlens` | Individual (Eric Amodio/GitKraken), 40M+ downloads | Git blame, history, authorship | Recommended for collaboration | Open source, very widely used |
| `usernamehw.errorlens` | Individual, open source | Inline error/warning display | Optional for debugging | Open source, lightweight |
| `oderwat.indent-rainbow` | Individual, open source | Color-coded indentation | Optional (readability) | Open source, cosmetic only |
| `alefragnani.project-manager` | Individual (Alessandro Fragnani) | Multi-project management | Optional for multi-project work | Open source, established |
| `DeepEcon.stata-mcp` | DeepEcon.ai (individual/small team), MIT licensed | Stata MCP integration | Essential for Stata users | MIT licensed, open source |
