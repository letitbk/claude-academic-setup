#!/bin/bash
set -euo pipefail

echo "=== Claude Code + Cursor Academic Researcher Setup (Core) ==="
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

# Node.js
if command -v node > /dev/null 2>&1; then
  NODE_VER=$(node -v | sed 's/v//')
  ok "node $NODE_VER found"
else
  fail "node not found"
  echo "     Install Node.js 18+:"
  echo "       macOS:   brew install node"
  echo "       or:      https://nodejs.org/"
  echo "       Linux:   https://github.com/nodesource/distributions"
  MISSING=1
fi

# Python 3
if command -v python3 > /dev/null 2>&1; then
  PY_VER=$(python3 --version | awk '{print $2}')
  ok "python3 $PY_VER found"
else
  fail "python3 not found"
  echo "     Install Python 3.10+:"
  echo "       macOS:   brew install python"
  echo "       or:      https://www.python.org/downloads/"
  MISSING=1
fi

# jq
if command -v jq > /dev/null 2>&1; then
  ok "jq found"
else
  fail "jq not found"
  echo "     Install jq:"
  echo "       macOS:   brew install jq"
  echo "       Linux:   sudo apt install jq  (or yum/dnf)"
  MISSING=1
fi

# Claude Code CLI
if command -v claude > /dev/null 2>&1; then
  ok "claude found"
else
  fail "claude not found"
  echo "     Install Claude Code CLI:"
  echo "       npm install -g @anthropic-ai/claude-code"
  echo "       Docs: https://docs.anthropic.com/en/docs/claude-code"
  MISSING=1
fi

# Homebrew check (macOS only — informational)
if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew > /dev/null 2>&1; then
  warn "Homebrew not found — many tools above can be installed via brew"
  echo "     Install Homebrew: https://brew.sh/"
fi

if [ "$MISSING" -eq 1 ]; then
  echo ""
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
  warn "R not found — R package installation will be skipped (install from https://cran.r-project.org/)"
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

# ---------- 2. Cursor Extensions (Core Only) ----------
echo "2. Installing core Cursor extensions..."

CORE_EXTENSIONS=(
  anthropic.claude-code
  shd101wyy.markdown-preview-enhanced
  bierner.markdown-mermaid
  mechatroner.rainbow-csv
  grapecity.gc-excelviewer
  redhat.vscode-yaml
  streetsidesoftware.code-spell-checker
  pkief.material-icon-theme
  james-yu.latex-workshop
  ltex-plus.vscode-ltex-plus
  quarto.quarto
  REditorSupport.r
  ms-python.python
  ms-toolsai.jupyter
)

if [ "$HAS_CURSOR" -eq 1 ]; then
  for ext in "${CORE_EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" || warn "Failed: $ext"
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
for check_dir in ~/.claude/skills ~/.claude/commands ~/.claude/hooks; do
  [ -d "$check_dir" ] && NEED_BACKUP=1
done
[ -f ~/.claude/CLAUDE.md ] && NEED_BACKUP=1

if [ "$NEED_BACKUP" -eq 1 ]; then
  mkdir -p "$BACKUP_DIR"
  [ -d ~/.claude/skills ] && cp -r ~/.claude/skills "$BACKUP_DIR/"
  [ -d ~/.claude/commands ] && cp -r ~/.claude/commands "$BACKUP_DIR/"
  [ -d ~/.claude/hooks ] && cp -r ~/.claude/hooks "$BACKUP_DIR/"
  [ -f ~/.claude/CLAUDE.md ] && cp ~/.claude/CLAUDE.md "$BACKUP_DIR/"
  ok "Backed up existing files to $BACKUP_DIR"
fi
echo ""

# ---------- 4. Settings ----------
echo "4. Copying settings.json (permissive defaults)..."

cp "$SCRIPT_DIR/settings.json" ~/.claude/settings.json
ok "settings.json installed (13 plugins, bypassPermissions mode — dangerous ops still blocked)"
echo ""

# ---------- 5. Core Skills ----------
echo "5. Copying core skills (12)..."

CORE_SKILLS=(
  napkin
  catch-up
  codex
  gemini
  discuss-claims
  skill-creator
  screenshot
  playwright
  pdf
  doc
  brainstorming
  datacheck
)

mkdir -p ~/.claude/skills
for skill_name in "${CORE_SKILLS[@]}"; do
  skill_dir="$SCRIPT_DIR/skills/$skill_name"
  if [ -d "$skill_dir" ]; then
    mkdir -p ~/.claude/skills/"$skill_name"
    cp -r "$skill_dir"/* ~/.claude/skills/"$skill_name"/
    ok "$skill_name"
  else
    warn "$skill_name not found in repo — skipping"
  fi
done
echo ""

# ---------- 6. Commands ----------
echo "6. Copying commands (7)..."

mkdir -p ~/.claude/commands
for cmd_file in "$SCRIPT_DIR"/commands/*.md; do
  cp "$cmd_file" ~/.claude/commands/
  ok "$(basename "$cmd_file")"
done
echo ""

# ---------- 7. Hooks ----------
echo "7. Copying hooks..."

mkdir -p ~/.claude/hooks
cp "$SCRIPT_DIR/hooks/check-docs-update.sh" ~/.claude/hooks/
chmod +x ~/.claude/hooks/check-docs-update.sh
ok "check-docs-update.sh (executable)"
echo ""

# ---------- 8. CLAUDE.md ----------
echo "8. Copying CLAUDE.md..."

cp "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
ok "CLAUDE.md installed"
echo ""

# ---------- 9. Multi-AI & packages ----------
echo "9. Installing multi-AI tools and packages..."

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

# ---------- 10. MCP Servers ----------
echo "10. MCP server setup..."

echo "   paper-search-mcp can be added to your MCP config."
echo "   Add to ~/.claude/settings.json mcpServers or use:"
echo "   npx -y paper-search-mcp"
echo ""
echo "   Zotero MCP: Ensure Zotero desktop app is running and API key is set."
echo "   See: https://github.com/54yyyu/zotero-mcp for setup instructions."
ok "MCP server instructions printed"
echo ""

# ---------- 11. Plugin Installation ----------
echo "11. Installing Claude Code plugins (13)..."
echo ""

# Add custom marketplaces for non-official plugins
echo "   Adding plugin marketplaces..."
claude plugin marketplace add obra/superpowers-marketplace 2>/dev/null \
  && ok "Marketplace: superpowers-marketplace (obra)" \
  || warn "Marketplace superpowers-marketplace may already exist"

claude plugin marketplace add backnotprop/plannotator 2>/dev/null \
  && ok "Marketplace: plannotator (backnotprop)" \
  || warn "Marketplace plannotator may already exist"

claude plugin marketplace add 777genius/claude-notifications-go 2>/dev/null \
  && ok "Marketplace: claude-notifications-go (777genius)" \
  || warn "Marketplace claude-notifications-go may already exist"

echo ""
echo "   Installing plugins..."

# Plugins from custom marketplaces
CUSTOM_PLUGINS=(
  "superpowers@superpowers-marketplace"
  "plannotator@plannotator"
  "claude-notifications-go@claude-notifications-go"
)

# Plugins from official marketplace
OFFICIAL_PLUGINS=(
  "ralph-loop@claude-plugins-official"
  "playwright@claude-plugins-official"
  "code-review@claude-plugins-official"
  "github@claude-plugins-official"
  "context7@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "commit-commands@claude-plugins-official"
  "plugin-dev@claude-plugins-official"
  "pyright-lsp@claude-plugins-official"
)

for plugin in "${CUSTOM_PLUGINS[@]}" "${OFFICIAL_PLUGINS[@]}"; do
  plugin_name="${plugin%%@*}"
  claude plugin install "$plugin" 2>/dev/null \
    && ok "$plugin_name" \
    || warn "Failed: $plugin_name — try manually: claude plugin install $plugin"
done

echo ""

# ---------- 12. Verification ----------
echo "=== Verification ==="
echo ""

if [ "$HAS_CURSOR" -eq 1 ]; then
  EXT_COUNT=$(cursor --list-extensions 2>/dev/null | wc -l | tr -d ' ')
  echo "1. Cursor extensions: $EXT_COUNT (expected: >= 14 core)"
else
  echo "1. Cursor extensions: SKIPPED (cursor not in PATH)"
fi

if python3 -c "import json; json.load(open('$HOME/.claude/settings.json'))" 2>/dev/null; then
  PLUGIN_COUNT=$(python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print(len(d.get('enabledPlugins', {})))")
  echo "2. Settings.json: valid, $PLUGIN_COUNT plugins (expected: 13)"
else
  echo "2. Settings.json: INVALID or missing"
fi

echo "3. Skills: $(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ') (expected: >= 12 core)"
echo "4. Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ') (expected: >= 7)"

test -x ~/.claude/hooks/check-docs-update.sh \
  && echo "5. Hook: executable" \
  || echo "5. Hook: MISSING"

test -f ~/.claude/CLAUDE.md \
  && echo "6. CLAUDE.md: present" \
  || echo "6. CLAUDE.md: MISSING"

command -v gemini > /dev/null 2>&1 \
  && echo "7. Gemini CLI: installed" \
  || echo "7. Gemini CLI: NOT INSTALLED"

command -v codex > /dev/null 2>&1 \
  && echo "8. Codex CLI: installed" \
  || echo "8. Codex CLI: NOT INSTALLED"

python3 -c "import plotnine; import plotly; import statsmodels" 2>/dev/null \
  && echo "9. Python packages: OK" \
  || echo "9. Python packages: SOME MISSING"

if [ "$HAS_R" -eq 1 ]; then
  R_STATUS=$(Rscript -e "cat(ifelse(all(c('survey','tidyverse','marginaleffects') %in% installed.packages()[,'Package']), 'OK', 'SOME MISSING'))" 2>/dev/null || echo "CHECK FAILED")
  echo "10. R packages: $R_STATUS"
else
  echo "10. R packages: SKIPPED (R not found)"
fi

echo ""
echo "=== Core setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Authenticate Gemini: run 'gemini' and sign in"
echo "  2. Authenticate Codex: run 'codex' and sign in"
echo "  3. Set up Zotero MCP (see step 10 above)"
echo "  4. For optional skills (30 more) and extensions: bash install-optional.sh"
