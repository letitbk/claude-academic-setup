---
name: gemini
description: Web search, URL analysis, and multi-source synthesis using Gemini CLI. Use for online research, fetching and analyzing web pages, combining web search with local files, and synthesizing information from multiple sources.
---

# Gemini Web Search & Research Skill

Use Google's Gemini CLI for web search, URL deep-dive analysis, and multi-source synthesis. This provides grounded web search with source citations.

## When to Use This Skill

Trigger when user:
- Uses `/gemini` command explicitly
- Asks to "search the web" or "look up online"
- Wants to analyze or summarize a URL/webpage
- Needs to synthesize information from multiple sources
- Asks "what does the web say about..."
- Wants to combine local files with web research
- Requests "find information about..." or "research..."

## Prerequisites

Gemini CLI must be installed and authenticated:
```bash
# Check installation
which gemini

# Verify authentication
gemini --version
```

## Workflow

### Step 1: Ask User for Mode

**ALWAYS ask the user which mode to use:**

Use AskUserQuestion with these options:

1. **Web Search** - Search the web for a topic/question
2. **URL Deep-Dive** - Fetch and analyze a specific URL
3. **Multi-Source Synthesis** - Search multiple topics and synthesize findings
4. **Local + Web** - Combine local file(s) with web search

### Step 2: Gather Input

Based on mode, collect:

| Mode | Required Input |
|------|----------------|
| Web Search | Search query/question |
| URL Deep-Dive | URL + question about content |
| Multi-Source Synthesis | Multiple topics/questions to research |
| Local + Web | File path(s) + search query |

### Step 3: Execute Search

#### Mode 1: Web Search
```bash
gemini -y "Search the web and answer this question: USER_QUERY

Requirements:
- Provide a comprehensive answer based on current web sources
- Include source URLs for every major claim
- Format as clean markdown
- List all sources at the end with URLs"
```

#### Mode 2: URL Deep-Dive
```bash
gemini -y "Analyze this webpage: URL_HERE

Question: USER_QUESTION

Requirements:
- Extract relevant information to answer the question
- Quote key passages when helpful
- Provide source URL in your response"
```

#### Mode 3: Multi-Source Synthesis
```bash
gemini -y "Research and synthesize information on these topics:
1. TOPIC_1
2. TOPIC_2
3. TOPIC_3

Requirements:
- Search the web for each topic
- Identify key findings and themes across sources
- Note any contradictions or debates
- Provide comprehensive synthesis with source URLs for each claim
- List all sources at the end"
```

#### Mode 4: Local + Web
```bash
gemini -y --include-directories /path/to/files "Using @/path/to/local/file.ext as context, search the web to answer: USER_QUERY

Requirements:
- Ground your search in the context from the local file
- Find supporting or contrasting web sources
- Compare local content with web findings
- Include source URLs for web claims"
```

### Step 4: Output Handling

After search completes:

1. **Display results** directly to user in terminal
2. **Ask if user wants to save** to markdown file
3. If yes, save to: `gemini_search_YYYYMMDD_HHMMSS.md` in current directory

## Command Reference

### Basic Web Search
```bash
# Simple search
gemini -y "Search the web for: QUERY. Include source URLs."

# Detailed research
gemini -y "Conduct thorough web research on: TOPIC

Provide:
- Key findings (with source URLs)
- Different perspectives if they exist
- Recent developments
- Summary of sources"
```

### URL Analysis
```bash
# Summarize a webpage
gemini -y "Summarize the main points from: URL_HERE. Include the source URL."

# Answer question about URL
gemini -y "Based on URL_HERE, answer: QUESTION. Cite specific passages."

# Extract specific information
gemini -y "From URL_HERE, extract all information about: TOPIC"
```

### Multi-Source Research
```bash
# Compare sources
gemini -y "Search the web and compare different perspectives on: TOPIC

Include:
- At least 3 different sources
- Points of agreement
- Points of disagreement
- Source URLs for each perspective"

# Comprehensive research
gemini -y "Conduct comprehensive research on: TOPIC

Cover:
- Background and context
- Current state
- Key debates or issues
- Recent developments
- Future outlook
- All source URLs"
```

### Local + Web Combined
```bash
# Fact-check local document
gemini -y --include-directories /path "Using @/path/document.pdf as reference, search the web to verify the claims made. List which claims are supported, which are contradicted, and which need more evidence. Include source URLs."

# Extend local research
gemini -y --include-directories /path "Based on @/path/notes.md, search for additional recent research on these topics. What new developments exist? Include source URLs."

# Compare local vs web
gemini -y --include-directories /path "Compare the information in @/path/report.pdf with current web sources. What's consistent? What's outdated? What's missing? Include source URLs."
```

## Usage Examples

### Example 1: Web Search
```
User: /gemini

Claude asks: Which mode?
User: Web Search

Claude asks: What would you like to search for?
User: Latest developments in mRNA vaccine technology

Claude executes:
gemini -y "Search the web for the latest developments in mRNA vaccine technology (2025-2026).

Requirements:
- Focus on recent breakthroughs and clinical trials
- Include source URLs for every major claim
- Format as clean markdown
- List all sources at the end with URLs"

Claude displays results and asks: Save to file?
```

### Example 2: URL Deep-Dive
```
User: /gemini

Claude asks: Which mode?
User: URL Deep-Dive

Claude asks: What URL and what question?
User: https://example.com/article - What are the main arguments?

Claude executes:
gemini -y "Analyze this webpage: https://example.com/article

Question: What are the main arguments presented?

Requirements:
- Extract and summarize the key arguments
- Quote relevant passages
- Note the source URL"
```

### Example 3: Local + Web
```
User: /gemini

Claude asks: Which mode?
User: Local + Web

Claude asks: Which file(s) and what search query?
User: Use my paper draft.pdf to find supporting research online

Claude executes:
gemini -y --include-directories /Users/bk/docs "Using @/Users/bk/docs/draft.pdf as context, search for recent peer-reviewed research that supports or extends the findings in this paper. Include source URLs for all citations."
```

## AskUserQuestion Template

When triggered, ask:

```
Question 1: "Which search mode would you like to use?"
Options:
- Web Search (search the web for a topic)
- URL Deep-Dive (analyze a specific webpage)
- Multi-Source Synthesis (research multiple topics)
- Local + Web (combine local files with web search)
```

Then based on mode:

**Web Search:**
```
Question: "What would you like to search for?"
(Free text input)
```

**URL Deep-Dive:**
```
Question: "What URL would you like to analyze, and what's your question about it?"
(Free text input)
```

**Multi-Source Synthesis:**
```
Question: "What topics would you like to research and synthesize? (List multiple)"
(Free text input)
```

**Local + Web:**
```
Question: "Which local file(s) should I use, and what should I search for online?"
(Free text input)
```

## Output Format

All responses should include:

1. **Answer/Summary** - Main findings in clean markdown
2. **Source Citations** - URL for each major claim inline
3. **Sources List** - Complete list of URLs at the end

Example format:
```markdown
## Summary

[Main findings here with inline citations]

According to [Source Name](URL), the key finding is...

## Key Points

- Point 1 ([source](URL))
- Point 2 ([source](URL))

## Sources

1. [Title 1](URL1)
2. [Title 2](URL2)
3. [Title 3](URL3)
```

## Saving Output

When user wants to save:

1. Generate filename: `gemini_search_YYYYMMDD_HHMMSS.md`
2. Save to current working directory
3. Confirm: "Saved search results to: /path/to/gemini_search_YYYYMMDD_HHMMSS.md"

Alternative naming by topic:
- `gemini_search_[topic_slug].md`
- `gemini_url_[domain].md`
- `gemini_synthesis_[date].md`

## Error Handling

| Error | Solution |
|-------|----------|
| Not authenticated | Run `gemini` interactively to login |
| URL not accessible | Check URL is valid and publicly accessible |
| File not found | Verify file path, use `--include-directories` |
| Rate limited | Wait and retry, or reduce query complexity |
| Timeout | Break into smaller queries |

## Tips

1. **Be specific**: More specific queries get better results
2. **Request citations**: Always ask for source URLs in prompt
3. **Use local context**: Combining local files improves relevance
4. **Check recency**: Ask for recent sources when timeliness matters
5. **Verify sources**: Cross-reference important claims across sources

## Limitations

- Requires internet connection and Google AI access
- Web search results depend on Gemini's search capabilities
- Some URLs may be blocked or inaccessible
- Rate limits apply (check Google AI quota)
- Very long documents may need chunked processing
- Cannot access paywalled content
