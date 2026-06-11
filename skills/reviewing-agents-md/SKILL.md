---
name: reviewing-agents-md
description: Use when writing, reviewing, or refactoring AGENTS.md, writing an agent guide, documenting the project for AI agents, or orienting AI coding tools to a new repository.
---

# reviewing-agents-md

Analyze the repository and write (or overwrite) an `AGENTS.md` file in the project
root. The file is a concise, prescriptive orientation guide for AI coding agents.
Do not duplicate content from `README.md` - link there for anything already covered.

## Workflow

1. Read `README.md`, `pyproject.toml` / `package.json` / equivalent manifest,
   and any existing config files to infer the tech stack and tooling.
2. Identify the environment manager, test runner, linter, and build tool in use.
3. Write `AGENTS.md` following the structure below.
4. Keep the file **under 80 lines** total.

## Required sections

### 1. What This Project Does (2-4 sentences)

State the project's purpose and technology stack category. Add a pointer to
`README.md` for full details.

### 2. Environment & Tooling - CRITICAL

Identify the exact tool that manages the environment and write explicit rules covering:

- The exact command to run the test suite
- How to install/sync dependencies
- How to lint and format
- Which alternatives are explicitly forbidden

Mark this section `- CRITICAL` so agents cannot miss it.

### 3. Conventions (non-obvious only)

Cover naming patterns and the canonical source-of-truth files agents respect
when adding new parameters or configuration keys.

### 4. Testing Guidelines

- Where tests live and how they map to source modules
- Whether external I/O needs mocking
- Rules about keeping tests in sync when function signatures change

### 5. Common Operations

One shell code block with one-liner comments for the 4-6 most frequent tasks
(test, lint, build, deploy, docs preview, etc.).

## Style rules

- Write in **English**.
- Use RFC 2119 keywords (`MUST`, `SHOULD`, `MUST NOT`) selectively - reserve them for hard constraints where violation produces broken, incorrect, or insecure output. For routine guidance, use plain imperative language (e.g., "Run tests with `pytest`", "Format with `ruff format`"). Overusing RFC 2119 keywords dilutes their signal.
- Omit content already in `README.md` and link there instead.
- Prefer bullet lists and short paragraphs over prose.
- Do not use emoji, em dashes, or excess bold/italic text.
- Use plain Markdown (no HTML) and only ASCII punctuation.
- When repository facts cannot be determined from the repo contents or user input, do not guess; instead state "Insufficient information".
