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
    \\    "active_tool": "",
    \\    "last_decision": "",
    \\    "last_tool_result": "",
    \\    "history": []
    \\  },
    \\  "runtime_session": {
    \\    "status": "idle",
    \\    "provider": "",
    \\    "model": "",
    \\    "endpoint": "",
    \\    "approval_mode": "guarded",
    \\    "current_turn_id": "",
    \\    "last_health_check": "",
    \\    "last_error": "",
    \\    "active_log_path": "",
    \\    "last_actor": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\        "iteration": 0,
    \\        "objective": "",
    \\        "completion_signal": "",
    \\        "dependencies": [],
    \\        "result_summary": "",
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
    \\    "logs_dir": ".contubernium/logs"
    \\  },
    \\  "policy": {
    \\    "approval_mode": "guarded",
    \\    "allow_read_tools_without_confirmation": true,
    \\    "allow_workspace_writes_without_confirmation": false,
    \\    "allow_shell_without_confirmation": false,
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
    \\  "action": "finish | invoke_specialist | tool_request | ask_user | blocked",
    \\  "reasoning": "short explanation",
    \\  "current_goal": "current mission focus",
    \\  "lane": "backend | frontend | systems | qa | research | brand | media | docs | bulk_ops",
    \\  "actor": "faber | artifex | architectus | tesserarius | explorator | signifer | praeco | calo | mulus",
    \\  "objective": "specialist objective when invoking a specialist",
    \\  "completion_signal": "how completion will be judged",
    \\  "dependencies": [
    \\    "optional dependency list"
    \\  ],
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
    \\  "action": "complete | tool_request | ask_user | blocked",
    \\  "reasoning": "short explanation",
    \\  "description": "what changed or what was learned",
    \\  "result_summary": "short result summary",
    \\  "artifacts": [
    \\    "changed files or produced outputs"
    \\  ],
    \\  "follow_up_needed": "optional suggestion for decanus",
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
    \\- decide whether to finish, invoke a specialist, ask for tools, ask the user, or block
    \\- keep the loop moving
    \\- keep specialist invocations narrow and concrete
    \\- return control decisions, not implementation prose
    \\
    \\You own:
    \\
    \\- planning
    \\- routing
    \\- final response quality
    \\- loop completion
    \\
    \\You do not directly execute implementation work. If work is needed, request tools or invoke the correct specialist.
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
