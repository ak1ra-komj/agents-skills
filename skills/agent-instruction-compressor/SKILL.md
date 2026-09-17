---
name: agent-instruction-compressor
description: Use when compressing, shortening, or simplifying an existing Agent Skill or its references without losing important behavior, reducing context usage, deduplicating SKILL.md and references, reviewing progressive disclosure, or running a final compression pass before validation or packaging.
---

# agent-instruction-compressor

Run a final compression and context-efficiency review on an existing Agent
Skill. Minimize loaded context while preserving or improving behavioral
constraints, decision quality, and execution reliability. This is not
summarization.

Modify the target skill directly. If the user asks only for a review, output
recommendations without editing files.

## Fresh context

Prefer running this pass in a sub-agent or other fresh context when one is
available: it then judges the target skill without the invoking conversation's
context. Pass the target skill path and the mode (review or write), not a
retyped copy of the skill; the fresh agent must read the target from disk and
must not assume context it was not given.

## Scope

Review `SKILL.md` and all Markdown files in the skill (typically under
`references/`). Check `agents/openai.yaml` only for concise trigger metadata
consistent with the `SKILL.md` description; do not edit unrelated fields. Do
not change the behavior of `scripts/` or `assets/`. Delete templates, examples,
and empty directories only after confirming nothing in the skill references
them.

## Keep-or-delete test

For every paragraph, rule, example, and reference file ask:

> If this were removed, would the agent become materially more likely to make
> an incorrect decision, violate an important constraint, choose the wrong
> workflow, or fail the task?

If no, delete. If valuable but long, compress. If needed only by a narrow class
of tasks, move to a conditional reference. Judge by behavioral value per token,
not knowledge coverage. For any longer passage, name the concrete mistake an
agent could make without it; if no realistic failure mode exists, delete or
compress further.

Preserve:

- instructions that change agent behavior, hard constraints, decision rules,
  failure-prevention rules, validation requirements, and workflow routing
- non-obvious engineering knowledge, anti-patterns, exceptions, and facts
  prior model knowledge would likely get wrong
- `condition -> action`, `condition -> exception`, and
  `decision -> consequence` relationships
- safety constraints, destructive-operation safeguards, required tool usage,
  environment assumptions, explicit user requirements, compatibility
  boundaries, error handling, false-positive verification guards, and
  distinctions between mutually incompatible workflows, even when rarely
  triggered

Delete:

- background, history, tutorials, textbook concepts, and common knowledge
- duplicated official documentation and full CLI/API/reference enumerations
- intros that repeat the description and summaries or conclusions that repeat
  the body
- near-duplicate phrasings of one rule and best-practice filler with no
  behavioral effect
- content that exists only to look complete

Never create fake brevity: do not drop exceptions or failure handling, replace
precise rules with vague slogans, merge distinct rules, remove reference
routing, or rely on assumed project knowledge.

## Progressive disclosure

Treat `SKILL.md` as the control plane: core workflow, always-on rules, main
decision points, conditional reference routing, and final validation. Move
detail to `references/` only when a realistic class of tasks needs it and most
other tasks do not; otherwise keep it in `SKILL.md` or delete it. Every
reference must be discoverable directly from `SKILL.md`; never build
`SKILL.md -> A.md -> B.md` chains.

Deduplicate globally: give each rule one canonical location. If the full rule
lives in a reference, keep only the route in `SKILL.md`.

Challenge every reference: delete it if no realistic task benefits from
loading it, or fold its few valuable rules elsewhere. Scrutinize catch-all
files such as `overview.md`, `concepts.md`, `examples.md`, `best-practices.md`,
`faq.md`, and `cli-reference.md`.

Challenge every example: keep it only when it expresses a relationship hard to
state as a rule, prevents a common error, shows a format to imitate exactly,
combines several rules, or provides a deterministic pattern. Keep the densest
example per pattern; prefer minimal snippets over complete files.

Prefer stable decision knowledge over volatile facts such as version-specific
options, CLI arguments, API fields, provider support, and compatibility
matrices. Tell the agent when to verify and where the authoritative source is
instead of caching external documentation.

## Rewrite rules

Rewrite tutorial prose as concise imperative rules. Remove filler such as
"generally", "usually", "it is important to", "it should be noted", and "in
order to", but keep qualifiers that express real uncertainty or exceptions.

Do not change domain semantics. Fix only clear contradictions, conflicting
duplicates, known errors, or broken progressive-loading structure; report
suspected errors instead of silently correcting them.

Keep the frontmatter `description` accurate enough to trigger on what the
skill does, when to invoke it, and typical user intent; do not over-compress
it. Remove trigger-irrelevant background and do not repeat the description as
a "When to use" section in the body.

## Workflow

1. Inspect the skill tree, `SKILL.md`, references, and metadata. Understand the
   problem the skill solves before deleting anything.
2. Identify invariants: primary workflows, hard constraints, decision
   boundaries, failure prevention, validation, and reference routing.
3. Classify each block as critical, conditional, redundant, referenceable, or
   low-value.
4. Deduplicate globally with one canonical location per rule.
5. Rewrite for density, preferring delete over compress over relocate. Move
   conditional detail to a reference when that clearly improves progressive
   loading.
6. Simplify structure: merge related references, fold tiny ones back into
   `SKILL.md`, and delete empty directories. Progressive disclosure avoids
   irrelevant context; it does not maximize file count.
7. Re-read the compressed skill from scratch. An agent must be able to tell
   what to do first, which constraints are binding, how to branch, when to load
   references, and how to validate. If not, compression went too far.
8. Counterfactual check: for 5-10 important real task types, would an agent
   using only the compressed skill be materially more likely to decide wrong?
   Restore the minimal rule that removes the failure mode, not the original
   paragraph.

There is no target percentage or line count. If the skill is already tight,
leave it unchanged. A second run must not churn wording, headings, or file
layout for the sake of a diff.

## Validate and report

Run the target skill's validator or packaging workflow if one exists, and fix
problems caused by this review. A passing validator does not prove behavior
preservation; rely on the counterfactual check. Also check: frontmatter
complete, reference paths valid, no dangling links, no empty files, no
leftover templates, no duplicate canonical rules, and all required
instructions still discoverable. Run tests if invocation patterns changed.

End with a short review summary. Cover what was removed by category, what
moved to references, references merged or deleted, over-compression risk,
whether progressive loading still holds, core content kept because it cannot
be compressed further, and suspected errors left unfixed.

```text
Compression review complete.
- Removed repeated background and tutorial material.
- Consolidated scenario-selection rules into scenarios.md.
- Reduced duplicate examples from four to one.
- Kept destructive-operation and validation safeguards unchanged.
- Validation passed.
```

Do not produce a paragraph-by-paragraph report unless asked. If nothing
material can be improved, state `No material compression was justified.` and
leave the files unchanged.
