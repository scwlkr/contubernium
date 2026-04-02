# Contubernium User Manual

## Purpose

This manual is the operator-facing record of shipped behavior.

Under the Constitution, every shipped feature change must update this file with:

- the user-visible behavior
- required setup or commands
- the test coverage that verifies the behavior

This file is a baseline scaffold. It should grow as constitutional alignment work lands.
The `Feature And Test Ledger` section is the canonical place to record the verifying test reference for each shipped feature.

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
- installs the fallback template set, including the session index template used by `init.sh`

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
- `contubernium sessions list [project-root]`
- `contubernium sessions show <session-id> [project-root]`
- `contubernium sessions resume <session-id> [project-root]`
- `contubernium sessions approvals <on|off>`

## OpenTUI

Current shipped behavior:

- `Esc`, `/exit`, and `/quit` tear down the OpenTUI renderer before the process exits
- terminal state is restored on those exits, including mouse tracking cleanup

## Provider Configuration

Current shipped behavior:

- `.contubernium/config.json` uses a `model_policy` object with `primary`, `escalation`, and `fallback` routes
- the default strategy is `smallest-capable`
- the runtime starts from `model_policy.primary`, can escalate when prompt pressure or repair retries cross the configured thresholds, and can fail over to `model_policy.fallback` when the active provider/model fails
- `openrouter` is a first-class provider type built on the OpenAI-compatible transport path
- older configs that still carry top-level `provider` and `fallback_provider` fields are still read, but new scaffolds write `model_policy`

Local-only mode:

- keep `model_policy.primary.type = "ollama-native"`
- leave `model_policy.fallback.enabled = false`
- optionally point `model_policy.escalation` at a larger local Ollama model

Cloud-enabled mode:

- set `model_policy.fallback.type = "openrouter"`
- export `OPENROUTER_API_KEY`
- optionally set `site_url` and `app_name` in the fallback route to send OpenRouter attribution headers

Operator notes:

- `contubernium models` lists models from the primary route provider
- `/model <name>` updates the primary route model selection
- run logs capture the active provider/model per turn, plus route role and route reason when policy routing is involved

## Mission Loop

The current loop is:

`Think -> Tool -> Result -> Think -> Finish`

Current guarantees:

- `decanus` is the sole orchestrator
- specialists return structured results
- guarded shell and write actions require approval by default

## Approvals And Safety

Current approval behavior:

- runtime tools publish formal `Read` / `Write` / `Execute` contracts in `docs/RUNTIME_TOOL_CONTRACTS.md`
- read tools can run automatically when session policy allows it
- writes require approval by default
- shell commands require approval by default
- blocked command patterns fail immediately
- failures surface canonical `code` / `cause` fields plus contextual metadata
- `contubernium sessions approvals on|off` can enable or disable session-scoped approval bypass without changing project config defaults

Current constitutional gap:

- none in the shipped approval and session-policy surface

## Memory And Logs

Current local project files:

- `.contubernium/state.json`
- `.contubernium/config.json`
- `.contubernium/sessions/index.json`
- `.contubernium/sessions/<session-id>.json`
- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/logs/`

Current behavior:

- mission state is stored in `state.json`
- run logs are written as structured JSON under `.contubernium/logs/`
- durable session records are written under `.contubernium/sessions/`
- session indexes and session records are written as `format_version: 1` JSON
- `global.md` starts with `<!-- contubernium:global-memory format_version=1 -->`
- legacy unversioned session/global-memory files are normalized forward at load time
- newer unknown memory-format versions are rejected until the runtime is upgraded
- the current project keeps the canonical session payload; the home-level `~/.contubernium/session-index.json` stores lightweight session metadata only
- `contubernium sessions list` and `contubernium sessions show` inspect stored sessions intentionally
- `contubernium sessions resume` restores a stored session snapshot and continues it
- cross-project recall stays blocked by default; operators must pass an explicit project root to inspect or resume another project's sessions
- session approval bypass defaults to off for each new session
- each run log stores the primary model policy metadata at the top level
- each log event stores the active provider/model and, when applicable, the model-policy role and reason
- prompt context is condensed when the context budget gets tight

Portability note:

- `CONTUBERNIUM_HOME` is honored before platform home-directory fallbacks
- the Bash bootstrap helpers target macOS/Linux today
- runtime shell execution still uses `sh -lc`, so the compiled CLI is the canonical path as future Windows support is added
- detailed compatibility notes live in [docs/MEMORY_FORMATS.md](/Users/shanewalker/Desktop/dev/Contubernium/docs/MEMORY_FORMATS.md)

## Feature And Test Ledger

Every shipped behavior change must add or update a row in this table.
The `Current verification` column is the canonical place to record the test file and test name that verify the behavior.
If behavior changes and no row changes here, the feature is not documented completely.

| Feature | User-facing behavior | Current verification |
| --- | --- | --- |
| Project scaffold | `contubernium init` creates the canonical local `.contubernium/` runtime files. | `src/runtime_app.zig` test: `scaffoldProject creates canonical runtime and context assets` |
| Mission reset | Starting a mission resets the canonical mission state and loop surfaces. | `src/runtime_app.zig` test: `resetStateForMission resets canonical phase 3 state surfaces` |
| Approval gating | Guarded writes and shell actions are mediated through approval state. | `src/runtime_app.zig` tests: `approval transitions update canonical state ownership`; `executeToolRequests records approval denials through the mediated write_file path` |
| Session approval bypass | `contubernium sessions approvals on|off` changes approval bypass for the active session only. | `src/runtime_app.zig` test: `executeToolRequests honors session approval bypass for guarded tools`; `src/cli.zig` test: `parse requires a mode for sessions approvals` |
| Tool validation | Invalid or blocked tool requests produce structured failures instead of silent execution. | `src/runtime_app.zig` tests: `executeToolRequests blocks policy-denied commands with structured failure state`; `executeToolRequests converts malformed read_file requests into structured failures` |
| Structured run logs | Runtime events are written into structured JSON run logs. | `src/runtime_app.zig` test: `runtime run log stores structured events` |
| Durable sessions | Every mission conversation writes a canonical session record plus project-local and home-level session index metadata. | `src/runtime_app.zig` test: `persistSessionMemory writes durable local and global session indexes` |
| Memory format migration | Legacy unversioned session/global-memory files are normalized to the current format, and newer unknown versions are rejected explicitly. | `src/runtime_app.zig` tests: `loadSessionIndex migrates legacy unversioned format to the current version`; `loadSessionRecord migrates legacy unversioned format to the current version`; `loadGlobalSessionIndex rejects unsupported future format versions`; `normalizeGlobalMemoryMarkdown adds a version marker and strips it for prompt use` |
| Session retrieval | Operators can list, inspect, and target stored sessions deliberately, including explicit cross-project roots. | `src/cli.zig` tests: `parse routes sessions subcommands with optional project roots`; `parse requires a session id for sessions show` |
| OpenTUI exit cleanup | `Esc`, `/exit`, and `/quit` restore terminal state before leaving OpenTUI. | `opentui/exit.test.ts` test: `requestOpenTuiExit sends bridge exit before shutdown` |
| Model policy config | Project config uses `model_policy` routes and mirrors them onto legacy provider fields for compatibility. | `src/runtime_app.zig` test: `loadConfig mirrors model_policy routes into legacy provider fields` |
| Model policy log metadata | Each run log stores primary route metadata, escalation metadata, and fallback metadata. | `src/runtime_app.zig` test: `initializeRuntimeRunLog stores model policy metadata` |
| Active routed provider visibility | Status snapshots show the currently active provider/model when the runtime switches routes. | `src/runtime_app.zig` test: `snapshotFromState prefers the active routed provider over the primary config` |
| Context compression | Older history can be condensed into a retained digest when context pressure rises. | `src/runtime_app.zig` test: `condenseHistoryForContext replaces older entries with a retained digest` |
| Prompt assembly | Commander prompts include project context and loaded memory layers. | `src/runtime_app.zig` test: `buildDecanusUserPrompt includes project context and memory layers` |

## Manual Update Rule

When a feature changes:

1. add or update the test first
2. implement the behavior
3. update the affected operator-facing section in this manual when commands, setup, or behavior changed
4. add or update the matching `Feature And Test Ledger` row with the current test reference

If a change cannot be described here, the feature is not documented well enough yet.
