Search across all your Claude Code conversation history for: $ARGUMENTS

## Multi-Source Prompt Search

Search through your Claude Code conversation history using multiple methods to find relevant prompts, discussions, and insights.

### Database Search (SQLite)
First, search the main conversation database:

```bash
# Search user messages for keywords
sqlite3 ~/.claude/__store.db "
SELECT 
    b.session_id,
    datetime(b.timestamp, 'unixepoch') as date,
    substr(u.message, 1, 100) as preview
FROM user_messages u 
JOIN base_messages b ON u.uuid = b.uuid 
WHERE u.message LIKE '%$ARGUMENTS%' 
ORDER BY b.timestamp DESC 
LIMIT 10;"
```

### Project History Search (JSON)
Search through project-specific conversation history:

```python
import json
import re
from datetime import datetime

def search_project_history(search_term):
    try:
        with open('/Users/YOUR_USERNAME/.claude.json', 'r') as f:
            data = json.load(f)
        
        results = []
        if 'projects' in data:
            for project_path, project_data in data['projects'].items():
                if 'history' in project_data:
                    for i, item in enumerate(project_data['history']):
                        text = ""
                        if isinstance(item, dict) and 'display' in item:
                            text = item['display']
                        elif isinstance(item, str):
                            text = item
                        
                        if search_term.lower() in text.lower():
                            results.append({
                                'project': project_path.split('/')[-1],
                                'index': i,
                                'text': text[:200] + "..." if len(text) > 200 else text,
                                'relevance': text.lower().count(search_term.lower())
                            })
        
        # Sort by relevance
        results.sort(key=lambda x: x['relevance'], reverse=True)
        return results[:15]  # Top 15 results
    
    except Exception as e:
        return [{'error': f"Search failed: {e}"}]

# Execute search
results = search_project_history("$ARGUMENTS")
for result in results:
    if 'error' in result:
        print(f"❌ {result['error']}")
    else:
        print(f"📁 Project: {result['project']}")
        print(f"🔢 Relevance: {result['relevance']} matches")
        print(f"💬 Text: {result['text']}")
        print("---")
```

### Session-Based Search
Find and resume specific conversation sessions:

```bash
# Get recent sessions with context
sqlite3 ~/.claude/__store.db "
SELECT DISTINCT 
    b.session_id,
    datetime(MIN(b.timestamp), 'unixepoch') as start_date,
    datetime(MAX(b.timestamp), 'unixepoch') as end_date,
    COUNT(*) as message_count,
    b.cwd as working_directory
FROM base_messages b
GROUP BY b.session_id 
ORDER BY MAX(b.timestamp) DESC 
LIMIT 10;"
```

### Advanced Pattern Search
Search for complex patterns and contexts:

```python
import re

def advanced_prompt_search(pattern, context_words=5):
    """
    Search for regex patterns with surrounding context
    """
    # This would search through conversation files
    # and return matches with surrounding context
    
    search_patterns = [
        r'(?i)' + re.escape("$ARGUMENTS"),  # Case insensitive exact match
        r'(?i).*' + re.escape("$ARGUMENTS") + r'.*',  # Contains term
        r'(?i)\b' + re.escape("$ARGUMENTS") + r'\b',  # Whole word match
    ]
    
    print(f"🔍 Searching for patterns related to: '$ARGUMENTS'")
    print(f"📝 Including {context_words} words of context around matches")
    
    # Implementation would search through all conversation sources
    return "Advanced search results would appear here"

advanced_prompt_search("$ARGUMENTS")
```

### Conversation Summary Search
Search through conversation summaries for high-level topics:

```bash
# Search conversation summaries
sqlite3 ~/.claude/__store.db "
SELECT 
    cs.summary,
    datetime(cs.updated_at, 'unixepoch') as last_updated
FROM conversation_summaries cs
WHERE cs.summary LIKE '%$ARGUMENTS%'
ORDER BY cs.updated_at DESC;"
```

### Temporal Search
Find conversations from specific time periods:

```bash
# Search conversations from last 7 days
sqlite3 ~/.claude/__store.db "
SELECT 
    b.session_id,
    datetime(b.timestamp, 'unixepoch') as date,
    substr(u.message, 1, 150) as preview
FROM user_messages u 
JOIN base_messages b ON u.uuid = b.uuid 
WHERE u.message LIKE '%$ARGUMENTS%' 
AND b.timestamp > strftime('%s', 'now', '-7 days')
ORDER BY b.timestamp DESC;"
```

### Resume Relevant Sessions
After finding relevant conversations, resume them:

```bash
# Resume a specific session (replace SESSION_ID)
claude --resume SESSION_ID

# Or use interactive session selector
claude --resume
```

## Search Strategy

1. **Start Broad**: Use general keywords related to your topic
2. **Narrow Down**: Add specific terms or use regex patterns  
3. **Time Context**: Filter by recent conversations if looking for current projects
4. **Project Context**: Focus on specific project histories if relevant
5. **Session Resume**: Use session IDs to continue relevant conversations

## Output Format

```
🔍 PROMPT SEARCH RESULTS for: "$ARGUMENTS"

📊 SUMMARY
- Database matches: X results
- Project history matches: Y results  
- Session matches: Z sessions

🎯 TOP MATCHES
[Ranked list of most relevant conversations]

📅 RECENT DISCUSSIONS
[Time-ordered recent mentions]

🔗 RESUMABLE SESSIONS
- Session ID: abc123 | Date: 2024-01-15 | Context: "Working on ML pipeline"
- Use: claude --resume abc123

💡 RELATED TOPICS
[Automatically detected related search terms]
```

## Usage Tips

- Use **quotation marks** for exact phrase searches
- Try **variations** of your search terms (plurals, synonyms)
- Search for **project names** to find all related conversations
- Use **technical terms** that are unique to your domain
- Combine with **time filters** for recent vs. historical discussions

Execute comprehensive prompt search starting with database query, then expanding to project histories and conversation summaries.
