# Developing Ansible Roles

Covers role design, directory layout, variable placement, handlers, templates, platform support, and documentation.

## Design

- Design roles around functionality, not a specific software implementation.
- Give each role a specific, guaranteed outcome and a limited scope.
- Keep roles loosely coupled and hierarchical; compose them in playbooks.
- Do not hard-depend on external roles or variables; define a clear interface.
- Consumers should not need to understand internal implementation details.
- Put content shared by several roles in a common role inside the collection.

## Directory Structure

Follow the standard Ansible Galaxy role layout:

```text
roles/
  <role_name>/
    defaults/
      main.yml      # Overridable defaults
    vars/
      main.yml      # Static role variables
    tasks/
      main.yml      # Main task entry point
    handlers/
      main.yml      # Notify-triggered handlers
    templates/      # Jinja2 templates (.j2)
    files/          # Static files for copy
    meta/
      main.yml      # Role metadata and dependencies
      argument_specs.yml  # Argument validation
```

- Scaffold with `ansible-galaxy init` or `ansible-creator` for consistency.
- Role names must contain only lowercase alphanumeric characters and underscores, and start with a letter.
- When a standalone role ships custom modules, prefix their names with the role name.
- Use `meta/argument_specs.yml` for argument validation on ansible-core 2.11 and later.
- Break complex task files into discrete files; keep entry files minimal.
- Move reusable Python code to `module_utils/` or `plugin_utils/` when the role lives in a collection.
- Use semantic versioning with `0.y.z` before the first stable release.

## Variable Placement

| Location                    | Purpose                                             |
| --------------------------- | --------------------------------------------------- |
| `defaults/main.yml`         | Default values intended to be overridden by callers |
| `vars/main.yml`             | Role-internal constants not meant to be overridden  |
| `group_vars/`, `host_vars/` | Inventory-bound values (outside the role)           |

- You MUST NOT duplicate a variable in both `defaults/` and `vars/` for the same role.
- Prefix every public default and argument with the role name.
- Prefix internal variables with a double underscore.
- Define provider variables as `role_name_provider` and `role_name_provider_os_default`.
- Give every external argument a default in `defaults/main.yml`; comment out a variable when no meaningful default exists.
- You SHOULD document all variables in `defaults/main.yml` with inline comments.
- Do not give default values in `vars/main.yml`; it has high precedence.
- Use `vars/main.yml` for large lists, magic values, and constants.
- Do not override role defaults or vars with `set_fact`.
- Use the smallest variable scope possible; facts are global.

## Handlers

- Define service restart and reload actions as handlers in `handlers/main.yml`.
- You MUST use `notify` to trigger handlers; you MUST NOT restart services directly from tasks.
- Handler names MUST be globally unique within a play.
- Prefix handler tags with the role name or another unique descriptive prefix.

## Templates

- Add an `ansible_managed` comment at the top of every template.
- Do not include timestamps in templates.
- Use `backup: true` until the user asks for configurability.
- Use the `role_path/subdir/` prefix with variable filenames.
- Append `.j2` to template filenames; keep filenames close to destination system names.
- Prefer `ansible.builtin.template` over `ansible.builtin.copy` for rendered file pushes; use `copy` for static files.
- Avoid `ansible.builtin.lineinfile` where a template or a specific module works.

## Platform Support

- Do not test distribution and version directly in tasks.
- Add variable files under `vars/` for each supported distribution.
- Load platform variables with a `tasks/set_vars.yml` include and `lookup('first_found')`.
- Use the distribution and `os_family` hierarchy.
- Reference facts with bracket notation, e.g. `ansible_facts['os_family']`.
- Handle `gather_facts: false`; run `ansible.builtin.setup` when the role needs facts.
- Explicitly define provider defaults for each supported OS.

```yaml
# tasks/set_vars.yml
- name: "Load platform variables"
  ansible.builtin.include_vars: '{{ lookup("first_found", params) }}'
  vars:
    params:
      files:
        - '{{ ansible_facts["distribution"] }}.yml'
        - '{{ ansible_facts["os_family"] }}.yml'
        - default.yml
      paths:
        - '{{ role_path }}/vars'
```

## Documentation

- Create a meaningful README in the role root.
- Include example playbooks with fully qualified role names.
- List inbound and outbound arguments.
- Document user-facing capabilities, idempotent status, tags, and atomic designation.
- Use RFC-compliant addresses in examples.

## Dependencies

- Declare role dependencies in `meta/main.yml`.
- You SHOULD keep inter-role dependencies minimal; prefer composing roles in the playbook instead.

## Quality Checklist

- All tasks are idempotent; a second run reports no changes.
- Check mode is supported and tasks do not fail in it.
- Tags work standalone and are documented.
- Variables are documented and scoped as narrowly as possible.
