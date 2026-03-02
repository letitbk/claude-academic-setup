# Advanced Configuration

This guide covers configuration beyond the default install: safe mode, MCP servers, settings internals, and context management.

---

## 1. Safe Mode

The default install uses **permissive settings**: Claude executes pre-approved commands without prompting. Dangerous operations (SSH keys, credentials, `sudo`, `rm -rf /`, force push) are still blocked by the deny list.

If you prefer Claude to ask before running shell commands, copy the safe settings:

```bash
cp settings-safe.json ~/.claude/settings.json
```

### What changes

Both configurations use `defaultMode: "acceptEdits"` — Claude reads and edits files freely, and executes shell commands that match the `permissions.allow` patterns (git, Python, R, Stata, npm, etc.) without asking. Commands NOT in the allow list still require confirmation.

| Setting | Default | Safe |
|---------|---------|------|
| `skipDangerousModePermissionPrompt` | `true` | `false` |

The only difference is the startup warning:
- **Default (`true`)** -- Claude starts immediately without a "dangerous mode" confirmation dialog. Practical for daily use since the deny list already blocks destructive operations.
- **Safe (`false`)** -- Claude shows a warning dialog each time you start a session, reminding you that commands will be auto-executed. Useful if you want a deliberate opt-in each session.

### Security notes

In the default permissive mode, Claude will run any command matching the `permissions.allow` patterns without confirmation. The `permissions.deny` list still blocks dangerous operations, but anything not explicitly denied is executed automatically.

**Consider switching to safe mode when:**
- You are working with sensitive data or production systems
- You want to review each command before execution
- You are unfamiliar with what Claude might do for a given task

### Switching back to permissive

```bash
cp settings.json ~/.claude/settings.json
```

Or manually set `"skipDangerousModePermissionPrompt": true` in `~/.claude/settings.json`.

---

## 2. MCP Servers

MCP (Model Context Protocol) servers extend Claude with external tools. Add them to the `mcpServers` section of `~/.claude/settings.json` or to a project-level `.mcp.json`.

### [Zotero MCP](https://github.com/54yyyu/zotero-mcp) (literature management)

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

### [paper-search-mcp](https://github.com/openags/paper-search-mcp) (PubMed / arXiv / Semantic Scholar)

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

Active Claude Code plugins. The default config enables 14 plugins including context7 (documentation lookup), github (PR/issue management), playwright (browser automation), code-review, and others.

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
- [Claude Code Usage Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor) -- Browser-based usage dashboard

### Session hygiene

- **Start new sessions for unrelated tasks.** Context from a data analysis session will confuse a paper-writing session.
- **CLAUDE.md is persistent memory.** Put project-specific conventions, file locations, variable naming rules, and important decisions in your project's CLAUDE.md. This persists across sessions -- conversation context does not.
- **Front-load context.** If Claude needs to know about specific files, mention them early. Referencing a file by name triggers Claude to read it.

