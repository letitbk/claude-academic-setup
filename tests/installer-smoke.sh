#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
MOCK_BIN="$TEST_ROOT/bin"
FAILURES=0

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; FAILURES=$((FAILURES + 1)); }

expect_file() {
  if [ -f "$1" ]; then pass "$2"; else fail "$2"; fi
}

expect_dir() {
  if [ -d "$1" ]; then pass "$2"; else fail "$2"; fi
}

expect_absent() {
  if [ ! -e "$1" ]; then pass "$2"; else fail "$2"; fi
}

expect_text() {
  if rg -q --fixed-strings "$2" "$1"; then pass "$3"; else fail "$3"; fi
}

expect_log_line() {
  if rg -q --fixed-strings --line-regexp "$2" "$1"; then pass "$3"; else fail "$3"; fi
}

expect_skill_count() {
  local directory="$1"
  local expected="$2"
  local label="$3"
  local actual="0"
  if [ -d "$directory" ]; then
    actual="$(find "$directory" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
  fi
  if [ "$actual" = "$expected" ]; then
    pass "$label"
  else
    fail "$label (expected $expected, found $actual)"
  fi
}

mkdir -p "$MOCK_BIN"

cat >"$MOCK_BIN/claude" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$MOCK_LOG"
if [ "${1:-}" = "plugin" ] && [ "${2:-}" = "list" ]; then
  printf '%s\n' "${MOCK_PLUGIN_JSON:-[]}"
  exit 0
fi
if [ -n "${MOCK_FAIL_MATCH:-}" ] && [[ "$*" == *"$MOCK_FAIL_MATCH"* ]]; then
  exit 1
fi
exit 0
MOCK

cat >"$MOCK_BIN/codex" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$MOCK_LOG"
exit 0
MOCK

chmod +x "$MOCK_BIN/claude" "$MOCK_BIN/codex"

run_script() {
  local home_dir="$1"
  local script_name="$2"
  local target="$3"
  local input="${4:-}"
  local output_file="$home_dir/output.log"
  mkdir -p "$home_dir"
  : >"$home_dir/mock.log"
  if [ -n "$input" ]; then
    printf '%b' "$input" | env \
      HOME="$home_dir" \
      MOCK_LOG="$home_dir/mock.log" \
      MOCK_PLUGIN_JSON="${MOCK_PLUGIN_JSON:-[]}" \
      MOCK_FAIL_MATCH="${MOCK_FAIL_MATCH:-}" \
      PATH="$MOCK_BIN:${TEST_PATH:-$PATH}" \
      bash "$ROOT/$script_name" "$target" >"$output_file" 2>&1
  else
    env \
      HOME="$home_dir" \
      MOCK_LOG="$home_dir/mock.log" \
      MOCK_PLUGIN_JSON="${MOCK_PLUGIN_JSON:-[]}" \
      MOCK_FAIL_MATCH="${MOCK_FAIL_MATCH:-}" \
      PATH="$MOCK_BIN:${TEST_PATH:-$PATH}" \
      bash "$ROOT/$script_name" "$target" >"$output_file" 2>&1
  fi
}

claude_home="$TEST_ROOT/claude-home"
if run_script "$claude_home" install.sh claude; then
  pass "Claude target exits successfully"
else
  fail "Claude target exits successfully"
fi
expect_file "$claude_home/.claude/CLAUDE.md" "Claude instructions installed"
expect_file "$claude_home/.claude/settings.json" "Claude settings installed"
expect_skill_count "$claude_home/.claude/skills" 6 "Claude core skill manifest"
expect_dir "$claude_home/.claude/skills/codex" "Claude target installs /codex"
expect_absent "$claude_home/.claude/skills/claude" "Claude target skips the Codex-only reviewer"
expect_absent "$claude_home/.codex" "Claude target leaves Codex untouched"
expect_log_line "$claude_home/mock.log" "plugin marketplace add backnotprop/plannotator" "Plannotator marketplace command"
for plugin_id in \
  superpowers@claude-plugins-official \
  plannotator@plannotator; do
  expect_log_line "$claude_home/mock.log" "plugin install $plugin_id --scope user" "Plugin install command: $plugin_id"
done

if run_script "$claude_home" install.sh claude; then
  pass "Claude rerun exits successfully"
else
  fail "Claude rerun exits successfully"
fi
expect_text "$claude_home/output.log" "unchanged $claude_home/.claude/CLAUDE.md" "Claude rerun recognizes unchanged instructions"
expect_text "$claude_home/output.log" "unchanged skill $claude_home/.claude/skills/napkin" "Claude rerun recognizes unchanged skills"

codex_home="$TEST_ROOT/codex-home"
if run_script "$codex_home" install.sh codex; then
  pass "Codex target exits successfully"
else
  fail "Codex target exits successfully"
fi
expect_file "$codex_home/.codex/AGENTS.md" "Codex instructions installed"
expect_skill_count "$codex_home/.codex/skills" 6 "Codex core skill manifest"
expect_dir "$codex_home/.codex/skills/claude" "Codex target installs the Claude reviewer"
expect_absent "$codex_home/.codex/skills/codex" "Codex target skips /codex"
expect_absent "$codex_home/.claude" "Codex target leaves Claude untouched"

both_home="$TEST_ROOT/both-home"
if run_script "$both_home" install.sh both; then
  pass "Both target exits successfully"
else
  fail "Both target exits successfully"
fi
expect_skill_count "$both_home/.claude/skills" 6 "Both target installs Claude core skills"
expect_skill_count "$both_home/.codex/skills" 6 "Both target installs Codex core skills"

tools_home="$TEST_ROOT/tools-home"
system_bin="$TEST_ROOT/system-python-bin"
mkdir -p "$system_bin"
ln -s "$(python3 -c 'import sys; print(sys.executable)')" "$system_bin/python3"
if TEST_PATH="$system_bin:/usr/bin:/bin" run_script "$tools_home" install.sh claude; then
  pass "Missing optional tools do not fail setup"
else
  fail "Missing optional tools do not fail setup"
fi
expect_text "$tools_home/output.log" "WARNING missing agy" "Missing agy is reported"
expect_text "$tools_home/output.log" "WARNING missing plannotator" "Missing plannotator is reported"

settings_home="$TEST_ROOT/settings-home"
mkdir -p "$settings_home/.claude"
cat >"$settings_home/.claude/settings.json" <<'JSON'
{
  "permissions": {"defaultMode": "acceptEdits"},
  "personalSetting": true
}
JSON
if run_script "$settings_home" install.sh claude 'm\n'; then
  pass "Settings merge exits successfully"
else
  fail "Settings merge exits successfully"
fi
settings_result="$(python3 - "$settings_home/.claude/settings.json" <<'PY'
import json
import sys
data = json.load(open(sys.argv[1]))
print(data["permissions"]["defaultMode"], data["personalSetting"], data["sandbox"]["enabled"], bool(data["permissions"]["deny"]))
PY
)"
if [ "$settings_result" = "acceptEdits True True True" ]; then
  pass "Settings merge preserves values and adds missing keys"
else
  fail "Settings merge preserves values and adds missing keys"
fi
if find "$settings_home/.claude-academic-setup-backups" -type f -path '*/.claude/settings.json' | rg -q .; then
  pass "Settings merge creates backup"
else
  fail "Settings merge creates backup"
fi

instructions_home="$TEST_ROOT/instructions-home"
mkdir -p "$instructions_home/.claude"
cat >"$instructions_home/.claude/CLAUDE.md" <<'MARKDOWN'
# Personal instructions

## 1. Use Skills When Relevant

Keep my custom wording.
MARKDOWN
if run_script "$instructions_home" install.sh claude 'm\n'; then
  pass "Instruction merge exits successfully"
else
  fail "Instruction merge exits successfully"
fi
expect_text "$instructions_home/.claude/CLAUDE.md" "Keep my custom wording." "Instruction merge keeps existing section"
expect_text "$instructions_home/.claude/CLAUDE.md" "## 7. Write prose without hard wrapping" "Instruction merge adds missing sections"
heading_count="$(rg -c '^## 1\.' "$instructions_home/.claude/CLAUDE.md")"
if [ "$heading_count" = "1" ]; then pass "Instruction merge avoids duplicate headings"; else fail "Instruction merge avoids duplicate headings"; fi

skill_home="$TEST_ROOT/skill-home"
mkdir -p "$skill_home/.claude/skills/napkin"
printf 'old skill\n' >"$skill_home/.claude/skills/napkin/old.txt"
if run_script "$skill_home" install.sh claude 'r\n'; then
  pass "Skill replacement exits successfully"
else
  fail "Skill replacement exits successfully"
fi
expect_file "$skill_home/.claude/skills/napkin/SKILL.md" "Skill replacement installs new skill"
expect_absent "$skill_home/.claude/skills/napkin/old.txt" "Skill replacement removes old directory contents"
if find "$skill_home/.claude-academic-setup-backups" -type f -path '*/.claude/skills/napkin/old.txt' | rg -q .; then
  pass "Skill replacement creates backup"
else
  fail "Skill replacement creates backup"
fi

disabled_home="$TEST_ROOT/disabled-home"
MOCK_PLUGIN_JSON='[{"id":"superpowers@claude-plugins-official","enabled":false},{"id":"plannotator@plannotator","enabled":true}]'
if run_script "$disabled_home" install.sh claude; then
  pass "Disabled plugin target exits successfully"
else
  fail "Disabled plugin target exits successfully"
fi
expect_log_line "$disabled_home/mock.log" "plugin enable superpowers@claude-plugins-official --scope user" "Disabled plugin is enabled"
expect_text "$disabled_home/output.log" "unchanged plugin plannotator@plannotator" "Enabled plugin is left unchanged"
unset MOCK_PLUGIN_JSON

failure_home="$TEST_ROOT/failure-home"
MOCK_FAIL_MATCH='plugin install plannotator@plannotator'
if run_script "$failure_home" install.sh claude; then
  fail "Plugin failure returns nonzero"
else
  pass "Plugin failure returns nonzero"
fi
expect_text "$failure_home/output.log" "retry: claude plugin install plannotator@plannotator --scope user" "Plugin failure prints exact retry"
unset MOCK_FAIL_MATCH

unknown_home="$TEST_ROOT/unknown-home"
if run_script "$unknown_home" install.sh other; then
  fail "Unknown target returns nonzero"
else
  pass "Unknown target returns nonzero"
fi
expect_absent "$unknown_home/.claude" "Unknown target writes no Claude files"
expect_absent "$unknown_home/.codex" "Unknown target writes no Codex files"

missing_home="$TEST_ROOT/missing-home"
missing_bin="$TEST_ROOT/python-only-bin"
mkdir -p "$missing_bin"
ln -s "$(command -v python3)" "$missing_bin/python3"
mkdir -p "$missing_home"
if env HOME="$missing_home" PATH="$missing_bin:/usr/bin:/bin" bash "$ROOT/install.sh" claude >"$missing_home/output.log" 2>&1; then
  fail "Missing selected CLI returns nonzero"
else
  pass "Missing selected CLI returns nonzero"
fi
expect_absent "$missing_home/.claude" "Prerequisite failure happens before writes"

if [ "$FAILURES" -gt 0 ]; then
  printf '\n%d installer smoke check(s) failed.\n' "$FAILURES"
  exit 1
fi

printf '\nInstaller smoke tests passed.\n'
