# Security

Threat model and hardening for workflow YAML. Load for every new or changed workflow. Machine
checks (zizmor) cover a subset; the reasoning below is still required.

## Trust boundaries

The central question: can someone outside the trusted group trigger this workflow, and what
does the run get?

| Trigger                          | Triggered by      | Token     | Secrets |
| -------------------------------- | ----------------- | --------- | ------- |
| `push`, same-repo `pull_request` | collaborators     | write     | yes     |
| `pull_request` from a fork       | anyone            | read-only | no      |
| `pull_request_target`            | anyone            | write     | yes     |
| `workflow_run`                   | after another run | write     | yes     |
| `issue_comment`, `issues`        | anyone            | write     | yes     |
| `schedule`, `workflow_dispatch`  | maintainers       | default   | yes     |

Fork `pull_request` is safe by design. Do not switch to `pull_request_target` to regain
secrets for fork PRs; that hands a write token and secrets to arbitrary contributors.

## Script injection

`${{ }}` is expanded into the script text before the shell runs. Any attacker-controllable
value in a `run:`, a `script:` body, or an action input that reaches a shell is command
injection.

Untrusted sources include issue, PR, comment, and review bodies and titles; branch names
(`github.head_ref`, `github.event.pull_request.head.ref`); commit messages and author fields;
labels; and wiki page names. Treat any `github.event.*` field a non-collaborator can set as
untrusted.

Safe pattern: bind to `env:` and reference the quoted shell variable.

```yaml
# unsafe
- run: |
    echo "PR: ${{ github.event.pull_request.title }}"

# safe
- env:
    PR_TITLE: ${{ github.event.pull_request.title }}
  run: |
    echo "PR: $PR_TITLE"
```

The same applies to `actions/github-script` (read `process.env`, never interpolate into
`script:`) and to `with:` inputs of actions that pass inputs to a shell.

Writing untrusted multiline data to `$GITHUB_ENV` or `$GITHUB_OUTPUT` can inject variables or
outputs. Use the heredoc form with a delimiter that cannot appear in the value, and validate
the value shape first.

## Permissions

- If no `permissions:` is set, the workflow inherits the repository default, which may be
  read/write for most scopes.
- Set a restrictive workflow default, then elevate per job. `permissions: {}` denies all;
  `contents: read` is the usual baseline.
- When any permission is listed, all unlisted scopes become `none`.
- Fork `pull_request` runs downgrade write scopes to read; you cannot elevate them.
- `pull_request_target` runs get the repository's full read/write token.
- `GITHUB_TOKEN` events do not trigger new workflow runs, except `workflow_dispatch` and
  `repository_dispatch`, and approval-gated `pull_request` activity. Use a GitHub App token or
  PAT when you need chained runs.

## Secrets

- Store secrets in repository, organization, or environment settings, never in YAML.
- Environment secrets are readable only after the environment protection rules pass.
- Masking is exact-string and best effort. Transformed or structured data (JSON blobs) can
  defeat it. Do not store a structured document as one secret; register generated values with
  `::add-mask::`.
- Fork PR runs and Dependabot-triggered runs get no Actions secrets.
- Pass secrets to reusable workflows explicitly or with `secrets: inherit`; inherit forwards
  every accessible secret and is worth avoiding in shared workflows.

## Supply chain

Every `uses:` runs third-party code with your token and secrets.

- A full-length commit SHA is the only immutable reference. Tags and branches can be moved.
- Third-party actions require a deliberate decision: SHA-pin per repository policy, and verify
  the SHA belongs to the action's repository; a SHA from a fork is an impostor commit.
- Resolve a version to a SHA from the upstream repository (`git ls-remote
https://github.com/owner/repo refs/tags/vX.Y.Z` or the GitHub API). Never guess or invent a
  SHA.
- First-party `actions/*` and `github/*` are lower risk but still benefit from pinning. If the
  repository intentionally allows tags for first-party actions, record that policy instead of
  pinning everything to satisfy a tool default.
- Never use `@main` or `@master`.
- Keep a `# vX.Y.Z` comment next to a SHA so updates are reviewable.
- Enable Dependabot for the `github-actions` ecosystem to keep pins current.
- `actions/checkout` persists the token in `.git/config` by default. Set
  `persist-credentials: false` for jobs that later run untrusted code and for jobs that never
  push.

## Privileged triggers and untrusted code

`pull_request_target` and `workflow_run` run in the base repository with secrets and a write
token. The safe pattern is two workflows: an unprivileged `pull_request` workflow that runs
the untrusted code and uploads results, and a privileged `workflow_run` workflow that consumes
only the results as data.

Do not, in a privileged workflow:

- check out `github.event.pull_request.head.sha`, `refs/pull/N/merge`, or a fork repository
- run install, build, or test commands on untrusted code
- execute scripts or binaries from downloaded artifacts
- evaluate attacker-controlled configuration

`actions/checkout` blocks fork head refs in `pull_request_target` unless
`allow-unsafe-pr-checkout: true` is set. Treat that option as a red flag.

A privileged trigger used only for metadata operations (labels, comments, statuses) that never
checks out or executes contributor code is acceptable. Keep its token scoped to the single
write permission it needs, and never add a checkout "because the workflow might need it".

## Caches and artifacts

Caches and artifacts from low-trust runs are untrusted input to privileged workflows; restoring
or executing them can run attacker-controlled content. See `caching-artifacts.md` for cache and
artifact trust rules.

## Runners

GitHub-hosted runners are ephemeral. Self-hosted runners persist and can be compromised by
untrusted code, then used against later jobs or the surrounding network. Do not run
fork-triggered workflows on self-hosted runners. If self-hosted is required, use ephemeral or
JIT runners and isolate the network.

## OIDC

Prefer OIDC over long-lived cloud keys. `id-token: write` lets the job request a short-lived
JWT; the cloud provider must still trust it, scoped to this repository and ideally a branch or
environment. See `deployments-and-oidc.md` for setup.

## Reporting findings

State the trust boundary, the concrete exploit path, and the fix. Severity reflects who can
trigger the workflow and what the run can access. Do not mark a fork `pull_request` run
critical merely because it runs untrusted code; it has no secrets and a read-only token.
