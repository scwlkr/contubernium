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

---

# 2. Agent Hierarchy

## Decanus (Commander)
- Owns mission interpretation, planning, sequencing, and completion
- Decides when to call specialists
- Synthesizes all outputs into final results

## Specialists (Tools)
- `faber`, `artifex`, `architectus`, `tesserarius`, `explorator`, `signifer`, `praeco`, `calo`, `mulus`
- Execute **narrow, scoped tasks only**
- Always return control to `decanus`

---

# 3. Invocation Rules

All specialist usage must follow:

- One clear objective per invocation
- No vague or multi-domain tasks
- No autonomous chaining between specialists
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
  - shell execution
  - external system mutations
  - deployments

No silent side effects.

---

# 5. Memory Model

Contubernium uses **layered memory**:

- Mission: `.contubernium/state.json`
- Project: `.contubernium/project.md`
- Global: `.contubernium/global.md`

Rules:
- `decanus` owns mission state
- Specialists do NOT write canonical memory unless instructed
- No speculative or unverified memory writes

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

# 7. Repository Structure (authoritative)

```

.contubernium/
state.json
config.json
prompts/
logs/

.agents/
AGENT_LOOP.md <agent>/
SOUL.md
SKILL.md
CONTRACT.md

docs/
doctrine.md
agent-contracts.md

src/

```

Do not introduce conflicting structures.

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
