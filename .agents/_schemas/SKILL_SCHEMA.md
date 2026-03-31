# SKILL Schema

This schema is canonical for every `.agents/<agent>/SKILL.md`.

`SKILL.md` is a router layer. It defines capability coverage and action selection. It does not hold deep execution procedure.

## Required File Contract

- The top-level heading MUST be `# <Agent> Skill`.
- Sections MUST appear exactly once and in this order:
  1. `# <Agent> Skill`
  2. `## Role Summary`
  3. `## Capability Domains`
  4. `## Invocation Forms`
  5. `## Workflow`
  6. `## Action Selection`
  7. `## Output Structure`

## Section Field Requirements

### `## Role Summary`

Required fields:
- `- Owns:` concise statement of the agent-owned lane.
- `- Does not own:` concise statement of excluded scope.

Validation:
- MUST summarize scope, not personality or law.
- MUST stay consistent with `CONTRACT.md`.

### `## Capability Domains`

Required fields:
- One or more bullets in the form `- <domain>: <what this domain covers>`

Validation:
- MUST describe stable domains, not step-by-step procedures.
- MUST map cleanly to one or more actions.

### `## Invocation Forms`

Required fields:
- `- Bare agent call:` how `agent` resolves.
- `- Explicit action call:` how `agent::ACTION_NAME` resolves.
- `- Supported actions:` comma-separated or bulleted list of valid action names.

Validation:
- MUST define a default action for bare-agent resolution.
- MUST list only actions that exist under `actions/`.

### `## Workflow`

Required fields:
- An ordered list beginning at `1.`

Validation:
- MUST describe routing behavior only.
- MUST remain short.
- MUST NOT contain detailed execution mechanics that belong in actions.

### `## Action Selection`

Required fields:
- One or more bullets in the form `- If <condition>: use <ACTION_NAME>`
- One bullet in the form `- If no action fits: <block or escalate rule>`

Validation:
- MUST make action choice explicit.
- MUST cover ambiguity handling.

### `## Output Structure`

Required fields:
- `- Return type:` expected structured result type.
- `- Required fields:` required output fields.
- `- Completion rule:` explicit return-to-`decanus` behavior.

Validation:
- MUST define structured output.
- MUST make handoff back to `decanus` explicit.

## Canonical Template

```md
# <Agent> Skill

## Role Summary
- Owns:
- Does not own:

## Capability Domains
- <domain>:

## Invocation Forms
- Bare agent call:
- Explicit action call:
- Supported actions:

## Workflow
1. Validate that the objective belongs to this agent.
2. Select one action.
3. Load only the selected action.
4. Execute inside contract boundaries.
5. Return a structured result to `decanus`.

## Action Selection
- If <condition>: use <ACTION_NAME>
- If no action fits:

## Output Structure
- Return type:
- Required fields:
- Completion rule:
```

## Prohibited Content

- No SOUL-level identity, tone, or worldview
- No CONTRACT-level law restatement beyond routing boundaries
- No action-level detailed procedures
- No multi-page knowledge dump
- No references to project-local actions or project-local agent overrides

## Pass / Fail Rules

Fail the skill file if any of the following are true:
- the heading order differs from this schema
- a required heading is missing
- a required field label is missing
- the file does not define bare-agent resolution
- the file does not define explicit `agent::ACTION` resolution
- the file embeds detailed procedures that belong in `actions/*.md`
- supported actions listed in the file do not exist
- the return-to-`decanus` rule is absent
