# Developing Ansible Playbooks

Covers the structure and requirements for Ansible playbook files.

See [common.md](common.md) for baseline style and project conventions.

## Play Definition

Every play must declare all four top-level keys:

```yaml
- name: Configure web servers
  hosts: web
  gather_facts: true
  become: true
```

- `name`: required, must be descriptive.
- `hosts`: required, must reference an inventory group or pattern — never hard-code IPs.
- `gather_facts`: required, set explicitly to `true` or `false`.
- `become`: required, set explicitly even when `false`.

## Includes and Imports

- Prefer `import_tasks` and `import_playbook` over `include_tasks` and `include_playbook` when the inclusion is unconditional.
- Use `include_tasks` only when the file to include must be determined dynamically at runtime.

## Idempotency

- Ensure all playbooks are idempotent: running them multiple times must produce the same end state.
- Avoid tasks that always report `changed` — use `changed_when` to suppress false positives.

## Error Handling

- Use `block`/`rescue`/`always` for explicit error handling.
- See [reference-code-blocks.md](reference-code-blocks.md) for the canonical error handling pattern.
