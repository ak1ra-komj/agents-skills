# Ansible Reference Code Blocks

Canonical patterns to compose from when writing Ansible code.
Include only the blocks that the playbook or role actually needs.

## Error Handling - block/rescue/always

Use this pattern for tasks that may fail and require recovery or guaranteed cleanup:

```yaml
- name: "Risky operation with recovery"
  block:
    - name: "Task that might fail"
      ansible.builtin.command: /bin/risky

  rescue:
    - name: "Recovery action"
      ansible.builtin.debug:
        msg: "Recovering from failure..."

  always:
    - name: "Cleanup temporary file"
      ansible.builtin.file:
        path: /tmp/temp
        state: absent
```

- `block`: the primary task sequence.
- `rescue`: runs only when a task in `block` fails; use it for recovery logic.
- `always`: runs unconditionally after `block` or `rescue`; use it for cleanup.

## Template Task Pair

```yaml
- name: "Render nginx virtualhost config"
  ansible.builtin.template:
    src: nginx-vhost.conf.j2
    dest: '/etc/nginx/sites-available/{{ site_name }}.conf'
    owner: root
    group: root
    mode: "0644"
  notify: "Reload nginx"
```

## Handler

```yaml
- name: "Reload nginx"
  ansible.builtin.service:
    name: nginx
    state: reloaded
```

## shell/command with Idempotency Guards

```yaml
- name: "Compile application"
  ansible.builtin.command:
    cmd: make build
    chdir: /opt/app
  creates: /opt/app/bin/app
  changed_when: false
```

## Wait for Readiness

Wait for an observable condition instead of sleeping:

```yaml
- name: "Wait for the API to become ready"
  ansible.builtin.uri:
    url: "http://127.0.0.1:8080/health"
    status_code: 200
  register: api_health
  until: api_health.status == 200
  retries: 30
  delay: 2
```

## Include a Role from Tasks

```yaml
- name: "Apply the application role"
  ansible.builtin.include_role:
    name: my_namespace.my_collection.application
  vars:
    application_port: 8080
```
