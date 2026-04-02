# Contubernium Doctrine

## 1. What Contubernium Is

Contubernium is a commander-led AI execution system for taking a project from idea to structured, working reality.

It is not a chatbot.
It is not a general-purpose assistant.
It is a project execution system built around controlled delegation.

## 2. Core Philosophy

Contubernium is built on one principle:

> Clear command, disciplined execution.

That principle is enforced through:

- one commander: `decanus`
- specialist tools with strict roles
- an explicit execution loop
- visible state and logs
- minimal ambiguity in responsibility

The system rejects:

- vague multi-agent autonomy
- hidden behavior
- uncontrolled side effects
- role overlap that weakens accountability

## 3. Commander Model

All work flows through `decanus`.

`decanus`:

- interprets the mission
- breaks it into tasks
- selects the correct specialist when needed
- evaluates results
- determines completion

No other agent owns the mission or final outcome.

## 4. Specialist And Helper Model

All non-`decanus` agents are tools, not peers.

They:

- operate in narrow scope
- perform a single assigned objective
- return structured results to `decanus`

The constitutional core target is 8 total agents including `decanus`.
If the installed asset set temporarily contains more than 7 non-`decanus` agents during alignment work, the extras are helper agents rather than additional core peers.

Helper agents still:

- do not orchestrate
- do not own the mission
- do not override commander-first control

## 5. Execution Loop

Contubernium runs on the same loop everywhere:

Think -> Tool -> Result -> Think -> Finish

In practice:

1. the user provides a mission
2. `decanus` interprets and plans
3. a specialist is invoked if needed
4. the specialist returns results
5. `decanus` evaluates and continues or completes

The loop ends only when:

- the mission is complete
- the system is blocked
- approval or user input is required

## 6. Memory Model

Contubernium uses three constitutional memory tiers mapped onto the current local project files.

Mission memory:

- `.contubernium/state.json`
- `.contubernium/logs/` as the durable per-run execution trace

Project memory:

- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`

Global memory:

- the current runtime-loaded global layer at `.contubernium/global.md`

Important distinction:

- `~/.contubernium/` is the installed global asset home
- it provides agents, shared patterns, adapters, templates, and preserved home-level state
- it is not the project-local scaffold created by `contubernium init`

Only validated information becomes canonical memory.
Speculative or temporary data must not be persisted.

## 7. Installed Assets And Project Layout

Contubernium separates installed assets from project state.

Installed home layout lives under `~/.contubernium/` and contains:

- `agents/`
- `shared/`
- `adapters/`
- `templates/`

Initialized project layout lives under the working directory and contains:

- `.contubernium/state.json`
- `.contubernium/config.json`
- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/logs/`

Project-local `.agents/` and `.contubernium/prompts/` are legacy assumptions, not the canonical runtime layout.

## 8. Execution Boundaries

Contubernium may:

- read files
- write code
- run commands
- use APIs

Contubernium must:

- request approval before risky actions
- avoid destructive or irreversible changes without confirmation
- remain explicit about intended side effects

Safety is enforced through visible approvals and traceable logs.

## 9. Local-First Runtime

Contubernium is designed to operate:

- locally by default
- with Zig as the authoritative runtime
- with Ollama as the primary local backend

OpenAI-compatible backends are allowed, but core behavior must not depend on cloud availability.

## 10. Interface Scope

The primary interface is the OpenTUI terminal interface.

Other interfaces are adapters and must not redefine core behavior.

`USER_MANUAL.md` is the operator-facing feature manual for shipped behavior.

## 11. System Discipline

Contubernium prioritizes:

1. clarity over cleverness
2. structure over flexibility
3. control over autonomy
4. execution over discussion

Every part of the system should remain:

- explainable
- predictable
- intentional

## 12. Non-Goals

Contubernium is not:

- a general AI assistant
- a casual conversation tool
- a UI-first product
- an unconstrained agent swarm

## 13. Definition Of Success

Contubernium succeeds when:

- a project moves from idea to structure to working implementation
- decisions remain consistent over time
- complexity does not degrade into chaos
- users can rely on execution, not just suggestions

## 14. Final Principle

> The strength of Contubernium is not intelligence.
>
> It is discipline.

Every design decision should reinforce clear roles, controlled execution, and reliable outcomes.
