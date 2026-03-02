#!/bin/bash
set -euo pipefail

echo "=== Claude Code Academic Setup — Optional Add-ons ==="
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

# ---------- Pre-check: core must be installed ----------
if [ ! -f ~/.claude/settings.json ]; then
  fail "Core not installed. Run 'bash install.sh' first."
  exit 1
fi

SKILL_COUNT=$(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_COUNT" -lt 10 ]; then
  fail "Core skills not found ($SKILL_COUNT < 10). Run 'bash install.sh' first."
  exit 1
fi

ok "Core install detected ($SKILL_COUNT skills found)"
echo ""

# Core skills to skip (already installed)
CORE_SKILLS=(
  napkin catch-up codex gemini discuss-claims skill-creator
  screenshot playwright pdf doc lit-review brainstorming datacheck
)

is_core() {
  local name="$1"
  for core in "${CORE_SKILLS[@]}"; do
    [ "$core" = "$name" ] && return 0
  done
  return 1
}

# ---------- 1. Optional Skills ----------
echo "1. Installing optional skills..."

OPTIONAL_COUNT=0
for skill_dir in "$SCRIPT_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")
  if is_core "$skill_name"; then
    continue
  fi
  mkdir -p ~/.claude/skills/"$skill_name"
  cp -r "$skill_dir"* ~/.claude/skills/"$skill_name"/
  ok "$skill_name"
  OPTIONAL_COUNT=$((OPTIONAL_COUNT + 1))
done
echo "   Installed $OPTIONAL_COUNT optional skills"
echo ""

# ---------- 2. Optional Cursor Extensions ----------
echo "2. Installing optional Cursor extensions..."

OPTIONAL_EXTENSIONS=(
  google.gemini-cli-vscode-ide-companion
  openai.chatgpt
  hediet.vscode-drawio
  eamodio.gitlens
  usernamehw.errorlens
  oderwat.indent-rainbow
  alefragnani.project-manager
  DeepEcon.stata-mcp
)

if command -v cursor > /dev/null 2>&1; then
  for ext in "${OPTIONAL_EXTENSIONS[@]}"; do
    cursor --install-extension "$ext" 2>/dev/null && ok "$ext" || warn "Failed: $ext"
  done
else
  warn "Skipping extensions — cursor not in PATH"
fi
echo ""

# ---------- 3. Verification ----------
echo "=== Verification ==="
echo ""

TOTAL_SKILLS=$(ls -d ~/.claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')
echo "1. Total skills: $TOTAL_SKILLS (expected: >= 43)"
echo "2. Commands: $(ls ~/.claude/commands/*.md 2>/dev/null | wc -l | tr -d ' ') (expected: >= 7)"

echo ""
echo "=== Optional add-ons installed ==="
echo ""
echo "See docs/optional-skills.md for descriptions of each optional skill."
