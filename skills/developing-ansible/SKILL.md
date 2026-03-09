---
name: developing-ansible
description: Use when writing, reviewing, or refactoring Ansible playbooks, roles, or tasks.
---

# developing-ansible skill

This skill covers any task involving **writing, reviewing, or refactoring** Ansible playbooks, roles, or tasks.

## Rule of Thumb

If the project already has existing examples, always follow them in terms of structure, naming, and style to maintain consistency.
If no relevant examples exist, apply the guidelines defined in this skill and its reference documents.

## Reference Documents

Always load:

- **[common.md](common.md)** — baseline requirements that apply to all Ansible files.
- **[developing-tasks.md](developing-tasks.md)** — task key ordering, FQCN, module selection, `loop`; tasks are the fundamental unit present in both playbooks and roles.

Then load only the documents that match the request:

- **[developing-playbooks.md](developing-playbooks.md)** — Load when writing or reviewing playbook files: play definitions, `import_*` vs `include_*`, error handling at play level.
- **[developing-roles.md](developing-roles.md)** — Load when creating or modifying a role: directory layout, `defaults/`, `vars/`, `handlers/`, `meta/`.
- **[handling-boolean-values.md](handling-boolean-values.md)** — Load when the code involves boolean variables, `| ansible.builtin.bool`, or `is ansible.builtin.truthy` expressions.
- **[jinja2-templates.md](jinja2-templates.md)** — Load when working with `.j2` template files or Jinja2 filter/macro expressions.
- **[reference-code-blocks.md](reference-code-blocks.md)** — Load when composing `block/rescue/always` patterns or other reusable canonical patterns.
