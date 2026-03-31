# WIRE_USER_FLOW

## Purpose

- Outcome: implement a bounded client-side interaction flow.
- Scope: handle frontend state, validation, navigation, and event-driven behavior for a specific user journey.

## When to Use

- Use when: the task is primarily about forms, local state, interaction handling, multi-step flow behavior, or route transitions.
- Do not use when: the task is only about visual component structure or only about existing API hookup.

## Inputs

- Required: objective, relevant routes or components, current flow behavior, and constraints on user interaction.
- Optional: acceptance criteria, validation rules, edge cases, or UX notes.

## Constraints

- Must: keep behavior explicit, predictable, and local to the assigned user flow.
- Must not: invent backend contracts or redefine visual identity.
- Escalate when: the required behavior depends on missing product rules or undefined backend responses.

## Process

1. Inspect the current flow, state boundaries, and event handling in the relevant frontend files.
2. Identify the exact interaction path that needs to change.
3. Implement the client-side logic, validation, navigation, and state updates required by that flow.
4. Check success, failure, empty, and edge states that the flow can reach.
5. Return the changed files, findings, blockers, and confidence.

## Output

- Status: `complete`, `partial`, or `blocked`
- Required fields: `summary`, `changes`, `findings`, `blockers`, `confidence`
- Success condition: the requested user flow behaves correctly within frontend ownership and reports any unresolved external dependency.

## Failure Modes

- Undefined business rule: block and surface the missing rule instead of inventing it.
- Flow depends on missing backend response semantics: escalate to `faber`.
- Requested change spans multiple separate flows: return `blocked` and ask `decanus` to split scope.

## Example

- Invocation: `artifex::WIRE_USER_FLOW`
- Usage: implement client-side validation and step transitions for an onboarding form wizard.
