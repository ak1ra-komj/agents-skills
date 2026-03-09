# Trim SKILL.md Files to Reduce Token Cost

Refactored three SKILL.md files to reduce per-session token consumption and improve reference document loading precision.

## Summary

The `developing-ansible` skill was loading all seven reference documents on every invocation (~40k tokens). The root causes were: (1) `description` fields used "Guidelines for…" phrasing that doesn't serve as a usable trigger condition; (2) reference document tables listed only topic/covers columns with no actionable load conditions, leading agents to load everything; (3) `developing-bash-scripts` and `developing-posix-shell-scripts` used verbose classification tables and redundant prose. The session replaced tables with inline prose criteria, rewrote `description` fields as "Use when…" trigger conditions, added explicit "Load when" conditions per reference document, and promoted `common.md` + `developing-tasks.md` to always-load in the ansible skill. One commit was made.

## Changed Files

- `skills/developing-ansible/SKILL.md` — Rewrote `description` as a trigger condition; removed table; split reference documents into always-load (`common.md`, `developing-tasks.md`) and conditional-load with explicit "Load when" criteria per document.
- `skills/developing-bash-scripts/SKILL.md` — Rewrote `description`; replaced classification table with inline Simple/Complex prose criteria; replaced flag-auditing sub-section with a single paragraph covering both the "genuinely varies" test and common-sense hardcoding heuristic; restructured Step 2 to use "Load when" phrasing.
- `skills/developing-posix-shell-scripts/SKILL.md` — Same changes as bash skill; kept POSIX-specific differences (`-h` vs `--help`, bash-isms forbidden note).

## Git Commits

- `c02e10e` refactor: trim SKILL.md files to reduce token cost

## Notes

- `description` in a skill's front matter is the trigger condition used for skill matching — it must start with "Use when…", not "Guidelines for…". The latter describes content rather than invocation context and is ineffective.
- A reference document table with "Topic / Covers" columns gives an agent no signal about _when_ to load each document — it loads all of them defensively. Replacing with explicit "Load when <condition>" bullet points constrains loading to what the request actually requires.
- Promoting small, universally needed documents to always-load (e.g. `common.md` at 23 lines, `developing-tasks.md` at 48 lines) is a reasonable trade-off: the fixed cost is low and it removes ambiguity.
- For flag/complexity classification, "would a caller genuinely pass different values?" is necessary but not sufficient. Common-sense hardcoding heuristics (internal paths, fixed timeouts, log levels for non-CLI tools) should also be applied — not everything that _could_ vary _should_ be a flag.
- The current implementation's flag count is not evidence of correct classification; always re-classify from scratch when reviewing.
