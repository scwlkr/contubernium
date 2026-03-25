# Universal Invocation Protocol Implementation v1

## Goal

This protocol standardizes how:

* `decanus` invokes specialists
* specialists return results
* approvals are requested
* mission state is updated
* the loop advances or stops

It should be treated as the **runtime contract** between:

* TUI
* loop engine
* state manager
* agent adapters
* approval system

---

# 1. Core principles

## One invocation = one scoped action

Every invocation must represent a single, clearly bounded unit of work.

Not:

* “work on the app”
* “improve everything”

Yes:

* “analyze local repo structure and summarize system architecture”
* “design deployment options for local-first Zig runtime”
* “write backend API handler for X”

## Decanus is the only scheduler

In v1:

* only `decanus` creates specialist invocations
* specialists never invoke each other directly
* all returns go back to `decanus`

## Every invocation must terminate in one of three states

* `complete`
* `partial`
* `blocked`

No silent hanging state.

---

# 2. Runtime objects

There are 6 core objects in the protocol:

1. **Mission**
2. **Invocation**
3. **Result**
4. **ApprovalRequest**
5. **LoopStep**
6. **StateSnapshot**

---

# 3. Mission object

The mission is the top-level unit of work.

```json
{
  "mission_id": "msn_20260325_001",
  "title": "Define Contubernium doctrine and contracts",
  "user_prompt": "Define the universal invocation protocol implementation",
  "status": "active",
  "created_at": "2026-03-25T14:00:00Z",
  "updated_at": "2026-03-25T14:03:00Z",
  "current_actor": "decanus",
  "loop_iteration": 4,
  "active_invocation_id": "inv_004",
  "final_response": null
}
```

## Fields

* `mission_id`: unique mission identifier
* `title`: short mission label
* `user_prompt`: original user request
* `status`: `active | awaiting_approval | blocked | complete | interrupted`
* `created_at`, `updated_at`: timestamps
* `current_actor`: active agent
* `loop_iteration`: current loop count
* `active_invocation_id`: current invocation if any
* `final_response`: final output once complete

---

# 4. Invocation object

This is the heart of the system.

Every agent action should be represented as an invocation object.

```json
{
  "invocation_id": "inv_004",
  "mission_id": "msn_20260325_001",
  "parent_invocation_id": null,
  "issued_by": "decanus",
  "target_agent": "explorator",
  "objective": "Analyze the current project files and summarize the system architecture",
  "context": {
    "project_root": "/Users/shane/projects/contubernium",
    "relevant_files": [
      "AGENTS.md",
      "docs/doctrine.md",
      "docs/agent-contracts.md"
    ],
    "constraints": [
      "Do not modify files",
      "Focus on current repo reality, not aspiration"
    ],
    "dependencies": []
  },
  "scope": {
    "read_allowed": true,
    "write_allowed": false,
    "shell_allowed": false,
    "network_allowed": false,
    "memory_write_allowed": false
  },
  "status": "active",
  "created_at": "2026-03-25T14:02:00Z",
  "updated_at": "2026-03-25T14:02:30Z"
}
```

## Required fields

* `invocation_id`
* `mission_id`
* `issued_by`
* `target_agent`
* `objective`
* `context`
* `scope`
* `status`

## Status values

* `pending`
* `active`
* `awaiting_approval`
* `complete`
* `partial`
* `blocked`
* `cancelled`

---

# 5. Result object

Every specialist must return a result object in a predictable shape.

```json
{
  "invocation_id": "inv_004",
  "agent": "explorator",
  "status": "complete",
  "summary": "Analyzed the repository doctrine files and identified the current command hierarchy and missing runtime protocol layer.",
  "changes": [],
  "findings": [
    "AGENTS.md defines strict commander-first control",
    "doctrine.md defines philosophy and non-goals",
    "agent-contracts.md defines role boundaries",
    "No canonical invocation protocol implementation exists yet"
  ],
  "artifacts": [],
  "blockers": [],
  "recommended_next_action": "Have decanus define the universal invocation protocol and state schema",
  "recommended_next_agent": "decanus",
  "confidence": 0.94,
  "completed_at": "2026-03-25T14:03:10Z"
}
```

## Result rules

* `summary` should be short and concrete
* `changes` lists files or systems changed
* `findings` lists important outputs
* `blockers` only if relevant
* `recommended_next_agent` is optional guidance, not a direct call
* `confidence` is 0.0–1.0

---

# 6. ApprovalRequest object

Any guarded action must go through this object.

```json
{
  "approval_id": "apr_002",
  "mission_id": "msn_20260325_001",
  "invocation_id": "inv_005",
  "requested_by": "architectus",
  "action_type": "shell",
  "reason": "Need to run zig build test to validate runtime integrity after protocol refactor",
  "command": "zig build test",
  "risk_level": "medium",
  "status": "pending",
  "created_at": "2026-03-25T14:10:00Z",
  "resolved_at": null
}
```

## Action types

* `shell`
* `destructive_edit`
* `external_api_mutation`
* `deployment`
* `credential_access`

## Approval status

* `pending`
* `approved`
* `denied`
* `expired`

## Approval rule

The runtime must not execute guarded actions until approval status is `approved`.

---

# 7. LoopStep object

Each loop iteration should be logged as a discrete step.

```json
{
  "step_id": "step_006",
  "mission_id": "msn_20260325_001",
  "iteration": 6,
  "actor": "decanus",
  "action_type": "invoke_agent",
  "invocation_id": "inv_006",
  "notes": "Delegated protocol state schema design to decanus internal planning layer",
  "timestamp": "2026-03-25T14:12:00Z"
}
```

## Action types

* `mission_started`
* `think`
* `invoke_agent`
* `receive_result`
* `request_approval`
* `approval_resolved`
* `memory_write`
* `mission_completed`
* `mission_blocked`
* `mission_interrupted`

This gives you replayability and debuggability.

---

# 8. StateSnapshot object

This is the canonical runtime state stored in `.contubernium/state.json`.

```json
{
  "version": "1.0",
  "project_name": "contubernium",
  "global_status": "active",
  "current_actor": "decanus",
  "mission": {
    "mission_id": "msn_20260325_001",
    "title": "Define universal invocation protocol",
    "user_prompt": "Define the universal invocation protocol implementation",
    "status": "active",
    "created_at": "2026-03-25T14:00:00Z",
    "updated_at": "2026-03-25T14:15:00Z",
    "loop_iteration": 6,
    "active_invocation_id": "inv_006",
    "final_response": null
  },
  "runtime_session": {
    "provider": "ollama",
    "model": "llama3.1",
    "endpoint": "http://localhost:11434",
    "approval_mode": "interactive",
    "last_error": null
  },
  "invocations": [
    {
      "invocation_id": "inv_004",
      "mission_id": "msn_20260325_001",
      "issued_by": "decanus",
      "target_agent": "explorator",
      "objective": "Analyze project files and summarize architecture",
      "status": "complete"
    }
  ],
  "results": [
    {
      "invocation_id": "inv_004",
      "agent": "explorator",
      "status": "complete",
      "summary": "Architecture summary returned"
    }
  ],
  "approvals": [],
  "loop_history": [
    {
      "step_id": "step_001",
      "iteration": 1,
      "actor": "decanus",
      "action_type": "mission_started",
      "timestamp": "2026-03-25T14:00:00Z"
    }
  ]
}
```

---

# 9. Recommended `.contubernium/state.json` structure

Use this top-level structure:

```json
{
  "version": "1.0",
  "project_name": "",
  "global_status": "",
  "current_actor": "",
  "mission": {},
  "runtime_session": {},
  "invocations": [],
  "results": [],
  "approvals": [],
  "loop_history": []
}
```

## Why this shape works

It is:

* easy to serialize in Zig
* easy to inspect in raw JSON
* easy to replay/debug
* flexible enough for future adapters

---

# 10. Loop engine behavior

This is the actual runtime flow.

## Step 1: Mission start

When the user submits a task:

* create `mission`
* append `mission_started` loop step
* set `current_actor = decanus`

## Step 2: Decanus think phase

Decanus evaluates:

* can I answer directly?
* do I need a specialist?
* do I need approval?
* am I blocked?

This phase should produce exactly one of:

* direct completion
* specialist invocation
* approval request
* blocked state

## Step 3: Specialist invocation

If needed:

* create `invocation`
* append `invoke_agent`
* set `current_actor = target_agent`
* execute agent

## Step 4: Specialist returns result

* store `result`
* append `receive_result`
* set `current_actor = decanus`

## Step 5: Decanus evaluates result

Decanus either:

* completes mission
* issues next invocation
* requests approval
* marks blocked

## Step 6: Repeat until terminal state

---

# 11. Terminal states

A mission may end as:

## `complete`

Mission is fulfilled and `final_response` is written

## `blocked`

Progress cannot continue without missing information or contradiction

## `awaiting_approval`

Runtime is paused pending approval response

## `interrupted`

User or runtime interrupted execution

These must be explicit in state.

---

# 12. Approval flow implementation

## Guarded actions

The runtime should detect guarded actions before execution.

Examples:

* shell command execution
* recursive file edits
* deletion/overwrite of many files
* API POST/PUT/PATCH/DELETE
* deployment changes

## Flow

1. agent/decanus declares intent
2. runtime creates `ApprovalRequest`
3. mission status becomes `awaiting_approval`
4. TUI prompts user
5. user approves or denies
6. approval is recorded
7. loop resumes or returns blocked/partial

## TUI example

```text
APPROVAL REQUIRED
Agent: architectus
Action: shell
Command: zig build test
Reason: validate runtime after changes

Approve? [y/n]:
```

---

# 13. Input schema recommendation for Zig structs

You should implement these as strongly typed structs.

Recommended core structs:

* `Mission`
* `Invocation`
* `InvocationContext`
* `InvocationScope`
* `InvocationResult`
* `ApprovalRequest`
* `LoopStep`
* `RuntimeSession`
* `StateSnapshot`

## Minimal enum set

### `AgentName`

* `decanus`
* `faber`
* `artifex`
* `architectus`
* `tesserarius`
* `explorator`
* `signifer`
* `praeco`
* `calo`
* `mulus`

### `MissionStatus`

* `active`
* `awaiting_approval`
* `blocked`
* `complete`
* `interrupted`

### `InvocationStatus`

* `pending`
* `active`
* `awaiting_approval`
* `complete`
* `partial`
* `blocked`
* `cancelled`

### `ApprovalStatus`

* `pending`
* `approved`
* `denied`
* `expired`

### `LoopActionType`

* `mission_started`
* `think`
* `invoke_agent`
* `receive_result`
* `request_approval`
* `approval_resolved`
* `memory_write`
* `mission_completed`
* `mission_blocked`
* `mission_interrupted`

---

# 14. Specialist output normalization

Even if an underlying model returns messy text, the runtime should normalize it into the result schema.

That means:

* parse model response
* extract structured fields
* fill missing fields with sane defaults
* reject invalid outputs if necessary

## Good fallback defaults

* `changes: []`
* `findings: []`
* `blockers: []`
* `recommended_next_agent: null`
* `confidence: 0.5`

This matters a lot because model outputs will not always be clean.

---

# 15. Error handling rules

## Invalid agent result

If a specialist returns invalid structure:

* mark invocation `blocked` or `partial`
* append error to runtime session / loop history
* return control to `decanus`

## Missing required fields

Use runtime defaults where safe, otherwise block.

## Unknown target agent

Reject invocation before execution.

## Approval denied

Mark invocation as `blocked` or `partial`, depending on whether alternate path exists.

---

# 16. Memory write protocol

Memory writes should be explicit events, not side effects.

## Rule

Any write to:

* mission memory
* project memory
* global memory

should produce a `memory_write` loop step.

## Canonical authority

* `decanus` approves canonical writes
* `calo` may assist in writing docs/memory artifacts
* specialists may propose memory updates, not commit them automatically

---

# 17. v1 simplifications

Do not add these yet:

* specialist-to-specialist chaining
* parallel invocations
* speculative branching
* agent voting/debate
* hidden background daemons making autonomous decisions
* multiple active invocations at once

Keep v1 single-threaded in logic, even if the UI uses worker threads.

That simplicity is a strength.

---

# 18. Recommended file additions

To support this protocol, add:

```text
docs/
  invocation-protocol.md

.contubernium/
  state.json
  project.md
  global.md
  logs/
```

You can also split protocol docs later into:

* schema
* state lifecycle
* approvals
* adapter behavior

But one file is enough for now.

---

# 19. Best implementation order

Codex should implement this in this order:

1. define Zig enums and structs
2. define JSON serialization/deserialization
3. define state manager read/write helpers
4. define mission start flow
5. define invocation creation flow
6. define result ingestion flow
7. define approval request/resolution flow
8. wire loop history logging
9. connect TUI rendering
10. update docs and README

That order will reduce breakage.

---

# 20. Final principle

The protocol should make the system feel like this:

* **predictable**
* **inspectable**
* **recoverable**
* **disciplined**

If a user opens `.contubernium/state.json`, they should be able to understand exactly:

* what the mission is
* who is acting
* what happened
* what is blocked
* what comes next

That is the standard.