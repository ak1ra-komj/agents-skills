# Developing Ansible Roles

Covers the directory layout, variable placement, and handler rules for Ansible roles.

See [common.md](common.md) for baseline style and project conventions.

## Directory Structure

Follow the standard Ansible Galaxy role layout:

```
roles/
  <role_name>/
    defaults/
      main.yaml     # Overridable defaults
    vars/
      main.yaml     # Static role variables
    tasks/
      main.yaml     # Main task entry point
    handlers/
      main.yaml     # Notify-triggered handlers
    templates/      # Jinja2 templates (.j2)
    files/          # Static files for copy
    meta/
      main.yaml     # Role metadata and dependencies
```

## Variable Placement

| Location                    | Purpose                                             |
| --------------------------- | --------------------------------------------------- |
| `defaults/main.yaml`        | Default values intended to be overridden by callers |
| `vars/main.yaml`            | Role-internal constants not meant to be overridden  |
| `group_vars/`, `host_vars/` | Inventory-bound values (outside the role)           |

- You MUST NOT duplicate a variable in both `defaults/` and `vars/` for the same role.
- You SHOULD document all variables in `defaults/main.yaml` with inline comments.

## Handlers

- Define service restart and reload actions as handlers in `handlers/main.yaml`.
- You MUST use `notify` to trigger handlers; you MUST NOT restart services directly from tasks.
- Handler names MUST be globally unique within a play.

## Dependencies

- Declare role dependencies in `meta/main.yaml`.
- You SHOULD keep inter-role dependencies minimal; prefer composing roles in the playbook instead.
