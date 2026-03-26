# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `3. State manager`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [ ] Phase 3. State manager
- [ ] Phase 4. Basic agent loop (no agents yet)
- [ ] Phase 5. Tool execution layer
- [ ] Phase 6. Single agent (Decanus only)
- [ ] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-2

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, turn/tool failure handling, tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Default `.contubernium/state.json` scaffold now includes structured failure state.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan.

## Architectural Decisions Already Made

1. Logging is a structured JSON run ledger in `.contubernium/logs/`, not ad hoc text dumps.
2. Error handling is now canonicalized as a structured runtime failure object with:
   - `error_code`
   - `message`
   - `context`
3. `runtime_session.last_error` remains in place as a compatibility surface for the current UI/state snapshot.
4. `runtime_session.last_failure` is the canonical structured failure record for phase 2 onward.
5. Failures are logged into runtime log events, not only shown in UI/state strings.
6. Phases 1-2 were kept inside runtime infrastructure only. They intentionally did not redesign the state manager, the loop, or the TUI.

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Avoid TUI-driven schema changes in phase 3. The state manager should lead; the UI should follow later.

## Phase 3 Target

Phase 3 is the `State manager` from [docs/FEATURES.md](docs/FEATURES.md):

- Track active mission
- Track current actor
- Track tool history
- Track intermediate results
- Store canonically in `.contubernium/state.json`

## What “Done” Means For Phase 3

Phase 3 is done when all of the following are true:

1. Runtime state ownership is explicit and centralized instead of being spread across ad hoc field mutations.
2. `.contubernium/state.json` is confirmed as the canonical state shape for:
   - mission
   - current actor
   - loop status
   - tool history
   - intermediate results
   - runtime session metadata
3. State transitions are represented through clear helpers/functions instead of incidental updates scattered across turns.
4. The current schema remains compatible with phase-1 logs and phase-2 structured failures.
5. Existing tests still pass, and new tests cover state initialization and key transition flows.
6. Phase 3 does not silently implement phase 4, 5, or 8 work.

## Suggested Phase 3 Approach

1. Inventory all state mutations in [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig).
2. Group them into state-manager responsibilities:
   - mission lifecycle
   - runtime session lifecycle
   - loop step transitions
   - invocation/task transitions
   - approval transitions
3. Introduce explicit state-manager helpers for those transitions.
4. Keep compatibility with the current snapshot/UI fields while consolidating write paths.
5. Add tests around initialization, blocked transitions, completion transitions, and approval transitions.

## Validation Commands

Run these after phase 3 changes:

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
feat(runtime): complete phases 1-2 logging and structured error handling
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 3 only.

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
- Do not redesign the TUI in phase 3.
- Keep `.contubernium/state.json` as canonical runtime state.

Task:
Implement phase 3, the state manager, and update FEATURES_CHECKLIST.md when done.
```
