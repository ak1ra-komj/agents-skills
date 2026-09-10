# Developing Complex Bash Scripts

Complex Bash scripts are production CLI tools or reusable utilities distinguished from simple scripts by three structural additions: a **Logging Subsystem**, a **Usage/Help function**, and **Argument Parsing** via `getopt`. Apply them only when the script genuinely needs them.

See [common.md](common.md) for baseline requirements (shebang, safety modes, tooling, logic, quoting).

## Shebang & Safety Modes

Add `errtrace` to ensure ERR traps are inherited by functions and subshells:

```bash
#!/usr/bin/env bash

set -o errexit -o nounset -o errtrace
```

## Composition Guide

Pick and compose from [reference-code-blocks.md](reference-code-blocks.md). Include only what the script actually uses.

1. **Include**: Script Identity + Shebang/Safety Modes + `main`.
2. **Include the Logging Subsystem** when output needs severity levels or colour; omit the setter functions if `--log-level` / `--log-format` flags are not exposed.
3. **Include the Dependency Check** when relying on non-standard external commands; it calls `log_error`, so include the Logging Subsystem as well.
4. **Include the Cleanup Handler** when the script allocates resources (temp files, locks, etc.).
5. **MUST** include Usage + Argument Parsing **using `getopt` (not `getopts`)** when the script accepts any named flags.
