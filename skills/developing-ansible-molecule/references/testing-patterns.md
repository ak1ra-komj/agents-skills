# Testing patterns

How to write lifecycle playbooks that test real behavior and stay maintainable.
The lifecycle responsibilities are the backbone:

- `create.yml` provisions resources only.
- `prepare.yml` establishes prerequisites the test needs.
- `converge.yml` applies the content under test as a user would.
- `verify.yml` asserts the observable result.
- `side_effect.yml` disturbs the system between converge runs.
- `cleanup.yml` removes artifacts outside the instance.
- `destroy.yml` tears down resources.

## Converge

- Call the role the way a real user calls it. In a collection, use
  `ansible.builtin.include_role` with the fully qualified role name; in a
  standalone role, `include_role` or a `roles:` entry works.
- Pass scenario-specific variables from inventory, group_vars, or the play, not
  from the role's own defaults.
- For playbook repositories, converge can `import_playbook` the playbook under
  test so the real entry point is exercised.
- Do not reimplement the role in converge. If the role generates a config file,
  converge must not write that file itself.
- Keep converge deterministic and non-interactive so idempotence is meaningful.

## Verify

Assert what an operator can observe:

- Package state (`package_facts`, `ansible.builtin.package` checks).
- Service state and enablement (`service_facts`, `systemctl show`).
- File and directory existence, ownership, mode, and content (`stat`, `slurp`).
- Configuration semantics (parsed values, not raw whitespace).
- Listening sockets and ports (`wait_for`, `ss` via `command` with
  `changed_when: false`).
- HTTP or API behavior (`uri` with status and body assertions).
- Command behavior and exit codes (`command` with `changed_when: false`).

Guidelines:

- Prefer read-only modules and `assert` with explicit `fail_msg`.
- Do not re-run converge tasks in verify, and do not assert on internal task
  names, handler names, or the number of changed tasks.
- Avoid volatile values: timestamps, PIDs, ephemeral ports, generated secrets.
- Verify after idempotence too when the sequence runs it, so the second converge
  is proven not to have broken anything.

## Idempotence

`molecule idempotence` re-runs converge on an already-converged instance and
fails if Ansible reports changes. The instance must already be converged.

- Fix the role, not the test. Use modules that report change correctly,
  `changed_when`, `creates` / `removes`, and handlers.
- For read-only commands or commands whose effect is tracked elsewhere, set
  `changed_when: false` so they do not fail idempotence.
- Tag genuinely non-idempotent tasks with `molecule-idempotence-notest` so they
  are skipped only during the idempotence action.
- `molecule-notest` (or `notest`) skips a task in every Molecule run.
- Reboots, upgrades, and failure injection break idempotence by design. Keep
  them in `side_effect.yml`, never in `converge.yml`.

## Prepare anti-patterns

`prepare.yml` should establish prerequisites a real user would already have:
base packages, users, seeded data, or an external service. It must not:

- Install, configure, or start the service the role under test manages.
- Create the files the role is supposed to create.
- Paper over a non-idempotent or broken role so the scenario passes.

`prepare` runs once per instance lifetime; `molecule prepare --force` re-runs it
when iterating.

## Services and systemd in containers

Plain containers do not run systemd as PID 1, so `systemctl` fails with
"System has not been booted with systemd as init system". To test service-managing
content:

- Use an init image such as `ubi-init` or a distribution init image.
- Set `container_command: /sbin/init` and, for Podman,
  `container_systemd: always` in inventory.
- systemd needs cgroup v2; rootless Podman additionally needs the v2 hierarchy
  delegated to the user.
- `wait_for_connection` only proves the connection is up, not that boot finished.
  Wait on a unit or on `systemctl is-system-running` with retries before
  converge.
- Some images run as a non-root user; add `become: true` or choose a root image.
- A `Type=oneshot` unit reports `stopped` after a successful run. Assert
  enablement or the effect it produced instead of `running`.
- When a service should be tested without systemd, verify the process or socket
  instead of the unit.

## Destructive, upgrade, and migration tests

- Keep destructive and upgrade scenarios separate from the default scenario.
- Upgrade: seed the old version in `prepare.yml`, apply the new version in
  `converge.yml`, and verify both service health and data or configuration
  survival in `verify.yml`.
- Migration: create old-format state in prepare, run the migration through
  converge, and assert the new format. Test rollback separately if the content
  supports it.
- Destructive scenarios may not be safe under shared state; give them their own
  resources unless isolation is guaranteed.

## Resources and cleanup

- Derive resource names from `inventory_hostname`, the scenario name, or another
  unique identifier; never rely on fixed global names.
- `destroy.yml` must succeed after a partial create and must be safe to run more
  than once. Use `state: absent` and tolerate already-missing resources.
- `cleanup.yml` runs before every destroy, including the one before create. It
  must not fail when the resources it cleans do not exist yet.
- Put cleanup of external resources (databases, DNS records, users, cloud
  objects) in `cleanup.yml`; put instance teardown in `destroy.yml`.
- If `molecule login` or `molecule list` should work for dynamically created
  hosts, persist their connection data to inventory `host_vars` during create.

## Local development versus CI

- Inner loop: `molecule converge` then `molecule verify`; keep the instance up
  while iterating. `molecule login --host <name>` opens a shell for debugging.
- `molecule test --destroy=never` runs the full sequence but leaves resources for
  inspection after a failure.
- Before commit: `molecule idempotence`, then `molecule test` for each changed
  scenario. Use `molecule test --all` when scenarios share inventory or state.
- CI: run the full sequence, matrix over OS and versions, and keep scenario count
  bounded. Confirm version-sensitive flags before adding them.
- Debug with `molecule --debug test` and inspect the generated ephemeral
  directory when a playbook fails.
- Never destroy a developer's running test instance to make a command succeed.
