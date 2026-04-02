# Contubernium Agent Architecture

This file mirrors the canonical architecture doctrine in `docs/AGENT_ARCHITECTURE.md`.

## 1. Purpose

Contubernium agents are persistent, global, specialized capability systems. Projects provide context only.

## 2. Core Doctrine

Every agent is composed from four layers:

1. `SOUL.md`
2. `CONTRACT.md`
3. `SKILL.md`
4. `actions/*.md`

## 2.1 Constitutional Topology

- Core roster: `decanus` plus `faber`, `artifex`, `architectus`, `tesserarius`, `explorator`, `signifer`, and `calo`
- Helper roster: `praeco` and `mulus`
- Core and helper agents share the same installed `agents/` tree
- Helper agents are explicit adjunct tools, not default lane owners

## 3. Global vs Project Boundary

- Global agents live in the Contubernium home.
- Projects do not redefine agent identity or behavior.
- Projects provide local truth through `.contubernium/ARCHITECTURE.md`, `PLAN.md`, `PROJECT_CONTEXT.md`, `state.json`, and logs.

## 4. Non-Negotiable Rules

- Agents are global.
- Actions are global.
- Projects contain truth, not behavior.

## 5. Agent File Structure

```txt
agent-name/
  SOUL.md
  CONTRACT.md
  SKILL.md
  actions/
    ACTION_NAME.md
```

## 6. File Responsibilities

- `SOUL.md`: identity, worldview, tone, decision style.
- `CONTRACT.md`: strict law, guarantees, escalation, handoff.
- `SKILL.md`: role summary, domains, workflow, action routing, output shape.
- `actions/*.md`: focused execution units.

## 7. Action Design Rules

Create an action when it is reusable, bounded, structured, and reduces skill-level complexity.

## 8. Invocation Model

Supported call forms:

- `agent`
- `agent::ACTION`

Default lane routing only applies to core specialists. Helper agents must be named explicitly.

## 9. Runtime Composition Order

The runtime assembles:

1. agent core
2. selected actions
3. project context
4. live state

## 10. Project Context Files

- `ARCHITECTURE.md`
- `PLAN.md`
- `PROJECT_CONTEXT.md`

## 11. Capability Evolution

Add context to project files. Add reusable behavior as a new global action.

## 12. Compatibility Philosophy

Adapters concatenate agent core plus selected actions and append project context and live state.

## 13. Design Principles

- Separation of concerns
- Composability
- Minimal context loading
- Explicit execution
- Centralized stability

## 14. Summary

Global canonical agents plus project-local contextual truth keep Contubernium scalable, portable, and disciplined.
