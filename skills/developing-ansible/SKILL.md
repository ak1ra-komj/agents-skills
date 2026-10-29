---
name: developing-ansible
description: Use when writing, reviewing, or refactoring Ansible playbooks, roles, collections, inventories, tasks, or Molecule tests, or when developing custom filter/test plugins or setting up the control-node environment.
---

# developing-ansible skill

## Rule of Thumb

If the project already has existing examples, follow them in terms of structure, naming, and style to maintain consistency.
If no relevant examples exist, apply the guidelines defined in this skill and its reference documents.

## Guiding Principles

When a specific rule is unclear, fall back to the Zen of Ansible:

- Ansible is not Python, and playbooks are not for programming. Keep logic in modules and roles, not in YAML.
- Clear is better than cluttered; concise is better than verbose; simple is better than complex.
- Prefer declarative modules over imperative commands, convention over configuration, and FQCNs over short names.
- Use the smallest change that solves the problem. Start simple and add complexity only when justified.
- Every repeated shell command or manual step is a candidate for automation.

## Project Type

Choose the project shape before writing content:

- A **collection project** packages reusable roles, plugins, and docs for distribution.
- A **playbook project** orchestrates a landscape and keeps an adjacent in-repo collection until it is mature enough to publish.

Scaffold either with `ansible-creator`; see [references/developing-projects.md](references/developing-projects.md) for layouts, versioning, and CI.

## Testing with Molecule

When the task involves Molecule scenarios, lifecycle playbooks, or `molecule.yml`,
load [references/molecule-workflow.md](references/molecule-workflow.md) first, then
the focused reference for the work.

- Lifecycle playbooks are ordinary playbooks; all rules in this skill apply.
- Default to ansible-native configuration. Do not emit new `driver:`,
  `platforms:`, or `provisioner:` blocks; those are legacy constructs.
- Treat the test instance as an ordinary managed node, not an Ansible development
  environment.
- Follow existing scenario style; do not migrate a working legacy scenario unless
  the user asks for migration.
- Confirm the installed Molecule version with `molecule --version` before relying
  on a flag, schema key, or scenario layout.

## Reference Documents

Load:

- **[references/common.md](references/common.md)** - baseline formatting, naming, project, and validation requirements that apply to all Ansible files.
- **[references/developing-tasks.md](references/developing-tasks.md)** - task key ordering, FQCN, module selection, conditionals, `loop`; tasks are the fundamental unit present in both playbooks and roles.

Then load only the documents that match the request:

- **[references/developing-projects.md](references/developing-projects.md)** - Load when starting a collection or playbook project, choosing a layout, or setting up version control, CI, and releases.
- **[references/developing-collections.md](references/developing-collections.md)** - Load when creating or modifying a collection: `galaxy.yml`, plugin layout, module organization, docs, and licensing.
- **[references/developing-playbooks.md](references/developing-playbooks.md)** - Load when writing or reviewing playbook files: play definitions, `import_*` vs `include_*`, tags, output, waiting, and error handling at play level.
- **[references/developing-roles.md](references/developing-roles.md)** - Load when creating or modifying a role: design, directory layout, `defaults/`, `vars/`, handlers, templates, platform support, `meta/`.
- **[references/developing-inventories.md](references/developing-inventories.md)** - Load when designing inventory, `group_vars`/`host_vars`, dynamic sources, SSOT, or variable precedence.
- **[references/handling-boolean-values.md](references/handling-boolean-values.md)** - Load when the code involves boolean variables, `| ansible.builtin.bool`, or `is ansible.builtin.truthy` expressions.
- **[references/jinja2.md](references/jinja2.md)** - Load when working with `.j2` template files or with Jinja2 expressions anywhere (filters, tests, conditions, defaults, undefined handling).
- **[references/developing-plugins.md](references/developing-plugins.md)** - Load when writing custom filter or test plugins, or deciding whether a transformation belongs in a plugin.
- **[references/molecule-workflow.md](references/molecule-workflow.md)** - Load when planning, implementing, or validating a Molecule scenario: inspect, decide, implement, validate, and run commands.
- **[references/molecule-native.md](references/molecule-native.md)** - Load when writing or reviewing `molecule.yml`, inventory, dependencies, executor options, or the ansible-native versus legacy choice.
- **[references/molecule-scenarios.md](references/molecule-scenarios.md)** - Load when choosing scenario layout: default versus extra scenarios, OS matrix, multi-node, nested collection scenarios, shared state, side effects, upgrade, and reboot.
- **[references/molecule-testing-patterns.md](references/molecule-testing-patterns.md)** - Load when writing `converge.yml` or `verify.yml`, or when testing idempotence, services, and systemd.
- **[references/installing-ansible.md](references/installing-ansible.md)** - Load when installing or upgrading Ansible on the control node, or when controller-side code needs extra Python dependencies.
- **[references/reference-code-blocks.md](references/reference-code-blocks.md)** - Load when composing `block/rescue/always` patterns or other reusable canonical patterns.
