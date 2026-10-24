---
name: developing-ansible
description: Use when writing, reviewing, or refactoring Ansible playbooks, roles, or tasks, or when developing custom filter/test plugins or setting up the control-node environment.
---

# developing-ansible skill

## Rule of Thumb

If the project already has existing examples, follow them in terms of structure, naming, and style to maintain consistency.
If no relevant examples exist, apply the guidelines defined in this skill and its reference documents.

## Related Skills

When the task involves Molecule scenarios, lifecycle playbooks, or `molecule.yml`,
load the **`developing-ansible-molecule`** skill in addition to this one. It
covers scenario design, ansible-native configuration, inventory, and verifier
patterns.

## Reference Documents

Load:

- **[references/common.md](references/common.md)** - baseline requirements that apply to all Ansible files.
- **[references/developing-tasks.md](references/developing-tasks.md)** - task key ordering, FQCN, module selection, `loop`; tasks are the fundamental unit present in both playbooks and roles.

Then load only the documents that match the request:

- **[references/developing-playbooks.md](references/developing-playbooks.md)** - Load when writing or reviewing playbook files: play definitions, `import_*` vs `include_*`, error handling at play level.
- **[references/developing-roles.md](references/developing-roles.md)** - Load when creating or modifying a role: directory layout, `defaults/`, `vars/`, `handlers/`, `meta/`.
- **[references/handling-boolean-values.md](references/handling-boolean-values.md)** - Load when the code involves boolean variables, `| ansible.builtin.bool`, or `is ansible.builtin.truthy` expressions.
- **[references/jinja2.md](references/jinja2.md)** - Load when working with `.j2` template files or with Jinja2 expressions anywhere (filters, tests, conditions, defaults, undefined handling).
- **[references/developing-plugins.md](references/developing-plugins.md)** - Load when writing custom filter or test plugins, or deciding whether a transformation belongs in a plugin.
- **[references/installing-ansible.md](references/installing-ansible.md)** - Load when installing or upgrading Ansible on the control node, or when controller-side code needs extra Python dependencies.
- **[references/reference-code-blocks.md](references/reference-code-blocks.md)** - Load when composing `block/rescue/always` patterns or other reusable canonical patterns.
