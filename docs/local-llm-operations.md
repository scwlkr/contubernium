# Local LLM Runtime Operations

## Goal

This guide explains how to operate the local-model Contubernium runtime once the code is present in the repo.

## Install Flow

### 1. Build the Zig CLI

From the repo root:

```bash
zig build
```

The executable is exposed through the build output as `contubernium`.

### 2. Initialize the workspace

```bash
./zig-out/bin/contubernium init
```

This prepares:

- `contubernium.config.json`
- `.contubernium/logs/`

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

### 5. Edit `contubernium.config.json`

Set:

- `provider.type`
- `provider.base_url`
- `provider.model`
- approval policy

### 6. Run `doctor`

```bash
./zig-out/bin/contubernium doctor
```

This should pass before real missions are attempted.

### 7. Start a mission

```bash
./zig-out/bin/contubernium run "Add a release checklist to the docs"
```

### 8. Resume if needed

```bash
./zig-out/bin/contubernium resume
```

## Day-To-Day Commands

List models:

```bash
./zig-out/bin/contubernium models list
```

Advance only one turn:

```bash
./zig-out/bin/contubernium step
```

## Approval Behavior

The default runtime policy is `guarded`.

That means:

- reading files is usually automatic
- writing files requires confirmation
- shell commands require confirmation
- explicitly blocked commands never run

If a command is denied, the runtime records the blocked condition in state and logs. Use `resume` after changing the situation.

## Log Locations

Turn logs are written under:

```text
.contubernium/logs/
```

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

### The configured model is missing

Run:

```bash
ollama pull <model-name>
```

Then rerun:

```bash
./zig-out/bin/contubernium doctor
```

### The model returns invalid JSON

This is expected sometimes with local models. The runtime will try bounded repair retries. If retries fail:

- inspect the log
- try a stronger model
- reduce prompt complexity
- lower context pressure

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

### The backend is not Ollama

Use the `openai-compatible` provider mode and point the config at the local server endpoint. The protocol does not change.

## Operational Advice

- Keep one default model per workspace until the loop is stable.
- Do not start with full autonomy.
- Use `doctor` after config changes, model changes, or backend changes.
- Treat the logs and docs as part of the runtime, not optional extras.
