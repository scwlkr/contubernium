# IMPLEMENT_INTERFACE

## Purpose

- Outcome: deliver one bounded frontend slice that may include component work, interaction logic, and existing client integration.
- Scope: use this only when the assigned change spans multiple frontend concerns but still belongs to one coherent user-facing slice.

## When to Use

- Use when: the task cannot be cleanly reduced to only component work, only client flow work, or only API wiring.
- Do not use when: a narrower Artifex action fully covers the task.

## Inputs

- Required: objective, relevant frontend files, existing UX constraints, and any backend contracts the interface must respect.
- Optional: screenshots, component references, interaction notes, acceptance details, or design-system references.

## Constraints

- Must: stay within frontend ownership and preserve existing system direction unless instructed otherwise.
- Must not: invent backend behavior, redefine brand direction, or absorb unrelated product scope.
- Escalate when: the task depends on missing backend contracts, unresolved visual authority, or unclear product behavior.

## Process

1. Inspect the relevant interface files, user flow, and existing contract boundaries.
2. Identify the minimum frontend slice required to satisfy the objective.
3. Implement the necessary interface surface, client behavior, and existing API wiring within that slice.
4. Check the result for scope drift, UX regressions, and unresolved dependencies.
5. Return the changed files, findings, blockers, and confidence.

## Output

- Status: `complete`, `partial`, or `blocked`
- Required fields: `summary`, `changes`, `findings`, `blockers`, `confidence`
- Success condition: one coherent frontend slice is implemented without crossing into backend, brand, or mission ownership.

## Failure Modes

- Missing backend contract: block or escalate to `faber` instead of inventing the contract.
- Unresolved visual-system rule: escalate to `signifer` before redefining visual language.
- Scope exceeds one bounded slice: return `blocked` and surface the scope split needed from `decanus`.

## Example

- Invocation: `artifex::IMPLEMENT_INTERFACE`
- Usage: deliver a settings screen update that adds UI states, client validation, and wiring to an already-defined save endpoint.
