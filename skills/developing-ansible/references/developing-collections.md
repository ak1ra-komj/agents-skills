# Developing Ansible Collections

Covers collection structure, plugin layout, variables, documentation, licensing, dependencies, and versioning.

## When to Use a Collection

- Use a collection when reusable roles, plugins, and docs need versioned distribution.
- Do not create a collection for a single role that no one else consumes; keep it in a playbook project until it matures.
- Organize collections at type or landscape level, not per individual role.
- Package multiple related roles together and put shared content in a common role.

## Structure

```text
<namespace>/<collection>/
  galaxy.yml
  README.md
  LICENSE
  meta/
    runtime.yml
  roles/
    <role_name>/
  plugins/
    filter/
    test/
    modules/
  tests/
    unit/
    integration/
  docs/
    docsite/
      rst/
```

- Scaffold with `ansible-creator init collection`; extend with `ansible-creator add`.
- Keep module directories flat; migrate deep directory layouts with redirects in `meta/runtime.yml`.
- Keep roles reusable outside the collection; do not hide required behavior in collection-only paths.
- Document collection variables separately from role variables.
- Use `module_utils/` and `plugin_utils/` for shared Python code.

## Naming and FQCN

- Use the collection FQCN for every module, role, and plugin.
- Prefer `ansible.builtin` for internal Ansible actions; use `ansible.legacy` only for deliberate local overrides.
- Do not use the `collections` keyword; FQCNs are explicit and avoid ambiguity.
- Use canonical module names; redirects may work, but the canonical name is clearer and faster.
- Avoid variable collisions when roles are reused; prefix public variables with the role name.

## Variables

- Create implicit collection variables referenced from role defaults.
- Prefer the pattern `role_name_var` followed by `collection_name_var`.
- Keep role defaults overridable; use `vars/` only for constants.
- Do not let collection variables duplicate inventory variables for the same desired state.

## Documentation

- Include a README in the collection root with the collection purpose, license link, supported `ansible-core` versions, required libraries, and usage.
- Generate plugin documentation from code.
- Put supplemental documentation under `docs/docsite/rst/`.
- Use standard Markdown with clear headings, a table of contents, and language-tagged code blocks.

## License

- Include `LICENSE` or `COPYING` in the collection root.
- Note different licenses in file headers when applicable.

## Dependencies and Execution Environments

- Declare collection dependencies in `galaxy.yml`; `ansible-galaxy` installs them but does not install Python packages.
- Declare controller-side Python dependencies in `requirements.txt` at the collection root, or point `meta/execution-environment.yml` at other files.
- Put test-only packages in `tests/unit/requirements.txt` or `tests/integration/requirements.txt`.
- Pin the execution environment, collections, and Python dependencies for deterministic builds.
- See [developing-plugins.md](developing-plugins.md) for plugin development environments and [installing-ansible.md](installing-ansible.md) for the control-node toolchain.

## Versioning and CI

- Use semantic versioning; keep `0.y.z` before the first stable release.
- Maintain a CHANGELOG for safe upgrades.
- Run `ansible-test sanity` and `ansible-test units`, `ansible-lint`, and Molecule scenarios under `extensions/molecule/`.
- Test every supported OS and `ansible-core` version in CI.
- Keep Molecule scenarios under `extensions/molecule/` in collection mode; see [molecule-scenarios.md](molecule-scenarios.md).
