## Context

The repository documents its writing conventions in `AGENTS.md` (ASCII punctuation only, no em dashes). Five files under `skills/` currently contain non-ASCII characters. The Bash and POSIX shell skills are near-identical twins, but the Bash skill already renders the script-classification thresholds as ASCII (`0-2`, `>= 50`) while the POSIX skill uses `0–2` and `≥ 50`. See proposal.md for the full motivation.

## Goals / Non-Goals

**Goals:**

- Replace every non-ASCII character in `skills/` with an ASCII equivalent, using a consistent substitution convention.
- Make the POSIX shell skill's wording match the Bash skill's already-ASCII form.
- Codify a `prettier -w` formatting convention in `AGENTS.md`.

**Non-Goals:**

- No rewording beyond what the punctuation substitution requires; meaning is preserved.
- The Ansible version pins in `handling-boolean-values.md` (`2.19` / `2.23`) are out of scope; they are content, not punctuation.
- `.gitignore` cleanup is out of scope; the stale session-log paths are intentionally kept for downstream repos that have not migrated yet.

## Decisions

1. **Use ASCII symbol equivalents rather than rewording.** Substitution map:
   - `→` -> `->`
   - `≥` -> `>=`
   - `–` (en dash) -> `-`
   - `—` (em dash) -> `-`

   Rationale: keeps diffs minimal and preserves table alignment in `handling-boolean-values.md`. Rewording would risk altering meaning and enlarge the diff for no benefit. The only mild ambiguity is `->` in prose; in the affected lines it reads unambiguously as "results in".

2. **Align the POSIX skill with the Bash skill's thresholds.** Replace `0–2` with `0-2` and `≥ 50` with `>= 50`, matching `developing-bash-scripts/SKILL.md` verbatim.

   Rationale: the two skills describe the same classification logic; divergent rendering invites drift.

3. **Codify prettier as a convention, not a hard rule.** Add a bullet to `AGENTS.md` under "Conventions": "Run `prettier -w` on every modified file before finishing." Use plain imperative language (not RFC 2119), consistent with the existing guidance style.

   Rationale: formatting enforcement is routine guidance, so it must not use `MUST`/`SHOULD` per the repo's RFC 2119 policy. `prettier -w` rewrites in place; scoping to "modified files" avoids reformatting untouched content.

## Risks / Trade-offs

- [Mechanical edit touches four skills] -> Mitigation: substitutions are char-for-char and do not change wording; a `git diff` review confirms no semantic change.
- [Non-ASCII could reappear later] -> Mitigation: this change fixes current occurrences only; enforcement is already stated in `AGENTS.md` and is not duplicated here.
