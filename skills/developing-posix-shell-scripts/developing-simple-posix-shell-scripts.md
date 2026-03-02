# Developing Simple POSIX Shell Scripts

Simple POSIX shell scripts cover ad-hoc tasks, short wrappers, and linear logic that does not need full CLI scaffolding.

Prioritise correctness, brevity, and portability. Do NOT pad simple scripts with template boilerplate.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, POSIX compliance, logic, quoting).

## When to Use

- Ad-hoc or one-off automation tasks targeting `/bin/sh`
- Portable wrappers intended to run on Alpine, BusyBox, or other minimal environments
- Basic init scripts or simple file operations
- Scripts expected to stay under ~50 lines
- No need for `-h`/help output, structured logging, or multiple named flags

## Notes

- Positional arguments (`"${1}"`, `"${2}"`) are fine; use `:?` for mandatory arg validation.

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

Refactor a simple script into a complex script when **any** of the following apply:

- Script exceeds ~50 lines of logic
- Needs 3 or more named flags / options
- Requires structured logging (`log_info`, `log_error`, etc.)
- Needs `-h` / help output
- Has non-trivial error handling or cleanup logic
- Will be shared or reused as a production tool

When upgrading, see [developing-complex-posix-shell-scripts.md](developing-complex-posix-shell-scripts.md) and [reference-code-blocks.md](reference-code-blocks.md).
