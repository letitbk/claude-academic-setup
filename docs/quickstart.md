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

### Two approaches that matter more than any prompt

Most AI coding tools encourage a simple loop: you type a request, the tool produces output. Claude Code can do that, but the real value for research comes from two specific interaction patterns. Learning these two approaches early will shape every session that follows.

**Approach 1: Plan Mode — co-design before executing.** Press `Shift+Tab` to enter Plan Mode. In this mode, Claude outlines an approach without running anything. You review, push back, revise. Nothing executes until you approve. This is how you avoid wasting time on analysis that starts from the wrong assumptions.

**Approach 2: Interactive Q&A — make Claude ask YOU questions.** Instead of writing a long, detailed prompt that tries to anticipate everything, tell Claude to ask you questions first. Claude will surface assumptions you didn't know you were making — how to handle missing data, what counts as an outlier, whether a control variable belongs in the model. This produces better analysis than any prompt you could write alone, because it forces you to articulate decisions you would otherwise make silently.

These two approaches work together. Plan Mode structures the *what*. Interactive Q&A surfaces the *why*. In practice, you'll move between them: plan an analysis, let Claude ask questions that refine the plan, then execute.

### Try it

**Prompt 1: Understand your data first.**

> Read the file data/survey_2024.csv. Tell me the encoding, number of rows and columns, variable names and types, how missing values are coded, and whether there are any obvious data quality issues like duplicate IDs or impossible values.

Claude will inspect the raw bytes, detect encoding issues, print summary statistics, and flag problems before you write any analysis code.

**Prompt 2: Plan before you execute.** Press `Shift+Tab` to enter Plan Mode, then type:

> I want to estimate the effect of parental education on children's health outcomes, using data/survey_2024.csv. The outcome is self_rated_health (ordinal, 1-5). Key predictors are parent_education (categorical) and household_income (continuous). I need to control for age, gender, and region. Plan an analysis in R using ordered logistic regression with marginal effects.

In Plan Mode, Claude outlines the full approach — model specification, variable coding, diagnostics — without running anything. Review the plan, revise it, then exit Plan Mode (`Shift+Tab` again) to execute.

**Prompt 3: Let Claude interview you.** Instead of specifying every detail yourself:

> I want to analyze the relationship between social media use and mental health in this dataset. Before writing any code, ask me questions about what I want and what assumptions I'm making.

Claude will ask things like: What's your outcome measure? Are you looking for a causal estimate or a descriptive association? How do you want to handle respondents who report zero social media use — are they a meaningful category or missing data? Each question forces you to make a decision you might have skipped. This is the interactive approach in action.

**Prompt 4: Execute step by step.**

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

**Settings matter less than how you use the tool.** You can spend hours tweaking settings, permissions, and configurations. Don't. The default settings work well for most academic workflows. What matters far more is whether you use the two approaches described above — planning before executing, and letting Claude ask you questions instead of trying to write the perfect prompt. These two habits will improve your results more than any configuration change.

**Invest time in setup, reap returns later.** The 15 minutes you spend installing and learning today saves hours per project. The skills you create, the CLAUDE.md conventions you establish, and the workflow patterns you develop — these accumulate. Your fifth project will be dramatically faster than your first.

**More you use it, better you use it.** Claude Code is a tool, not magic. Like learning R or Stata, proficiency comes from regular use. The researchers who get the most value are those who use Claude Code daily, not those with the most elaborate configurations.

---

## Next Steps

After your first session:

1. **Set up CLAUDE.md** in your project — describe your data, research question, and conventions
2. **Try `/codex` or `/gemini`** — get a second opinion on your analysis plan
3. **Run `bash install-optional.sh`** if you want the full 22-skill toolkit
4. **Read the Research Lifecycle section** in README.md for the complete workflow
