pub const state_json =
    \\{
    \\  "project_name": "UNASSIGNED",
    \\  "global_status": "idle",
    \\  "current_actor": "decanus",
    \\  "mission": {
    \\    "initial_prompt": "",
    \\    "current_goal": "",
    \\    "success_criteria": [],
    \\    "constraints": [],
    \\    "final_response": ""
    \\  },
    \\  "agent_loop": {
    \\    "status": "awaiting_initial_prompt",
    \\    "iteration": 0,
    \\    "max_iterations": 24,
    \\    "active_tool": null,
    \\    "last_step": {
    \\      "iteration": 0,
    \\      "kind": "think",
    \\      "actor": "decanus",
    \\      "lane": "command",
    \\      "summary": ""
    \\    },
    \\    "last_decision": "",
    \\    "last_tool_result": "",
    \\    "intermediate_results": [],
    \\    "history": []
    \\  },
    \\  "runtime_session": {
    \\    "status": "idle",
    \\    "provider": "",
    \\    "model": "",
    \\    "endpoint": "",
    \\    "approval_mode": "guarded",
    \\    "active_approval": {
    \\      "status": "idle",
    \\      "kind": "read",
    \\      "requested_by": "decanus",
    \\      "lane": "command",
    \\      "tool_name": "",
    \\      "detail": "",
    \\      "reason": "",
    \\      "target": ""
    \\    },
    \\    "current_turn_id": "",
    \\    "last_health_check": "",
    \\    "last_error": "",
    \\    "last_failure": {
    \\      "error_code": "",
    \\      "message": "",
    \\      "context": {
    \\        "actor": "",
    \\        "lane": "",
    \\        "tool": "",
    \\        "target": "",
    \\        "command": "",
    \\        "detail": "",
    \\        "provider": "",
    \\        "model": "",
    \\        "turn_id": "",
    \\        "iteration": 0
    \\      }
    \\    },
    \\    "active_log_path": "",
    \\    "last_actor": "decanus",
    \\    "repair_attempts": 0,
    \\    "context_budget": {
    \\      "estimated_prompt_chars": 0,
    \\      "estimated_prompt_tokens": 0,
    \\      "context_window_tokens": 32768,
    \\      "response_reserve_tokens": 4096,
    \\      "remaining_tokens": 28672,
    \\      "used_percent": 0,
    \\      "condensation_count": 0,
    \\      "condensed_history_events": 0,
    \\      "last_condensed_iteration": 0
    \\    }
    \\  },
    \\  "agent_tools": {
    \\    "faber": {
    \\      "lane": "backend",
    \\      "purpose": "Forge backend services, APIs, and data models.",
    \\      "use_when": [
    \\        "Need database work, server logic, or API implementation."
    \\      ]
    \\    },
    \\    "artifex": {
    \\      "lane": "frontend",
    \\      "purpose": "Build the interface and connect user flows to working behavior.",
    \\      "use_when": [
    \\        "Need UI implementation, interaction design, or frontend wiring."
    \\      ]
    \\    },
    \\    "architectus": {
    \\      "lane": "systems",
    \\      "purpose": "Manage infrastructure, scripts, CI, and deployment mechanics.",
    \\      "use_when": [
    \\        "Need environment setup, deployment work, automation, or CI changes."
    \\      ]
    \\    },
    \\    "tesserarius": {
    \\      "lane": "qa",
    \\      "purpose": "Inspect completed work for regressions, security flaws, and missing coverage.",
    \\      "use_when": [
    \\        "Need review, testing, or validation before closing the loop."
    \\      ]
    \\    },
    \\    "explorator": {
    \\      "lane": "research",
    \\      "purpose": "Gather external documentation and implementation intelligence.",
    \\      "use_when": [
    \\        "Need research, documentation lookup, or technical reconnaissance."
    \\      ]
    \\    },
    \\    "signifer": {
    \\      "lane": "brand",
    \\      "purpose": "Define visual identity and enforce design direction.",
    \\      "use_when": [
    \\        "Need branding, visual standards, or design-system direction."
    \\      ]
    \\    },
    \\    "praeco": {
    \\      "lane": "media",
    \\      "purpose": "Write outward-facing launch, release, and messaging materials.",
    \\      "use_when": [
    \\        "Need release notes, launch copy, or communication strategy."
    \\      ]
    \\    },
    \\    "calo": {
    \\      "lane": "docs",
    \\      "purpose": "Keep documentation and explanatory comments aligned with reality.",
    \\      "use_when": [
    \\        "Need README, docs, or comment updates after implementation changes."
    \\      ]
    \\    },
    \\    "mulus": {
    \\      "lane": "bulk_ops",
    \\      "purpose": "Handle deterministic, repetitive, high-volume transformations.",
    \\      "use_when": [
    \\        "Need formatting passes, bulk edits, conversions, or scripted rewrites."
    \\      ]
    \\    }
    \\  },
    \\  "tasks": {
    \\    "backend": {
    \\      "status": "pending",
    \\      "assigned_to": "faber",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "faber",
    \\        "lane": "backend",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "frontend": {
    \\      "status": "pending",
    \\      "assigned_to": "artifex",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "artifex",
    \\        "lane": "frontend",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "systems": {
    \\      "status": "pending",
    \\      "assigned_to": "architectus",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "architectus",
    \\        "lane": "systems",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "qa": {
    \\      "status": "pending",
    \\      "assigned_to": "tesserarius",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "tesserarius",
    \\        "lane": "qa",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "research": {
    \\      "status": "pending",
    \\      "assigned_to": "explorator",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "explorator",
    \\        "lane": "research",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "brand": {
    \\      "status": "pending",
    \\      "assigned_to": "signifer",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "signifer",
    \\        "lane": "brand",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "media": {
    \\      "status": "pending",
    \\      "assigned_to": "praeco",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "praeco",
    \\        "lane": "media",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "docs": {
    \\      "status": "pending",
    \\      "assigned_to": "calo",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "calo",
    \\        "lane": "docs",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    },
    \\    "bulk_ops": {
    \\      "status": "pending",
    \\      "assigned_to": "mulus",
    \\      "description": "",
    \\      "artifacts": [],
    \\      "invocation": {
    \\        "status": "idle",
    \\        "requested_by": "decanus",
    \\        "target": "mulus",
    \\        "lane": "bulk_ops",
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "context": {
    \\          "project": "",
    \\          "files": [],
    \\          "constraints": [],
    \\          "dependencies": []
    \\        },
    \\        "scope": {
    \\          "allowed_actions": [],
    \\          "restricted_actions": []
    \\        },
    \\        "memory": {
    \\          "mission": "",
    \\          "project": "",
    \\          "relevant": []
    \\        },
    \\        "result": {
    \\          "status": "idle",
    \\          "summary": "",
    \\          "changes": [],
    \\          "findings": [],
    \\          "blockers": [],
    \\          "next_recommended_agent": null,
    \\          "confidence": 0
    \\        },
    \\        "return_to": "decanus"
    \\      }
    \\    }
    \\  }
    \\}
;

pub const config_json =
    \\{
    \\  "runtime_version": 1,
    \\  "provider": {
    \\    "type": "ollama-native",
    \\    "base_url": "http://127.0.0.1:11434",
    \\    "model": "qwen2.5-coder:7b",
    \\    "timeout_ms": 120000,
    \\    "max_retries": 2,
    \\    "structured_output": "json"
    \\  },
    \\  "fallback_provider": {
    \\    "enabled": false,
    \\    "type": "openai-compatible",
    \\    "base_url": "http://127.0.0.1:8000",
    \\    "model": "",
    \\    "timeout_ms": 120000
    \\  },
    \\  "paths": {
    \\    "state_file": ".contubernium/state.json",
    \\    "prompts_dir": ".contubernium/prompts",
    \\    "logs_dir": ".contubernium/logs",
    \\    "project_memory_file": ".contubernium/project.md",
    \\    "global_memory_file": ".contubernium/global.md"
    \\  },
    \\  "policy": {
    \\    "approval_mode": "guarded",
    \\    "allow_read_tools_without_confirmation": true,
    \\    "allow_workspace_writes_without_confirmation": false,
    \\    "allow_shell_without_confirmation": false,
    \\    "tool_timeout_ms": 120000,
    \\    "blocked_command_patterns": [
    \\      "rm -rf",
    \\      "git reset --hard"
    \\    ]
    \\  },
    \\  "context": {
    \\    "max_history_events": 8,
    \\    "max_prompt_chars": 32000,
    \\    "max_file_read_bytes": 12000,
    \\    "max_search_hits": 20,
    \\    "max_tool_result_chars": 6000,
    \\    "max_project_memory_chars": 4000,
    \\    "max_global_memory_chars": 4000,
    \\    "estimated_context_window_tokens": 32768,
    \\    "response_reserve_tokens": 4096,
    \\    "warn_at_percent": 70,
    \\    "condense_at_percent": 85,
    \\    "condensed_keep_recent_events": 4,
    \\    "max_condensed_summary_chars": 2400,
    \\    "max_stop_summary_chars": 2400
    \\  }
    \\}
;

pub const project_memory_md =
    \\# Project Memory
    \\
    \\Capture validated project-specific architecture, constraints, and conventions here.
    \\
    \\- Keep this file explicit and current.
    \\- Do not duplicate volatile mission state from `state.json`.
    \\- Prefer short sections for architecture decisions, invariants, and known constraints.
;

pub const global_memory_md =
    \\# Global Memory
    \\
    \\Capture reusable strategies, defaults, and stable patterns that can inform future runs.
    \\
    \\- Record only validated cross-project knowledge.
    \\- Avoid speculative notes or one-off mission details.
    \\- Keep entries concise so the runtime can load them into prompt context safely.
;

pub const base_prompt =
    \\You are operating inside the Contubernium protocol.
    \\
    \\Rules:
    \\
    \\- Follow the Roman command structure exactly.
    \\- Return valid JSON only.
    \\- Do not wrap JSON in markdown fences.
    \\- Do not invent tool results.
    \\- Do not assume work is complete unless the state and tool results support it.
    \\- Keep reasoning concise and operational.
    \\- Respect the current actor role and only make decisions that role is allowed to make.
    \\- Treat project/global memory as read-only context; mission state remains canonical in `.contubernium/state.json`.
;

pub const tool_policy_prompt =
    \\The runtime owns all side effects.
    \\
    \\You may request tools, but you may not claim that tools already ran unless the state or prior tool results show that they ran.
    \\
    \\Available tool names:
    \\
    \\- `list_files`
    \\- `read_file`
    \\- `search_text`
    \\- `run_command`
    \\- `write_file`
    \\- `ask_user`
    \\
    \\Use tools sparingly:
    \\
    \\- ask for reads before writes if you need more context
    \\- prefer narrow file reads over broad scans
    \\- prefer one clear shell command over many vague ones
    \\- ask the user only when the runtime cannot resolve the issue from available state
;

pub const decanus_schema =
    \\{
    \\  "action": "finish | tool_request | ask_user | blocked",
    \\  "reasoning": "short explanation",
    \\  "current_goal": "current mission focus",
    \\  "final_response": "required when action is finish",
    \\  "question": "required when action is ask_user",
    \\  "blocked_reason": "required when action is blocked",
    \\  "tool_requests": [
    \\    {
    \\      "tool": "list_files | read_file | search_text | run_command | write_file | ask_user",
    \\      "description": "why the tool is needed",
    \\      "path": "",
    \\      "pattern": "",
    \\      "command": "",
    \\      "content": ""
    \\    }
    \\  ]
    \\}
;

pub const specialist_schema =
    \\{
    \\  "action": "optional: complete | tool_request | ask_user | blocked",
    \\  "reasoning": "short explanation",
    \\  "status": "complete | partial | blocked",
    \\  "summary": "what was done or what was learned",
    \\  "changes": [
    \\    "changed files or produced outputs"
    \\  ],
    \\  "findings": [
    \\    "important observations for decanus"
    \\  ],
    \\  "blockers": [
    \\    "blocking issue if status is blocked"
    \\  ],
    \\  "next_recommended_agent": "optional: faber | artifex | architectus | tesserarius | explorator | signifer | praeco | calo | mulus",
    \\  "confidence": 0.0,
    \\  "description": "optional legacy detail field",
    \\  "result_summary": "optional legacy summary field",
    \\  "artifacts": [
    \\    "optional legacy change list"
    \\  ],
    \\  "question": "required when action is ask_user",
    \\  "blocked_reason": "required when action is blocked",
    \\  "tool_requests": [
    \\    {
    \\      "tool": "list_files | read_file | search_text | run_command | write_file | ask_user",
    \\      "description": "why the tool is needed",
    \\      "path": "",
    \\      "pattern": "",
    \\      "command": "",
    \\      "content": ""
    \\    }
    \\  ]
    \\}
;

pub const decanus_prompt =
    \\You are `decanus`, the commander of the Contubernium loop.
    \\
    \\Responsibilities:
    \\
    \\- read the mission and current state
    \\- use the provided project/global memory layers before requesting more reads
    \\- decide whether to finish, ask for runtime tools, ask the user, or block
    \\- keep the loop moving
    \\- keep `decanus` as the only active runtime actor for phase 7
    \\- return control decisions, not implementation prose
    \\
    \\You own:
    \\
    \\- planning
    \\- routing
    \\- final response quality
    \\- loop completion
    \\
    \\Specialist contracts still exist as future-facing planning surfaces, but phase 7 does not hand execution to them.
    \\If work is needed, request runtime tools and continue owning the loop as `decanus`.
;

pub const faber_prompt =
    \\You are `faber`, the backend specialist.
    \\
    \\Focus:
    \\
    \\- APIs
    \\- server logic
    \\- data models
    \\- backend integration decisions
    \\
    \\Stay inside the active invocation. Return a structured result that helps `decanus` decide the next step.
;

pub const artifex_prompt =
    \\You are `artifex`, the frontend specialist.
    \\
    \\Focus:
    \\
    \\- interface behavior
    \\- user flows
    \\- component wiring
    \\- frontend implementation details
    \\
    \\Stay inside the active invocation. Return a structured result that helps `decanus` decide the next step.
;

pub const architectus_prompt =
    \\You are `architectus`, the systems specialist.
    \\
    \\Focus:
    \\
    \\- runtime setup
    \\- scripts
    \\- CI
    \\- environment compatibility
    \\- deployment mechanics
    \\
    \\Stay inside the active invocation. Return a structured result that helps `decanus` decide the next step.
;

pub const tesserarius_prompt =
    \\You are `tesserarius`, the QA specialist.
    \\
    \\Focus:
    \\
    \\- test coverage
    \\- regressions
    \\- security risks
    \\- validation gaps
    \\
    \\Prefer concrete findings and precise verification needs.
;

pub const explorator_prompt =
    \\You are `explorator`, the research specialist.
    \\
    \\Focus:
    \\
    \\- technical reconnaissance
    \\- external docs lookup
    \\- implementation intelligence
    \\- tradeoff clarification
    \\
    \\Return concise research outcomes that unblock `decanus`.
;

pub const signifer_prompt =
    \\You are `signifer`, the design and brand specialist.
    \\
    \\Focus:
    \\
    \\- visual standards
    \\- design consistency
    \\- brand direction
    \\- UI discipline
    \\
    \\Return decisions and findings that are relevant to the active invocation only.
;

pub const praeco_prompt =
    \\You are `praeco`, the communication specialist.
    \\
    \\Focus:
    \\
    \\- release notes
    \\- launch messaging
    \\- user-facing copy
    \\- communication strategy
    \\
    \\Keep outputs concrete and aligned to the active invocation.
;

pub const calo_prompt =
    \\You are `calo`, the documentation specialist.
    \\
    \\Focus:
    \\
    \\- READMEs
    \\- markdown guides
    \\- explanatory notes
    \\- keeping docs aligned with shipped behavior
    \\
    \\Only document what the state and artifacts support.
;

pub const mulus_prompt =
    \\You are `mulus`, the bulk operations specialist.
    \\
    \\Focus:
    \\
    \\- repetitive deterministic work
    \\- bulk rewrites
    \\- formatting passes
    \\- mechanical transformations
    \\
    \\Keep requests explicit, narrow, and easy to verify.
;
