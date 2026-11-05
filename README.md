# Claude Code and Codex for academic researchers

This repository is the setup I use to do research with coding agents. It works with Claude Code, Codex, or both. It adds instruction files and skills, plus two plugins for Claude Code. Each part addresses a problem that keeps people, including me, from using and trusting these agents.

The table below lists those problems and what I do about each. The [beginner guide](docs/getting-started.md) has the step by step instructions.

## Why this setup exists

| | Problem | What I do |
|---|---|---|
| 1 | [Can I trust the agent's work?](docs/why-this-setup.md#1-can-i-trust-the-agents-work) | Make a plan before work starts, review it myself, and check the result against it |
| 2 | [Did the agent do the work, and does the plan cover everything?](docs/why-this-setup.md#2-did-the-agent-do-the-work-and-does-the-plan-cover-everything) | Ask an agent from another company to review the plan and the output, with `/codex`, `/agy`, or `$claude` |
| 3 | [How do I write a detailed plan?](docs/why-this-setup.md#3-how-do-i-write-a-detailed-plan) | Say what I want and why, and let the agent ask me questions before it plans |
| 4 | [Agents write text that is hard to read](docs/why-this-setup.md#4-agents-write-text-that-is-hard-to-read) | The `plain-writing` skill |
| 5 | [Agents forget what has been done](docs/why-this-setup.md#5-agents-forget-what-has-been-done) | The `napkin` skill, which keeps a short file of lessons in each project |
| 6 | [I wait while the agent works](docs/why-this-setup.md#6-i-wait-while-the-agent-works) | Run several projects at once in [Orca](https://github.com/stablyai/orca), with each task in its own worktree |
| 7 | [Agents trust data and figures too quickly](docs/why-this-setup.md#7-agents-trust-data-and-figures-too-quickly) | The `datacheck` and `viz` skills |
| 8 | [Did the agent run the analysis, or make up the result?](docs/why-this-setup.md#8-did-the-agent-run-the-analysis-or-make-up-the-result) | The Reproducible Evidence rule, which saves the output of each analysis to a dated log |
| 9 | [Agents do more than I asked](docs/why-this-setup.md#9-agents-do-more-than-i-asked) | The Simplicity First and Surgical Changes rules, which keep each change small enough to read |
| 10 | [Agents break lines in the middle of a sentence](docs/why-this-setup.md#10-agents-break-lines-in-the-middle-of-a-sentence) | The line break rule, which keeps each paragraph on one line |

[Why this setup exists](docs/why-this-setup.md) gives the full answer to each problem and explains each section of the instruction file.

## Which models and agents to use

Use your most advanced model to brainstorm and plan, and a cheaper model to carry out the plan. If you can pay for two plans, use agents from two companies, so that one can check the other. I use Claude Max (OPUS 5.5 as my main agent orchestrator, planner, and executor) and Open AI ChatGPT Plus with Codex GPT-6 Astra as a second reviewer (sometimes Gemini 4 Argon as a third reviewer).

[Which models and agents to use](docs/models-and-plans.md) compares the plans and has the sign up links.

## What the installer adds

| Part | Problem it addresses | Installed for |
|---|---|---|
| Global `CLAUDE.md` or `AGENTS.md` | Independent review (2), asking before guessing (3), evidence that code ran (8), small changes (9), and line breaks (10) | Each agent |
| Plannotator plugin | Review a plan before work starts (1) | Claude Code |
| Superpowers plugin | Brainstorming and planning before work starts (1, 3) | Claude Code |
| `codex`, `agy`, and `claude` skills | Cross model review (2) | `codex` in Claude Code, `claude` in Codex, `agy` in both |
| `plain-writing` skill | Readable prose (4) | Both |
| `napkin` skill | Memory across sessions and agents (5) | Both |
| `datacheck` and `viz` skills | Data and figure checks (7) | Both |
| Starter `settings.json` | Permission prompts, a Bash sandbox, and deny rules for destructive commands | Claude Code |

The installer does not install Claude Code, Codex, the Antigravity CLI, Orca, Planboard, R, or Python packages. You stay in control of those choices.

### Optional additions

The installer leaves these out. The [guide](docs/getting-started.md#optional-skills-and-plugins) shows how to add each one.

| Addition | What it does | Where it comes from |
|---|---|---|
| `hallucinator` skill | Checks that the references in a PDF or bibliography exist, with the right authors, and were not retracted | This repository, plus the [hallucinator](https://github.com/gianlucasb/hallucinator) command line tool |
| Document skills for Claude Code | Read, create, and edit PDF, Word, Excel, and PowerPoint files | Anthropic's [skills repository](https://github.com/anthropics/skills) |
| Document plugins for Codex | Read, create, and edit PDF and Word files | The `pdf` and `documents` plugins that come with recent Codex versions |
| Superpowers for Codex | The same planning and development skills that the setup installs for Claude Code | The [Codex plugin marketplace](https://github.com/openai/plugins/tree/main/plugins/superpowers) |

## Get started

You need Claude Code or Codex, Git, and Python 3. Clone this repository and choose one target:

```bash
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup
bash install.sh claude
# or: bash install.sh codex
# or: bash install.sh both
```

If a file already exists, the installer asks whether to keep it, merge the missing parts, or back it up and replace it. At the end, it lists any programs that the review skills or plugins need and how to install them.

Then read the [beginner guide](docs/getting-started.md). It covers how to install each agent, a first session, permissions and auto mode, Orca and the desktop apps, the review skills, Planboard, and troubleshooting.

## Single purpose research skills

Some skills solve one research problem each, so they live in their own repositories. Install only the ones you need. The [guide](docs/getting-started.md#add-single-purpose-research-skills-when-needed) shows how.

| Repository | What it does |
|---|---|
| [journal-style](https://github.com/letitbk/journal-style) | Format and check regression tables and figures for 17 journals and venues in sociology, general science, economics, political science, public health, statistics, communication, and computer science, and add more |
| [qualtrics-skills](https://github.com/letitbk/qualtrics-skills) | Build and edit Qualtrics surveys through the API, and test every route with scripted respondents before fielding |
| [annotated-site](https://github.com/letitbk/annotated-site) | Make a password protected site where collaborators comment on your Markdown documents |
| [dataverse-skills](https://github.com/letitbk/dataverse-skills) | Keep a replication package in Harvard Dataverse in step with your repository |

## License and credits

This repository is MIT licensed. See [LICENSE](LICENSE).

The bundled `napkin` and `plain-writing` skills keep their upstream licenses and attribution. Sections 2 to 4 of the instruction files adapt the MIT licensed [andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) guidelines. Superpowers, Plannotator, Planboard, Codex, the Antigravity CLI, Orca, hallucinator, and Anthropic's document skills are separate projects with their own licenses and terms.
