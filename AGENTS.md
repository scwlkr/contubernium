# AGENTS.md — Contubernium Operating Law

This file defines the **non-negotiable rules** for how Contubernium operates.  
All implementations must follow this.

---

# 1. Core Model

Contubernium is a **commander-first execution system**.

- `decanus` is the sole orchestrator
- All other agents are **specialist tools**
- Work follows a loop:

Think → Tool → Result → Think → Finish

At no point should control leave `decanus`.

Specialists may execute published runtime tools inside a bounded subordinate sub-loop when `decanus` has already assigned the objective.
That subordinate loop never grants mission ownership, specialist chaining, or autonomous orchestration.

---

# 2. Agent Hierarchy

## Decanus (Commander)
- Owns mission interpretation, planning, sequencing, and completion
- Decides when to call specialists
- Synthesizes all outputs into final results

## Specialists and Helpers (Tools)
- The constitutional core target is 8 total agents including `decanus`
- All non-`decanus` agents remain specialist tools
- If the installed asset set contains more than 7 non-`decanus` agents during alignment, the extra agents are helper agents
- Helper agents never orchestrate, never own the mission, and always return control to `decanus`

Current installed specialist assets in this repository:
- `faber`, `artifex`, `architectus`, `tesserarius`, `explorator`, `signifer`, `praeco`, `calo`, `mulus`

---

# 3. Invocation Rules

All specialist usage must follow:

- One clear objective per invocation
- No vague or multi-domain tasks
- No autonomous chaining between specialists
- Runtime tool usage only within the assigned scope and published tool contracts
- All results return to `decanus`

Bad:
> “improve the project”

Good:
> “design backend API structure for X using Y constraints”

---

# 4. Execution Boundaries

The system MAY:
- read project files
- write/edit code
- run shell commands
- use external APIs

The system MUST:
- require approval for:
  - destructive changes
  - external system mutations
  - deployments
  - guarded shell execution unless the active session is in explicit operator-consented approval-bypass mode
  - guarded workspace writes unless the active session is in explicit operator-consented approval-bypass mode
- keep approval-bypass state explicit, session-scoped, reversible, and off by default

No silent side effects.

---

# 5. Memory Model

Contubernium uses **layered memory**:

- Mission: `.contubernium/state.json` plus per-run traces in `.contubernium/logs/`
- Project: `.contubernium/ARCHITECTURE.md`, `.contubernium/PLAN.md`, `.contubernium/PROJECT_CONTEXT.md`, and `.contubernium/project.md`
- Global: the current runtime-loaded constitutional global layer at `.contubernium/global.md`

Rules:
- `decanus` owns mission state
- Specialists do NOT write canonical memory unless instructed
- No speculative or unverified memory writes

Installed home assets under `~/.contubernium/` provide global agent, shared, adapter, and template files. They are not the canonical project-memory layout created by `contubernium init`.

---

# 6. Agent Design Rules

Each agent MUST:
- have a clear purpose
- operate within a strict domain
- accept structured input
- return structured output

Agents MUST NOT:
- behave as general assistants
- expand scope without instruction
- override `decanus`

---

# 7. Repository And Runtime Layout (authoritative)

```

Source repository:

.agents/
AGENT_LOOP.md <agent>/
SOUL.md
SKILL.md
CONTRACT.md

shared/
adapters/
templates/

docs/
doctrine.md
agent-contracts.md

src/

Installed global home:

~/.contubernium/
agents/
shared/
adapters/
templates/
global.md

Initialized project:

.contubernium/
state.json
config.json
ARCHITECTURE.md
PLAN.md
PROJECT_CONTEXT.md
project.md
global.md
logs/

```

Do not introduce conflicting structures. Project-local `.agents/` and `.contubernium/prompts/` are legacy assumptions, not the canonical initialized-project layout.

---

# 8. Runtime Principles

- Local-first execution (Ollama primary)
- OpenAI-compatible adapters allowed
- No cloud dependency required for core operation
- Zig runtime is authoritative

---

# 9. Interface Scope

Primary interface:
- OpenTUI terminal interface

Other interfaces (Telegram, etc.) are adapters and must not redefine core behavior.

---

# 10. Implementation Discipline

When making changes:

1. Read:
   - `AGENTS.md`
   - `docs/doctrine.md`
   - `docs/agent-contracts.md`
   - `USER_MANUAL.md` when shipped behavior changes

2. Before editing:
   - identify conflicts with current repo
   - list intended changes

3. Prefer:
   - minimal, clean, composable changes
   - explicit structure over implicit behavior

4. Do NOT:
   - introduce hidden logic
   - bypass the agent loop model
   - merge agent responsibilities

---

# 11. Non-Goals

Contubernium is NOT:
- a general chatbot
- a UI-first product
- a loosely defined agent swarm
- an unstructured automation tool

---

# 12. Priority Order

When tradeoffs occur, prioritize:

1. Commander-first control (decanus)
2. Clear agent boundaries
3. Loop integrity
4. Local-first execution
5. Simplicity over feature creep

---

# 13. Source of Truth

If conflicts exist:

AGENTS.md → doctrine.md → agent-contracts.md → implementation

---

# 14. Enforcement

If a change violates this file:
- stop
- surface the violation
- do not proceed silently
