## 1. Fix typo in commit-and-summarize

- [x] 1.1 In `skills/commit-and-summarize/SKILL.md`, fix the filename-template block `YYY-MM-DD-<session-title>.md` to `YYYY-MM-DD-<session-title>.md`

## 2. Replace non-ASCII punctuation in shell skills

- [x] 2.1 In `skills/developing-bash-scripts/common.md`, replace the em dash `—` with `-`
- [x] 2.2 In `skills/developing-posix-shell-scripts/SKILL.md`, replace `0–2` with `0-2` and `≥ 50` with `>= 50`

## 3. Replace non-ASCII punctuation in Ansible skill

- [x] 3.1 In `skills/developing-ansible/handling-boolean-values.md`, replace every `→` with `->` and `≥` with `>=`
- [x] 3.2 In `skills/developing-ansible/jinja2-templates.md`, replace `→` with `->`

## 4. Add prettier convention to AGENTS.md

- [x] 4.1 In `AGENTS.md`, add a bullet under "Conventions": "Run `prettier -w` on every modified file before finishing."

## 5. Verify

- [x] 5.1 Run a non-ASCII scan over `skills/` and `AGENTS.md` (e.g. `grep -rnP '[^\x00-\x7F]' skills/ AGENTS.md`) and confirm no matches remain
