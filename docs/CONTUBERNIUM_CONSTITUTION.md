# CONTUBERNIUM CONSTITUTION
## Core Beliefs and Non-Negotiables

### Article I — Local-First Principle
Contubernium is Local-First; therefore, being lightweight is essential.  
Models are primarily focused on local execution but must retain the capacity for online/cloud models.  
Models are handled through Ollama and OpenRouter.

### Article II — Model Selection
Model selection must be dynamic and governed by the following rules:
- Default to the smallest capable model.
- Escalate only when necessary.
- A fallback must exist for all model failures.

### Article III — Interface Priority
Contubernium is CLI-centric. All other user experiences are secondary.

### Article IV — Orchestration Authority
Contubernium shall have only one orchestration agent with authority, known as Decanus.  
No other agent may command another agent. All agents may only submit requests to Decanus.

### Article V — Memory Structure
Contubernium shall maintain the following levels of memory:
- Short-term context window memory  
- Mid-term project-local memory  
- Long-term global memory containing user information and preferences  

### Article VI — Agent System
Contubernium shall maintain:
- Eight (8) core agents  
- Two or more (2+) helper agents  

These agents shall collectively be capable of solving any problem that can be solved with software.  
Helper agents may be added or removed as needed.

Each agent must include:
- A `SOUL.md` defining its personality  
- A `CONTRACT.md` defining its boundaries and operating rules  
- A `SKILL.md` defining its overall capabilities  
- A nested `actions/` directory containing markdown files that define specific actions or procedures available to the agent  

All agents shall be located in the system’s home directory and shall not be project-local.

### Article VII — System Design Philosophy
The purpose of multiple agents is to avoid reliance on system-intensive large language models.  
Contubernium shall operate by decomposing large problems into smaller tasks that can be executed sequentially on smaller models, thereby reducing resource usage.

### Article VIII — Sessions
Each conversation shall constitute a session.  
All sessions must be logged into memory, enabling retrieval and continuation at any time.

### Article IX — Platform Support
Contubernium is macOS and Linux first.  
No architectural decision shall make future Windows support exceedingly difficult.

### Article X — Open Source Requirement
Contubernium is open source and must remain easy to install.  
The `README` must always contain up-to-date installation instructions.

### Article XI — Development Process
All features must follow this strict build order:
1. Develop a test for the intended outcome (Test-Driven Development)  
2. Implement the feature  
3. Document both the feature and the test in `USER_MANUAL.md`  

### Article XII — Versioning and Migration
Contubernium must be version-controlled.  
Migration compatibility with global memory must be maintained at all times.

### Article XIII — Logging and Errors
All actions must produce structured logs.  
If an action fails, an error must be produced containing:
- Code  
- Cause  

### Article XIV — User Authority
The user is the ultimate authority.  
The system must allow:
- Interruption  
- Override  
- Manual approval at any step  
- Explicit consent to proceed without approval  

### Article XV — Context Management
Context overflow must never result in system failure.  
The system must:
- Summarize  
- Compress  
- Or discard non-critical data  

All while preserving mission-critical state.

### Article XVI — Permissions
All tools and actions must define permission levels, including:
- Read  
- Write  
- Execute  

### Article XVII — Memory Isolation
Project memory must be isolated to the directory in which Contubernium is currently operating.  
No data may cross project boundaries unless explicitly authorized.

### Article XVIII — Tooling Standards
All tools must define:
- Input schema  
- Output schema  
- Timeout behavior  
- Failure response format  

### Article XIX — Constitutional Immutability

This Constitution is immutable and shall not be modified, altered, or rewritten by any artificial intelligence under any circumstances. Such actions are strictly forbidden.

Any required changes, additions, or revisions must be enacted exclusively through a separate amendment document.

### Article XX — Amendment Format and Naming Convention

All amendments must be created as separate documents and shall not alter this Constitution directly.

Amendments must follow a standardized naming convention:
- AMENDMENT_001.md
-  AMENDMENT_002.md
- AMENDMENT_003.md
- and so forth, in sequential numerical order

Each amendment document must include:
- A clear title
- A statement of purpose
- The full text of the amendment
- The effective date of the amendment

Amendments shall be cumulative and must not overwrite or modify the original Constitution text.

