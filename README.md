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

When writing a new skill or reference document, ensure the `description` field uses the form **"Use when [condition]"** — a precise, trigger-oriented phrase that tells the agent exactly when to load the file. Vague descriptions cause skills to be skipped or misapplied.

## Available Skills

| Skill                            | Description                                                                                                                                                                                                                |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `developing-ansible`             | Use when writing, reviewing, or refactoring Ansible playbooks, roles, or tasks.                                                                                                                                            |
| `developing-bash-scripts`        | Use when writing, reviewing, or refactoring a Bash script.                                                                                                                                                                 |
| `developing-posix-shell-scripts` | Use when writing, reviewing, or refactoring a POSIX shell script (`/bin/sh`), or when targeting Alpine, BusyBox, or any environment where Bash cannot be assumed.                                                          |
| `init-agents-md`                 | Use when the user asks to create or overwrite `AGENTS.md`, write an agent guide, document the project for AI agents, or orient AI coding tools to a new repository.                                                        |
| `keep-a-changelog`               | Use when the user mentions preparing or publishing a new release, or asks to review or refactor `CHANGELOG.md`, following Keep a Changelog format and Semantic Versioning.                                                   |
| `summarize-current-session`      | Use when the user asks to summarize this session, write a session log, save what we did today, or similar.                                                                                                                 |
