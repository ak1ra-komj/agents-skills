# Reference Docs Refactor for Bash and POSIX Shell Skills

Replace the entry-point + sub-skill pattern (which caused content duplication) with a single skill directory containing a thin `SKILL.md` entry point plus focused reference documents.

## Summary

The previous refactor (2026-03-01) split each shell skill family into three sub-skills (entry point, simple, complex). While this prevented over-engineering of simple scripts, the three separate `SKILL.md` files duplicated significant content — the POSIX compliance table, shebang/safety modes, logic guidelines, and quoting rules appeared in both the simple and complex sub-skills.

This session replaced the sub-skill pattern with **reference documents** inside the same skill directory:

| File                       | Role                                                        |
| -------------------------- | ----------------------------------------------------------- |
| `SKILL.md`                 | Classification entry point only                             |
| `common.md`                | Shared baseline (shebang, tooling, logic, quoting)          |
| `developing-simple-*.md`   | Simple-specific guidance and example                        |
| `developing-complex-*.md`  | Complex intro and composition guide                         |
| `reference-code-blocks.md` | Composable code blocks (formerly the complex SKILL.md body) |

Additional refinements made during the session:

**Bash features belong in `common.md`**: arrays (`declare -a`/`declare -A`), process substitution, and here-strings are not complex-only features; any Bash script (simple or complex) should use them when they simplify logic. These were moved from `developing-complex-bash-scripts.md` into `common.md`.

**Complex is defined by three structural additions**: the description and intro of `developing-complex-bash-scripts.md` were rewritten to state clearly that the distinguishing features of a complex script are a Logging Subsystem, a Usage/Help function, and Argument Parsing via `getopt`. Unrelated guidelines that belonged in `common.md` were removed.

**Log Level/Format Setters merged into Logging Subsystem**: `set_log_level` and `set_log_format` were a separate Section 3 in `reference-code-blocks.md`. Because they are always bundled with the logging variables and functions, they were merged into Section 2 (Logging Subsystem) with a note that they can be omitted if `-l`/`-f` flags are not exposed. Subsequent sections were renumbered 3–7. The same change was applied to both the Bash and POSIX variants.

**Excessive horizontal rules removed**: `---` separators between every section added visual noise without structural value. All section dividers were removed from `common.md`, `developing-simple-*.md`, `developing-complex-*.md`, and `reference-code-blocks.md` in both skill families.

**POSIX downgrade check in `developing-bash-scripts` SKILL.md**: after classifying a script as Simple, the entry point now asks whether the script actually uses any Bash-specific features. If not, it recommends switching the shebang to `#!/bin/sh` and following the `developing-posix-shell-scripts` skill instead.

**POSIX skill description clarified**: the `developing-posix-shell-scripts` skill description now explicitly states "No Bash features allowed" and lists the target environments (`/bin/sh`, Alpine, BusyBox, embedded). The SKILL.md body opens with a bold warning on the same point.

## Changed files

### developing-bash-scripts

- `SKILL.md` — removed Special Case section; refactoring guidance folded into Step 1 flag audit note; added POSIX downgrade check after Simple classification
- `common.md` — new: shared baseline; added bash-specific features (arrays, process substitution, here-strings) to Logic section
- `developing-simple-bash-scripts.md` — new: simple-specific guidance, minimal example, upgrade checklist; note clarifying bash features are appropriate
- `developing-complex-bash-scripts.md` — new: intro naming the three structural additions; composition guide referencing reference-code-blocks.md
- `reference-code-blocks.md` — adapted from former complex SKILL.md; removed all `---` dividers; merged Section 3 (Log Level/Format Setters) into Section 2 (Logging Subsystem); renumbered to 7 sections
- `skills/developing-simple-bash-scripts/SKILL.md` — deleted (directory removed)
- `skills/developing-complex-bash-scripts/SKILL.md` — deleted (directory removed; content migrated)

### developing-posix-shell-scripts

- `SKILL.md` — rewritten to match bash entry-point structure; description and opening paragraph explicitly forbid Bash features
- `common.md` — new: shared baseline including full POSIX compliance table (bash-isms and their replacements)
- `developing-simple-posix-shell-scripts.md` — new: mirrors bash simple doc, adapted for `/bin/sh`
- `developing-complex-posix-shell-scripts.md` — new: mirrors bash complex doc, adapted for `/bin/sh`
- `reference-code-blocks.md` — adapted from former complex SKILL.md; merged Section 3 into Section 2; renumbered to 7 sections; all `---` dividers removed
- `skills/developing-simple-posix-shell-scripts/SKILL.md` — deleted (directory removed)
- `skills/developing-complex-posix-shell-scripts/SKILL.md` — deleted (directory removed; content migrated)

### Other

- `README.md` — removed sub-skill rows; updated descriptions for `developing-bash-scripts` and `developing-posix-shell-scripts`

## Git commits

- `e4f9638` refactor(bash-scripts): replace sub-skills with reference documents
- `dcd8a0b` refactor(posix-shell-scripts): replace sub-skills with reference documents

## Notes

- **Sub-skill duplication was the structural problem**: placing simple and complex guidelines in separate `SKILL.md` files forced duplication of every shared requirement. Reference documents inside one directory share `common.md` naturally.
- **`common.md` is the single source of truth for portability constraints**: the POSIX compliance table lives only in `skills/developing-posix-shell-scripts/common.md`. Any update to the bash-isms list needs to happen there only.
- **Logging Subsystem section is the natural home for setters**: `set_log_level`/`set_log_format` depend on the `LOG_PRIORITY` associative array and `LOG_LEVEL`/`LOG_FORMAT` variables declared in the same block. Separating them created a false boundary and required agents to remember a dependency rule; merging them removes the rule entirely.
- **POSIX downgrade check placement**: the check sits after the Simple classification verdict but before "When in doubt, prefer Simple". This ordering ensures the question is only asked when the Simple path is already chosen, and does not interfere with the Complex path.
