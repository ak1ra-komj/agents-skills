# Common Ansible Requirements

Applies to all Ansible files: playbooks, roles, tasks, variable files, and templates.

## Code Style and Formatting

- YAML files MUST use consistent 2-space indentation.
- YAML files MUST use the `.yaml` extension, not `.yml`.
- Task names MUST be clear, descriptive, and meaningful.
- Formatting SHOULD remain consistent across all files.
- Boolean literals MUST use lowercase `true`/`false`; you MUST NOT use `yes`/`no`, `on`/`off`, or strings.
- For conditional expressions and module parameters involving booleans, see [handling-boolean-values.md](handling-boolean-values.md).

## Project Layout

- You MUST NOT hard-code hosts or environment-specific values in playbooks or roles.
- Inventory-bound variables MUST live in `group_vars/` or `host_vars/`.
- Secrets MUST be stored exclusively in Ansible Vault and MUST NOT appear in plaintext variable files.

## Validation

- You MUST validate playbooks with `ansible-lint` before committing.
- You SHOULD run `ansible-playbook --syntax-check` to catch structural errors early.
