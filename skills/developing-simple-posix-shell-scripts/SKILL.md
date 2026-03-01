---
name: developing-simple-posix-shell-scripts
description: Guidelines for writing concise, simple POSIX-compliant shell scripts (/bin/sh) for ad-hoc tasks, wrappers, and linear logic. Prioritises brevity and portability over boilerplate. Use developing-complex-posix-shell-scripts when scripts grow beyond ~50 lines or need 3+ flags.
---

# developing-simple-posix-shell-scripts skill

This skill defines guidelines for writing **simple** POSIX shell scripts: ad-hoc tasks, short wrappers, linear logic, or init-style scripts that do not need full CLI scaffolding.

Prioritise correctness, brevity, and portability. Do NOT pad simple scripts with template boilerplate.

If a script grows beyond ~50 lines, needs 3+ flags, or involves complex control flow, switch to the **developing-complex-posix-shell-scripts** skill instead.

## When to Use This Skill

- Ad-hoc or one-off automation tasks targeting `/bin/sh`
- Portable wrappers intended to run on Alpine, BusyBox, or other minimal environments
- Basic init scripts or simple file operations
- Scripts expected to stay under ~50 lines
- No need for `--help`, structured logging, or multiple named flags

## Core Requirements

### Shebang & Safety Modes

Every script, no matter how simple, MUST start with:

```sh
#!/bin/sh

set -e
set -u
```

- `set -e`: exit immediately on error.
- `set -u`: exit on reference to an unset variable.
- `set -o pipefail` is **not** POSIX — do not use it.

### Tooling

- All scripts MUST pass `shellcheck --shell=sh` without warnings.
- Format with `shfmt -ln posix` before considering the script done.

### POSIX Compliance — Do NOT Use These Bash-isms

| Bash feature                  | POSIX replacement                 |
| ----------------------------- | --------------------------------- |
| `[[ ... ]]`                   | `[ ... ]`                         |
| `local var`                   | prefix with `_funcname_var`       |
| `declare -a arr`              | not available — restructure logic |
| `source file`                 | `. file`                          |
| `function f { }`              | `f() { }`                         |
| `(( expr ))`                  | `$(( expr ))`                     |
| `$'...'` strings              | `printf`                          |
| `<<<` here-strings            | `printf ... \|` or temp file      |
| `<(cmd)` process substitution | temp file or pipe                 |
| `echo -e`                     | `printf`                          |

### Logic & Control Flow

- Conditionals: always quote variables in tests: `[ "${var}" = "value" ]`.
- Use `case` for pattern matching or multiple-branch decisions.
- Prefer guard clauses to keep nesting shallow:

  ```sh
  # Bad
  if [ -f "${file}" ]; then
      process "${file}"
  else
      printf 'File not found\n' >&2
      exit 1
  fi

  # Good
  if [ ! -f "${file}" ]; then
      printf 'File not found: %s\n' "${file}" >&2
      exit 1
  fi
  process "${file}"
  ```

### Variables & Quoting

- Always use `${var}` (braces) for variable expansion.
- Always quote expansions: `"${var}"`.
- Use descriptive variable names; avoid magic numbers.
- Use `$(...)` for command substitution, never backticks.
- Prefer `printf` over `echo` for reliable, portable output.

## Minimal Example

```sh
#!/bin/sh

set -e
set -u

src="${1:?Usage: $0 <src> <dst>}"
dst="${2:?Usage: $0 <src> <dst>}"

if [ ! -f "${src}" ]; then
    printf 'Source file not found: %s\n' "${src}" >&2
    exit 1
fi

cp "${src}" "${dst}"
printf 'Copied %s -> %s\n' "${src}" "${dst}"
```

## Upgrade Checklist

Refactor a simple script into a complex script when **any** of the following apply:

- Script exceeds ~50 lines of logic
- Needs 3 or more named flags / options
- Requires structured logging (`log_info`, `log_error`, etc.)
- Needs `-h` / help output
- Has non-trivial error handling or cleanup logic
- Will be shared or reused as a production tool
