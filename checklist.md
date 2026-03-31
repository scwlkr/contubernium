# Temporary Checklist

This file is a temporary memory aid after the modular runtime refactor.

## Verified

- Split the old `src/main.zig` monolith into:
  - `src/runtime_app.zig`
  - `src/runtime_core.zig`
  - `src/runtime_assets.zig`
  - `src/runtime_loop.zig`
  - `src/runtime_prompting.zig`
  - `src/runtime_provider.zig`
  - `src/runtime_tools.zig`
- Kept `src/main.zig` as the thin entrypoint.
- Fixed cross-module `RuntimeHooks` visibility so non-core modules can call:
  - `emit`
  - `isInterrupted`
  - `requestApproval`

## Follow Up

- [x] Reduce `src/runtime_app.zig` further by extracting:
  - mission composer
  - spinner
  - bridge / worker UI plumbing
  - CLI command dispatch targets
- [x] Reduce `src/runtime_core.zig` further by moving:
  - JSON parsing helpers
  - model JSON normalization helpers
  - pretty-print / parse ownership helpers
- [x] Revisit import alias noise created during the safe extraction pass.
- [x] Add a dedicated UI module for the extracted mission and bridge surface.
- [x] Add a dedicated serialization / model-json module.
- [x] Tighten mission prompt behavior so unassigned lanes do not look like active work.
- [x] Fix `decanus returned a blocked state` for unsupported-but-recoverable decanus action values.
- [x] Verify the runtime with `zig build test`, `zig build`, and a local mission smoke test.

## Safety Notes

- Do not treat this file as canonical project memory.
- Canonical project memory remains under `.contubernium/`.
- This file can be deleted after the follow-up pass is complete.
