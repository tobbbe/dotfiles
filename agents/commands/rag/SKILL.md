---
description: Answer using Cloudflare AutoRAG "tobbe"
---

Use the Cloudflare AutoRAG MCP to answer the user's question.

Requirements:
- Use the AutoRAG with id `tobbe`.
- Use cloudflare_autorag_search as the default retrieval method.
- Use AutoRAG as the only source if not told otherwise.
- Quote or summarize the relevant source when possible.
- If the AutoRAG does not contain enough information, say so clearly.
- Do not call cloudflare_autorag_list_rags or cloudflare_autorag_accounts_list.
- Assume the active account is already persisted. Only call cloudflare_autorag_set_active_account if the AutoRAG tools report that no active account is set.

Response style:
- Answer the user's question directly in the first line. Do not mention AutoRAG, MCP, retrieval, or search unless the user asks about them or they are needed to explain a limitation.
- If the answer is uncertain or incomplete, say that plainly without filler.
- Keep the reply concise, structured and natural. Example response for question: "What is the required global ratio for members?"
```
  Required global ratio is at least `1.0`.

  Sources:
  - "We require every member to have a global ratio of at least 1.0." (rules.md)

  Related information:
  - "For all torrents you must seed for 72 hours within 30 days." (rules.md)

  (optional)
  Do you mean a different kind of ratio? I only found evidence for the global ratio requirement.
```

Question: $ARGUMENTS
