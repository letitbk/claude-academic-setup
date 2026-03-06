---
marp: true
theme: default
paginate: true
---

<style>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500&display=swap');

:root {
  --color-background: #ffffff;
  --color-foreground: #2c2c2c;
  --color-heading: #1a1a1a;
  --color-accent: #e0e0e0;
  --font-default: 'Inter', 'Helvetica Neue', sans-serif;
}

section {
  background-color: var(--color-background);
  color: var(--color-foreground);
  font-family: var(--font-default);
  font-weight: 300;
  box-sizing: border-box;
  position: relative;
  line-height: 1.8;
  font-size: 24px;
  padding: 60px 80px;
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 400;
  color: var(--color-heading);
  margin: 0;
  padding: 0;
}

h1 {
  font-size: 60px;
  line-height: 1.3;
  text-align: left;
  font-weight: 300;
  letter-spacing: 0.02em;
}

h2 {
  font-size: 42px;
  margin-bottom: 40px;
  font-weight: 400;
  letter-spacing: 0.01em;
}

h3 {
  color: var(--color-foreground);
  font-size: 28px;
  margin-top: 32px;
  margin-bottom: 16px;
  font-weight: 400;
}

ul, ol {
  padding-left: 32px;
}

li {
  margin-bottom: 14px;
  line-height: 1.7;
}

footer {
  font-size: 14px;
  color: #999999;
  position: absolute;
  left: 80px;
  right: 80px;
  bottom: 40px;
  text-align: center;
}

section.lead {
  display: flex;
  flex-direction: column;
  justify-content: center;
  text-align: center;
}

section.lead h1 {
  margin-bottom: 32px;
  text-align: center;
}

section.lead p {
  font-size: 24px;
  color: var(--color-foreground);
  font-weight: 300;
}

hr {
  border: none;
  border-top: 1px solid var(--color-accent);
  margin: 40px 0;
}

blockquote {
  border-left: 3px solid var(--color-accent);
  padding-left: 20px;
  margin: 16px 0;
  font-size: 22px;
  color: #555;
}

code {
  font-size: 20px;
  background: #f5f5f5;
  padding: 2px 8px;
  border-radius: 4px;
}
</style>

<!-- _class: lead -->

# Coding Agents for Academic Research

BK Lee · NYU
March 2026

---

## From Chatbot to Agent

### Chatbot
You ask → it generates code → you copy-paste → you run it → you debug → you paste the error back → repeat

### Agent
You describe the task → it reads your files → writes code → runs it → checks output → fixes errors → repeats until done

Runs in your terminal or inside your IDE.
You direct **what** and **why**. The agent figures out **how**.

---

## The Tireless RA

An RA who can code in any language, works around the clock, and follows your instructions to the letter.

But: it has no independent judgment about your research question. Your job is direction and verification.

**You are the PI. The agent is the lab tech.**

The key skill shift: from *learning to code* to *learning to supervise*.

---

## What I've Used It For

- **Data collection:** Web scraping job postings, searching faculty across departments
- **Survey research:** Survey data analysis (Korean social survey, GSS), simulating survey responses, integrating LLMs into Qualtrics
- **Text & network analysis:** Fanfiction corpus, LLM embeddings, belief networks, ego-centric networks
- **Tools & teaching:** Building a data exploration web app, research methods course prep

---

## The Workflow

### 1. Plan
Tell the agent **what** and **why** (not how). Review its plan. Revise.

### 2. Execute
Agent writes code, runs it, checks output autonomously.

### 3. Validate
Verify results, get second opinions, create audit trail.

If you can write a clear methodology section, you can direct an agent.

---

## Planning: The Most Important Phase

**Vague plan (bad):**
> 1. Clean the data
> 2. Run the regression
> 3. Make a table

**Detailed plan (good):**
> 1. Load `survey_2024.csv`, check encoding, recode 97/98/99 as NA → *verify: no coded missings remain*
> 2. Run ordered logistic regression: `health ~ parent_ed + income + age + gender + region` → *verify: model converges, proportional odds tested*
> 3. Compute average marginal effects → *verify: reasonable signs and magnitudes*
> 4. Export table to Word with 3 decimal places → *verify: renders correctly*

Spend 70% of your time planning.

---

## Execution & Verification

### Let it run
With a good plan, the agent works autonomously — reads data, writes code, runs it, checks diagnostics, fixes errors.

### Then verify
How do you know your RA did the work correctly?

- Check output against expectations
- Review the code it wrote
- Run diagnostics
- Spot-check results against hand calculations

Ask the agent for a review document: motivation, method, results, interpretation, limitations.

---

## What Agents Cannot Do

- **Cannot judge substantive significance** — runs the regression but doesn't know if the result is theoretically interesting
- **Can hallucinate logic** — may invent a parameter or misapply a method
- **Lacks institutional memory** — doesn't know *why* you chose that specific subset unless you tell it

Your expertise + agent execution = the combination that works.

*Let me show you how this works in practice.*

---

<!-- _class: lead -->

# Demo

---

## Tips

- **Plan as much as possible** — planning is cheap, re-doing is expensive
- **Specify what and why, not how** — let the agent figure out implementation
- **Ask the agent to ask you questions back** — better than writing a long prompt upfront
- **Create reusable skills** for repeated workflows
- **Always verify citations** against original sources

---

## Common Concerns

**"Is my data private?"**
API-based, not used for training. For extra privacy: use a university-provided service or team plan.

**"Can it overwrite my files?"**
Configurable. Guided Mode asks before each command. Permissive Mode runs pre-approved commands but blocks dangerous operations.

**"How do I know the code is correct?"**
Review output, run diagnostics, get independent second opinions from other AIs.

---

<!-- _class: lead -->

# Get Started

`github.com/letitbk/claude-academic-setup`
`bash install.sh` → ready in 15 minutes

Thank you — questions?
