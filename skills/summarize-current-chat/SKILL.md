---
name: summarize-current-chat
description: Use when the user asks to summarize this session or chat - and the conversation is happening in a web chat interface (e.g. ChatGPT Pro) where no file system or terminal access is available.
---

# summarize-current-chat

Summarize everything done in the current conversation and output the result
directly as a Markdown document in the chat. No files are created; the output
is meant to be copied and saved manually by the user.

## Workflow

1. Review the full conversation to identify all changes made, problems solved,
   and decisions taken.
2. Use today's date as shown in the conversation context, or state the date as
   "unknown" if it cannot be determined - you MUST NOT guess or fabricate it.
3. Derive a short English session title from the session content.
4. Produce the full Markdown document inline in your response.

## Output format

You MUST output a single fenced Markdown code block (` ```markdown `)
containing the complete document, so the user can copy it as-is.

## Document structure

### H1 - Session title

One sentence describing what the session accomplished.

### H2 - Summary

One paragraph covering: background / motivation, the problem or request,
the approach taken, and the outcome.

### H2 - Changed files

A list of every file discussed or modified during the session. For each file
include:

- The file path (as a relative path from the project root, if known)
- A one-line description of what changed and why

If no files were changed, you MUST write: "No files were changed in this session."

### H2 - Notes

Distil the most reusable or noteworthy insights from the session, such as:

- Reusable patterns or best practices discovered
- Mistakes made and how to avoid them in future
- Non-obvious design decisions and their rationale
- Anything a future agent or developer should know before touching the same code

## Style rules

- You MUST write in **English** throughout.
- You SHOULD keep each section concise and prefer bullet lists over prose.
- The "Notes" section is high-value and MUST NOT be empty.
- You MUST NOT include a "Git commits" section - terminal access is unavailable in
  web chat mode; omit it entirely rather than leaving it empty or guessing.
- Output SHOULD NOT use emoji, em dashes, or excess bold/italic text.
- Output SHOULD be plain Markdown (no HTML) and use only ASCII punctuation.
- When uncertain, output MUST NOT guess; instead state "Insufficient information".
