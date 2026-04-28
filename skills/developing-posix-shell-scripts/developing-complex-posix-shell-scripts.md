# Developing Complex POSIX Shell Scripts

Complex POSIX shell scripts are production system utilities or reusable tools distinguished from simple scripts by three structural additions: a **Logging Subsystem**, a **Usage/Help function**, and **Argument Parsing** via `getopts`. You SHOULD apply them only when the script genuinely needs them.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, POSIX compliance, logic, quoting).

## When to Use

- Reusable system utilities or production automation scripts targeting `/bin/sh`
- Scripts with multiple named flags / options
- Requires structured logging with severity levels
- Needs `-h` / help output
- Has cleanup logic or dependency checks
- Must run portably on Alpine, BusyBox, embedded, or other minimal systems

## Composition Guide

You SHOULD pick and compose from [reference-code-blocks.md](reference-code-blocks.md). You SHOULD include only what the script actually uses.

1. **You MUST include**: Script Identity + Shebang/Safety Modes + `main`.
2. **You SHOULD include the Logging Subsystem** when output needs severity levels or colour; you MAY omit the setter functions if `-l` / `-f` flags are not exposed.
3. **You SHOULD include the Dependency Check** when relying on non-standard external commands.
4. **You SHOULD include the Cleanup Handler** when the script allocates resources (temp files, locks, etc.).
5. **You MUST include Usage + Argument Parsing** when the script accepts any named flags.
