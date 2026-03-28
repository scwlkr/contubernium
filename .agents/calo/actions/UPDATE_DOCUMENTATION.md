# UPDATE_DOCUMENTATION

## Purpose
Update README and operational docs to reflect implemented reality.

## When to Use
- The task is documentation maintenance or canonical written record updates

## Inputs
- Verified implementation changes
- Relevant docs

## Constraints
- Document only verified behavior
- Keep explanations concise and traceable

## Process
1. Read the implemented behavior and current docs.
2. Update only the affected documentation.
3. Return changed files and remaining doc gaps.

## Output
A structured specialist result with documentation artifacts.

## Failure Modes
- Unverified behavior: do not document it
- Scope drift into implementation: stop and return control

## Example
`calo::UPDATE_DOCUMENTATION` after installation behavior changes.
