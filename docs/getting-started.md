# Beginner guide to Claude Code and Codex

This guide explains the setup in this repository. It assumes that you are comfortable opening a terminal but does not assume that you have used a coding agent before.

## Choose Claude Code, Codex, or both

Both agents can read a repository, edit files, run programs, and inspect the result. The main difference for this setup is that Planboard is a Claude Code plugin. A Codex only setup still supports ordinary coding and research work, but it cannot host Planboard.

Choose Claude Code if you already use Claude or want the Planboard workflow. Choose Codex if you already use ChatGPT or prefer Codex as your main terminal agent. Choose both if you want one model to review another.

## Install the agent itself

### Claude Code on macOS, Linux, or WSL

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude --version
claude
```

The native installer updates Claude Code automatically. Homebrew is also supported, but it requires manual upgrades.

### Codex on macOS or Linux

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex --version
codex
```

Choose the ChatGPT sign in option unless you intend to use an API key.

### Native Windows

Follow the official Windows instructions for your selected agent. This repository does not ship a PowerShell installer. You can run the Bash setup inside WSL, or configure the files manually in PowerShell. Claude's Bash sandbox is available in WSL but not in native Windows.

Before copying, back up any destination that already exists. For Claude Code:

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills" | Out-Null
Copy-Item .\CLAUDE.md "$HOME\.claude\CLAUDE.md"
Copy-Item .\settings.json "$HOME\.claude\settings.json"
foreach ($skill in "napkin", "plain-writing", "datacheck", "viz", "codex") {
  Copy-Item -Recurse ".\skills\$skill" "$HOME\.claude\skills\$skill"
}
claude plugin marketplace add jarrodwatts/claude-hud
claude plugin marketplace add letitbk/planboard
claude plugin install superpowers@claude-plugins-official --scope user
claude plugin install github@claude-plugins-official --scope user
claude plugin install claude-hud@claude-hud --scope user
claude plugin install planboard@planboard --scope user
```

On native Windows, edit the copied `settings.json` and set `sandbox.enabled` to `false`; keep standard permission prompts and the deny rules. Leave it enabled when running Claude Code in WSL.

For Codex:

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
Copy-Item .\AGENTS.md "$HOME\.codex\AGENTS.md"
foreach ($skill in "napkin", "plain-writing", "datacheck", "viz") {
  Copy-Item -Recurse ".\skills\$skill" "$HOME\.codex\skills\$skill"
}
```

These commands assume that the destination files and skill directories do not exist. If they do, stop and back them up first. Use the Bash installer in WSL if you want guided keep, merge, and backup choices.

## Install this repository's small configuration layer

You need Git and Python 3. From a terminal:

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup
bash install.sh claude
```

Replace `claude` with `codex` or `both` as needed. With no argument, the script asks which target to configure.

The script checks prerequisites before writing. It then installs:

| Target | Instructions | Skills | Other configuration |
|---|---|---|---|
| Claude | `~/.claude/CLAUDE.md` | Four shared skills plus `/codex` | Minimal settings and four user plugins |
| Codex | `~/.codex/AGENTS.md` | Four shared skills | No Claude settings or plugins |

The shared skills are `napkin`, `plain-writing`, `datacheck`, and `viz`.

### What happens when a file already exists

The installer never silently overwrites a different file.

For instruction files, you can:

- keep the existing file;
- append only template sections whose `##` heading is missing;
- back up the existing file and replace it.

For Claude settings, you can:

- keep the existing settings;
- add missing template keys while preserving every existing value;
- back up and replace the settings.

For a skill directory, you can keep it or back it up and replace it. Backups are stored under `~/.claude-academic-setup-backups/<timestamp>/`.

## Your first session

Start in a small Git repository. Do not use sensitive data for the first exercise.

```bash
cd path/to/a/small-repository
git status
claude
# or: codex
```

Ask the agent to work in three stages:

```text
Explain this repository. Do not change files yet.
```

Check whether its explanation matches what you know. Then ask:

```text
Suggest one small improvement and give me a plan. Wait for my approval before editing.
```

Ask questions about anything unclear. Once the plan is acceptable:

```text
Implement the approved change. Run the smallest relevant check and show me the diff.
```

Read the diff. Keep the change only if you understand it. Git gives you a checkpoint, but it does not replace review.

## Instruction files are durable context

An agent does not remember every past session. Instruction files provide stable rules that load when a session starts.

Claude Code reads `CLAUDE.md`. Codex reads `AGENTS.md`. Both support a global file for rules that apply everywhere and project files for local facts.

| Scope | Claude Code | Codex |
|---|---|---|
| Global | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` |
| Project | `CLAUDE.md` in the repository | `AGENTS.md` in the repository |

Keep global rules general. Put the research question, data sources, analysis conventions, and project commands in the project file.

A useful project file is short:

```markdown
# Project

## Question

Estimate how parental education is associated with self rated health.

## Data

- `data/analysis.csv` is the cleaned analysis file.
- Missing values use `NA`.

## Checks

- Run `Rscript tests/check-analysis.R` after model changes.
- Do not edit raw files under `data/raw/`.
```

## Skills and plugins

A skill is a small instruction package for a recurring kind of task. Skills can trigger from an ordinary request, so you do not need to memorize slash commands.

A plugin can add skills, tools, hooks, or external services to Claude Code. Plugins are trusted code. Review the source before installing an unfamiliar plugin.

The Claude setup installs:

| Plugin | Why it is included |
|---|---|
| Planboard | Durable plans, decisions, results, and review for research projects |
| Superpowers | General planning, debugging, testing, and development discipline |
| Claude HUD | Visible session and context information |
| GitHub | Issues, pull requests, and repository collaboration |

Use `/plugin` in Claude Code to inspect, update, disable, or uninstall plugins. Use `/mcp` if the GitHub integration needs authentication.

## Permissions and sandboxing

Permissions decide which tools the agent may use. Sandboxing limits what Bash commands can reach on the filesystem and network. They are separate safety layers.

This repository's template uses:

- normal permission prompts;
- an enabled Bash sandbox;
- prompts even for sandboxed Bash commands;
- no unsandboxed command escape;
- deny rules for common secret and credential files.

Use `/permissions` to inspect the active rules. Do not make permission bypass mode your beginner default. It skips the normal approval layer and is appropriate only inside an environment whose isolation you understand.

The installer merges only missing settings when you choose merge. If your existing file already selects a different permission mode, your existing choice wins.

## Use Git as a checkpoint

Before a meaningful change:

```bash
git status
git diff
```

After you verify the result:

```bash
git add path/to/files
git commit -m "Describe the completed change"
```

Do not ask an agent to force push or erase uncommitted work unless you understand exactly what will be lost.

## Manage long sessions

Start a new session when the task changes substantially. Keep durable facts in project instructions or project documentation instead of relying on chat history.

The `napkin` skill keeps a small `.claude/napkin.md` file with corrections and useful lessons. It is not a transcript. It should contain only information that would change how the next session works.

Planboard provides a stronger record for long research projects. It stores plans, decisions, results, and review state in the project itself.

## Add Planboard after learning the basic loop

Planboard is installed for Claude users during bootstrap. It remains inactive until a project opts in.

Use it when the project will be revised, shared, submitted, or defended later. A throwaway exploration usually does not need it.

```text
/planboard:init
/planboard:plan
/planboard:execute
```

The first command interviews you about the project. The second prepares a reviewable execution plan. The third asks you to sign the plan before work begins, then captures results against it.

Planboard can ask Codex to review work, but Claude Code must host the plugin. Read the [Planboard quickstart](https://github.com/letitbk/planboard/blob/main/QUICKSTART.md) for the complete workflow.

## Add the research skill bundle only when needed

```bash
bash install-research-skills.sh claude
# or: codex / both
```

The script installs a fixed set. It does not scan the repository and install every skill it finds.

| Skill | External requirements |
|---|---|
| `clean-survey-data` | R packages named in the skill |
| `marginaleffects` | R and the `marginaleffects` package |
| `survey-analysis` | R and the `survey` package |
| `qualtrics-survey` | A Qualtrics API token and Python or curl |
| `journal-figures` | Python image and PDF packages |
| `journal-tables` | R, LaTeX, Poppler, and Pandoc |

Install only the dependencies needed by your project. The setup scripts do not modify your R or Python environments.

## Use Orca after you understand the CLI

Orca is a visual workspace for command line agents. It can create separate Git worktrees, run several agents side by side, display repository files, and annotate diffs.

Install it from [onOrca.dev](https://www.onorca.dev/) or on macOS:

```bash
brew install --cask stablyai/orca/orca
```

Connect the agent accounts you already use. Start with one worktree and one agent. Add parallel work only after you are comfortable checking which branch and directory each agent controls.

## Updating from an older version of this repository

The new installer does not delete global skills or uninstall plugins from an older setup. This protects personal modifications.

Before cleaning anything up:

```bash
claude plugin list
find ~/.claude/skills -mindepth 1 -maxdepth 1 -type d
```

Use Claude's `/plugin` screen to disable an old plugin before uninstalling it. Move a skill directory to a backup before deleting it. The current repository manifest in the README is the source of truth for what a fresh install includes.

## Troubleshooting

| Problem | Check |
|---|---|
| `claude` or `codex` is not found | Reopen the terminal, then run the official installer again |
| Installer stops before writing | Confirm the selected CLI and `python3` are on `PATH` |
| A plugin fails | Run the exact retry command printed by the installer |
| GitHub plugin cannot connect | Open `/mcp` in Claude and complete authentication |
| Sandbox unavailable | Use WSL on Windows, or follow the Claude sandbox troubleshooting guide |
| Skill does not trigger | Restart the agent and ask for the task in ordinary language or invoke the skill explicitly |
| Existing settings behave differently | Your existing values win when you choose merge; inspect them with `/permissions` |

Useful diagnostics:

```bash
claude doctor
claude plugin list
codex --version
python3 --version
git status
```

## Official references

- [Claude Code setup](https://code.claude.com/docs/en/setup)
- [Claude Code permissions](https://code.claude.com/docs/en/permissions)
- [Claude Code settings](https://code.claude.com/docs/en/settings)
- [Claude Code plugins](https://code.claude.com/docs/en/discover-plugins)
- [Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)
- [Planboard](https://github.com/letitbk/planboard)
- [Orca](https://github.com/stablyai/orca)
