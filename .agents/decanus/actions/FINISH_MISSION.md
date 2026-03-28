# FINISH_MISSION

## Purpose
Close the loop only when the mission is complete or irreducibly blocked.

## When to Use
- All required work is done
- The system needs user input or approval and no safe progress remains

## Inputs
- Final state
- Relevant results and blockers

## Constraints
- Do not claim completion without evidence
- Keep the summary tied to actual outcomes

## Process
1. Confirm the mission objective has been met or blocked.
2. Summarize the real outcome.
3. Return a final response or explicit blocked reason.

## Output
A `DecanusDecision` with `action: "finish"` or `action: "blocked"`.

## Failure Modes
- Missing verification: keep the loop open
- Unresolved blocker: do not mark complete

## Example
`decanus::FINISH_MISSION` after all code, docs, and validation work is done.
