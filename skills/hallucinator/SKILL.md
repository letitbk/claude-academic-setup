---
name: hallucinator
description: Use when checking whether academic citations in a PDF, .bib, or .bbl are real, triaging possible hallucinated references, or when the user says "check references", "verify citations", "hallucination check", or "are these references real".
---

# Hallucinator

Check academic references against 10+ online databases using `hallucinator-cli`. Detect hallucinated, retracted, or author-mismatched citations in PDFs, `.bib`, and `.bbl` files.

## When to Use

- Check references in a PDF paper (own paper, submission review, ad-hoc)
- Validate a `.bib` or `.bbl` bibliography file
- Batch-check multiple PDFs in a directory
- Spot-check a list of citations pasted as text (converted to temp `.bib`)
- Verify discovered references are real (after finding them via web search or APIs)

## When NOT to Use

- Building offline databases — tell user to run `hallucinator-cli update-dblp` etc. directly
- Extract-only without verification — use `hallucinator-cli check --dry-run` directly
- Non-academic references (URLs, blog posts, news articles, software citations)
- Image-only / non-searchable PDFs — hallucinator can't extract text; will return 0 references
- General literature search or discovery — this tool **verifies**, it does not discover

## Workflow

### Phase 0: Pre-flight

Before running any check:

If `hallucinator-cli` is missing, tell the user to install it with `curl -sSf https://hallucinator.science/install-cli.sh | sh` (see https://github.com/gianlucasb/hallucinator). Do not install it yourself.

```bash
# Verify CLI is available
hallucinator-cli --version

# Verify input file exists and is valid
file "<input_path>"

# Create logs directory
mkdir -p logs
```

**Check API key availability.** Warn if neither `OPENALEX_KEY` env var nor `~/.config/hallucinator/config.toml` exists — results will be limited to databases that don't require keys (CrossRef, arXiv, DBLP, ACL, NeurIPS, Europe PMC, PubMed).

```bash
# Check env vars
echo "OPENALEX_KEY: ${OPENALEX_KEY:-(not set)}"
echo "S2_API_KEY: ${S2_API_KEY:-(not set)}"

# Check config file
ls ~/.config/hallucinator/config.toml 2>/dev/null || echo "No config file found"
```

If `--searxng` is intended, verify `SEARXNG_URL` is set or that `localhost:8080` is reachable:
```bash
echo "SEARXNG_URL: ${SEARXNG_URL:-(not set, will default to localhost:8080)}"
```

### Phase 1: Check Single File

Core command template:

```bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
BASENAME=$(basename "<file>" | sed 's/[^a-zA-Z0-9._-]/_/g')

hallucinator-cli check \
  --no-color \
  --check-openalex-authors \
  --output "logs/${TIMESTAMP}_hallucinator_${BASENAME}.log" \
  "<file>"
```

**Always include:**
- `--no-color` — clean logs, reliable output parsing
- `--check-openalex-authors` — comprehensive author mismatch detection
- `--output` — captures results to `logs/` per CLAUDE.md section 5

**Add when needed:**
| Flag | When |
|------|------|
| `--json "logs/${TIMESTAMP}_hallucinator_${BASENAME}.json"` | Programmatic analysis, batch reporting |
| `--searxng` | SearxNG is available for web search fallback |
| `--num-workers 2` | Hitting rate limits frequently |
| `--disable-dbs=CSV` | Skip specific databases |

After running, read the output log to interpret results (see Phase 4).

### Phase 2: Batch Check

For multiple PDFs, use a shared cache to avoid redundant queries:

```bash
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
CACHE="logs/${TIMESTAMP}_hallucinator_cache.sqlite"

for f in <directory>/*.pdf; do
  BASENAME=$(basename "$f" | sed 's/[^a-zA-Z0-9._-]/_/g')
  hallucinator-cli check \
    --no-color \
    --check-openalex-authors \
    --cache-path "$CACHE" \
    --output "logs/${TIMESTAMP}_hallucinator_${BASENAME}.log" \
    --json "logs/${TIMESTAMP}_hallucinator_${BASENAME}.json" \
    "$f"
done
```

- `--cache-path` is critical — avoids re-querying shared citations across papers
- `--json` for batch runs enables cross-file summary from structured data
- To refresh stale "not found" entries: `--clear-not-found`

### Phase 3: Text Citations

When the user provides citations as text (not in a file):

1. Parse citations into minimal BibTeX format in `/tmp`:

```bibtex
@article{ref1,
  author = {LastName, FirstName and LastName2, FirstName2},
  title = {The Exact Title As Given},
  year = {2023},
  journal = {Journal Name}
}
```

Minimum required: `title` and `author`. Include `year` and `journal`/`booktitle` when available for better matching.

2. Write to `/tmp/hallucinator_check_TIMESTAMP.bib`
3. Run `hallucinator-cli check` on that file (same flags as Phase 1)
4. Clean up: `rm /tmp/hallucinator_check_*.bib`

### Phase 4: Interpret Results

Results fall into three layers. Work through them in order.

**Layer 1 — Execution failures**

CLI not found, file missing, config/env problem, network errors, rate limiting (429s). Fix these before interpreting any results.

**Layer 2 — Extraction issues**

Skipped references (URLs, titles <5 words) and uncheckable entries (malformed citations). If 0 references extracted from a PDF, the file is likely image-only or has non-standard formatting — try `.bib`/`.bbl` source instead. Report skip count and reasons.

**Layer 3 — Verification verdicts**

| Verdict | Meaning | Action |
|---------|---------|--------|
| Verified | Found in DB with matching authors | No action needed. Note source database. |
| Author Mismatch | Title found, authors differ | Investigate: name variants (initials, transliteration, "et al." truncation), editor vs author, consortium names. Check DOI/URL. Often benign. |
| Not Found | Not in any database | Triage below. NOT automatic proof of hallucination. |
| Retracted | Found but flagged as retracted | Do NOT cite. Check Retraction Watch for details. Recommend replacement source. |
| Web Search | Title found on web only | Weakest signal. No author verification. Always requires manual confirmation. |

**"Not Found" triage (follow in order):**

1. **Check extraction** — was the citation parsed correctly? Run `--dry-run` to inspect extracted title/authors
2. **Try better source** — if PDF extraction is poor, use `.bib`/`.bbl` instead
3. **Check recency** — if published <3 months ago, may not be indexed yet
4. **Check language** — non-English metadata has lower recall across all databases
5. **Clear stale cache** — run with `--clear-not-found` if cache may be outdated
6. **Manual search** — check Google Scholar directly
7. **Flag as likely hallucinated** — only after exhausting steps 1-6

For each flagged citation, report:
- Raw citation text
- Normalized title / authors / year (if extracted)
- Matched source database (if any)
- Confidence level (high/medium/low concern)
- Recommended next action

## Reporting

Present results in this order:

1. **Summary line**: "Checked N references: X verified, Y not found, Z author mismatch, W retracted, V web-only, S skipped"
2. **Problems first**: Not Found and Retracted items with full citation text
3. **Warnings**: Author Mismatch and Web Search items
4. **Clean**: Note verified count (no need to list each unless asked)
5. **Log location**: Point to the output file path

For batch runs, also provide a cross-file summary table.

## Secondary Workflow: Discover + Verify

Hallucinator-cli **verifies** — it does not discover references. For finding papers by person or topic:

1. Use web search, Semantic Scholar API, or OpenAlex API to find candidate papers
2. Compile results into a `.bib` file
3. Run `hallucinator-cli check` on the `.bib` to verify they're real
4. Report verified references with DOIs/URLs

## Quick Reference

| Task | Command |
|------|---------|
| Check single PDF | `hallucinator-cli check --no-color --check-openalex-authors --output out.log paper.pdf` |
| Check .bib file | `hallucinator-cli check --no-color --check-openalex-authors refs.bib` |
| Batch with cache | `hallucinator-cli check --cache-path cache.sqlite --no-color paper.pdf` |
| Dry run (parse only) | `hallucinator-cli check --dry-run paper.pdf` |
| JSON export | `hallucinator-cli check --json results.json paper.pdf` |
| Clear stale cache | `hallucinator-cli check --clear-not-found --cache-path cache.sqlite` |
| With web search | `hallucinator-cli check --searxng --no-color paper.pdf` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Running without `--no-color` | Logs contain ANSI codes. Always use `--no-color`. |
| Forgetting `--check-openalex-authors` | Misses OpenAlex author mismatches. Always include. |
| No `--cache-path` for batch runs | Redundant API queries. Share one cache per batch. |
| Treating "Not Found" as definitive hallucination | Follow triage steps. Could be new, obscure, or non-English. |
| Treating "Web Search" as verified | Weakest signal. Requires manual confirmation. |
| Missing `SEARXNG_URL` when using `--searxng` | Check env var first; default localhost:8080 may not be running. |
| Image-only PDF producing 0 references | Verify text is extractable before running. Use `.bib` source instead. |
| Stale "not found" results in cache | Use `--clear-not-found` to refresh cached negative results. |
| Not saving output | Use `--output` flag. CLAUDE.md section 5 requires reproducible evidence. |
