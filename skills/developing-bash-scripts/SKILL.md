---
name: developing-bash-scripts
description: Use when writing, reviewing, or refactoring a Bash script.
---

# developing-bash-scripts skill

This skill covers any task involving **writing, reviewing, or refactoring** a Bash script.

## Step 1 — Classify the Script

Audit flags before classifying. Ask for each proposed flag: would a real caller ever pass a different value, or can it be a `readonly` constant? Beyond that, apply common sense — not everything that _could_ vary _should_ be a flag. Internal paths, fixed timeouts, log levels for non-CLI tools, and similar values are typically hardcoded in practice even if they could theoretically differ. When reviewing an existing script, re-classify from scratch; the current number of flags is not evidence of correct classification.

**Simple** — all of: < 50 lines of logic, 0–2 genuine flags, no structured logging, no `--help`, no resource cleanup, not shared across systems/environments.

**Complex** — any of: ≥ 50 lines, 3+ genuine flags, structured logging, `--help`, resource cleanup, shared across systems/environments.

When in doubt, prefer **Simple**.

If the result is **Simple** and the script uses no Bash-specific features (`[[ ]]`, arrays, process substitution, here-strings, etc.), use `#!/bin/sh` and follow the **developing-posix-shell-scripts** skill instead.

## Step 2 — Follow the Reference Document

Always load **[common.md](common.md)** first, then load the matching document:

- **[developing-simple-bash-scripts.md](developing-simple-bash-scripts.md)** — Load when classified as Simple.
- **[developing-complex-bash-scripts.md](developing-complex-bash-scripts.md)** — Load when classified as Complex. Also load **[reference-code-blocks.md](reference-code-blocks.md)** to compose only the blocks the script actually needs.
