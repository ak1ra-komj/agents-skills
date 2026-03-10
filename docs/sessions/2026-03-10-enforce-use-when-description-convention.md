# Enforce "Use when" description convention across skills and docs

Audited and aligned all `description` fields in SKILL.md files and README.md to consistently lead with the form **"Use when [condition]"**.

## Summary

The repository lacked a written convention for how `description` fields should be phrased. This led to some skills (e.g., `init-agents-md`, `keep-a-changelog`, `summarize-current-session`) using action-first phrasing ("Generates…", "Maintains…", "Summarizes…") with the trigger condition appended at the end, making it harder for agents to determine when to load the skill. The session established the convention, applied it retroactively to all non-conforming SKILL.md files, and kept README.md in sync throughout.

## Changed files

- `AGENTS.md` — added convention bullet: `description` fields must use the form **"Use when [condition]"**; applies equally to skill descriptions and reference document descriptions.
- `README.md` — added **Authoring Skills** section explaining the convention; updated the Available Skills table descriptions to match each SKILL.md's `description` field exactly.
- `skills/init-agents-md/SKILL.md` — reordered `description` to lead with "Use when…", moving the action clause inline.
- `skills/keep-a-changelog/SKILL.md` — reordered `description` to lead with "Use when…".
- `skills/summarize-current-session/SKILL.md` — reordered `description` to lead with "Use when…", removing the redundant action preamble.

## Git commits

No commits were made in this session.

## Notes

- The "Use when [condition]" form is a trigger-oriented phrase — it tells the agent the condition under which to load the file, rather than describing what the file does. This is a more reliable signal for agent dispatch.
- Descriptions that lead with an action ("Generates…", "Maintains…") describe content, not invocation context; they are easy to confuse with the skill body and tend to be ignored by agents scanning for relevance.
- The same convention applies to reference documents inside a skill (the `Load when …` clauses in `## Reference Documents` sections), not just top-level SKILL.md `description` fields.
- When auditing conformance, check: does the description answer "when should I load this?" before answering "what does this do?".
