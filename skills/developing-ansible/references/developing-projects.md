# Ansible Project Structure

Covers choosing between a collection project and a playbook project, scaffolding, version control, releases, and CI.

## Choose the Project Type

| Project type     | Use when                                                                                                     |
| ---------------- | ------------------------------------------------------------------------------------------------------------ |
| Collection       | Reusable roles, plugins, and docs must be versioned and shared by multiple teams or environments.            |
| Playbook project | Purpose-built orchestration is needed, with tightly scoped roles that do not need external distribution yet. |

Scaffold a collection with `ansible-creator init collection` and a playbook
project with `ansible-creator init playbook`. Extend either with
`ansible-creator add` instead of hand-creating the standard files.

## Collection Project

A collection packages reusable automation building blocks.

```text
<namespace>/<collection>/
  galaxy.yml
  README.md
  LICENSE
  roles/
  plugins/
  meta/
  tests/
  docs/
```

- Keep the standard structure and put related roles, plugins, and docs together.
- Define clear public interfaces with `meta/argument_specs.yml` in each role.
- Implement provider abstraction when the collection supports several platforms.
- Follow the naming and formatting rules in [common.md](common.md).
- Pin execution environments, collections, and Python dependencies for deterministic builds.
- Run `ansible-lint` and Molecule scenarios in CI.
- Use semantic versioning and keep a CHANGELOG.

See [developing-collections.md](developing-collections.md) for collection-specific rules.

## Playbook Project

A playbook project orchestrates a landscape and may carry an adjacent collection.

```text
project/
  playbooks/
  inventories/
    production/
    staging/
  collections/
    ansible_collections/
      <namespace>/<name>/
  ansible.cfg
```

- Put playbooks in `playbooks/` and per-environment inventories in structured directories.
- Keep the adjacent collection in `collections/ansible_collections/<namespace>/<name>/` until it is mature enough to publish.
- Emphasize data-driven inputs and a single source of truth; see [developing-inventories.md](developing-inventories.md).
- Keep As-Is and To-Be information separate.
- Use FQCNs for all modules, roles, and plugins.
- Make all content idempotent and check-mode compatible.
- Pin the execution environment and declare the supported OS and `ansible-core` matrix.
- Run `ansible-lint` and Molecule for roles in CI.

## Starting Approach

- Start with basic playbooks and static inventories.
- Refactor and modularize as the project grows.
- Avoid over-engineering at the beginning; add complexity only when it is justified.
- Build incrementally from a working foundation.

## Version Control

- Manage all Ansible content in Git or another version control system.
- Commit frequently with descriptive messages.
- Use branches for feature development and bug fixes.
- Review changes before merging to the main branch.
- Tag releases with semantic versioning.

## CI and Testing

- Implement unit, integration, and smoke tests where they add value.
- Smoke-test services after they start and fail fast on basic health checks.
- Test playbooks in non-production environments first.
- Test against every supported platform in CI.
- Run `ansible-lint`, YAML lint, `ansible-playbook --syntax-check`, Molecule, and `ansible-test` as applicable.
- Automate the whole test sequence so local runs and CI use the same entry point.
- For Molecule scenarios, load [molecule-workflow.md](molecule-workflow.md).
