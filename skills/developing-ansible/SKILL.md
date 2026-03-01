---
name: developing-ansible
description: Comprehensive guidelines for Ansible development, covering playbooks, roles, tasks, modules, and project management. Focuses on structure, idempotency, and best practices.
---

# developing-ansible skill

This skill defines the guidelines for generating, modifying, or reviewing Ansible code. It consolidates best practices for playbooks, roles, tasks, and project configuration.

## Rule of Thumb

If the project already has existing examples, always follow them in terms of structure, naming, and style to maintain consistency.
If no relevant examples exist, apply the guidelines defined in this skill.

## Code Style and Formatting

- Use YAML with consistent 2-space indentation.
- Use `.yaml` extension (not `.yml`) for all YAML files.
- Write clear, descriptive, and meaningful task names.
- Keep formatting consistent across all files.

## Playbook Structure

- Each play must define name, hosts, gather_facts, and become.
- Prefer import_tasks and import_playbook over dynamic includes when appropriate.
- Use block, rescue, and always to implement explicit error handling.
- Ensure all playbooks are idempotent, deterministic, and repeatable.

## Role Architecture

- Follow the standard Ansible Galaxy role directory structure.
- Place default variables in defaults/main.yaml (easily overridden).
- Place static variables in vars/main.yaml (not meant to be overridden).
- Document role dependencies in meta/main.yaml.
- Restart/reload services only via handlers in handlers/main.yaml.
- Use handlers to trigger restarts, not direct task execution.

## Task Structure and Modules

- The name key must be present for every task.
- The when key (if used) must appear immediately after name.
- If become is used, it should follow when (or name).
- Always use fully qualified collection names (e.g., ansible.builtin.copy).
- Reference facts via ansible_facts (e.g., ansible_facts['os_family']).
- Use true/false for booleans, not strings.

### Iteration

- Use loop instead of `with_*`.
- Define a custom loop variable via loop_control to avoid variable collisions.

### Module Selection

- Prefer Ansible modules over shell/command.
- Use creates/removes and changed_when/failed_when for shell/command modules to ensure idempotency and correct error reporting.
- Use ansible.builtin.template for configs, ansible.builtin.copy for static files.

## Project Management

- Do not hard-code hosts or environment-specific values. Use group_vars/ and host_vars/.
- Store secrets exclusively in Ansible Vault.
- Validate playbooks using ansible-lint and ansible-playbook --syntax-check.

## Error Handling Pattern

Use block/rescue/always for robust error handling:

```yaml
- block:
    - name: Task that might fail
      ansible.builtin.command: /bin/risky
  rescue:
    - name: Recovery action
      ansible.builtin.debug:
        msg: "Recovering..."
  always:
    - name: Cleanup
      ansible.builtin.file:
        path: /tmp/temp
        state: absent
```
