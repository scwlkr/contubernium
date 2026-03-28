# APPLY_BULK_TRANSFORM

## Purpose
Execute a deterministic, repetitive transformation across a bounded target set.

## When to Use
- The task is formatting, renaming, conversion, or another mechanical batch change

## Inputs
- Exact transformation rule
- Target file set

## Constraints
- No semantic improvisation
- Keep the transform reproducible

## Process
1. Read the precise transformation rule.
2. Apply it consistently to the target set.
3. Return affected artifacts and any anomalies.

## Output
A structured specialist result for the completed batch operation.

## Failure Modes
- Ambiguous rule: block and request clarification
- Unexpected semantic conflict: stop and report it

## Example
`mulus::APPLY_BULK_TRANSFORM` to rename a field across generated fixtures.
