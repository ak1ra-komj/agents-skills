# Developing Ansible Filter and Test Plugins

Filter and test plugins add Python logic to the Jinja2 expressions used by
playbooks, roles, and templates. Filters transform data (`value | my_filter`);
tests answer a boolean question (`value is my_test`). Both run on the control
node and share one namespace with all other plugins. This document covers
these two plugin types; for action, callback, connection, inventory, lookup,
and vars plugins, see the Ansible
[Developing plugins](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_plugins.html)
guide.

Reach for a custom plugin only when the builtin toolset runs out: the Jinja2
builtins (see [jinja2.md](jinja2.md)), `ansible.builtin` plugins, and plugins
from installed collections cover most needs.

## When to Write a Plugin

Use a custom filter plugin when a data transformation is complex enough that
expressing it in Jinja2 hurts readability or correctness. Treat any of these
as the signal:

- It needs more than a couple of chained filters, or `{% set %}` variables
  that only hold intermediate results.
- It needs control flow: loops with accumulators, mutation while iterating,
  nested conditionals, or validation that rejects bad input early.
- It relates structures to each other: it builds a lookup index keyed by an
  attribute, joins lists on a key, groups and aggregates, or resolves
  cross-references.
- It applies project-specific semantics: custom merge, deduplication,
  ordering, or normalization that a single builtin filter cannot express.
- It must fail with a message that names the offending value.
- It is reused across templates or roles, or it is part of a role's public
  variable contract.

Write a test plugin when the same boolean check is repeated in `when:`,
`assert`, or a `select`-family filter, and the builtin tests cannot express
it. Tests must return a boolean; a transformation that returns any other type
belongs in a filter.

Keep single builtin filters, one-line `selectattr` / `map` chains, and Python
method calls on individual values inline. A plugin adds a Python file that
must be loaded, documented, and tested, so pay that cost only when it buys
back readability or reuse.

## Filter Plugins

A filter plugin is a Python file exposing a `FilterModule` class whose
`filters()` method maps names to callables:

```python
# filter_plugins/myapp.py
from ansible.errors import AnsibleFilterError


def listener_index(listeners, key="name"):
    """Build a {key: listener} mapping from a list of listener mappings."""
    if not isinstance(listeners, list):
        raise AnsibleFilterError(
            f"listener_index expects a list, got {type(listeners).__name__}"
        )
    index = {}
    for listener in listeners:
        if not isinstance(listener, dict) or key not in listener:
            raise AnsibleFilterError(
                f"listener_index: entry without '{key}': {listener!r}"
            )
        index[listener[key]] = listener
    return index


class FilterModule(object):
    def filters(self):
        return {"myapp_listener_index": listener_index}
```

```jinja2
{% set upstreams_by_name = upstreams | myapp_listener_index %}
proxy_pass http://{{ upstreams_by_name[upstream].host }}:{{ upstreams_by_name[upstream].port }};
```

- The value on the left of `|` is the first argument; additional arguments
  follow, positional or by keyword.
- A filter may return any type, including lists and dicts.
- Several related filters can share one file and one `FilterModule` class;
  more than one plugin per file is normal.

## Test Plugins

A test plugin is a Python file exposing a `TestModule` class whose `tests()`
method maps names to callables returning a boolean:

```python
# test_plugins/myapp.py
from ansible.errors import AnsibleFilterError


def online(host):
    """Return True when a single host entry reports online."""
    if not isinstance(host, dict):
        raise AnsibleFilterError(
            f"online expects a mapping, got {type(host).__name__}"
        )
    return bool(host.get("online", False))


class TestModule(object):
    def tests(self):
        return {"myapp_online": online}
```

```jinja2
{% set offline = upstreams | reject('myapp_online') | list %}
```

```yaml
- name: Report every offline upstream
  ansible.builtin.debug:
    msg: "{{ item.name }} is offline"
  loop: "{{ upstreams | reject('myapp_online') | list }}"

- name: Run only when the primary upstream is online
  ansible.builtin.debug:
    msg: Primary upstream is online
  when: primary_upstream is myapp_online
```

## Loading and Naming

- Standalone plugins load from a `filter_plugins/` or `test_plugins/`
  directory adjacent to the playbook or inside a role, or from paths
  configured with the `filter_plugins` / `test_plugins` settings in
  `ansible.cfg` (`$ANSIBLE_FILTER_PLUGINS`, `$ANSIBLE_TEST_PLUGINS`).
  Adjacent directories must use the `_plugins` suffix.
- Prefix standalone filter and test names (`myapp_`) - they share one
  namespace with every installed plugin.
- Publish shared plugins in a collection under `plugins/filter/` and
  `plugins/test/`, and call them by FQCN (`namespace.collection.name`). A
  role that lives inside a collection cannot carry plugins of its own.
- Document collection plugins with a `DOCUMENTATION` block (or an adjacent
  YAML file) containing `name`, `short_description`, `description`, and
  `options`, where `_input` describes the value on the left of `|` / `is`;
  `ansible-doc -t filter <fqcn>` and `ansible-doc -t test <fqcn>` then
  render it.

## Dependencies and Environments

Plugins import third-party packages from the environment that runs Ansible,
not from the project virtual environment; to provide them, extend that
environment or run Ansible from the project venv - see
[installing-ansible.md](installing-ansible.md).

Use a project virtual environment for development only: lint, type checking,
and unit tests. A `pyproject.toml` with `[tool.uv] package = false` and
dependency groups fits a collection or playbook repository well:

```toml
[dependency-groups]
lint = ["ansible-core>=2.19", "ruff", "ty"]
test = ["ansible-core>=2.19", "pytest"]
```

- `ansible-core` belongs in the dev groups because `uv run pytest` and
  `uv run ty check` execute in the project venv, not in the venv that
  provides the `ansible` command: pytest imports `ansible.*`, and a type
  checker needs ansible-core installed to resolve `ansible.*` imports.
- Keep `[project].dependencies` empty unless the repository is a real Python
  package; a collection is not one.

For collections:

- `galaxy.yml` declares collection dependencies, and `ansible-galaxy`
  installs those; it does not install Python packages.
- To have Ansible Builder install controller-side Python dependencies when
  it builds an execution environment, declare them in `requirements.txt` at
  the collection root, or point `meta/execution-environment.yml` at other
  files. Collections such as `ansible.netcommon` and `amazon.aws` ship that
  file. See
  [Collection-level dependencies](https://docs.ansible.com/projects/builder/en/latest/collection_metadata).
- Test-only packages belong in `tests/unit/requirements.txt` or
  `tests/integration/requirements.txt`; `ansible-test` installs them.

## Errors and Undefined Values

- Raise `AnsibleFilterError` with a message that includes the offending
  value. The generic `AnsibleError` also works when nothing more specific
  fits.
- Do not catch `jinja2.exceptions.UndefinedError`; Ansible propagates it as
  `AnsibleUndefinedVariable` so undefined variables are fatal only when the
  value is actually needed.
- Raise `AnsibleTypeError` for type errors on ansible-core 2.19+;
  `AnsibleFilterTypeError` is deprecated and is removed in ansible-core
  2.23. Check the installed Ansible version's error classes when unsure.
- Keep plugins free of side effects: Ansible evaluates variables lazily and
  may re-render a template, so a plugin can run more than once for the same
  data.

## Testing

- In a collection, put unit tests under `tests/unit/plugins/filter/` or
  `tests/unit/plugins/test/` and run them with `ansible-test units`; run
  `ansible-test sanity` to validate plugin documentation before publishing.
- For standalone `filter_plugins/` files, import the module in a plain
  `pytest` test - the filter and test functions are ordinary Python.
- Exercise the plugin from a scratch playbook: filters in a `debug` task,
  tests in `when:` and in `select` / `reject` expressions.

See also:

- [Developing plugins](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_plugins.html)
- [Adding modules and plugins locally](https://docs.ansible.com/projects/ansible/latest/dev_guide/developing_locally.html)
- [Adjacent YAML documentation files](https://docs.ansible.com/projects/ansible/latest/dev_guide/sidecar.html)
- [Using filters to manipulate data](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_filters.html)
- [Tests](https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_tests.html)
