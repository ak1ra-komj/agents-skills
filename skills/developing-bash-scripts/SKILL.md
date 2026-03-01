---
name: developing-bash-scripts
description: Guidelines for generating, modifying, or reviewing Bash shell scripts. Distinguishes between simple scripts and complex production-ready tools.
---

# developing-bash-scripts skill

This skill defines mandatory guidelines for generating, modifying, or reviewing Bash shell scripts to ensure consistency, robustness, and compliance with project standards.

It MUST be applied whenever Bash scripts are involved.

## Script Classification

To balance robustness with conciseness, first determine the script's category:

### 1. Simple Scripts

- Use Case: Ad-hoc tasks, simple wrappers, linear logic, internal use, or short (< 50 lines) scripts.
- Requirements: Must follow Core Guidelines.
- Exemptions: May omit `template.sh` boilerplate, complex argument parsing, and structured logging.

### 2. Complex Scripts

- Use Case: Production tools, reusable CLI utilities, scripts with multiple options/flags, or complex control flow.
- Requirements: Must follow Core Guidelines AND Template & Structure.
- Goal: Ensure maintainability, standard interface (help, logging), and robust error handling.

## Core Guidelines (Mandatory for ALL Scripts)

### Bash Version & Safety

- Shebang: `#!/usr/bin/env bash` (Bash 4.0+ assumed).
- Safety Modes:
  ```bash
  set -o errexit   # Exit on error
  set -o nounset   # Exit on unset variables
  set -o errtrace  # Recommended for error trapping
  ```
  DO NOT `set -o pipefail` globally unless handling critical pipe chains

### Tooling

- Validation: All scripts must pass `shellcheck` and be formatted with `shfmt`.

### Logic & Control Flow

- Conditionals: Always use `[[ ... ]]` (not `[ ... ]`).
- Branching: Use `case` statements for pattern matching or multiple branches.
- Guard Clauses: Check failure conditions early to avoid deep nesting.
  - _Bad_: `if [[ success ]]; then ... else exit 1; fi`
  - _Good_: `if [[ ! success ]]; then exit 1; fi; ...`
- Features:
  - Use Arrays (`declare -a`) and Associative Arrays (`declare -A`).
  - Use Process Substitution (`<(cmd)`) instead of temp files where possible.
  - Use Here Strings (`<<<"str"`) for short inputs.

### Variables & Style

- Expansion: Always use `${var}` (braces) and ALWAYS quote expansions (`"${var}"`) to prevent globbing/splitting.
- Naming: Descriptive names. No magic numbers. Well-named functions (`main`, `parse_args`, etc.).

## Template & Structure (Complex Scripts ONLY)

Complex Scripts MUST be based on the provided [template.sh](template.sh).

- Structure: Organize code into functions (`main`, `parse_args`, etc.).
- Argument Parsing: Use `getopt` (not `getopts`) to support long options (`--help`, `--log-level`).
- Logging: Use the template's logging subsystem (`log_info`, `log_error`) rather than raw `echo`.
- Validation: Must be checked with `shellcheck` and formatted with `shfmt`.

## Simple Script Guidelines

For Simple Scripts, prioritize brevity:

- Standard template boilerplate is optional.
- Direct positional argument usage (`"${1}"`) is allowed for simple inputs.
- Standard Output/Error (`echo`, `printf`) is allowed.
- Constraint: If a simple script grows beyond ~50 lines or needs 3+ flags, refactor it into a Complex Script using the template.
