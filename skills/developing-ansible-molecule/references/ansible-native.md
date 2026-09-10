# Ansible-native configuration

The ansible-native model delegates resource management to ordinary Ansible:
standard inventory plus ordinary playbooks, with no driver, provider, or platform
abstraction. It is the default for new tests.

## Configuration shape

```yaml
---
ansible:
  executor:
    backend: ansible-playbook
    args:
      ansible_playbook:
        - --inventory=inventory/
  env:
    ANSIBLE_FORCE_COLOR: "1"
  cfg:
    defaults:
      host_key_checking: false
  playbooks:
    create: create.yml
    prepare: prepare.yml
    converge: converge.yml
    verify: verify.yml
    destroy: destroy.yml

dependency:
  name: galaxy
  options:
    requirements-file: ${MOLECULE_SCENARIO_DIRECTORY}/requirements.yml
```

- `ansible.playbooks` keys: `create`, `destroy`, `converge`, `prepare`, `verify`,
  `cleanup`, `side_effect`; defaults are `<action>.yml` relative to the scenario
  directory.
- `ansible.executor.backend` is `ansible-playbook` (default) or
  `ansible-navigator` for execution environments.
- `ansible.env` sets environment variables for every Ansible execution.
- `ansible.cfg` merges into a generated `ansible.cfg` for the scenario. Use it for
  `roles_path`, `collections_path`, `interpreter_python`, and similar settings.
  This replaces the legacy `provisioner.config_options`.
- `scenario.test_sequence` overrides the default action sequence; see
  [scenarios.md](scenarios.md).

## Where files live

| Project         | Scenario root                     | Shared base config                   |
| --------------- | --------------------------------- | ------------------------------------ |
| Standalone role | `molecule/<scenario>/`            | `<repo>/.config/molecule/config.yml` |
| Collection      | `extensions/molecule/<scenario>/` | `extensions/molecule/config.yml`     |
| Playbook repo   | `molecule/<scenario>/`            | `<repo>/.config/molecule/config.yml` |

Molecule deep-merges the base config into each scenario `molecule.yml`. A global
default may live at `~/.config/molecule/config.yml`.

## Inventory

Inventory is the single source of truth for hosts; do not duplicate host
definitions in `molecule.yml`. Point the executor at standard Ansible inventory
sources with `--inventory=`, `ANSIBLE_INVENTORY`, or `ansible.cfg`.

- A directory of inventory files loads alphabetically; prefix files
  (`01-hosts.yml`, `02-constructed.yml`) when order matters.
- Hosts carry both connection details (`ansible_connection`, `ansible_host`,
  `ansible_user`, `ansible_port`, `ansible_ssh_private_key_file`) and the data
  `create.yml` needs to build the resource (`container_image`,
  `container_command`, and similar).
- Groups are the unit of play targeting and of `create.yml` / `destroy.yml` loops
  (`loop: "{{ groups['molecule'] }}"`).
- Dynamic and constructed inventory plugins work; a constructed plugin can derive
  test groups from host variables.
- `molecule list` and `molecule login` resolve hosts by running `ansible-inventory`
  against the configured sources. Values that exist only at runtime (a published
  container port, a cloud instance IP) must be written to the inventory path
  during `create.yml`, typically `host_vars/<name>.yml`, or they stay invisible to
  `list` and `login`.

## Providers

Providers are ordinary collections, not Molecule drivers:

- Containers: `containers.podman.podman_container` with
  `ansible_connection: containers.podman.podman` in inventory, or
  `community.docker` for Docker.
- Cloud and virtualization: the provider collection (`amazon.aws`,
  `community.libvirt`, and so on) in `create.yml` / `destroy.yml`.
- Remote or pre-existing hosts: plain SSH inventory; omit create/destroy from the
  sequence when the playbooks do not manage those resources.

Declare provider collections in `requirements.yml` so the `dependency` action
installs them before the first playbook runs.

## Dependencies

- `dependency.name: galaxy` (default) installs `requirements.yml` for roles and
  `collections.yml` for collections. Override with `options.role-file` and
  `options.requirements-file`.
- Reference scenario-local files with `${MOLECULE_SCENARIO_DIRECTORY}`.
- `dependency.name: shell` with `command:` covers non-Galaxy setup; set
  `dependency.enabled: false` only when dependencies are already present.
- Role and collection search paths are configured through `ansible.cfg`, not
  through Molecule-specific keys.

## Legacy boundary

Legacy configurations use `driver`, `platforms`, and `provisioner`. They still
run, but do not choose them for new work. A legacy config requires `platforms`; an
ansible-native config requires none. Legacy material lives in the official docs
under "Pre Ansible-Native Configuration".

The two models cannot be mixed in one file. The schema rejects combinations such
as `ansible.executor.args` with `provisioner.ansible_args`, `ansible.cfg` with
`provisioner.config_options`, `ansible.env` with `provisioner.env`, and
`ansible.playbooks` with `provisioner.playbooks`.

The `verifier` key still exists. In ansible-native configs, set the verify
playbook under `ansible.playbooks.verify`; use `verifier` only for
`enabled: false` or a non-default verifier.

When migrating a legacy scenario on request:

1. Replace `driver` / `platforms` with standard inventory and
   `ansible_connection` values.
2. Move `provisioner.playbooks` to `ansible.playbooks`,
   `provisioner.config_options` to `ansible.cfg`, `provisioner.env` to
   `ansible.env`, and `provisioner.ansible_args` to
   `ansible.executor.args.ansible_playbook`.
3. Rewrite `create.yml` / `destroy.yml` with provider collection modules.
4. Remove `platforms` and re-run the full sequence.
