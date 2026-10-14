# Installing Ansible and the Toolchain

Install the Ansible command-line tools at user level in an isolated
environment. This avoids modifying the system Python, keeps upgrades and
removal to a single command, and lets different projects use different
versions. The examples use `uv`; `pipx` and plain virtual environments work
the same way.

## Minimal CLI

```sh
uv tool install ansible-core
```

`ansible-core` exposes the whole CLI family: `ansible`, `ansible-playbook`,
`ansible-galaxy`, `ansible-doc`, `ansible-config`, `ansible-inventory`,
`ansible-vault`, `ansible-console`, `ansible-pull`, and `ansible-test`. Add
the Ansible community package when the playbooks use the collections that
ship with it (a large install):

```sh
uv tool install --force ansible-core --with ansible
```

## Lint and Test Toolchain

`ansible-dev-tools` bundles `ansible-lint`, `molecule`, `ansible-navigator`,
`ansible-creator`, and related tools in one environment. It is a meta
package: the tools are its dependencies, so expose their commands explicitly
with `--with-executables-from`. Keep the install in a versioned script so it
can be re-run to update or rebuild the environment:

```sh
# bin/install-ansible.sh
uv tool install --force ansible-dev-tools \
  --with-executables-from ansible-builder \
  --with-executables-from ansible-core \
  --with-executables-from ansible-creator \
  --with-executables-from ansible-dev-environment \
  --with-executables-from ansible-lint \
  --with-executables-from ansible-navigator \
  --with-executables-from ansible-sign \
  --with-executables-from molecule
```

`ansible-dev-tools` is convenient, not required: install only `ansible-core`
when the job is running playbooks, and add the toolchain when the project
also lints, tests with Molecule, or builds execution environments.
Container-driven Molecule scenarios also need a driver extra, for example
`--with molecule-plugins[podman]` or `--with molecule-plugins[docker]`.

## Injecting Controller-Side Dependencies

Plugins and other controller-side code import their Python packages from the
environment that runs Ansible, not from the project virtual environment. Add
those packages to the same tool install with `--with <package>`:

```sh
  --with ncclient    # imported by ansible.netcommon
  --with boto3       # imported by amazon.aws and similar collections
```

Add the lines to the script above and re-run it with `--force`. A reinstall
replaces the whole flag set, so always edit the script and re-run it instead
of typing a partial `uv tool install` command, which would drop the
`--with-executables-from` flags and the commands they expose.

`ansible-galaxy` does not install the Python packages that collections
import; packages such as `ncclient`, `paramiko`, and `boto3` belong in the
environment that runs Ansible. See [developing-plugins.md](developing-plugins.md)
for development environments and collection requirements files.

Alternatives: `pipx install ansible-core` with `pipx inject` for extras, or a
dedicated virtual environment that you activate before running Ansible.
Whatever the tool, the rule is the same: one environment runs Ansible and
holds all controller-side dependencies.
