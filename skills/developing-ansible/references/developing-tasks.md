# Developing Ansible Tasks

Covers task key ordering, module selection, conditionals, iteration, control flow, and check-mode behavior.

## Task Key Ordering

Every task follows this key order:

1. `name` - required; place it first.
2. `when` - if used, immediately after `name`.
3. `become` - if used, follows `when` (or `name` if no `when`).
4. Module key - the actual module and its arguments.
5. `loop` / `loop_control` - if used, after the module.
6. `notify` - if used, near the end.
7. `changed_when` / `failed_when` - if used, last.

## Naming

- Every task and task block has a descriptive `name`.
- Task names within one play must be unique.
- Do not use loop variables in task names.
- Put Jinja2 templates at the end of task names, not at the beginning.

## Module Selection

- You MUST use fully qualified collection names (FQCN), e.g. `ansible.builtin.copy`, not `copy`.
- Prefer specific Ansible modules over `ansible.builtin.shell` / `ansible.builtin.command`; they provide idempotency and error handling.
- Prefer `ansible.builtin.command` over `ansible.builtin.shell` unless shell features are needed.
- Use `ansible.builtin.meta` for meta actions.
- Always specify `state` for modules that support it; define the desired state explicitly instead of relying on defaults.
- Pass package lists to package modules instead of looping over one package at a time.
- Apply the same principle to other modules that accept lists.
- Use specific package managers when platform differences require it.
- Use `ansible.builtin.template` for Jinja2-rendered configs and `ansible.builtin.copy` for static files.
- Avoid `ansible.builtin.lineinfile` where a template or a specific module works.
- Do not use the `collections` keyword; FQCNs are explicit.

## Command and Shell

When `shell` or `command` is unavoidable:

- Add `creates` or `removes` to enable idempotency checks.
- Add `changed_when` and `failed_when` for correct change and error reporting.
- Add a comment explaining why the command is necessary.
- Use `changed_when: false` for read-only commands.
- Handle check mode with dry-run flags when the tool supports them; tasks should not fail in check mode.

## Facts and Variables

- You MUST reference facts via `ansible_facts`, e.g. `ansible_facts['os_family']`.
- Use bracket notation for variable and fact lookup, e.g. `vars['name']`, not `vars.name`.
- Do not use the legacy bare fact names (e.g. `ansible_os_family`).
- Limit `set_fact`; facts are global and can leak across plays.
- Do not override role defaults or vars with `set_fact`.

## Conditionals and Types

- Cast public boolean variables with `| ansible.builtin.bool` when they may arrive as strings.
- Use `float`, `int`, and `bool` filters to cast values at the boundary of the public interface.
- Do not use the `eq`, `equalto`, or `==` Jinja tests for string matching; use `match`, `search`, or `regex`.
- Omit `{{ }}` in `when`, `changed_when`, `failed_when`, and `until`; these fields are implicitly templated.
- Do not compare booleans with `== true` or `== false`; write `when: my_flag` and `when: not my_flag`.

See [handling-boolean-values.md](handling-boolean-values.md) for the full boolean rules.

## Iteration

- You MUST use `loop` instead of any `with_*` construct.
- You SHOULD set a custom loop variable via `loop_control` to avoid variable collisions:

```yaml
- name: "Create user accounts"
  ansible.builtin.user:
    name: '{{ item.name }}'
    state: present
  loop: '{{ users }}'
  loop_control:
    loop_var: item
    label: '{{ item.name }}'
```

## Control Flow

- Use handlers instead of `when: result is changed`.
- Do not use `meta: end_play`; use `meta: end_host` when only the current host must stop.
- Use `block` / `rescue` / `always` for explicit error handling.
- Do not use `ignore_errors: true` casually, especially around blocks that contain asserts.
- Use `notify` to trigger handlers instead of conditional tasks.
- Use `include_*` and `import_*` to reduce repetition.

## Waiting

- Wait for a specific condition instead of a fixed delay.
- Prefer `ansible.builtin.wait_for` with a condition, or `until` with retries.
- Check ports, files, or API endpoints for readiness.
- Set reasonable timeouts so a task cannot hang indefinitely.
