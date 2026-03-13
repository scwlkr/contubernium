# Contubernium

**Contubernium** is an 8-agent localized workspace scaffolding designed to orchestrate complex development tasks using a team of specialized AI agents. The project uses a central deployment script to provision state management and link agent skills to any target repository.

## 🚀 Current Status

- **Project Scaffolding Complete**: The foundational directory structure for the 8-agent swarm is established under `.agents/`.
- **Agent Personas Defined**: Skill definitions (`SKILL.md`) for all 8 agents have been created within their respective directories.
- **State Management Initiated**: The local JSON state manager (`contubernium_state.json`) logic and structure are successfully scaffolded.
- **Deployment Script Standardized**: `init.sh` has been built and refined to handle the global `.agents` symlinking and state hydration without overwriting existing data.

## 🤖 The Swarm

The workspace is powered by an orchestrator and 7 specialized agents:

1. **optio-orchestrator**: The commander. Parses user requests, updates the state file, and delegates tasks.
2. **backend-architect**: Builds databases, APIs, and server logic.
3. **brand-architect**: Enforces visual identity, typography, and design rules.
4. **frontend-weaver**: Builds the user interface and connects frontend logic to APIs.
5. **media-strategist**: Handles marketing copy, release notes, and social strategy.
6. **qa-centurion**: Ruthless code reviewer and tester.
7. **scout-researcher**: Gathers technical docs, competitive analysis, and API specs.
8. **systems-engineer**: Manages infrastructure, CI/CD, and environment scripts.

## 🛠️ Usage

To initialize the swarm in a target directory (assuming Contubernium is your global reference):

```bash
/path/to/Contubernium/init.sh
```

This script will:
1. Safely symlink the `.agents` directory to your local working directory.
2. Generate `contubernium_state.json` to keep track of tasks across the swarm.

## 📄 State Tracking

Contubernium relies on `contubernium_state.json` to monitor the overarching project. It tracks:
- `project_name`
- `global_status`
- `current_actor`
- Specific tasks assigned to various agents with corresponding statuses.
