# developing-ansible Skill Refactor

Refactored the `developing-ansible` skill from a monolithic `SKILL.md` into a structured set of reference documents aligned with the bash-scripts/posix-shell-scripts skill pattern.

## Summary

The `developing-ansible` skill was never being invoked in practice because its `description` field only described content rather than trigger scenarios. This session rewrote the description to include explicit use cases, restructured `SKILL.md` as a topic-based routing table, and split all guidelines into focused reference documents. Additional reference docs were added for boolean value handling (`handling-boolean-values.md`) — incorporating notes from an existing Obsidian document on Ansible truthy/falsy pitfalls — and for Jinja2 template patterns (`jinja2-templates.md`). Throughout the session, all Ansible-specific filters and tests were updated to FQCN form, a duplication between the routing table and reference list in `SKILL.md` was eliminated, and Prettier-aligned table padding was removed from `SKILL.md` to reduce token overhead.

## Changed Files

- `README.md` — updated `developing-ansible` skill description to match new routing approach
- `skills/developing-ansible/SKILL.md` — rewrote description with explicit trigger scenarios; replaced monolithic guidelines with a 3-column routing table (topic / doc / covers); removed duplicate Step 2 list
- `skills/developing-ansible/common.md` — new file; baseline YAML style, project layout, Vault, and validation rules applying to all Ansible files
- `skills/developing-ansible/developing-playbooks.md` — new file; play definition four-key rule, import vs include preference, idempotency, error handling pointer
- `skills/developing-ansible/developing-roles.md` — new file; Galaxy directory layout, defaults vs vars distinction, handler rules, dependency guidelines
- `skills/developing-ansible/developing-tasks.md` — new file; task key ordering, FQCN requirement, fact reference style, loop with `loop_control`
- `skills/developing-ansible/reference-code-blocks.md` — new file; canonical block/rescue/always, play definition, loop, template task, and shell idempotency patterns
- `skills/developing-ansible/handling-boolean-values.md` — new file; YAML native booleans, `ansible.builtin.bool` strict-allowlist behaviour vs Python `bool()`, `is ansible.builtin.truthy`/`falsy` tests, `or` operator pitfall, `default()` vs `default(val, true)` semantics, quick reference table
- `skills/developing-ansible/jinja2-templates.md` — new file; whitespace control, `{% set %}`, macros, structured config generation with `ansible.builtin.to_nice_yaml`/`to_nice_json`, list/dict filters (`combine`, `flatten`, `selectattr`, `map`), default value pitfalls, undefined variable behaviour

## Git Commits

- `997667c` feat(developing-ansible): refactor SKILL.md and split into reference docs

## Notes

- **Trigger scenario in `description` is critical.** Skills without explicit "use when …" phrasing in their description are unlikely to be selected by the model. The fix is to enumerate concrete user actions: "writing a new playbook", "creating or modifying a role", etc.
- **Routing table redundancy pattern.** A "Step 1 — table of topics → docs" followed by "Step 2 — list of the same docs with descriptions" is pure duplication. Merge them into a single 3-column table (topic / doc / covers).
- **Table alignment in `SKILL.md` has non-trivial token cost.** Prettier-aligned padding in the routing table of a skill file is loaded on every invocation. Keep `SKILL.md` compact; alignment is acceptable in reference docs that are loaded on demand and benefit human readers.
- **`| bool` vs `is truthy` vs YAML bool are genuinely different mechanisms.** `ansible.builtin.bool` uses a strict allowlist — integers other than 0/1, non-empty lists, dicts, and arbitrary strings all silently return `False` with a deprecation warning. `is ansible.builtin.truthy` delegates to Python `bool()`. Confusing the two is a common source of silent bugs.
- **`or` as a fallback is unsafe for falsy values.** `primary or fallback` skips `primary` whenever it is falsy, regardless of whether it was intentionally set. Use `| default(fallback)` (undefined-only) or `| default(fallback, true)` (undefined-or-falsy) according to whether a falsy value is meaningful.
- **FQCN applies to filters and tests too, not just modules.** `| bool`, `| to_nice_yaml`, `is truthy` etc. should be written as `| ansible.builtin.bool`, `| ansible.builtin.to_nice_yaml`, `is ansible.builtin.truthy` for consistency and clarity.
