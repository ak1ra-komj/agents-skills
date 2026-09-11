# developing-github-actions

An Agent Skill for creating, modifying, reviewing, debugging, and optimizing GitHub Actions
workflows (`.github/workflows/*.yml` and `*.yaml`). It is portable across Coding Agents that
support the Agent Skills mechanism and does not depend on any single vendor's proprietary
features.

## Purpose

Coding agents write GitHub Actions YAML confidently but frequently get the Actions-specific
semantics wrong: context availability, implicit `success()`, fork trust boundaries, script
injection through `${{ }}`, cache and artifact scope, matrix `include` behavior, and reusable
workflow restrictions. This skill packages the decision-changing parts of the official
documentation, established security practice, and machine verification into a small control
plane plus focused references.

## Scope

Covered:

- Workflow YAML: triggers, jobs, steps, expressions, contexts, variables
- Permissions, secrets, script injection, supply-chain pinning
- Caching, artifacts, matrix, concurrency
- Reusable workflows and workflow extraction decisions
- Environments, deployment protection, OIDC
- Debugging from real workflow runs with `gh`
- Static and security verification with `actionlint` and `zizmor`

Not covered:

- Authoring JavaScript, Docker, or composite custom actions
- GitLab CI, Jenkins, or other CI systems
- GitHub account, organization, or runner administration outside workflow YAML

When a task crosses into custom action authoring, the skill states the boundary and treats the
action implementation as a separate task.

## Design Principles

1. **Thin control plane.** `SKILL.md` routes the task and states non-negotiable rules. Detail
   lives in references, loaded only when relevant.
2. **Progressive disclosure.** Each reference owns one decision domain; no reference chains and
   no duplicated rules across files.
3. **Evidence over pattern matching.** Debugging starts from the run and its logs. Optimization
   starts from measured run data, not from the presence or absence of a cache block.
4. **Security by default.** Injection, permissions, trust boundaries, and credential exposure
   are considered on every workflow change, not only when a review is requested.
5. **Do not reimplement tools.** Static syntax, expression typing, and security analysis are
   delegated to actionlint and zizmor. The skill supplies reasoning, not a second linter.
6. **No over-engineering.** Matrix, cache, concurrency, and reusable workflows are added only
   when a requirement or measurement justifies them.
7. **Honest verification.** Passed, failed, and not run are reported as distinct states.
   Lower-tier checks are never presented as proof of higher-tier behavior.

## Project Structure

```
developing-github-actions/
|-- SKILL.md                          Control plane: scope, workflow, routing, hard rules
|-- README.md                         This file (human-facing, not loaded at runtime)
|-- agents/
|   `-- openai.yaml                   UI metadata for OpenAI products
|-- references/
|   |-- authoring.md                  Job/step mechanics, shell, env, outputs, if, needs
|   |-- triggers-and-expressions.md   Events, expressions, contexts, variables
|   |-- security.md                   Threat model and hardening
|   |-- reuse.md                      Reusable workflows and extraction decisions
|   |-- caching-artifacts.md          Cache and artifact mechanics and trust
|   |-- matrix-concurrency.md         Matrix expansion and concurrency groups
|   |-- deployments-and-oidc.md       Environments, protection rules, OIDC
|   |-- debugging.md                  Run evidence, failure classification, gh usage
|   `-- verification.md               Verification ladder and tool interpretation
`-- scripts/
    `-- verify.sh                     actionlint and optional zizmor wrapper
```

## Usage

Install the skill directory into any Agent Skills discovery path, for example
`~/.agents/skills/developing-github-actions/` or a project-local `.agents/skills/` directory.
The host agent loads `SKILL.md` and then reads references on demand.

The verification script can also be run directly from a repository checkout:

```bash
scripts/verify.sh                      # actionlint over .github/workflows
scripts/verify.sh --security           # plus offline zizmor
scripts/verify.sh .github/workflows/ci.yml
```

Exit codes: `0` all requested checks passed, `1` validation failed, `2` a requested tool is
unavailable or an environment or usage error occurred, `3` no workflow files found. The script
never installs tools, never modifies the repository, and needs no network access.

## Verification Tools

| Tool                                              | Role                                      | Install                                       |
| ------------------------------------------------- | ----------------------------------------- | --------------------------------------------- |
| [actionlint](https://github.com/rhysd/actionlint) | Static workflow and expression validation | release binary, Docker, or package manager    |
| [zizmor](https://github.com/zizmorcore/zizmor)    | Static security analysis                  | release binary, pip/pipx/uv, cargo, or Docker |
| [GitHub CLI](https://cli.github.com/)             | Remote workflow and run inspection        | package manager                               |

The skill does not vendor these tools. When one is missing, the corresponding tier is reported
as not run.

## Upstream Sources

Research was performed on 2026-09-11. Revisions are the commits or releases read at that time.
The skill paraphrases facts and adapts design ideas; it does not include substantial copied
text or code from any upstream project.

| Source                                                                                                                                                                                                    | Role in this skill                                                                                         | Revision / accessed                                       | License                                     | Adaptation                                                        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- | ------------------------------------------- | ----------------------------------------------------------------- |
| [GitHub Actions documentation](https://docs.github.com/en/actions)                                                                                                                                        | Authoritative behavior, syntax, security semantics                                                         | Accessed 2026-09-11                                       | CC BY 4.0 (docs content)                    | Facts re-expressed and compressed; no text copied                 |
| [github/docs](https://github.com/github/docs)                                                                                                                                                             | Source markdown behind docs.github.com, used to resolve included snippets                                  | `fca276503b17a1742e2dca1553288e92498c881b`                | CC BY 4.0                                   | Facts re-expressed; no text copied                                |
| [github/awesome-copilot](https://github.com/github/awesome-copilot)                                                                                                                                       | Skill organization and GitHub Actions reasoning                                                            | `7568a482ce2df38f8965ab5336a3220db796a4ba`                | MIT, Copyright GitHub, Inc.                 | Design ideas; independently rewritten                             |
| [github-actions-hardening](https://github.com/github/awesome-copilot/tree/main/skills/github-actions-hardening)                                                                                           | Threat model, trust matrix, injection patterns                                                             | Same commit                                               | MIT                                         | Concepts re-expressed; no files copied                            |
| [github-actions-efficiency](https://github.com/github/awesome-copilot/tree/main/skills/github-actions-efficiency)                                                                                         | Measure-first optimization approach                                                                        | Same commit                                               | MIT                                         | Concepts re-expressed; no files copied                            |
| [github-actions-runtime-upgrade-conventions](https://github.com/github/awesome-copilot/tree/main/skills/github-actions-runtime-upgrade-conventions)                                                       | Action version upgrade discipline                                                                          | Same commit                                               | MIT                                         | Concepts re-expressed; no files copied                            |
| [GitHub Actions CI/CD best-practices instructions](https://github.com/github/awesome-copilot/blob/main/instructions/github-actions-ci-cd-best-practices.instructions.md)                                  | Review checklist topics and workflow structure                                                             | Same commit                                               | MIT                                         | Concepts re-expressed; no text copied                             |
| [GitLab gitlab-ci-skill](https://gitlab.com/gitlab-org/ci-cd/gitlab-ci-skill)                                                                                                                             | Skill architecture: thin `SKILL.md`, progressive disclosure, verification ladder, evidence-first debugging | `6ddc101995c2504c5743612920e0f0748d854dc3`                | MIT, Copyright (c) 2026-present GitLab Inc. | Architecture adapted; GitLab CI semantics not carried over        |
| [rhysd/actionlint](https://github.com/rhysd/actionlint)                                                                                                                                                   | Static verification tool and its documented checks                                                         | `011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7` (post v1.7.12) | MIT, Copyright (c) 2021 rhysd               | Tool invoked; capability summary derived from its docs and source |
| [zizmorcore/zizmor](https://github.com/zizmorcore/zizmor)                                                                                                                                                 | Security analysis tool and its audit catalog                                                               | `bb180c27ef1f03dd231d8ca536fce7bcf458dfa9` (v1.30.1)      | MIT, Copyright (c) 2024 William Woodruff    | Tool invoked; audit summary derived from its docs and source      |
| [GitHub CLI](https://cli.github.com/)                                                                                                                                                                     | Remote workflow and run inspection commands                                                                | Manual accessed 2026-09-11; local `gh` 2.46.0             | MIT                                         | Commands referenced; no text copied                               |
| [actions/checkout](https://github.com/actions/checkout), [actions/upload-artifact](https://github.com/actions/upload-artifact), [actions/download-artifact](https://github.com/actions/download-artifact) | Artifact, checkout, and credential behavior                                                                | READMEs accessed 2026-09-11                               | MIT                                         | Behavior summarized; no text copied                               |

## Attribution and Licensing

This repository is distributed under the MIT License (see the repository `LICENSE`). The skill
directory is an independent work. The following notices apply to upstream material that
informed it:

- GitHub documentation content is licensed under CC BY 4.0. This skill paraphrases factual
  behavior from it with attribution; it does not reproduce documentation text.
- `github/awesome-copilot` is MIT licensed, Copyright GitHub, Inc. Concepts and design ideas
  from its GitHub Actions skills were re-expressed in original wording.
- `gitlab-ci-skill` is MIT licensed, Copyright (c) 2026-present GitLab Inc. Its skill
  architecture informed the structure of this skill; no GitLab CI content or text is included.
- `actionlint` is MIT licensed, Copyright (c) 2021 rhysd. It is invoked as an external tool and
  is not bundled.
- `zizmor` is MIT licensed, Copyright (c) 2024 William Woodruff. It is invoked as an external
  tool and is not bundled.
- The MIT license texts of the upstream projects are available in their repositories and are
  not reproduced here because no substantial portions of their code or text are redistributed.

This project is a community-developed Agent Skill. It is not affiliated with, endorsed by, or
sponsored by GitHub, GitLab, or any upstream project mentioned here. Product names are used
only to describe interoperability and sources.

## Maintenance and Refresh Strategy

GitHub Actions evolves: runner images move, action runtimes are deprecated, security defaults
change, and new syntax is added behind feature gates. To keep this skill accurate:

- Treat the official GitHub documentation as the source of truth; when this skill and the docs
  disagree, the docs win.
- Keep volatile facts out of references: specific action major versions, runner image lists,
  and deprecation dates are deliberately not pinned as recommendations.
- Re-research the upstream sources in the table above when GitHub announces workflow syntax,
  security, or runner changes, and update the revision column.
- Re-run `scripts/verify.sh` against fixture workflows after editing references or the script,
  and keep `shellcheck` and `shfmt` clean for `verify.sh`.
- Record the next review date and the reviewer in the repository history when refreshing.
