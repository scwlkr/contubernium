# ACTION Schema

This schema is canonical for every file in `.agents/<agent>/actions/`.

An action file either passes this schema exactly or it is non-compliant.

## Required File Contract

- The file name MUST be `ACTION_NAME.md`.
- `ACTION_NAME` MUST be uppercase snake case.
- The top-level heading MUST exactly match the file name without `.md`.
- Sections MUST appear exactly once and in this order:
  1. `# ACTION_NAME`
  2. `## Purpose`
  3. `## When to Use`
  4. `## Inputs`
  5. `## Constraints`
  6. `## Process`
  7. `## Output`
  8. `## Failure Modes`
  9. `## Example`

## Section Field Requirements

### `## Purpose`

Required fields:
- `- Outcome:` one sentence describing the concrete result this action produces.
- `- Scope:` one sentence defining the exact boundary of the action.

Validation:
- MUST describe one bounded capability.
- MUST NOT restate the entire agent role.

### `## When to Use`

Required fields:
- `- Use when:` one or more trigger conditions.
- `- Do not use when:` one or more exclusion conditions.

Validation:
- MUST distinguish this action from neighboring actions.
- MUST make it possible for `SKILL.md` to route into this action.

### `## Inputs`

Required fields:
- `- Required:` explicit required inputs.
- `- Optional:` explicit optional inputs or `none`.

Validation:
- MUST name the information the runtime or `decanus` has to provide.
- MUST NOT hide required inputs inside prose paragraphs.

### `## Constraints`

Required fields:
- `- Must:` hard requirements.
- `- Must not:` hard prohibitions.
- `- Escalate when:` conditions that require blocking or handoff.

Validation:
- MUST align with the agent contract.
- MUST state at least one boundary condition.

### `## Process`

Required fields:
- An ordered list beginning at `1.`

Validation:
- MUST contain the execution steps for this action only.
- MUST be procedural and finite.
- MUST NOT reference another action as a delegated step.

### `## Output`

Required fields:
- `- Status:` allowed result states.
- `- Required fields:` required output fields.
- `- Success condition:` what qualifies as completion.

Validation:
- MUST describe structured output, not vague prose.
- MUST align with specialist result expectations.

### `## Failure Modes`

Required fields:
- At least one bullet in the form `- <failure>: <response>`

Validation:
- MUST describe likely failure cases and the required handling.
- MUST include escalation or blocking behavior where relevant.

### `## Example`

Required fields:
- One example invocation in the form `` `agent::ACTION_NAME` ``
- One example objective or usage sentence

Validation:
- MUST match the owning agent and the file name.

## Canonical Template

```md
# ACTION_NAME

## Purpose
- Outcome:
- Scope:

## When to Use
- Use when:
- Do not use when:

## Inputs
- Required:
- Optional:

## Constraints
- Must:
- Must not:
- Escalate when:

## Process
1. 
2. 
3. 

## Output
- Status:
- Required fields:
- Success condition:

## Failure Modes
- Failure: Response

## Example
- Invocation: `agent::ACTION_NAME`
- Usage:
```

## Prohibited Content

- No SOUL-level identity or tone guidance
- No CONTRACT-level law duplication beyond action-local constraints
- No unrelated capabilities
- No hidden steps outside `## Process`
- No empty required fields

## Pass / Fail Rules

Fail the action if any of the following are true:
- the heading order differs from this schema
- a required heading is missing
- a required field label is missing
- the action name is not uppercase snake case
- the file contains multi-capability scope
- `## Process` is replaced by vague guidance instead of steps
- `## Example` does not match the action name
