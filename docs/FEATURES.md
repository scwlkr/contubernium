> Historical planning note:
> This document predates the global-agent architecture in `docs/AGENT_ARCHITECTURE.md`.
> Where it describes project-local prompt assets or copied local agent definitions, the current implementation uses global agents plus project-local context files instead.

🏛️ CONTUBERNIUM — FEATURES (v2, build-ready)

0. System Philosophy (lock this first)
	•	Decanus owns execution loop and final decisions
	•	Agents are stateless workers with contracts
	•	Memory is external, structured, and queryable
	•	Tools are strictly mediated (no direct execution)
	•	Everything is observable (logs > magic)

⸻

1. Core Engine (Zig) ⚙️

Owner: Runtime
Priority: P0 (must exist first)

Responsibilities
	•	Agent loop execution
	•	Tool request routing
	•	State lifecycle management
	•	Approval gating

Subsystems

1.1 Agent Loop

User Input
  ↓
Decanus (think)
  ↓
Decision:
  → respond
  → call tool
  ↓
Tool Execution
  ↓
Return → Decanus
  ↓
Repeat until complete

1.2 Tool Execution System
	•	Typed tool registry
	•	Sandboxed execution
	•	Input/output validation
	•	Timeout + failure handling

1.3 State Manager
	•	Tracks:
	•	active mission
	•	current actor
	•	tool history
	•	intermediate results
	•	Stored in:

.contubernium/state.json



1.4 Approval System
	•	Required before:
	•	file writes
	•	destructive actions
	•	external calls
	•	Modes:
	•	strict
	•	relaxed
	•	auto (future)

⸻

2. Agent Layer 🧠

Owner: Design System
Priority: P1

Structure

.agents/{agent_name}/
  SOUL.md
  CONTRACT.md
  SKILL.md

Components

2.1 SOUL.md
Defines:
	•	personality
	•	reasoning style
	•	priorities
	•	tone constraints

👉 This is behavioral bias, not capability

2.2 CONTRACT.md
Defines:
	•	allowed actions
	•	forbidden actions
	•	tool access scope
	•	expected outputs

👉 This is hard boundaries

2.3 SKILL.md
	•	One scoped execution guide per agent
	•	Encodes the narrow callable behavior `decanus` can invoke
	•	Keeps the agent folder self-contained

👉 `SKILL.md` is the canonical v2 shape. A future `SKILLS/` subtree can exist as an expansion inside the same agent folder, but it is not the base structure.

⸻

3. Memory System 🧱

Owner: Persistence Layer
Priority: P0

Structure

.contubernium/
  state.json
  project.md
  global.md
  config.json
  prompts/
  logs/

Components

3.1 state.json (volatile)
	•	Current mission
	•	Active agent
	•	Loop state
	•	Tool history

3.2 project.md (semi-static)
	•	Architecture decisions
	•	Known constraints
	•	Project-specific knowledge

3.3 global.md (shared intelligence)
	•	Patterns learned across projects
	•	Reusable strategies

3.4 logs/ (critical)
	•	Structured logs (NOT plain text dumps)
	•	Each run = traceable session

Example:

logs/
  2026-03-25-run-01.json


⸻

4. Installation System 🛠️

Owner: Distribution Layer
Priority: P1

Behavior

4.1 Global Install
Installs to:

~/.contubernium/

Contains:
	•	base agents
	•	default prompts
	•	default templates
	•	global memory

4.2 Project Initialization
Command:

contubernium init

Creates:

.contubernium/
  state.json
  project.md
  global.md
  config.json
  prompts/
  logs/

.agents/
  AGENT_LOOP.md
  {agent_name}/
    SOUL.md
    CONTRACT.md
    SKILL.md


⸻

5. Zig + OpenTUI Runtime CLI 🖥️

Owner: Interface Layer
Priority: P2 (after engine works)

Responsibilities
	•	Display agent loop in real time
	•	Show:
	•	current actor
	•	reasoning step
	•	tool calls
	•	outputs
	•	Accept:
	•	user input
	•	approvals

Views

5.1 Main View
	•	Active mission
	•	Current agent
	•	Step-by-step loop

5.2 Tool View
	•	Tool input/output
	•	Execution status

5.3 Logs View
	•	Scrollable run history

⸻

6. Logging System 📜

Owner: Observability
Priority: P0 (do NOT delay this)

Requirements
	•	Every step is logged
	•	Structured JSON (not strings)

Log Event Example

{
  "timestamp": "...",
  "actor": "decanus",
  "action": "tool_request",
  "tool": "read_file",
  "input": "...",
  "output": "...",
  "status": "success"
}

Capabilities
	•	Copy logs easily
	•	Replay runs (future)
	•	Debug failures

⸻

7. Error System 🚨

Owner: Reliability
Priority: P0

Requirements
	•	Every failure returns:
	•	error_code
	•	message
	•	context

Example:

{
  "error_code": "TOOL_TIMEOUT",
  "message": "Tool execution exceeded 5s",
  "context": { "tool": "read_file" }
}


⸻

8. Tooling System 🔧

Owner: Execution Layer
Priority: P0

Rules
	•	Tools are pure interfaces
	•	No agent directly executes logic
	•	Everything goes through tool layer

Types
	•	file tools
	•	system tools
	•	project tools

⸻

🚨 What You Were Missing (Critical)

You originally lacked:

1. Priority order

Without this → you’ll build random pieces and stall

2. Ownership boundaries

Without this → everything becomes spaghetti

3. Logging + errors as first-class systems

Without this → you will NOT be able to debug your agent loop

4. Definition of “what good looks like”

Now each section has constraints you can code against

⸻

🧭 Build Order (Do this exactly)
	1.	Logging system
	2.	Error system
	3.	State manager
	4.	Basic agent loop (no agents yet)
	5.	Tool execution layer
	6.	Single agent (Decanus only)
	7.	Memory system hookup
	8.	Then OpenTUI

If you don’t follow this order, you will get stuck.
