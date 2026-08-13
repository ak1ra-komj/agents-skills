---
name: commit-and-summarize
description: Use when the user asks to commit changes and/or summarize the current session - or when wrapping up a conversation that involved code or file edits.
---

# commit-and-summarize

Commit all relevant changes and write a session log as a single coordinated workflow.

## Overview

When wrapping up a session, this skill:

1. Commits work changes with clean commit messages.
2. Summarizes what was done and writes a session log to `.agents/sessions/`
   using the resulting commit IDs. The session log is written locally only and
   is not committed to git.

---

## Phase 1 - Commit work changes

Commit only files that were modified or created during this conversation.
You MUST NOT stage unrelated changes. Do not commit the session log written
in Phase 2.

If the changes span clearly distinct features or modules, split them into
multiple commits - but only do so when it adds genuine clarity. Use a
single commit for small or cohesive changes.

### Steps

1. Identify which files were changed or added in this conversation, excluding
   the session log that will be written in Phase 2.
2. Stage only those files (`git add <files>`).
3. Write commit messages following the style guide below.
4. Run `git commit -m "<subject>"` (or with `-m` body if needed).
5. Keep the resulting commit IDs available for the session log.

### Commit message style

- The subject line SHOULD follow Conventional Commits style.
- The subject line MUST be 50 characters or fewer.
- The subject line MUST NOT start with a capital letter.
- The subject line MUST NOT end with punctuation.
- The subject line MUST use the imperative mood.
- Add a body only when it provides useful context not already in the subject.
- The body MUST be separated from the subject by a blank line and MUST be wrapped at 72 characters.
- The commit message MUST NOT include the raw diff.

---

## Phase 2 - Write the session log

1. Review the full conversation to identify all changes made, problems solved,
   and decisions taken.
2. Run `date +%Y-%m-%d` in a terminal to get today's date.
3. Run `git log --oneline` (or `git log --oneline <range>`) to collect the work
   commits made during the session.
4. Derive a short English session title from the session content.
5. Write the file to `.agents/sessions/YYYY-MM-DD-<session-title>.md`.

### File naming

```
YYY-MM-DD-<session-title>.md
```

- Date: obtained from `date +%Y-%m-%d` - you MUST NOT guess or hardcode it.
- `<session-title>`: a short English phrase summarising the session, words
  joined with `-` (e.g. `add-liveness-probe-action-threshold`).

### File structure

#### H1 - Session title

One sentence describing what the session accomplished.

#### H2 - Summary

One paragraph covering: background / motivation, the problem or request,
the approach taken, and the outcome.

#### H2 - Changed files

A list of every file touched during the session. For each file include:

- The file path (as a relative path from the project root)
- A one-line description of what changed and why

#### H2 - Git commits

List every commit made during the session in the format:

```
- `a1b2c3d` <commit message>
```

Use the short hash (`git log --oneline`). Include the work commits
created before the session log was written. If no commits were made during the
session, write: "No commits were made in this session."

#### H2 - Notes

Distil the most reusable or noteworthy insights from the session, such as:

- Reusable patterns or best practices discovered
- Mistakes made and how to avoid them in future
- Non-obvious design decisions and their rationale
- Anything a future agent or developer should know before touching the same code

### Style rules

- Write in **English** throughout.
- Keep each section concise; prefer bullet lists over prose.
- The "Notes" section is high-value and MUST NOT be empty.
- Retrieve dates with `date +%Y-%m-%d` and MUST NOT hardcode them.
- Output SHOULD NOT use emoji, em dashes, or excess bold/italic text.
- Output SHOULD be plain Markdown (no HTML) and use only ASCII punctuation.
- When session facts cannot be determined from the conversation, git history,
  or the working tree, output MUST NOT guess; instead state "Insufficient information".
