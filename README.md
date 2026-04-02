# Contubernium

**Contubernium** is a commander-led, local-first AI execution system that takes a project from idea to structured, working reality.

It is not a chatbot.  
It is not a general-purpose assistant.  

It is a **project conquest system**.

---

# 🏛️ Core Model

Contubernium operates on a strict command structure:

- `decanus` is the sole orchestrator
- all other agents are **specialist tools**
- execution follows a controlled loop:

```

Think → Tool → Result → Think → Finish

```

At no point does control leave `decanus`.

---

# ⚔️ Agent Model

## Commander

- **decanus** — mission owner, planner, orchestrator, and final authority

## Constitutional Alignment Note

- the constitutional core target is 8 total agents including `decanus`
- the source tree currently carries additional specialist assets during alignment work
- any installed non-`decanus` asset beyond the final core set is a helper agent, not a peer commander

## Installed Specialist Assets

- **faber** — backend, APIs, data systems
- **artifex** — frontend, UI, interaction
- **architectus** — infrastructure, deployment, systems
- **tesserarius** — QA, validation, security
- **explorator** — research, discovery, analysis
- **signifer** — brand, design systems
- **praeco** — messaging, content, launch communication
- **calo** — documentation, system truth
- **mulus** — bulk operations, formatting, file manipulation

All specialists:
- operate in narrow scope
- return results to `decanus`
- never own the mission

---

# 🔁 Execution Loop

1. User provides a mission
2. `decanus` interprets and plans
3. A specialist is invoked (if needed)
4. Specialist returns structured result
5. `decanus` evaluates and continues or completes

The loop continues until:
- mission is complete
- system is blocked
- approval is required

---

# 🧠 System Capabilities

Contubernium is designed to handle the full lifecycle of a project:

### Ingest
- read local files or external sources
- understand structure, system, and constraints

### Design
- define architecture, stack, and layout
- establish branding and system structure
- estimate cost and operational complexity

### Execute
- write and modify code
- run commands (with approval)
- integrate systems and APIs

### Maintain
- update documentation
- track project state
- refine systems over time

---

# 🧩 Invocation Protocol

All work is executed through a structured protocol:

- every action is an **invocation**
- every invocation produces a **result**
- all steps are recorded in `.contubernium/state.json`

Core runtime objects:

- Mission
- Invocation
- Result
- ApprovalRequest
- LoopStep
- StateSnapshot

This makes the system:
- predictable
- inspectable
- debuggable

---

# 🧠 Memory And Assets

Contubernium separates installed runtime assets from project-local memory.

Installed global home:

```text
~/.contubernium/
  agents/
  shared/
  adapters/
  templates/
  global.md
```

Initialized project:

```text
.contubernium/
  state.json
  config.json
  ARCHITECTURE.md
  PLAN.md
  PROJECT_CONTEXT.md
  project.md
  global.md
  logs/
```

Constitutional memory tiers map onto the current project files like this:

- mission memory: `.contubernium/state.json` plus `.contubernium/logs/`
- project memory: `.contubernium/ARCHITECTURE.md`, `.contubernium/PLAN.md`, `.contubernium/PROJECT_CONTEXT.md`, `.contubernium/project.md`
- global memory: the current runtime-loaded layer at `.contubernium/global.md`

Project-local `.agents/` and `.contubernium/prompts/` are not part of the canonical `contubernium init` scaffold.

---

# ⚙️ Runtime

- **Language:** Zig
- **Interface:** OpenTUI terminal interface
- **Execution:** Local-first (Ollama primary)
- **Adapters:** OpenAI-compatible backends supported

Principles:
- no cloud dependency required
- portable and reproducible
- explicit approval for risky actions

---

# 🔐 Approval System

The system requires approval before:

- shell commands
- destructive file changes
- external API mutations
- deployment actions

Example:

```

APPROVAL REQUIRED
Agent: architectus
Action: shell
Command: zig build test

Approve? [y/n]:

```

No silent execution of risky operations.

---

# 📁 Source Repository

```
.agents/
AGENT_LOOP.md
AGENT_ARCHITECTURE.md
AGENT_COMPATIBILITY.md
_schemas/
<agent>/
  SOUL.md
  CONTRACT.md
  SKILL.md
  actions/

shared/
  patterns/
  templates/

adapters/

templates/
contubernium_state.template.json
contubernium.config.template.json
project.template.md
global.template.md
architecture.template.md
plan.template.md
project_context.template.md

docs/
doctrine.md
agent-contracts.md
invocation-protocol.md
installation.md

src/
```

---

# 🚀 Getting Started

## Install

```bash
git clone https://github.com/scwlkr/contubernium.git
cd contubernium
./install.sh
```

`install.sh` installs the CLI onto your `PATH`, syncs the global Contubernium home into `~/.contubernium/`, and installs the bundled OpenTUI frontend in `~/.contubernium/opentui/`.

Current shipped behavior and operator-facing feature notes live in [USER_MANUAL.md](/Users/shanewalker/Desktop/dev/Contubernium/USER_MANUAL.md).

## Run

```bash
contubernium
```

For scripted control instead of the terminal UI:

```bash
contubernium help
contubernium mission
contubernium mission start "Add a release checklist to the docs"
```

## Initialize in a project

```bash
cd your-project
contubernium init
```

`contubernium init` creates the canonical local project scaffold:

```text
.contubernium/
  state.json
  config.json
  ARCHITECTURE.md
  PLAN.md
  PROJECT_CONTEXT.md
  project.md
  global.md
  logs/
```

It does not create a project-local `.agents/` tree or `.contubernium/prompts/`.

If you need a Bash-only fallback from a source checkout, run:

```bash
./init.sh /path/to/project
```

See [docs/installation.md](/Users/shanewalker/Desktop/dev/Contubernium/docs/installation.md) for the full install and initialization flow and [USER_MANUAL.md](/Users/shanewalker/Desktop/dev/Contubernium/USER_MANUAL.md) for shipped operator-facing behavior.

## Configure Model Policy

Contubernium now routes models through `.contubernium/config.json` using a `model_policy` object instead of a single fixed provider/model pair.

- `primary` is the default smallest-capable route, typically a local Ollama model
- `escalation` is an optional stronger route used when prompt pressure or repair retries justify it
- `fallback` is an optional backup route used automatically when the active provider/model fails

Local-only mode:

- keep `model_policy.primary.type = "ollama-native"`
- leave `model_policy.fallback.enabled = false`

Cloud-enabled mode:

- set `model_policy.fallback.type = "openrouter"` for first-class OpenRouter support
- export `OPENROUTER_API_KEY`
- optionally set `site_url` and `app_name` to send OpenRouter attribution headers

Run logs under `.contubernium/logs/` record the primary route, policy decisions, escalation reasons, and fallback usage for each mission.

---

# 🧭 Usage

Inside the OpenTUI interface:

* enter a mission directly
* observe agent loop execution in real time
* approve or deny actions
* inspect state and loop history

Commands:

```
/status
/resume
/interrupt
/models
/model <name>
/doctor
/exit
```

---

# ⚠️ Non-Goals

Contubernium is not:

* a general AI assistant
* a chat-first interface
* an autonomous agent swarm
* an unstructured automation tool

---

# 🏁 Definition of Success

Contubernium succeeds when:

* a project moves from idea → system → implementation
* execution remains consistent over time
* complexity does not degrade into chaos
* the system produces real outcomes, not just suggestions

---

# 🏛️ Final Principle

> The strength of Contubernium is not intelligence.
> It is discipline.
