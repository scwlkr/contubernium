# Contubernium User Manual

## Purpose

This manual is the operator-facing record of shipped behavior.

Under the Constitution, every feature change should update this file with:

- the user-visible behavior
- required setup or commands
- the test coverage that verifies the behavior

This file is a baseline scaffold. It should grow as constitutional alignment work lands.

## Installation

Primary install flow:

```bash
git clone https://github.com/scwlkr/contubernium.git
cd contubernium
./install.sh
```

What this does today:

- builds the Zig binary
- installs `contubernium` into a user bin directory
- syncs global Contubernium assets into `~/.contubernium/`

Project initialization:

```bash
contubernium init
```

Fallback project bootstrap from a source checkout:

```bash
./init.sh /path/to/project
```

## Current Runtime Commands

Available commands:

- `contubernium`
- `contubernium ui`
- `contubernium init`
- `contubernium doctor`
- `contubernium models`
- `contubernium mission`
- `contubernium mission start "<prompt>"`
- `contubernium mission step`
- `contubernium mission continue`

## Provider Configuration

Current shipped behavior:

- primary local provider: `ollama-native`
- alternate generic provider: `openai-compatible`

Current constitutional gap:

- OpenRouter-specific configuration and routing are not yet first-class in the runtime
- dynamic smallest-capable model selection is not yet implemented
- automatic fallback execution is not yet implemented

Until that work lands, update `.contubernium/config.json` manually for provider/model changes.

## Mission Loop

The current loop is:

`Think -> Tool -> Result -> Think -> Finish`

Current guarantees:

- `decanus` is the sole orchestrator
- specialists return structured results
- guarded shell and write actions require approval by default

## Approvals And Safety

Current approval behavior:

- read tools can run automatically
- writes require approval
- shell commands require approval
- blocked command patterns fail immediately

Current constitutional gap:

- explicit operator consent to bypass approvals is not yet fully modeled
- permissions are not yet published as a formal `Read` / `Write` / `Execute` contract per tool

## Memory And Logs

Current local project files:

- `.contubernium/state.json`
- `.contubernium/config.json`
- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/logs/`

Current behavior:

- mission state is stored in `state.json`
- run logs are written as structured JSON under `.contubernium/logs/`
- prompt context is condensed when the context budget gets tight

Current constitutional gap:

- sessions are logged per run, but not yet exposed as durable session memory with retrieval and resume commands

## Feature And Test Ledger

This section should be updated whenever behavior changes.

| Feature | User-facing behavior | Current verification |
| --- | --- | --- |
| Project scaffold | `contubernium init` creates the canonical local `.contubernium/` runtime files. | `src/runtime_app.zig` test: `scaffoldProject creates canonical runtime and context assets` |
| Mission reset | Starting a mission resets the canonical mission state and loop surfaces. | `src/runtime_app.zig` test: `resetStateForMission resets canonical phase 3 state surfaces` |
| Approval gating | Guarded writes and shell actions are mediated through approval state. | `src/runtime_app.zig` tests: `approval transitions update canonical state ownership`; `executeToolRequests records approval denials through the mediated write_file path` |
| Tool validation | Invalid or blocked tool requests produce structured failures instead of silent execution. | `src/runtime_app.zig` tests: `executeToolRequests blocks policy-denied commands with structured failure state`; `executeToolRequests converts malformed read_file requests into structured failures` |
| Structured run logs | Runtime events are written into structured JSON run logs. | `src/runtime_app.zig` test: `runtime run log stores structured events` |
| Context compression | Older history can be condensed into a retained digest when context pressure rises. | `src/runtime_app.zig` test: `condenseHistoryForContext replaces older entries with a retained digest` |
| Prompt assembly | Commander prompts include project context and loaded memory layers. | `src/runtime_app.zig` test: `buildDecanusUserPrompt includes project context and memory layers` |

## Manual Update Rule

When a feature changes:

1. add or update the test first
2. implement the behavior
3. update this manual with the new behavior and the test reference

If a change cannot be described here, the feature is not documented well enough yet.
