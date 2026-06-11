# summarize-current-chat

Summarize everything done in the current conversation and output the result
directly as a Markdown document in the chat. No files are created; the output
is meant to be copied and saved manually by the user.

This is designed for web chat interfaces (e.g. ChatGPT Pro) where no file system
or terminal access is available. For agent environments with filesystem access,
use the `commit-and-summarize` skill instead.

## Workflow

1. Review the full conversation to identify all changes made, problems solved,
   and decisions taken.
2. Use today's date as shown in the conversation context, or state the date as
   "unknown" if it cannot be determined - do not guess or fabricate it.
3. Derive a short English session title from the session content.
4. Produce the full Markdown document inline in your response.

## Output format

Output a single fenced Markdown code block (` ```markdown `)
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

If no files were changed, write: "No files were changed in this session."

### H2 - Notes

Distil the most reusable or noteworthy insights from the session, such as:

- Reusable patterns or best practices discovered
- Mistakes made and how to avoid them in future
- Non-obvious design decisions and their rationale
- Anything a future agent or developer should know before touching the same code

## Style rules

- Write in **English** throughout.
- Keep each section concise; prefer bullet lists over prose.
- The "Notes" section is high-value - do not leave it empty.
- Do not include a "Git commits" section - terminal access is unavailable in
  web chat mode; omit it entirely rather than leaving it empty or guessing.
- Do not use emoji, em dashes, or excess bold/italic text.
- Use plain Markdown (no HTML) and only ASCII punctuation.
- When uncertain, do not guess; instead state "Insufficient information".
