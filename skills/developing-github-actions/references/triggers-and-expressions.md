# Triggers, expressions, and contexts

Event configuration and the expression and context model. For the security consequences of
privileged triggers, see `security.md`.

## Choosing a trigger

| Trigger                   | Typical use                                             | Trust note                                                 |
| ------------------------- | ------------------------------------------------------- | ---------------------------------------------------------- |
| `push`                    | CI on branches and tags                                 | Trusted authors; token has write by default                |
| `pull_request`            | CI for PRs, including forks                             | Fork runs get a read-only token and no secrets             |
| `pull_request_target`     | Label or comment on fork PRs without running their code | Privileged: base context, secrets, write token             |
| `workflow_dispatch`       | Manual run with inputs                                  | Workflow must exist on the default branch                  |
| `schedule`                | Periodic jobs                                           | Runs the default branch only                               |
| `workflow_run`            | Privileged follow-up to an unprivileged workflow        | Privileged; treat upstream artifacts as untrusted          |
| `repository_dispatch`     | External system triggers via API                        | Default branch context                                     |
| `merge_group`             | Merge queue validation                                  | Add alongside `pull_request` when a merge queue is enabled |
| `issues`, `issue_comment` | Triage and bots                                         | Privileged; untrusted input                                |

Prefer `pull_request` for CI. Use `pull_request_target` only for metadata operations (labels,
comments) that do not execute contributor code. See `security.md` for the pwn-request pattern.

## Event details

`pull_request`:

- Default activity types are `opened`, `synchronize`, `reopened`. Detecting a merge needs
  `types: [closed]` plus `github.event.pull_request.merged == true`.
- `branches` filters match the base branch; `paths` filters match the diff. If both are set,
  both must match.
- The payload is empty for fork PRs and merged PRs; use
  `github.event.pull_request.head.sha` for the head commit.

`workflow_dispatch`:

- Inputs are typed: `string`, `choice`, `number`, `boolean`, `environment`.
- `inputs.<name>` preserves the type; `github.event.inputs.<name>` is always a string. Prefer
  `inputs`.
- The workflow file must be on the default branch to appear in the UI. After one run, any
  branch or tag can be dispatched through the API or `gh workflow run`.

`schedule`:

- Five-field POSIX cron, UTC by default, minimum interval 5 minutes.
- Runs the latest commit of the default branch only.
- Delays are normal under load; `@daily` style macros are not supported.
- Public repositories disable scheduled workflows after 60 days of inactivity.

`workflow_run`:

- Must be defined on the default branch; the run uses the default branch ref and sha.
- Can chain at most 3 levels. Filter with `workflows: [name]` and `types: [completed]`.
- Gets secrets and a write token even when the triggering workflow did not. That is the
  privilege-separation tool, and the reason its inputs must be treated as untrusted.

`push`:

- `branches` and `branches-ignore` cannot be combined; use ordered `!` patterns instead.
- If only tag filters exist, branch pushes do not trigger. If neither exists, both trigger.
- Path filters are not evaluated for tag pushes.
- Path filters are skipped when a push contains more than 1,000 commits. When a diff has more
  than 3,000 files and no match is in the first 3,000, the workflow does not run.

`merge_group`:

- When required checks are enforced through a merge queue, add `merge_group` or merges block
  waiting for checks that never run.

## Expressions

- Literals: booleans, `null`, numbers, strings. Use single quotes; double quotes are invalid.
  Escape a quote by doubling it (`'It''s'`).
- Falsy values: `false`, `0`, `-0`, `""`, `null`. Everything else is truthy.
- Operators: `!`, `==`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `[]`, `.`, `()`. There is no
  arithmetic and no ternary.
- String comparison is case-insensitive; mismatched types coerce to numbers.
- Functions: `contains`, `startsWith`, `endsWith`, `format`, `join`, `toJSON`, `fromJSON`,
  `hashFiles`, plus the status functions. `format` uses `{0}` placeholders and `{{` and `}}`
  escapes.
- `fromJSON` turns an output string into a number, array, or object, for example a dynamic
  matrix.
- `hashFiles(glob)` returns a SHA-256 over matching files relative to the workspace and an
  empty string when nothing matches. It is only allowed in step-level keys.
- Status functions (`success()`, `failure()`, `cancelled()`, `always()`) are only valid in
  `jobs.<id>.if` and `steps.if`. Elsewhere use `job.status`.

## Contexts

Available contexts: `github`, `env`, `vars`, `job`, `jobs` (reusable workflows only),
`steps`, `runner`, `secrets`, `strategy`, `matrix`, `needs`, `inputs`.

Availability depends on the workflow key. The restrictions that cause most errors:

| Key                                                                           | Allowed contexts                                                                                          |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| `run-name`, `concurrency`                                                     | `github`, `inputs`, `vars`                                                                                |
| workflow `env`                                                                | `github`, `secrets`, `inputs`, `vars`                                                                     |
| `jobs.<id>.if`                                                                | `github`, `needs`, `vars`, `inputs`                                                                       |
| `jobs.<id>.runs-on`, `.name`, `.environment`, `.timeout-minutes`, `.strategy` | `github`, `needs`, `strategy`, `matrix`, `vars`, `inputs`                                                 |
| `jobs.<id>.env`                                                               | `github`, `needs`, `strategy`, `matrix`, `vars`, `secrets`, `inputs`                                      |
| `steps.if`                                                                    | `github`, `needs`, `strategy`, `matrix`, `job`, `runner`, `env`, `vars`, `steps`, `inputs` (no `secrets`) |
| `steps.run`, `.env`, `.with`, `.name`, `.working-directory`                   | the step `if` set plus `secrets`                                                                          |

`github` context notes:

- `github.event` is the raw webhook payload and differs per event; branch on
  `github.event_name`.
- `github.ref` is fully formed (`refs/heads/main`); `github.ref_name` is short. For unmerged
  PRs `github.ref` is `refs/pull/N/merge`.
- `github.sha` depends on the event; for `pull_request` it is the merge commit, not the head.
- `github.actor` is the user who started the run; a re-run uses the original actor's
  privileges. `github.triggering_actor` is who triggered the current attempt.
- `github.token` is null outside step execution; `secrets.GITHUB_TOKEN` works in job-level
  `env` and `with`.
- `github.base_ref` and `github.head_ref` exist only for pull request events.

## Variables

Three separate mechanisms:

| Mechanism | Scope                                 | Notes                                                   |
| --------- | ------------------------------------- | ------------------------------------------------------- |
| `env`     | workflow, job, step                   | defined in YAML; not secret                             |
| `vars`    | organization, repository, environment | configured in GitHub settings; unset is an empty string |
| `inputs`  | `workflow_dispatch`, `workflow_call`  | typed; only for callable workflows                      |

Configuration variable precedence: environment > repository > organization. Default
environment variables such as `GITHUB_*` and `RUNNER_*` are provided by the runner and cannot
be overwritten. `CI` is always `true`.

When debugging, print context safely with `${{ toJSON(github) }}`; never dump `secrets` or
`github.token`.
