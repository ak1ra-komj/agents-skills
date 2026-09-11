# Authoring workflows

Workflow structure, job and step mechanics, and data passing. For triggers and expressions,
see `triggers-and-expressions.md`. Syntax and expression type errors are caught by actionlint;
this document covers behavior that valid YAML can still get wrong.

## Skeleton

```yaml
name: CI
on: ...
permissions: {}
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@<ref>
      - run: ...
```

- `on` and `jobs` are required; every job needs `runs-on` or `uses`.
- Set `permissions` at workflow level and override per job.
- Give long jobs an explicit `timeout-minutes`; the default is 360 minutes.
- Quote `on:` when any tool other than GitHub parses the file; YAML 1.1 parsers read unquoted
  `on` as boolean true.

## Toolchain setup

Install the project toolchain with the ecosystem's setup action (`actions/setup-node`,
`actions/setup-python`, `actions/setup-go`, `actions/setup-java`, `astral-sh/setup-uv`, and
similar), pinned per repository policy. Do not rely on what the runner image happens to
include.

## Jobs and steps

- Job IDs: a letter or `_`, then alphanumerics, `-`, `_`.
- Step outputs require `id:`; reference them as `steps.<id>.outputs.<name>`.
- `steps.<id>.outcome` is the result before `continue-on-error`; `conclusion` is after. A
  failed step with `continue-on-error: true` has `outcome: failure` and `conclusion: success`.
- A job calling a reusable workflow cannot have `steps`, `runs-on`, `env`, or `container`.
- `run` scripts are limited to 21,000 characters.

## Shell behavior

Default and explicit shells differ:

| Shell                   | Command                                    |
| ----------------------- | ------------------------------------------ |
| Linux and macOS default | `bash -e {0}` (no `pipefail`)              |
| `shell: bash`           | `bash --noprofile --norc -eo pipefail {0}` |
| `shell: sh`             | `sh -e {0}`                                |
| Windows default         | `pwsh`, falling back to Windows PowerShell |

Use explicit `shell: bash` when you need `pipefail`. Container jobs and minimal images may not
provide bash. Each `run:` is a separate process; a multi-line `run:` shares one shell.
`defaults.run` accepts only `shell` and `working-directory`, and `working-directory` must
already exist.

## Environment variables

Scopes, most specific wins: step > job > workflow. Values in the same `env:` map cannot
reference each other.

Default `GITHUB_*` and `RUNNER_*` variables cannot be overwritten; assignments are ignored.
The `env` context does not contain default variables; use `github.*` or `$GITHUB_*`.

Writing to `$GITHUB_ENV` affects subsequent steps only, not the current step, and
`NODE_OPTIONS` cannot be set this way. Prefer static `env:`; use `$GITHUB_ENV` only when a
previous step computes the value.

## Passing data

- Step output: `echo "name=value" >> "$GITHUB_OUTPUT"` with `id:` on the step.
- Multi-line output or env value: heredoc form `name<<DELIMITER` ... `DELIMITER`. Choose a
  delimiter that cannot appear in the value; never write raw untrusted input.
- Job output: `jobs.<id>.outputs.<name>: ${{ steps.<step>.outputs.<name> }}`, consumed as
  `needs.<id>.outputs.<name>`. Limits: 1 MB per job, 50 MB per workflow run.
- Matrix job outputs merge across legs with no guaranteed order; duplicate names overwrite.
  Aggregate explicitly when order matters.
- `$GITHUB_PATH` prepends to `PATH` for later steps only.
- `$GITHUB_STEP_SUMMARY` appends Markdown (1 MiB per step); `>` overwrites, `>>` appends.
- For large or binary data between jobs, use artifacts, not outputs (see
  `caching-artifacts.md`).

## Conditions

- `if:` is evaluated as an expression automatically; `${{ }}` is optional unless the
  expression starts with `!`.
- A step or job `if` gets an implicit `success()` unless it contains `success()`, `failure()`,
  `cancelled()`, or `always()`.
- Use `if: ${{ !cancelled() }}` for cleanup that should run even when canceled. `always()`
  also runs on cancellation and can hang on network operations.
- `jobs.<id>.if` is evaluated before `strategy.matrix`; only `github`, `needs`, `vars`, and
  `inputs` are available there. `matrix`, `env`, and `secrets` are not.
- `secrets` is not available in any `if:`. Assign to job `env` and test `env.NAME` instead.
- There is no ternary operator. Avoid the `cond && a || b` idiom; if `a` is falsy, `b` wins.
- Equality coerces types (`'' == 0` is true). Compare numbers with `fromJSON()` when values
  come from outputs.

## needs

- `needs` accepts a job ID or a list. It contains direct dependencies only, not transitive
  ones.
- If a dependency fails or is skipped, dependents are skipped unless their `if` overrides it.
- `needs.<id>.result` is `success`, `failure`, `cancelled`, or `skipped`.

## Action and workflow references

| Form                  | Meaning                                                                 |
| --------------------- | ----------------------------------------------------------------------- |
| `owner/repo@ref`      | action from a repository                                                |
| `owner/repo/path@ref` | action in a subdirectory                                                |
| `./path`              | action in this repository; requires checkout                            |
| `docker://image:tag`  | container action                                                        |
| `$/path`              | this repository at the running commit; no `@ref`; not available on GHES |

Local `./` and `$/` resolve on the runner workspace, not the workflow repository. Prefer
scripts or repository actions over copying logic into YAML.

## YAML pitfalls

- Filter patterns starting with `*`, `[`, or `!` must be quoted.
- In filter patterns, `?` means zero or one of the preceding character, not a wildcard.
- Anchors and aliases are supported on GitHub.com but are not portable to GHES and are harder
  for tools to analyze. Prefer reuse via reusable workflows or scripts.
