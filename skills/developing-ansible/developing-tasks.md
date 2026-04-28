# Developing Ansible Tasks

Covers task key ordering, module selection, and iteration.

See [common.md](common.md) for baseline style and project conventions.

## Task Key Ordering

Every task MUST follow this key order:

1. `name` - required and MUST appear first.
2. `when` - if used, immediately after `name`.
3. `become` - if used, follows `when` (or `name` if no `when`).
4. Module key - the actual module and its arguments.
5. `loop` / `loop_control` - if used, after the module.
6. `notify` - if used, near the end.
7. `changed_when` / `failed_when` - if used, last.

## Module Selection

- You MUST use fully qualified collection names (FQCN), e.g. `ansible.builtin.copy`, not `copy`.
- You SHOULD prefer Ansible modules over `ansible.builtin.shell` / `ansible.builtin.command`.
- When `shell` or `command` is unavoidable:
  - Add `creates` or `removes` to enable idempotency checks.
  - Add `changed_when` and `failed_when` for correct change and error reporting.
- You SHOULD use `ansible.builtin.template` for Jinja2-rendered configs.
- You SHOULD use `ansible.builtin.copy` for static files.

## Facts

- You MUST reference facts via `ansible_facts`, e.g. `ansible_facts['os_family']`.
- You MUST NOT use the legacy bare fact names (e.g. `ansible_os_family`).

## Iteration

- You MUST use `loop` instead of any `with_*` construct.
- You MUST set a custom loop variable via `loop_control` to avoid variable collisions:

```yaml
- name: Create user accounts
  ansible.builtin.user:
    name: "{{ item.name }}"
    state: present
  loop: "{{ users }}"
  loop_control:
    loop_var: item
    label: "{{ item.name }}"
```
