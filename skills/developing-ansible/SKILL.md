---
name: developing-ansible
description: Use when writing, reviewing, or refactoring Ansible playbooks, roles, or tasks.
---

# developing-ansible skill

This skill covers any task involving **writing, reviewing, or refactoring** Ansible playbooks, roles, or tasks.

## Rule of Thumb

If the project already has existing examples, follow them in terms of structure, naming, and style to maintain consistency.
If no relevant examples exist, apply the guidelines defined in this skill and its reference documents.

## Reference Documents

Load:

- **[references/common.md](references/common.md)** - baseline requirements that apply to all Ansible files.
- **[references/developing-tasks.md](references/developing-tasks.md)** - task key ordering, FQCN, module selection, `loop`; tasks are the fundamental unit present in both playbooks and roles.

Then load only the documents that match the request:

- **[references/developing-playbooks.md](references/developing-playbooks.md)** - Load when writing or reviewing playbook files: play definitions, `import_*` vs `include_*`, error handling at play level.
- **[references/developing-roles.md](references/developing-roles.md)** - Load when creating or modifying a role: directory layout, `defaults/`, `vars/`, `handlers/`, `meta/`.
- **[references/handling-boolean-values.md](references/handling-boolean-values.md)** - Load when the code involves boolean variables, `| ansible.builtin.bool`, or `is ansible.builtin.truthy` expressions.
- **[references/jinja2-templates.md](references/jinja2-templates.md)** - Load when working with `.j2` template files or Jinja2 filter/macro expressions.
- **[references/reference-code-blocks.md](references/reference-code-blocks.md)** - Load when composing `block/rescue/always` patterns or other reusable canonical patterns.
