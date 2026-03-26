# Contubernium Invocation Protocol

This document defines the universal invocation protocol that sits between `decanus`, the runtime, and every specialist.

It is derived from:

- `AGENTS.md`
- `docs/doctrine.md`
- `docs/agent-contracts.md`

If any implementation conflicts with those files, those files win.

## 1. Invariants

The protocol is valid only when all of these remain true:

- `decanus` is the sole orchestrator.
- Every invocation targets exactly one specialist.
- Every invocation carries exactly one clear objective.
- Specialists do not chain to other specialists.
- All specialist output returns to `decanus`.
- Risky side effects pass through explicit approval gates.
- The runtime stays local-first.
- The primary interface remains OpenTUI.

## 2. Invocation Envelope

Every specialist handoff must be represented as a single invocation object:

```json
{
  "objective": "clear, narrow task",
  "context": {
    "project": "project identifier",
    "files": [],
    "constraints": [],
    "dependencies": []
  },
  "scope": {
    "allowed_actions": [],
    "restricted_actions": []
  },
  "memory": {
    "mission": "current mission summary",
    "project": "confirmed project state",
    "relevant": []
  }
}
```

Rules:

- `objective` must be concrete and testable.
- `context.files` should stay narrow; do not hand a specialist the whole repository unless that is the actual task.
- `scope.allowed_actions` must be explicit.
- `scope.restricted_actions` must explicitly forbid specialist chaining, mission ownership, and canonical memory writes.
- `memory` carries confirmed state only.

## 3. Result Envelope

Every specialist completion or block returns a single invocation result:

```json
{
  "status": "complete | partial | blocked",
  "summary": "what was done",
  "changes": [],
  "findings": [],
  "blockers": [],
  "next_recommended_agent": "optional",
  "confidence": 0.0
}
```

Rules:

- `status=complete` means the scoped objective is satisfied.
- `status=partial` means progress was made but `decanus` must decide the next step.
- `status=blocked` means the specialist cannot proceed without approval, user input, or another runtime action.
- `blockers` must be explicit. No silent failure.
- `next_recommended_agent` is advisory only. It does not transfer control.

## 4. Approval Gates

Approval is not implicit. The runtime must materialize an approval request before any risky action:

- shell execution
- workspace writes outside already-approved flow
- destructive change
- external mutation
- deployment

Approval request lifecycle:

1. Runtime creates `ApprovalRequest(status=pending)`.
2. Runtime exposes intent in OpenTUI.
3. Operator approves or denies.
4. Runtime records `approved` or `denied`.
5. `decanus` continues only after the result is known.

## 5. Loop Lifecycle

The loop is modeled as explicit steps:

1. `think`
2. `invoke`
3. `wait_for_approval`
4. `execute`
5. `result`
6. `finish`
7. `blocked`

State transitions:

- Mission start: `decanus` enters `think`.
- Specialist handoff: runtime records `invoke` and sets the active invocation.
- Approval required: runtime records `wait_for_approval`.
- Specialist execution: runtime records `execute`.
- Specialist return: runtime records `result` and restores `current_actor=decanus`.
- Mission completion: runtime records `finish`.
- Any unresolved stop: runtime records `blocked`.

## 6. Runtime Mapping

The Zig runtime maps this protocol to typed structures:

- `Mission`
- `Invocation`
- `InvocationResult`
- `ApprovalRequest`
- `LoopStep`
- `StateSnapshot`

Supporting enums cover:

- actor identity
- lane identity
- mission/global status
- loop status
- runtime status
- task status
- invocation status
- approval kind and approval status
- invocation result status
- loop step kind

## 7. Non-Goals

This protocol does not allow:

- peer-to-peer specialist collaboration
- hidden side effects
- vague, multi-domain invocations
- specialists deciding mission completion
- cloud dependency for core loop behavior
