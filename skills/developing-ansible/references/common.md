# Common Ansible Requirements

Applies to all Ansible files: playbooks, roles, tasks, variable files, and templates.

## Code Style and Formatting

- Use 2-space indentation consistently in all YAML files.
- You SHOULD use the `.yaml` extension, not `.yml`.
- Write task names that are clear, descriptive, and meaningful.
- Keep formatting consistent across all files.
- You SHOULD use lowercase `true` / `false` for boolean literals; you SHOULD NOT use `yes` / `no`, `on` / `off`, or strings.
- For conditional expressions and module parameters involving booleans, see [handling-boolean-values.md](handling-boolean-values.md).

## Project Layout

- You MUST NOT hard-code hosts or environment-specific values in playbooks or roles.
- Place inventory-bound variables in `group_vars/` or `host_vars/`.
- You MUST store secrets exclusively in Ansible Vault; you MUST NOT put them in plaintext variable files.

## Validation

- You SHOULD validate playbooks with `ansible-lint` before committing.
- Run `ansible-playbook --syntax-check` to catch structural errors early.
