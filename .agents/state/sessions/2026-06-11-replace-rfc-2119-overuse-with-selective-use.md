# Replace RFC 2119 overuse with selective, criteria-driven use across all skills

## Summary

The previous RFC 2119 adoption (session 2026-04-28) applied MUST/SHOULD/MUST NOT to
nearly every instruction in every skill, causing agents to over-focus on keyword-heavy
lines and ignore genuinely critical rules. The `reviewing-agents-md` skill compounded
this by instructing agents to use RFC 2119 keywords when generating AGENTS.md for
target repos, creating a cascade of excessive MUST requirements.

This session replaced the blanket RFC 2119 style with a tiered approach:
- MUST/MUST NOT for hard constraints where violation = broken/incorrect/insecure output
- SHOULD/SHOULD NOT for strong preferences with rare valid exceptions
- Plain imperative for routine guidance, style conventions, and workflow steps

The chatbot-oriented content (`skills/summarize-current-chat/` and the ChatGPT custom
instruction in README.md) was moved to `docs/` as reference documents, since they are
designed for web chatbots without filesystem access and do not fit as agent skills.

## Changed files

- `AGENTS.md` - replaced the "RFC 2119 keywords" section with guidance on selective use; removed output style rules into a separate section
- `README.md` - removed RFC 2119 promotion from Authoring Skills; removed `summarize-current-chat` from table; removed ChatGPT custom instruction section; added Reference Documents section linking to docs/
- `skills/reviewing-agents-md/SKILL.md` - changed "Avoid RFC 2119 keywords" to "Use RFC 2119 keywords selectively"; updated Environment & Tooling section to remove MUST/MUST NOT rule reference
- `skills/commit-and-summarize/SKILL.md` - rewrote commit message style, session log style rules, and Phase 3 rules with selective RFC 2119 (MUST NOT for hard constraints, SHOULD for conventions)
- `skills/keep-a-changelog/SKILL.md` - rewrote style rules with selective RFC 2119; updated section rules to use MUST
- `skills/developing-ansible/SKILL.md` - converted agent-facing instructions to plain imperative
- `skills/developing-ansible/common.md` - rewritten with selective MUST/SHOULD (MUST NOT hard-code hosts, MUST store secrets in Vault, SHOULD use .yaml extension and lowercase booleans)
- `skills/developing-ansible/developing-playbooks.md` - rewritten (MUST be idempotent, MUST NOT hard-code IPs, SHOULD set gather_facts/become explicitly)
- `skills/developing-ansible/developing-tasks.md` - rewritten (MUST use FQCN, MUST use loop, MUST reference ansible_facts, SHOULD prefer modules over shell/command)
- `skills/developing-ansible/developing-roles.md` - rewritten (MUST NOT duplicate vars, MUST use notify, MUST keep handlers unique)
- `skills/developing-ansible/handling-boolean-values.md` - rewritten (MUST NOT compare with == true/false, MUST NOT use |bool on non-boolean values, SHOULD use lowercase true/false)
- `skills/developing-ansible/jinja2-templates.md` - rewritten (MUST NOT rely on undefined collapse, SHOULD use |default() and whitespace control)
- `skills/developing-ansible/reference-code-blocks.md` - minor prose cleanup
- `skills/developing-bash-scripts/SKILL.md` - converted to plain imperative
- `skills/developing-bash-scripts/common.md` - rewritten (MUST use [[ ]], MUST pass shellcheck, MUST quote expansions, SHOULD use case/guard clauses)
- `skills/developing-bash-scripts/developing-complex-bash-scripts.md` - rewritten (MUST include Usage+Arg Parsing when flags present)
- `skills/developing-bash-scripts/developing-simple-bash-scripts.md` - rewritten
- `skills/developing-bash-scripts/reference-code-blocks.md` - rewritten (MUST use getopt not getopts)
- `skills/developing-posix-shell-scripts/SKILL.md` - converted to plain imperative
- `skills/developing-posix-shell-scripts/common.md` - rewritten (MUST NOT use Bash features, MUST NOT use pipefail, MUST pass shellcheck, MUST use $() not backticks)
- `skills/developing-posix-shell-scripts/developing-complex-posix-shell-scripts.md` - rewritten
- `skills/developing-posix-shell-scripts/developing-simple-posix-shell-scripts.md` - rewritten (SHOULD NOT pad with boilerplate)
- `skills/developing-posix-shell-scripts/reference-code-blocks.md` - minor prose cleanup
- `skills/summarize-current-chat/SKILL.md` - moved to `docs/summarize-current-chat.md`, frontmatter removed, rewritten with selective RFC 2119
- `docs/chatgpt-custom-instruction.md` - extracted from README.md ChatGPT section, preserved the instruction block verbatim

## Git commits

- `538b8ba` docs: move chatbot-oriented content out of skills
- `618f056` docs: replace rfc 2119 overuse with selective use

## Notes

- The key insight: RFC 2119 keywords are valuable for signaling hard constraints, but overusing them (MUST on every line) causes agents to habituate and ignore all of them. The solution is not to ban them, but to use them only where violation has real consequences.
- The tiered criteria (MUST = broken output, SHOULD = strong preference, plain imperative = style/routine) provides a clear framework for future skill authoring.
- The `reviewing-agents-md` skill was the cascade point - its instruction to generate RFC 2119-heavy AGENTS.md files for target repos was the root cause of the strange behavior. Fixing that one rule was the highest-impact change.
- Chatbot-oriented content (web chat summarization, ChatGPT custom instruction) belongs in reference documents, not as agent skills. Skills target coding agents with filesystem access; web chatbot prompts serve a different audience.
