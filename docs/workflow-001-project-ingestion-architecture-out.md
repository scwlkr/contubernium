# 🏛️ Workflow 001 — Project Ingestion → Architecture Output

## Goal

Take a project (folder or URL) and produce:

* system understanding
* architecture design
* tech stack recommendation
* file structure
* infra + cost estimate

**Output = one clean, usable architecture spec**

---

# 1. Entry Point (User → Decanus)

## Input (TUI)

```text
Analyze this project and design a full system architecture:

Source: ./project-folder
Goal: Turn this into a production-ready system
Constraints: local-first preferred, simple deployment
```

---

## Decanus — Step 1 (Interpretation)

Decanus converts this into:

### Mission

```json
{
  "title": "Project ingestion and architecture design",
  "objective": "Understand the project and produce a complete system architecture",
  "mode": "analysis + design"
}
```

### Plan (internal)

1. gather project understanding → `explorator`
2. define system architecture → `architectus`
3. define backend structure → `faber`
4. define frontend structure → `artifex`
5. validate coherence → `tesserarius`
6. finalize output → `decanus`

---

# 2. Step 1 — Project Ingestion (Explorator)

## Invocation

```json
{
  "target_agent": "explorator",
  "objective": "Analyze the project source and produce a structured understanding of system, purpose, and components",
  "context": {
    "source": "./project-folder",
    "depth": "full",
    "focus": [
      "purpose",
      "features",
      "structure",
      "tech clues",
      "gaps"
    ]
  },
  "scope": {
    "read_allowed": true,
    "write_allowed": false
  }
}
```

---

## Expected Output

```json
{
  "summary": "Project appears to be X with Y purpose",
  "findings": [
    "Core functionality: ...",
    "Existing stack: ...",
    "File structure: ...",
    "Missing components: ..."
  ],
  "artifacts": [
    {
      "type": "project_summary",
      "content": "..."
    }
  ],
  "recommended_next_agent": "architectus"
}
```

---

## Result

Decanus now has:

* what the project is
* what exists
* what is missing

---

# 3. Step 2 — System Architecture (Architectus)

## Invocation

```json
{
  "target_agent": "architectus",
  "objective": "Design a complete system architecture based on the project analysis",
  "context": {
    "project_summary": "...",
    "constraints": [
      "local-first preferred",
      "simple deployment",
      "scalable if needed"
    ]
  }
}
```

---

## Expected Output

```json
{
  "summary": "Defined system architecture",
  "findings": [
    "Architecture pattern: monolith / modular / etc",
    "Core services: ...",
    "Data flow: ...",
    "Deployment model: ..."
  ],
  "artifacts": [
    {
      "type": "architecture_spec",
      "content": "full architecture description"
    },
    {
      "type": "infra_plan",
      "content": "hosting, runtime, scaling, cost"
    }
  ],
  "recommended_next_agent": "faber"
}
```

---

# 4. Step 3 — Backend Design (Faber)

## Invocation

```json
{
  "target_agent": "faber",
  "objective": "Design backend system including APIs, data models, and service structure",
  "context": {
    "architecture_spec": "...",
    "project_summary": "..."
  }
}
```

---

## Expected Output

* API structure
* data models
* service layout
* internal logic breakdown

---

# 5. Step 4 — Frontend Design (Artifex)

## Invocation

```json
{
  "target_agent": "artifex",
  "objective": "Design frontend system including UI structure and interaction flows",
  "context": {
    "architecture_spec": "...",
    "backend_spec": "..."
  }
}
```

---

## Expected Output

* page/component structure
* user flows
* frontend architecture
* integration points

---

# 6. Step 5 — QA Validation (Tesserarius)

## Invocation

```json
{
  "target_agent": "tesserarius",
  "objective": "Validate full system design for consistency, risks, and missing components",
  "context": {
    "architecture": "...",
    "backend": "...",
    "frontend": "..."
  }
}
```

---

## Expected Output

```json
{
  "status": "complete",
  "findings": [
    "Missing auth layer",
    "Potential scaling issue",
    "API mismatch between frontend/backend"
  ],
  "recommendations": [
    "Add auth system",
    "Adjust endpoint structure"
  ]
}
```

---

# 7. Step 6 — Final Output (Decanus)

Decanus now synthesizes everything into:

## Final Deliverable

```md
# Project Architecture

## Overview
...

## System Architecture
...

## Backend Design
...

## Frontend Design
...

## Infrastructure & Cost
...

## Risks & Recommendations
...

## Next Steps
- implement backend
- scaffold frontend
- set up deployment
```

---

# 8. Loop Visualization

```id="8x0r3f"
User
  ↓
Decanus (plan)
  ↓
Explorator (understand)
  ↓
Architectus (system)
  ↓
Faber (backend)
  ↓
Artifex (frontend)
  ↓
Tesserarius (validate)
  ↓
Decanus (final output)
```

---

# 9. What this tests

This workflow validates:

* agent contracts are actually usable
* invocation protocol works end-to-end
* memory is meaningful
* loop integrity holds
* Decanus control is preserved

If this works → your system is real.

---

# 10. v1 Constraints (IMPORTANT)

Do NOT:

* parallelize steps
* skip QA
* allow agents to chain each other
* add extra agents

Keep it:

* linear
* explicit
* observable
