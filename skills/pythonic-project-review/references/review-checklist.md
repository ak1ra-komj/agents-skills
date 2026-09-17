# Pythonic Review Checklist

Per-area signals for the review step of the `pythonic-project-review` skill.

No Python project must satisfy every item below. Treat these as questions that
identify designs worth investigating, not as mechanical rules.

## Cognitive load

Ask first:

- How much state must a reader hold in mind to understand this code?
- How many files must be crossed to understand one simple behavior?
- Is there unnecessary abstraction or indirection?
- Can a concept be deleted instead of added?
- Is the happy path visible at a glance?
- Is the API easy to use correctly?

Lowering cognitive load takes priority over every other concern in this
document.

## Functions

Check:

- does the function have multiple independent responsibilities
- too many parameters
- many boolean flags
- does it mix calculation with unrelated side effects
- does it depend on hidden global state
- deep nesting
- can guard clauses simplify the control flow
- are helpers split too finely
- are generators or context managers used where a straight-line function is
  clearer
- does the name accurately describe the behavior

Do not use line count as the primary reason to split a function.

## Classes

For each important class ask:

> Why is this a class?

Check whether it is only:

- a namespace
- a set of static methods
- a wrapper around a single callable
- stateless
- an interface forced in for dependency injection

Also check:

- is mutable state excessive
- is inheritance necessary
- would composition be more natural
- does the constructor perform I/O or complex business logic
- do properties have surprising side effects
- does it overload operators on a type that is not numeric or collection-like

## Data modeling

Look for:

- dictionary-driven programming
- `dict[str, Any]`
- magic strings and magic numbers
- several related parameters always passed together
- tuples whose field meaning depends on position
- booleans that actually express an enum or state
- nullable fields that force defensive checks everywhere

Consider whether a dataclass, `Enum`, `TypedDict`, `NamedTuple`, `Protocol`, or
an explicit domain type fits better. Do not create meaningless classes for
simple data.

## Types

Check:

- `Any`
- `cast`
- `# type: ignore`
- overly complex generics
- annotations inconsistent with runtime semantics
- public API types that are too wide
- parameters that should accept an abstract collection interface
- unstable return types

Types should express the design, not drive the design to become more complex.

## Control flow

Look for:

- deeply nested `if`
- nested loops
- state variables
- duplicated conditions
- long `if` / `elif` chains
- exception-driven normal flow

Keep the normal path linear.

## Exceptions

Check:

- bare `except`
- `except Exception`
- swallowed exceptions
- catch-log-reraise
- lost exception context
- error messages without context
- exceptions used for ordinary branches
- unnecessary custom exception hierarchies

Follow EAFP, but keep exception boundaries clear.

## Mutability

Check:

- mutable defaults
- shared mutable state
- hidden mutation of arguments
- import-time mutation
- global caches
- singletons
- unclear object lifetimes

Prefer local, explicit state.

## Resource management

Check files, sockets, locks, subprocesses, temporary files, and external
connections. Ask whether their lifetime can be expressed with `with`, a context
manager, `contextlib`, or `ExitStack`.

## Standard library

Check for needless reimplementation of:

- `pathlib`
- `collections`
- `itertools`
- `functools`
- `contextlib`
- `dataclasses`
- `enum`
- `typing`
- `tempfile`
- `subprocess`
- `shlex`
- `json`
- `csv`
- `logging`
- `urllib.parse`
- `datetime`
- `zoneinfo`

Using the standard library still requires the result to be simpler.

## Modules

Check:

- does the module have multiple unrelated responsibilities
- `utils.py` and `helpers.py` catch-alls
- cyclic imports
- import direction
- package boundaries
- private implementation leakage
- `__init__.py` side effects

Do not fragment the codebase into one-file-per-class structures.

## Public API

Check:

- naming
- defaults
- keyword-only parameters
- positional argument ambiguity
- error semantics
- return types
- backward compatibility
- internal representation leakage

The API should be easy to use correctly and difficult to use incorrectly.

## Testing

Check:

- tests coupled to implementation details
- excessive mocks
- fragile fixtures
- duplicated setup
- missing edge cases
- missing failure-path tests
- whether public behavior is genuinely verified

Code that is hard to test is often a design signal.

## Dependencies

Ask:

- is the dependency really needed
- would the standard library be enough
- is it pulled in for a few lines of functionality
- is a runtime dependency misplaced as a dev dependency
- are compatibility workarounds already obsolete

Do not rewrite mature tools to chase zero dependencies.

## Comments and docs

Check:

- comments that merely translate the code
- outdated comments
- obsolete `TODO`s
- inaccurate or trivial docstrings
- missing "why"

Let the code express "what" and comments explain "why".

## Delete candidates

Look for:

- dead code
- unused helpers
- obsolete compatibility layers
- duplicated implementations
- unnecessary wrappers
- unused dependencies
- stale configuration
- abandoned feature flags

Deletion is often the most effective simplification.

## Performance

Handle only clear problems:

- accidental O(n^2)
- repeated I/O
- repeated parsing
- unnecessary materialization
- avoidable large copies
- unnecessary work in a hot path

For anything not evident from the code itself:

> benchmark before optimizing.

Do not perform speculative micro-optimizations.
