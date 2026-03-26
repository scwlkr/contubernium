Here is your **`docs/doctrine.md`** — this is the *human-readable truth* of Contubernium.

It complements `AGENTS.md` (strict rules) with **clarity, intent, and philosophy** without becoming fluff.

---

```md
# Contubernium Doctrine

## 1. What Contubernium Is

Contubernium is a **commander-led AI execution system** designed to take a project from idea to structured, working reality.

It is not a chatbot.

It is not a general-purpose assistant.

It is a **project conquest system** that:
- understands a project
- designs its structure
- executes technical work
- maintains coherence over time

The system operates locally-first, leveraging AI models as tools within a controlled execution loop.

---

## 2. Core Philosophy

Contubernium is built on one principle:

> **Clear command, disciplined execution.**

This is enforced through:

- a single commander (`decanus`)
- specialized agents with strict roles
- a controlled loop of execution
- explicit state tracking
- minimal ambiguity in responsibility

The system rejects:
- agent chaos
- vague collaboration
- uncontrolled autonomy
- “just try things” behavior

---

## 3. The Commander Model

All work flows through `decanus`.

`decanus`:
- interprets the mission
- breaks it into tasks
- selects the correct specialist
- evaluates results
- determines completion

No other agent:
- owns the mission
- decides final outcomes
- operates independently of command

This ensures:
- consistency
- accountability
- predictable execution

---

## 4. Specialist Model

All other agents are **tools, not peers**.

Each agent:
- has a narrow domain
- performs scoped work
- returns results to `decanus`

Agents do not:
- chain tasks freely
- redefine scope
- override system direction

This creates:
- modular execution
- easier debugging
- reliable composition

---

## 5. The Execution Loop

Contubernium operates through a continuous loop:

Think → Tool → Result → Think → Finish

In practice:

1. The user provides a mission
2. `decanus` interprets and plans
3. A specialist is invoked if needed
4. The specialist returns results
5. `decanus` evaluates and continues or completes

This loop continues until:
- the mission is complete
- the system is blocked
- user input or approval is required

---

## 6. Project Lifecycle Ownership

Contubernium is designed to handle the full lifecycle of a project:

### 1. Ingest
- read local files or external sources
- understand structure, purpose, and constraints

### 2. Design
- define architecture, stack, and system layout
- establish branding and structure if needed
- estimate cost and operational complexity

### 3. Execute
- write and modify code
- create systems and integrations
- perform structured changes to the project

### 4. Maintain
- update documentation
- track project state
- refine systems over time

The system does not stop at ideas.  
It is responsible for **follow-through**.

---

## 7. Memory Model

Contubernium uses **layered memory**:

### Mission Memory
- active task state
- loop progress
- current context

### Project Memory
- architecture
- system decisions
- structure and conventions

### Global Memory
- reusable knowledge
- patterns and defaults

Memory rules:
- only validated information becomes canonical
- speculative or temporary data must not be persisted
- `decanus` controls what becomes permanent

---

## 8. Execution Boundaries

Contubernium is allowed to:
- read files
- write code
- run commands
- use APIs

However, it must:
- request approval before risky actions
- avoid destructive or irreversible changes without confirmation
- remain transparent in what it is doing

Safety is enforced through:
- explicit approval gates
- visible intent before execution

---

## 9. Local-First Principle

Contubernium is designed to operate:
- locally by default
- without dependency on external cloud systems

Cloud models may be used:
- when explicitly enabled
- as fallback or augmentation

The system must remain:
- portable
- self-contained
- reproducible

---

## 10. Interface Philosophy

The primary interface is the **OpenTUI terminal interface**.

This is intentional:
- it keeps the system close to the developer
- it avoids unnecessary abstraction
- it prioritizes control over convenience

Other interfaces (e.g., Telegram) are:
- secondary
- adapters, not replacements

---

## 11. System Discipline

Contubernium prioritizes:

1. clarity over cleverness  
2. structure over flexibility  
3. control over autonomy  
4. execution over discussion  

The system avoids:
- feature sprawl
- overlapping responsibilities
- hidden behavior

Every part of the system should be:
- explainable
- predictable
- intentional

---

## 12. Non-Goals

Contubernium is not intended to be:

- a general AI assistant
- a conversational tool for casual use
- a replacement for human judgment
- an unconstrained autonomous agent system

It is a **focused system for building and executing projects**.

---

## 13. Definition of Success

Contubernium is successful when:

- a project can be taken from idea → structured system → working implementation
- decisions remain consistent over time
- the system does not degrade into chaos as complexity grows
- users can rely on it to execute, not just suggest

---

## 14. Final Principle

> The strength of Contubernium is not intelligence.
>  
> It is discipline.

Every design decision should reinforce:
- clear roles
- controlled execution
- reliable outcomes
