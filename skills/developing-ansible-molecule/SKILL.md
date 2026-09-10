---
name: developing-ansible-molecule
description: Use when adding, creating, editing, debugging, or reviewing Molecule tests for Ansible roles, collections, or playbooks. Covers scenarios and lifecycle playbooks (create, prepare, converge, verify, destroy, cleanup, side_effect), inventory, idempotence, verifier design, CI runs, and legacy pre-ansible-native configurations or migration.
---

# developing-ansible-molecule skill

## Rule of Thumb

- Default to the current **ansible-native** configuration. Do not emit new
  `driver:`, `platforms:`, or `provisioner:` blocks; those are legacy constructs.
- If the repository already has scenarios, follow their existing style and change
  only what the task requires. Do not migrate a working legacy scenario unless the
  user asks for migration.
- Molecule evolves quickly; confirm the installed version with `molecule --version`
  before assuming a flag, schema key, or scenario layout exists, and verify
  version-sensitive details against the official docs at
  <https://docs.ansible.com/projects/molecule/>.

## Workflow

### 1. Inspect

Before creating or editing files, establish:

- Project type: standalone role, collection, or playbook repository. This decides
  where scenarios live (`molecule/` versus `extensions/molecule/`).
- Existing scenarios: read each `molecule.yml` before touching playbooks.
- Configuration model: `ansible:` section (ansible-native) or `driver:` /
  `platforms:` / `provisioner:` (legacy).
- Supported targets: OS and version list from `meta/main.yml`, collection docs, or
  the CI matrix.
- Dependencies: `requirements.yml`, `meta/main.yml`, collection dependencies, and
  the inventory sources a scenario relies on.
- How CI invokes tests today; reuse the same entry point locally.

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
kernel modules, mounts, or a real reboot. For scenario layout, OS matrices,
shared state, nested collection scenarios, and upgrade or reboot design, read
[references/scenarios.md](references/scenarios.md).

### 3. Implement

Respect the lifecycle responsibilities:

- `create.yml` - create test resources only (containers, VMs, networks).
- `prepare.yml` - establish prerequisites only. Never implement behavior the role
  under test claims to provide.
- `converge.yml` - call the role or collection the way a real user would.
- `verify.yml` - assert observable end state, not task implementation details.
- `side_effect.yml` - disturb the system between converge runs.
- `destroy.yml` - remove resources safely and repeatably.
- `cleanup.yml` - reset artifacts outside the instance; must tolerate running
  before resources exist, because it runs before every destroy.

### 4. Validate

Run the shortest loop that proves the change, then the full lifecycle for each
changed scenario:

```bash
molecule converge && molecule verify   # inner loop
molecule idempotence                   # after changing role tasks
molecule test                          # full lifecycle before commit or CI
```

Debug with `molecule --debug test`; keep a failed environment with
`molecule test --destroy=never` and get a shell with `molecule login --host <name>`.
Also run the repository's existing `ansible-lint`, YAML lint, and CI checks. Do
not assume the local host has containers, systemd, or root; read the CI setup
first. Do not destroy a user's long-lived test environment without asking.

## Reference Documents

Load only what the task needs:

- **[references/ansible-native.md](references/ansible-native.md)** - Load when
  writing or reviewing `molecule.yml`, inventory, dependencies, or executor
  options, or when deciding between ansible-native and legacy configuration.
- **[references/scenarios.md](references/scenarios.md)** - Load when choosing
  scenario layout: default versus extra scenarios, OS matrix, multi-node, nested
  collection scenarios, shared state, side effects, upgrade, and reboot.
- **[references/testing-patterns.md](references/testing-patterns.md)** - Load when
  writing `converge.yml` or `verify.yml`, or when testing idempotence, services,
  and systemd.
