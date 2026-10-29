# Common Ansible Requirements

Applies to all Ansible files: playbooks, roles, tasks, variable files, templates, and collection metadata.

## YAML Formatting

- Use 2-space indentation.
- Indent list contents beyond the list definition.
- Use the `.yml` extension for all Ansible YAML files, not `.yaml`.
- Start every YAML file with the `---` document start marker.
- Use double quotes for YAML strings, except Jinja2 expressions, which use single quotes:

  ```yaml
  - name: "Configure web servers"
    ansible.builtin.user:
      name: '{{ user.name }}'
  ```

- Do not quote module keywords such as `present`, `absent`, `true`, or `false`.
- Quote user-facing strings such as descriptions, names, and messages.
- Quote octal values, for example `mode: "0644"`.
- Use lowercase `true` / `false`; do not use `yes` / `no`, `on` / `off`, `True` / `False`, or strings.
- Write module arguments in YAML style, not `key=value` format.
- Split long lines with the folded scalar `>-`, not `>`.
- Break long `when` conditions into a list.
- Keep lines under 160 characters when possible.
- Do not leave trailing whitespace; end every file with a newline.
- Do not duplicate mapping keys.
- Align comments with the content they describe, and keep spacing around colons, commas, and brackets consistent.
- Avoid long runs of blank lines.

For boolean expressions and module parameters, see [handling-boolean-values.md](handling-boolean-values.md).

## Naming

- Use `snake_case` for files, variables, arguments, roles, and dictionary keys.
- Variable names must contain only lowercase alphanumeric characters and underscores.
- Use valid Python identifiers: letters, digits, and underscore only. Do not use dashes in role names.
- Use mnemonic, descriptive names; avoid unnecessary abbreviations, and capitalize unavoidable abbreviations.
- Follow the `object[_feature]_action` pattern for names that should sort consistently.
- Name every play, task, and task block.
- Write task names in imperative form, start them with an uppercase letter, and keep them unique within a play.
- Put Jinja2 templates at the end of task names, not at the beginning.
- Do not use variables in play names or loop variables in task names.
- Prefix tasks in sub-task files with the file identifier.
- Avoid numbering roles and playbooks.
- Prefix role variables with the role name; use a double underscore prefix for role-internal variables.
- Do not use Ansible reserved names, magic variables, or Python keywords as variable names.
- Do not put Jinja2 templating in variable names.
- Variable names must be strings and ASCII.

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

- Choose a collection or playbook project layout; see [developing-projects.md](developing-projects.md).
- Do not hard-code hosts or environment-specific values in playbooks or roles.
- Place inventory-bound variables in `group_vars/` or `host_vars/`; see [developing-inventories.md](developing-inventories.md).
- Store secrets exclusively in Ansible Vault; do not put them in plaintext variable files.
- Use FQCNs for all modules, roles, and plugins. Do not use the `collections` keyword.
- Prefer `ansible.builtin` for internal Ansible actions; use `ansible.legacy` only for deliberate local overrides.
- Use canonical module names. A redirect may work, but the canonical name is clearer and faster.

## Validation

- Run `ansible-lint` before committing.
- Run `ansible-playbook --syntax-check` to catch structural errors early.
- Run Molecule for roles that have scenarios; see [molecule-workflow.md](molecule-workflow.md).
- Run `ansible-test sanity` and `ansible-test units` for collections and plugins.
- Run YAML lint and the Python checks (`ruff format --check`, `ruff check`, `mypy .`, `pydoclint`) when the project provides them.
- Test in a non-production environment first, and test the supported OS and `ansible-core` matrix in CI.
