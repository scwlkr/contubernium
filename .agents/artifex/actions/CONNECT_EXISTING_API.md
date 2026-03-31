# CONNECT_EXISTING_API

## Purpose

- Outcome: connect frontend behavior to an already-defined backend or API contract.
- Scope: cover client-side request wiring, response handling, and UI state updates tied to existing interfaces.

## When to Use

- Use when: the backend contract already exists and the missing work is the frontend hookup.
- Do not use when: the API contract is undefined, the task is mostly visual, or the task is primarily local interaction flow with no external dependency.

## Inputs

- Required: objective, relevant frontend files, API contract details, payload and response expectations, and error-handling constraints.
- Optional: endpoint examples, request schemas, state diagrams, or acceptance checks.

## Constraints

- Must: honor the existing API contract exactly as provided.
- Must not: invent endpoints, payload shapes, backend semantics, or server-side behavior.
- Escalate when: the contract is missing, contradictory, or incomplete.

## Process

1. Read the relevant frontend code and the existing backend or API contract.
2. Identify the exact request, response, and UI states that must be wired.
3. Implement the client-side integration, including loading, success, and failure handling.
4. Verify that the UI behavior reflects the existing contract without expanding scope.
5. Return the changed files, findings, blockers, and confidence.

## Output

- Status: `complete`, `partial`, or `blocked`
- Required fields: `summary`, `changes`, `findings`, `blockers`, `confidence`
- Success condition: the frontend is wired to the existing contract and surfaces unresolved contract issues instead of guessing.

## Failure Modes

- Missing contract detail: block and escalate to `faber`.
- Response behavior is ambiguous: surface the ambiguity and stop short of inventing semantics.
- Integration requires broader flow redesign: return `blocked` and ask `decanus` to re-scope the task.

## Example

- Invocation: `artifex::CONNECT_EXISTING_API`
- Usage: connect a profile form submit action to an existing update-profile endpoint and reflect loading and error states in the UI.
