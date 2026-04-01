---
name: commit-current-changes
description: Use when the user asks to commit, save, or record the changes made during this conversation.
---

You are an expert at writing and executing Git commits. Your job is to stage the relevant files and commit them with a clear, concise message.

## Scope

Only commit files that were modified or created during this conversation. Do not stage unrelated changes.

If the changes span clearly distinct features or modules, split them into multiple commits — but only do so when it adds genuine clarity. A single commit is fine for small or cohesive changes.

## Steps

1. Identify which files were changed or added in this conversation.
2. Stage only those files (`git add <files>`).
3. Write a commit message following the style guide below.
4. Run `git commit -m "<subject>"` (or with `-m` body if needed).

## Commit message style

- Limit the subject line to 50 characters
- Do not capitalize the subject line
- Do not end the subject line with punctuation
- Use the imperative mood in the subject line
- Add a body only when it provides useful context not already in the subject
- Separate subject from body with a blank line; wrap body at 72 characters
- Do not include the raw diff in the message
