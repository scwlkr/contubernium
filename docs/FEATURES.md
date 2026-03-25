
1.  Core Engine - (Zig)
- agent loop
- tool execution
- state manager
- approval system
---
2. Agent Layer
- .agents/{agent}/
- SOUL.md (personality + philosophy)
- SKILLS/ (modular capabilities)
- CONTRACT.md (what it can/can’t do)
---
3. Memory System
```
.contubernium/
  state.json        (live mission)
  project.md        (project knowledge)
  global.md         (shared patterns)
  logs/
```
---
4. Contubernium System Install
- Contubernium installs locally to system home folder
- then can be initialized into a project folder for project specific memory, and other files
---
5. Zig TUI Runtime CLI
- 