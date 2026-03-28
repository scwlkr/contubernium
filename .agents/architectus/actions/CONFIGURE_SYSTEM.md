# CONFIGURE_SYSTEM

## Purpose
Implement or adjust runtime, CI, environment, or installation mechanics.

## When to Use
- The task concerns infrastructure, scripts, deployment paths, or environment setup

## Inputs
- Objective
- Runtime constraints
- Relevant config or script files

## Constraints
- Keep behavior explicit
- Avoid hidden side effects
- Preserve local-first execution

## Process
1. Inspect the current system topology.
2. Modify the required runtime or automation surface.
3. Record operator-facing assumptions and blockers.

## Output
A structured systems result with changed artifacts and risks.

## Failure Modes
- Unsafe mutation requires approval
- Missing environment detail blocks completion

## Example
`architectus::CONFIGURE_SYSTEM` to add CI validation and installer sync logic.
