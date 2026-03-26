# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `8. Then TUI`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [x] Phase 4. Basic agent loop (no agents yet)
- [x] Phase 5. Tool execution layer
- [x] Phase 6. Single agent (Decanus only)
- [x] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-7

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, centralized state-manager transitions, shared loop progression, typed tool mediation, timeout-aware command execution, phase-6 single-agent runtime guards, explicit project/global memory loading and prompt hookup, and focused runtime tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Embedded default config now includes project/global memory paths and memory-size bounds, plus default project/global memory scaffold files and phase-7 prompt guidance.
- [prompts/decanus.md](/Users/shanewalker/Desktop/dev/Contubernium/prompts/decanus.md)
  Repo prompt asset now instructs `decanus` to use external project/global memory while staying in the phase-7 Decanus-only loop.
- [prompts/shared/base.md](/Users/shanewalker/Desktop/dev/Contubernium/prompts/shared/base.md)
  Shared repo prompt rules now call project/global memory read-only context while keeping mission state canonical in `.contubernium/state.json`.
- [.contubernium/prompts/decanus.md](/Users/shanewalker/Desktop/dev/Contubernium/.contubernium/prompts/decanus.md)
  Active runtime prompt asset mirrors the phase-7 Decanus memory guidance.
- [.contubernium/prompts/shared/base.md](/Users/shanewalker/Desktop/dev/Contubernium/.contubernium/prompts/shared/base.md)
  Active runtime base prompt mirrors the phase-7 read-only memory guidance.
- [contubernium.config.json](/Users/shanewalker/Desktop/dev/Contubernium/contubernium.config.json)
  Repo config now exposes project/global memory file paths and bounded memory-context defaults alongside the existing runtime policy surface.
- [templates/contubernium.config.template.json](/Users/shanewalker/Desktop/dev/Contubernium/templates/contubernium.config.template.json)
  Template config now mirrors the phase-7 memory file paths and memory-size bounds.
- [.contubernium/config.json](/Users/shanewalker/Desktop/dev/Contubernium/.contubernium/config.json)
  Active runtime config now points the running workspace at the project/global memory layers and their phase-7 bounds.
- [.contubernium/project.md](/Users/shanewalker/Desktop/dev/Contubernium/.contubernium/project.md)
  Default project-memory scaffold now exists as a live runtime input.
- [.contubernium/global.md](/Users/shanewalker/Desktop/dev/Contubernium/.contubernium/global.md)
  Default global-memory scaffold now exists as a live runtime input.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan updated through phase 7.
- [PHASE_HANDOFF.md](/Users/shanewalker/Desktop/dev/Contubernium/PHASE_HANDOFF.md)
  Bootstrap guidance now hands the next thread off to phase 8 with phase-7 memory constraints recorded.

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
14. Phase 6 constrains active runtime execution to `decanus`; any attempt to execute a specialist turn now blocks with a structured `SINGLE_AGENT_RUNTIME_ONLY` failure.
15. Phase 6 keeps specialist task contracts, prompts, and invocation/state-manager helpers in place as future-facing surfaces rather than removing them.
16. Phase 6 narrows Decanus prompt/schema guidance to `finish`, `tool_request`, `ask_user`, or `blocked`, and rejects legacy `invoke_specialist` decisions at runtime.
17. Phase 7 loads project/global memory from configured file paths at prompt-build time rather than copying those external layers into `.contubernium/state.json`.
18. Phase 7 bounds external memory through dedicated context limits and logs memory-layer loading/truncation explicitly.
19. Phase 7 turns missing, invalid, or oversized memory-layer inputs into structured runtime failures instead of silent prompt omissions.

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Preserve the phase-5 typed tool mediation layer. Do not re-scatter tool validation or execution policy across actor-specific branches.
8. Preserve the phase-6 Decanus-only runtime guard. Do not silently reintroduce active specialist execution during phase 8.
9. Preserve the phase-7 external memory loading model. Do not fold project/global memory back into ad hoc state fields.
10. Avoid redesigning the engine, logging, or memory layers just to advance the TUI.

## Phase 8 Target

Phase 8 is the `Then TUI` step from [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md):

- Build the TUI on top of the now-complete runtime stack so the interface shows mission state, loop progress, tool activity, and approvals without redefining runtime behavior
- Reuse the structured state snapshots, structured logs, context-budget telemetry, and memory-aware prompt/runtime surfaces already in place
- Keep the TUI as an adapter over commander-first runtime execution in line with [AGENTS.md](AGENTS.md) and [docs/FEATURES.md](docs/FEATURES.md)

## What “Done” Means For Phase 8

Phase 8 is done when all of the following are true:

1. The TUI visibly reflects the canonical runtime state: active mission, current actor, loop step, tool activity, and key runtime status.
2. Operator input and approval handling stay mediated through the existing runtime layer instead of adding parallel UI-only execution paths.
3. Phase-1 through phase-7 logging, failures, memory hookup, and Decanus-only runtime control remain intact.
4. The TUI surfaces enough runtime context to make the commander loop observable without needing ad hoc debug prints.
5. Existing tests still pass, and any new tests focus on TUI rendering/event integration rather than reworking engine behavior.
6. Phase 8 does not silently reintroduce specialist execution as active runtime turns.

## Suggested Phase 8 Approach

1. Inventory the current legacy/vaxis TUI surfaces and compare them against the required Phase 8 views from [docs/FEATURES.md](docs/FEATURES.md).
2. Prefer wiring missing UI views to existing runtime events/state snapshots instead of inventing new runtime-specific UI state.
3. Reuse the phase-1 structured logs, phase-3/4 state-manager ownership, phase-5 tool mediation, phase-6 Decanus-only guard, and phase-7 memory/context telemetry as read-only UI inputs.
4. Add focused tests around TUI rendering/event handling where feasible, without redesigning runtime semantics.
5. Keep documentation/checklists aligned once phase 8 is complete.

## Validation Commands

Run these after phase 8 changes:

```bash
zig fmt src/main.zig src/embedded_assets.zig
zig build test
zig build run -- init
```

Optional runtime validation if a local model backend is available:

```bash
zig build run -- doctor
```

Optional interface validation:

```bash
zig build run -- ui --legacy
```

## Suggested Commit Message

```text
feat(runtime): complete phase 7 memory hookup
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 8 only.

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
- Preserve the phase-3 state-manager ownership, phase-4 shared loop-progression helpers, phase-5 typed tool mediation layer, phase-6 Decanus-only runtime guard, and phase-7 external memory loading model.
- Keep `.contubernium/state.json` as canonical runtime state.
- Do not fold project/global memory into ad hoc UI state.

Task:
Implement phase 8, the TUI step, and update the handoff/checklist artifacts when done.
```
