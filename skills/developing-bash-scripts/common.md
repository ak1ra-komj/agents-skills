# Common Bash Script Requirements

Applies to both simple and complex Bash scripts.

## Shebang & Safety Modes

Start every script with:

```bash
#!/usr/bin/env bash

set -o errexit -o nounset
```

- `errexit`: exit immediately on error.
- `nounset`: exit on reference to an unset variable.

Complex scripts additionally add `-o errtrace` (see [developing-complex-bash-scripts.md](developing-complex-bash-scripts.md)).

**SHOULD NOT** add `set -o pipefail` globally; reserve it for critical pipe chains that must be checked.

## Tooling

- Scripts **MUST** pass `shellcheck` without warnings.
- Format with `shfmt -i=4 -ci` before considering the script done.

## Logic & Control Flow

- **MUST** use `[[ ... ]]` for conditionals; **MUST NOT** use `[ ... ]`.
- **SHOULD** use `case` for pattern matching or multiple-branch decisions.
- **SHOULD** prefer guard clauses to keep nesting shallow:

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

- Use `declare -a` for arrays and `declare -A` for associative arrays when working with structured data.
- **SHOULD** use process substitution `<(cmd)` instead of temp files where possible.
- **SHOULD** use here-strings `<<<"str"` for short single-line inputs.

## Variables & Quoting

- **MUST** use `${var}` braces for variable expansion.
- **MUST** quote expansions: `"${var}"` — this prevents word-splitting and glob expansion.
- **SHOULD** use descriptive variable names; avoid magic numbers.

## Output

- Use `echo` or `printf` for normal output.
- **MUST** write errors to stderr, e.g. `echo "error message" >&2`.
