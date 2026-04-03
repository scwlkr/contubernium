# Docs Guide

`docs/` now follows a simple rule:

- root `docs/` files are the current core references
- `docs/archive/` holds historical material that still has reference value
- `docs/scratchpad/` holds temporary or exploratory notes that are not canonical

## Core Docs

- [CONTUBERNIUM_CONSTITUTION.md](./CONTUBERNIUM_CONSTITUTION.md): immutable constitutional source of truth
- [doctrine.md](./doctrine.md): system doctrine aligned to the Constitution
- [agent-contracts.md](./agent-contracts.md): agent boundaries and invocation contracts
- [AGENT_ARCHITECTURE.md](./AGENT_ARCHITECTURE.md): current agent topology and asset layout
- [invocation-protocol.md](./invocation-protocol.md): runtime invocation and result protocol
- [RUNTIME_TOOL_CONTRACTS.md](./RUNTIME_TOOL_CONTRACTS.md): published runtime tool contracts
- [MEMORY_FORMATS.md](./MEMORY_FORMATS.md): memory compatibility and migration notes
- [installation.md](./installation.md): install and project initialization flow

## Sequential Audit

| Order | Document | Bucket | Alignment | Notes |
| --- | --- | --- | --- | --- |
| 1 | [AGENT_ARCHITECTURE.md](./AGENT_ARCHITECTURE.md) | Core | Aligned | Matches the commander-first model, global-home agent assets, and core-plus-helper roster. |
| 2 | [archive/CONSTITUTION_ALIGNMENT_PLAN.md](./archive/CONSTITUTION_ALIGNMENT_PLAN.md) | Archive | Partially aligned | Useful implementation history, but it still references stale follow-up targets and is not front-line guidance. |
| 3 | [archive/CONSTITUTION_DECISIONS.md](./archive/CONSTITUTION_DECISIONS.md) | Archive | Aligned | Decision record remains useful, but the live rules should exist in the core docs. |
| 4 | [archive/CONSTITUTION_GAP_ANALYSIS.md](./archive/CONSTITUTION_GAP_ANALYSIS.md) | Archive | Partially aligned | Historical audit with valid context, but some open questions and legacy references are no longer current. |
| 5 | [CONTUBERNIUM_CONSTITUTION.md](./CONTUBERNIUM_CONSTITUTION.md) | Core | Source of truth | Immutable constitutional baseline. |
| 6 | [MEMORY_FORMATS.md](./MEMORY_FORMATS.md) | Core | Aligned | Matches the documented memory tiers, portability notes, and migration discipline. |
| 7 | [RUNTIME_TOOL_CONTRACTS.md](./RUNTIME_TOOL_CONTRACTS.md) | Core | Aligned | Publishes the permission, schema, timeout, and failure-contract expectations required by the Constitution. |
| 8 | [agent-contracts.md](./agent-contracts.md) | Core | Aligned | Preserves `decanus` authority and specialist-tool boundaries. |
| 9 | [scratchpad/context_engineering_high_level.md](./scratchpad/context_engineering_high_level.md) | Scratchpad | Non-canonical | General context-engineering background; not a governing Contubernium spec. |
| 10 | [doctrine.md](./doctrine.md) | Core | Aligned | Consistent with commander-first control, local-first runtime, and layered memory. |
| 11 | [installation.md](./installation.md) | Core | Aligned | Describes the current global-home install flow and canonical project scaffold. |
| 12 | [invocation-protocol.md](./invocation-protocol.md) | Core | Aligned | Keeps all specialist work routed through `decanus` with explicit approvals and structured envelopes. |

## Working Rules

- Add a document to the root only if it is a current operator or engineering reference.
- Move completed audits, plans, and decision logs to `docs/archive/`.
- Put temporary notes and exploratory thinking in `docs/scratchpad/`.
- Promote a scratchpad note into the root only after it becomes stable, canonical guidance.
