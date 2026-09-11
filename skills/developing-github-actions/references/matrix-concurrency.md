# Matrix and concurrency

## Matrix

Use a matrix when the decision requires multiple environments or versions. Do not add a matrix
to look thorough; every leg costs runner minutes and adds a failure mode.

- A matrix produces the cartesian product. `include` is the part that confuses people:
  - An `include` entry augments original combinations where it does not overwrite original
    values. If it would overwrite one, it creates a new additional combination instead.
  - Original values are never overwritten. Later `include` entries can overwrite values added
    by earlier ones.
  - `exclude` runs first and is a partial match: any subset of matching keys removes the
    combination. `include` can add a combination back.
  - With no matrix keys, all `include` entries run.
- Values can be arrays of objects, producing nested properties such as `matrix.node.version`.
- A dynamic matrix comes from `fromJSON(needs.<job>.outputs.<name>)`; the output must be a
  JSON array or object.
- `fail-fast` defaults to `true` and cancels other legs on the first failure. Set it to
  `false` when complete results are required, and use `continue-on-error` per leg for
  experimental targets.
- Limit: 256 jobs per workflow run.
- Reduce breadth by event: full matrix for releases and compatibility validation, a
  representative leg for ordinary changes.

## Concurrency

- At most one run is in progress and one is pending per group. A new pending run replaces the
  older pending run; it does not cancel the running one unless `cancel-in-progress: true`.
- Groups are repository-wide. Scope them with the workflow name, for example
  `${{ github.workflow }}-${{ github.ref }}`, or a run can cancel runs from another workflow.
- Group names are case-insensitive; ordering is FIFO by wait time and is not guaranteed.
- `cancel-in-progress` accepts an expression; protect release branches from cancellation.
- Use a PR-specific group such as
  `${{ github.workflow }}-${{ github.head_ref || github.run_id }}` so PR runs cancel each other
  without canceling branch runs.
- `queue: max` allows up to 100 pending runs and cannot be combined with
  `cancel-in-progress: true`.
- Deployments are not serialized by `environment:` alone. Add a `concurrency` group when a
  deployment must not overlap.
- On cancellation, jobs with `always()` still run. Expect a short grace period before the
  process is killed.
