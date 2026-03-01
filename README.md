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

| Skill                               | Description                                                                                          |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `developing-ansible`                | Guidelines for Ansible playbooks, roles, tasks, and project structure                                |
| `developing-bash-scripts`           | Entry point: classifies a script as simple or complex and delegates to the appropriate sub-skill     |
| `developing-simple-bash-scripts`    | Concise Bash scripts for ad-hoc tasks and simple wrappers (< 50 lines)                               |
| `developing-complex-bash-scripts`   | Production-ready Bash CLI tools with structured logging, argument parsing, and robust error handling |
| `developing-posix-shell-scripts`         | Entry point: classifies a script as simple or complex and delegates to the appropriate sub-skill     |
| `developing-simple-posix-shell-scripts`  | Concise POSIX `/bin/sh` scripts for ad-hoc tasks and simple wrappers (< 50 lines)                   |
| `developing-complex-posix-shell-scripts` | Production-ready POSIX `/bin/sh` utilities with structured logging, argument parsing, and robust error handling |
| `generate-agents-md-for-repository` | Generate or overwrite `AGENTS.md` in a project root                                                  |
| `summarize-current-session`         | Summarize the current conversation and write a session log                                           |
| `update-changelog-md`               | Maintain `CHANGELOG.md` following Keep a Changelog and Semantic Versioning                           |
