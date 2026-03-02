# Common Ansible Requirements

Applies to all Ansible files: playbooks, roles, tasks, variable files, and templates.

## Code Style and Formatting

- Use YAML with consistent 2-space indentation.
- Use `.yaml` extension (not `.yml`) for all YAML files.
- Write clear, descriptive, and meaningful task names.
- Keep formatting consistent across all files.
- Use `true`/`false` (lowercase) for boolean literals, not `yes`/`no`, `on`/`off`, or strings.
- For conditional expressions and module parameters involving booleans, see [handling-boolean-values.md](handling-boolean-values.md).

## Project Layout

- Do not hard-code hosts or environment-specific values in playbooks or roles.
- Use `group_vars/` and `host_vars/` for inventory-bound variables.
- Store secrets exclusively in Ansible Vault — never in plaintext variable files.

## Validation

- Validate playbooks with `ansible-lint` before committing.
- Run `ansible-playbook --syntax-check` to catch structural errors early.
