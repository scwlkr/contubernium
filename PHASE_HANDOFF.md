# Phase Handoff

This file is the bootstrap artifact for the next thread.

## Current Snapshot

- Current build order source: [FEATURES_CHECKLIST.md](FEATURES_CHECKLIST.md)
- Feature source of truth: [docs/FEATURES.md](docs/FEATURES.md)
- Phase 8 is complete.
- OpenTUI is now the canonical terminal interface.
- No follow-on phase is recorded in the checklist after phase 8.

## Completed Phases

- [x] Phase 1. Logging system
- [x] Phase 2. Error system
- [x] Phase 3. State manager
- [x] Phase 4. Basic agent loop (no agents yet)
- [x] Phase 5. Tool execution layer
- [x] Phase 6. Single agent (Decanus only)
- [x] Phase 7. Memory system hookup
- [x] Phase 8. OpenTUI

## Phase 8 Files Touched

- [src/main.zig](/Users/shanewalker/Desktop/dev/Contubernium/src/main.zig)
  Removed the legacy terminal renderer, added the OpenTUI launcher, added the `ui-bridge` JSON-lines adapter, kept the Decanus-first runtime loop authoritative, fixed bridge/runtime compatibility issues, and kept tests green.
- [build.zig](/Users/shanewalker/Desktop/dev/Contubernium/build.zig)
  Removed the `vaxis` dependency wiring.
- [build.zig.zon](/Users/shanewalker/Desktop/dev/Contubernium/build.zig.zon)
  Removed the `vaxis` dependency declaration.
- [install.sh](/Users/shanewalker/Desktop/dev/Contubernium/install.sh)
  Installs/syncs the bundled OpenTUI frontend into `~/.contubernium/opentui` and runs `bun install --frozen-lockfile`.
- [opentui/package.json](/Users/shanewalker/Desktop/dev/Contubernium/opentui/package.json)
  Declares the Bun/OpenTUI frontend dependencies and scripts.
- [opentui/tsconfig.json](/Users/shanewalker/Desktop/dev/Contubernium/opentui/tsconfig.json)
  TypeScript config for the frontend.
- [opentui/main.tsx](/Users/shanewalker/Desktop/dev/Contubernium/opentui/main.tsx)
  OpenTUI app that renders transcript/log panes, runtime rail, approvals, model selection, and slash-command input over the Zig bridge.
- [README.md](/Users/shanewalker/Desktop/dev/Contubernium/README.md)
  Runtime/interface docs now describe OpenTUI as the terminal interface.
- [FEATURES_CHECKLIST.md](/Users/shanewalker/Desktop/dev/Contubernium/FEATURES_CHECKLIST.md)
  Phase 8 is now marked complete with an OpenTUI-specific completion summary.
- [PHASE_HANDOFF.md](/Users/shanewalker/Desktop/dev/Contubernium/PHASE_HANDOFF.md)
  Updated to reflect the completed OpenTUI migration.

## Architectural Decisions Already Made

1. Logging remains a structured JSON run ledger in `.contubernium/logs/`.
2. Structured runtime failures remain canonical; `last_error` is still a compatibility surface.
3. `.contubernium/state.json` remains the canonical runtime state file.
4. The runtime loop remains commander-first and Decanus-only during active execution.
5. Project/global memory is still loaded from `.contubernium/project.md` and `.contubernium/global.md` at prompt-build time.
6. Zig remains the authoritative runtime and state owner.
7. `contubernium ui` now launches a Bun-based OpenTUI frontend instead of any in-process `vaxis` renderer.
8. The Zig binary exposes `contubernium ui-bridge`, which streams runtime snapshots and events to OpenTUI over newline-delimited JSON.
9. OpenTUI is an adapter over existing runtime state/events; it must not introduce a second execution path.
10. The legacy `vaxis` and ANSI renderer path has been removed and must not be reintroduced.
11. Installation now includes the bundled OpenTUI app and its Bun lockfile-backed dependency install.
12. `loadState` includes a minimal compatibility migration for legacy persisted optional-actor fields such as `"active_tool": ""`.

## Constraints That Must Not Be Broken

1. Preserve commander-first control from [AGENTS.md](AGENTS.md): `decanus` owns loop control and final decisions.
2. Keep tools mediated through the runtime layer. Do not let OpenTUI execute logic directly.
3. Keep structured JSON logs intact. Do not regress to plain-text runtime logging.
4. Keep structured failures intact. Do not collapse them back into plain strings.
5. Keep `.contubernium/state.json` as the canonical runtime state file.
6. Preserve the phase-5 typed tool mediation layer.
7. Preserve the phase-6 Decanus-only runtime guard.
8. Preserve the phase-7 external memory loading model.
9. Keep OpenTUI as the only terminal UI. Do not reintroduce `vaxis`, `--legacy`, or a parallel legacy renderer.
10. Avoid redesigning the engine, logging, or memory layers just to change the interface.

## Phase 8 Outcome

Phase 8 delivered:

- an OpenTUI frontend for transcript, structured run log, runtime rail, approvals, and model controls
- a Zig bridge layer that converts canonical runtime snapshots/events into frontend-friendly JSON lines
- an updated `contubernium ui` entrypoint that launches OpenTUI through Bun
- installation and documentation aligned around OpenTUI as the sole terminal interface

## Validation Commands

These passed in the current workspace:

```bash
zig fmt src/main.zig src/runtime_protocol.zig
zig build test
printf '{"type":"snapshot"}\n{"type":"exit"}\n' | zig build run -- ui-bridge
```

Interactive validation if Bun is available:

```bash
contubernium ui
```

Optional backend validation if a local model backend is available:

```bash
contubernium doctor
```

## Suggested Commit Message

```text
feat(ui): replace legacy tui with opentui
```

## Next Thread Bootstrap Prompt

```text
Continue Contubernium work from the post-phase-8 state.

Read:
- AGENTS.md
- docs/doctrine.md
- docs/agent-contracts.md
- docs/FEATURES.md
- FEATURES_CHECKLIST.md
- PHASE_HANDOFF.md

Constraints:
- Preserve commander-first runtime control.
- Preserve structured JSON logs and structured runtime failures.
- Preserve the phase-5 typed tool mediation layer.
- Preserve the phase-6 Decanus-only runtime guard.
- Preserve the phase-7 external memory loading model.
- Keep `.contubernium/state.json` canonical.
- Keep OpenTUI as the only terminal interface. Do not reintroduce `vaxis` or a legacy renderer path.

Task:
Implement the next requested feature or refinement without regressing the OpenTUI migration.
```
