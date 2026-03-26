# Features Checklist

This checklist tracks implementation progress against [FEATURES.md](docs/FEATURES.md).

## Build Order

- [x] 1. Logging system
- [x] 2. Error system
- [x] 3. State manager
- [x] 4. Basic agent loop (no agents yet)
- [ ] 5. Tool execution layer
- [ ] 6. Single agent (Decanus only)
- [ ] 7. Memory system hookup
- [ ] 8. Then TUI

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
- [x] Preserved the existing runtime/TUI state references so the current log path is still observable in the UI snapshot

## Phase 2: Error System

Reference:
- [FEATURES.md](docs/FEATURES.md) section `7. Error System`

Done:
- [x] Added a structured runtime failure object with `error_code`, `message`, and `context`
- [x] Preserved the existing `last_error` string as a compatibility surface while storing canonical structured failure data beside it
- [x] Standardized blocked/error paths across loop interruption, loop limits, context exhaustion, tool denials, invalid model JSON, and blocked actor turns
- [x] Included structured failure payloads in runtime log events so failures are inspectable beyond plain text

Still to do later:
- [ ] Phase 5: tighten the tool execution layer around typed mediation and validation
- [ ] Phase 6: constrain execution to Decanus-only behavior where later-phase logic currently reaches beyond that target
- [ ] Phase 7: hook the external memory layers fully into the runtime flow
- [ ] Phase 8: refine the TUI only after the underlying runtime stack is confirmed

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
- [x] Made the loop's `result` step explicit for runtime-tool and invocation-result transitions without redesigning the tool layer or TUI
- [x] Preserved phase-1 structured logging, phase-2 structured failures, and phase-3 state-manager ownership while reducing duplicated loop-transition logic in actor-specific turn handling
- [x] Added focused tests covering runtime tool result progression, invocation handoff/result progression, and mission completion
