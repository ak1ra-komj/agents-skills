---
name: developing-simple-bash-scripts
description: Guidelines for writing concise, simple Bash scripts for ad-hoc tasks, wrappers, and linear logic. Prioritises brevity over boilerplate. Use developing-complex-bash-scripts when scripts grow beyond ~50 lines or need 3+ flags.
---

# developing-simple-bash-scripts skill

This skill defines guidelines for writing **simple** Bash scripts: ad-hoc tasks, short wrappers, linear logic, or internal-use scripts that do not need full CLI scaffolding.

Prioritise correctness and brevity. Do NOT pad simple scripts with template boilerplate.

If a script grows beyond ~50 lines, needs 3+ flags, or involves complex control flow, switch to the **developing-complex-bash-scripts** skill instead.

## When to Use This Skill

- Ad-hoc or one-off automation tasks
- Simple wrappers around existing commands
- Linear logic with no or minimal branching
- Scripts expected to stay under ~50 lines
- No need for `--help`, structured logging, or multiple named flags

## Core Requirements

### Shebang & Safety Modes

Every script, no matter how simple, MUST start with:

```bash
#!/usr/bin/env bash

set -o errexit -o nounset
```

- `errexit`: exit immediately on error.
- `nounset`: exit on reference to an unset variable.
- `errtrace` is optional for simple scripts.
- Do NOT add `set -o pipefail` globally unless the script has critical pipe chains that must be checked.

### Tooling

- All scripts MUST pass `shellcheck` without warnings.
- Format with `shfmt` before considering the script done.

### Logic & Control Flow

- Conditionals: always use `[[ ... ]]`, never `[ ... ]`.
- Use `case` for pattern matching or multiple-branch decisions.
- Prefer guard clauses to keep nesting shallow:

  ```bash
  # Bad
  if [[ -f "${file}" ]]; then
      process "${file}"
  else
      echo "File not found" >&2
      exit 1
  fi

  # Good
  if [[ ! -f "${file}" ]]; then
      echo "File not found: ${file}" >&2
      exit 1
  fi
  process "${file}"
  ```

### Variables & Quoting

- Always use `${var}` (braces) for variable expansion.
- Always quote expansions: `"${var}"` — prevents word-splitting and glob expansion.
- Use descriptive variable names; avoid magic numbers.

### Output

- Use `echo` or `printf` for normal output.
- Write errors to stderr: `echo "error message" >&2`.
- Positional arguments (`"${1}"`, `"${2}"`) are fine for simple inputs.

## Minimal Example

```bash
#!/usr/bin/env bash

set -o errexit -o nounset

src="${1:?Usage: $0 <src> <dst>}"
dst="${2:?Usage: $0 <src> <dst>}"

if [[ ! -f "${src}" ]]; then
    echo "Source file not found: ${src}" >&2
    exit 1
fi

cp "${src}" "${dst}"
echo "Copied ${src} -> ${dst}"
```

## Upgrade Checklist

Refactor a simple script into a complex script when **any** of the following apply:

- Script exceeds ~50 lines of logic
- Needs 3 or more named flags / options
- Requires structured logging (`log_info`, `log_error`, etc.)
- Needs `--help` output
- Has non-trivial error handling or cleanup logic
- Will be shared or reused as a production tool
