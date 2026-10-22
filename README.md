# Claude Code and Codex for Academic Researchers: Beginner Setup

This repository gives academic researchers a small, safe starting point for using a coding agent. You can use Claude Code, Codex, or both. The setup adds a few durable instructions and research skills without turning your computer into a preconfigured workstation.

The goal is simple: learn the basic agent loop first, then add a plan based workflow when the work needs a durable record.

## What this setup adds

| If you choose | The installer adds |
|---|---|
| Claude Code | Global `CLAUDE.md`, five core skills, safe starter settings, and four plugins |
| Codex | Global `AGENTS.md` and four core skills |
| Both | Both configurations, with shared skills installed for each agent |

The Claude plugins are [Planboard](https://github.com/letitbk/planboard), official Superpowers, Claude HUD, and the official GitHub integration. Planboard is installed but does nothing in a project until you run `/planboard:init`.

The base installer does not install Claude Code, Codex, Orca, R, Python packages, browsers, or publishing tools. You stay in control of those system level choices.

## 1. Choose an agent

Claude Code and Codex both read your repository, edit files, run commands, and check their work. Start with the one covered by your existing subscription. Installing both is useful when you want a second model to review important work.

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

## 2. Run the starter setup

You also need Git and Python 3. Clone this repository, then choose one target:

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup

bash install.sh claude
# or: bash install.sh codex
# or: bash install.sh both
```

Run `bash install.sh` without an argument if you prefer an interactive choice.

If a global instruction, settings, or skill file already exists, the installer asks before changing it. It can keep the file, merge safe missing sections or settings, or create a timestamped backup and replace it.

## 3. Complete one basic session

Open a small Git repository that you can safely change. Start your chosen agent and try this sequence:

```text
Explain what this repository does. Read only for now.

Propose one small improvement. Give me a plan before editing anything.

Make the approved change, run the relevant check, and show me the diff.
```

Use `/permissions` to inspect what the agent can do. Review the diff before committing. This setup starts Claude with standard permission prompts and a Bash sandbox. It does not enable permission bypass mode.

## 4. Add Planboard for durable research

Once the basic loop feels familiar, use Planboard for research that you will need to explain, revisit, or share. Planboard adds signed execution plans, a decision log, immutable results bundles, and a browser review board.

Planboard requires Claude Code as its host. Codex can still review plans or run selected work from inside the Planboard workflow.

In a research project, start Claude Code and run:

```text
/planboard:init
```

Then use `/planboard:plan` for the next research component and `/planboard:execute` after you approve its plan. See the [Planboard quickstart](https://github.com/letitbk/planboard/blob/main/QUICKSTART.md) before using it with important data.

## 5. Optional research skills

The base setup stays small. Install the research bundle only if you need it:

```bash
bash install-research-skills.sh claude
# or: codex / both
```

The bundle contains:

- `clean-survey-data`
- `marginaleffects`
- `survey-analysis`
- `qualtrics-survey`
- `journal-figures`
- `journal-tables`

These skills describe workflows but do not install their R, Python, LaTeX, or system dependencies.

## 6. Use Orca when you want a visual workspace

[Orca](https://github.com/stablyai/orca) is an optional desktop workspace for Claude Code, Codex, and other command line agents. It can keep agents in separate Git worktrees, show several sessions side by side, and let you review diffs in one place.

Learn the command line loop first. Then install Orca from [onOrca.dev](https://www.onorca.dev/) or on macOS with:

```bash
brew install --cask stablyai/orca/orca
```

Orca does not replace your Claude or ChatGPT subscription.

## Core skills

| Skill | Purpose |
|---|---|
| `napkin` | Remember corrections and useful project specific lessons |
| `plain-writing` | Write clear prose with simple words and little filler |
| `datacheck` | Inspect a new data file before analysis |
| `viz` | Plan, create, and check a data visualization |
| `codex` | Ask Codex for a separate review from inside Claude Code |

The `/codex` skill is installed only for Claude Code. Running it inside Codex would ask Codex to review itself.

## Learn more

The [beginner guide](docs/getting-started.md) explains instruction files, permissions, skills, plugins, Git checkpoints, context management, Planboard, Orca, migration from older versions of this repository, and troubleshooting.

Official references:

- [Claude Code setup](https://code.claude.com/docs/en/setup)
- [Claude Code permissions](https://code.claude.com/docs/en/permissions)
- [Claude Code plugins](https://code.claude.com/docs/en/discover-plugins)
- [Codex CLI](https://developers.openai.com/codex/cli/)
- [Codex AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)

## License and credits

This repository is MIT licensed. See [LICENSE](LICENSE).

The bundled `napkin` and `plain-writing` skills retain their upstream licenses and attribution. Planboard, Claude plugins, Codex, and Orca are separate projects with their own licenses and terms.
