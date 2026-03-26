# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `4. Basic agent loop (no agents yet)`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [ ] Phase 4. Basic agent loop (no agents yet)
- [ ] Phase 5. Tool execution layer
- [ ] Phase 6. Single agent (Decanus only)
- [ ] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-3

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, centralized state-manager transitions, intermediate results, tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Default `.contubernium/state.json` scaffold now includes structured failure state and canonical intermediate results.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan updated through phase 3.

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
8. Phase 3 stayed inside runtime/state infrastructure only. It intentionally did not isolate the loop, redesign the tool layer, or rework the TUI.

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Avoid TUI-driven schema or loop changes in phase 4. Runtime behavior should lead; the UI should follow later.

## Phase 4 Target

Phase 4 is the `Basic agent loop (no agents yet)` from [docs/FEATURES.md](docs/FEATURES.md):

- Isolate and confirm the loop mechanics independently from specialist behavior
- Keep the loop shape aligned to:
  - Think
  - Tool
  - Result
  - Think
  - Finish
- Avoid quietly pulling in phase-5 tool mediation redesign or phase-6 Decanus-only constraints beyond what phase 4 requires

## What “Done” Means For Phase 4

Phase 4 is done when all of the following are true:

1. The loop mechanics are explicit and testable without depending on specialist-specific behavior.
2. Turn progression, completion, and blocked/interrupt exits are confirmed independently from later tool-layer tightening.
3. Phase-3 state-manager ownership stays intact; phase 4 should build on it instead of re-scattering state mutations.
4. The current schema remains compatible with phase-1 logs, phase-2 structured failures, and phase-3 canonical state transitions.
5. Existing tests still pass, and new tests cover loop progression without silently implementing phase 5, 6, or 8.
6. Phase 4 does not redesign the TUI or collapse specialist boundaries into the loop layer.

## Suggested Phase 4 Approach

1. Inventory where the current runtime loop still mixes basic loop progression with specialist-specific handling in [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig).
2. Separate the generic loop mechanics from specialist/Decanus behavior as far as phase 4 allows.
3. Keep using the state-manager helpers for loop-state ownership instead of writing fields directly.
4. Add tests around loop progression, blocked exits, and completion exits without redesigning the tool layer yet.
5. Preserve current logging and failure capture on every loop transition.

## Validation Commands

Run these after phase 4 changes:

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
feat(runtime): complete phase 3 state manager
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 4 only.

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
- Preserve the phase-3 state-manager ownership and canonical `.contubernium/state.json` shape.
- Do not redesign the TUI in phase 4.
- Keep `.contubernium/state.json` as canonical runtime state.

Task:
Implement phase 4, the basic agent loop (no agents yet), and update FEATURES_CHECKLIST.md when done.
```
