#!/bin/bash
set -euo pipefail

echo "=== Claude Code + Cursor Academic Researcher Setup ==="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- 1. Prerequisites ----------
echo "1. Checking prerequisites..."

MISSING=0
for cmd in claude node python3 jq; do
  if command -v "$cmd" > /dev/null 2>&1; then
    ok "$cmd found"
  else
    fail "$cmd not found"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  fail "Missing required tools. Install them and re-run."
  exit 1
fi

# Optional tools (guarded with flags)
HAS_CURSOR=0
if command -v cursor > /dev/null 2>&1; then
  ok "cursor found"
  HAS_CURSOR=1
else
  warn "cursor not in PATH — open Cursor and run: Shell Command: Install 'cursor' command in PATH"
fi

HAS_R=0
if command -v Rscript > /dev/null 2>&1; then
  ok "R found"
  HAS_R=1
else
  warn "R not found — R package installation will be skipped"
fi

HAS_STATA=0
if command -v stata > /dev/null 2>&1 || command -v stata-mp > /dev/null 2>&1; then
  ok "Stata found"
  HAS_STATA=1
else
  warn "Stata not found — Stata-specific features will still work if Stata is available at runtime"
fi

HAS_QUARTO=0
if command -v quarto > /dev/null 2>&1; then
  ok "quarto found"
  HAS_QUARTO=1
else
  warn "quarto not found — install from https://quarto.org/docs/get-started/"
fi

HAS_PANDOC=0
if command -v pandoc > /dev/null 2>&1; then
  ok "pandoc found"
  HAS_PANDOC=1
else
  warn "pandoc not found — install via: brew install pandoc"
fi

HAS_LATEXMK=0
if command -v latexmk > /dev/null 2>&1; then
  ok "latexmk found"
  HAS_LATEXMK=1
else
  warn "latexmk not found — needed for LaTeX compilation: brew install --cask mactex-no-gui"
fi

echo ""

# ---------- 2. Cursor Extensions ----------
echo "2. Installing Cursor extensions..."

# Core extensions verified on Open VSX
EXTENSIONS=(
  anthropic.claude-code
  google.gemini-cli-vscode-ide-companion
  openai.chatgpt
  shd101wyy.markdown-preview-enhanced
  bierner.markdown-mermaid
  hediet.vscode-drawio
  mechatroner.rainbow-csv
  grapecity.gc-excelviewer
  redhat.vscode-yaml
  eamodio.gitlens
  streetsidesoftware.code-spell-checker
  usernamehw.errorlens
  oderwat.indent-rainbow
  alefragnani.project-manager
  pkief.material-icon-theme
)

# Academic extensions (Open VSX — verify at install time)
ACADEMIC_EXTENSIONS=(
  james-yu.latex-workshop
  ltex-plus.vscode-ltex-plus
  quarto.quarto
  REditorSupport.r
)

# Optional extensions (may need manual VSIX install)
OPTIONAL_EXTENSIONS=(
  ms-python.python
  ms-toolsai.jupyter
  DeepEcon.stata-mcp
)

if [ "$HAS_CURSOR" -eq 1 ]; then
  echo "   Core extensions..."
  for ext in "${EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" || warn "Failed: $ext"
  done
  echo ""
  echo "   Academic extensions..."
  for ext in "${ACADEMIC_EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" || warn "Failed: $ext — may need manual install"
  done
  echo ""
  echo "   Optional extensions (may need manual VSIX install)..."
  for ext in "${OPTIONAL_EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" || warn "Failed: $ext — install manually from VSIX"
  done
else
  warn "Skipping extensions — cursor not in PATH"
fi
echo ""

# ---------- 3. Backup existing Claude Code files ----------
echo "3. Backing up existing files..."

mkdir -p ~/.claude

if [ -f ~/.claude/settings.json ]; then
  BACKUP=~/.claude/settings.json.backup.$(date +%Y%m%d%H%M%S)
  cp ~/.claude/settings.json "$BACKUP"
  ok "Backed up settings.json to $BACKUP"
fi

BACKUP_DIR=~/.claude/backup.$(date +%Y%m%d%H%M%S)
NEED_BACKUP=0
for check_dir in ~/.claude/skills ~/.claude/agents ~/.claude/commands ~/.claude/hooks; do
  [ -d "$check_dir" ] && NEED_BACKUP=1
done
[ -f ~/.claude/CLAUDE.md ] && NEED_BACKUP=1

if [ "$NEED_BACKUP" -eq 1 ]; then
  mkdir -p "$BACKUP_DIR"
  [ -d ~/.claude/skills ] && cp -r ~/.claude/skills "$BACKUP_DIR/"
  [ -d ~/.claude/agents ] && cp -r ~/.claude/agents "$BACKUP_DIR/"
  [ -d ~/.claude/commands ] && cp -r ~/.claude/commands "$BACKUP_DIR/"
  [ -d ~/.claude/hooks ] && cp -r ~/.claude/hooks "$BACKUP_DIR/"
  [ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md "$BACKUP_DIR/"
  ok "Backed up existing files to $BACKUP_DIR"
fi
echo ""

# ---------- 4. Settings ----------
echo "4. Copying settings.json..."

cp "$SCRIPT_DIR/settings.json" ~/.claude/settings.json
ok "settings.json installed"
echo ""

# ---------- 5. Skills ----------
echo "5. Copying skills (43)..."

mkdir -p ~/.claude/skills
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  mkdir -p ~/.claude/skills/"$skill_name"
  cp -r "$skill_dir"* ~/.claude/skills/"$skill_name"/
  ok "$skill_name"
done
echo ""

# ---------- 6. Agents ----------
echo "6. Copying agents (32)..."

mkdir -p ~/.claude/agents
for agent in "$SCRIPT_DIR"/agents/*.md; do
  cp "$agent" ~/.claude/agents/
  ok "$(basename "$agent")"
done
echo ""

# ---------- 7. Commands ----------
echo "7. Copying commands (6)..."

mkdir -p ~/.claude/commands
for cmd_file in "$SCRIPT_DIR"/commands/*.md; do
  cp "$cmd_file" ~/.claude/commands/
  ok "$(basename "$cmd_file")"
done
echo ""

# ---------- 8. Hooks ----------
echo "8. Copying hooks..."

mkdir -p ~/.claude/hooks
cp "$SCRIPT_DIR/hooks/check-docs-update.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/check-docs-update.sh
ok "check-docs-update.sh (executable)"
echo ""

# ---------- 9. CLAUDE.md ----------
echo "9. Copying CLAUDE.md..."

cp "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
ok "CLAUDE.md installed"
echo ""

# ---------- 10. Multi-AI & packages ----------
echo "10. Installing multi-AI tools and packages..."

# Gemini CLI
if command -v gemini > /dev/null 2>&1; then
  ok "Gemini CLI already installed"
else
  echo "   Installing Gemini CLI..."
  npm install -g @google/gemini-cli 2>/dev/null && ok "Gemini CLI installed" || warn "Gemini CLI install failed — run: npm install -g @google/gemini-cli"
fi

# Codex CLI
if command -v codex > /dev/null 2>&1; then
  ok "Codex CLI already installed"
else
  echo "   Installing Codex CLI..."
  npm install -g @openai/codex 2>/dev/null && ok "Codex CLI installed" || warn "Codex CLI install failed — run: npm install -g @openai/codex"
fi

# Python packages
echo "   Installing Python packages..."
pip3 install --quiet pandas plotnine plotly kaleido matplotlib scipy statsmodels openpyxl beautifulsoup4 advertools Pillow pyyaml 2>/dev/null \
  && ok "Python packages installed" \
  || warn "Some Python packages failed — run: pip3 install pandas plotnine plotly kaleido matplotlib scipy statsmodels openpyxl beautifulsoup4 advertools Pillow pyyaml"

# Playwright
echo "   Installing Playwright..."
pip3 install --quiet playwright 2>/dev/null && python3 -m playwright install chromium 2>/dev/null \
  && ok "Playwright + Chromium installed" \
  || warn "Playwright install failed — run: pip3 install playwright && python3 -m playwright install chromium"

# R packages (if R is available)
if [ "$HAS_R" -eq 1 ]; then
  echo "   Installing R packages..."
  Rscript -e "pkgs <- c('survey', 'tidyverse', 'marginaleffects', 'ggplot2', 'modelsummary', 'fixest', 'haven'); new <- pkgs[!pkgs %in% installed.packages()[,'Package']]; if(length(new)) install.packages(new, repos='https://cloud.r-project.org', quiet=TRUE)" 2>/dev/null \
    && ok "R packages installed" \
    || warn "Some R packages failed — install manually in R"
else
  warn "Skipping R packages — R not found"
fi

echo ""

# ---------- 11. MCP Servers ----------
echo "11. MCP server setup..."

echo "   paper-search-mcp can be added to your MCP config."
echo "   Add to ~/.claude/settings.json mcpServers or use:"
echo "   npx -y paper-search-mcp"
echo ""
echo "   Zotero MCP: Ensure Zotero desktop app is running and API key is set."
echo "   See: https://github.com/kujenga/zotero-mcp for setup instructions."
ok "MCP server instructions printed"
echo ""

# ---------- 12. Plugins reminder ----------
echo "12. Plugin installation (manual step)"
echo ""
echo "   Open Claude Code CLI and run these commands:"
echo ""
echo "   /install code-simplifier@claude-plugins-official"
echo "   /install claude-notifications-go@claude-notifications-go"
echo "   /install superpowers@obra"
echo "   /install clangd-lsp@claude-plugins-official"
echo "   /install plannotator@plannotator"
echo "   /install context7@claude-plugins-official"
echo "   /install code-review@claude-plugins-official"
echo "   /install github@claude-plugins-official"
echo "   /install feature-dev@claude-plugins-official"
echo "   /install ralph-loop@claude-plugins-official"
echo "   /install playwright@claude-plugins-official"
echo "   /install commit-commands@claude-plugins-official"
echo "   /install pyright-lsp@claude-plugins-official"
echo "   /install figma@claude-plugins-official"
echo "   /install plugin-dev@claude-plugins-official"
echo "   /install frontend-design@claude-code-plugins"
echo ""

# ---------- 13. Verification ----------
echo "=== Verification ==="
echo ""

if [ "$HAS_CURSOR" -eq 1 ]; then
  EXT_COUNT=$(cursor --list-extensions 2>/dev/null | wc -l | tr -d ' ')
  echo "1. Cursor extensions: $EXT_COUNT (expected: >= 15 core + 4 academic)"
else
  echo "1. Cursor extensions: SKIPPED (cursor not in PATH)"
fi

if python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))" 2>/dev/null; then
  PLUGIN_COUNT=$(python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d.get('enabledPlugins', {})))")
  echo "2. Settings.json: valid, $PLUGIN_COUNT plugins (expected: 16)"
else
  echo "2. Settings.json: INVALID or missing"
fi

echo "3. Skills: $(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ') (expected: >= 43)"
echo "4. Agents: $(ls ~/.claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ') (expected: >= 32)"
echo "5. Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ') (expected: >= 6)"

test -x ~/.claude/hooks/check-docs-update.sh \
  && echo "6. Hook: executable" \
  || echo "6. Hook: MISSING"

test -f ~/.claude/CLAUDE.md \
  && echo "7. CLAUDE.md: present" \
  || echo "7. CLAUDE.md: MISSING"

command -v gemini > /dev/null 2>&1 \
  && echo "8. Gemini CLI: installed" \
  || echo "8. Gemini CLI: NOT INSTALLED"

command -v codex > /dev/null 2>&1 \
  && echo "9. Codex CLI: installed" \
  || echo "9. Codex CLI: NOT INSTALLED"

python3 -c "import plotnine; import plotly; import statsmodels" 2>/dev/null \
  && echo "10. Python packages: OK" \
  || echo "10. Python packages: SOME MISSING"

if [ "$HAS_R" -eq 1 ]; then
  R_STATUS=$(Rscript -e "cat(ifelse(all(c('survey','tidyverse','marginaleffects') %in% installed.packages()[,'Package']), 'OK', 'SOME MISSING'))" 2>/dev/null || echo "CHECK FAILED")
  echo "11. R packages: $R_STATUS"
else
  echo "11. R packages: SKIPPED (R not found)"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Install plugins (step 12 above) inside Claude Code CLI"
echo "  2. Authenticate Gemini: run 'gemini' and sign in"
echo "  3. Authenticate Codex: run 'codex' and sign in"
echo "  4. Set up Zotero MCP (see step 11 above)"
echo "  5. Try: /lit-search [topic], /zotero-review [collection], /page"
