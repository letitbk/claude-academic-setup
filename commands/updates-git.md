You are documenting project progress and committing changes after a major analysis or pipeline step.

## Context from user (if provided)
$ARGUMENTS

## Step 1: Understand what changed

Run these in parallel:
- `git diff --stat` — see which files were modified
- `git diff --staged --stat` — see what's already staged
- `git status` — see untracked files
- `git log --oneline -5` — recent commit style

Also review the current conversation history for context about what work was done in this session.

## Step 2: Identify documentation updates needed

Check each file and update ONLY sections that need to change based on the actual work done. Do NOT fabricate progress or results.

### README.md
- **Pipeline table** (lines ~39-55): Update status column (Pending → Done) and Key Output for any completed steps.
- **Next Steps** section: Remove completed items, add any newly identified next steps.
- **Other sections**: Only update if the work directly affects them (e.g., new dictionary version, new data source).

### CLAUDE.md
- **Pipeline Progress table** (lines ~65-83): Mirror README pipeline status updates.
- **Key Files**: Add any new important files created during this session.
- Do NOT change API docs, CLI docs, or coding conventions unless they actually changed.

### .claude/napkin.md
- **Corrections table**: Add any new mistakes/corrections discovered this session.
- **Patterns That Work / Don't Work**: Add newly confirmed patterns.
- **Domain Notes**: Update if new domain knowledge was established.
- Do NOT duplicate entries that already exist.

### Auto-memory (MEMORY.md)
- Find and update the project's auto-memory MEMORY.md file (under `~/.claude/projects/`) if:
  - A pipeline step status changed
  - New stable patterns were confirmed across multiple interactions
  - Key file paths or conventions changed
- Keep MEMORY.md under 200 lines.

## Step 3: Make the edits

- Use the Edit tool for surgical changes. Do NOT rewrite entire files.
- Match existing formatting and style exactly.
- Only change lines that reflect actual new information.

## Step 4: Commit and push

1. Stage all modified documentation files plus any other changed files from this session's work.
   - Use `git add <specific files>` — never `git add -A`.
   - Do NOT stage files in `data/`, `.env`, or credential files.
2. Write a commit message that summarizes what was accomplished (not "update docs"):
   - Example: "Complete generalizability check: F1=0.871 across 19 non-discovery industries"
   - Example: "Add keyword recon pipeline + update dictionary to v3.1"
   - Do NOT include Co-Authored-By lines.
3. Push to origin.
4. Show the user a brief summary of what was updated and the commit hash.

## Rules
- Never fabricate results or status. If unsure whether a step is complete, ask.
- If nothing meaningful changed, say so and skip the commit.
- If there are merge conflicts or push failures, report them — do not force-push.
