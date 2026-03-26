# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Next phase to implement: `7. Memory system hookup`

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [x] Phase 4. Basic agent loop (no agents yet)
- [x] Phase 5. Tool execution layer
- [x] Phase 6. Single agent (Decanus only)
- [ ] Phase 7. Memory system hookup
- [ ] Phase 8. TUI

## Files Touched By Phases 1-6

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Runtime logging ledger, structured failures, centralized state-manager transitions, shared loop progression, typed tool mediation, timeout-aware command execution, phase-6 single-agent runtime guards, and focused runtime tests.
- [src/embedded_assets.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/embedded_assets.zig)
  Embedded default config includes the phase-5 timeout policy surface, and embedded Decanus prompt/schema assets now default to phase-6 single-agent behavior.
- [prompts/decanus.md](/Users/shanewalker/Desktop/dev/Contubernium/prompts/decanus.md)
  Repo prompt asset now instructs `decanus` to stay in a Decanus-only runtime loop for phase 6.
- [prompts/shared/decanus-schema.json](/Users/shanewalker/Desktop/dev/Contubernium/prompts/shared/decanus-schema.json)
  Repo schema asset now narrows Decanus runtime decisions to `finish`, `tool_request`, `ask_user`, or `blocked` for phase 6.
- [contubernium.config.json](/Users/shanewalker/Desktop/dev/Contubernium/contubernium.config.json)
  Repo config now exposes the phase-5 `tool_timeout_ms` policy default.
- [templates/contubernium.config.template.json](/Users/shanewalker/Desktop/dev/Contubernium/templates/contubernium.config.template.json)
  Template config now mirrors the phase-5 tool timeout policy field.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Progress tracker and ordered build plan updated through phase 6.
- [PHASE_HANDOFF.md](/Users/shanewalker/Desktop/dev/Contubernium/PHASE_HANDOFF.md)
  Bootstrap guidance now hands the next thread off to phase 7 with phase-6 single-agent constraints recorded.

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

## Constraints That Must Not Be Broken

1. Preserve build order from [docs/FEATURES.md](docs/FEATURES.md) and [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md). Do not skip ahead.
2. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
3. Keep tools mediated through the runtime layer. Do not let agents execute logic directly.
4. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
5. Keep structured failures intact. Do not collapse phase-2 failures back into plain strings.
6. Keep `.contubernium/state.json` as the canonical runtime state file.
7. Preserve the phase-5 typed tool mediation layer. Do not re-scatter tool validation or execution policy across actor-specific branches.
8. Preserve the phase-6 Decanus-only runtime guard. Do not silently reintroduce active specialist execution during phase 7.
9. Avoid TUI-driven schema or memory-layer redesign in phase 7 unless the runtime layer requires it first.

## Phase 7 Target

Phase 7 is the `Memory system hookup` step from [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md):

- Wire the external memory layers into runtime execution: mission state stays in `.contubernium/state.json`, while project and global memory become available to prompt assembly and loop decisions
- Preserve the phase-6 single-agent runtime target so memory hookup strengthens Decanus-owned execution instead of reopening specialist turns
- Keep memory structured, explicit, and queryable in line with [AGENTS.md](AGENTS.md) and [docs/FEATURES.md](docs/FEATURES.md)

## What “Done” Means For Phase 7

Phase 7 is done when all of the following are true:

1. Runtime prompt assembly and loop decisions can read the external project/global memory layers without collapsing them into ad hoc state fields.
2. `.contubernium/state.json` remains the canonical mission/runtime state file while `.contubernium/project.md` and `.contubernium/global.md` become live inputs to execution.
3. Phase-5 typed tool mediation and phase-6 Decanus-only control remain intact.
4. Structured logs and structured failures remain canonical and compatible.
5. Existing tests still pass, and new tests cover memory loading/hookup behavior without redesigning the TUI.
6. Phase 7 does not quietly reintroduce specialist execution as active runtime turns.

## Suggested Phase 7 Approach

1. Inventory the current memory files, prompt builders, and any config/state surfaces that should expose project/global memory to Decanus.
2. Introduce the smallest clean runtime layer that loads and bounds project/global memory before prompt assembly.
3. Reuse the phase-3/4 state-manager helpers, the phase-5 tool mediation layer, and the phase-6 single-agent runtime guard instead of adding new side-effect paths.
4. Add focused tests around memory loading, prompt inclusion, and failure handling for missing or oversized memory inputs.
5. Keep documentation/checklists aligned once phase 7 is complete.

## Validation Commands

Run these after phase 7 changes:

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
feat(runtime): complete phase 6 single-agent loop
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium feature work from phase 7 only.

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
- Preserve the phase-3 state-manager ownership, phase-4 shared loop-progression helpers, phase-5 typed tool mediation layer, and phase-6 Decanus-only runtime guard.
- Do not redesign the TUI in phase 7.
- Keep `.contubernium/state.json` as canonical runtime state.

Task:
Implement phase 7, the memory system hookup step, and update the handoff/checklist artifacts when done.
```
