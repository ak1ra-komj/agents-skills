# Scenario design

A scenario is a self-contained directory with a `molecule.yml` and the lifecycle
playbooks it needs. Its name is the directory name. The conventional starting
point is a `default` scenario; `molecule init scenario <name>` scaffolds one.

Run scenarios with:

```bash
molecule test -s <scenario>        # one scenario
molecule test --all                # every discovered scenario
molecule test -s group/scenario    # nested collection scenario
molecule test -s "group/*"         # all scenarios under a group
```

## Scenario, sequence, action

- An **action** is one lifecycle playbook: `create`, `prepare`, `converge`,
  `verify`, `idempotence`, `side_effect`, `cleanup`, `destroy`, `syntax`,
  `dependency`.
- A **sequence** is an ordered list of actions. `scenario.test_sequence` controls
  `molecule test`; other subcommands have their own sequences
  (`create_sequence`, `converge_sequence`, `destroy_sequence`, and so on).
- A **scenario** binds configuration, inventory, and playbooks together.

Override `test_sequence` only when the default is wrong for the scenario. The
built-in default is dependency, cleanup, destroy, syntax, create, prepare,
converge, idempotence, side_effect, verify, cleanup, destroy. Common deliberate
variants: dropping `side_effect` when unused, or using
`prepare, converge, verify, idempotence, cleanup` for shared-state component
scenarios. `molecule matrix test` shows the effective sequence.

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

## One scenario or several

Prefer the smallest layout that expresses the test.

| Situation                                     | Prefer                                                       |
| --------------------------------------------- | ------------------------------------------------------------ |
| Same target, different variables              | One scenario, inventory vars or group_vars                   |
| Different OS or version                       | Extra inventory hosts (containers), or a CI matrix entry     |
| Different feature path in the same role       | One scenario with `side_effect` plus another converge/verify |
| Independent feature area with different setup | Separate scenario                                            |
| Multi-node cluster                            | One scenario, multiple inventory hosts and groups            |
| Upgrade or migration                          | Dedicated scenario                                           |
| Destructive behavior                          | Dedicated scenario, never the default                        |

Avoid copy-pasting whole scenarios for small differences. Multiple hosts and
inventory variables are cheaper to maintain than near-duplicate scenario
directories.

## OS matrix

- For containers, add one inventory host per image and loop the group in
  `create.yml`. OS-specific values belong in `host_vars` / `group_vars`.
- For VMs or cloud instances, the OS is baked into the resource, so use separate
  scenarios or a CI matrix instead of one scenario.
- Keep converge and verify OS-agnostic where possible; branch with `when` on
  `ansible_facts` rather than duplicating playbooks.

## Multi-node

- Define logical groups in inventory (`web_servers`, `db_servers`) and have
  `create.yml` / `destroy.yml` loop `groups['<group>']`.
- `converge.yml` targets the group under test; `verify.yml` may span groups and
  use `hostvars` for cross-host assertions.
- Add `wait_for_connection` (or a readiness check) after creating each host so
  converge does not race resource startup.
- Keep resource names unique per host; derive them from `inventory_hostname` or
  the scenario name.

## Shared state

Use `shared_state: true` when several scenarios should test against one set of
resources:

- The `default` scenario becomes the lifecycle manager. Give it a sequence of
  `create, destroy` and the create/destroy playbooks.
- Component scenarios omit create/destroy and run testing actions such as
  `prepare, converge, verify, idempotence, cleanup`.
- `molecule test --all` creates shared resources first, runs each component
  scenario, then destroys the resources last.
- Without shared state, every scenario creates and destroys its own resources:
  stronger isolation, higher cost, and no cross-scenario state leakage.

Do not enable shared state when scenarios must not influence each other's state.

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

`side_effect.yml` runs between the idempotence and verify steps by default. Use it
for anything that changes system state outside the role's normal convergence:

- Reboot, service restarts, and recovery checks.
- Configuration drift or failure injection, followed by a converge that should
  restore the desired state.
- Upgrade or migration steps in a dedicated scenario.

If verify after a side effect expects the converged state, the side effect must
restore the system or a later `converge` must run before that verify.

## Upgrade scenarios

- `prepare.yml` installs or seeds the old version and its data.
- `converge.yml` applies the new version through the normal role entry point.
- `verify.yml` asserts the service is healthy, configuration survived, and data
  was migrated.
- Keep the old-version setup in prepare so the role under test is never used to
  create the pre-upgrade state.
- Prefer a separate scenario so the default test stays fast and focused.

## Reboot scenarios

- Rebooting requires a real init system: a VM, or a systemd-capable container
  (init image, `container_command: /sbin/init`, `container_systemd: always`).
- Put the reboot in `side_effect.yml` (for example `ansible.builtin.reboot`),
  then add `verify after_reboot.yml` to check the service came back and state
  persisted.
- Never put a reboot in `converge.yml`; it breaks idempotence and the default
  lifecycle assumptions.

## Isolation and cleanup

- Every scenario has its own ephemeral state directory. Name resources with the
  scenario or `inventory_hostname` to avoid collisions when scenarios or CI jobs
  run at the same time.
- `cleanup.yml` runs before every destroy, including the destroy that precedes
  create in the default sequence. It must succeed when nothing exists yet.
- `destroy.yml` must work after a partial create and must be safe to run twice.
- Scenarios that share external resources (databases, DNS records, cloud
  accounts) need explicit cleanup rules; prefer per-scenario names over deleting
  a shared resource.

## CI

- Use the same `molecule test` entry point in CI as locally.
- Use a CI matrix for OS, Ansible, and Python versions rather than multiplying
  scenarios.
- Run `molecule test --all` when scenarios share inventory or state.
- Version-sensitive flags change between releases (`--parallel` was replaced by
  `--workers`); confirm against the installed version before adding them.
