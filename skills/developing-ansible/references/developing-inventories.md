# Inventories and Variables

Covers inventory layout, single source of truth, host and group variables, and variable precedence.

## Single Source of Truth

- Identify the SSOT for each piece of information.
- Use dynamic inventory sources to combine multiple SSOTs.
- Keep only unique data static in inventory.
- Distinguish technical SSOTs, managed SSOTs, and inventory-only data.
- Do not generate conflicting information in several places.

## As-Is vs To-Be

- Clearly separate discovered facts from managed desired state.
- Inventory should describe the managed desired state; discovered facts are not variables.
- Use discovered information only when it is not part of the desired state.
- Do not confuse facts with variables.

## Inventory Structure

Use a structured directory instead of a single file:

```text
inventories/
  production/
    groups_and_hosts
    group_vars/
      all/
        ansible.yml
        common.yml
      web/
        nginx.yml
    host_vars/
      web01.yml
      web02.yml
  staging/
    groups_and_hosts
    group_vars/
    host_vars/
```

- Use `host_vars/` and `group_vars/` directories.
- Name variable files after roles, except `ansible.yml`.
- Keep `groups_and_hosts` free of variables; use ini format for readability.
- Use subdirectories under `host_vars/` and `group_vars/` for complex setups.
- Include dynamic inventory plugin configuration files.
- Keep secrets in Ansible Vault.
- Do not hard-code hosts or environment-specific values in playbooks or roles.

## Loop Over Hosts

- Rely on inventory to loop over hosts, not lists of hosts in variables.
- Use groups and patterns to target hosts.
- Use `--limit` to restrict a run.
- Use Ansible parallelization and throttling instead of manual loops.
- Do not create lists of hosts in variables.

## Variable Types and Precedence

Use the simplified precedence order:

1. role defaults
2. inventory variables
3. facts
4. role vars
5. scoped vars
6. runtime vars
7. extra vars

- Use role defaults for default values.
- Use inventory vars for desired state.
- Use role vars for constants.
- Avoid playbook and play vars; use inventory instead.
- Avoid scoped variables unless they are needed at runtime.
- Reserve extra vars for troubleshooting and validation; do not define desired state with them.
- Use the smallest scope that expresses the value.

## Naming

- Use lowercase alphanumeric characters and underscores for variable names.
- Start variable names with a letter or underscore.
- Do not use Ansible reserved names, magic variables, or Python keywords.
- Do not put Jinja2 templating in variable names.
- Prefix role variables with the role name; see [developing-roles.md](developing-roles.md).
- Use bracket notation for variable and fact lookup, not dot notation.

## Terms

- **FQCN**: fully qualified collection name, such as `ansible.builtin.copy` or
  `community.general.docker_container`.
- **SSOT**: single source of truth; every data element is stored once in one
  authoritative location.
- **CMDB**: configuration management database; a managed source of To-Be
  information such as ownership, location, and desired state.
