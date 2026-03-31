# Local LLM Runtime Specification

> Historical planning note:
> This spec predates the global-agent architecture.
> The current runtime loads global agent assets and project-local context files rather than copying prompts or local agent definitions into each project.

## Purpose

This document defines the runtime contract for executing the Contubernium protocol against a local model backend.

## CLI Surface

The Zig executable is named `contubernium`.

Supported commands:

- `contubernium init`
- `contubernium doctor`
- `contubernium models`
- `contubernium mission start "<mission>"`
- `contubernium mission step`
- `contubernium mission continue`
- `contubernium ui`
- `contubernium`

### Command Behavior

`init`
- Creates `.contubernium/config.json` if missing.
- Creates `.contubernium/state.json` if missing.
- Creates `.contubernium/project.md` if missing.
- Creates `.contubernium/global.md` if missing.
- Creates `.contubernium/prompts/` from embedded assets if missing.
- Creates `.contubernium/logs/` if missing.
- Creates `.agents/` from embedded agent assets if missing.

`doctor`
- Auto-scaffolds `.contubernium/` if it is missing.
- Loads config and state.
- Verifies prompt assets.
- Verifies backend reachability.
- Verifies configured model availability.
- Runs a structured-output smoke test.

`models`
- Auto-scaffolds `.contubernium/` if it is missing.
- Queries the active provider and prints the model identifiers it can serve.

`mission start`
- Sets the mission prompt if supplied.
- Initializes `runtime_session`.
- Executes turns until the run finishes or blocks.

`mission step`
- Auto-scaffolds `.contubernium/` if it is missing.
- Executes exactly one actor turn.

`mission continue`
- Auto-scaffolds `.contubernium/` if it is missing.
- Continues execution from the current state and runtime session.

`ui`
- Starts the full-screen Roman-styled terminal UI in the current project.
- Auto-scaffolds `.contubernium/` if it is missing.
- Runs an OpenTUI frontend backed by a Zig `ui-bridge` process so the interface remains interactive while a mission is executing.
- Streams Ollama chat output chunk-by-chunk into the mission log.
- Shows live mission context from `.contubernium/state.json` in the OpenTUI header, transcript, and side rail.
- Supports slash commands for model discovery and model switching.
- Supports inline approval prompts for guarded writes and shell actions.

`contubernium` with no args
- Starts the same interactive UI as `contubernium ui`.

### OpenTUI Slash Commands

- `/doctor`
- `/models`
- `/model <n|name>`
- `/status`
- `/resume`
- `/interrupt`
- `/clear`
- `/exit`

### OpenTUI Keyboard Controls

- `Enter` submits the active input line.
- `Ctrl+R` resumes the active mission loop.
- `Ctrl+D` runs `doctor` when no approval prompt is active.
- `Ctrl+M` refreshes the model roster.
- `Ctrl+L` switches between the live transcript and structured run log views.
- `Ctrl+C` interrupts the active loop when idle.
- `Ctrl+A` approves the active approval prompt.
- `Ctrl+D` denies the active approval prompt when an approval prompt is active.
- `Esc` exits OpenTUI.

## File Layout

- `.contubernium/state.json`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/config.json`
- `.contubernium/prompts/`
- `.contubernium/logs/`
- `.agents/AGENT_LOOP.md`
- `.agents/<agent>/SOUL.md`
- `.agents/<agent>/CONTRACT.md`
- `.agents/<agent>/SKILL.md`
- `docs/`

## Runtime Config Shape

```json
{
  "runtime_version": 1,
  "provider": {
    "enabled": true,
    "type": "ollama-native",
    "base_url": "http://127.0.0.1:11434",
    "model": "qwen2.5-coder:7b",
    "timeout_ms": 120000,
    "max_retries": 2,
    "structured_output": "json"
  },
  "fallback_provider": {
    "enabled": false,
    "type": "openai-compatible",
    "base_url": "http://127.0.0.1:8000",
    "model": "",
    "timeout_ms": 120000
  },
  "paths": {
    "state_file": ".contubernium/state.json",
    "prompts_dir": ".contubernium/prompts",
    "logs_dir": ".contubernium/logs",
    "project_memory_file": ".contubernium/project.md",
    "global_memory_file": ".contubernium/global.md"
  },
  "policy": {
    "approval_mode": "guarded",
    "allow_read_tools_without_confirmation": true,
    "allow_workspace_writes_without_confirmation": false,
    "allow_shell_without_confirmation": false,
    "tool_timeout_ms": 120000,
    "blocked_command_patterns": [
      "rm -rf",
      "git reset --hard"
    ]
  },
  "context": {
    "max_history_events": 8,
    "max_prompt_chars": 32000,
    "max_file_read_bytes": 12000,
    "max_search_hits": 20,
    "max_tool_result_chars": 6000,
    "max_project_memory_chars": 4000,
    "max_global_memory_chars": 4000,
    "estimated_context_window_tokens": 32768,
    "response_reserve_tokens": 4096,
    "warn_at_percent": 70,
    "condense_at_percent": 85,
    "condensed_keep_recent_events": 4,
    "max_condensed_summary_chars": 2400,
    "max_stop_summary_chars": 2400
  }
}
```

## State Extension

Add `runtime_session` to `.contubernium/state.json`:

```json
{
  "runtime_session": {
    "status": "idle",
    "provider": "",
    "model": "",
    "endpoint": "",
    "approval_mode": "guarded",
    "active_approval": {
      "status": "idle",
      "kind": "read",
      "requested_by": "decanus",
      "lane": "command",
      "tool_name": "",
      "detail": "",
      "reason": "",
      "target": ""
    },
    "current_turn_id": "",
    "last_health_check": "",
    "last_error": "",
    "last_failure": {
      "error_code": "",
      "message": "",
      "context": {
        "actor": "",
        "lane": "",
        "tool": "",
        "target": "",
        "command": "",
        "detail": "",
        "provider": "",
        "model": "",
        "turn_id": "",
        "iteration": 0
      }
    },
    "active_log_path": "",
    "last_actor": "decanus",
    "repair_attempts": 0
  }
}
```

## Prompt Loading Rules

Required files:

- `.contubernium/prompts/shared/base.md`
- `.contubernium/prompts/shared/tool-policy.md`
- `.contubernium/prompts/shared/decanus-schema.json`
- `.contubernium/prompts/shared/specialist-schema.json`
- `.contubernium/prompts/decanus.md`
- one prompt file per specialist agent

Prompt assembly order:

1. shared base instructions
2. shared tool policy
3. actor-specific role prompt
4. JSON schema reference
5. live mission/state slice

## Adapter Contract

### `BackendAdapter`

Required behavior:

- `healthCheck()`
- `listModels()`
- `structuredChat(request)`
- `capabilities()`

### `structuredChat(request)`

Input fields:

- `system_prompt`
- `user_prompt`
- `model`
- `timeout_ms`
- `schema_kind`

Output fields:

- `raw_text`
- `provider_name`
- `model_name`
- `latency_ms`

### Streaming Behavior

- `ollama-native` uses streaming mode for the OpenTUI session and forwards chunks through the Zig `ui-bridge` event stream as they arrive.
- The OpenTUI frontend stores streamed chunks separately from the render loop so terminal input and repainting do not block on inference latency.
- Non-interactive commands still use the same runtime loop and write the final provider payload to the per-turn log.

## Supported Providers

### `ollama-native`

Expected endpoints:

- `GET /api/tags`
- `POST /api/chat`

Interactive expectation:

- `POST /api/chat` is called with `stream=true` inside the OpenTUI bridge worker.
- The runtime consumes newline-delimited JSON chunks, appends `message.content` to the live chat log, and interrupts the child request when the operator presses `Ctrl+C`.

### `openai-compatible`

Expected endpoints:

- `GET /v1/models`
- `POST /v1/chat/completions`

The OpenAI-compatible provider exists so the same runtime can later work with local `llama.cpp`, `vLLM`, `LM Studio`, and similar servers.

## Turn Schemas

### `DecanusDecision`

```json
{
  "action": "finish | invoke_specialist | tool_request | ask_user | blocked",
  "reasoning": "short explanation",
  "current_goal": "current mission focus",
  "lane": "backend | frontend | systems | qa | research | brand | media | docs | bulk_ops",
  "actor": "faber | artifex | architectus | tesserarius | explorator | signifer | praeco | calo | mulus",
  "objective": "what the specialist must do next",
  "completion_signal": "how decanus will know it is done",
  "dependencies": ["optional list"],
  "final_response": "required only when action=finish",
  "question": "required only when action=ask_user",
  "blocked_reason": "required only when action=blocked",
  "tool_requests": []
}
```

### `SpecialistResult`

```json
{
  "action": "complete | tool_request | ask_user | blocked",
  "reasoning": "short explanation",
  "description": "what changed",
  "result_summary": "short result summary",
  "artifacts": ["paths or identifiers"],
  "follow_up_needed": "",
  "question": "required only when action=ask_user",
  "blocked_reason": "required only when action=blocked",
  "tool_requests": []
}
```

### `ToolRequest`

```json
{
  "tool": "list_files | read_file | search_text | run_command | write_file | ask_user",
  "description": "why the tool is needed",
  "path": "",
  "pattern": "",
  "command": "",
  "content": ""
}
```

## Turn Engine Rules

### Decanus Turn

- Reads mission state and recent history.
- Requests a JSON decision from the model.
- Validates the JSON.
- Applies exactly one next-step decision.

When `action=invoke_specialist`:

- update `tasks.<lane>.invocation`
- set `agent_loop.active_tool`
- append a `tool_call` history event
- set `current_actor` to the specialist

When `action=finish`:

- write `mission.final_response`
- set `global_status` to `complete`
- set `agent_loop.status` to `complete`

### Specialist Turn

- Reads only the scoped invocation and relevant mission context.
- Returns a structured result.
- On completion, writes artifacts and summary to its lane.
- Returns control to `decanus`.

## Tool Execution Policy

The runtime owns all side effects.

Decision outcomes:

- `allow`
- `confirm`
- `block`

Default policy:

- read-only tools can auto-run
- writes require confirmation
- shell commands require confirmation
- blocked command patterns always fail

In OpenTUI, confirmations are surfaced as inline approval prompts instead of blocking stdin reads in the worker thread.

## Retry And Repair

When JSON parsing fails:

1. capture raw output
2. log the failure
3. ask the model to repair into valid JSON
4. retry up to `max_retries`
5. fail with a clear blocked state if repair does not succeed

## Runtime Status Values

Common `runtime_session.status` values:

- `idle`
- `ready`
- `running`
- `complete`
- `blocked`
- `interrupted`

## Logging

Each turn writes a log entry containing:

- timestamp
- actor
- model
- provider
- schema kind
- prompt summary
- raw output
- parsed output
- tool activity
- errors

## Minimum Acceptance Tests

- `doctor` catches missing prompts
- `doctor` catches missing model
- `mission start` can start a new mission
- `mission step` advances one actor turn
- `mission continue` continues from a blocked state
- invalid JSON produces repair attempts
- denial of confirmation produces a blocked state
