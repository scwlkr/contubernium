# 🏛️ CONTUBERNIUM — AGENT ARCHITECTURE

## 1. Purpose

This document defines the **structure, behavior, and composition rules** for all agents within Contubernium.

Contubernium is a **commander-led execution system**.

Agents are:
- persistent
- global
- specialized
- composable

Projects are:
- contextual
- local
- non-authoritative over agent identity

---

## 2. Core Doctrine

> An agent is not a prompt.  
> An agent is a structured capability system.

Each agent is composed of four layers:

1. **SOUL** → identity, personality, decision style  
2. **CONTRACT** → rules, boundaries, guarantees  
3. **SKILL** → capability map and execution logic  
4. **ACTIONS** → granular execution units  

---

## 3. Global vs Project Boundary

### 3.1 Global (System-Level)

All agent definitions live in the Contubernium home directory.

```txt
~/.contubernium/
  agents/
    AGENT_ARCHITECTURE.md
    AGENT_COMPATIBILITY.md

    _schemas/
      SOUL_SCHEMA.md
      CONTRACT_SCHEMA.md
      SKILL_SCHEMA.md
      ACTION_SCHEMA.md

    decanus/
      SOUL.md
      CONTRACT.md
      SKILL.md
      actions/

    architectus/
      SOUL.md
      CONTRACT.md
      SKILL.md
      actions/

    artifex/
      SOUL.md
      CONTRACT.md
      SKILL.md
      actions/

    calo/
      SOUL.md
      CONTRACT.md
      SKILL.md
      actions/

  shared/
    patterns/
    templates/

  adapters/
    claude-code.md
    codex.md
    gemini-cli.md
    antigravity.md
````

### 3.2 Project (Local Context Only)

Projects do **NOT** define or override agents.

Projects provide **context for agents to act within**.

```txt
project-root/
  .contubernium/
    ARCHITECTURE.md
    PLAN.md
    PROJECT_CONTEXT.md

    state.json
    logs/
```

---

## 4. Non-Negotiable Rules

### 4.1 Agents are Global

* Agents MUST NOT be duplicated per project
* Agents MUST NOT be modified by project files
* All agent evolution happens in the global system

### 4.2 Actions are Global

* All actions belong to global agents
* Project-specific actions are NOT allowed
* If a new capability is needed:

  * either encode it in project context
  * or promote it to a global action

### 4.3 Projects Contain Truth, Not Behavior

Projects define:

* architecture
* goals
* constraints
* execution plan

Projects do NOT define:

* agent identity
* agent capabilities
* execution logic

---

## 5. Agent File Structure

Each agent MUST follow this structure:

```txt
agent-name/
  SOUL.md
  CONTRACT.md
  SKILL.md
  actions/
    ACTION_NAME.md
```

---

## 6. File Responsibilities

### 6.1 SOUL.md (Identity Layer)

Defines:

* personality
* tone
* worldview
* decision style
* what the agent optimizes for

Does NOT include:

* step-by-step instructions
* implementation detail
* execution logic

---

### 6.2 CONTRACT.md (Law Layer)

Defines:

* allowed behaviors
* forbidden behaviors
* required guarantees
* escalation rules
* handoff conditions

This file is **authoritative and strict**.

---

### 6.3 SKILL.md (Capability Layer)

Defines:

* role summary
* capability domains
* workflow process
* action selection rules
* output structure

Acts as:

> a router, not a knowledge dump

Must NOT:

* contain excessive procedural detail
* duplicate action content

---

### 6.4 actions/*.md (Execution Layer)

Each action is a **focused execution unit**.

#### Required Structure:

```markdown
# ACTION NAME

## Purpose
What this action does

## When to Use
Trigger conditions

## Inputs
Required data

## Constraints
Rules and limitations

## Process
Step-by-step execution

## Output
Expected result format

## Failure Modes
Common issues and how to handle them

## Example
Concrete example usage
```

---

## 7. Action Design Rules

An action SHOULD exist if:

* it is reusable
* it has clear boundaries
* it reduces SKILL.md complexity
* it produces a structured output

An action SHOULD NOT exist if:

* it is trivial
* it is one-off
* it overlaps heavily with another action

---

## 8. Invocation Model

Agents are invoked through structured calls.

### Syntax

```txt
agent
agent::action
```

### Examples

```txt
artifex::BUTTON
architectus::SETUP_CI
calo::WRITE_DOC
```

---

## 9. Runtime Composition

When executing an agent, the runtime MUST assemble context in this order:

### 1. Agent Core

* SOUL.md
* CONTRACT.md
* SKILL.md

### 2. Relevant Actions

* Only load required action files
* DO NOT load entire actions directory

### 3. Project Context

* ARCHITECTURE.md
* PLAN.md
* PROJECT_CONTEXT.md

### 4. Live State

* state.json
* recent logs (if needed)

---

## 10. Project Context Files

### 10.1 ARCHITECTURE.md

Defines:

* system structure
* components
* relationships
* technical decisions

---

### 10.2 PLAN.md

Defines:

* current work
* next steps
* execution order
* progress tracking

---

### 10.3 PROJECT_CONTEXT.md

Defines:

* goals
* constraints
* stack
* conventions
* terminology
* important background

---

## 11. Capability Evolution

When new behavior is needed:

### Option A — Context Problem

Add to:

* PROJECT_CONTEXT.md
* ARCHITECTURE.md
* PLAN.md

### Option B — Capability Problem

Add new global action:

```txt
~/.contubernium/agents/{agent}/actions/NEW_ACTION.md
```

---

## 12. Compatibility Philosophy

Agents are **portable assets**.

To use agents in external systems:

* concatenate:

  * SOUL.md
  * CONTRACT.md
  * SKILL.md
  * selected actions

Adapters define how to do this per tool.

---

## 13. Design Principles

### Separation of Concerns

* agents define behavior
* projects define context

### Composability

* agents operate via modular actions

### Minimal Context Loading

* only load what is necessary

### Explicit Execution

* all work is traceable via actions

### Stability

* agents evolve centrally, not per project

---

## 14. Summary

Contubernium enforces:

* global, canonical agents
* modular action-based execution
* project-local contextual truth
* strict separation between capability and context

This architecture ensures:

* scalability
* maintainability
* clarity
* portability
