# Local LLM Support for Contubernium

## What This Solves

Right now, Contubernium defines how the agents should think, hand work off, and record state, but it does not include a runtime that can actually drive the protocol with a local model. This plan adds that missing runtime so you can run the Contubernium loop against Ollama first, then other local model servers later, without rewriting the protocol every time you change model hosts.

The main idea is simple:

- Contubernium stays the commander and workflow system.
- Ollama or another local server is only the model engine.
- The local model does not directly edit files or run shell commands.
- The runtime asks the model for structured decisions, then the runtime decides what is safe to execute.

That separation is what keeps the system understandable and recoverable.

## What Stays The Same

- `decanus` still receives the mission first.
- Specialist agents still work as narrow tools inside the commander loop.
- `.contubernium/state.json` stays the mission memory and workflow record.
- The loop is still `Think -> Tool -> Result -> Think -> Finish`.

## What Changes

- A standalone Zig CLI runner becomes the execution engine.
- A new project-local `.contubernium/config.json` file stores runtime settings such as provider, model, endpoint, timeouts, and safety policy.
- Prompt files for `decanus` and each specialist are packaged in the repo instead of relying on Codex-only behavior.
- A backend adapter layer lets the same protocol talk to Ollama first and OpenAI-compatible local servers next.
- A guarded tool executor sits between the model and the machine.

## Plain-English System Picture

Think of the system as three layers:

1. Contubernium protocol
   This is the Roman command structure, state machine, task lanes, and handoff rules.

2. Local runtime
   This is the Zig CLI that reads the state, loads prompts, calls the model, validates the JSON decision, and runs approved actions.

3. Model host
   This is Ollama, or later another local server like `llama.cpp`, `vLLM`, or `LM Studio`.

The runtime is the bridge between the protocol and the model host.

## Sequential Workflow

### 1. Install the runtime

Build the Zig CLI so you have a local `contubernium` executable.

### 2. Install and start Ollama

Ollama runs as the first supported local model server. It is the easiest on-ramp because it manages downloads, serving, and local model naming in one place.

### 3. Pull or import a model

Pick one instruct or coding model and use it for all Contubernium roles in phase 1. The roles are separated by prompts, not by separate model processes.

### 4. Run `doctor`

Before trying real missions, run a health check:

- is the config present?
- are the prompt files present?
- is the backend reachable?
- does the configured model exist?
- can the model return valid JSON?

If `doctor` fails, fix the environment first.

### 5. Set the runtime config

The runtime config tells Contubernium:

- which provider to use
- which model to call
- where the backend lives
- how strict approvals should be
- where prompts and logs live

### 6. Start a mission

Run `contubernium run "your prompt here"` or start the full-screen terminal interface with `contubernium`.

The runtime writes the mission to `.contubernium/state.json`, sets `current_actor` to `decanus`, and starts the loop.

### 7. Approve guarded actions when asked

The model can request actions, but the runtime is the one that decides whether those actions are safe.

Examples:

- reading files can usually proceed automatically
- writing files may require confirmation
- shell commands may be allowed, confirmed, or blocked depending on policy

### 8. Resume if interrupted

If the process stops, `resume` continues from the state file and the runtime logs.

## Implementation Steps

### Step 1. Persist the documentation first

Create the documentation set in `docs/` before coding:

- `local-llm-contubernium-plan.md`
- `local-llm-runtime-spec.md`
- `local-llm-operations.md`

These documents become the long-term reference for future work.

### Step 2. Add runtime configuration

Introduce `.contubernium/config.json` and the template file under `templates/`.

This file is separate from mission state because config changes much less often than mission memory.

### Step 3. Extend mission state

Add `runtime_session` to `.contubernium/state.json` so the runtime can record:

- provider
- model
- endpoint
- approval mode
- current turn id
- last health check
- last error
- active log path

### Step 4. Package the prompts

Add stable prompt files for:

- `decanus`
- each specialist
- shared tool policy
- shared JSON response contracts

That makes the runtime portable across workspaces.

### Step 5. Build the Zig runner skeleton

Implement commands:

- `contubernium init`
- `contubernium doctor`
- `contubernium models list`
- `contubernium run`
- `contubernium step`
- `contubernium resume`
- `contubernium ui`
- `contubernium`

### Step 6. Add provider adapters

Phase 1:

- `ollama-native`

Phase 2:

- `openai-compatible`

This keeps the protocol stable even if the backend changes.

### Step 7. Add structured JSON turn handling

Every model response must be valid JSON that matches one of the runtime schemas.

`decanus` should decide whether to:

- finish
- invoke a specialist
- request tools
- ask the user for help
- block with a reason

Specialists should return:

- completion status
- result summary
- artifacts
- optional tool requests

### Step 8. Add guarded tool execution

The runtime, not the model, owns side effects.

Initial tools:

- list files
- read files
- search text
- run shell command
- write file
- ask user

### Step 9. Add repair and retry logic

Local models will sometimes return malformed JSON. The runtime must:

- detect the failure
- attempt a bounded repair retry
- stop cleanly if the model cannot recover

### Step 10. Add context controls

To prevent prompt blow-up, the runtime should:

- keep only recent history in the live prompt
- summarize older history
- preserve the exact active invocation contract
- keep recent tool results visible

### Step 11. Add replay and resume

Every turn should log:

- actor
- prompt inputs
- raw model output
- parsed JSON
- tool requests
- tool results
- retry attempts
- state changes

### Step 12. Update bootstrap and README

`init.sh` should also deploy:

- prompt assets
- config template

The README should link the new runtime docs directly.

## Technical Appendix

### Runtime Ownership

- `.contubernium/state.json`: mission memory and loop state
- `.contubernium/config.json`: runtime/operator configuration
- `.contubernium/prompts/`: role prompts and shared contracts
- `.contubernium/logs/`: per-turn runtime logs

### Phase 1 Backend Contract

The adapter contract needs four core operations:

- `healthCheck`
- `listModels`
- `structuredChat`
- `capabilities`

### Safety Model

The local model never gets direct shell ownership. It can only request actions. The runtime then decides:

- allow automatically
- ask for confirmation
- block

### Why Ollama First

Ollama is the best phase 1 target because it already handles:

- local model storage
- pulling named models
- serving them over HTTP
- easy local setup

After that, an OpenAI-compatible adapter can cover a wider set of local runners without changing the Contubernium protocol itself.

## Acceptance Criteria

- The runtime can complete a `decanus -> specialist -> decanus -> finish` cycle using a local model.
- The same protocol works with Ollama and with an OpenAI-compatible local server.
- Invalid JSON is handled with repair retries and clear failure reporting.
- Guarded actions can be approved, denied, logged, and resumed.
- `contubernium init` can create a full `.contubernium/` scaffold in any project directory and launch the full-screen terminal UI in an interactive terminal.
- `contubernium` with no args launches the same full-screen interface.
- The terminal UI can list locally available models and switch the active model without leaving the interface.
- The documentation is enough for a future engineer to continue the work without reconstructing the design.
