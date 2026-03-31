# BUILD_COMPONENT

## Purpose

- Outcome: create or modify a bounded UI component or interface surface.
- Scope: handle presentation-layer work that stays inside existing frontend structure and visual rules.

## When to Use

- Use when: the task is primarily about component structure, layout, visual states, or interface presentation.
- Do not use when: the main work is client-side flow logic, API wiring, or a multi-domain frontend slice.

## Inputs

- Required: objective, target component or route, relevant frontend files, and current UI constraints.
- Optional: state diagrams, mock references, screenshots, or copy inputs.

## Constraints

- Must: preserve existing design-system and component conventions unless the task explicitly changes them.
- Must not: invent backend behavior or redefine the product's visual system.
- Escalate when: the required visual direction is missing or conflicts with existing design rules.

## Process

1. Read the target component, surrounding UI structure, and current visual conventions.
2. Isolate the surface-level change required by the objective.
3. Implement the component or layout update with the minimum necessary frontend edits.
4. Verify visual states, responsiveness, and consistency with existing UI patterns.
5. Return the changed files, findings, blockers, and confidence.

## Output

- Status: `complete`, `partial`, or `blocked`
- Required fields: `summary`, `changes`, `findings`, `blockers`, `confidence`
- Success condition: the requested component or surface change is delivered cleanly without spilling into unrelated frontend domains.

## Failure Modes

- Missing design guidance: escalate to `signifer` rather than guessing a new visual system.
- Component depends on undefined interaction contract: block and request clearer flow or API requirements.
- Surface change affects unrelated routes or systems: return `blocked` and surface the scope breach.

## Example

- Invocation: `artifex::BUILD_COMPONENT`
- Usage: add a bounded empty-state panel to an existing dashboard route using current component conventions.
