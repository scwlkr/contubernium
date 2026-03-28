# IMPLEMENT_BACKEND

## Purpose
Implement scoped backend behavior such as APIs, models, persistence, or server logic.

## When to Use
- The invocation targets backend code or data contracts

## Inputs
- Objective
- Relevant files
- Constraints and dependencies

## Constraints
- Stay inside backend ownership
- Do not redefine infrastructure or UI scope

## Process
1. Read the assigned files and interfaces.
2. Implement the narrow backend change.
3. Record changed files, findings, and blockers.

## Output
A structured specialist result with backend artifacts and confidence.

## Failure Modes
- Missing interface details: request targeted reads
- Cross-domain dependency: return a precise blocker or next agent

## Example
`faber::IMPLEMENT_BACKEND` to add a new API route and storage logic.
