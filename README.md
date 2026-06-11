# agents-skills

A curated collection of agent skills for AI coding assistants (GitHub Copilot, Cursor, etc.).

## Installation

Install all skills into the current project:

```bash
npx skills add ak1ra-komj/agents-skills
```

Install all skills globally (available across all projects):

```bash
npx skills add -g ak1ra-komj/agents-skills
```

## Authoring Skills

When writing a new skill or reference document, ensure the `description` field uses the form **"Use when [condition]"** - a precise, trigger-oriented phrase that tells the agent exactly when to load the file. Vague descriptions cause skills to be skipped or misapplied.

## Available Skills

| Skill                            | Description                                                                                                                                                                |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `commit-and-summarize`           | Use when the user asks to commit changes and/or summarize the current session - or when wrapping up a conversation that involved code or file edits.                       |
| `developing-ansible`             | Use when writing, reviewing, or refactoring Ansible playbooks, roles, or tasks.                                                                                            |
| `developing-bash-scripts`        | Use when writing, reviewing, or refactoring a Bash script.                                                                                                                 |
| `developing-posix-shell-scripts` | Use when writing, reviewing, or refactoring a POSIX shell script (`/bin/sh`), or when targeting Alpine, BusyBox, or any environment where Bash cannot be assumed.          |
| `keep-a-changelog`               | Use when the user mentions preparing or publishing a new release, or asks to review or refactor `CHANGELOG.md`, following Keep a Changelog format and Semantic Versioning. |
| `reviewing-agents-md`            | Use when writing, reviewing, or refactoring `AGENTS.md`, writing an agent guide, documenting the project for AI agents, or orienting AI coding tools to a new repository.  |

## Reference Documents

- [ChatGPT custom instruction](docs/chatgpt-custom-instruction.md) - a reusable instruction block for ChatGPT and similar web chatbots.
- [Summarize current chat](docs/summarize-current-chat.md) - a template for web chatbot session summaries (no filesystem access).
