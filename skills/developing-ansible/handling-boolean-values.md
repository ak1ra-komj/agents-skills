# Handling Boolean Values in Ansible

Boolean handling in Ansible is a common source of bugs. The three mechanisms —
YAML booleans, the `| ansible.builtin.bool` filter, and the `is ansible.builtin.truthy` / `is ansible.builtin.falsy` tests —
each behave differently, and mixing them up produces hard-to-debug surprises.

## The Three Mechanisms

### 1. YAML Native Booleans

YAML 1.1 (used by Ansible) recognises a fixed set of keywords as native booleans:

| True                   | False                     |
| ---------------------- | ------------------------- |
| `true`, `True`, `TRUE` | `false`, `False`, `FALSE` |
| `yes`, `Yes`, `YES`    | `no`, `No`, `NO`          |
| `on`, `On`, `ON`       | `off`, `Off`, `OFF`       |

These are parsed into Python `True` / `False` **before** Jinja2 ever sees them.
Any other casing (e.g. `TrUE`, `FaLSe`) is treated as a plain string.

**Rule**: always use `true` / `false` (lowercase) as the canonical form for
boolean literals in YAML. Never use `yes`/`no` or `on`/`off` — they are valid
but ambiguous in prose context.

### 2. `| ansible.builtin.bool` Filter

Converts a value to a Python bool using a **strict allowlist**:

| Converts to `True`                                  | Converts to `False`                                  |
| --------------------------------------------------- | ---------------------------------------------------- |
| `"yes"`, `"on"`, `"true"`, `"1"` (case-insensitive) | `"no"`, `"off"`, `"false"`, `"0"` (case-insensitive) |
| `True` (Python bool), `1` (int)                     | `False` (Python bool), `0` (int), `None`             |

**Values outside the allowlist emit a deprecation warning and fall back to
`False`** (scheduled for removal in Ansible 2.23). This means:

- Integer `42`, `-7` → **`False`** (not in allowlist)
- Non-empty list `[1, 2, 3]` → **`False`**
- Non-empty dict `{"key": "val"}` → **`False`**
- Arbitrary non-empty string `"foo"` → **`False`**

This differs sharply from Python's built-in `bool()`.

### 3. `is ansible.builtin.truthy` / `is ansible.builtin.falsy` Tests

Delegates directly to Python's `bool()`, so any non-empty / non-zero value is
truthy — matching standard Python semantics:

- `42`, `-7` → **truthy**
- `[1, 2, 3]` → **truthy**
- `{"key": "val"}` → **truthy**
- `""`, `[]`, `{}`, `0`, `None` → **falsy**

`is truthy` / `is falsy` accept an optional `convert_bool=True` argument that
first passes the value through `| bool` before evaluating:

```jinja2
{{ "yes" is ansible.builtin.truthy(convert_bool=True) }}  {# True #}
{{ "foo" is ansible.builtin.truthy(convert_bool=True) }}  {# False — "foo" fails bool conversion #}
```

> **Note**: `is ansible.builtin.truthy` / `is ansible.builtin.falsy` are Ansible-specific test plugins.
> They cannot be used in pure Jinja2 environments (e.g. standalone template rendering).

## When to Use Which

| Scenario                                                                  | Recommended                          |
| ------------------------------------------------------------------------- | ------------------------------------ |
| Variable declared in vars / defaults as a feature flag                    | YAML native bool: `my_feature: true` |
| User-supplied string that represents a boolean (`"yes"`, `"true"`, `"1"`) | `\| ansible.builtin.bool` filter                     |
| `when:` condition on a registered result or a Python object               | `is ansible.builtin.truthy` / `is ansible.builtin.falsy` tests       |
| Checking whether a list, dict, or arbitrary value is non-empty            | `is ansible.builtin.truthy` test                     |
| Module parameter that expects a boolean                                   | YAML native bool or `\| ansible.builtin.bool` filter |

## Concrete Rules

**Declare feature flags with YAML native booleans.**

```yaml
# defaults/main.yaml
my_role_enable_tls: true
my_role_debug_mode: false
```

Never use string `"true"` or `"false"` as a default value for a boolean variable.

**Use `| ansible.builtin.bool` only when the source is a string representation of a boolean.**

```yaml
- name: Enable TLS when the env var says so
  when: lookup('env', 'ENABLE_TLS') | ansible.builtin.bool
```

Do not use `| ansible.builtin.bool` on integers other than `0` / `1`, or on lists / dicts — the
result will silently be `False`.

**Use `is ansible.builtin.truthy` when the value may be any Python type and you want Python
semantics.**

```yaml
- name: Run only when result has output
  when: command_result.stdout is ansible.builtin.truthy
```

**Never compare booleans with `== true` or `== false`.**

```yaml
# Bad
when: my_flag == true
when: my_flag == "true"

# Good
when: my_flag
when: not my_flag
```

**Avoid `yes` / `no` and `on` / `off` as boolean literals in task parameters.**
They work but are visually ambiguous:

```yaml
# Bad — "no" reads like an English word, not a boolean
ansible.builtin.service:
  enabled: no

# Good
ansible.builtin.service:
  enabled: false
```

## Quick Reference

```
Value            | type_debug  | | ansible.builtin.bool  | is ansible.builtin.truthy
-----------------+-------------+-----------------------+--------------------------
true             | bool        | True                  | True
false            | bool        | False                 | False
"true"           | str         | True                  | True
"false"          | str         | False                 | False
"yes" / "on"     | str         | True                  | True
"no" / "off"     | str         | False                 | False
1                | int         | True                  | True
0                | int         | False                 | False
42               | int         | False*                | True
"foo"            | str         | False*                | True
[1, 2, 3]        | list        | False*                | True
{"k": "v"}       | dict        | False*                | True
""               | str         | False                 | False
[]               | list        | False                 | False
{}               | dict        | False                 | False
None / null      | NoneType    | False                 | False
```

`*` — emits a deprecation warning in Ansible ≥ 2.19; will become an error in 2.23.
