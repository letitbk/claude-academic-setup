# Which models and agents to use

Brainstorming and planning need your most advanced model, because every later step depends on the plan. Carrying out a clear plan takes less reasoning, so a cheaper model can do that part. So I change the model for each stage of the work. Claude Code and Codex have a `/model` command, and the [guide](getting-started.md#choose-a-model-for-each-step) shows how to use it. In the Antigravity CLI, `agy models` lists your models.

| Work | Claude Code | Codex | Antigravity CLI |
|---|---|---|---|
| Brainstorming, planning, and review | Opus 5.5 | GPT-6 Astra | Gemini 4 Argon |
| Carrying out a plan | Sonnet 5.5 | GPT-6.1 Sol | Gemini 3.8 Flash |

I also use two agents from different companies, for the reason in [problem 2](why-this-setup.md#2-did-the-agent-do-the-work-and-does-the-plan-cover-everything). If you can pay for two plans, two plans at $20 serve you better than one. A plan is a file in the project, so after one agent writes it, the other agent can review it or carry it out.

| Monthly cost | Plans | What you get |
|---|---|---|
| $20 | [Claude Pro](https://claude.com/pricing) or [ChatGPT Plus](https://chatgpt.com/pricing) | One agent, with no review from another company |
| $40 | Claude Pro and ChatGPT Plus | Two agents, so one can plan and the other can review or carry out the plan |
| $120 | [Claude Max](https://claude.com/pricing) and ChatGPT Plus | What I use. Claude Max has five times the usage of Claude Pro. |

From my experience, $100 for Claude and $20 for Codex is the best mix. Claude Code with Opus 5.5 is my default, and I use it instead of Sonnet to work out the plan and direct the work. Codex or Sonnet 5.5 then carries out the plan. Most empirical academic projects do not need Fable 5.1, unless the project has a hard math problem to solve.

The Antigravity CLI, which runs `/agy` reviews, is a useful third reviewer. It works without a paid plan on a smaller weekly quota, with Gemini 3.8 Flash but not Gemini 4 Argon. [Google AI Pro](https://one.google.com/about/google-ai-plans/) costs about $20 a month and adds Gemini 4 Argon and higher limits. [Google AI Studio](https://aistudio.google.com/) is a separate tool that is free to start, and you can use it to try Gemini models in a browser.

These are US prices from November 2026, and model names change often, so check each plan page before you pay. Run `/model` to see what your plan offers.
