# Local LLM Runtime Operations

> Historical planning note:
> This guide includes older references to project-local prompt assets.
> The implemented runtime now loads global-home agent/shared assets and keeps project-local files limited to memory and runtime state.
> Use [USER_MANUAL.md](/Users/shanewalker/Desktop/dev/Contubernium/USER_MANUAL.md) for the operator-facing record of shipped behavior.

## Goal

This guide explains how to operate the local-model Contubernium runtime once the code is present in the repo.

## Install Flow

### 1. Install the global CLI

From the Contubernium repo root:

```bash
./install.sh
```

This builds the binary, installs `contubernium` into a user bin directory such as `~/bin` or `~/.local/bin`, and syncs the global Contubernium home into `~/.contubernium/`.

Before shipping changes to the runtime itself, run:

```bash
zig build
zig build test
```

### 2. Initialize the workspace

```bash
contubernium init
```

This prepares:

- `.contubernium/config.json`
- `.contubernium/state.json`
- `.contubernium/ARCHITECTURE.md`
- `.contubernium/PLAN.md`
- `.contubernium/PROJECT_CONTEXT.md`
- `.contubernium/project.md`
- `.contubernium/global.md`
- `.contubernium/logs/`

It does not create a project-local `.agents/` tree or `.contubernium/prompts/`.

If you need a Bash-only fallback from a source checkout, run:

```bash
./init.sh /path/to/project
```

### 3. Start Ollama

Make sure Ollama is installed and serving locally. The default config expects:

```text
http://127.0.0.1:11434
```

### 4. Pull or import a model

Examples:

```bash
ollama pull qwen2.5-coder:7b
ollama pull llama3.1:8b
```

Use one reliable instruct or coding model first. Keep the phase 1 setup simple.

### 5. Edit `.contubernium/config.json`

Set:

- `provider.type`
- `provider.base_url`
- `provider.model`
- approval policy

### 6. Run `doctor`

```bash
contubernium doctor
```

This should pass before real missions are attempted.

`doctor` verifies:

- global agent and shared assets
- required project memory files
- backend reachability
- configured model availability
- structured output behavior

### 7. Start a mission

```bash
contubernium mission
```

This opens the plain CLI mission launcher:

- `Up` / `Down` switches models
- mission text is rendered in a distinct prompt color
- `Enter` starts the mission
- `Esc` cancels

If you want a direct non-interactive command instead:

```bash
contubernium mission start "Add a release checklist to the docs"
```

### 8. Resume if needed

```bash
contubernium mission continue
```

### 9. Start the interactive UI

```bash
contubernium
```

or

```bash
contubernium ui
```

The OpenTUI interface supports:

- direct mission prompts
- live state context for actor, lane, loop iteration, provider, model, and last error
- streamed Ollama output in the mission log while the terminal remains interactive
- `/doctor`
- `/models`
- `/model <n|name>`
- `/status`
- `/resume`
- `/interrupt`
- `/clear`
- `/exit`

Keyboard controls:

- `Enter` submits the current input line
- `Up` / `Down` scroll the mission log
- `PageUp` / `PageDown` scroll faster
- `Left` / `Right` move inside the input field
- `Ctrl+C` interrupts the active loop or exits when idle
- approval prompts are handled inline in the OpenTUI flow

## Day-To-Day Commands

List models:

```bash
contubernium models
```

Advance only one turn:

```bash
contubernium mission step
```

## Approval Behavior

The default runtime policy is `guarded`.

That means:

- reading files is usually automatic
- writing files requires confirmation
- shell commands require confirmation
- explicitly blocked commands never run

If a command is denied, the runtime records the blocked condition in state and logs. Use `mission continue` after changing the situation.

Inside OpenTUI, those confirmations appear inline in the command tent instead of as blocking terminal prompts from the worker thread.

## Log Locations

Turn logs are written under:

```text
.contubernium/logs/
```

They are structured JSON run logs with one file per runtime session.

Use these logs when:

- the model returns malformed JSON
- a run blocks unexpectedly
- a backend call fails
- a specialist gets stuck repeating the same action

## Troubleshooting

### Ollama is installed but the runtime cannot reach it

Check:

- Ollama is actually serving
- the configured `base_url` is correct
- local firewall or process issues are not blocking the port

OpenTUI will show this as a backend-unavailable status in the model roster area. Use `/models` or `/doctor` after starting the service.

### The configured model is missing

Run:

```bash
ollama pull <model-name>
```

Then rerun:

```bash
contubernium doctor
```

Or from OpenTUI:

```text
/models
/model <n|name>
/doctor
```

### The model returns invalid JSON

This is expected sometimes with local models. The runtime will try bounded repair retries. If retries fail:

- inspect the log
- try a stronger model
- reduce prompt complexity
- lower context pressure

During OpenTUI runs you will still see the streamed attempt in the ledger, followed by the repair retry.

### The context window is too small

Symptoms:

- the agent forgets the active invocation
- JSON quality drops
- the model starts repeating itself

Fixes:

- use a model with a larger context window
- reduce prompt size
- rely on the runtime summary rather than passing full history every turn

### The runtime blocks on a risky action

This means the policy is working as designed. Either:

- approve the action when prompted
- change the policy in config
- choose a less risky workflow

If you need to stop a long-running inference or loop mid-flight, press `Ctrl+C` or run `/interrupt`.

### The backend is not Ollama

Use the `openai-compatible` provider mode and point the config at the local server endpoint. The protocol does not change.

## Operational Advice

- Keep one default model per workspace until the loop is stable.
- Do not start with full autonomy.
- Use `doctor` after config changes, model changes, or backend changes.
- Treat the logs and docs as part of the runtime, not optional extras.
