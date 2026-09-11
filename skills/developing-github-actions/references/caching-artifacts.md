# Caching and artifacts

Cache and artifacts solve different problems. Cache is for regenerable dependencies and
intermediate state across runs. Artifacts are for build outputs, reports, and passing data
between jobs. Do not use one where the other fits.

## Dependency caching

- Prefer the built-in caching of setup actions (`setup-node`, `setup-python`, `setup-java`,
  `setup-go`, and similar) over hand-written `actions/cache` steps. Enabling it for a committed
  lockfile on trusted triggers is a low-risk default; manual `actions/cache` entries for other
  paths need justification.
- `actions/cache` lookup order: exact `key` on the current branch, then `key` prefix, then
  each `restore-keys` prefix, then the same on the default branch. The most recently created
  match wins.
- `cache-hit` is `true` only for an exact key match. A `restore-keys` hit is still a miss for
  gating.
- Key on lockfile hashes, not on `github.run_id` or timestamps. Add a run-id suffix only when
  a cache must never be reused.
- Scope: a branch can restore its own caches and default-branch caches; PR runs can also
  restore the base branch. Caches are not shared between unrelated branches or tags.
- Limits: 10 GB per repository by default, evicted after 7 days without access (LRU).
- `actions/cache/restore` and `actions/cache/save` allow split restore and save, which is
  useful when a job may only read caches.

## Cache trust

Caches are unsigned and can be written by less-privileged runs. Do not restore caches into a
privileged workflow when untrusted code can influence the cache key, and never cache secrets
or credentials.

Low-trust triggers (`pull_request_target`, `workflow_run`, `issue_comment`) get read-only
cache access by default. Overriding that reintroduces cache poisoning. The `cache-mode` key
(`read`, `write`, `write-only`, `none`) controls this on supported GitHub plans; do not set
`write` on an untrusted trigger without a concrete reason.

## Artifacts

- Upload with `actions/upload-artifact`, download with `actions/download-artifact`. Artifacts
  are immutable per name in v4 and later: uploading the same name again fails unless
  `overwrite: true`.
- Give each matrix leg a unique artifact name, or uploads collide.
- Hidden files and directories are excluded by default (`include-hidden-files: false`).
- Zip archives do not preserve the executable bit. Use `tar` plus `archive: false` when
  permissions matter.
- `download-artifact` extracts a single artifact directly to `path`; multiple artifacts create
  per-name subdirectories unless `merge-multiple: true`.
- Default retention is 90 days. Set `retention-days` deliberately for large or sensitive data.
- To pass data between jobs, upload in the producer and declare `needs:` on the consumer. Job
  outputs are for small values only.

## Artifact trust

Artifacts produced by fork PRs or other workflows are untrusted. A privileged `workflow_run`
may download them as data but must not execute their contents, and should validate paths when
extracting because archives can contain traversal entries. The same applies to reports
rendered as HTML or interpreted as scripts.
