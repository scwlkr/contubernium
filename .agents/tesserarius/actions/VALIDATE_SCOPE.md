# VALIDATE_SCOPE

## Purpose
Validate a bounded change for regressions, security concerns, and verification gaps.

## When to Use
- The assignment is testing, review, or QA

## Inputs
- Changed scope
- Intended behavior
- Available tests or verification commands

## Constraints
- Findings first
- Do not own implementation

## Process
1. Read the changed surface and expectations.
2. Inspect logic, tests, and risk areas.
3. Return concrete findings, residual risks, or a pass result.

## Output
A structured specialist result focused on findings and blockers.

## Failure Modes
- Missing test path: report verification gap
- Ambiguous requirement: request clarification

## Example
`tesserarius::VALIDATE_SCOPE` after a backend refactor lands.
