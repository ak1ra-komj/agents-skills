---
name: maintaining-agents-md
description: Use when creating, reviewing, updating, or maintaining AGENTS.md files and nested agent instructions, documenting a repository for coding agents, or orienting AI coding tools to an unfamiliar repository.
---

# maintaining-agents-md

Treat `AGENTS.md` as a routing and orientation layer for repository-specific
agent knowledge, not a substitute for project documentation. Keep it concise,
evidence-based, and limited to what an agent cannot infer from the repository.

## Determine intent

- Review: report findings and recommendations without editing files; prioritize
  stale or contradicted guidance, scope errors, duplication, speculative
  commands, and missing high-value constraints.
- Create: write a new `AGENTS.md` at the requested scope.
- Update or refactor: edit in place, preserving useful instructions.

Never overwrite an existing `AGENTS.md` wholesale. Remove or rewrite content
only when it is stale, redundant, ambiguous, incorrectly scoped, or
contradicted by stronger repository evidence.

## Discover the hierarchy first

Search for `AGENTS.md`, nested `AGENTS.md`, and `AGENTS.override.md`, and
establish each file's directory scope before proposing changes. Keep
repository-wide guidance in the root file and component rules in the nested
file nearest the code they govern; do not centralize scoped instructions at
the root. When the root file grows, move component-specific rules into a
nested file instead of expanding it.

## Establish facts from evidence

Read `README.md`, `CONTRIBUTING.md`, architecture and development docs,
manifests and lockfiles, `Makefile`, `justfile`, `Taskfile.yml`, package
scripts, `tox.ini`, `noxfile.py`, CI workflows, and build, release, and
documentation tooling before writing instructions.

Installed dependencies do not establish the canonical workflow: `pytest` or
`ruff` being present does not make invoking them directly correct. When a
wrapper or task runner exists, document it (`make test`, not `pytest`).
Cross-check important commands against more than one source when practical,
and verify them by execution when prompt and safe; use a lightweight form
when a full run is expensive. Document an unverified command only when
repository evidence is strong.

Never invent commands, conventions, restrictions, or workflow rules. If a
fact cannot be established, omit it from `AGENTS.md` and report
`Insufficient information` to the user with the missing evidence. Do not
leave placeholders such as `Deployment: Insufficient information` in the
file; record uncertainty only when it is operationally important to future
agents.

## What to include

Add a section only when evidence supports it; do not force a fixed template
or invent deployment, build, test, or documentation guidance the repository
does not have. Point to existing sources (`docs/`, `CONTRIBUTING.md`,
schemas, CI) instead of copying them. Omit anything an agent can infer from
filenames, standard syntax, ordinary package-manager behavior, or generic
practice; a short accurate file beats a complete-looking one.

High-value content is repository-specific:

- purpose and stack in one or two sentences, linking `README.md` for detail
- canonical setup, test, lint, format, build, docs, and release commands
- generated files that must not be edited by hand
- authoritative schemas, configuration, and sources of truth
- files that must be kept in sync
- non-obvious test organization, architectural boundaries, and release rules
- operational constraints not visible in source code

## Constraints and validation

- Target approximately 80 lines for the root `AGENTS.md`; exceed it only to
  keep important repository-wide constraints.
- Reserve RFC 2119 keywords (`MUST`, `MUST NOT`, `SHOULD`) for hard
  constraints whose violation produces broken, incorrect, insecure, or
  inconsistent results, and place them near the relevant operation. Do not
  use `IMPORTANT` / `CRITICAL` labels or repeated warnings.
- Write in English with plain Markdown and ASCII punctuation; no emoji, no
  em dashes, minimal emphasis.
- Before finishing, check scope, unsupported assumptions, duplicated
  documentation, and line budget; verify documented commands that remain
  unverified when practical.
