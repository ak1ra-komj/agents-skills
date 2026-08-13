## Why

`AGENTS.md` mandates "ASCII punctuation only. No emoji, em dashes, or excess bold/italic text" for all Markdown content in this repository. Several files under `skills/` violate that rule by using non-ASCII characters (em dash, en dash, arrow, greater-than-or-equal sign), and one file-naming template contains a typo (`YYY` instead of `YYYY`). This makes the collection inconsistent with the very conventions it documents. The change also codifies formatting enforcement (`prettier`) in `AGENTS.md`.

## What Changes

- Fix the filename-template typo in `skills/commit-and-summarize/SKILL.md`: `YYY-MM-DD` -> `YYYY-MM-DD`.
- Replace non-ASCII punctuation with ASCII equivalents so every skill document complies with `AGENTS.md`:
  - `skills/developing-bash-scripts/common.md`: em dash `—` -> `-`.
  - `skills/developing-posix-shell-scripts/SKILL.md`: en dash `–` -> `-`, `≥` -> `>=`, to match the parallel wording in the Bash skill.
  - `skills/developing-ansible/handling-boolean-values.md`: arrow `→` -> `->`, `≥` -> `>=`.
  - `skills/developing-ansible/jinja2-templates.md`: arrow `→` -> `->`.
- Add a convention to `AGENTS.md`: run `prettier -w` on every modified file before finishing.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This is a pure documentation correction with no spec-level behavior change, so this change sets `skip_specs: true`.

## Impact

- Affected files: five Markdown documents under `skills/` (listed above) plus `AGENTS.md`. No code, API, or dependency changes.
- No behavioral change to any skill; wording and meaning are preserved.
