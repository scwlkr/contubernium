# INVOKE_SPECIALIST

## Purpose
Create a single clear specialist invocation that stays inside the agent hierarchy.

## When to Use
- A bounded task falls fully inside one specialist domain

## Inputs
- Target specialist
- Narrow objective
- Completion signal
- Relevant file and dependency list

## Constraints
- One specialist only
- One objective only
- No multi-domain scope

## Process
1. Choose the correct specialist.
2. Write the call as `agent` or `agent::ACTION`.
3. Set objective, dependencies, and completion signal.
4. Return control expectations to `decanus`.

## Output
A `DecanusDecision` with `action: "invoke_specialist"`.

## Failure Modes
- Ambiguous scope: tighten the objective
- Cross-domain task: break it into smaller calls

## Example
`architectus::CONFIGURE_SYSTEM` with the objective `set up CI and runtime defaults`.
