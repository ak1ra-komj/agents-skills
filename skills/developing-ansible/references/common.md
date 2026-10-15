# Common Ansible Requirements

Applies to all Ansible files: playbooks, roles, tasks, variable files, and templates.

## Code Style and Formatting

- Use 2-space indentation consistently in all YAML files.
- You SHOULD use the `.yaml` extension, not `.yml`.
- Write task names that are clear, descriptive, and meaningful.
- Keep formatting consistent across all files.
- You SHOULD use lowercase `true` / `false` for boolean literals; you SHOULD NOT use `yes` / `no`, `on` / `off`, or strings.
- For conditional expressions and module parameters involving booleans, see [handling-boolean-values.md](handling-boolean-values.md).

## Jinja2 Filters and Tests

Filters (`value | filter`) and tests (`value is test`) resolve plugin names
differently from modules:

- Jinja2 builtin filters and tests keep their bare names, e.g. `default`,
  `selectattr`, `join`, `is defined`.
- Filters and tests provided by a collection MUST be written with their FQCN,
  e.g. `ansible.builtin.to_json`, `ansible.builtin.combine`,
  `is ansible.builtin.truthy`, `community.general.json_query`. Names outside
  the Jinja2 builtin lists are not automatically `ansible.builtin`; the
  namespace shows where the plugin is defined.
- Unlike modules, the `collections:` keyword provides no short-name fallback
  for filters and tests, so a plugin from another collection is reachable only
  through its FQCN.
- Many names look like Jinja2 builtins but are not: `bool`, `to_json`,
  `to_yaml`, `combine`, `flatten`, `zip`, `regex_replace`, `ternary`,
  `b64encode`, `json_query`.

See [jinja2.md](jinja2.md) for the Jinja2 3.1 builtin lists and namespace
exceptions.

## Project Layout

- You MUST NOT hard-code hosts or environment-specific values in playbooks or roles.
- Place inventory-bound variables in `group_vars/` or `host_vars/`.
- You MUST store secrets exclusively in Ansible Vault; you MUST NOT put them in plaintext variable files.

## Validation

- You SHOULD validate playbooks with `ansible-lint` before committing.
- Run `ansible-playbook --syntax-check` to catch structural errors early.
