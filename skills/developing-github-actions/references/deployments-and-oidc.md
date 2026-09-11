# Deployments, environments, and OIDC

## Environments

- A job gets an environment with `environment: name` or an object with `name`, `url`, and
  `deployment`.
- Referencing a nonexistent environment creates it. Protection rules (required reviewers, wait
  timer, deployment branch and tag restrictions) are configured in GitHub settings, not in
  YAML; a workflow can only reference them.
- Protection rules gate the job before it starts. A job waiting for approval more than 30 days
  fails automatically.
- Environment secrets and variables are available only to jobs that reference the environment,
  and secrets only after the protection rules pass. Environment secrets override repository
  and organization secrets of the same name.
- `deployment: false` keeps environment secret and variable access without creating a
  deployment record. Custom protection rules fail the job immediately in that mode.
- Branch restrictions match `GITHUB_REF` with glob semantics; allow `refs/pull/*/merge` only
  when PR-triggered deployments are intended.

## Deployment job shape

- Build once, deploy the same artifact. Upload in the build job, download in the deploy job.
- Gate deploy jobs with `environment:`, `needs:`, and `if:` for the branch or tag.
- Add `concurrency` with a stable group per target and `cancel-in-progress: false` so two
  deploys to the same target cannot overlap.
- Set `timeout-minutes` and keep deploy steps idempotent.
- For production, prefer a manual approval environment over a fragile `workflow_dispatch`
  gate.

## OIDC

OIDC replaces long-lived cloud credentials with a short-lived JWT exchanged for cloud
credentials.

- The job needs `permissions: id-token: write`. That permission only allows requesting the
  token; it does not grant any cloud access.
- The cloud provider must trust GitHub's OIDC issuer and restrict the trust policy by
  repository and, ideally, branch or environment. A trust policy with no conditions allows any
  GitHub repository to assume the role.
- Default `sub` formats:
  - branch or tag: `repo:OWNER/REPO:ref:refs/heads/BRANCH`
  - pull request: `repo:OWNER/REPO:pull_request`
  - environment: `repo:OWNER/REPO:environment:ENV`
- Referencing an environment changes the subject claim; if the trust policy requires the
  environment claim, the job must set `environment:`.
- Common actions: `aws-actions/configure-aws-credentials`, `azure/login`,
  `google-github-actions/auth`, and provider publish actions such as
  `pypa/gh-action-pypi-publish`. Pin them per the repository policy.
- A reusable workflow owned by another organization or enterprise needs the caller to grant
  `id-token: write` explicitly.
- GHES uses a different issuer (`https://HOSTNAME/_services/token`).

## Deployment verification

Local tools cannot validate OIDC or environment protection. Verify on GitHub: dispatch the
workflow on a safe branch, watch the job, and confirm the cloud role assumption. When
reporting, distinguish what was statically checked from what only a real run proves.
