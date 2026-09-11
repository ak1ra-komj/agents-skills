---
name: developing-github-actions
description: Use when creating, modifying, reviewing, debugging, or optimizing GitHub Actions workflows in .github/workflows, including triggers, expressions, contexts, permissions, secrets, caching, artifacts, matrix, concurrency, reusable workflows, environments, OIDC deployments, security hardening, or diagnosing failures from real workflow runs. Does not cover authoring custom JavaScript, Docker, or composite actions.
---

# developing-github-actions skill

## Scope

Covers workflow YAML only. Does not cover authoring custom actions (JavaScript, Docker, or
composite actions). When a task requires writing `action.yml` or action implementation code,
say so, finish the workflow-side integration (calling and pinning the action), and treat the
action implementation as a separate task.

## Rule of Thumb

If the repository already has workflows, follow their conventions: file layout, job and step
naming, runner labels, action pinning policy, cache keys, trigger scoping, and how much logic
lives in YAML versus scripts. If no workflows exist, apply the defaults in this skill and keep
the first workflow small.

## Workflow

### 1. Inspect

Read before writing:

- `.github/workflows/*.yml` and `*.yaml`, including reusable workflows
- Language and package manifests, lockfiles, build system
- Existing scripts, `Makefile`, task runner configuration
- `.github/dependabot.yml` (the `github-actions` ecosystem entry)
- CI expectations in `README`, `CONTRIBUTING`, or docs
- `actionlint.yaml` or `zizmor.yml` config if present
- For failures: the actual run and logs, not only the YAML

### 2. Design

Decide each of these explicitly, then keep the workflow as simple as the requirement allows:

- trigger and trust boundary (who can run it, what it can access)
- `GITHUB_TOKEN` permissions per job
- job graph (`needs`), runner, and matrix
- caching, artifacts, concurrency
- environments, credentials, OIDC
- whether a reusable workflow or script extraction is justified

Do not add matrix, caching, concurrency, reusable workflows, or abstractions just because
they are best practice. Each adds failure modes. Add them when a requirement or measurement
justifies them.

### 3. Implement

- Prefer the repository's existing scripts and task runner over inline YAML logic.
- GitHub Actions should orchestrate; build and test logic belongs in commands a developer can
  run locally.
- Match existing action versions and pinning policy. Evaluate mutable refs (see security).
- Keep changes minimal; do not reformat or restructure unrelated workflow code.

### 4. Verify

Run the verification ladder after every change. Fix the first failing tier before continuing.

| Tier          | Command                                   | Catches                                                                                                        |
| ------------- | ----------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| 1. Static     | `scripts/verify.sh`                       | syntax, expression types, context availability, `needs`, runner labels, action inputs, reusable workflow calls |
| 2. Security   | `scripts/verify.sh --security`            | excessive permissions, injection, unpinned actions, dangerous triggers, credential exposure                    |
| 3. Repository | run the commands the workflow invokes     | missing scripts, wrong flags, broken build or test                                                             |
| 4. Remote     | `gh run list`, `gh run view --log-failed` | real GitHub runner behavior and run history                                                                    |

If a tool is unavailable, report that tier as not run rather than guessing. Do not claim a
workflow works because it looks correct. If a tier fails for a pre-existing reason unrelated
to your change (a broken lockfile, an empty test suite), report it; do not expand scope to fix
the project unless asked. See [references/verification.md](references/verification.md) for tool
interpretation. `gh` cannot validate a workflow that has not been pushed.

## Task Routing

Load only what the task needs.

| Task                             | Load                                                                                                                                                             | Covers                                                                                  |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| Create a workflow from scratch   | [`authoring.md`](references/authoring.md), [`triggers-and-expressions.md`](references/triggers-and-expressions.md), then [`security.md`](references/security.md) | structure, shell, env, outputs, `if`, `needs`; events, expressions, contexts; hardening |
| Add or change a job              | [`authoring.md`](references/authoring.md) plus the reference for the changed area                                                                                | job and step mechanics; the changed area                                                |
| Fix a failing run                | [`debugging.md`](references/debugging.md)                                                                                                                        | evidence, failure classification, `gh`, local reproduction limits                       |
| Review or harden                 | [`security.md`](references/security.md)                                                                                                                          | threat model, injection, permissions, pinning, secrets, privileged triggers             |
| Optimize                         | [`matrix-concurrency.md`](references/matrix-concurrency.md), [`caching-artifacts.md`](references/caching-artifacts.md)                                           | matrix and concurrency mechanics; cache and artifact mechanics                          |
| Reusable workflows               | [`reuse.md`](references/reuse.md)                                                                                                                                | `workflow_call` interface, permissions, limits                                          |
| Deploy, environments, OIDC       | [`deployments-and-oidc.md`](references/deployments-and-oidc.md)                                                                                                  | protection rules, deployment jobs, OIDC trust setup                                     |
| Cache or artifacts               | [`caching-artifacts.md`](references/caching-artifacts.md)                                                                                                        | cache keys and scope, artifact mechanics, data passing, trust                           |
| Expressions, contexts, variables | [`triggers-and-expressions.md`](references/triggers-and-expressions.md)                                                                                          | event configuration, expression language, context availability, variables               |
| Verification                     | [`verification.md`](references/verification.md)                                                                                                                  | `verify.sh` exit codes, actionlint and zizmor capabilities and limits                   |

## Security Rules That Always Apply

1. Never interpolate untrusted `${{ }}` values into `run:` or `script:` bodies. Pass them through `env:` and reference the quoted shell variable.
2. Set `permissions:` explicitly. Default to `contents: read` and grant write scopes per job only where needed.
3. `pull_request_target`, `workflow_run`, `issue_comment`, and `issues` are privileged. Never check out untrusted code and execute it in these workflows.
4. Never write credentials into workflow YAML. Use `secrets`, environment secrets, or OIDC.
5. Evaluate mutable action refs. Do not blindly pin everything to a SHA, but do not leave a third-party action on a tag or branch without a deliberate decision.
6. Fork `pull_request` runs get a read-only token and no secrets by design. Do not switch to `pull_request_target` to "fix" that.

Explain the reasoning when reporting a security issue; do not just quote a rule.

## Optimization

Do not add cache, concurrency, or matrix changes from pattern matching alone. When run data is
available, inspect duration, repeated jobs, superseded runs, matrix cost, cache behavior, and
the critical path first. When no run data is available, say so and ask for durations from the
Actions UI or `gh run view`; static duplication is a candidate, not proof. You may still fix
correctness and security issues, but do not claim a speedup without measurement. Optimize for
correctness, security, and feedback latency before runner minutes, and do not trade large
complexity for small time savings.
