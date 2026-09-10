# Testing patterns

## Converge

- Call the role the way a real user calls it: `ansible.builtin.include_role` with
  the fully qualified role name in a collection, or `include_role` / a `roles:`
  entry in a standalone role. Playbook repositories can `import_playbook` the
  playbook under test.
- Pass scenario-specific variables from inventory, group_vars, or the play, not
  by editing the role's own defaults.
- Do not reimplement the role in converge. If the role generates a config file,
  converge must not write that file itself.
- Keep converge deterministic and non-interactive so idempotence is meaningful.

## Verify

Assert what an operator can observe: package state, service state and enablement,
file existence / ownership / mode / content, parsed configuration values,
listening sockets, HTTP or API behavior, command exit codes. Prefer read-only
modules and `assert` with explicit `fail_msg`.

- Do not re-run converge tasks in verify, and do not assert on internal task
  names, handler names, or the number of changed tasks.
- Avoid volatile values: timestamps, PIDs, ephemeral ports, generated secrets.

## Idempotence

`molecule idempotence` re-runs converge on an already-converged instance and fails
if Ansible reports changes. Fix the role, not the test: use modules that report
change correctly, `changed_when`, `creates` / `removes`, and handlers.

- Read-only or externally tracked commands need `changed_when: false`.
- Tag genuinely non-idempotent tasks with `molecule-idempotence-notest` to skip
  them only during the idempotence action; `molecule-notest` (or `notest`) skips a
  task in every Molecule run.
- Reboots, upgrades, and failure injection belong in `side_effect.yml`, never in
  `converge.yml`.

## Services and systemd in containers

Plain containers do not run systemd as PID 1, so `systemctl` fails. To test
service-managing content:

- Use an init image (`ubi-init` or a distribution init image) with
  `container_command: /sbin/init` and, for Podman, `container_systemd: always` in
  inventory.
- systemd needs cgroup v2; rootless Podman additionally needs the v2 hierarchy
  delegated to the user.
- `wait_for_connection` only proves the connection is up, not that boot finished.
  Wait on a unit or `systemctl is-system-running` with retries before converge.
- Some images run as a non-root user; add `become: true` or choose a root image.
- A `Type=oneshot` unit reports `stopped` after a successful run. Assert
  enablement or the effect it produced instead of `running`.
- To test a service without systemd, verify the process or socket instead of the
  unit.
