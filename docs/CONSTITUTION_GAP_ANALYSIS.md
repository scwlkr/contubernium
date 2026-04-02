# Constitution Gap Analysis

## Purpose

This document maps [docs/CONTUBERNIUM_CONSTITUTION.md](./CONTUBERNIUM_CONSTITUTION.md) against the current Contubernium repository. It identifies where the project is already aligned, where alignment is partial, and where implementation or governance changes are required.

This document does not amend the Constitution. It is an implementation audit.

## Executive Summary

The current project already matches the Constitution in several important ways:

- `decanus` remains the sole orchestrator.
- The runtime is local-first and Zig-based.
- The primary interface is CLI/OpenTUI.
- Context management already summarizes and condenses state.
- Structured per-run logs already exist.

The main constitutional gaps are:

- Model policy is not yet dynamic and true fallback execution is not implemented.
- The agent roster does not match the new "8 core + 2+ helper" requirement.
- Session logging exists, but sessions are not yet written into canonical memory with retrieval and resume semantics.
- Tool permissions and tool schemas are only partially modeled.
- The new `USER_MANUAL.md` baseline still needs process enforcement and ongoing maintenance.
- Several legacy documents still describe project-local prompts or project-local agent scaffolding that the runtime no longer uses.

## Article-by-Article Status

| Article | Status | Current State | Required Change |
| --- | --- | --- | --- |
| I. Local-First Principle | Partial | The runtime is local-first and defaults to Ollama. The code supports `ollama-native` and a generic `openai-compatible` provider. | Expose OpenRouter as a first-class supported backend while reusing the industry-standard OpenAI-compatible transport pattern. |
| II. Model Selection | Conflict | The config stores one primary model plus one fallback config, but runtime selection is static and fallback execution is not wired into the turn loop. | Add a real model policy layer: smallest-capable defaulting, escalation rules, and automatic fallback on provider/model failure. |
| III. Interface Priority | Aligned | The CLI and OpenTUI are the primary operator interfaces. | No structural change required. |
| IV. Orchestration Authority | Aligned | The runtime, doctrine, and contracts all keep authority inside `decanus`. | Preserve current behavior while updating surrounding docs. |
| V. Memory Structure | Partial | The repo has short-term mission/session state plus project and global memory. Extra local files such as `ARCHITECTURE.md`, `PLAN.md`, and `PROJECT_CONTEXT.md` extend the model beyond the Constitution. | Normalize the documented memory model so the extra files are clearly treated as project-local memory layers under the constitutional three-tier model. |
| VI. Agent System | Conflict | The repo currently ships 10 named agents (`decanus` plus 9 specialists) and no defined helper-agent tier. The owner has now clarified that the constitutional core 8 includes `decanus`, so the current roster is oversized. The runtime already prefers global-home agent assets, but legacy docs still describe project-local agent scaffolds. | Reclassify the roster into 8 core agents total and 2+ helper agents, then remove stale project-local agent claims from docs. |
| VII. System Design Philosophy | Partial | The philosophy is present in doctrine, but the runtime does not yet actively optimize around smaller-model decomposition. | Tie model-routing and task decomposition rules to runtime policy, not just prose. |
| VIII. Sessions | Conflict | Per-run JSON logs exist under `.contubernium/logs/`, but sessions are not stored in canonical memory with list/retrieve/resume primitives. `mission continue` resumes only the current local state. | Add a session registry plus session recall/resume flow that writes durable session metadata into memory. |
| IX. Platform Support | Partial | The project clearly targets macOS and Linux. There is no explicit portability guardrail or smoke coverage for future Windows support. | Add a portability note to engineering docs and avoid path/process assumptions that make Windows support unusually hard later. |
| X. Open Source Requirement | Aligned | The repo is source-based and `README.md` contains installation instructions. | Keep the README current as runtime/config behavior changes. |
| XI. Development Process | Conflict | There are Zig tests in place and the repo now has a baseline `USER_MANUAL.md`, but there is still no contributor-facing rule that enforces test-first plus manual updates for every feature. | Keep the manual, document the process, and later enforce it through review/CI policy. |
| XII. Versioning and Migration | Partial | The repo is version-controlled, but global-memory compatibility and migration rules are not explicitly versioned. | Version the global-memory/session format and add migration guidance or tooling. |
| XIII. Logging and Errors | Partial | Structured logs exist and failures already carry `error_code` and contextual fields. The failure shape does not use an explicit `cause` field, and not every action/tool contract documents that format. | Standardize failure envelopes around `code` and `cause`, and publish that format in docs and tool metadata. |
| XIV. User Authority | Partial | The runtime supports interruption and manual approval for guarded actions. The owner has now clarified that explicit approval bypass should be session-scoped and reversible mid-session, but that behavior is not yet implemented. | Add session-scoped approval bypass state with an explicit toggle to turn it back off. |
| XV. Context Management | Aligned | Prompt budgeting and history condensation already exist in the runtime. | Keep this behavior and document the guarantees more clearly. |
| XVI. Permissions | Conflict | Runtime tools only declare approval gates such as `read`, `shell`, and `write`. There is no unified permission model published across tools and actions using `Read` / `Write` / `Execute`. | Introduce explicit permission metadata for every runtime tool and action. |
| XVII. Memory Isolation | Partial | Project memory files live inside the working directory, which is good. Cross-project authorization rules are not yet defined for future global memory/session retrieval features. | Define isolation and authorization rules before adding global session recall. |
| XVIII. Tooling Standards | Conflict | Tool request validation exists in code, and timeouts exist in config, but there is no published per-tool registry that defines input schema, output schema, timeout behavior, and failure response format. | Add a canonical tool contract document and corresponding runtime metadata. |
| XIX. Constitutional Immutability | Aligned | The Constitution exists as its own file and has not been modified here. | Keep future changes in amendment documents only. |
| XX. Amendment Format | Partial | The Constitution defines the amendment format, but the repo does not yet provide an amendment template or process note. | Add an amendment template only if constitutional changes are needed later. |

## Highest-Priority Conflicts

These conflicts should be treated as first-order work because they change system behavior or governance:

1. Model policy and fallback behavior do not satisfy Articles I, II, and VII.
2. The agent roster and helper-agent model do not satisfy Article VI.
3. Session memory and retrieval do not satisfy Article VIII.
4. Tool permissions and tooling schema standards do not satisfy Articles XVI and XVIII.
5. The development process still does not satisfy Article XI until test-first and manual-update rules are enforced as standard practice.

## Legacy Documentation Drift

The following documents still describe older architecture assumptions and should be rewritten during alignment work:

- `AGENTS.md`
- `docs/doctrine.md`
- `docs/agent-contracts.md`
- `docs/FEATURES.md`
- `docs/local-llm-runtime-spec.md`
- `docs/local-llm-operations.md`

The main drift is:

- project-local `.agents/` scaffolding
- project-local `.contubernium/prompts/`
- older provider language that predates the global-home asset layout

## Resolved Owner Decisions

The following ambiguities are now resolved and recorded in [docs/CONSTITUTION_DECISIONS.md](./CONSTITUTION_DECISIONS.md):

1. The core 8 includes `decanus`.
2. OpenRouter should be first-class, implemented via the standard OpenAI-compatible transport pattern.
3. Approval bypass is scoped per session and must be reversible during that session.

## Remaining Open Decision

One structural item still benefits from an explicit choice during implementation:

1. Should helper agents live beside core agents under the same home-directory `agents/` tree, or under a separate `helpers/` namespace?

## Recommended Next Document

Use [docs/CONSTITUTION_ALIGNMENT_PLAN.md](./CONSTITUTION_ALIGNMENT_PLAN.md) as the implementation sequence for resolving the conflicts in this audit.
