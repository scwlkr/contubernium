# Installation

## Global Install

From the repository root:

```bash
./install.sh
```

This does two things:

1. Builds the Zig CLI and installs `contubernium` into a user bin directory such as `~/.local/bin` or `~/bin`.
2. Syncs the global Contubernium home into `~/.contubernium/`.

Global home layout:

```text
~/.contubernium/
agents/
shared/
adapters/
templates/
global.md
source/        # managed checkout when install.sh clones for you
```

`~/.contubernium/templates/` contains the canonical bootstrap files used by the Bash fallback initializer:

- `session_index.json`
- `state.json`
- `config.json`
- `architecture.md`
- `plan.md`
- `project_context.md`
- `project.md`
- `global.md`

`~/.contubernium/global.md` is preserved across reinstalls so global memory is not overwritten silently.

## Project Initialization

Preferred path:

```bash
contubernium init
```

This creates the canonical project layout:

```text
.contubernium/
  state.json
  sessions/
    index.json
  ARCHITECTURE.md
  PLAN.md
  PROJECT_CONTEXT.md
  project.md
  global.md
  config.json
  logs/
```

`contubernium init` uses embedded assets from the built binary, so it does not need symlinks or a live source checkout to scaffold a project.
Session memory files use versioned JSON, and `global.md` carries a version marker comment. See [docs/MEMORY_FORMATS.md](/Users/shanewalker/Desktop/dev/Contubernium/docs/MEMORY_FORMATS.md) for the compatibility rules.

## Bash Fallback

If you want to initialize a project from a source checkout without using the compiled CLI:

```bash
./init.sh /path/to/project
```

`init.sh` uses the installed global home when it exists and falls back to the repository’s tracked `templates/` directory when it does not. Agent behavior always stays global.
`install.sh` and `init.sh` are Bash-oriented helpers for macOS and Linux today; the compiled CLI is the canonical path for future cross-platform bootstrap work.

## Recommended Verification

After installation and initialization:

```bash
contubernium doctor
```

Then confirm the local project contains:

- `.contubernium/state.json`
- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/config.json`
- `.contubernium/logs/`

## Upgrade Notes

- The canonical config path is `.contubernium/config.json`.
- The canonical mission state path is `.contubernium/state.json`.
- Legacy root-level state or config files should be retired in favor of the `.contubernium/` layout.
