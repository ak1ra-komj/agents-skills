---
name: developing-posix-shell-scripts
description: Guidelines for POSIX-compliant shell scripts (/bin/sh). Distinguishes between simple scripts and complex production-ready tools.
---

# developing-posix-shell-scripts skill

This skill defines mandatory guidelines for generating, modifying, or reviewing POSIX-compliant shell scripts (`/bin/sh`) to ensure portability across UNIX-like systems.

It MUST be applied whenever strict POSIX compliance is required (e.g., targeting `/bin/sh`, Alpine, embedded systems).

## Script Classification

To balance portability with conciseness, first determine the script's category:

### 1. Simple Scripts

- Use Case: Basic init scripts, simple file operations, minimal wrappers, or short (< 50 lines) scripts.
- Requirements: Must follow Core Guidelines.
- Exemptions: May omit `template.sh` boilerplate and structured logging.

### 2. Complex Scripts

- Use Case: Reusable system utilities, scripts requiring user flags (`-v`, `-f`), or complex logic.
- Requirements: Must follow Core Guidelines AND Template & Structure.
- Goal: Ensure standardized behaviors and robust execution across platforms.

## Core Guidelines (Mandatory for ALL Scripts)

### Shell Standards

- Standard: IEEE Std 1003.1 (POSIX sh).
- Shebang: `#!/bin/sh` (or `#!/usr/bin/env sh`).

### Safety & Environment

- Safety Modes:
  ```sh
  set -e  # Exit on error (ensure compatibility with target shell)
  set -u  # Exit on unset variables
  ```
- Validation: All scripts must pass `shellcheck` (targeting `sh`) and be formatted.

### Compliance (Do NOT Use Bash-isms)

- No `[[ ... ]]` (Use `[ ... ]`).
- No Arrays (`arr[0]`).
- No `function name { ... }` (Use `name() { ... }`).
- No `local` (Variables are global; prefix them like `_func_var`).
- No `source` (Use `.` operator).
- No `pipefail` (Not POSIX standard).
- No `<<<` or process substitution `<(...)`.
- No `bash` arithmetic `(( ... ))` (Use `$(( ... ))`).

### Logic & Style

- Conditionals: Quote variables in tests: `[ "${var}" = "val" ]`.
- Quoting: ALWAYS quote variable expansions: `"${var}"`.
- Expansion: Always use `${var}` syntax.
- Command Substitution: Use `$(...)` instead of backticks.
- Output: Prefer `printf` over `echo` for reliable formatting.

## Template & Structure (Complex Scripts ONLY)

Complex Scripts MUST be based on the provided [template.sh](template.sh).

- Argument Parsing: Use `getopts` (standard built-in) for parsing short options.
- Logging: Use the template's logging functions.
- Structure: Group logic into functions.

## Simple Script Guidelines

For Simple Scripts:

- Keep it minimal and portable.
- Template boilerplate is optional.
- Direct implementation in main scope is acceptable.
- If arguments or logic become complex, refactor into a Complex Script.
