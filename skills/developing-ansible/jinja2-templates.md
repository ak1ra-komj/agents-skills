# Jinja2 Templates in Ansible

Ansible uses Jinja2 for both inline expressions in playbooks/tasks and for
`ansible.builtin.template`-rendered config files. The two contexts are different
but share the same engine — most of the pitfalls below apply to both.

## Whitespace Control

By default, Jinja2 preserves newlines around block tags, which can produce blank
lines in rendered output.

```jinja2
{%- for item in items %}
{{ item.name }}
{%- endfor %}
```

- `{%-` strips whitespace **before** the tag.
- `-%}` strips whitespace **after** the tag.
- Use these consistently inside loops and conditionals to keep rendered files
  clean and diff-friendly.

Set `lstrip_blocks: true` and `trim_blocks: true` in the template header to
apply stripping globally instead of per-tag:

```jinja2
#jinja2: lstrip_blocks: True, trim_blocks: True
```

## Local Variables with `{% set %}`

Declare intermediate values to avoid repeating complex expressions:

```jinja2
{% set listen_addr = item.bind_address | default('0.0.0.0') %}
{% set listen_port = item.port | default(8080) %}
bind {{ listen_addr }}:{{ listen_port }};
```

Avoid deep-nesting filter chains inline — extract them into named variables for
readability and easier review.

## Macros for Repeated Config Blocks

Use `{% macro %}` when the same structural block appears more than once or needs
to be parameterised:

```jinja2
{% macro server_block(name, port, upstream) %}
server {
    server_name {{ name }};
    listen {{ port }};
    location / {
        proxy_pass http://{{ upstream }};
    }
}
{% endmacro %}

{% for vhost in vhosts %}
{{ server_block(vhost.name, vhost.port | default(80), vhost.upstream) }}
{% endfor %}
```

Macros keep templates DRY and make individual blocks independently testable.

## Generating Structured Config Files with JSON / YAML Filters

When a config file format is JSON or YAML, avoid constructing it with raw string
interpolation. Instead, build the data structure in Ansible variables and
serialise it with a filter:

```yaml
- name: Write application config
  ansible.builtin.copy:
    content: "{{ app_config | ansible.builtin.to_nice_yaml(indent=2) }}"
    dest: /etc/myapp/config.yaml
    mode: "0644"
```

| Filter                                      | Output              |
| ------------------------------------------- | ------------------- |
| `\| ansible.builtin.to_json`                | Compact JSON        |
| `\| ansible.builtin.to_nice_json(indent=2)` | Pretty-printed JSON |
| `\| ansible.builtin.to_yaml`                | Compact YAML        |
| `\| ansible.builtin.to_nice_yaml(indent=2)` | Human-readable YAML |

**Prefer this pattern over `ansible.builtin.template` for config files whose
entire content is a single data structure.** It keeps the source of truth in
variables (where it can be validated, merged with `ansible.builtin.combine`, and overridden) rather than
scattered across a template.

Use `ansible.builtin.template` when the file mixes structured data with prose,
comments that must be preserved, or requires per-line conditional logic.

## List and Dict Operations

Use Jinja2 filters instead of tasks to transform data inline:

```jinja2
{# Filter a list to only enabled items #}
{% set active = items | selectattr('enabled', 'true') | list %}

{# Extract a single attribute from each item #}
{% set names = items | map(attribute='name') | list %}

{# Merge two dicts (right side wins on conflict) #}
{% set merged = defaults | ansible.builtin.combine(overrides) %}

{# Flatten a nested list #}
{% set flat = nested_list | ansible.builtin.flatten %}
```

## Default Values and Falsy Variables

The `or` operator and the `| default()` filter interact with falsy values in
different ways. Choosing the wrong one is a common source of silent bugs.

### The `or` Operator Pitfall

Consider a variable that holds a valid value that may legitimately be falsy
(e.g., an integer index set to `0`, a boolean flag set to `false`, an empty
list that means "no items"). Using `or` as a fallback:

```jinja2
{{ primary_value or fallback_value }}
```

When `primary_value` is `0`, Jinja2 evaluates `0 or fallback_value` and returns
`fallback_value` — silently ignoring the explicitly configured value.
**Any falsy value (`0`, `false`, `""`, `[]`, `{}`) causes `or` to skip to the
right-hand side**, regardless of whether the left side was intentionally set.

Avoid `var_a or var_b` as a fallback pattern whenever the primary variable can
legitimately hold a falsy value.

### `| default(fallback)` — undefined only

```jinja2
{{ primary_value | default(fallback_value) }}
```

Substitutes `fallback` only when the variable is **undefined** (raises a Jinja2
`UndefinedError`). If `primary_value` is defined as `0` or `false`, this
returns the defined value correctly.

Use this when the variable may not be set at all, but any defined value —
including falsy ones like `0`, `false`, `""` — should be preserved as-is.

### `| default(fallback, true)` — undefined or falsy

```jinja2
{{ primary_value | default(fallback_value, true) }}
```

The second argument `true` (the `boolean` parameter) extends the substitution
condition: fallback is used when the variable is **undefined OR falsy**.
`0`, `false`, `""`, `[]`, `{}`, and `None` all trigger the fallback.

This behaves identically to `or` for falsy values:
`0 | default(1, true)` → `1`.

Use this **only** when a falsy value genuinely means "not provided" — for
example, falling back to a non-empty string when a variable is an empty string,
or to a non-zero value when zero carries no meaningful value in context.

### Choosing Between Them

| Scenario                                                                              | Correct pattern                       |
| ------------------------------------------------------------------------------------- | ------------------------------------- |
| Variable may be undefined; any defined value (incl. `0`, `false`) is valid            | `\| default(fallback)`                |
| Variable may be undefined or empty string; non-empty string default needed            | `\| default(fallback, true)`          |
| Variable may be undefined or `false`; non-false default needed                        | `\| default(fallback, true)`          |
| Variable may be undefined or `0`; non-zero default and `0` is **not** meaningful here | `\| default(fallback, true)`          |
| Variable is always defined; protect against accidental falsy logic                    | Use `when: var is defined` separately |

## Undefined Variable Behaviour

Ansible uses Jinja2's `StrictUndefined` mode by default — referencing an
undefined variable raises an error immediately rather than silently producing an
empty string.

- Use `| default(...)` to provide a fallback for variables that may not exist.
- Use `is defined` / `is undefined` in `when:` conditions to guard task
  execution:

  ```yaml
  when: my_optional_var is defined
  ```

- Do **not** rely on undefined variables silently collapsing to `""` — this
  behaviour is not guaranteed and hides bugs.
