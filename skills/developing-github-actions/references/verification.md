# Verification

The verification ladder, tool capabilities, and how to interpret `scripts/verify.sh`. Load
when running or interpreting verification.

## Ladder

| Tier       | Tool                 | Catches                                                                                                                                                                                        | Does not catch                                                                     |
| ---------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| Static     | actionlint           | workflow syntax, expression types, context availability, `needs` graph, runner labels, action inputs and outputs, reusable workflow calls, cron and glob syntax, shellcheck findings in `run:` | runtime behavior, permissions semantics, remote actions, remote reusable workflows |
| Security   | zizmor               | excessive permissions, injection, unpinned or unsafe action refs, dangerous triggers, credential exposure, artifact and cache trust issues                                                     | runtime behavior; some audits need network and are skipped offline                 |
| Repository | project commands     | missing scripts, wrong flags, broken build or test                                                                                                                                             | GitHub-specific behavior                                                           |
| Remote     | `gh` plus a real run | fork token behavior, environments and approvals, OIDC, cache service, runner images, marketplace resolution                                                                                    | workflows that are not pushed                                                      |

Fix the first failing tier before moving down. Do not skip the security tier on new or changed
workflows.

## scripts/verify.sh

```bash
scripts/verify.sh                      # discover .github/workflows, run actionlint
scripts/verify.sh --security           # also run zizmor (offline)
scripts/verify.sh FILE...              # specific files
scripts/verify.sh --dir path/to/workflows
```

| Exit code | Meaning                                                          | Action                                   |
| --------- | ---------------------------------------------------------------- | ---------------------------------------- |
| 0         | all requested checks passed                                      | proceed                                  |
| 1         | validation failed                                                | read findings, fix, re-run               |
| 2         | a requested tool is unavailable, or a usage or environment error | report the tier as not run; do not guess |
| 3         | no workflow files found                                          | check the path                           |

The script never installs tools, never modifies the repository, and never requires network
access. If actionlint is missing, install it (`rhysd/actionlint`, MIT) or report that static
validation was not run. If zizmor is missing, the security tier was not run; do not claim the
workflow is hardened.

## actionlint

- Run from the repository root so local actions, local reusable workflows, and
  `.github/actionlint.yaml` resolve. `verify.sh` handles this.
- It needs a detectable project root (a directory containing `.git` and `.github/workflows`)
  to deep-check local `./` actions and reusable workflows. Without one, those references are
  not resolved and a pass does not prove their interface.
- Recent syntax such as `$/` self-repository references may not be recognized yet. If a valid
  workflow fails on it, check the actionlint version before changing the workflow.
- It uses shellcheck and pyflakes when they are installed; when absent, those checks are
  silently skipped.
- Remote actions and remote reusable workflows are not fetched. Only `./` references get deep
  validation.
- Configure self-hosted runner labels and allowed config variables in
  `.github/actionlint.yaml`; without that, custom labels are reported as errors.
- Expression checking is intentionally stricter than the runtime, for example rejecting object
  values in `${{ }}`. Treat findings as real, but confirm runtime-legal edge cases against the
  docs.
- There is no official GitHub Action; use the download script or the Docker image in CI.

## zizmor

- Offline mode: `zizmor --offline --format=plain .github/workflows`. Online audits
  (`impostor-commit`, `known-vulnerable-actions`, `ref-confusion`, `stale-action-refs`,
  `ref-version-mismatch`) need a token and network and are skipped.
- The default persona is `regular`. It suppresses some findings, including
  `excessive-permissions` for a workflow with a single job. `verify.sh --security` uses the
  default persona and is a baseline, not a complete audit. For a security review, also run
  `zizmor --persona=auditor --min-severity=medium .github/workflows` and reason about the extra
  findings.
- The default `unpinned-uses` policy requires a SHA for every action, including first-party
  ones. If the repository intentionally allows tags for first-party actions, configure
  `rules.unpinned-uses.config.policies` in `zizmor.yml` or accept the finding as a recorded
  decision; do not change the repository's pinning policy just to make the tool pass.
- A deliberately safe privileged-trigger workflow still triggers `dangerous-triggers`. If the
  usage is reviewed and safe, suppress that finding inline with a comment explaining why, or
  accept it; do not remove the trigger to silence the tool.
- Exit codes 11 to 14 mean findings at informational, low, medium, or high severity; 0 means
  none.
- Suppress a finding only after deciding it is a false positive or an accepted risk, and leave
  a comment explaining why. Never blanket-disable an audit to make CI green.
- zizmor analyzes definitions only; it does not run the workflow and does not inspect scripts
  the workflow calls.

## Remote verification

Use `gh` when the repository is on GitHub and the task needs real behavior:

```bash
gh run list --workflow <file> --limit 10
gh run view <run-id> --log-failed
gh workflow run <file> --ref <branch>
```

`workflow_dispatch` runs need the workflow on the default branch for the first run and
explicit inputs. Ask before triggering a real run, especially for anything with side effects.
Remote verification is the only way to confirm token behavior, environment approvals, OIDC,
and runner availability.

## Reporting

Separate three states when reporting verification: passed, failed, and not run (tool or access
unavailable). Never present a lower tier as proof of a higher tier. State explicitly what was
checked locally and what remains unverified.
