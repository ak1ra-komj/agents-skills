# Developing Simple Bash Scripts

Simple Bash scripts cover ad-hoc tasks, short wrappers, and linear logic that does not need full CLI scaffolding.

Prioritise correctness and brevity. Do not pad simple scripts with template boilerplate.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, logic, quoting).

## Notes

- `errtrace` is not required.
- Use positional arguments (`"${1}"`, `"${2}"`); use `:?` for mandatory arg validation.
- Use Bash-specific features such as arrays, process substitution, and here-strings whenever they simplify the logic - see [common.md](common.md).

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

When the script meets any Complex criterion from the skill's classification
(roughly 50 lines, 3+ flags, structured logging, `--help`, cleanup, or shared
use), refactor with
[developing-complex-bash-scripts.md](developing-complex-bash-scripts.md) and
[reference-code-blocks.md](reference-code-blocks.md).
