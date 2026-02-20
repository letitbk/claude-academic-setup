#!/bin/bash
# =============================================================================
# Claude Code Hook: Documentation Update Checker
# =============================================================================
# Triggers after Claude finishes responding to check if documentation
# (README.md, CLAUDE.md, etc.) should be updated based on work completed.
#
# Based on community best practices from:
# - https://github.com/ChrisWiles/claude-code-showcase
# - https://gist.github.com/stevenrouk/6250d07a9112fd16e8f9cfa7b41ecb01
# - https://blog.gitbutler.com/automate-your-ai-workflows-with-claude-code-hooks
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
# File patterns that indicate significant work (worth documenting)
SIGNIFICANT_PATTERNS=(
    '\.py$'           # Python files
    '\.js$'           # JavaScript
    '\.ts$'           # TypeScript
    '\.jsx$'          # React JSX
    '\.tsx$'          # React TSX
    '\.go$'           # Go
    '\.rs$'           # Rust
    '\.java$'         # Java
    '\.rb$'           # Ruby
    '\.php$'          # PHP
    '\.c$'            # C
    '\.cpp$'          # C++
    '\.h$'            # Headers
    '\.swift$'        # Swift
    '\.kt$'           # Kotlin
    '\.scala$'        # Scala
    '\.r$'            # R (case insensitive handled below)
    '\.R$'            # R
    '\.do$'           # Stata
    '\.ado$'          # Stata ado
    'Snakefile'       # Snakemake
    '\.smk$'          # Snakemake rules
    '\.sql$'          # SQL
    '\.sh$'           # Shell scripts
    'Makefile'        # Makefiles
    'Dockerfile'      # Docker
    '\.ya?ml$'        # YAML configs
    '\.toml$'         # TOML configs
    'package\.json$'  # Node.js config
    'Cargo\.toml$'    # Rust config
    'pyproject\.toml$' # Python config
)

# Files to exclude from triggering (already documentation)
EXCLUDE_PATTERNS=(
    'README'
    'CLAUDE'
    'CHANGELOG'
    'LICENSE'
    '\.md$'
    'docs/'
)

# Minimum number of file changes to trigger
MIN_CHANGES=1

# -----------------------------------------------------------------------------
# Read hook input from stdin
# -----------------------------------------------------------------------------
INPUT=$(cat)

# Extract fields from hook input JSON
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# -----------------------------------------------------------------------------
# Validate we have necessary data
# -----------------------------------------------------------------------------
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    # No transcript available, exit silently
    exit 0
fi

# -----------------------------------------------------------------------------
# Analyze the transcript for significant work
# -----------------------------------------------------------------------------

# Count file modifications (Write and Edit tools)
MODIFIED_FILES=$(grep -oE '"tool"\s*:\s*"(Write|Edit)"[^}]*"file_path"\s*:\s*"[^"]*"' "$TRANSCRIPT_PATH" 2>/dev/null | \
    grep -oE '"file_path"\s*:\s*"[^"]*"' | \
    sed 's/"file_path"\s*:\s*"//;s/"$//' | \
    sort -u || true)

# If no files modified, exit silently
if [ -z "$MODIFIED_FILES" ]; then
    exit 0
fi

# Count total modified files
TOTAL_MODIFIED=$(echo "$MODIFIED_FILES" | wc -l | tr -d ' ')

# -----------------------------------------------------------------------------
# Filter for significant files (exclude docs, include source code)
# -----------------------------------------------------------------------------
SIGNIFICANT_FILES=""
while IFS= read -r file; do
    [ -z "$file" ] && continue

    # Skip excluded patterns (documentation files)
    SKIP=false
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        if echo "$file" | grep -qiE "$pattern"; then
            SKIP=true
            break
        fi
    done
    [ "$SKIP" = true ] && continue

    # Check if file matches significant patterns
    for pattern in "${SIGNIFICANT_PATTERNS[@]}"; do
        if echo "$file" | grep -qE "$pattern"; then
            SIGNIFICANT_FILES="$SIGNIFICANT_FILES$file"$'\n'
            break
        fi
    done
done <<< "$MODIFIED_FILES"

# Remove trailing newline and count
SIGNIFICANT_FILES=$(echo "$SIGNIFICANT_FILES" | sed '/^$/d')
SIGNIFICANT_COUNT=$(echo "$SIGNIFICANT_FILES" | grep -c . || echo 0)

# -----------------------------------------------------------------------------
# Check for other indicators of significant work
# -----------------------------------------------------------------------------

# Check if new features were added (function/class definitions)
NEW_FEATURES=false
if grep -qE '"(def |class |function |const |let |var |func |fn |pub fn )' "$TRANSCRIPT_PATH" 2>/dev/null; then
    NEW_FEATURES=true
fi

# Check if tests were added or modified
TESTS_MODIFIED=false
if echo "$MODIFIED_FILES" | grep -qiE '(test_|_test\.|\.test\.|spec\.)'; then
    TESTS_MODIFIED=true
fi

# Check if configuration was changed
CONFIG_CHANGED=false
if echo "$MODIFIED_FILES" | grep -qiE '(config|settings|\.env|\.ya?ml|\.toml|\.json)'; then
    CONFIG_CHANGED=true
fi

# Check for API changes
API_CHANGED=false
if grep -qiE '(endpoint|route|api|handler|controller)' "$TRANSCRIPT_PATH" 2>/dev/null; then
    if [ "$SIGNIFICANT_COUNT" -gt 0 ]; then
        API_CHANGED=true
    fi
fi

# -----------------------------------------------------------------------------
# Determine if we should prompt for documentation update
# -----------------------------------------------------------------------------
SHOULD_PROMPT=false
REASON_PARTS=()

if [ "$SIGNIFICANT_COUNT" -ge "$MIN_CHANGES" ]; then
    SHOULD_PROMPT=true
    REASON_PARTS+=("$SIGNIFICANT_COUNT source file(s) modified")
fi

if [ "$NEW_FEATURES" = true ]; then
    SHOULD_PROMPT=true
    REASON_PARTS+=("new functions/classes added")
fi

if [ "$TESTS_MODIFIED" = true ]; then
    REASON_PARTS+=("tests updated")
fi

if [ "$CONFIG_CHANGED" = true ]; then
    REASON_PARTS+=("configuration changed")
fi

if [ "$API_CHANGED" = true ]; then
    REASON_PARTS+=("possible API changes")
fi

# -----------------------------------------------------------------------------
# Output result
# -----------------------------------------------------------------------------
if [ "$SHOULD_PROMPT" = true ]; then
    # Build reason string
    REASON=$(IFS=', '; echo "${REASON_PARTS[*]}")

    # Build list of modified files for context (max 5)
    FILE_LIST=$(echo "$SIGNIFICANT_FILES" | head -5 | tr '\n' ', ' | sed 's/,$//')
    if [ "$SIGNIFICANT_COUNT" -gt 5 ]; then
        FILE_LIST="$FILE_LIST, and $((SIGNIFICANT_COUNT - 5)) more"
    fi

    # Output JSON to trigger Claude to ask user
    cat << EOF
{"decision":"block","reason":"Significant work completed: $REASON. Files: $FILE_LIST. Ask the user if they would like to update README.md, CLAUDE.md, or other project documentation to reflect these changes."}
EOF
    exit 0
fi

# No significant work detected, exit normally
exit 0
