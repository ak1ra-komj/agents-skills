# Ansible-native configuration

The ansible-native model delegates resource management to ordinary Ansible:
standard inventory plus ordinary playbooks. There is no driver, provider, or
platform abstraction to configure. This is the current default and the target
for new tests.

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

scenario:
  test_sequence:
    - dependency
    - destroy
    - create
    - converge
    - idempotence
    - verify
    - destroy
```

- `ansible.playbooks` keys: `create`, `destroy`, `converge`, `prepare`, `verify`,
  `cleanup`, `side_effect`. Defaults are `<action>.yml` relative to the scenario
  directory.
- `ansible.executor.backend` is `ansible-playbook` (default) or
  `ansible-navigator` (for execution environments).
- `ansible.env` sets environment variables for every Ansible execution.
- `ansible.cfg` merges into a generated `ansible.cfg` for the scenario. Use it for
  `roles_path`, `collections_path`, `interpreter_python`, and similar settings.
  Since Molecule v6 this replaces the old provisioner `config_options` approach.
- `scenario.test_sequence` replaces the built-in full sequence. Only override it
  when the default does not fit; the default already covers create, prepare,
  converge, idempotence, side_effect, verify, cleanup, and destroy.

## Where files live

| Project         | Scenario root                     | Shared base config                   |
| --------------- | --------------------------------- | ------------------------------------ |
| Standalone role | `molecule/<scenario>/`            | `<repo>/.config/molecule/config.yml` |
| Collection      | `extensions/molecule/<scenario>/` | `extensions/molecule/config.yml`     |
| Playbook repo   | `molecule/<scenario>/`            | `<repo>/.config/molecule/config.yml` |

Molecule deep-merges the base config into each scenario `molecule.yml`. A global
default may live at `~/.config/molecule/config.yml`. An explicit base can be
passed with `molecule --base-config <file>`.

## Inventory

Ansible-native scenarios use standard Ansible inventory sources. Point the
executor at them with `--inventory=`, `ANSIBLE_INVENTORY`, or `ansible.cfg`.

- Inventory may be a single file or a directory. Directory sources load
  alphabetically, so prefix files (`01-hosts.yml`, `02-constructed.yml`) when
  order matters.
- Hosts carry both connection details (`ansible_connection`, `ansible_host`,
  `ansible_user`, `ansible_port`, `ansible_ssh_private_key_file`) and the data
  `create.yml` needs to build the resource (`container_image`,
  `container_command`, and similar).
- Groups are the unit of play targeting and of `create.yml` / `destroy.yml`
  loops (`loop: "{{ groups['molecule'] }}"`).
- Dynamic and constructed inventory plugins work. A constructed plugin can derive
  test groups from host variables.
- The inventory is the single source of truth. Do not duplicate host definitions
  in `molecule.yml`.

`molecule list` and `molecule login` resolve hosts by running `ansible-inventory`
against the configured sources. Values that only exist at runtime (a published
container port, a cloud instance IP) must be written to disk under the inventory
path, typically a `host_vars/<name>.yml` file in `create.yml`, or they will be
invisible to `list` and `login`.

## Providers

Providers are ordinary collections, not Molecule drivers:

- Containers: `containers.podman.podman_container` with
  `ansible_connection: containers.podman.podman` in inventory, or
  `community.docker` for Docker.
- Cloud and virtualization: the provider collection (`amazon.aws`,
  `community.libvirt`, and so on) in `create.yml` / `destroy.yml`.
- Remote or pre-existing hosts: plain SSH inventory; omit create/destroy from the
  test sequence when the playbooks do not manage those resources.

Declare provider collections in `requirements.yml` so the `dependency` action
installs them before the first playbook runs.

## Dependencies

- `dependency.name: galaxy` (default) installs `requirements.yml` for roles and
  `collections.yml` for collections. Override with `options.role-file` and
  `options.requirements-file`.
- Reference scenario-local files with `${MOLECULE_SCENARIO_DIRECTORY}`, for
  example `requirements-file: ${MOLECULE_SCENARIO_DIRECTORY}/requirements.yml`.
- `dependency.name: shell` with `command:` covers non-Galaxy setup.
- Set `dependency.enabled: false` only when dependencies are already present.
- Role and collection search paths are configured through `ansible.cfg`, not
  through Molecule-specific keys.

## Legacy boundary

Legacy configurations use `driver`, `platforms`, and `provisioner`. They still
run, and the official docs keep them under "Pre Ansible-Native Configuration",
but do not choose them for new work.

- A legacy config requires `platforms`; an ansible-native config requires none.
- The two models cannot be mixed in one file. The schema rejects combinations
  such as `ansible.executor.args` with `provisioner.ansible_args`,
  `ansible.cfg` with `provisioner.config_options`, `ansible.env` with
  `provisioner.env`, and `ansible.playbooks` with `provisioner.playbooks`.
- The `verifier` key still exists, and the default `ansible` verifier runs the
  configured verify playbook. In ansible-native configs, set the verify playbook
  under `ansible.playbooks.verify`; use `verifier` only for `enabled: false` or a
  non-default verifier.

When migrating a legacy scenario on request:

1. Replace `driver` / `platforms` with standard inventory and
   `ansible_connection` values.
2. Move `provisioner.playbooks` entries to `ansible.playbooks`.
3. Move `provisioner.config_options` to `ansible.cfg`, `provisioner.env` to
   `ansible.env`, and `provisioner.ansible_args` to
   `ansible.executor.args.ansible_playbook`.
4. Rewrite `create.yml` / `destroy.yml` to use provider collection modules.
5. Remove `platforms` and re-run the full sequence.

Do not migrate when the user only asked to fix or extend a test; note the legacy
state and keep the existing structure working.

## Freshness

- Docs: <https://docs.ansible.com/projects/molecule/>
- Source: <https://github.com/ansible/molecule>
- Run `molecule --version` and check `molecule matrix test` before relying on
  sequence or flag details that may have changed.
