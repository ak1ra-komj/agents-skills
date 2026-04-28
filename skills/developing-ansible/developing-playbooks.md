# Developing Ansible Playbooks

Covers the structure and requirements for Ansible playbook files.

See [common.md](common.md) for baseline style and project conventions.

## Play Definition

Every play MUST declare all four top-level keys:

```yaml
- name: Configure web servers
  hosts: web
  gather_facts: true
  become: true
```

- `name`: required and MUST be descriptive.
- `hosts`: required, MUST reference an inventory group or pattern, and MUST NOT hard-code IPs.
- `gather_facts`: required and MUST be set explicitly to `true` or `false`.
- `become`: required and MUST be set explicitly even when `false`.

## Includes and Imports

- You SHOULD prefer `import_tasks` and `import_playbook` over `include_tasks` and `include_playbook` when the inclusion is unconditional.
- You MUST use `include_tasks` only when the file to include must be determined dynamically at runtime.

## Idempotency

- All playbooks MUST be idempotent: running them multiple times MUST produce the same end state.
- Tasks SHOULD NOT always report `changed`; use `changed_when` to suppress false positives.

## Error Handling

- You SHOULD use `block`/`rescue`/`always` for explicit error handling.
- See [reference-code-blocks.md](reference-code-blocks.md) for the canonical error handling pattern.
