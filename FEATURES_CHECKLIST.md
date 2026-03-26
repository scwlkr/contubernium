# Features Checklist

This checklist tracks implementation progress against [FEATURES.md](docs/FEATURES.md).

## Build Order

- [x] 1. Logging system
- [x] 2. Error system
- [x] 3. State manager
- [x] 4. Basic agent loop (no agents yet)
- [x] 5. Tool execution layer
- [x] 6. Single agent (Decanus only)
- [x] 7. Memory system hookup
- [x] 8. Then OpenTUI

## Phase 1: Logging System

Reference:
- [FEATURES.md](docs/FEATURES.md) section `6. Logging System`
- [FEATURES.md](docs/FEATURES.md) section `3.4 logs/ (critical)`
- [FEATURES.md](docs/FEATURES.md) section `0. System Philosophy`

Done:
- [x] Replaced ad hoc plain-text turn dumps with structured JSON runtime logs under `.contubernium/logs/`
- [x] Switched the active runtime log path to a `.json` run ledger so each mission/resume session is traceable
- [x] Logged prompt capture, provider transport, raw model output, parsed output, tool requests/results, approval flow, repair retries, and run outcomes as structured events
- [x] Kept logging local-first and runtime-owned in Zig without introducing hidden behavior
- [x] Preserved the existing runtime/OpenTUI state references so the current log path is still observable in the OpenTUI snapshot

## Phase 2: Error System

Reference:
- [FEATURES.md](docs/FEATURES.md) section `7. Error System`

Done:
- [x] Added a structured runtime failure object with `error_code`, `message`, and `context`
- [x] Preserved the existing `last_error` string as a compatibility surface while storing canonical structured failure data beside it
- [x] Standardized blocked/error paths across loop interruption, loop limits, context exhaustion, tool denials, invalid model JSON, and blocked actor turns
- [x] Included structured failure payloads in runtime log events so failures are inspectable beyond plain text

Still to do later:
- [x] Phase 8: replace the legacy terminal UI with OpenTUI after the underlying runtime stack is confirmed

## Phase 3: State manager

Reference:
- [FEATURES.md](docs/FEATURES.md) section `1.3 State Manager`
- [FEATURES.md](docs/FEATURES.md) section `3.1 state.json (volatile)`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md) section `Architectural Decisions Already Made`

Done:
- [x] Centralized mission, turn, approval, invocation, blocking, and completion transitions behind a dedicated runtime state-manager layer in `src/main.zig`
- [x] Kept `.contubernium/state.json` as the canonical runtime state file while making the state shape explicit for mission, current actor, loop state, runtime session, and intermediate results
- [x] Added canonical `agent_loop.intermediate_results` tracking without regressing existing `last_tool_result` and history compatibility surfaces
- [x] Preserved phase-1 structured logs and phase-2 structured failures while routing blocked and completion paths through the state manager
- [x] Added focused tests for reset, approval, blocked, invocation, and intermediate-result transitions

## Phase 4: Basic agent loop

Reference:
- [FEATURES.md](docs/FEATURES.md) section `1.1 Agent Loop`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md) section `Phase 4 Target`

Done:
- [x] Isolated shared loop-progression helpers in `src/main.zig` so runtime tool results, specialist handoffs, invocation results, and mission completion flow through a common state-manager surface
- [x] Made the loop's `result` step explicit for runtime-tool and invocation-result transitions without redesigning the tool layer or OpenTUI
- [x] Preserved phase-1 structured logging, phase-2 structured failures, and phase-3 state-manager ownership while reducing duplicated loop-transition logic in actor-specific turn handling
- [x] Added focused tests covering runtime tool result progression, invocation handoff/result progression, and mission completion

## Phase 5: Tool execution layer

Reference:
- [FEATURES.md](docs/FEATURES.md) section `1.2 Tool Execution System`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md) section `Phase 5 Target`

Done:
- [x] Replaced the long ad hoc tool-name branch in `src/main.zig` with a typed runtime mediation layer for lookup, approval policy, validation, and execution dispatch
- [x] Added explicit per-tool validation for unsupported tools, missing inputs, blocked commands, and workspace-path safety before execution
- [x] Added structured runtime failure handling for malformed requests, operator denials, policy denials, and command timeouts without regressing phase-1 logs or phase-3/4 loop ownership
- [x] Added a bounded command timeout policy/config surface so shell-backed tool execution is mediated instead of unbounded
- [x] Added focused tests for valid execution, malformed input, policy denial, and approval denial through `executeToolRequests`

## Phase 6: Single agent (Decanus only)

Reference:
- [FEATURES.md](docs/FEATURES.md) section `0. System Philosophy`
- [FEATURES.md](docs/FEATURES.md) section `2. Agent Layer`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md) section `Phase 6 Target`

Done:
- [x] Constrained `executeStep` in `src/main.zig` so active runtime execution blocks non-`decanus` turns instead of routing into specialist execution
- [x] Rejected `invoke_specialist` decisions from `decanus` with structured failures, state/history updates, and explicit runtime log events
- [x] Updated Decanus prompt/schema assets in `prompts/`, `.contubernium/prompts/`, and `src/embedded_assets.zig` so phase 6 runtime guidance is single-agent by default
- [x] Added focused tests covering blocked active-specialist turns and blocked specialist-invocation requests without removing the future-facing invocation/state-manager surfaces

## Phase 7: Memory system hookup

Reference:
- [FEATURES.md](docs/FEATURES.md) section `3. Memory System`
- [FEATURES.md](docs/FEATURES.md) section `3.1 state.json (volatile)`
- [FEATURES.md](docs/FEATURES.md) section `3.2 project.md (semi-static)`
- [FEATURES.md](docs/FEATURES.md) section `3.3 global.md (shared intelligence)`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md) section `Phase 7 Target`

Done:
- [x] Added an explicit runtime memory-loading layer in `src/main.zig` that reads configured project/global memory files before prompt assembly instead of copying those layers into ad hoc state fields
- [x] Kept `.contubernium/state.json` as canonical mission/runtime state while wiring `.contubernium/project.md` and `.contubernium/global.md` into Decanus and future specialist prompt context
- [x] Added bounded memory-context limits plus structured blocking failures/log events for missing, invalid, or oversized memory-layer inputs
- [x] Scaffolded default project/global memory files and config defaults in `src/embedded_assets.zig`, `.contubernium/config.json`, and template/repo config surfaces
- [x] Updated phase-7 prompt guidance in `prompts/` and `.contubernium/prompts/` so Decanus treats external memory as read-only context while keeping the phase-6 single-agent guard intact
- [x] Added focused tests covering memory truncation, prompt inclusion, and blocked prompt assembly when a required memory layer is missing

## Phase 8: OpenTUI

Reference:
- [FEATURES.md](docs/FEATURES.md) section `5. Zig + OpenTUI Runtime CLI`
- [PHASE_HANDOFF.md](PHASE_HANDOFF.md)

Done:
- [x] Removed the `vaxis` dependency and deleted the legacy terminal renderer from `src/main.zig`
- [x] Added an OpenTUI frontend under `opentui/` that renders the mission transcript, structured run log, runtime rail, approvals, and model controls
- [x] Added a Zig `ui-bridge` command that streams runtime events and snapshots to OpenTUI over JSON lines without bypassing commander-first runtime control
- [x] Updated `contubernium ui` so it launches the OpenTUI frontend through Bun while keeping Zig as the authoritative runtime
- [x] Updated installation flow and documentation so OpenTUI is the only documented terminal interface
- [x] Kept runtime tests green and added a bridge smoke-path that works against the current workspace state
