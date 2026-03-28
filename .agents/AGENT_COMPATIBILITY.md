# Agent Compatibility

Contubernium agents are portable assets.

## Assembly Order

When another runtime consumes an agent, concatenate content in this order:

1. shared runtime base
2. shared tool policy
3. `SOUL.md`
4. `CONTRACT.md`
5. `SKILL.md`
6. selected `actions/*.md`
7. project context files
8. live state

## Rules

- Never load project-local agent overrides.
- Load only the action files required by the active invocation.
- Preserve structured input and output contracts.
- Keep `decanus` as the sole orchestrator across adapters.

## Adapter Scope

Adapters change formatting and transport details only. They do not change agent identity, law, or authority boundaries.
