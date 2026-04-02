# Constitution Alignment Plan

## Purpose

This document turns the gap analysis into concrete implementation work. It is ordered to reduce governance drift first, then runtime risk, then long-tail cleanup.

Use this plan together with [docs/CONSTITUTION_GAP_ANALYSIS.md](./CONSTITUTION_GAP_ANALYSIS.md).
Resolved owner decisions are recorded in [docs/CONSTITUTION_DECISIONS.md](./CONSTITUTION_DECISIONS.md).

## Alignment Principles

- Preserve commander-first control.
- Keep changes minimal and explicit.
- Prefer documentation and schema clarity before behavioral expansion.
- Do not add new autonomy that weakens `decanus`.
- Treat session memory and global memory changes as migration-sensitive.

## Phase 0: Resolve Owner Decisions

Before runtime edits begin, make these decisions explicitly:

1. Confirm where helper agents live in the installed home layout.

Output:

- a short decision record in `docs/`
- updated wording for the governing docs

## Phase 1: Reconcile Governance Documents

Update the governance and operator docs so they no longer contradict the Constitution or the implemented global-home asset model.

Target files:

- `AGENTS.md`
- `docs/doctrine.md`
- `docs/agent-contracts.md`
- `README.md`
- `docs/FEATURES.md`
- `docs/local-llm-runtime-spec.md`
- `docs/local-llm-operations.md`

Required changes:

- remove project-local `.agents/` claims from operator docs
- remove project-local `.contubernium/prompts/` claims from operator docs
- rewrite the memory section to map constitutional tiers onto the current local files
- define helper-agent terminology if it is adopted
- document the current installation flow as global-home assets plus local project memory
- link to `USER_MANUAL.md` as the operator-facing feature manual

Acceptance criteria:

- no primary doc contradicts the Constitution
- no primary doc claims `contubernium init` creates `.agents/` or `.contubernium/prompts/`
- README install instructions still match `install.sh` and `init.sh`

## Phase 2: Lock The Agent Topology

Bring the runtime and docs into compliance with the new agent-system article.

Target areas:

- `.agents/`
- `src/runtime_core.zig`
- `src/runtime_assets.zig`
- `src/runtime_protocol.zig`
- agent docs and action inventories

Required changes:

- define the authoritative core roster as 8 total core agents including `decanus`
- add at least two helper agents or formally reclassify existing agents into helper roles
- update runtime enums, lane mapping, task mapping, and install validation
- ensure each installed agent has `SOUL.md`, `CONTRACT.md`, `SKILL.md`, and `actions/`
- document how helper agents differ from core agents without granting them orchestration authority

Acceptance criteria:

- roster count matches the Constitution exactly
- helper agents are documented and installed in the home directory
- no runtime path treats helper agents as peers to `decanus`

## Phase 3: Implement Constitutional Model Policy

Turn Articles I, II, and VII into runtime behavior.

Target areas:

- `src/runtime_core.zig`
- `src/runtime_provider.zig`
- `src/runtime_loop.zig`
- `templates/contubernium.config.template.json`
- `src/embedded_assets/contubernium.config.template.json`
- `README.md`
- `USER_MANUAL.md`

Required changes:

- define a model-policy object instead of a single static primary model
- support "smallest capable" defaulting
- record why an escalation happened
- implement real fallback execution when the active provider/model fails
- expose OpenRouter explicitly as a first-class supported backend using the OpenAI-compatible transport pattern
- log model policy decisions into the structured run log

Acceptance criteria:

- a failed model call can fall back without manual file edits
- run logs show primary model, escalation decisions, and fallback use
- config and manual explain how to operate both local and cloud-enabled modes

## Phase 4: Add Session Memory And Retrieval

Turn runtime run logs into durable session memory.

Target areas:

- `src/runtime_core.zig`
- `src/runtime_assets.zig`
- `src/runtime_app.zig`
- `src/cli.zig`
- `.contubernium/` templates
- `USER_MANUAL.md`

Required changes:

- define a canonical session record format
- write session metadata into durable memory, not only log files
- add commands to inspect and resume past sessions
- preserve project isolation when recalling session state
- define how global memory references session history without leaking project-local data
- add session-scoped approval bypass state that can be turned on and off during the session

Suggested storage approach:

- local session state stays under the project's `.contubernium/`
- global memory stores lightweight session index metadata only
- session recall requires explicit project match or explicit user authorization
- session approval bypass defaults to off for each new session

Acceptance criteria:

- every conversation produces a durable session record
- operators can list and resume prior sessions intentionally
- cross-project recall is blocked unless explicitly authorized

## Phase 5: Publish Permissions And Tool Contracts

Bring tools and actions into compliance with Articles XVI and XVIII.

Target areas:

- `src/runtime_core.zig`
- `src/runtime_tools.zig`
- `src/runtime_protocol.zig`
- `.agents/_schemas/`
- `docs/invocation-protocol.md`
- new tool contract docs under `docs/`

Required changes:

- extend runtime tool metadata to include permission class: `Read`, `Write`, or `Execute`
- define canonical input schema and output schema for each runtime tool
- standardize timeout behavior per tool
- standardize failure response shape using explicit `code` and `cause`
- optionally extend action docs to declare expected permission needs

Suggested documentation artifact:

- `docs/RUNTIME_TOOL_CONTRACTS.md`

Acceptance criteria:

- every supported runtime tool has one published contract entry
- every failure path returns the same top-level shape
- approval behavior is derived from published permission metadata, not only ad hoc branches

## Phase 6: Enforce The Development Process

Turn Article XI from a statement into a working rule.

Target areas:

- `USER_MANUAL.md`
- `README.md`
- contribution or review docs if added later
- CI configuration if introduced

Required changes:

- require feature work to land with tests
- require manual updates when behavior changes
- document where test references belong inside `USER_MANUAL.md`
- add a review checklist or CI guard later if needed

Acceptance criteria:

- contributors know where to document a feature and its test
- the manual becomes a maintained artifact instead of a placeholder

## Phase 7: Versioning, Migration, And Portability

Finish the long-tail constitutional work after the core runtime changes are stable.

Target areas:

- global memory/session schemas
- migration tooling
- platform notes and scripts

Required changes:

- version the global-memory/session format
- add migration rules for format changes
- add a portability note for path handling and process assumptions
- avoid Unix-only assumptions where easy to fix now

Acceptance criteria:

- memory schema changes can be migrated forward
- future Windows support is not boxed out by avoidable choices

## Recommended Implementation Order

1. Phase 0
2. Phase 1
3. Phase 2
4. Phase 5
5. Phase 3
6. Phase 4
7. Phase 6
8. Phase 7

Rationale:

- governance drift should be removed before behavior changes
- agent topology and tool contracts affect multiple runtime surfaces
- model policy and sessions are behavior-heavy and should be built on stable contracts

## Suggested Definition Of Done

Constitution alignment is complete when:

- the governing docs no longer contradict the Constitution
- the installed agent roster matches the constitutional model
- session recall exists and respects memory isolation
- runtime tools publish permissions and schemas
- model fallback is real, logged, and documented
- `USER_MANUAL.md` is actively maintained for every shipped feature change
