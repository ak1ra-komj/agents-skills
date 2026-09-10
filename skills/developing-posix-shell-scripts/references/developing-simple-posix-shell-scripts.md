# Developing Simple POSIX Shell Scripts

Simple POSIX shell scripts cover ad-hoc tasks, short wrappers, and linear logic that does not need full CLI scaffolding.

Prioritise correctness, brevity, and portability. SHOULD NOT pad simple scripts with template boilerplate.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, POSIX compliance, logic, quoting).

## Notes

- Use positional arguments (`"${1}"`, `"${2}"`); use `:?` for mandatory arg validation.

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

## Upgrade to Complex

When the script meets any Complex criterion from the skill's classification
(roughly 50 lines, 3+ flags, structured logging, `-h`/help output, cleanup, or
shared use), refactor with
[developing-complex-posix-shell-scripts.md](developing-complex-posix-shell-scripts.md)
and [reference-code-blocks.md](reference-code-blocks.md).
