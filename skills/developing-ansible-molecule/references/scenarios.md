# Scenario design

A scenario is a directory with a `molecule.yml` and the lifecycle playbooks it
needs; its name is the directory name. `molecule init scenario <name>` scaffolds
one. Prefer the smallest layout that expresses the test: extra inventory hosts
and variables are cheaper than near-duplicate scenario directories.

## Sequences

`scenario.test_sequence` controls `molecule test`; other subcommands have their
own sequences (`create_sequence`, `converge_sequence`, `destroy_sequence`, and so
on). Override only when the default does not fit. The default is `dependency,
cleanup, destroy, syntax, create, prepare, converge, idempotence, side_effect,
verify, cleanup, destroy`; `molecule matrix test` prints the effective sequence.

Multiple `converge`, `idempotence`, `side_effect`, and `verify` entries are
allowed, and `side_effect` / `verify` accept a file or directory argument:

```yaml
scenario:
  test_sequence:
    - converge
    - side_effect reboot.yml
    - verify after_reboot/
    - converge
    - verify
```

Run one scenario with `molecule test -s <scenario>` or every discovered scenario
with `molecule test --all`.

## OS matrix

- Containers: add one inventory host per image and loop the group in
  `create.yml`; keep OS-specific values in `host_vars` / `group_vars`.
- VMs and cloud instances bake the OS into the resource, so use separate
  scenarios or a CI matrix instead of one scenario.
- Keep converge and verify OS-agnostic; branch with `when` on `ansible_facts`
  rather than duplicating playbooks.

## Multi-node

- Define logical groups in inventory (`web_servers`, `db_servers`) and loop
  `groups['<group>']` in `create.yml` / `destroy.yml`.
- `converge.yml` targets the group under test; `verify.yml` may span groups and
  use `hostvars` for cross-host assertions.
- Add `wait_for_connection` or a readiness check after creating each host so
  converge does not race resource startup.

## Shared state

Use `shared_state: true` when several scenarios should test one set of resources:

- The `default` scenario becomes the lifecycle manager: sequence `create,
destroy`, plus the create/destroy playbooks.
- Component scenarios omit create/destroy and run `prepare, converge, verify,
idempotence, cleanup`.
- `molecule test --all` creates shared resources first, runs each component
  scenario, then destroys the resources last.
- Without shared state every scenario creates and destroys its own resources:
  stronger isolation, higher cost. Do not enable shared state when scenarios must
  not influence each other's state.

## Nested scenarios (collections)

Collections with many scenarios can group them:

```text
extensions/molecule/
|-- config.yml
|-- default/
|   `-- molecule.yml
`-- appliance_vlans/
    |-- merged/molecule.yml
    `-- replaced/molecule.yml
```

- The scenario name is the path relative to `extensions/molecule/`, such as
  `appliance_vlans/merged`; target it with `-s appliance_vlans/merged` or
  `-s "appliance_vlans/*"`.
- Set `MOLECULE_GLOB="extensions/molecule/**/molecule.yml"` so `molecule list`
  and `--all` discover nested scenarios.
- Nested layouts apply to collection mode only. Role scenarios stay flat under
  `molecule/`.

## side_effect

`side_effect.yml` runs between idempotence and verify by default. Use it for
anything that changes system state outside normal convergence: reboots, service
restarts, recovery checks, failure injection, or configuration drift followed by
a converge that should restore the desired state. If verify after a side effect
expects the converged state, the side effect must restore the system or a later
`converge` must run before that verify.

## Upgrade and migration

- `prepare.yml` seeds the old version and its data; `converge.yml` applies the new
  version through the normal role entry point; `verify.yml` asserts service
  health plus data and configuration survival.
- Keep the old-version setup in prepare so the role under test never creates the
  pre-upgrade state.
- Use a dedicated scenario so the default test stays fast and focused.
- For migrations, create old-format state in prepare, run the migration through
  converge, and assert the new format. Test rollback separately when the content
  supports it.

## Reboot

- Rebooting requires a real init system: a VM, or a systemd-capable container.
  See [testing-patterns.md](testing-patterns.md) for the container setup.
- Put the reboot in `side_effect.yml` (for example `ansible.builtin.reboot`), then
  `verify after_reboot.yml` to check the service returned and state persisted.

## Isolation

- Name resources from the scenario or `inventory_hostname` so concurrent
  scenarios and CI jobs do not collide.
- Destructive scenarios get dedicated resources; never run them under shared
  state.
- Scenarios that touch external shared resources (databases, DNS records, cloud
  accounts) need explicit cleanup rules and per-scenario names.
