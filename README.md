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

## Available Skills

| Skill                            | Description                                                                                                                                          |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `developing-ansible`             | Guidelines for Ansible playbooks, roles, tasks, and project structure                                                                                |
| `developing-bash-scripts`        | Write, review, or refactor any Bash script; classifies as simple or complex and references the appropriate guide                                     |
| `developing-posix-shell-scripts` | Write, review, or refactor strictly POSIX `/bin/sh` scripts (no Bash features); classifies as simple or complex and references the appropriate guide |
| `init-agents-md`                 | Generate or overwrite `AGENTS.md` in a project root                                                                                                  |
| `keep-a-changelog`               | Maintain `CHANGELOG.md` following Keep a Changelog and Semantic Versioning                                                                           |
| `summarize-current-session`      | Summarize the current conversation and write a session log                                                                                           |
