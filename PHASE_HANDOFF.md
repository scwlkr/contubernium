# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `6. Single agent (Decanus only)`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [x] Phase 4. Basic agent loop (no agents yet)
- [x] Phase 5. Tool execution layer
- [ ] Phase 6. Single agent (Decanus only)
- [ ] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-5

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, centralized state-manager transitions, shared loop progression, typed tool mediation, timeout-aware command execution, and focused phase-5 tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Embedded default config now includes the runtime tool timeout policy surface used by phase 5.
- [contubernium.config.json](/Users/shanewalker/Desktop/dev/Contubernium/contubernium.config.json)
  Repo config now exposes the phase-5 `tool_timeout_ms` policy default.
- [templates/contubernium.config.template.json](/Users/shanewalker/Desktop/dev/Contubernium/templates/contubernium.config.template.json)
  Template config now mirrors the phase-5 tool timeout policy field.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan updated through phase 5.

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
11. Phase 5 introduced a typed runtime tool registry/spec surface in `src/main.zig` so lookup, approval policy, validation, and execution dispatch are mediated through one path.
12. Phase 5 made malformed tool input, workspace-path escapes, policy-blocked commands, operator denials, and command timeouts produce structured runtime failures instead of raw branch-local errors.
13. Phase 5 added `policy.tool_timeout_ms` to the config/default config surfaces and uses it for shell-backed runtime tool execution.

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Preserve the phase-5 typed tool mediation layer. Do not re-scatter tool validation or execution policy across actor-specific branches.
8. Avoid TUI-driven schema or memory-layer redesign in phase 6 unless the runtime layer requires it first.

## Phase 6 Target

Phase 6 is the `Single agent (Decanus only)` step from [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md):

- Tighten runtime behavior so the working loop targets `decanus` as the only active agent for this phase
- Keep specialists represented as contracts/prompts/config surfaces without letting phase 6 quietly turn into a multi-agent redesign
- Preserve the phase-5 tool execution layer while narrowing control flow toward the commander-first target described in [AGENTS.md](AGENTS.md)

## What “Done” Means For Phase 6

Phase 6 is done when all of the following are true:

1. Runtime mission execution operates within a Decanus-only target instead of depending on specialist turn execution for the core loop.
2. Commander-first control from [AGENTS.md](AGENTS.md) is clearer in runtime behavior without bypassing the existing state-manager helpers.
3. Phase-5 typed tool mediation remains intact and continues to own runtime side effects.
4. Structured logs, structured failures, and `.contubernium/state.json` remain canonical and compatible.
5. Existing tests still pass, and new tests cover the Decanus-only runtime behavior without silently implementing phase 7 or redesigning the TUI.
6. Phase 6 does not expand scope into external memory wiring or interface redesign.

## Suggested Phase 6 Approach

1. Inventory where the runtime still models specialist turns as active execution instead of commander-owned behavior.
2. Introduce the smallest clean change set that constrains the active runtime loop to Decanus while preserving agent contracts and prompts as future-facing surfaces.
3. Reuse the phase-3/4 state-manager helpers and the phase-5 tool mediation layer instead of adding new side-effect paths.
4. Add focused tests around the Decanus-only control-flow expectations.
5. Keep documentation/checklists aligned once phase 6 is complete.

## Validation Commands

Run these after phase 6 changes:

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
feat(runtime): complete phase 5 tool execution layer
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 6 only.

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
- Preserve the phase-3 state-manager ownership, phase-4 shared loop-progression helpers, and phase-5 typed tool mediation layer.
- Do not redesign the TUI in phase 6.
- Keep `.contubernium/state.json` as canonical runtime state.

Task:
Implement phase 6, the Decanus-only runtime step, and update the handoff/checklist artifacts when done.
```
