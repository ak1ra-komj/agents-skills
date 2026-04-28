---
name: commit-and-summarize
description: Use when the user asks to commit changes and/or summarize the current session - or when wrapping up a conversation that involved code or file edits.
---

# commit-and-summarize

Commit all relevant changes, write a session log, and optionally commit that
log - as a single coordinated workflow.

## Overview

When wrapping up a session, this skill:

1. Commits work changes with clean commit messages.
2. Summarizes what was done and writes a session log to `.agents/state/sessions/`
   using the resulting commit IDs.
3. Commits the session log file in a **separate** commit - but only when it is
   not excluded by `.gitignore`.

---

## Phase 1 - Commit work changes

You MUST commit only files that were modified or created during this conversation.
You MUST NOT stage unrelated changes.

If the changes span clearly distinct features or modules, split them into
multiple commits - but only do so when it adds genuine clarity. You MAY use a
single commit for small or cohesive changes.

### Steps

1. Identify which files were changed or added in this conversation, excluding
   the session log that will be written in Phase 2.
2. Stage only those files (`git add <files>`).
3. Write commit messages following the style guide below.
4. Run `git commit -m "<subject>"` (or with `-m` body if needed).
5. Keep the resulting commit IDs available for the session log.

### Commit message style

- The subject line SHOULD follow Conventional Commits style
- The subject line MUST be 50 characters or fewer
- The subject line MUST NOT start with a capital letter
- The subject line MUST NOT end with punctuation
- The subject line MUST use the imperative mood
- You MAY add a body only when it provides useful context not already in the subject
- The body MUST be separated from the subject by a blank line and wrapped at 72 characters
- The commit message MUST NOT include the raw diff

---

## Phase 2 - Write the session log

1. Review the full conversation to identify all changes made, problems solved,
   and decisions taken.
2. Run `date +%Y-%m-%d` in a terminal to get today's date.
3. Run `git log --oneline` (or `git log --oneline <range>`) to collect the work
   commits made during the session.
4. Derive a short English session title from the session content.
5. Write the file to `.agents/state/sessions/YYYY-MM-DD-<session-title>.md`.

### File naming

```
YYYY-MM-DD-<session-title>.md
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

Use the short hash (`git log --oneline`). You MUST include the work commits
created before the session log was written. If the session log itself is later
committed in Phase 3, you MUST NOT include that log-only commit in this
section. If no commits were made during the session, write: "No commits were
made in this session."

#### H2 - Notes

Distil the most reusable or noteworthy insights from the session, such as:

- Reusable patterns or best practices discovered
- Mistakes made and how to avoid them in future
- Non-obvious design decisions and their rationale
- Anything a future agent or developer should know before touching the same code

### Style rules

- You MUST write in **English** throughout.
- You SHOULD keep each section concise and prefer bullet lists over prose.
- The "Notes" section is high-value and MUST NOT be empty.
- You MUST retrieve dates with `date +%Y-%m-%d` and MUST NOT hardcode them.
- Output SHOULD NOT use emoji, em dashes, or excess bold/italic text.
- Output SHOULD be plain Markdown (no HTML) and use only ASCII punctuation.
- When session facts cannot be determined from the conversation, git history,
  or the working tree, output MUST NOT guess; instead state "Insufficient information".

---

## Phase 3 - Commit the session log (conditional)

Before committing the session log, check whether that path is ignored by git:

```sh
git check-ignore -v .agents/state/sessions/
```

- **If `.agents/state/sessions/` is excluded by `.gitignore`**: you MUST NOT stage or commit
  the session log. You MUST inform the user that the file was written locally but not
  committed due to the ignore rule.
- **If `.agents/state/sessions/` is not ignored**: you MUST stage **only** the session
  log file and create a separate commit for it. You MUST NOT mix it with the work
  changes from Phase 1, and you MUST NOT go back and add this log-only commit to the
  session log.

Suggested commit message for the session log:

```
docs: add session log YYYY-MM-DD-<session-title>
```
