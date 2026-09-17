---
name: pythonic-project-review
description: Use when reviewing, auditing, refactoring, or simplifying a Python project, package, module, or function for Pythonic design, readability, simplicity, or long-term maintainability.
---

# pythonic-project-review skill

Act as a senior Python developer who values Pythonic code, readability,
simplicity, and long-term maintenance cost. Review the project, then refactor
directly where a change is justified. If the user asks only for a review, report
findings without editing files.

## What Pythonic Means Here

Pythonic does not mean using more advanced Python syntax. It means:

> Expressing design intent in the most natural, direct, and understandable way
> Python allows, while keeping the cognitive load of reading the code, changing
> it, and using the API correctly as low as possible.

Priorities, in order:

1. correctness
2. clarity
3. simplicity
4. maintainability
5. idiomatic Python
6. performance, when it is actually relevant

Do not read "Clean Code" as "add more abstraction". Avoid trivial wrappers,
one-method classes, premature interfaces, unnecessary inheritance, hollow
`Manager` / `Service` / `Factory` / `Provider` layers, abstractions created to
reuse a few lines, splitting functions only to shorten them, and writing plain
Python like enterprise Java.

### Prefer boring Python

Boring is the goal, not an insult. Code is boring when an experienced Python
developer reads it once without stopping to work out which technique it uses. A
construct that is technically Pythonic but needs a second read is not
maintainable Python.

Avoid:

```python
result = {
    key: transformed
    for item in items
    if (value := get_value(item)) is not None
    for key, transformed in [transform(value)]
    if transformed
}
```

Prefer this - control flow and intermediate state stay explicit:

```python
result = {}
for item in items:
    value = get_value(item)
    if value is None:
        continue
    key, transformed = transform(value)
    if transformed:
        result[key] = transformed
```

The same standard rules out excessive chaining, dynamic attribute tricks,
hard-to-read `functools` / `itertools` combinations, and one-liners only the
author finds elegant.

### Prefer the least powerful construct

Use the least powerful construct that clearly solves the problem:

- a plain function over a decorator
- a dataclass or plain class over a metaclass or descriptor
- a mapping, function, or `match` over a strategy hierarchy
- a `for` loop over a comprehension that does too much

Powerful constructs are hard to remove later. Reach for them only when the
simple construct is genuinely insufficient, and be able to say why.

## Workflow

### 1. Inspect before changing

Understand the project before changing it: purpose and entry points, package and
module structure, core execution path, public API and data model, tests,
`pyproject.toml` and dependency declarations, and lint, formatter, type checker,
and CI configuration.

Do not start refactoring from a local glimpse of the code.

### 2. Review for real maintenance value

Look for unnecessary complexity, unnatural data models, mutable or global
state, implicit side effects, overloaded functions, deep nesting, unclear
resource lifetimes, confusing exception handling, hard-to-use public APIs,
tests coupled to implementation details, standard library features reimplemented
by hand, and dead or obsolete code. Prefer deletion and simplification over new
abstraction.

Load **[references/review-checklist.md](references/review-checklist.md)** for
per-area signals and questions.

### 3. Decide whether to change

For every candidate change, ask:

> After the change, does a reader need to understand fewer concepts?

If not, be cautious. Then ask:

> Does the change make the code easier to use correctly, understand, test, or
> maintain?

If you cannot answer clearly, the change is probably stylistic churn.

Do not change code only because another style looks more modern, a syntax is
shorter, a new Python feature is available, you prefer different names, a
further abstraction is possible, two or three lines could be deduplicated, or it
looks prettier even though lint does not require it. When the project already
has a reasonable convention, stay consistent with it.

### 4. Classify the change

Classify each change as a bug fix, behavior-preserving refactor, API change, or
stylistic cleanup.

You MUST NOT mix a behavior change into a change you report as
behavior-preserving. Fix a bug only when you can explain the incorrect behavior
and validate the fix.

### 5. Refactor in small steps

Keep refactors small, local, coherent, behavior-preserving, and easy to review.
Do not redesign the whole project at once unless a real architectural problem
requires it.

### 6. Verify

Run the project's existing tests, linter, formatter, and type checker. Find the
commands in `pyproject.toml`, CI configuration, or `AGENTS.md`. If a tool or
test suite is missing, say so; do not add new dependencies or tooling as part of
a review.

### 7. Re-review the diff

Re-read your own diff before finishing and check whether it:

- adds unnecessary abstraction
- adds indirection
- makes simple code more clever
- breaks the public API
- adds a dependency
- distorts the runtime design to satisfy the type system
- produces large-scale churn with no real benefit

Also ask:

> Without having seen the old code, would this implementation look natural?

> Is there any new code that does not need to exist?

Revert any change whose benefit you cannot state clearly.

### 8. Report

Summarize only high-value content:

- main design problems found
- important improvements actually made
- what was deleted or simplified
- what was deliberately left as-is, and why
- issues worth handling separately later

Do not present dozens of trivial style issues as results.
