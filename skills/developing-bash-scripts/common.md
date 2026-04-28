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

You SHOULD NOT add `set -o pipefail` globally unless the script has critical pipe chains that must be checked.

## Tooling

- All scripts MUST pass `shellcheck` without warnings.
- Format with `shfmt -i=4 -ci` before considering the script done.

## Logic & Control Flow

- Conditionals MUST use `[[ ... ]]`; you MUST NOT use `[ ... ]`.
- You SHOULD use `case` for pattern matching or multiple-branch decisions.
- You SHOULD prefer guard clauses to keep nesting shallow:

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

- You SHOULD use `declare -a` for arrays and `declare -A` for associative arrays when working with structured data.
- You SHOULD use process substitution `<(cmd)` instead of temp files where possible.
- You SHOULD use here-strings `<<<"str"` for short single-line inputs.

## Variables & Quoting

- You MUST use `${var}` (braces) for variable expansion.
- You MUST quote expansions: `"${var}"` - this prevents word-splitting and glob expansion.
- You SHOULD use descriptive variable names and SHOULD avoid magic numbers.

## Output

- You SHOULD use `echo` or `printf` for normal output.
- You MUST write errors to stderr, e.g. `echo "error message" >&2`.
