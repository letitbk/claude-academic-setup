# 15-Minute Quickstart

Get from zero to your first Claude Code research session in 15 minutes.

---

## Minutes 1-5: Install

```bash
# 1. Install Claude Code CLI (requires Node.js 18+)
npm install -g @anthropic-ai/claude-code

# 2. Clone and run the setup
git clone https://github.com/letitbk/claude-academic-setup.git
cd claude-academic-setup
bash install.sh
```

The installer handles skills, commands, settings, Cursor extensions, Python/R packages, and AI review tools. Watch the output for any warnings — most are non-critical.

## Minutes 5-10: First Session

```bash
# Open Claude Code in any project directory
cd ~/your-research-project
claude
```

Try these first prompts:

1. **"Read my data and describe what you see."** — Give Claude a CSV or Stata file. It will inspect encoding, structure, missing values, and variable types.

2. **"Plan an analysis of [your research question] using [your data]."** — Use `Shift+Tab` to enter Plan Mode. Claude outlines an approach without executing anything. Review the plan, ask questions, revise.

3. **"Run the analysis step by step."** — Claude writes code, runs it, checks diagnostics, and iterates. Watch the agentic loop in action.

## Minutes 10-15: Install Plugins

Inside your Claude Code session, run these one at a time:

```
/install superpowers@obra
/install ralph-loop@claude-plugins-official
/install github@claude-plugins-official
/install context7@claude-plugins-official
```

These four give you extended capabilities, autonomous iteration, GitHub integration, and library documentation lookup. Install the remaining 9 plugins later (see the full list in README.md).

---

## What to Expect

**The first session will feel slow.** You are learning Claude's interaction model, figuring out how to phrase requests, and understanding what it can and cannot do. This is normal. By the third session, you will be significantly faster.

**You will fail at first.** Claude will misunderstand your intent, produce wrong code, or take an approach you don't like. This is part of the learning process. The key is iteration: correct Claude, ask it to explain its reasoning, and guide it toward what you want. Each correction teaches you how to communicate more effectively.

**Settings matter less than how you use the tool.** You can spend hours tweaking settings, permissions, and configurations. Don't. The default settings work well for most academic workflows. What matters far more is:

- **How you frame your requests** — WHAT and WHY, not HOW
- **Whether you plan before executing** — Plan Mode saves more time than any setting
- **Whether you ask Claude to ask YOU questions** — this produces better results than long prompts
- **Whether you build skills for repeated work** — `/skill-creator` compounds your investment

**Invest time in setup, reap returns later.** The 15 minutes you spend installing and learning today saves hours per project. The skills you create, the CLAUDE.md conventions you establish, and the workflow patterns you develop — these accumulate. Your fifth project will be dramatically faster than your first.

**More you use it, better you use it.** Claude Code is a tool, not magic. Like learning R or Stata, proficiency comes from regular use. The researchers who get the most value are those who use Claude Code daily, not those with the most elaborate configurations.

---

## Next Steps

After your first session:

1. **Set up CLAUDE.md** in your project — describe your data, research question, and conventions
2. **Install all 13 plugins** — the full list is in README.md under Post-Install Setup
3. **Try `/codex` or `/gemini`** — get a second opinion on your analysis plan
4. **Run `bash install-optional.sh`** if you want the full 43-skill toolkit
5. **Read the Research Lifecycle section** in README.md for the complete workflow
