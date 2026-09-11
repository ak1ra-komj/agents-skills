# Reusable workflows

## When to extract

Extract a reusable workflow when the same multi-job pipeline is duplicated across workflows or
repositories and the shared interface (inputs, secrets, outputs, permissions) is stable. Do
not extract for a single caller, for a few shared steps, or to hide a complex workflow behind
indirection. Prefer a script or a composite action for shared steps.

## Calling

```yaml
jobs:
  call:
    uses: owner/repo/.github/workflows/ci.yml@<ref>
    with:
      target: ${{ matrix.target }}
    secrets: inherit
    permissions:
      contents: read
```

- `uses` accepts `./.github/workflows/file.yml` (same commit as the caller),
  `owner/repo/.github/workflows/file.yml@ref`, or `$/.github/workflows/file.yml` (this
  repository at the running commit, no `@ref`; not available on GHES). `$/` is the newer
  same-repo form and current actionlint releases may reject it; use `./` when local validation
  must pass.
- The called workflow must declare `on: workflow_call` and live directly in
  `.github/workflows/`.
- Calling jobs allow only `name`, `uses`, `with`, `secrets`, `strategy`, `needs`, `if`,
  `concurrency`, and `permissions`. `strategy` is allowed, so matrix calls work.

## Interface

- `on.workflow_call.inputs.<id>` requires `type` (`boolean`, `number`, or `string`); defaults
  are `false`, `0`, and `""`. Passing an undeclared input is an error.
- `on.workflow_call.secrets.<id>` declares secrets; passing an undeclared secret is an error.
  `secrets: inherit` forwards all caller secrets and skips the interface check.
- `on.workflow_call.outputs.<id>.value` must reference a job output
  (`${{ jobs.<id>.outputs.<name> }}`), not a step output. With a matrix, the last job that
  sets a value wins.
- The caller's workflow-level `env` does not propagate into the called workflow. Pass values
  as inputs or use repository variables.
- The `github` context is always the caller's; inside the called workflow `github.workflow` is
  the caller's workflow name.

## Permissions and secrets

- If the calling job does not set `permissions`, the called workflow gets the repository
  default, not the caller's token scopes.
- Permissions can only be downgraded through the call chain, never elevated.
- Secrets flow only to the directly called workflow. For A -> B -> C, B must pass them to C
  again.
- `id-token: write` for a reusable workflow outside your organization or enterprise must be
  granted explicitly by the caller.

## Limits

- Nesting: 10 levels total (4 on GHES); at most 50 unique reusable workflows per top-level
  caller (20 on GHES). Loops are rejected.
- Re-running all jobs resolves the ref again; re-running failed jobs keeps the original SHA.
- `concurrency` groups are repository-wide. If the caller and the called workflow both use
  `github.workflow` in the same group with `cancel-in-progress: true`, the called run can
  cancel its caller. Include a distinguishing component in the group.
