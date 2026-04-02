# Memory Formats

## Purpose

This document defines the current on-disk compatibility rules for versioned session memory and the project-local global memory layer.

## Current Format Versions

- Project session index: `.contubernium/sessions/index.json` uses JSON `format_version: 1`
- Project session records: `.contubernium/sessions/<session-id>.json` use JSON `format_version: 1`
- Home session index: `~/.contubernium/session-index.json` uses JSON `format_version: 1`
- Project global memory: `.contubernium/global.md` starts with `<!-- contubernium:global-memory format_version=1 -->`

## Migration Rules

- Missing session `format_version` is treated as legacy v0 and normalized forward to v1 at load time.
- Missing global-memory version markers are treated as legacy v0 and normalized forward to the v1 marker at load time.
- The runtime writes only the current v1 formats when it scaffolds or persists memory.
- A stored version newer than the runtime's supported version is rejected intentionally instead of being guessed through.

## Compatibility Discipline

- New format versions must define an explicit migration path from the immediately previous format.
- Version bumps should stay additive when possible so older data can be normalized without losing meaning.
- Cross-project recall rules do not change with format migrations: project session payloads stay local, and the home session index remains metadata-only.

## Portability Notes

- Runtime path assembly should use `std.fs.path.join` instead of hard-coded `/` separators.
- Home resolution should honor `CONTUBERNIUM_HOME` first, then fall back to the platform home directory environment.
- The compiled `contubernium` CLI is the canonical bootstrap path for future platform expansion.
- `install.sh` and `init.sh` are Bash-oriented bootstrap helpers for macOS and Linux today.
- Runtime shell execution still goes through `sh -lc`; future Windows support should isolate that behind a platform-specific command adapter rather than spreading shell assumptions across the runtime.
