# Developing Ansible Roles

Covers the directory layout, variable placement, and handler rules for Ansible roles.

See [common.md](common.md) for baseline style and project conventions.

## Directory Structure

You SHOULD follow the standard Ansible Galaxy role layout:

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

- Service restart and reload actions MUST be defined as handlers in `handlers/main.yaml`.
- Tasks MUST use `notify` to trigger handlers and MUST NOT restart services directly.
- Handler names MUST be globally unique within a play.

## Dependencies

- Role dependencies MUST be declared in `meta/main.yaml`.
- Inter-role dependencies SHOULD remain minimal; you SHOULD prefer composing roles in the playbook instead.
