# Why this setup exists

This page gives the full answer to each problem in the [README](../README.md). The [beginner guide](getting-started.md) has the step by step instructions.

## 1. Can I trust the agent's work?

Agents make things up, and they report a finished task with the same confidence whether the work is right or wrong. You cannot check every line an agent writes.

My answer is to make a plan before any work starts and to review the plan myself. Later, I ask agents to check the result against the plan. A plan is short enough for me to read closely. It is also a fixed standard that the agent and a reviewer can check the work against.

- In Claude Code, I use plan mode. Press Shift+Tab until the mode shows plan, and Claude researches and writes a plan without editing files. The [Plannotator](https://github.com/backnotprop/plannotator) plugin then opens the plan in the browser, where I comment on any line and send the comments back before Claude starts.
- For research that I will need to explain or share later, I use [Planboard](https://github.com/letitbk/planboard). It keeps signed plans, a decision log, and versioned results in the project. Planboard is optional and not installed by default.

## 2. Did the agent do the work, and does the plan cover everything?

An agent can skip a step and still say it finished. When the same agent checks its own work, it tends to miss the same mistakes it made. A plan can also leave out a case that no one thought of.

My answer is to ask an agent from a different company to review the plan, and later the output, before I look at it myself. A model from another company does not share the first model's reasoning, so it catches different mistakes. I do this for every plan or result that matters.

| You work in | Ask for a review with | It calls |
|---|---|---|
| Claude Code | `/codex` | OpenAI Codex CLI |
| Claude Code or Codex | `/agy` | Google's Antigravity CLI (Gemini models) |
| Codex | `$claude` | Claude Code CLI |

Each review skill reports its findings and stops. You decide what to fix. In the instruction file, I also ask the agent to get this review for important plans and results.

## 3. How do I write a detailed plan?

Writing a detailed plan by hand takes a long time. When I tell an agent exactly how to do each step, it follows the steps even where they do not fit the data, because it does not know what the steps are for.

My answer is to say what I want and why, and to leave out how. The reason is the most useful context I can give. When the agent knows the reason, it can choose sensible defaults and notice when a request does not fit the goal. Then the agent and I work out how together. In the instruction file, I ask the agent to state its assumptions and to ask before it guesses. In Claude Code, the agent asks through its question tool, which shows a few options to pick from, so I can answer quickly. I name the tool, `AskUserQuestion`, in the instruction file and say to load it through `ToolSearch`, because an agent stopped using it in one of my sessions in March 2026. For Codex, I name `request_user_input`. Here's one example request:

> I want to examine how social isolation relates to self-rated health during the COVID-19 pandemic, using the survey data in `@data/rawdata`.
>
> Past research links social isolation to poorer mental health. The pandemic may differ, because social distancing was also a privilege. Essential workers often could not isolate, and people who did isolate could stay connected through Zoom. So isolation may not always have harmed health.
>
> The data are longitudinal (see the survey date variable), so we can see how these relationships changed over the pandemic. The data also describe people's discussion networks: whom they talked to about important matters, which channels they used, and whether they stayed at home. These measures may help us separate physical isolation from social connection, and test whether some kinds of contact moderated the link between isolation and health.
>
> Read the codebook in `@data/rawdata` and explore the data to find the relevant variables. Before you write the research plan, ask me about any substantive or methodological decisions that need my input.

## 4. Agents write text that is hard to read

Agents write sentences that sound fluent but say little. They use words people do not use, and they fill text with abbreviations and dashes.

My answer is the `plain-writing` skill. With this skill, the agent writes in simple words and complete sentences. It avoids jargon, unexplained abbreviations, and filler. The agent uses the skill whenever it writes prose for me, e.g., a README, a report, or a commit message. For academic writing, it keeps the field's terms and stays concise.

## 5. Agents forget what has been done

Each session has a limited context window, which is the amount of text the model can hold at once. When a session runs long, the agent summarizes or drops the oldest parts. A new session starts with none of it. With several agents on one project, one agent does not know what another has done.

My answer is the `napkin` skill. With this skill, the agent keeps a short file, `.claude/napkin.md`, in each project. The file records corrections, what worked and what failed, and where the work stands. Every agent reads the napkin when a session starts and updates it as it works. Because the record lives in the project, I can open any agent in a terminal, Claude or Codex, and ask it to continue where the last session stopped.

## 6. I wait while the agent works

A large task can keep an agent busy for many minutes. I do not want to wait, so I work on several projects at once, often with more than one agent in each. That means I need to track which agent works in which folder and branch, and what each one changed.

My answer is [Orca](https://github.com/stablyai/orca), a free, open source desktop app that runs any command line agent. It gives each task its own Git worktree, which is a separate checkout of the repository, so parallel agents do not edit the same files. You can read the project's code, Markdown files, and PDFs next to each agent. Because Claude Code, Codex, and the Antigravity CLI run side by side, it is easy to have one agent review another. If you use only one provider, the Claude or ChatGPT desktop app also manages several projects. The [guide](getting-started.md#work-on-many-projects-at-once) compares the two routes.

## 7. Agents trust data and figures too quickly

Agents load a file and start the analysis without checking what one row is, how missing values are stored, or whether a merge dropped rows. Their figures often label the wrong statistic or leave out groups.

My answer is the `datacheck` and `viz` skills. I built both from the mistakes recorded in about 80 project napkins. `datacheck` inspects a data file before analysis and again after each merge or filter. `viz` plans a figure and checks the exported file, not the plot on screen.

## 8. Did the agent run the analysis, or make up the result?

An agent can report a coefficient or a count that no code produced, and the sentence reads the same as a real result. I kept having to ask agents, "did you run all these models?"

My answer is the Reproducible Evidence section of the instruction file. I added it in March 2026 so that I would have a record that the agent analyzed the data and did not make up the result. For a substantive analysis, the agent saves the output with `tee` to a dated file in `logs/`, e.g., `logs/2026-03-08_14-30-00_main-models.log`. The agent must not report a result unless a log, notebook output, or test report shows that the code ran. One-liners and quick checks do not need a log. The `logs/` folder stays in `.gitignore`, so logs stay out of the repository.

With a log, I can see that the code ran and what the code printed. A log cannot show that the analysis is correct, so I still check the results as problems 1 and 2 describe.

## 9. Agents do more than I asked

Agents add things I did not ask for, and they change things that have nothing to do with the task. In one project, I asked an agent to check three pages, and it added a new analysis of individual users. Extra work like this is more for me to review, and I may not notice it.

My answer is the Simplicity First and Surgical Changes sections of the instruction file. I adapted them, with Think Before Coding, from a [set of guidelines](https://github.com/forrestchang/andrej-karpathy-skills) based on Andrej Karpathy's description of common mistakes that coding agents make. With Simplicity First, the agent builds only what the task needs. With Surgical Changes, the agent leaves alone any code I did not ask it to change. It also matches the existing style and removes only what its own changes left unused. When the agent changes less, I can read every change.

The Git section adds two lines for the same reason. The agent looks at the Git status and diffs before it changes or commits files, and it does not discard work it did not create. I often run several agents on one project, so uncommitted work in a folder may be mine or another agent's.

## 10. Agents break lines in the middle of a sentence

When agents write Markdown or other prose, they break each paragraph into short lines at a fixed width. I had to ask agents to fix these line breaks each time, in one project after another.

My answer is the Prose & Markdown Line Breaks section of the instruction file. The agent writes each paragraph as one continuous line, and the editor wraps it on screen. The agent adds a newline only between blocks, e.g., between two paragraphs. There are two exceptions. Commit message bodies wrap at about 72 characters. A file that is already hard wrapped stays that way unless I agree to change it.

## The eight sections of the instruction file

`CLAUDE.md` and `AGENTS.md` are the files I use myself, so some rules reflect my own preferences. Change any rule that does not suit your work. The two files have the same sections, and each one names its own agent's tools.

| Section | What it asks the agent to do | Why |
|---|---|---|
| 1. Use Skills When Relevant | Use the matching skill first, and ask through the question tool | Problems 3, 4, 5, and 7 |
| 2. Think Before Coding | State assumptions and ask when unsure | Problem 3 |
| 3. Simplicity First | Build only what the task needs | Problem 9 |
| 4. Surgical Changes | Change only what the task needs | Problem 9 |
| 5. Reproducible Evidence | Save the output and report only what ran | Problem 8 |
| 6. Git | Check the Git status first, and keep work it did not create | Problem 9 |
| 7. Prose & Markdown Line Breaks | Write each paragraph as one line | Problem 10 |
| 8. Independent Review | Get a review from a different model for important plans and results | Problem 2 |
