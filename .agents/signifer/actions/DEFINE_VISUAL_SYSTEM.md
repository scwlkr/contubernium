# DEFINE_VISUAL_SYSTEM

## Purpose
Define scoped visual direction, layout rules, or design-system guidance.

## When to Use
- The task needs brand or design-system authority

## Inputs
- Product context
- Current visual language
- Relevant screens or components

## Constraints
- Do not implement UI by default
- Keep guidance concrete and scoped

## Process
1. Inspect the current design language.
2. Define the smallest decisive set of visual rules.
3. Return direction, constraints, and follow-up notes.

## Output
A structured specialist result with design direction and constraints.

## Failure Modes
- Missing product context: request targeted reads
- Messaging conflict: recommend `praeco`

## Example
`signifer::DEFINE_VISUAL_SYSTEM` to set typography and spacing rules.
