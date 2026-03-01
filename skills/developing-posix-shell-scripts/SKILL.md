---
name: developing-posix-shell-scripts
description: Entry point for all POSIX shell script tasks. Classifies the script as simple or complex, then delegates to the appropriate sub-skill. When refactoring existing scripts, first re-evaluates actual complexity to avoid over-engineering simple scripts.
---

# developing-posix-shell-scripts skill

This skill is the entry point for any task that involves **writing, modifying, or reviewing** a POSIX-compliant shell script (`/bin/sh`).

Apply this skill whenever strict POSIX compliance is required (e.g., targeting `/bin/sh`, Alpine, BusyBox, embedded systems).

Its sole responsibility is **classification**: determine which sub-skill applies, then follow that sub-skill's guidelines exclusively.

---

## Step 1 — Classify the Script

Read the script (or the request) and answer these questions:

| Question                              | Simple     | Complex    |
| ------------------------------------- | ---------- | ---------- |
| Expected line count (logic only)      | < 50 lines | ≥ 50 lines |
| Named flags / options needed          | 0–2        | 3 or more  |
| Structured logging required?          | No         | Yes        |
| `-h` / help output required?          | No         | Yes        |
| Cleanup / resource management?        | No         | Yes        |
| Reused across systems / environments? | No         | Yes        |

**If all answers fall in the Simple column → use `developing-simple-posix-shell-scripts`.**  
**If any answer falls in the Complex column → use `developing-complex-posix-shell-scripts`.**

When in doubt, prefer **Simple**. It is always easier to promote a simple script to complex than to untangle unnecessary boilerplate.

---

## Step 2 — Delegate

Follow the chosen sub-skill entirely:

- **[developing-simple-posix-shell-scripts]**: concise scripts, no boilerplate, brevity and portability over structure.
- **[developing-complex-posix-shell-scripts]**: production system utilities, compose only the reference blocks the script actually needs.

---

## Special Case: Refactoring an Existing Script

When the task is to **refactor or rewrite** an existing script, perform an additional review before classifying:

1. **Read the existing script in full.**
2. **Identify what the script actually does** — list its responsibilities in plain language (one line each).
3. **Re-classify from scratch** using the table above, ignoring the current implementation's size or structure.
4. If the existing script is over-engineered for its actual functionality (e.g., a 300-line script that only copies a file), **simplify it** to match the correct classification.
   - Remove unused boilerplate, logging subsystems, and option parsers that serve no real purpose.
   - A script that does one simple thing should look like it does one simple thing.
5. Only preserve complexity that the script's **actual functionality** justifies.

> **Rule**: The implementation complexity must match the functional complexity, not the other way around.
