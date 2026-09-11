# Debugging failed runs

## Gather evidence first

Before changing YAML, collect:

- workflow file and name
- triggering event and ref
- failed job and step
- the failing log lines, not just the summary
- matrix dimension, if any
- recent changes to the workflow or the code it runs

With GitHub CLI:

```bash
gh run list --limit 10
gh run view <run-id>
gh run view <run-id> --log-failed        # failed steps only
gh run view <run-id> --log               # full log
gh run watch <run-id>
gh workflow list
gh workflow view <name-or-file>
gh workflow run <name-or-file> --ref <branch> -f key=value
```

`gh workflow view` shows workflows that exist on GitHub; it cannot validate a local workflow
that has not been pushed. Use actionlint for that.

## Classify before fixing

| Class                  | Evidence                                                      | Where the fix goes                                       |
| ---------------------- | ------------------------------------------------------------- | -------------------------------------------------------- |
| Workflow configuration | actionlint error, invalid key, missing `needs`, bad `runs-on` | YAML                                                     |
| Expression or context  | `Unrecognized named-value`, empty value, wrong `if` branch    | YAML, after checking context availability                |
| Permissions            | 403, `Resource not accessible by integration`, missing secret | `permissions`, token choice, secret scope                |
| Dependency or cache    | install failure, stale cache, wrong lockfile                  | workflow cache config or project dependency files        |
| Runner or environment  | tool missing, image or tag failure, disk full, OOM            | `runs-on`, setup steps, job resources                    |
| Project command        | test, build, or lint command exits non-zero                   | project code or scripts, not the workflow                |
| Transient external     | network timeouts, registry 5xx, rate limits                   | retry policy or a rerun; do not restructure the workflow |

A command failing inside GitHub Actions is not automatically an Actions problem. If the same
command fails locally, fix the project, not the YAML.

When you only have a pasted log and no repository or `gh` access, classify from the log, state
what cannot be confirmed, and ask for the missing evidence. Do not change YAML to guess at a
cause.

## Common signatures

| Signature                                                   | Likely cause                                                                              |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `Unrecognized named-value: 'matrix'` in `jobs.<id>.if`      | `matrix` is not available in job-level `if`; move the condition to the step               |
| Context value empty or marked invalid                       | context not available in that key; see `triggers-and-expressions.md`                      |
| Step skipped unexpectedly                                   | implicit `success()` plus a failed or skipped dependency; use an explicit status function |
| `Resource not accessible by integration`                    | `GITHUB_TOKEN` missing a scope; add it per job                                            |
| Fork PR secrets empty                                       | fork `pull_request` runs get no secrets by design; do not switch to `pull_request_target` |
| Cache never hits                                            | key too dynamic or wrong path; check `cache-hit` and restore keys                         |
| `npm ci ... package.json and package-lock.json are in sync` | lockfile drift or npm version mismatch; fix dependency files, not the workflow            |
| `::set-output` warning                                      | legacy workflow command; migrate to `$GITHUB_OUTPUT`                                      |
| Job queued forever                                          | `runs-on` labels match no runner, especially self-hosted                                  |
| Exit 137 or `terminated`                                    | OOM or cancellation; check memory and `cancel-in-progress`                                |

## Debug logging

Set `ACTIONS_STEP_DEBUG=true` as a secret or variable to enable step debug messages, and
`ACTIONS_RUNNER_DEBUG=true` for runner diagnostics. Anyone who can re-run a workflow can turn
these on for that run, so never rely on debug logs to protect secrets. The `runner.debug`
context can gate debug-only steps.

## Fix cycle

1. Reproduce or classify from the log.
2. Apply the smallest fix in the correct layer: YAML, permissions, script, or project code.
3. Run the verification ladder for the layer you changed.
4. If the failure is runtime and a real run is available, re-run the workflow and read the new
   log. Do not declare success from static checks alone.
5. After two attempts with the same error, stop changing YAML. Report the evidence and ask for
   the missing information.

## Local reproduction

`act` and similar tools are best-effort local emulators. They do not reproduce GitHub runner
images, the token model, secrets, environments, OIDC, the cache service, or action marketplace
resolution. Use them only as an optional smoke check and never describe their output as
authoritative GitHub behavior.
