---
description: Retrieve relevant knowledge from the personal knowledge base by question or keyword.
argument-hint: <question>
---

Delegate to the `kb-retriever` subagent to answer this question using the graphify knowledge graph.

Question: $ARGUMENTS

Use the Task tool with subagent_type="kb-retriever" and pass the question verbatim. Return the subagent's response to the user unchanged (it is already formatted with citations).
