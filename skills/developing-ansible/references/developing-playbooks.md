# Developing Ansible Playbooks

Covers play structure, composition, tags, output, waiting, and error handling.

Molecule lifecycle playbooks are ordinary playbooks covered by these rules.
When writing or reviewing them, also load [molecule-workflow.md](molecule-workflow.md)
for scenario layout, `molecule.yml`, and test execution.

## Play Definition

Every play requires all four top-level keys:

```yaml
- name: "Configure web servers"
  hosts: web
  gather_facts: true
  become: true
```

- `name`: MUST be set; make it descriptive. Do not use variables in play names.
- `hosts`: MUST be set; reference an inventory group or pattern; you MUST NOT hard-code IPs.
- `gather_facts`: SHOULD be set explicitly to `true` or `false`.
- `become`: SHOULD be set explicitly even when `false`.

## Structure and Simplicity

- Keep playbooks as simple as possible; put logic in roles.
- Limit a playbook to a list of roles when possible.
- Use either `roles` or `tasks` in one play, never both.
- Use `roles` for static imports; use `tasks` with `include_role` / `import_role` for dynamic inclusion.
- Decide the structure for each playbook purpose (landscape, type, function, component) and keep it consistent.
- Do not use playbook or play variables for desired state; use inventory instead.
- Do not use host group names directly; use variables.
- Do not import roles by path; use FQCN role names.
- Do not use `meta: end_play`; use `meta: end_host` if only the current host must stop.

## Includes and Imports

- You SHOULD prefer `import_tasks` and `import_playbook` over `include_tasks` and `include_playbook` when the inclusion is unconditional.
- Use `include_tasks` only when the file to include must be determined dynamically at runtime.
- Use `include_role` or `import_role` when a role must be composed from the `tasks` section.

## Tags

- Limit tags to role names and specific meaningful purposes.
- Document every tag and its purpose.
- Each tag must produce a meaningful result when used alone.
- Do not create tags that cannot run standalone.
- Do not create destructive tags that could damage systems.
- Prefix tags in roles with the role name.

## Debug and Output

- Use `ansible.builtin.debug` with the `verbosity` parameter for troubleshooting output.
- Keep verbose output out of normal production runs.
- Prefer descriptive task names over comments.

## Waiting for Conditions

- Wait for specific conditions instead of arbitrary delays.
- Avoid fixed delays with `pause` or `wait_for` timeouts.
- Use `ansible.builtin.wait_for` with appropriate conditions, or `until` with retries.
- Poll for readiness rather than assuming timing.
- Set reasonable timeouts so a play cannot hang indefinitely.
- Check service ports, files, or API endpoints for readiness.

## Idempotency

- Playbooks MUST be idempotent: running them multiple times MUST produce the same end state.
- Tasks SHOULD NOT always report `changed`; use `changed_when` to suppress false positives.
- Support check mode and report changes accurately.
- Tasks should not fail in check mode; use dry-run flags when a command supports them.

## Error Handling

- Use `block` / `rescue` / `always` for explicit error handling.
- See [reference-code-blocks.md](reference-code-blocks.md) for the canonical error handling pattern.
