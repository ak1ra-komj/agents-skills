# Common POSIX Shell Script Requirements

Applies to both simple and complex POSIX shell scripts.

**These scripts target `/bin/sh`. MUST NOT use Bash-specific features.**

## Shebang & Safety Modes

Start every script with:

```sh
#!/bin/sh

set -e
set -u
```

- `set -e`: exit immediately on error.
- `set -u`: exit on reference to an unset variable.
- `set -o pipefail` is **not** POSIX; MUST NOT use it.

## Tooling

- Run `shellcheck --shell=sh` on every script; it MUST pass without warnings.
- Run `shfmt -ln posix` to format before considering the script done.

## POSIX Compliance - Bash-isms to Avoid

| Bash feature                  | POSIX replacement                           |
| ----------------------------- | ------------------------------------------- |
| `[[ ... ]]`                   | `[ ... ]`                                   |
| `local var`                   | prefix with `_funcname_var` (see Variables) |
| `declare -a arr`              | not available - restructure logic           |
| `source file`                 | `. file`                                    |
| `function f { }`              | `f() { }`                                   |
| `(( expr ))`                  | `$(( expr ))`                               |
| `$'...'` strings              | `printf`                                    |
| `<<<` here-strings            | `printf ... \|` or temp file                |
| `<(cmd)` process substitution | temp file or pipe                           |
| `echo -e`                     | `printf`                                    |

## Logic & Control Flow

- MUST quote variables in conditional tests: `[ "${var}" = "value" ]`.
- SHOULD use `case` for pattern matching or multiple-branch decisions.
- SHOULD prefer guard clauses to keep nesting shallow:

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

## Variables & Quoting

- Use `${var}` (braces) for variable expansion.
- MUST quote expansions: `"${var}"`.
- POSIX `sh` has no `local` keyword. Simulate function-local variables by prefixing with the function name: `_log_message_color`, `_parse_args_opt`, etc. Unset them at the end of the function.
- MUST use `$(...)` for command substitution; MUST NOT use backticks.
- SHOULD prefer `printf` over `echo` for reliable, portable output.
