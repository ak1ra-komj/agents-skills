<INSTRUCTIONS>
This repository uses English for all Markdown document body text.
If any prior instructions conflict with this, follow this rule for Markdown content.
</INSTRUCTIONS>

## Conventions

- Correctness and clarity take priority over micro-optimizations.
- Keep guidance actionable and scoped to real engineering decisions.
- `description` fields use the form **"Use when [condition]"**
  - This applies to both skill descriptions and reference document descriptions.
- When uncertain, do not guess; instead state "Insufficient information".
- Run `prettier -w` on every modified file before finishing.

## RFC 2119 keywords

Use RFC 2119 keywords (`MUST`, `SHOULD`, `MUST NOT`) selectively - reserve them for
hard constraints where violation produces broken, incorrect, or insecure output.
Overusing them on routine guidance dilutes their signal and causes agents to
ignore genuinely critical rules.

For routine guidance, use plain imperative language ("Run tests with `pytest`",
"Format with `ruff format`").

## Output format

- Plain Markdown only. No HTML unless requested.
- ASCII punctuation only. No emoji, em dashes, or excess bold/italic text.
