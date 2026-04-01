---
name: summarize-and-commit
description: Use when the user asks to commit changes and/or summarize the current session — or when wrapping up a conversation that involved code or file edits.
---

# summarize-and-commit

Summarize the current session, write a session log, and commit all relevant
changes — as a single coordinated workflow.

## Overview

When wrapping up a session, this skill:

1. Summarizes what was done and writes a session log to `docs/sessions/`.
2. Commits work changes with a clean commit message.
3. Commits the session log file in a **separate** commit — but only when it is
   not excluded by `.gitignore`.

---

## Phase 1 — Write the session log

1. Review the full conversation to identify all changes made, problems solved,
   and decisions taken.
2. Run `date +%Y-%m-%d` in a terminal to get today's date.
3. Run `git log --oneline` (or `git log --oneline <range>`) to collect commits
   made during the session.
4. Derive a short English session title from the session content.
5. Write the file to `docs/sessions/YYYY-MM-DD-<session-title>.md`.

### File naming

```
YYYY-MM-DD-<session-title>.md
```

- Date: obtained from `date +%Y-%m-%d` — never guess or hardcode it.
- `<session-title>`: a short English phrase summarising the session, words
  joined with `-` (e.g. `add-liveness-probe-action-threshold`).

### File structure

#### H1 — Session title

One sentence describing what the session accomplished.

#### H2 — Summary

One paragraph covering: background / motivation, the problem or request,
the approach taken, and the outcome.

#### H2 — Changed files

A list of every file touched during the session. For each file include:

- The file path (as a relative path from the project root)
- A one-line description of what changed and why

#### H2 — Git commits

List every commit made during the session in the format:

```
- `a1b2c3d` <commit message>
```

Use the short hash (`git log --oneline`). If no commits were made during the
session, write: "No commits were made in this session."

#### H2 — Notes

Distil the most reusable or noteworthy insights from the session, such as:

- Reusable patterns or best practices discovered
- Mistakes made and how to avoid them in future
- Non-obvious design decisions and their rationale
- Anything a future agent or developer should know before touching the same code

### Style rules

- Write in **English** throughout.
- Keep each section concise — prefer bullet lists over prose.
- The "Notes" section is the most valuable part; do not leave it empty.
- Never hardcode dates; always retrieve them with `date +%Y-%m-%d`.

---

## Phase 2 — Commit work changes

Only commit files that were modified or created during this conversation.
Do not stage unrelated changes.

If the changes span clearly distinct features or modules, split them into
multiple commits — but only do so when it adds genuine clarity. A single
commit is fine for small or cohesive changes.

### Steps

1. Identify which files were changed or added in this conversation, **excluding**
   the session log written in Phase 1.
2. Stage only those files (`git add <files>`).
3. Write a commit message following the style guide below.
4. Run `git commit -m "<subject>"` (or with `-m` body if needed).

### Commit message style

- Limit the subject line to 50 characters
- Do not capitalize the subject line
- Do not end the subject line with punctuation
- Use the imperative mood in the subject line
- Add a body only when it provides useful context not already in the subject
- Separate subject from body with a blank line; wrap body at 72 characters
- Do not include the raw diff in the message

---

## Phase 3 — Commit the session log (conditional)

Before committing the session log, check whether it is tracked by git:

```sh
git check-ignore -v docs/sessions/
```

- **If `docs/sessions/` is excluded by `.gitignore`**: do not stage or commit
  the session log. Inform the user that the file was written locally but not
  committed due to the ignore rule.
- **If `docs/sessions/` is not ignored**: stage **only** the session log file
  and create a separate commit for it. Do not mix it with the work changes from
  Phase 2.

Suggested commit message for the session log:

```
docs: add session log YYYY-MM-DD-<session-title>
```
