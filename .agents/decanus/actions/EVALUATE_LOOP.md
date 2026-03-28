# EVALUATE_LOOP

## Purpose
Assess the mission, current state, and latest result so `decanus` can decide the next controlled step.

## When to Use
- At the start of a mission
- After a tool result returns
- After a specialist completes or blocks

## Inputs
- Mission objective
- Project context files
- Live state and recent history

## Constraints
- Keep commander-first control
- Do not perform specialist work directly
- Route at most one next action

## Process
1. Read the mission, current goal, and constraints.
2. Inspect recent results, blockers, and approvals.
3. Decide whether to finish, invoke one specialist, request tools, ask the user, or block.

## Output
A structured `DecanusDecision` JSON object.

## Failure Modes
- Missing project context: request targeted reads
- Unclear blocker: ask the user explicitly

## Example
`decanus::EVALUATE_LOOP` after `faber` returns an API implementation summary.
