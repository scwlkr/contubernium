# Features Checklist

This checklist tracks implementation progress against [FEATURES.md](docs/FEATURES.md).

## Build Order

- [x] 1. Logging system
- [x] 2. Error system
- [ ] 3. State manager
- [ ] 4. Basic agent loop (no agents yet)
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
- [ ] Phase 3: audit and refine canonical state-manager ownership against `state.json`
- [ ] Phase 4: isolate and confirm the basic agent loop independently from specialist behavior
- [ ] Phase 5: tighten the tool execution layer around typed mediation and validation
- [ ] Phase 6: constrain execution to Decanus-only behavior where later-phase logic currently reaches beyond that target
- [ ] Phase 7: hook the external memory layers fully into the runtime flow
- [ ] Phase 8: refine the TUI only after the underlying runtime stack is confirmed
