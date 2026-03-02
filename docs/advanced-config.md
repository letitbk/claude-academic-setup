# Advanced Configuration

This guide covers configuration beyond the default install: permissive mode, MCP servers, settings internals, context management, and custom agents.

---

## 1. Permissive Mode

The default install uses **safe settings**: Claude asks before running shell commands (`acceptEdits` mode). This is the right default for most work.

For autonomous workflows where you want Claude to execute without prompting, copy the permissive settings:

```bash
cp settings-permissive.json ~/.claude/settings.json
```

### What changes

| Setting | Default | Permissive |
|---------|---------|------------|
| `defaultMode` | `acceptEdits` | `autoApprove` |
| `skipDangerousModePermissionPrompt` | `false` | `true` |

- **`acceptEdits`** -- Claude can read files freely but asks before writing or running commands.
- **`autoApprove`** -- Claude executes all pre-approved commands without asking.
- **`skipDangerousModePermissionPrompt`** -- Suppresses the warning dialog when entering auto-approve mode. Without this, Claude shows a confirmation each time you start a session in auto-approve.

### Security implications

In permissive mode, Claude will run any command matching the `permissions.allow` patterns without confirmation. The `permissions.deny` list still blocks dangerous operations (SSH keys, credentials, `sudo`, `rm -rf /`, force push, etc.), but anything not explicitly denied is fair game.

**Only use permissive mode when:**
- You are in an isolated environment (container, VM, disposable workspace)
- You fully trust the task and have reviewed what Claude will do
- You are running batch/pipeline operations that would be tedious to approve one by one

### Switching back

```bash
cp settings.json ~/.claude/settings.json
```

Or manually set `"defaultMode": "acceptEdits"` in `~/.claude/settings.json`.

---

## 2. MCP Servers

MCP (Model Context Protocol) servers extend Claude with external tools. Add them to the `mcpServers` section of `~/.claude/settings.json` or to a project-level `.mcp.json`.

### Zotero MCP (literature management)

Connects Claude to your Zotero library for searching, reading annotations, and managing references.

**Prerequisites:**
1. Install [Zotero desktop app](https://www.zotero.org/download/) and keep it running
2. Get an API key from https://www.zotero.org/settings/keys
3. Find your user ID on the same page

**Configuration:**

```json
"mcpServers": {
  "zotero": {
    "command": "npx",
    "args": ["-y", "zotero-mcp"],
    "env": {
      "ZOTERO_API_KEY": "YOUR_KEY",
      "ZOTERO_USER_ID": "YOUR_ID"
    }
  }
}
```

Once configured, Claude gains tools like `zotero_search_items`, `zotero_semantic_search`, `zotero_get_annotations`, and `zotero_get_item_fulltext`. The `lit-review` and `citation-verification` skills use these under the hood.

### paper-search-mcp (PubMed / arXiv / Semantic Scholar)

Gives Claude direct access to academic paper databases without browser automation.

```json
"mcpServers": {
  "paper-search": {
    "command": "npx",
    "args": ["-y", "paper-search-mcp"]
  }
}
```

No API keys needed for basic usage. The `/lit-search` command and `lit-review` skill rely on this server.

---

## 3. Settings Deep Dive

The `settings.json` file controls Claude Code's behavior globally. Here is what each section does.

### `env`

```json
"env": {
  "USE_BUILTIN_RIPGREP": "1"
}
```

Forces Claude to use its bundled ripgrep binary instead of any system-installed version. Avoids version mismatches.

### `permissions.allow`

Pre-approved tool patterns. Claude runs these without asking (in `autoApprove` mode) or with a quick confirmation (in `acceptEdits` mode).

Categories in the default config: file ops (`Read`, `Edit`, `Write`), Node/JS (`npm`, `npx`, `node`, `yarn`, `pnpm`), git (status, diff, log, add, commit, push), shell reads (`ls`, `cat`, `find`, `grep`, `rg`), Python (`python3`, `pip install`), R (`Rscript`, `R CMD`, `renv::`), Stata (`stata`, `stata-mp`), build tools (`make`, `snakemake`, `docker`), publishing (`quarto`, `pandoc`, `latexmk`), and web fetch for select domains (GitHub, npm, Python docs, MDN, StackOverflow, Crossref, Google Scholar).

### `permissions.deny`

Hard blocks. These override `allow` and cannot be bypassed. Covers secrets (`.ssh/*`, `.env`, `*credentials*`, `*.pem`, `*.key`), destructive commands (`sudo`, `rm -rf /`, `dd`, `mkfs`, `shutdown`, `chmod 777`), dangerous git (`push --force`), and Docker cleanup (`docker rm -f`, `docker system prune`).

### `permissions.defaultMode`

- **`acceptEdits`** -- Claude can read files but asks before writes and shell commands. Recommended default.
- **`autoApprove`** -- Claude executes all allowed operations without confirmation.

### `hooks`

Two hooks are configured:

**Stop hook** (`check-docs-update.sh`): Runs after Claude finishes responding. Scans the transcript for source file modifications and prompts you to update documentation if significant work was done.

**PostToolUse hook** (Write/Edit validation): Runs after every file write or edit. Validates:
- `.json` files: parsed with `python3 -c "import json; json.load(...)"`
- `.R` files: syntax-checked with `R --no-save -e "parse(...)"`
- `.yml`/`.yaml` files: parsed with `python3 -c "import yaml; yaml.safe_load(...)"`

If validation fails, Claude sees the error and can fix it immediately.

### `enabledPlugins`

Active Claude Code plugins. The default config enables 16 plugins including context7 (documentation lookup), github (PR/issue management), playwright (browser automation), code-review, and others.

### `alwaysThinkingEnabled`

When `true`, Claude uses extended thinking (chain-of-thought) for every response. Improves quality on complex reasoning tasks but uses more tokens. Disable for simple tasks to save cost.

---

## 4. Context Management

Claude Code sessions have a finite context window. Managing it well is the difference between productive sessions and confused ones.

### Key commands

- **`/compact`** -- Compresses conversation history, reclaiming working memory. Use when Claude starts forgetting earlier context or when you see token warnings. The compressed summary preserves key decisions and file locations.
- **`/clear`** -- Full reset. Use when switching to an unrelated topic. Cheaper than fighting stale context.

### Model selection

- **Sonnet** -- Default for most tasks. Fast, cost-effective, handles code generation and analysis well.
- **Opus** -- Use for complex multi-step reasoning, architecture decisions, or subtle bugs. Higher cost but significantly better at nuanced tasks.
- **Haiku** -- Use for simple lookups, formatting, or mechanical tasks. Fastest and cheapest.

### Token monitoring

Track your usage with:
- [ccusage CLI](https://github.com/ryoppippi/ccusage) -- Command-line token tracking
- Claude Code Usage Monitor -- Built-in usage display

### Session hygiene

- **Start new sessions for unrelated tasks.** Context from a data analysis session will confuse a paper-writing session.
- **CLAUDE.md is persistent memory.** Put project-specific conventions, file locations, variable naming rules, and important decisions in your project's CLAUDE.md. This persists across sessions -- conversation context does not.
- **Front-load context.** If Claude needs to know about specific files, mention them early. Referencing a file by name triggers Claude to read it.

---

## 5. Custom Agents (Advanced)

### Built-in agents cover most needs

Claude's Task tool already includes specialized agent types. This setup ships 32 agents (statistical-analyst, causal-inference, literature-scout, methods-writer, etc.) that cover the common academic research workflows. Start with these before building your own.

### Creating custom agents

If you need domain-specific behavior not covered by the built-ins, create `.md` files in `~/.claude/agents/`:

```markdown
---
name: meta-analysis-specialist
description: Conducts meta-analyses following PRISMA guidelines
---

You are a meta-analysis specialist. You follow PRISMA 2020 guidelines.

When asked to conduct a meta-analysis:
1. Define inclusion/exclusion criteria
2. Search for studies using available MCP tools
3. Extract effect sizes and standard errors
4. Fit random-effects models using R metafor package
5. Generate forest plots and funnel plots
6. Assess publication bias with Egger's test
```

### How agents work

- Each agent runs as an isolated sub-process with its own context window.
- Agents can use the same tools as the main Claude session.
- The main session can delegate work to agents via the Task tool.
- Agents do not share context with each other or with the main session beyond their return value.

### Guidance

- **Start without custom agents.** The 32 built-in agents handle most academic workflows.
- **Add agents for repeated specialized tasks** that require specific domain knowledge or multi-step protocols.
- **Keep agent instructions short and procedural.** Long prose instructions waste the agent's context window.
