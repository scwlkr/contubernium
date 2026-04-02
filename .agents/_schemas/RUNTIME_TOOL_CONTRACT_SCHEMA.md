# RUNTIME_TOOL_CONTRACT Schema

This schema is canonical for every runtime tool entry published in `docs/RUNTIME_TOOL_CONTRACTS.md`.

An entry either passes this schema exactly or it is non-compliant.

## Required Entry Contract

- Each runtime tool entry MUST begin with `## <tool_name>`.
- Sections MUST appear exactly once and in this order:
  1. `## <tool_name>`
  2. `### Contract`
  3. `### Input Schema`
  4. `### Output Schema`
  5. `### Failure Response`

## Section Field Requirements

### `### Contract`

Required fields:
- `- Permission class:` one of `Read`, `Write`, `Execute`
- `- Approval behavior:` how operator approval is derived from runtime policy
- `- Timeout behavior:` `None` or the canonical policy-derived timeout rule

Validation:
- MUST use only canonical permission classes.
- MUST describe approval behavior in terms of published runtime metadata, not hidden branches.

### `### Input Schema`

Required fields:
- One or more bullets in the form `- <field> (<required|optional>, <type>): <description>`

Validation:
- MUST list every accepted request field for the tool.
- MUST mark required vs optional fields explicitly.

### `### Output Schema`

Required fields:
- One or more bullets in the form `- <field> (<type>): <description>`

Validation:
- MUST describe the success shape only.
- Failure details belong in `### Failure Response`.

### `### Failure Response`

Required fields:
- `- Shape:` the canonical failure envelope
- `- Common codes:` representative codes the tool may emit

Validation:
- MUST publish `code`, `cause`, and `context`.
- MUST keep the failure envelope consistent across all tools.

## Canonical Template

```md
## tool_name

### Contract
- Permission class:
- Approval behavior:
- Timeout behavior:

### Input Schema
- field (required, string):

### Output Schema
- field (string):

### Failure Response
- Shape:
- Common codes:
```
