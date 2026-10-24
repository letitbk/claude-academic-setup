# Claude Code and Codex for academic researchers

This repository is the setup I use to do research with coding agents. It works with Claude Code, Codex, or both. It adds instruction files and skills, plus two plugins for Claude Code. Each part addresses a problem that keeps people, including me, from using and trusting these agents.

The first section explains those problems and what I do about each. The [beginner guide](docs/getting-started.md) has the step by step instructions.

## Why this setup exists

### 1. Can I trust the agent's work?

Agents make things up, and they report a finished task with the same confidence whether the work is right or wrong. You cannot check every line an agent writes.

My answer is to make a plan before any work starts and to review the plan myself. Later, I ask agents to check the result against the plan. A plan is short enough for me to read closely. It is also a fixed standard that the agent and a reviewer can check the work against.

- In Claude Code, I use plan mode. Press Shift+Tab until the mode shows plan, and Claude researches and writes a plan without editing files. The [Plannotator](https://github.com/backnotprop/plannotator) plugin then opens the plan in the browser, where I comment on any line and send the comments back before Claude starts.
- For research that I will need to explain or share later, I use [Planboard](https://github.com/letitbk/planboard). It keeps signed plans, a decision log, and versioned results in the project. Planboard is optional and not installed by default.

### 2. Did the agent do the work, and does the plan cover everything?

An agent can skip a step and still say it finished. When the same agent checks its own work, it tends to miss the same mistakes it made. A plan can also leave out a case that no one thought of.

My answer is to ask an agent from a different company to review the plan, and later the output, before I look at it myself. A model from another company does not share the first model's reasoning, so it catches different mistakes. I do this for every plan or result that matters.

| You work in | Ask for a review with | It calls |
|---|---|---|
| Claude Code | `/codex` | OpenAI Codex CLI |
| Claude Code or Codex | `/agy` | Google's Antigravity CLI (Gemini models) |
| Codex | `$claude` | Claude Code CLI |

Each review skill reports its findings and stops. You decide what to fix. In the instruction file, I also ask the agent to get this review for important plans and results.

### 3. How do I write a detailed plan?

Writing a detailed plan by hand takes a long time. When I tell an agent exactly how to do each step, it follows the steps even where they do not fit the data, because it does not know what the steps are for.

My answer is to say what I want and why, and to leave out how. The reason is the most useful context I can give. When the agent knows the reason, it can choose sensible defaults and notice when a request does not fit the goal. Then the agent and I work out how together. In the instruction file, I ask the agent to state its assumptions and to ask before it guesses. In Claude Code, the agent asks through its question tool, which shows a few options to pick from. A request can be as short as this:

```text
I want a figure that compares self rated health across education groups.
It is for a talk to a general audience, who need to see the gap at a glance.
Ask me about anything you need to decide before you write the plan.
```

### 4. Agents write text that is hard to read

Agents write sentences that sound fluent but say little. They use words people do not use, and they fill text with abbreviations and dashes.

My answer is the `plain-writing` skill. With this skill, the agent writes in simple words and complete sentences. It avoids jargon, unexplained abbreviations, and filler. The agent uses the skill whenever it writes prose for me, e.g., a README, a report, or a commit message. For academic writing, it keeps the field's terms and stays concise.

### 5. Agents forget what has been done

Each session has a limited context window, which is the amount of text the model can hold at once. When a session runs long, the agent summarizes or drops the oldest parts. A new session starts with none of it. With several agents on one project, one agent does not know what another has done.

My answer is the `napkin` skill. With this skill, the agent keeps a short file, `.claude/napkin.md`, in each project. The file records corrections, what worked and what failed, and where the work stands. Every agent reads the napkin when a session starts and updates it as it works. Because the record lives in the project, I can open any agent in a terminal, Claude or Codex, and ask it to continue where the last session stopped.

### 6. I wait while the agent works

A large task can keep an agent busy for many minutes. I do not want to wait, so I work on several projects at once, often with more than one agent in each. That means I need to track which agent works in which folder and branch, and what each one changed.

My answer is [Orca](https://github.com/stablyai/orca), a free, open source desktop app that runs any command line agent. It gives each task its own Git worktree, which is a separate checkout of the repository, so parallel agents do not edit the same files. You can read the project's code, Markdown files, and PDFs next to each agent. Because Claude Code, Codex, and the Antigravity CLI run side by side, it is easy to have one agent review another. If you use only one provider, the Claude or ChatGPT desktop app also manages several projects. The [guide](docs/getting-started.md#work-on-many-projects-at-once) compares the two routes.

### 7. Agents trust data and figures too quickly

Agents load a file and start the analysis without checking what one row is, how missing values are stored, or whether a merge dropped rows. Their figures often label the wrong statistic or leave out groups.

My answer is the `datacheck` and `viz` skills. I built both from the mistakes recorded in about 80 project napkins. `datacheck` inspects a data file before analysis and again after each merge or filter. `viz` plans a figure and checks the exported file, not the plot on screen.

## What the installer adds

| Part | Problem it addresses | Installed for |
|---|---|---|
| Global `CLAUDE.md` or `AGENTS.md` | Ask before guessing (3) and get an independent review (2) | Each agent |
| Plannotator plugin | Review a plan before work starts (1) | Claude Code |
| Superpowers plugin | Brainstorming and planning before work starts (1, 3) | Claude Code |
| `codex`, `agy`, and `claude` skills | Cross model review (2) | `codex` in Claude Code, `claude` in Codex, `agy` in both |
| `plain-writing` skill | Readable prose (4) | Both |
| `napkin` skill | Memory across sessions and agents (5) | Both |
| `datacheck` and `viz` skills | Data and figure checks (7) | Both |
| Starter `settings.json` | Permission prompts, a Bash sandbox, and deny rules for destructive commands | Claude Code |

The installer does not install Claude Code, Codex, the Antigravity CLI, Orca, Planboard, R, or Python packages. You stay in control of those choices.

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
| [journal-style](https://github.com/letitbk/journal-style) | Format and check figures and regression tables for ASR, AJS, Social Forces, Demography, and PNAS |
| [qualtrics-skills](https://github.com/letitbk/qualtrics-skills) | Build and edit Qualtrics surveys through the API, and test every route with scripted respondents before fielding |
| [annotated-site](https://github.com/letitbk/annotated-site) | Make a password protected site where collaborators comment on your Markdown documents |
| [dataverse-skills](https://github.com/letitbk/dataverse-skills) | Keep a replication package in Harvard Dataverse in step with your repository |

These repositories are private for now while I prepare them for public release.

## License and credits

This repository is MIT licensed. See [LICENSE](LICENSE).

The bundled `napkin` and `plain-writing` skills keep their upstream licenses and attribution. Superpowers, Plannotator, Planboard, Codex, the Antigravity CLI, and Orca are separate projects with their own licenses and terms.
