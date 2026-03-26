# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `5. Tool execution layer`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [x] Phase 4. Basic agent loop (no agents yet)
- [ ] Phase 5. Tool execution layer
- [ ] Phase 6. Single agent (Decanus only)
- [ ] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-4

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, centralized state-manager transitions, explicit loop-progression helpers, and focused phase-4 tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Default `.contubernium/state.json` scaffold now includes structured failure state and canonical intermediate results.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan updated through phase 4.

## Architectural Decisions Already Made

1. Logging is a structured JSON run ledger in `.contubernium/logs/`, not ad hoc text dumps.
2. Error handling is now canonicalized as a structured runtime failure object with:
   - `error_code`
   - `message`
   - `context`
3. `runtime_session.last_error` remains in place as a compatibility surface for the current UI/state snapshot.
4. `runtime_session.last_failure` is the canonical structured failure record for phase 2 onward.
5. Failures are logged into runtime log events, not only shown in UI/state strings.
6. Phase 3 introduced a dedicated `StateManager` layer in runtime code to own mission, loop, approval, and invocation transitions.
7. `agent_loop.intermediate_results` is now part of the canonical `.contubernium/state.json` shape while `last_tool_result` remains in place as a compatibility surface.
8. Phase 4 moved repeated loop progression for runtime-tool results, specialist handoffs, invocation results, and mission completion behind shared `StateManager` helpers.
9. Phase 4 made the loop `result` step explicit for runtime-tool and invocation-result transitions without redesigning the tool execution layer.
10. Phase 4 stayed inside runtime control-flow and tests only. It intentionally did not tighten typed tool mediation, collapse execution to Decanus-only, or redesign the TUI.

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Avoid TUI-driven schema or tool-layer redesign in phase 5 unless the runtime layer requires it first.

## Phase 5 Target

Phase 5 is the `Tool execution layer` from [docs/FEATURES.md](docs/FEATURES.md):

- Tighten tool execution around typed mediation and explicit validation
- Keep tool access routed through the runtime layer rather than agent-specific shortcuts
- Avoid quietly pulling in phase-6 Decanus-only constraints, phase-7 memory wiring, or TUI redesign while hardening the tool layer

## What “Done” Means For Phase 5

Phase 5 is done when all of the following are true:

1. Tool requests are mediated through a clearer typed runtime surface instead of ad hoc branching alone.
2. Input validation and failure handling are explicit per tool path without regressing phase-1 logs, phase-2 failures, or phase-4 loop behavior.
3. Timeout/policy denial behavior remains structured and inspectable in both state and runtime logs.
4. Phase-3/4 state-manager ownership stays intact; phase 5 should not re-scatter loop state mutations.
5. Existing tests still pass, and new tests cover tool validation/mediation without silently implementing phases 6, 7, or 8.
6. Phase 5 does not redesign the TUI or collapse specialist boundaries into the tool layer.

## Suggested Phase 5 Approach

1. Inventory the current `executeToolRequests` branching in [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig) and identify what can move behind a typed mediation surface.
2. Introduce the smallest clean abstraction that centralizes tool lookup, request validation, and execution outcomes without rewriting the whole runtime.
3. Keep using the existing state-manager loop helpers so tool hardening does not re-entangle phase-4 loop progression with tool specifics.
4. Add tests for valid execution, policy-denied execution, and malformed/missing tool inputs.
5. Preserve current structured logging and failure capture on every tool request/result path.

## Validation Commands

Run these after phase 5 changes:

```bash
zig fmt src/main.zig src/embedded_assets.zig
zig build test
zig build run -- init
```

Optional runtime validation if a local model backend is available:

```bash
zig build run -- doctor
```

## Suggested Commit Message

```text
feat(runtime): complete phase 4 basic agent loop
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 5 only.

Read:
- AGENTS.md
- docs/doctrine.md
- docs/agent-contracts.md
- docs/FEATURES.md
- FEATURES_CHECKLIST.md
- PHASE_HANDOFF.md

Constraints:
- Do not skip build order.
- Preserve the structured JSON logging system from phase 1.
- Preserve the structured runtime failure system from phase 2.
- Preserve the phase-3 state-manager ownership and phase-4 shared loop-progression helpers.
- Do not redesign the TUI in phase 5.
- Keep `.contubernium/state.json` as canonical runtime state.

Task:
Implement phase 5, the tool execution layer, and update FEATURES_CHECKLIST.md when done.
```
