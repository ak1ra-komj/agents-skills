# Common Bash Script Requirements

Applies to both simple and complex Bash scripts.

## Shebang & Safety Modes

Every script MUST start with:

```bash
#!/usr/bin/env bash

set -o errexit -o nounset
```

- `errexit`: exit immediately on error.
- `nounset`: exit on reference to an unset variable.

Complex scripts additionally add `-o errtrace` (see [developing-complex-bash-scripts.md](developing-complex-bash-scripts.md)).

Do NOT add `set -o pipefail` globally unless the script has critical pipe chains that must be checked.

## Tooling

- All scripts MUST pass `shellcheck` without warnings.
- Format with `shfmt -i=4 -ci` before considering the script done.

## Logic & Control Flow

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

- Use `declare -a` for arrays and `declare -A` for associative arrays when working with structured data.
- Use process substitution `<(cmd)` instead of temp files where possible.
- Use here-strings `<<<"str"` for short single-line inputs.

## Variables & Quoting

- Always use `${var}` (braces) for variable expansion.
- Always quote expansions: `"${var}"` — prevents word-splitting and glob expansion.
- Use descriptive variable names; avoid magic numbers.

## Output

- Use `echo` or `printf` for normal output.
- Write errors to stderr: `echo "error message" >&2`.
