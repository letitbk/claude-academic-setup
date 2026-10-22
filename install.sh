#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=scripts/install-common.sh
source "$SCRIPT_DIR/scripts/install-common.sh"

COMMON_SKILLS=(
  "napkin"
  "plain-writing"
  "datacheck"
  "viz"
)

CLAUDE_SKILLS=(
  "${COMMON_SKILLS[@]}"
  "codex"
)

CODEX_SKILLS=(
  "${COMMON_SKILLS[@]}"
)

CLAUDE_PLUGINS=(
  "superpowers@claude-plugins-official"
  "github@claude-plugins-official"
  "claude-hud@claude-hud"
  "planboard@planboard"
)

TARGET="$(select_target "${1:-}")" || exit 2
require_prerequisites "$TARGET" || exit 2

printf 'Claude Code and Codex beginner setup\n'
printf 'Target: %s\n\n' "$TARGET"

if target_includes claude "$TARGET"; then
  install_config_file \
    "$SCRIPT_DIR/CLAUDE.md" \
    "$HOME/.claude/CLAUDE.md" \
    instructions
  install_config_file \
    "$SCRIPT_DIR/settings.json" \
    "$HOME/.claude/settings.json" \
    settings

  for skill_name in "${CLAUDE_SKILLS[@]}"; do
    install_skill \
      "$SCRIPT_DIR/skills/$skill_name" \
      "$HOME/.claude/skills/$skill_name"
  done

  add_marketplace "jarrodwatts/claude-hud" "claude-hud"
  add_marketplace "letitbk/planboard" "planboard"

  for plugin_id in "${CLAUDE_PLUGINS[@]}"; do
    install_plugin "$plugin_id"
  done
fi

if target_includes codex "$TARGET"; then
  install_config_file \
    "$SCRIPT_DIR/AGENTS.md" \
    "$HOME/.codex/AGENTS.md" \
    instructions

  for skill_name in "${CODEX_SKILLS[@]}"; do
    install_skill \
      "$SCRIPT_DIR/skills/$skill_name" \
      "$HOME/.codex/skills/$skill_name"
  done
fi

print_summary

if [ "$PLUGIN_FAILURES" -gt 0 ]; then
  printf '\nSetup completed with %d plugin failure(s). Retry the printed commands.\n' "$PLUGIN_FAILURES"
  exit 1
fi

case "$TARGET" in
  claude)
    next_step="Start Claude Code in a small Git repository."
    ;;
  codex)
    next_step="Start Codex in a small Git repository."
    ;;
  both)
    next_step="Start either Claude Code or Codex in a small Git repository."
    ;;
esac
printf '\nSetup complete. %s\n' "$next_step"
