#!/usr/bin/env bash

BACKUP_STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="$HOME/.claude-academic-setup-backups/$BACKUP_STAMP"
PLUGIN_FAILURES=0
SUMMARY=()

record() {
  SUMMARY+=("$1")
}

select_target() {
  local requested="${1:-}"
  if [ -z "$requested" ]; then
    if [ ! -t 0 ]; then
      printf 'Pass one target: claude, codex, or both.\n' >&2
      return 1
    fi
    printf 'Configure which agent? [claude/codex/both]: ' >&2
    read -r requested
  fi

  case "$requested" in
    claude|codex|both)
      printf '%s\n' "$requested"
      ;;
    *)
      printf 'Unknown target: %s. Use claude, codex, or both.\n' "$requested" >&2
      return 1
      ;;
  esac
}

target_includes() {
  local agent="$1"
  local target="$2"
  [ "$target" = "$agent" ] || [ "$target" = "both" ]
}

require_prerequisites() {
  local target="$1"
  local missing=0

  if ! command -v python3 >/dev/null 2>&1; then
    printf 'Missing python3. Install Python 3, then rerun this setup.\n' >&2
    missing=1
  fi
  if target_includes claude "$target" && ! command -v claude >/dev/null 2>&1; then
    printf 'Missing claude. Install it from https://code.claude.com/docs/en/setup and rerun.\n' >&2
    missing=1
  fi
  if target_includes codex "$target" && ! command -v codex >/dev/null 2>&1; then
    printf 'Missing codex. Install it from https://developers.openai.com/codex/cli/ and rerun.\n' >&2
    missing=1
  fi

  [ "$missing" -eq 0 ]
}

backup_item() {
  local source_path="$1"
  local relative_path="${source_path#$HOME/}"
  local backup_path="$BACKUP_ROOT/$relative_path"

  mkdir -p "$(dirname "$backup_path")"
  cp -R "$source_path" "$backup_path"
  printf '%s\n' "$backup_path"
}

prompt_file_action() {
  local destination="$1"
  local mode="$2"
  local answer=""

  while true; do
    printf '\nExisting file differs: %s\n' "$destination" >&2
    printf '[k]eep, [m]erge missing content, or [r]eplace after backup? [k]: ' >&2
    read -r answer || answer="k"
    answer="${answer:-k}"
    case "$answer" in
      k|m|r)
        printf '%s\n' "$answer"
        return 0
        ;;
      *)
        printf 'Choose k, m, or r.\n' >&2
        ;;
    esac
  done
}

install_config_file() {
  local source_path="$1"
  local destination="$2"
  local mode="$3"
  local action=""
  local backup_path=""
  local merged_path=""

  mkdir -p "$(dirname "$destination")"
  if [ ! -e "$destination" ]; then
    cp "$source_path" "$destination"
    record "installed $destination"
    return
  fi
  if cmp -s "$source_path" "$destination"; then
    record "unchanged $destination"
    return
  fi

  action="$(prompt_file_action "$destination" "$mode")"
  case "$action" in
    k)
      record "kept $destination"
      ;;
    m)
      merged_path="$(mktemp)"
      if python3 "$SCRIPT_DIR/scripts/merge-config.py" \
        "$mode" "$source_path" "$destination" "$merged_path"; then
        if cmp -s "$merged_path" "$destination"; then
          record "kept $destination (no missing content)"
        else
          backup_path="$(backup_item "$destination")"
          cp "$merged_path" "$destination"
          record "merged $destination (backup: $backup_path)"
        fi
      else
        record "FAILED to merge $destination; original kept"
      fi
      rm -f "$merged_path"
      ;;
    r)
      backup_path="$(backup_item "$destination")"
      cp "$source_path" "$destination"
      record "replaced $destination (backup: $backup_path)"
      ;;
  esac
}

prompt_skill_action() {
  local destination="$1"
  local answer=""

  while true; do
    printf '\nExisting skill differs: %s\n' "$destination" >&2
    printf '[k]eep or [r]eplace after backup? [k]: ' >&2
    read -r answer || answer="k"
    answer="${answer:-k}"
    case "$answer" in
      k|r)
        printf '%s\n' "$answer"
        return 0
        ;;
      *)
        printf 'Choose k or r.\n' >&2
        ;;
    esac
  done
}

install_skill() {
  local source_path="$1"
  local destination="$2"
  local action=""
  local backup_path=""

  mkdir -p "$(dirname "$destination")"
  if [ ! -e "$destination" ]; then
    cp -R "$source_path" "$destination"
    record "installed skill $destination"
    return
  fi
  if diff -qr "$source_path" "$destination" >/dev/null 2>&1; then
    record "unchanged skill $destination"
    return
  fi

  action="$(prompt_skill_action "$destination")"
  if [ "$action" = "k" ]; then
    record "kept skill $destination"
    return
  fi

  backup_path="$(backup_item "$destination")"
  rm -rf "$destination"
  cp -R "$source_path" "$destination"
  record "replaced skill $destination (backup: $backup_path)"
}

add_marketplace() {
  local source_name="$1"
  local display_name="$2"
  if claude plugin marketplace add "$source_name" >/dev/null 2>&1; then
    record "added marketplace $display_name"
  else
    record "marketplace available or unchanged: $display_name"
  fi
}

plugin_state() {
  local plugin_id="$1"
  claude plugin list --json 2>/dev/null | python3 -c '
import json, sys
plugin_id = sys.argv[1]
try:
    data = json.load(sys.stdin)
except Exception:
    print("unknown")
    raise SystemExit
items = data.get("installed", []) if isinstance(data, dict) else data
for item in items:
    if item.get("id") == plugin_id:
        print("enabled" if item.get("enabled") else "disabled")
        break
else:
    print("missing")
' "$plugin_id"
}

install_plugin() {
  local plugin_id="$1"
  local state=""
  local command_text=""

  state="$(plugin_state "$plugin_id")"
  if [ "$state" = "enabled" ]; then
    record "unchanged plugin $plugin_id"
    return
  fi
  if [ "$state" = "disabled" ]; then
    command_text="claude plugin enable $plugin_id --scope user"
    if claude plugin enable "$plugin_id" --scope user >/dev/null 2>&1; then
      record "enabled plugin $plugin_id"
      return
    fi
  else
    command_text="claude plugin install $plugin_id --scope user"
    if claude plugin install "$plugin_id" --scope user >/dev/null 2>&1; then
      record "installed plugin $plugin_id"
      return
    fi
  fi

  record "FAILED plugin $plugin_id; retry: $command_text"
  PLUGIN_FAILURES=$((PLUGIN_FAILURES + 1))
}

check_tool() {
  local tool_name="$1"
  local purpose="$2"
  local install_hint="$3"
  if command -v "$tool_name" >/dev/null 2>&1; then
    record "found $tool_name"
  else
    record "WARNING missing $tool_name ($purpose); install: $install_hint"
  fi
}

print_summary() {
  printf '\nSummary\n'
  local item=""
  for item in "${SUMMARY[@]}"; do
    printf '  - %s\n' "$item"
  done
}
