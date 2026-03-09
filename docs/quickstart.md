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

Try these first prompts. The key is being specific — vague prompts produce vague results.

**Prompt 1: Understand your data first.**

> Read the file data/survey_2024.csv. Tell me the encoding, number of rows and columns, variable names and types, how missing values are coded, and whether there are any obvious data quality issues like duplicate IDs or impossible values.

Claude will inspect the raw bytes, detect encoding issues (BOM markers, classic Mac line endings), print summary statistics, and flag problems before you write any analysis code. This is the `/datacheck` skill in action.

**Prompt 2: Plan before you execute.** Press `Shift+Tab` to enter Plan Mode first, then type:

> I want to estimate the effect of parental education on children's health outcomes, using data/survey_2024.csv. The outcome is self_rated_health (ordinal, 1-5). Key predictors are parent_education (categorical) and household_income (continuous). I need to control for age, gender, and region. Plan an analysis in R using ordered logistic regression with marginal effects. Ask me questions before you start.

In Plan Mode, Claude outlines the full approach — model specification, variable coding, diagnostics — without running anything. It will ask you clarifying questions (How should you handle missing income? Should you cluster standard errors by region?). Review the plan, revise, then approve.

**Prompt 3: Execute step by step.**

> Run the analysis from the plan. After each step, show me the output and wait for my approval before continuing. Start with data cleaning and recoding.

Claude writes the R code, runs it, shows you the output, and waits. You can say "looks good, continue" or "the income variable has outliers above 500k, winsorize at the 99th percentile." This is the agentic loop — Claude acts, you verify, Claude iterates.

## Minutes 10-15: Post-Install Setup

Plugins were already installed by `install.sh`. Now set up your tools:

```bash
# Authenticate AI review tools
gemini   # Sign in with Google account
codex    # Sign in with OpenAI account
```

If you use Zotero for references, you can add MCP servers later for literature management — see the optional skills documentation.

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
2. **Try `/codex` or `/gemini`** — get a second opinion on your analysis plan
3. **Run `bash install-optional.sh`** if you want the full 22-skill toolkit
4. **Read the Research Lifecycle section** in README.md for the complete workflow
