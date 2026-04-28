# Developing Complex Bash Scripts

Complex Bash scripts are production CLI tools or reusable utilities distinguished from simple scripts by three structural additions: a **Logging Subsystem**, a **Usage/Help function**, and **Argument Parsing** via `getopt`. You SHOULD apply them only when the script genuinely needs them.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, logic, quoting).

## When to Use

- Scripts with multiple named flags / options (`--foo`, `--bar`, ...)
- Requires structured logging with severity levels
- Needs `--help` output
- Has cleanup logic or dependency checks
- Will be shared across teams or environments

## Shebang & Safety Modes

Add `errtrace` to ensure ERR traps are inherited by functions and subshells:

```bash
#!/usr/bin/env bash

set -o errexit -o nounset -o errtrace
```

## Composition Guide

You SHOULD pick and compose from [reference-code-blocks.md](reference-code-blocks.md). You SHOULD include only what the script actually uses.

1. **You MUST include**: Script Identity + Shebang/Safety Modes + `main`.
2. **You SHOULD include the Logging Subsystem** when output needs severity levels or colour; you MAY omit the setter functions if `--log-level` / `--log-format` flags are not exposed.
3. **You SHOULD include the Dependency Check** when relying on non-standard external commands.
4. **You SHOULD include the Cleanup Handler** when the script allocates resources (temp files, locks, etc.).
5. **You MUST include Usage + Argument Parsing** when the script accepts any named flags.
