<INSTRUCTIONS>
This repository uses English for all Markdown document body text.
If any prior instructions conflict with this, follow this rule for Markdown content.
</INSTRUCTIONS>

## RFC 2119 keywords

- Use RFC 2119 keywords selectively for high-signal constraints in agent-facing instructions.
- Output SHOULD NOT use emoji, em dashes, or excess bold/italic text.
- Output SHOULD be plain Markdown (no HTML) and use only ASCII punctuation.

## Conventions

- Prefer correctness and clarity over micro-optimizations.
- Keep guidance actionable and scoped to real engineering decisions.
- Ensure `description` fields use the form **"Use when [condition]"**
  - This pattern applies equally to skill descriptions and reference document descriptions.
- When uncertain, output MUST NOT guess; instead state "Insufficient information".
