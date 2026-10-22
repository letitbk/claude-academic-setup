#!/usr/bin/env bash
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILURES=0

pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; FAILURES=$((FAILURES + 1)); }

expect_equal() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  if [ "$expected" = "$actual" ]; then
    pass "$label"
  else
    fail "$label (expected: $expected; actual: $actual)"
  fi
}

expected_skills=$(printf '%s\n' \
  agy claude codex datacheck napkin plain-writing viz | sort)
actual_skills=$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
expect_equal "skill manifest" "$expected_skills" "$actual_skills"

for path in \
  commands hooks install-optional.sh settings-safe.json \
  presentation_ai_workflow.pdf docs/plans install-research-skills.sh \
  skills/clean-survey-data skills/marginaleffects skills/survey-analysis \
  skills/qualtrics-survey skills/journal-figures skills/journal-tables; do
  if [ -e "$ROOT/$path" ]; then
    fail "removed path absent: $path"
  else
    pass "removed path absent: $path"
  fi
done

for script in install.sh scripts/install-common.sh tests/installer-smoke.sh; do
  if bash -n "$ROOT/$script"; then
    pass "$script syntax"
  else
    fail "$script syntax"
  fi
done

for executable in install.sh tests/validate-repo.sh tests/installer-smoke.sh; do
  if [ -x "$ROOT/$executable" ]; then
    pass "$executable is executable"
  else
    fail "$executable is executable"
  fi
done

if python3 -m json.tool "$ROOT/settings.json" >/dev/null; then
  pass "settings.json parses"
else
  fail "settings.json parses"
fi

settings_result=$(python3 - "$ROOT/settings.json" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1]))
sandbox = data.get("sandbox", {})
permissions = data.get("permissions", {})
ok = (
    sandbox.get("enabled") is True
    and sandbox.get("autoAllowBashIfSandboxed") is False
    and sandbox.get("allowUnsandboxedCommands") is False
    and permissions.get("defaultMode") == "default"
    and "enabledPlugins" not in data
)
print("ok" if ok else "bad")
PY
)
expect_equal "minimal safe settings" "ok" "$settings_result"

expected_plugins=$(printf '%s\n' \
  plannotator@plannotator superpowers@claude-plugins-official | sort)
actual_plugins=$(sed -n '/^CLAUDE_PLUGINS=(/,/^)/p' "$ROOT/install.sh" 2>/dev/null \
  | sed -n 's/^[[:space:]]*"\([^"]*\)"[[:space:]]*$/\1/p' | sort)
expect_equal "plugin manifest" "$expected_plugins" "$actual_plugins"

# Section 8 names each agent's own reviewers, so compare the shared sections only.
if diff -u <(sed -n '2,/^## 8\./p' "$ROOT/CLAUDE.md") <(sed -n '2,/^## 8\./p' "$ROOT/AGENTS.md") >/dev/null; then
  pass "instruction bodies match"
else
  fail "instruction bodies match"
fi
expect_equal "Claude template names its reviewers" "1" "$(rg -c '/codex. or ./agy' "$ROOT/CLAUDE.md")"
expect_equal "Codex template names its reviewers" "1" "$(rg -c '[$]claude. or .[$]agy' "$ROOT/AGENTS.md")"

if rg -n '/Users/bk|/Users/[^ ]+' "$ROOT/skills" -g '*.md' -g '*.py' -g '*.R' -g '*.yaml' >/dev/null; then
  fail "retained skills contain no private absolute paths"
else
  pass "retained skills contain no private absolute paths"
fi

if rg -n 'Cursor|cursor|claude-hud|github@claude-plugins-official|install-research-skills|clean-survey-data|survey-analysis|ralph-loop|claude-notifications-go|research-plans|presentation_ai_workflow' \
  "$ROOT/README.md" "$ROOT/docs" "$ROOT/install.sh" "$ROOT/settings.json" "$ROOT/CLAUDE.md" "$ROOT/AGENTS.md" >/dev/null 2>&1; then
  fail "active setup has no removed component references"
else
  pass "active setup has no removed component references"
fi

if rg -n '/(coefficient-plot|marginal-effects-plot|compute-survey-weights|updates-git)' \
  "$ROOT/skills" -g '*.md' >/dev/null; then
  fail "retained skills reference only bundled workflows"
else
  pass "retained skills reference only bundled workflows"
fi

if [ -f "$ROOT/tests/skill-scenarios.md" ]; then
  pass "skill trigger scenarios documented"
else
  fail "skill trigger scenarios documented"
fi

if rg -q '^logs/$' "$ROOT/.gitignore"; then
  pass "test logs are ignored"
else
  fail "test logs are ignored"
fi

if rg -n 'gemini' "$ROOT/skills/agy/SKILL.md" >/dev/null; then
  fail "agy skill does not point to an unshipped /gemini skill"
else
  pass "agy skill does not point to an unshipped /gemini skill"
fi

if [ "$FAILURES" -gt 0 ]; then
  printf '\n%d validation check(s) failed.\n' "$FAILURES"
  exit 1
fi

printf '\nRepository validation passed.\n'
