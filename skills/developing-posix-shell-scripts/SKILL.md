---
name: developing-posix-shell-scripts
description: Use when writing, reviewing, or refactoring a POSIX shell script (/bin/sh), or when targeting Alpine, BusyBox, or any environment where Bash cannot be assumed.
---

# developing-posix-shell-scripts skill

This skill covers any task involving **writing, reviewing, or refactoring** a POSIX-compliant shell script (`/bin/sh`).

**Bash-specific features are forbidden.** See [common.md](common.md) for the full list of bash-isms to avoid.

## Step 1 — Classify the Script

Audit flags before classifying. Ask for each proposed flag: would a real caller ever pass a different value, or can it be a `readonly` constant? Beyond that, apply common sense — not everything that _could_ vary _should_ be a flag. Internal paths, fixed timeouts, log levels for non-CLI tools, and similar values are typically hardcoded in practice even if they could theoretically differ. When reviewing an existing script, re-classify from scratch; the current number of flags is not evidence of correct classification.

**Simple** — all of: < 50 lines of logic, 0–2 genuine flags, no structured logging, no `-h`/help output, no resource cleanup, not shared across systems/environments.

**Complex** — any of: ≥ 50 lines, 3+ genuine flags, structured logging, `-h`/help output, resource cleanup, shared across systems/environments.

When in doubt, prefer **Simple**.

## Step 2 — Follow the Reference Document

Always load **[common.md](common.md)** first, then load the matching document:

- **[developing-simple-posix-shell-scripts.md](developing-simple-posix-shell-scripts.md)** — Load when classified as Simple.
- **[developing-complex-posix-shell-scripts.md](developing-complex-posix-shell-scripts.md)** — Load when classified as Complex. Also load **[reference-code-blocks.md](reference-code-blocks.md)** to compose only the blocks the script actually needs.
