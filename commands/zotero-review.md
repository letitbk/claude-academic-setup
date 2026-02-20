Analyze Zotero collection: $ARGUMENTS

Use Zotero MCP tools to retrieve all items in the specified collection (zotero_get_collections to find the collection key, then zotero_get_collection_items to get items).

For the collection, provide:
1. **Overview:** Total items, date range, top authors, most common journals
2. **Thematic clusters:** Group papers by topic/theme based on titles and abstracts
3. **Key findings:** Summarize the main conclusions across papers (use zotero_get_item_fulltext for available full texts)
4. **Gaps:** What topics or perspectives are underrepresented?
5. **Suggested additions:** Based on the collection's focus, recommend papers or search terms to fill gaps

If the user provides a topic instead of a collection name, search for matching collections first. If no collection matches, search the full library instead.
