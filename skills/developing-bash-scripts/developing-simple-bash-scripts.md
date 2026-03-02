# Developing Simple Bash Scripts

Simple Bash scripts cover ad-hoc tasks, short wrappers, and linear logic that does not need full CLI scaffolding.

Prioritise correctness and brevity. Do NOT pad simple scripts with template boilerplate.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, logic, quoting).

## When to Use

- Ad-hoc or one-off automation tasks
- Simple wrappers around existing commands
- Scripts expected to stay under ~50 lines
- No need for `--help`, structured logging, or multiple named flags

## Notes

- `errtrace` is not required.
- Positional arguments (`"${1}"`, `"${2}"`) are fine; use `:?` for mandatory arg validation.
- Bash-specific features such as arrays, process substitution, and here-strings are perfectly appropriate whenever they simplify the logic — see [common.md](common.md).

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

## Upgrade to Complex

Refactor a simple script into a complex script when **any** of the following apply:

- Script exceeds ~50 lines of logic
- Needs 3 or more named flags / options
- Requires structured logging (`log_info`, `log_error`, etc.)
- Needs `--help` output
- Has non-trivial error handling or cleanup logic
- Will be shared or reused as a production tool

When upgrading, see [developing-complex-bash-scripts.md](developing-complex-bash-scripts.md) and [reference-code-blocks.md](reference-code-blocks.md).
