# Create avoid-ai-writing-patterns skill

Created the `avoid-ai-writing-patterns` skill based on Wikipedia's Signs of AI Writing guide.

## Summary

The user asked for a new agent skill to help avoid common AI writing patterns when producing non-technical prose. The starting point was the Wikipedia page at https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing. An initial draft was written with the name `signs-of-ai-writing` and placed in a matching directory. After review the name was changed to `avoid-ai-writing-patterns` to better reflect purpose (avoiding the patterns, not describing them), the description was narrowed to non-technical prose and excludes technical docs and commit messages, and the skill content was reorganised into four sections: Word choice, Grammar, Content, Tone, and Format. A final pass added the plaintext-only output requirement that had been missing from earlier drafts.

## Changed files

- `skills/avoid-ai-writing-patterns/SKILL.md` — new skill file; created from scratch, iterated through four drafts during the session
- `skills/signs-of-ai-writing/SKILL.md` — initial draft location; content was superseded and the directory was left empty after the user renamed the folder externally

## Git commits

- `9e00ece` docs(avoid-ai-writing-patterns): update formatting guidelines to specify plaintext usage and clarify list usage
- `ed6fc17` feat(avoid-ai-writing-patterns): add new skill for writing non-technical prose

## Notes

- The `name` field in SKILL.md frontmatter should reflect what the skill instructs the agent to do, not what it describes. `avoid-ai-writing-patterns` is clearer than `signs-of-ai-writing` because the latter sounds like a detection guide rather than a writing guide.
- The `description` field is used by the agent to decide whether to load the skill. Scoping it precisely (non-technical prose; not technical docs or commit messages) prevents the skill from firing when it would not help.
- The plaintext-only rule belongs in the skill body, not just in the user's original prompt. Skills travel with the repository; the original prompt does not.
- The Wikipedia page groups AI patterns into: overloaded vocabulary, copulative avoidance (replacing "is/are" with "serves as/stands as"), superficial analysis appended via "-ing" phrases, promotional tone, vague attribution, negative parallelisms ("not just X but also Y"), rule of three, elegant variation (synonym substitution to avoid repetition), challenges-and-future-prospects boilerplate, and em dash overuse. All of these are worth keeping as distinct rules in the skill.
- When writing word lists in a skill, include the specific words documented by research (the Wikipedia page cites multiple studies). A vague instruction like "avoid AI words" is weaker than listing the actual words.
