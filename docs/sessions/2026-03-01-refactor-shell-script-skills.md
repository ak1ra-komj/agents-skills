# Refactor Shell Script Skills

Split monolithic `developing-bash-scripts` and `developing-posix-shell-scripts` skills into entry-point + simple + complex sub-skills to prevent over-engineering of simple scripts.

## Summary

Both `developing-bash-scripts` and `developing-posix-shell-scripts` previously contained a single `SKILL.md` backed by a `template.sh`. Because the template was always present, agents would apply full boilerplate (logging subsystem, `getopt`/`getopts` parsing, `--help`, cleanup handler) even to trivial scripts, producing hundreds of lines where a dozen would suffice.

The fix mirrors a pattern used in the bash skill refactoring: each skill family now has three components — an **entry-point** skill that classifies the request, a **simple** sub-skill focused on brevity, and a **complex** sub-skill that provides composable reference code blocks instead of a monolithic template. The entry-point also includes an explicit **refactoring workflow** that requires the agent to re-evaluate a script's actual functional complexity before choosing a classification, preventing existing over-engineered scripts from being preserved or made worse.

In addition, argument ordering conventions were added to the complex sub-skills to keep `usage`, `longoptions`/ optstring, and `case` statement in sync (template flags first, script-specific flags after).

## Changed files

- `skills/developing-bash-scripts/SKILL.md` — rewritten as classification entry point with classification table and refactoring workflow
- `skills/developing-bash-scripts/template.sh` — deleted; content inlined as composable code blocks
- `skills/developing-simple-bash-scripts/SKILL.md` — new: concise Bash script guidelines, minimal example, upgrade checklist
- `skills/developing-complex-bash-scripts/SKILL.md` — new: 8 composable reference code blocks, argument ordering convention in `usage` / `longoptions` / `case`
- `skills/developing-posix-shell-scripts/SKILL.md` — rewritten as classification entry point (mirrors Bash entry point)
- `skills/developing-posix-shell-scripts/template.sh` — deleted; content inlined as composable code blocks
- `skills/developing-simple-posix-shell-scripts/SKILL.md` — new: concise POSIX sh guidelines, POSIX compliance table, minimal example, upgrade checklist
- `skills/developing-complex-posix-shell-scripts/SKILL.md` — new: 8 composable reference code blocks adapted for POSIX (no `local`, no associative arrays, `_funcname_var` scoping convention)
- `README.md` — updated skill table to list all six skills

## Git commits

- `0ab8110` refactor(bash-scripts): split into simple/complex sub-skills with entry point
- `b360f45` refactor(posix-shell-scripts): split into simple/complex sub-skills with entry point

## Notes

- **Root cause of over-engineering**: the mere presence of `template.sh` caused agents to treat it as mandatory rather than optional. Removing the file and replacing it with opt-in code blocks eliminates the structural pressure to use everything.
- **Entry-point pattern**: a thin entry-point skill that only classifies and delegates is effective for skill families where the correct approach depends on context. The entry point stays stable; the sub-skills evolve independently.
- **Refactoring workflow is critical**: without an explicit instruction to re-read and re-classify an existing script from scratch, agents default to preserving the current structure. The "re-classify ignoring current size" rule directly addresses this.
- **Argument ordering convention**: requiring template flags first in `usage`, `longoptions`/ optstring, and `case` keeps three related locations in sync and makes the pattern easier for both agents and humans to follow.
- **POSIX `local` workaround**: POSIX `sh` has no `local` keyword. The `_funcname_var` prefix convention (with explicit `unset` at function end) was adopted as the idiomatic substitute and documented in the complex sub-skill.
- **File viewer wrapping**: the VS Code tool wraps SKILL.md content in a ` ```skill ``` ` code fence for display, but the actual files start directly with `---` frontmatter. Do not mistake the display wrapper for real file content when constructing `replace_string_in_file` calls.
