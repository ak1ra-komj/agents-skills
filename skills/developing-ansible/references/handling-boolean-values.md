# Handling Boolean Values in Ansible

Boolean handling in Ansible is a common source of bugs. YAML booleans, the
`| ansible.builtin.bool` filter, and the `is ansible.builtin.truthy` /
`is ansible.builtin.falsy` tests each behave differently, and mixing them up
produces hard-to-debug surprises.

## The Three Mechanisms

### 1. YAML Native Booleans

YAML 1.1 (used by Ansible) parses `true` / `false`, `yes` / `no`, and
`on` / `off` (any casing) into Python `True` / `False` before Jinja2 ever sees
them; any other casing such as `TrUE` stays a plain string. See
[common.md](common.md) for the canonical literal style.

### 2. `| ansible.builtin.bool` Filter

Converts a value to a Python bool using a **strict allowlist**:

| Converts to `True`                                  | Converts to `False`                                  |
| --------------------------------------------------- | ---------------------------------------------------- |
| `"yes"`, `"on"`, `"true"`, `"1"` (case-insensitive) | `"no"`, `"off"`, `"false"`, `"0"` (case-insensitive) |
| `True` (Python bool), `1` (int)                     | `False` (Python bool), `0` (int), `None`             |

**Values outside the allowlist emit a deprecation warning and fall back to
`False`.** Integer `42`, non-empty lists and dicts, and arbitrary strings such
as `"foo"` all become `False`, unlike Python's built-in `bool()`. Check the
installed Ansible version's docs for when this becomes an error.

### 3. `is ansible.builtin.truthy` / `is ansible.builtin.falsy` Tests

Delegates directly to Python's `bool()`, so any non-empty / non-zero value is
truthy: `42`, `[1, 2, 3]`, and `{"key": "val"}` are truthy; `""`, `[]`, `{}`,
`0`, and `None` are falsy.

`is truthy` / `is falsy` accept an optional `convert_bool=True` argument that
first passes the value through `| bool`:

```jinja2
{{ "yes" is ansible.builtin.truthy(convert_bool=True) }}  {# True #}
{{ "foo" is ansible.builtin.truthy(convert_bool=True) }}  {# False - "foo" fails bool conversion #}
```

These are Ansible-specific test plugins; they cannot be used in pure Jinja2
environments such as standalone template rendering.

## When to Use Which

| Scenario                                                                  | Recommended                                                    |
| ------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Variable declared in vars / defaults as a feature flag                    | YAML native bool: `my_feature: true`                           |
| User-supplied string that represents a boolean (`"yes"`, `"true"`, `"1"`) | `\| ansible.builtin.bool` filter                               |
| `when:` condition on a registered result or a Python object               | `is ansible.builtin.truthy` / `is ansible.builtin.falsy` tests |
| Checking whether a list, dict, or arbitrary value is non-empty            | `is ansible.builtin.truthy` test                               |
| Module parameter that expects a boolean                                   | YAML native bool or `\| ansible.builtin.bool` filter           |

## Concrete Rules

- Declare feature flags with YAML native booleans. Do not default a boolean
  variable to the strings `"true"` / `"false"`.
- Use `| ansible.builtin.bool` only when the source is a string representation
  of a boolean, for example
  `when: lookup('env', 'ENABLE_TLS') | ansible.builtin.bool`. You MUST NOT
  apply it to integers other than `0` / `1`, or to lists / dicts - the result
  is silently `False`.
- Use `is ansible.builtin.truthy` when the value may be any Python type and you
  want Python semantics, for example
  `when: command_result.stdout is ansible.builtin.truthy`.
- You MUST NOT compare booleans with `== true` or `== false`; write
  `when: my_flag` and `when: not my_flag`.

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

`*` - emits a deprecation warning; will become an error in a future release.
Check the installed Ansible version's docs for the removal version.
