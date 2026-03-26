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

# ⚔️ The Roster

## Commander

- **decanus** — mission owner, planner, orchestrator, and final authority

## Specialists (Tools)

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

# 🧠 Memory Model

Contubernium uses layered memory:

```
.contubernium/
state.json      # mission state (live loop)
project.md      # project-level knowledge
global.md       # reusable patterns
config.json     # runtime configuration
prompts/        # runtime prompt assets
logs/           # structured JSON run logs
```

Rules:
- `decanus` owns mission state
- only validated information becomes permanent
- no speculative memory writes

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

# 📁 Repository Structure

```
.agents/
AGENT_LOOP.md
<agent>/
  SOUL.md
  CONTRACT.md
  SKILL.md

templates/
contubernium_state.template.json
contubernium.config.template.json
project.template.md
global.template.md

docs/
doctrine.md
agent-contracts.md
invocation-protocol.md

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

## Run

```bash
contubernium
```

## Initialize in a project

```bash
cd your-project
contubernium init
```

`contubernium init` creates the canonical local project scaffold:

```text
.contubernium/
.agents/
```

If you need a Bash-only fallback from a source checkout, run:

```bash
./init.sh /path/to/project
```

See [docs/installation.md](/Users/shanewalker/Desktop/dev/Contubernium/docs/installation.md) for the full install and initialization flow.

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
