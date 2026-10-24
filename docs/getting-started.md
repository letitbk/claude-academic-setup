# Beginner guide to Claude Code and Codex

This guide explains the setup in this repository. It assumes that you are comfortable opening a terminal but does not assume that you have used a coding agent before.

## Choose Claude Code, Codex, or both

Both agents can read a repository, edit files, run programs, and inspect the result. Choose Claude Code if you already use Claude. Choose Codex if you already use ChatGPT or prefer Codex as your main terminal agent. Choose both if you want one model to review the work of the other.

The optional Planboard workflow is a Claude Code plugin. A Codex only setup still supports ordinary coding and research work, but it cannot host Planboard.

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
foreach ($skill in "napkin", "plain-writing", "datacheck", "viz", "agy", "codex") {
  Copy-Item -Recurse ".\skills\$skill" "$HOME\.claude\skills\$skill"
}
claude plugin marketplace add backnotprop/plannotator
claude plugin install superpowers@claude-plugins-official --scope user
claude plugin install plannotator@plannotator --scope user
irm https://plannotator.ai/install.ps1 | iex
```

On native Windows, edit the copied `settings.json` and set `sandbox.enabled` to `false`; keep standard permission prompts and the deny rules. Leave it enabled when running Claude Code in WSL.

For Codex:

```powershell
New-Item -ItemType Directory -Force "$HOME\.codex\skills" | Out-Null
Copy-Item .\AGENTS.md "$HOME\.codex\AGENTS.md"
foreach ($skill in "napkin", "plain-writing", "datacheck", "viz", "agy", "claude") {
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
| Claude | `~/.claude/CLAUDE.md` | Five shared skills plus `codex` | Minimal settings and two user plugins |
| Codex | `~/.codex/AGENTS.md` | Five shared skills plus `claude` | No Claude settings or plugins |

The shared skills are `napkin`, `plain-writing`, `datacheck`, `viz`, and `agy`. The `codex` skill lets Claude ask Codex for a review, and the `claude` skill lets Codex ask Claude.

The installer then checks for the programs that the review skills and plugins call: `agy`, `plannotator`, and the other agent's command line tool. If one is missing, the summary prints a warning and the command to install it. Setup still succeeds.

### Where Codex looks for skills

This installer copies Codex skills to `~/.codex/skills`, which current Codex versions read. The [Codex documentation](https://learn.chatgpt.com/docs/build-skills) names `~/.agents/skills` as the user skill folder, and tools such as `npx skills add -a codex` install there. Keep each skill in only one of the two folders. If the same skill is in both, Codex may list it twice.

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
| Superpowers | General planning, debugging, testing, and development discipline |
| Plannotator | Review and annotate a plan or a diff in the browser before the agent continues |

Plannotator needs the `plannotator` program. Install it with `curl -fsSL https://plannotator.ai/install.sh | bash` on macOS, Linux, or WSL.

Use `/plugin` in Claude Code to inspect, update, disable, or uninstall plugins.

## Permissions and sandboxing

Permissions decide which tools the agent may use. Sandboxing limits what Bash commands can reach on the filesystem and network. They are separate safety layers.

This repository's template uses:

- normal permission prompts;
- an enabled Bash sandbox;
- prompts even for sandboxed Bash commands;
- no unsandboxed command escape;
- deny rules for common secret and credential files;
- deny rules for a few destructive commands, e.g., `sudo`, force pushes, and `rm -rf` on your home folder.

Deny rules block a command in every permission mode. They are a backstop for the worst mistakes, not a complete list of risky commands.

Use `/permissions` to inspect the active rules. Do not make permission bypass mode your beginner default. It skips the normal approval layer and is appropriate only inside an environment whose isolation you understand.

The installer merges only missing settings when you choose merge. If your existing file already selects a different permission mode, your existing choice wins.

### Move to auto mode when you are comfortable

Recent Claude Code versions start in auto mode unless a setting says otherwise. The template sets `defaultMode` to `default`, so Claude asks before it edits files or runs most commands. Approving each step is a good way to learn what the agent does. After a few weeks, the prompts mostly slow you down. Auto mode is the next step, and it is the mode I use every day.

In [auto mode](https://code.claude.com/docs/en/permission-modes), Claude works without routine prompts. A separate model reviews each action before it runs and blocks actions that go beyond your request, e.g., a force push, `curl | bash`, or deleting files that existed before the session. Your deny rules and the Bash sandbox still apply. Anthropic's documentation warns that auto mode reduces prompts but does not guarantee safety, so keep committing often and keep reviewing diffs.

To try it for one session, run `claude --permission-mode auto`, or press Shift+Tab until the mode shows auto. To make it your default, set `"defaultMode": "auto"` in `~/.claude/settings.json`. It works only in your user settings file, not in a project's `.claude/settings.json`.

### Optional: check R and YAML syntax after each edit

A hook is a command that Claude Code runs at a fixed point, e.g., after every file edit. The following hook parses each `.R` or `.yaml` file right after Claude writes it, so a syntax error shows up immediately instead of at the end of a long pipeline run. It needs `jq`, R, and Python with `pyyaml`. Add it to the `hooks` key in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "f=$(jq -r '.tool_input.file_path'); if echo \"$f\" | grep -qE '\\.R$'; then R --no-save --no-restore -e \"parse('$f')\" 2>&1 | tail -3 || true; elif echo \"$f\" | grep -qE '\\.ya?ml$'; then python3 -c \"import yaml; yaml.safe_load(open('$f'))\" 2>&1 || true; fi"
          }
        ]
      }
    ]
  }
}
```

The installer does not add this hook. Run `/hooks` in Claude Code to check that it loaded.

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

Planboard is optional and is not installed by default. Use it when the project will be revised, shared, submitted, or defended later. A throwaway exploration usually does not need it.

```bash
claude plugin marketplace add letitbk/planboard
claude plugin install planboard@planboard --scope user
```

Then, in a research project:

```text
/planboard:init
/planboard:plan
/planboard:execute
```

The first command interviews you about the project. The second prepares a reviewable execution plan. The third asks you to sign the plan before work begins, then captures results against it.

Planboard can ask Codex to review work, but Claude Code must host the plugin. Read the [Planboard quickstart](https://github.com/letitbk/planboard/blob/main/QUICKSTART.md) for the complete workflow.

## Add single purpose research skills when needed

Research skills that solve one problem each live in their own repositories: journal-style, qualtrics-skills, annotated-site, and dataverse-skills. The README lists what each one does. Install only what a project needs, and install each skill's own dependencies, such as R packages or an API token, as its README describes. This setup does not change your R or Python environments.

## Work on many projects at once

Once agents help with real research, you will run them on several projects, and often run more than one session in a project. Decide early how you will keep track of them. For each session you should be able to answer these questions at a glance:

- Which project folder and which Git branch is it working in?
- What has it changed since your last commit?
- Has a person or a second model checked the result?

### If you use one provider, use its desktop app

The [Claude desktop app](https://claude.com/resources/articles/claude-code-desktop-redesign) lists every Claude Code session in a sidebar that you can group by project. Each session has a diff viewer, a file editor, an HTML and PDF preview pane, and a terminal. The [ChatGPT desktop app](https://learn.chatgpt.com/docs/app) lets you switch between ChatGPT and Codex and run projects in parallel. Both apps read the same skill folders that this installer writes. The installer needs the `claude` or `codex` command line tool. If you only have a desktop app, install the command line tool as described above, or copy the files with the PowerShell commands and their macOS or Linux equivalents.

### If you are comfortable in a terminal, try Orca

[Orca](https://github.com/stablyai/orca) is a free, open source desktop app for macOS, Windows, and Linux that runs any command line agent. It gives each task its own Git worktree. A worktree is a second checkout of the same repository on a separate branch, so two agents do not edit the same files. Orca also shows code, Markdown, images, and PDFs next to each agent, and you can comment on a diff line and send the comment back to the agent.

Install it from [onOrca.dev](https://www.onorca.dev/) or on macOS:

```bash
brew install --cask stablyai/orca/orca
```

Connect the agent accounts you already use. Start with one project and one agent. Add a second agent only after you can tell which branch and folder each agent controls.

A worktree separates files, not processes. An agent in a worktree can still run any command your account can run, so keep the permission prompts and the sandbox on.

### Check one model's work with another

With several agents open, it is easy to ask a second model to review a plan or a result before you accept it. A model from another company does not share the first model's reasoning, so it often catches different mistakes.

- In Claude Code, run `/codex` for a Codex review or `/agy` for a Gemini review.
- In Codex, run `$claude` for a Claude review or `$agy` for a Gemini review.

Each review skill reports its findings and stops. You choose which findings to act on.

The `agy` skill starts the Antigravity CLI with `--dangerously-skip-permissions`. The Antigravity CLI cannot show a permission prompt when it runs from a script, so without the flag it stops at its first command. This is the one place in the setup that skips permission prompts. The review prompt asks only for text, but the flag does not enforce that. Commit or stash your work before a review, so that `git status` shows any change the reviewer makes.

Install the Antigravity CLI from [Google's instructions](https://antigravity.google/docs/getting-started?tab=cli). On macOS and Linux:

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```

Google stopped serving Gemini CLI for personal Google accounts on June 18, 2026 and points users to the Antigravity products, so this setup uses `agy` rather than Gemini CLI.

## Updating from an older version of this repository

The new installer does not delete global skills or uninstall plugins from an older setup. This protects personal modifications.

Before cleaning anything up:

```bash
claude plugin list
find ~/.claude/skills -mindepth 1 -maxdepth 1 -type d
```

Use Claude's `/plugin` screen to disable an old plugin before uninstalling it. Move a skill directory to a backup before deleting it. The current repository manifest in the README is the source of truth for what a fresh install includes.

Earlier versions of this repository installed Claude HUD, the GitHub plugin, and Planboard by default, and included a research skill bundle with survey, marginal effects, Qualtrics, and journal formatting skills. Planboard is now optional. The Qualtrics and journal skills moved to their own repositories. Your existing copies keep working until you remove them.

## Troubleshooting

| Problem | Check |
|---|---|
| `claude` or `codex` is not found | Reopen the terminal, then run the official installer again |
| Installer stops before writing | Confirm the selected CLI and `python3` are on `PATH` |
| A plugin fails | Run the exact retry command printed by the installer |
| The summary warns that `agy` is missing | Install the Antigravity CLI, then run `agy` once to sign in |
| The summary warns that `plannotator` is missing | Run `curl -fsSL https://plannotator.ai/install.sh \| bash` |
| A skill appears twice in Codex | Keep it in only one of `~/.codex/skills` and `~/.agents/skills` |
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
- [Codex skills](https://learn.chatgpt.com/docs/build-skills)
- [Antigravity CLI](https://antigravity.google/docs/getting-started?tab=cli)
- [Plannotator](https://github.com/backnotprop/plannotator)
- [Planboard](https://github.com/letitbk/planboard)
- [Orca](https://github.com/stablyai/orca)
