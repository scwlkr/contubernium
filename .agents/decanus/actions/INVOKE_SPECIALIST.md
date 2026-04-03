# INVOKE_SPECIALIST

## Purpose

Create a single clear specialist invocation that stays inside the agent hierarchy, obeys the invocation protocol, and returns control cleanly to `decanus`.

`INVOKE_SPECIALIST` is how `decanus` turns command intent into a bounded specialist task without surrendering mission ownership.

## Strategic Goal

Produce a handoff that is:

- singular
- explicit
- domain-correct
- evidence-oriented
- easy to evaluate when it returns

## When To Use

Use `INVOKE_SPECIALIST` only when all of the following are true:

- a bounded task falls fully inside one specialist domain
- the next move has one clear owner
- the objective can be expressed concretely
- the completion signal is visible
- the active runtime lane permits specialist delegation

If any of those are false, do not invoke yet.

## Do Not Use When

Do not use `INVOKE_SPECIALIST` when:

- the task blends multiple domains
- the next move is still ambiguous
- `decanus` first needs more evidence
- the runtime requires `decanus` to remain the sole active executor
- the handoff would contain hidden follow-on tasks

In those cases, use `EVALUATE_LOOP` again and reduce the problem further.

## Required Inputs

- target specialist
- narrow objective
- completion signal
- relevant files only
- dependency list
- explicit constraints
- approvals or side-effect limits
- relevant confirmed memory

## Governing Constraints

`INVOKE_SPECIALIST` must preserve all of the following:

- one specialist only
- one objective only
- no multi-domain scope
- no delegation of command ownership
- no silent chaining to another specialist
- no canonical memory writes unless explicitly permitted

Helper agents must be targeted explicitly by agent name.
Lane fallback is reserved for core specialists.

## Specialist Selection Guide

Use the specialist whose constitutional role actually owns the next step:

- `faber` for backend behavior, APIs, persistence, data models, and server logic
- `artifex` for components, client logic, UI wiring, and user flows
- `architectus` for infra, deployment, environment design, CI/CD, and topology
- `tesserarius` for validation, testing, regression review, and security review
- `explorator` for research, documentation evidence, comparisons, and bounded discovery
- `signifer` for visual system definition and brand-facing design direction
- `praeco` for messaging and operator-facing language outputs
- `calo` for documentation updates and maintenance work
- `mulus` for bounded bulk transformation work

If two specialists seem required at once, the task is still too broad.

## Handoff Construction Standard

The invocation should follow the protocol shape from `docs/invocation-protocol.md`.

That means the handoff should define:

### Objective

- concrete
- narrow
- testable

### Context

- project identifier if relevant
- specific files
- explicit constraints
- dependencies needed for the task

### Scope

- allowed actions
- restricted actions
- explicit ban on mission ownership and specialist chaining

### Memory

- current mission summary
- confirmed project state
- only the relevant memory needed for this task

## Completion Signal Standard

Every invocation must say what "done" means for this scoped task.

Good completion signals:

- implement one named backend endpoint and report changed files
- validate one changed scope and return findings or pass result
- research one library choice and return tradeoffs with recommendation

Bad completion signals:

- improve the architecture
- keep going until it looks done
- fix whatever else you find

## Process

### Step 1: Confirm The Need For Delegation

Ask:

- Is this truly specialist-owned?
- Is the next step already reduced to one bounded objective?
- Would a runtime tool request be more correct in the current lane?

### Step 2: Choose The Specialist

Select the single best domain owner.
Do not route by convenience or agent availability.
Route by constitutional responsibility.

### Step 3: Tighten The Objective

Reduce the task until it has:

- one verb
- one owned scope
- one visible completion condition

### Step 4: Package The Context

Include only:

- the files the specialist actually needs
- the constraints that actually matter
- the dependencies that are relevant
- the memory that helps the specialist avoid re-discovery

### Step 5: State The Return Path

Make it explicit that:

- the specialist returns structured output
- `decanus` will reassess after the result
- no further action is implied beyond the scoped task

## Output Requirements

Return a `DecanusDecision` with `action: "invoke_specialist"`.

The reasoning should make clear:

- why the task is specialist-owned
- why this specialist is the correct owner
- why the scope is narrow enough to preserve command

## Success Criteria

`INVOKE_SPECIALIST` is successful when:

- the specialist gets one clear task
- the specialist has enough context but not excessive scope
- the result can be evaluated cleanly on return
- command ownership remains visibly with `decanus`

## Failure Modes

- Ambiguous scope: tighten the objective
- Cross-domain task: split it before invoking
- Missing completion signal: define one before invoking
- Runtime lane disallows delegation: request runtime tools instead
- Overloaded context: reduce files and constraints to what the specialist actually needs
- Hidden follow-on work: remove it from the invocation

## Example

`architectus::CONFIGURE_SYSTEM` with the objective `set up CI and runtime defaults`, the relevant config files, explicit constraints against application-feature implementation, and a completion signal that requires reported configuration changes and any blockers to return to `decanus`.
