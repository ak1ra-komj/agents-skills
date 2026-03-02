# Ansible Reference Code Blocks

Canonical patterns to compose from when writing Ansible code.
Only include blocks that the playbook or role actually needs.

## Error Handling — block/rescue/always

Use this pattern for tasks that may fail and require recovery or guaranteed cleanup:

```yaml
- name: Risky operation with recovery
  block:
    - name: Task that might fail
      ansible.builtin.command: /bin/risky

  rescue:
    - name: Recovery action
      ansible.builtin.debug:
        msg: "Recovering from failure..."

  always:
    - name: Cleanup temporary file
      ansible.builtin.file:
        path: /tmp/temp
        state: absent
```

- `block`: the primary task sequence.
- `rescue`: runs only when a task in `block` fails; use for recovery logic.
- `always`: runs unconditionally after `block` or `rescue`; use for cleanup.

## Play Definition

Minimal canonical play structure:

```yaml
- name: Configure web servers
  hosts: web
  gather_facts: true
  become: true

  tasks:
    - name: Ensure nginx is installed
      ansible.builtin.package:
        name: nginx
        state: present
      notify: Restart nginx

  handlers:
    - name: Restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted
```

## Loop with Custom Loop Variable

```yaml
- name: Create directories
  ansible.builtin.file:
    path: "{{ dir.path }}"
    state: directory
    mode: "{{ dir.mode | default('0755') }}"
  loop: "{{ directories }}"
  loop_control:
    loop_var: dir
    label: "{{ dir.path }}"
```

## Template Task Pair

```yaml
- name: Render nginx virtualhost config
  ansible.builtin.template:
    src: nginx-vhost.conf.j2
    dest: /etc/nginx/sites-available/{{ site_name }}.conf
    owner: root
    group: root
    mode: "0644"
  notify: Reload nginx
```

## shell/command with Idempotency Guards

```yaml
- name: Compile application
  ansible.builtin.command:
    cmd: make build
    chdir: /opt/app
  creates: /opt/app/bin/app
  changed_when: false
```
