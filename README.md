# Contubernium

**Contubernium** is a 10-agent localized workspace scaffolding designed to orchestrate complex development tasks using a disciplined Roman command structure. The project uses a central deployment script to provision state management and link agent skills to any target repository.

## 🚀 Current Status

- **Project Scaffolding Complete**: The foundational directory structure for the 10-agent contubernium is established under `.agents/`.
- **Agent Personas Defined**: Skill definitions (`SKILL.md`) for all 10 agents are maintained within their respective directories.
- **State Management Initiated**: The local JSON state manager (`contubernium_state.json`) logic and structure are successfully scaffolded.
- **Deployment Script Standardized**: `init.sh` hydrates the Roman roster and protects existing project state from being overwritten.

## 🤖 The Roster

The workspace is powered by 8 core legionaries and 2 auxiliaries.

1. **decanus**: The state commander who reads the mission, assigns work, and updates `contubernium_state.json`.
2. **faber**: The backend blacksmith who builds databases, APIs, and server logic.
3. **artifex**: The frontend artisan who builds the interface and connects client behavior to the backend.
4. **architectus**: The systems siege-engineer who manages infrastructure, CI/CD, and deployment scripts.
5. **tesserarius**: The QA gatekeeper who reviews work for security, logic, regressions, and performance issues.
6. **explorator**: The research scout who gathers technical docs, API specs, and external intelligence.
7. **signifer**: The brand standard-bearer who enforces visual identity and design discipline.
8. **praeco**: The media herald who writes launch copy, release notes, and social strategy.
9. **calo**: The documentation scribe who updates READMEs, markdown docs, and supporting comments after changes land.
10. **mulus**: The pack mule who handles bulk formatting, asset conversion, and high-volume file operations.

## 🛠️ Usage

To initialize the swarm in a target directory (assuming Contubernium is your global reference):

```bash
/path/to/Contubernium/init.sh
```

This script will:
1. Safely symlink the `.agents` directory to your local working directory.
2. Generate `contubernium_state.json` to keep track of tasks across the contubernium, including documentation and bulk-ops helper lanes.

## 📄 State Tracking

Contubernium relies on `contubernium_state.json` to monitor the overarching project. It tracks:
- `project_name`
- `global_status`
- `current_actor`
- Task lanes for backend, frontend, systems, QA, research, brand, media, documentation, and bulk operations.
