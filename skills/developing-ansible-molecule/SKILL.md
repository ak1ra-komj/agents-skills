---
name: developing-ansible-molecule
description: Use when adding, creating, editing, debugging, or reviewing Molecule tests for Ansible roles, collections, or playbooks. Covers scenarios and lifecycle playbooks (create, prepare, converge, verify, destroy, cleanup, side_effect), inventory, idempotence, verifier design, CI runs, and legacy pre-ansible-native configurations or migration.
---

# developing-ansible-molecule skill

Molecule tests Ansible content by running real Ansible playbooks against real
inventory. This skill covers **adding, creating, modifying, debugging, and
reviewing** Molecule tests in a role, collection, or playbook repository.

## Rule of Thumb

- Default to the current **ansible-native** configuration. Do not emit new
  `driver:`, `platforms:`, or `provisioner:` blocks; those are legacy constructs.
- If the repository already has scenarios, follow their existing style and change
  only what the task requires. Do not migrate a working legacy scenario unless the
  user asks for migration.
- Molecule evolves quickly. When a task depends on exact CLI flags, `molecule.yml`
  schema, nested scenarios, shared state, executor options, or supported
  providers, verify against the current official docs or the installed version
  instead of relying on memory. See "Freshness" below.

## Workflow

### 1. Inspect

Before creating or editing files, establish:

- Project type: standalone role, collection, or playbook repository. This decides
  where scenarios live (`molecule/` versus `extensions/molecule/`).
- Existing scenarios: list the scenario directory and read each `molecule.yml`
  before touching playbooks.
- Configuration generation: does `molecule.yml` use the `ansible:` section
  (ansible-native) or `driver:` / `platforms:` / `provisioner:` (legacy)?
- Supported targets: OS and version list from `meta/main.yml`, collection docs, or
  the CI matrix.
- CI: how tests are invoked today (workflow file, tox, Makefile). Reuse the same
  entry point locally.
- Dependencies: `requirements.yml`, `meta/main.yml`, collection dependencies, and
  the inventory sources a scenario relies on.

Do not restructure an existing Molecule setup just to make one scenario pass.

### 2. Decide

Choose the smallest change that tests the requested behavior:

| Need                                | Approach                                                                |
| ----------------------------------- | ----------------------------------------------------------------------- |
| Another OS or version               | Add an inventory host, or a CI matrix entry                             |
| A different code path               | New scenario, or `side_effect` plus another `converge` / `verify`       |
| Several hosts interacting           | Multiple inventory hosts and groups in one scenario                     |
| Upgrade behavior                    | Dedicated scenario: old version, then converge new version, then verify |
| Reboot or failure handling          | `side_effect` playbook, then `verify` after it                          |
| One resource set for many scenarios | `shared_state: true` with `default` as lifecycle manager                |

Use a container when the content only touches packages, files, and non-init
services. Use a systemd-capable container or a VM when the content needs systemd,
kernel modules, mounts, or a real reboot. See
[references/scenarios.md](references/scenarios.md) for the full decision guide.

### 3. Implement

Respect the lifecycle responsibilities:

- `create.yml` - create test resources only (containers, VMs, networks).
- `prepare.yml` - bring the instance to the state the test requires (base
  packages, users, seeded data). Do not do the role's job here.
- `converge.yml` - call the role or collection the way a real user would.
- `verify.yml` - assert observable end state, not task implementation details.
- `side_effect.yml` - disturb the system between converge runs.
- `destroy.yml` - remove resources safely and repeatably.
- `cleanup.yml` - reset artifacts outside the instance; must tolerate running
  before resources exist, because it runs before every destroy.

### 4. Validate

Run the shortest loop that proves the change, then the full lifecycle before
handing off:

```bash
molecule converge && molecule verify   # inner loop
molecule idempotence                   # after changing role tasks
molecule test                          # full lifecycle before commit or CI
```

Also run the repository's existing `ansible-lint`, YAML lint, and CI checks. Do
not assume the local host has containers, systemd, or root; read the CI setup
first. Do not destroy a user's long-lived test environment without asking.

## Reference Documents

Load only what the task needs:

- **[references/ansible-native.md](references/ansible-native.md)** - Load when
  writing or reviewing `molecule.yml`, inventory, dependency setup, or executor
  options, or when deciding between ansible-native and legacy configuration.
- **[references/scenarios.md](references/scenarios.md)** - Load when choosing
  scenario layout: default versus extra scenarios, OS matrix, multi-node, nested
  collection scenarios, shared state, side effects, upgrade, and reboot.
- **[references/testing-patterns.md](references/testing-patterns.md)** - Load when
  writing `prepare.yml`, `converge.yml`, `verify.yml`, `cleanup.yml`, or when
  debugging idempotence, service and systemd tests, destructive tests, and CI
  behavior.

## Freshness

The guidance in this skill targets Molecule 26.x with the ansible-native model.
For behavior that may have changed:

- Official docs: <https://docs.ansible.com/projects/molecule/>
- Source and release notes: <https://github.com/ansible/molecule>
- Confirm the installed version with `molecule --version` before assuming a flag,
  schema key, or scenario layout exists.

Legacy material remains in the official docs under "Pre Ansible-Native
Configuration". Consult it only when maintaining an existing legacy project.
