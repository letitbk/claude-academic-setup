# Claude Code and Codex for Academic Researchers

This repository gives academic researchers a small, safe starting point for using a coding agent. You can use Claude Code, Codex, or both. The setup adds a few durable instructions and skills without turning your computer into a preconfigured workstation.

Start with the basic agent loop. Once agents do useful work for you, you will run them on several projects at once, so the second section explains how to manage that. Add a plan based workflow when a project needs a durable record.

## What this setup adds

| If you choose | The installer adds |
|---|---|
| Claude Code | Global `CLAUDE.md`, six skills, safe starter settings, and two plugins |
| Codex | Global `AGENTS.md` and six skills |
| Both | Both configurations, with shared skills installed for each agent |

The Claude plugins are [Superpowers](https://github.com/obra/superpowers) and [Plannotator](https://github.com/backnotprop/plannotator). Plannotator also needs its own `plannotator` program, and the installer tells you if it is missing.

The installer does not install Claude Code, Codex, the Antigravity CLI, Orca, R, Python packages, or browsers. You stay in control of those system level choices.

## 1. Choose an agent

Claude Code and Codex both read your repository, edit files, run commands, and check their work. Start with the one covered by your existing subscription. Install both if you want one model to review the work of the other.

### Install Claude Code

Claude Code requires a paid Claude plan or an Anthropic Console account. Anthropic recommends its native installer:

```bash
curl -fsSL https://claude.ai/install.sh | bash
claude
```

Follow the browser sign in, then exit the first session.

### Install Codex

Codex can use your ChatGPT account. OpenAI recommends its standalone installer on macOS and Linux:

```bash
curl -fsSL https://chatgpt.com/codex/install.sh | sh
codex
```

Follow the sign in steps, then exit the first session.

Windows users can install either agent natively. The Bash setup scripts in this repository support macOS, Linux, and WSL. See the [beginner guide](docs/getting-started.md) for native Windows instructions.

## 2. Plan for many projects at once

When an agent starts doing useful work, you will soon have several research projects open, and often more than one agent session in each. One session cleans data while another drafts a section and a third reviews code. You will have to decide how to keep track of them. For each session, you need to know which project and which Git branch it works in, what it changed, and whether someone has checked the result. Pick a way to manage this early, because the habits are harder to change later.

There are two good routes. Choose by how comfortable you are in a terminal and by whether you want to stay with one company.

### Route A. Stay with one provider and use its desktop app

If you use only Claude or only ChatGPT, the official desktop app is a good choice.

- The [Claude desktop app](https://claude.com/resources/articles/claude-code-desktop-redesign) runs Claude Code sessions side by side. A sidebar lists every session and can group them by project. Each session has a diff viewer, a file editor, a preview pane for HTML and PDF files, and a terminal. It is available on the Pro, Max, Team, and Enterprise plans.
- The [ChatGPT desktop app](https://learn.chatgpt.com/docs/app) for macOS, Windows, and Linux lets you choose ChatGPT or Codex and run projects in parallel.

The desktop apps read the same skill folders as the command line tools, so this repository's setup still applies. The installer itself needs the `claude` or `codex` command on your `PATH`. If you have only a desktop app, install the command line tool too, or copy the files by hand as the [beginner guide](docs/getting-started.md) shows.

### Route B. Use Orca if you are comfortable in a terminal

[Orca](https://github.com/stablyai/orca) is a free, open source (MIT) desktop app for macOS, Windows, and Linux that runs any command line agent. This is the route I use. Orca has three strengths for research work:

- You can view code, Markdown files, images, and PDFs for each project next to the agent, so you can read a draft, a figure, or a paper without leaving the workspace.
- You can run Claude Code, Codex, and the Antigravity CLI side by side. Orca gives each task its own Git worktree, which is a separate checkout of the same repository, so parallel agents do not edit the same files.
- You can comment on any line of a diff and send the comments back to the agent.

Install it from [onOrca.dev](https://www.onorca.dev/), or on macOS with:

```bash
brew install --cask stablyai/orca/orca
```

A worktree keeps each agent's files apart, but it does not limit what the agent's commands can reach on your computer. Keep the permission prompts and sandbox from this setup on.

Orca does not replace your Claude or ChatGPT subscription. Start with one project and one agent. Add parallel work once you can tell at a glance which branch and folder each agent controls.

### Ask a second model to check the work

Running several agents makes one habit easy: one model does the work and a model from a different company reviews it. A different model tends to catch different mistakes, because it does not share the first model's reasoning. I often ask `/codex` or `/agy` to review a plan or a result that Claude produced before I accept it.

This setup installs the review skills for you:

| You work in | Ask for a review with | It calls |
|---|---|---|
| Claude Code | `/codex` | OpenAI Codex CLI |
| Claude Code or Codex | `/agy` | Google's Antigravity CLI (Gemini models) |
| Codex | `$claude` | Claude Code CLI |

Each review skill reports findings and then stops. You decide what to fix. OpenAI also publishes an official [Codex plugin for Claude Code](https://github.com/openai/codex-plugin-cc) with `/codex:review` and `/codex:adversarial-review` commands, if you prefer a plugin to a skill.

## 3. Run the starter setup

You need Git and Python 3. Clone this repository, then choose one target:

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup

bash install.sh claude
# or: bash install.sh codex
# or: bash install.sh both
```

Run `bash install.sh` without an argument if you prefer an interactive choice.

If a global instruction, settings, or skill file already exists, the installer asks before changing it. It can keep the file, merge missing sections or settings, or create a timestamped backup and replace it.

At the end, the installer lists any missing programs that the review skills or plugins need, with the command to install each one. It does not install them for you.

## 4. Complete one basic session

Open a small Git repository that you can safely change. Start your chosen agent and try this sequence:

```text
Explain what this repository does. Read only for now.

Propose one small improvement. Give me a plan before editing anything.

Make the approved change, run the relevant check, and show me the diff.
```

Use `/permissions` to inspect what the agent can do. Review the diff before committing. This setup starts Claude with standard permission prompts and a Bash sandbox. It does not turn on permission bypass mode. When the prompts start to slow you down, the [beginner guide](docs/getting-started.md#move-to-auto-mode-when-you-are-comfortable) explains how to move to auto mode.

## Core skills

| Skill | Purpose | Installed for |
|---|---|---|
| `napkin` | Remember corrections and useful project specific lessons | Both |
| `plain-writing` | Write clear prose with simple words and little filler | Both |
| `datacheck` | Inspect a new data file before analysis | Both |
| `viz` | Plan, create, and check a data visualization | Both |
| `agy` | Ask Gemini, through the Antigravity CLI, for an independent review | Both |
| `codex` | Ask Codex for an independent review from inside Claude Code | Claude Code |
| `claude` | Ask Claude for an independent review from inside Codex | Codex |

A review skill never runs inside the agent it calls, because the agent would be reviewing itself.

The `agy` skill is the one place where this setup skips permission prompts. The Antigravity CLI runs without a terminal to answer prompts, so the skill starts it with `--dangerously-skip-permissions` to let it read files and run `git diff`. The skill asks only for review text, but the flag does not enforce that. Commit or stash your work before a review, so that `git status` shows any change the reviewer makes.

## Optional: Planboard for durable research

[Planboard](https://github.com/letitbk/planboard) is a Claude Code plugin for research that you will need to explain, revisit, or share. It adds signed execution plans, a decision log, versioned results bundles, and a browser review board. Install it when the basic loop feels familiar:

```bash
claude plugin marketplace add letitbk/planboard
claude plugin install planboard@planboard --scope user
```

Then run `/planboard:init` in a research project. Use `/planboard:plan` for the next research component and `/planboard:execute` after you approve its plan. Read the [Planboard quickstart](https://github.com/letitbk/planboard/blob/main/QUICKSTART.md) before you use it with important data.

## Single purpose research skills

Some skills solve one research problem each, so they live in their own repositories. Install only the ones you need. Each repository works as a Claude Code plugin and as a set of Agent Skills for Codex and other agents.

| Repository | What it does |
|---|---|
| [journal-style](https://github.com/letitbk/journal-style) | Format and check figures and regression tables for ASR, AJS, Social Forces, Demography, and PNAS |
| [qualtrics-skills](https://github.com/letitbk/qualtrics-skills) | Build and edit Qualtrics surveys through the API, and test every route with scripted respondents before fielding |
| [annotated-site](https://github.com/letitbk/annotated-site) | Make a password protected site where collaborators comment on your Markdown documents |
| [dataverse-skills](https://github.com/letitbk/dataverse-skills) | Keep a replication package in Harvard Dataverse in step with your repository |

These repositories are private for now while I prepare them for public release.

For Claude Code, install one with:

```bash
claude plugin marketplace add letitbk/<repository>
claude plugin install <repository>@<repository> --scope user
```

For Codex, run `npx skills add letitbk/<repository> -g -a codex`.

## Learn more

The [beginner guide](docs/getting-started.md) explains instruction files, permissions, skills, plugins, Git checkpoints, long sessions, multi project workspaces, migration from older versions of this repository, and troubleshooting.

Official references:

- [Claude Code setup](https://code.claude.com/docs/en/setup)
- [Claude Code permissions](https://code.claude.com/docs/en/permissions)
- [Claude Code plugins](https://code.claude.com/docs/en/discover-plugins)
- [Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex skills](https://learn.chatgpt.com/docs/build-skills)
- [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)
- [Antigravity CLI](https://antigravity.google/docs/getting-started?tab=cli)

## License and credits

This repository is MIT licensed. See [LICENSE](LICENSE).

The bundled `napkin` and `plain-writing` skills keep their upstream licenses and attribution. Superpowers, Plannotator, Planboard, Codex, the Antigravity CLI, and Orca are separate projects with their own licenses and terms.
