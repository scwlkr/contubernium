# EVALUATE_LOOP

## Purpose

Assess the mission, current state, recent history, and latest result so `decanus` can choose the single next controlled step without surrendering commander-first ownership.

This is the default Decanus action.
When in doubt, return here.

## Strategic Goal

Convert the current mission state into one valid next move.

Not a roadmap.
Not a bundle.
Not a suggestion cloud.

One move.

## When To Use

Use `EVALUATE_LOOP`:

- at the start of a mission
- after any tool result returns
- after any specialist result returns
- after operator input changes scope, approval status, or constraints
- after a blocked condition is cleared
- whenever the next move is not already obvious and bounded

## Required Inputs

The evaluation should reason over:

- mission objective
- current goal
- project context files already loaded
- mission memory
- project memory
- global memory
- live loop state
- recent history
- open blockers
- open approvals
- latest evidence and pending side effects

## Governing Constraints

`EVALUATE_LOOP` must:

- keep commander-first control intact
- route at most one next action
- use known state before expanding context
- avoid specialist-domain implementation inside the control layer
- avoid completion claims without evidence
- prefer narrowing scope over broadening scope

## Evaluation Questions

Before choosing an action, `decanus` should be able to answer:

1. What is the mission asking for right now, not in general?
2. What is already known from state, memory, and recent results?
3. What is still unknown or still risky?
4. What is the smallest move that would reduce uncertainty or advance completion?
5. Who or what should own that move?
6. What evidence should come back after that move?
7. If this move fails, will the system still be legible?

If these cannot be answered, the next action is probably not ready.

## Process

### Step 1: Reconstruct Mission Position

- read the mission objective
- identify the current goal
- note any hard constraints from doctrine, contract, operator instruction, or runtime policy
- note whether the mission is advancing, waiting, or blocked

### Step 2: Assimilate Current Evidence

- inspect recent results and open findings
- inspect current files or state already in hand
- inspect approvals and side-effect boundaries
- separate confirmed evidence from inference

### Step 3: Identify The Next Decision Pressure

Classify the main reason the loop cannot simply finish:

- missing evidence
- missing implementation
- missing review or validation
- missing operator choice
- policy or permission constraint
- unresolved contradiction

The classification should drive the next action.

### Step 4: Reduce To One Next Move

Pick the narrowest move that will materially improve the mission state.

Good next moves:

- request one file read
- request one search
- request one command
- ask one clarifying question
- invoke one specialist on one bounded objective

Bad next moves:

- "continue implementation"
- "investigate the project"
- "improve quality"
- "do frontend and backend updates"

### Step 5: Choose The Decanus Action

Choose exactly one:

- `finish`
- `invoke_specialist`
- `tool_request`
- `ask_user`
- `blocked`

### Step 6: Sanity-Check The Decision

Before returning, confirm:

- the action is valid under the active runtime
- the current goal is explicit
- the reasoning is short and concrete
- no second hidden action is embedded in the explanation
- the next result will return usable evidence

## Action Selection Rules

### Choose `tool_request` when:

- `decanus` needs more evidence
- the runtime requires `decanus` to remain the sole active executor
- the next move is still command-owned and should not be framed as specialist work

### Choose `invoke_specialist` when:

- one specialist clearly owns the next bounded task
- the objective can be completed or blocked visibly
- the runtime lane permits specialist delegation

### Choose `ask_user` when:

- the operator must resolve ambiguity
- approval is required
- key constraints are missing and unsafe to infer

### Choose `finish` when:

- the mission objective is satisfied by actual evidence
- or the mission should end with an explicit final response now

### Choose `blocked` when:

- no safe next step exists
- policy or missing input prevents progress
- the system cannot proceed without an external change

## Output Requirements

Return a `DecanusDecision` JSON object.

The decision should always include:

- `action`
- `reasoning`
- `current_goal`

And then only the fields required by the selected action:

- `tool_requests` for `tool_request`
- `question` for `ask_user`
- `final_response` for `finish`
- `blocked_reason` for `blocked`

## Success Criteria

`EVALUATE_LOOP` is successful when:

- the next step is singular
- ownership of the next step is clear
- the next result will improve the command picture
- the loop remains controlled and resumable

## Failure Modes

- Missing project context: request targeted reads instead of broad exploration
- Unclear blocker: ask the operator explicitly instead of guessing
- Cross-domain next step: tighten scope until a single owner or tool action is clear
- Premature completion pressure: keep the loop open until evidence exists
- Over-reading: use already-loaded memory before requesting more context
- Hidden chaining: remove bundled follow-on work from the decision

## Example Decision Patterns

### Pattern: Need Exact File Evidence

- Current goal: verify whether config already exists
- Correct move: `tool_request` with `read_file`

### Pattern: Need One Specialist-Owned Change

- Current goal: implement one bounded backend contract
- Correct move: `invoke_specialist` targeting `faber`, if the runtime lane permits it

### Pattern: Need Operator Choice

- Current goal: resolve conflicting product direction
- Correct move: `ask_user`

### Pattern: Cannot Safely Proceed

- Current goal: run a prohibited side effect without approval path
- Correct move: `blocked`

## Example

`decanus::EVALUATE_LOOP` after `faber` returns an API implementation summary and `decanus` must decide whether the next correct move is validation, additional evidence gathering, operator escalation, or mission completion.
