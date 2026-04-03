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
- transcript cards render markdown-lite structure for headings, paragraphs, lists, blank lines, and fenced code blocks
- `stream_start` creates a temporary `thinking...` placeholder card, and `stream_finalize` either replaces that placeholder or appends a titled live summary card when the runtime emits a structured summary without an active placeholder
- raw streaming thinking/content chunks stay out of transcript bodies; JSON-highlighted entries remain verbatim

## Provider Configuration

Current shipped behavior:

- `.contubernium/config.json` uses a `model_policy` object with `primary`, `escalation`, and `fallback` routes
- `model_policy` may also carry a `registry` of local model entries with capability tags and size/context metadata
- the default strategy is `smallest-capable`
- the runtime starts from the smallest capable registry model when `model_policy.registry` is populated, otherwise from `model_policy.primary`
- the runtime can escalate to the next larger capable registry model when prompt pressure or repair retries cross the configured thresholds, and can fail over to `model_policy.fallback` or another registry entry when the active provider/model fails
- `openrouter` is a first-class provider type built on the OpenAI-compatible transport path
- `llama.cpp` is a first-class local provider type built on the OpenAI-compatible transport path exposed by the llama.cpp server
- older configs that still carry top-level `provider` and `fallback_provider` fields are still read, but new scaffolds write `model_policy`

Local-only mode:

- keep `model_policy.primary.type = "ollama-native"`
- leave `model_policy.fallback.enabled = false`
- optionally point `model_policy.escalation` at a larger local Ollama model

Local llama.cpp mode:

- set `model_policy.primary.type = "llama.cpp"`
- point `base_url` at the local llama.cpp server root, for example `http://127.0.0.1:8080`
- add Gemma routes to `model_policy.registry` with capability tags such as `structured-output`, `analysis`, `tool-use`, `orchestration`, and `coding`
- keep fallback local. If fallback shares the same llama.cpp daemon, it protects against model-level failures but not daemon outage. Use a second local endpoint when daemon-level fallback matters.

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
- specialists may request published runtime tools inside a bounded subordinate loop while working the assigned objective
- runtime tool results return to the same specialist until that invocation completes or blocks; specialists do not invoke other specialists directly
- active specialist handoffs persist subordinate tool-loop status, cycle count, and last request/result summaries under `tasks.<lane>.invocation.tool_loop`, and run logs record explicit subordinate-loop events
- guarded shell and write actions require approval by default unless the active session is in explicit operator-consented approval bypass
- greeting-only mission openers stay in the same mission and ask a direct follow-up instead of completing immediately
- plain-language project-summary questions such as `what does this project do?` are answered from the already-loaded project and global memory when that context is sufficient, instead of forcing extra clarification or a broad repository scan
- when a TTY mission run completes successfully, `contubernium mission`, `contubernium mission start`, `contubernium mission continue`, and `contubernium sessions resume` keep the same session alive and offer an inline `reply >` follow-up prompt instead of dropping immediately back to the shell
- when a TTY mission run blocks on `USER_INPUT_REQUIRED`, `contubernium mission`, `contubernium mission start`, `contubernium mission continue`, and `contubernium sessions resume` show an `awaiting your command` follow-up block with a highlighted question and inline `reply >` prompt instead of dropping immediately back to the shell
- inline `reply >` prompts in the plain CLI treat `/exit` and `/quit` as control commands that leave the conversation without sending those tokens back through `decanus`
- active mission sessions are chat-first: the latest non-empty follow-up reply becomes the active current goal for the next Decanus turn, while the initial prompt stays as session provenance
- commander prompts foreground the active ask and latest operator reply before loading architecture, plan, and memory layers as background evidence
- read-only exploratory follow-ups can be scoped by `decanus` without forcing the operator to choose harmless prioritization details first
- operator-invited brainstorming or “take this to the next level” exploration can be answered directly from current evidence and clearly labeled inference without reflexively bouncing the scope back to the operator
- pressing `Enter` on an empty inline reply leaves the mission blocked so it can be resumed later
- the plain CLI spinner shows a short rolling thinking preview for streaming `ollama-native` model runs while the model is active, clips the preview to the current terminal width, and keeps it on a single status line
- the plain CLI also prints incremental structured `thinking summary` entries during execution as decisions, runtime-tool results, and specialist results land, then still includes the bounded summary trail in the final mission outcome view
- plain mission output wraps markdown-lite prose on word boundaries, preserves headings/lists/fenced code blocks, and keeps list hanging indents intact
- mission outcome views insert a bounded `thinking summary` section between the active ask/session seed and the final response, question, error, or status block
- `thinking summary` only shows persisted structured summaries from parsed decisions, specialist results, runtime tool results, and invocation results; raw streaming thought/content text is not persisted into operator-facing mission transcripts

## Approvals And Safety

Current approval behavior:

- runtime tools publish formal `Read` / `Write` / `Execute` contracts in `docs/RUNTIME_TOOL_CONTRACTS.md`
- read tools can run automatically when session policy allows it
- writes require approval by default
- shell commands require approval by default
- `contubernium sessions approvals on|off` switches the active session between guarded approval mode and operator-consented `session-bypass` mode for guarded runtime tools
- approval bypass is off by default for each new session, affects only the active session, and does not change project config defaults
- approval bypass state is surfaced in session records and the active approval mode is recorded in run logs
- blocked command patterns fail immediately
- root `search_text` requests include canonical hidden `.contubernium` context while pruning logs, sessions, caches, and vendored directories so evidence gathering stays bounded
- failures surface canonical `code` / `cause` fields plus contextual metadata

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
- session records store both `approval_mode` and `approval_bypass_enabled`
- each run log stores the primary model policy metadata at the top level
- each run log stores the active approval mode at the top level
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
| Approval gating | Guarded writes and shell actions are mediated through approval state unless the active session is already in operator-consented bypass mode. | `src/runtime_app.zig` tests: `approval transitions update canonical state ownership`; `executeToolRequests records approval denials through the mediated write_file path` |
| Session approval bypass | `contubernium sessions approvals on|off` enables or disables operator-consented approval bypass for guarded runtime tools in the active session only. | `src/runtime_app.zig` test: `executeToolRequests honors session approval bypass for guarded tools`; `src/cli.zig` test: `parse requires a mode for sessions approvals` |
| Tool validation | Invalid or blocked tool requests produce structured failures instead of silent execution. | `src/runtime_app.zig` tests: `executeToolRequests blocks policy-denied commands with structured failure state`; `executeToolRequests converts malformed read_file requests into structured failures` |
| Specialist subordinate tool loop | Active specialist handoffs persist bounded subordinate tool-loop state in canonical mission state, and specialist prompts/logs surface the last request/result before control returns to `decanus`. | `src/runtime_app.zig` tests: `specialist runtime tool results keep subordinate loop state explicit`; `invocation loop transitions keep shared state and history aligned`; `buildSpecialistUserPrompt surfaces the subordinate tool loop contract` |
| Structured run logs | Runtime events are written into structured JSON run logs. | `src/runtime_app.zig` test: `runtime run log stores structured events` |
| Durable sessions | Every mission conversation writes a canonical session record plus project-local and home-level session index metadata. | `src/runtime_app.zig` test: `persistSessionMemory writes durable local and global session indexes` |
| Memory format migration | Legacy unversioned session/global-memory files are normalized to the current format, and newer unknown versions are rejected explicitly. | `src/runtime_app.zig` tests: `loadSessionIndex migrates legacy unversioned format to the current version`; `loadSessionRecord migrates legacy unversioned format to the current version`; `loadGlobalSessionIndex rejects unsupported future format versions`; `normalizeGlobalMemoryMarkdown adds a version marker and strips it for prompt use` |
| Session retrieval | Operators can list, inspect, and target stored sessions deliberately, including explicit cross-project roots. | `src/cli.zig` tests: `parse routes sessions subcommands with optional project roots`; `parse requires a session id for sessions show` |
| OpenTUI exit cleanup | `Esc`, `/exit`, and `/quit` restore terminal state before leaving OpenTUI. | `opentui/exit.test.ts` test: `requestOpenTuiExit sends bridge exit before shutdown` |
| Model policy config | Project config uses `model_policy` routes and mirrors them onto legacy provider fields for compatibility. | `src/runtime_app.zig` test: `loadConfig mirrors model_policy routes into legacy provider fields` |
| Model policy log metadata | Each run log stores primary route metadata, escalation metadata, and fallback metadata. | `src/runtime_app.zig` test: `initializeRuntimeRunLog stores model policy metadata` |
| Active routed provider visibility | Status snapshots show the currently active provider/model when the runtime switches routes. | `src/runtime_app.zig` test: `snapshotFromState prefers the active routed provider over the primary config` |
| llama.cpp provider transport | Local llama.cpp servers are addressable as a first-class provider type through the OpenAI-compatible transport path. | `src/runtime_app.zig` tests: `providerUsesOpenAICompatibleTransport recognizes llama.cpp`; `structuredChatWithRepair resolves llama.cpp registry route for smoke response` |
| Capability-based local model resolver | Registry-backed local routes pick the smallest capable model for the active actor and choose alternate local routes for fallback. | `src/runtime_app.zig` tests: `initialModelRouteForActor resolves the smallest capable registry model per actor`; `fallbackRouteForActor selects an alternate registry model when explicit fallback is absent` |
| Context compression | Older history can be condensed into a retained digest when context pressure rises. | `src/runtime_app.zig` test: `condenseHistoryForContext replaces older entries with a retained digest` |
| Prompt assembly | Commander prompts foreground the active ask and latest operator turn while still loading project context and memory layers as background evidence. | `src/runtime_app.zig` tests: `buildDecanusUserPrompt includes project context and memory layers`; `buildDecanusUserPrompt foregrounds the latest operator turn ahead of background evidence` |
| Project summary from memory | Plain-language project-summary prompts are guided to answer from loaded memory before broad exploration. | `src/runtime_app.zig` test: `buildDecanusUserPrompt includes project context and memory layers` |
| Exploratory mission replies | Read-only brainstorming and “next level” exploration can be answered directly from loaded evidence plus clearly marked inference instead of being bounced back for narrower scoping. | `src/runtime_app.zig` tests: `buildDecanusUserPrompt includes project context and memory layers`; `buildDecanusUserPrompt keeps greeting-only mission intake in follow-up mode` |
| Greeting-only mission intake | A greeting like `hello` keeps the mission open and asks what the operator wants to do next instead of completing immediately. | `src/runtime_app.zig` test: `buildDecanusUserPrompt keeps greeting-only mission intake in follow-up mode` |
| Inline post-completion follow-up | Completed TTY mission runs keep the same session alive for the next prompt instead of exiting immediately to the shell, and mission output foregrounds the active follow-up ask instead of the original session seed. | `src/runtime_app.zig` test: `resumeAfterOperatorReply clears stale completion state`; `src/runtime_ui.zig` tests: `completedMissionFollowUpAvailable detects completed conversational state`; `renderCliMissionOutcome foregrounds the active ask after a follow-up`; `parseInlineUserReplyCommand recognizes exit commands` |
| Inline mission follow-up | TTY mission resumes prompt for operator clarification inline, labels the blocked state as `awaiting your command`, highlights the pending question, keeps the same mission state alive after `USER_INPUT_REQUIRED`, leaves empty inline replies from changing the active ask, and treats `/exit` and `/quit` as control commands instead of mission text. | `src/runtime_app.zig` tests: `resumeAfterOperatorReply clears the blocked state and records operator history`; `resumeAfterOperatorReply ignores empty replies`; `src/runtime_ui.zig` tests: `renderCliMissionOutcome labels follow-up questions as awaiting your command`; `renderInlineUserReplyPrompt highlights the pending question`; `parseInlineUserReplyCommand recognizes exit commands` |
| Mission markdown output | Plain mission output wraps markdown-lite prose on word boundaries, preserves headings/lists/fenced code, and keeps hanging indents inside mission sections. | `src/runtime_ui.zig` tests: `renderCliMarkdownLiteSection wraps prose without splitting words`; `renderCliMarkdownLiteSection preserves headings lists blank lines and fenced code` |
| Mission thinking summary | Mission outcome views show a bounded structured `thinking summary` trail before the final response/question/error, follow-up replies clear stale summaries before the next ask, and the plain CLI can render titled live summary entries during execution before the final outcome lands. | `src/runtime_ui.zig` tests: `renderCliMissionOutcome labels follow-up questions as awaiting your command`; `renderCliMissionOutcome foregrounds the active ask after a follow-up`; `renderCliLiveThinkingSummary formats titled summary entries`; `src/runtime_app.zig` test: `resumeAfterOperatorReply clears stale intermediate summaries for the next ask` |
| OpenTUI transcript formatting | OpenTUI transcript cards render markdown-lite bodies, keep JSON blocks verbatim, replace the temporary thinking placeholder with the final summary, append titled live summary cards when no placeholder is active, and ignore raw streaming chunks. | `opentui/transcript.test.ts` tests: `markdown-lite formatting preserves list indentation and fenced code at narrow widths`; `stream_start placeholder is replaced by stream_finalize summary`; `stream_finalize without a placeholder appends a titled summary card`; `raw thinking and content chunks do not append transcript card bodies`; `json highlight entries render verbatim` |
| Root search pruning | Workspace-root `search_text` requests search hidden Contubernium context while pruning runtime noise and truncating hit output. | `src/runtime_app.zig` tests: `searchText includes hidden project context while pruning runtime noise`; `searchText truncates root-search hits to the configured limit` |
| Streaming thinking preview | Streaming Ollama runs enable provider thinking and surface a bounded rolling live preview before the final structured result lands, clipped to the active terminal width so the CLI status line does not wrap repeatedly. | `src/runtime_app.zig` tests: `buildOllamaChatBody preserves structured output settings across stream modes`; `processOllamaPendingLines emits bounded thinking chunks separately from content`; `src/runtime_ui.zig` tests: `appendSpinnerPreview normalizes whitespace and keeps a rolling tail`; `visibleSpinnerPreview fits the terminal budget` |

## Manual Update Rule

When a feature changes:

1. add or update the test first
2. implement the behavior
3. update the affected operator-facing section in this manual when commands, setup, or behavior changed
4. add or update the matching `Feature And Test Ledger` row with the current test reference

If a change cannot be described here, the feature is not documented well enough yet.
