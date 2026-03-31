const std = @import("std");
const protocol = @import("runtime_protocol.zig");

pub const max_file_bytes = 16 * 1024 * 1024;
pub const runtime_dir_name = ".contubernium";
pub const default_state_path = ".contubernium/state.json";
pub const default_config_path = ".contubernium/config.json";
pub const default_logs_dir = ".contubernium/logs";
pub const default_project_memory_path = ".contubernium/project.md";
pub const default_global_memory_path = ".contubernium/global.md";
pub const default_architecture_path = ".contubernium/ARCHITECTURE.md";
pub const default_plan_path = ".contubernium/PLAN.md";
pub const default_project_context_path = ".contubernium/PROJECT_CONTEXT.md";
pub const max_list_files_entries = 400;
pub const legacy_default_max_iterations = 12;
pub const default_max_iterations = 24;
pub const default_context_window_tokens = 32768;
pub const default_response_reserve_tokens = 4096;
pub const default_tool_timeout_ms = 120000;
pub const default_max_project_memory_chars = 4000;
pub const default_max_global_memory_chars = 4000;

pub const Actor = protocol.Actor;
pub const Lane = protocol.Lane;
pub const GlobalStatus = protocol.GlobalStatus;
pub const LoopStatus = protocol.LoopStatus;
pub const RuntimeStatus = protocol.RuntimeStatus;
pub const TaskStatus = protocol.TaskStatus;
pub const InvocationStatus = protocol.InvocationStatus;
pub const InvocationResultStatus = protocol.InvocationResultStatus;
pub const ApprovalStatus = protocol.ApprovalStatus;
pub const ApprovalKind = protocol.ApprovalKind;
pub const LoopStepKind = protocol.LoopStepKind;
pub const Mission = protocol.Mission;
pub const Invocation = protocol.Invocation;
pub const InvocationResult = protocol.InvocationResult;
pub const ApprovalRequest = protocol.ApprovalRequest;
pub const LoopStep = protocol.LoopStep;
pub const StateSnapshot = protocol.StateSnapshot;

pub const AppConfig = struct {
    runtime_version: usize = 1,
    provider: ProviderConfig = .{},
    fallback_provider: ProviderConfig = .{},
    paths: PathsConfig = .{},
    policy: PolicyConfig = .{},
    context: ContextConfig = .{},
};

pub const ProviderConfig = struct {
    enabled: bool = true,
    type: []const u8 = "ollama-native",
    base_url: []const u8 = "http://127.0.0.1:11434",
    model: []const u8 = "qwen2.5-coder:7b",
    timeout_ms: usize = 120000,
    max_retries: usize = 2,
    structured_output: []const u8 = "json",
};

pub const PathsConfig = struct {
    state_file: []const u8 = default_state_path,
    logs_dir: []const u8 = default_logs_dir,
    project_memory_file: []const u8 = default_project_memory_path,
    global_memory_file: []const u8 = default_global_memory_path,
    architecture_file: []const u8 = default_architecture_path,
    plan_file: []const u8 = default_plan_path,
    project_context_file: []const u8 = default_project_context_path,
};

pub const PolicyConfig = struct {
    approval_mode: []const u8 = "guarded",
    allow_read_tools_without_confirmation: bool = true,
    allow_workspace_writes_without_confirmation: bool = false,
    allow_shell_without_confirmation: bool = false,
    tool_timeout_ms: usize = default_tool_timeout_ms,
    blocked_command_patterns: []const []const u8 = &.{
        "rm -rf",
        "git reset --hard",
    },
};

pub const ContextConfig = struct {
    max_history_events: usize = 8,
    max_prompt_chars: usize = 32000,
    max_file_read_bytes: usize = 12000,
    max_search_hits: usize = 20,
    max_tool_result_chars: usize = 6000,
    max_project_memory_chars: usize = default_max_project_memory_chars,
    max_global_memory_chars: usize = default_max_global_memory_chars,
    estimated_context_window_tokens: usize = default_context_window_tokens,
    response_reserve_tokens: usize = default_response_reserve_tokens,
    warn_at_percent: usize = 70,
    condense_at_percent: usize = 85,
    condensed_keep_recent_events: usize = 4,
    max_condensed_summary_chars: usize = 2400,
    max_stop_summary_chars: usize = 2400,
};

pub const AppState = struct {
    project_name: []const u8 = "UNASSIGNED",
    global_status: GlobalStatus = .idle,
    current_actor: Actor = .decanus,
    mission: Mission = .{},
    agent_loop: AgentLoop = .{},
    runtime_session: RuntimeSession = .{},
    agent_tools: AgentTools = .{},
    tasks: Tasks = .{},
};

pub const AgentLoop = struct {
    status: LoopStatus = .awaiting_initial_prompt,
    iteration: usize = 0,
    max_iterations: usize = default_max_iterations,
    active_tool: ?Actor = null,
    last_step: LoopStep = .{},
    last_decision: []const u8 = "",
    last_tool_result: []const u8 = "",
    intermediate_results: []const IntermediateResult = &.{},
    history: []const HistoryEntry = &.{},
};

pub const ContextBudgetState = struct {
    estimated_prompt_chars: usize = 0,
    estimated_prompt_tokens: usize = 0,
    context_window_tokens: usize = 0,
    response_reserve_tokens: usize = 0,
    remaining_tokens: usize = 0,
    used_percent: usize = 0,
    condensation_count: usize = 0,
    condensed_history_events: usize = 0,
    last_condensed_iteration: usize = 0,
};

pub const RuntimeErrorContext = struct {
    actor: []const u8 = "",
    lane: []const u8 = "",
    tool: []const u8 = "",
    target: []const u8 = "",
    command: []const u8 = "",
    detail: []const u8 = "",
    provider: []const u8 = "",
    model: []const u8 = "",
    turn_id: []const u8 = "",
    iteration: usize = 0,
};

pub const RuntimeFailure = struct {
    error_code: []const u8 = "",
    message: []const u8 = "",
    context: RuntimeErrorContext = .{},
};

pub const RuntimeFailureContextSpec = struct {
    tool: []const u8 = "",
    target: []const u8 = "",
    command: []const u8 = "",
    detail: []const u8 = "",
};

pub const RuntimeSession = struct {
    status: RuntimeStatus = .idle,
    provider: []const u8 = "",
    model: []const u8 = "",
    endpoint: []const u8 = "",
    approval_mode: []const u8 = "guarded",
    active_approval: ApprovalRequest = .{},
    current_turn_id: []const u8 = "",
    last_health_check: []const u8 = "",
    last_error: []const u8 = "",
    last_failure: RuntimeFailure = .{},
    active_log_path: []const u8 = "",
    last_actor: Actor = .decanus,
    repair_attempts: usize = 0,
    context_budget: ContextBudgetState = .{},
};

pub const HistoryEntry = struct {
    iteration: usize = 0,
    type: []const u8 = "",
    actor: []const u8 = "",
    lane: []const u8 = "",
    summary: []const u8 = "",
    artifacts: []const []const u8 = &.{},
    timestamp: []const u8 = "",
};

pub const IntermediateResult = struct {
    iteration: usize = 0,
    actor: Actor = .decanus,
    lane: Lane = .command,
    kind: []const u8 = "",
    summary: []const u8 = "",
};

pub const AgentTool = struct {
    lane: []const u8 = "",
    purpose: []const u8 = "",
    use_when: []const []const u8 = &.{},
};

pub const AgentTools = struct {
    faber: AgentTool = .{},
    artifex: AgentTool = .{},
    architectus: AgentTool = .{},
    tesserarius: AgentTool = .{},
    explorator: AgentTool = .{},
    signifer: AgentTool = .{},
    praeco: AgentTool = .{},
    calo: AgentTool = .{},
    mulus: AgentTool = .{},
};

pub const TaskLane = struct {
    status: TaskStatus = .pending,
    assigned_to: Actor = .decanus,
    description: []const u8 = "",
    artifacts: []const []const u8 = &.{},
    invocation: Invocation = .{},
};

pub const Tasks = struct {
    backend: TaskLane = .{ .assigned_to = .faber },
    frontend: TaskLane = .{ .assigned_to = .artifex },
    systems: TaskLane = .{ .assigned_to = .architectus },
    qa: TaskLane = .{ .assigned_to = .tesserarius },
    research: TaskLane = .{ .assigned_to = .explorator },
    brand: TaskLane = .{ .assigned_to = .signifer },
    media: TaskLane = .{ .assigned_to = .praeco },
    docs: TaskLane = .{ .assigned_to = .calo },
    bulk_ops: TaskLane = .{ .assigned_to = .mulus },
};

pub const ToolRequest = struct {
    tool: []const u8 = "",
    description: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
};

pub const RuntimeToolKind = enum {
    list_files,
    read_file,
    search_text,
    run_command,
    write_file,
    ask_user,
};

pub const ToolApprovalGate = enum {
    none,
    read,
    shell,
    write,
};

pub const RuntimeToolSpec = struct {
    kind: RuntimeToolKind,
    name: []const u8,
    approval_gate: ToolApprovalGate = .none,
};

pub const ValidatedToolRequest = struct {
    spec: RuntimeToolSpec,
    detail: []const u8 = "",
    target: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
};

pub const ToolRequestValidation = union(enum) {
    ok: ValidatedToolRequest,
    blocked: RuntimeFailure,
};

pub const DecanusDecision = struct {
    action: []const u8 = "",
    reasoning: []const u8 = "",
    current_goal: []const u8 = "",
    agent_call: []const u8 = "",
    lane: []const u8 = "",
    actor: []const u8 = "",
    objective: []const u8 = "",
    completion_signal: []const u8 = "",
    dependencies: []const []const u8 = &.{},
    final_response: []const u8 = "",
    question: []const u8 = "",
    blocked_reason: []const u8 = "",
    tool_requests: []const ToolRequest = &.{},
};

pub const SpecialistResult = struct {
    action: []const u8 = "",
    reasoning: []const u8 = "",
    status: []const u8 = "",
    summary: []const u8 = "",
    changes: []const []const u8 = &.{},
    findings: []const []const u8 = &.{},
    blockers: []const []const u8 = &.{},
    next_recommended_agent: []const u8 = "",
    confidence: f32 = 0.0,
    description: []const u8 = "",
    result_summary: []const u8 = "",
    artifacts: []const []const u8 = &.{},
    follow_up_needed: []const u8 = "",
    question: []const u8 = "",
    blocked_reason: []const u8 = "",
    tool_requests: []const ToolRequest = &.{},
};

pub const SmokeResponse = struct {
    status: []const u8 = "",
};

pub const ProviderResponse = struct {
    raw_text: []const u8,
    transport_text: []const u8,
    provider_name: []const u8,
    model_name: []const u8,
    latency_ms: i64,
};

pub const CommandResult = struct {
    stdout: []const u8,
    stderr: []const u8,
    exit_code: i32,
};

pub const StepOutcome = enum {
    advanced,
    complete,
    blocked,
};

pub const PromptMode = enum {
    decanus,
    specialist,
};

pub const PromptBudgetEstimate = struct {
    prompt_chars: usize,
    prompt_tokens: usize,
    usable_prompt_tokens: usize,
    remaining_tokens: usize,
    used_percent: usize,
    should_warn: bool,
    should_condense: bool,
    exhausted: bool,
};

pub const RuntimeMemorySpec = struct {
    kind: []const u8,
    path: []const u8,
    max_chars: usize,
};

pub const RuntimeMemoryLayer = struct {
    kind: []const u8,
    path: []const u8,
    content: []const u8 = "",
    source_chars: usize = 0,
    truncated: bool = false,
    owns_content: bool = false,

    fn deinit(self: RuntimeMemoryLayer, allocator: std.mem.Allocator) void {
        if (self.owns_content) allocator.free(self.content);
    }
};

pub const RuntimeMemorySnapshot = struct {
    architecture: RuntimeMemoryLayer,
    plan: RuntimeMemoryLayer,
    project_context: RuntimeMemoryLayer,
    project: RuntimeMemoryLayer,
    global: RuntimeMemoryLayer,

    fn deinit(self: RuntimeMemorySnapshot, allocator: std.mem.Allocator) void {
        self.architecture.deinit(allocator);
        self.plan.deinit(allocator);
        self.project_context.deinit(allocator);
        self.project.deinit(allocator);
        self.global.deinit(allocator);
    }
};

pub const PromptBuildResult = struct {
    user_prompt: []const u8,
    memory: RuntimeMemorySnapshot,
};

pub const GlobalAssetLayout = struct {
    root: []const u8,
    agents_root: []const u8,
    shared_root: []const u8,
    adapters_root: []const u8,
};

pub const AgentCallSpec = struct {
    actor: Actor,
    action_name: []const u8 = "",
    explicit_action: bool = false,
};

pub const ResolvedAgentCall = struct {
    actor: Actor,
    action_name: []const u8,
    agent_call: []const u8,
};

pub const ResolvedSpecialistInvocation = struct {
    actor: Actor,
    lane: Lane,
    agent_call: []const u8,
    action_name: []const u8,
};

pub const StateManager = struct {
    state: *AppState,

    fn init(state: *AppState) StateManager {
        return .{ .state = state };
    }

    fn clearFailure(self: StateManager) void {
        self.state.runtime_session.last_error = "";
        self.state.runtime_session.last_failure = .{};
    }

    fn recordFailure(self: StateManager, failure: RuntimeFailure) void {
        self.state.runtime_session.last_error = failure.message;
        self.state.runtime_session.last_failure = failure;
    }

    fn resetForMission(self: StateManager, mission_prompt: []const u8) void {
        self.state.global_status = .planning;
        self.state.current_actor = .decanus;
        self.state.mission.initial_prompt = mission_prompt;
        self.state.mission.current_goal = mission_prompt;
        self.state.mission.success_criteria = &.{};
        self.state.mission.constraints = &.{};
        self.state.mission.final_response = "";
        self.state.agent_loop = .{};
        self.state.agent_loop.last_step = .{
            .iteration = 0,
            .kind = .think,
            .actor = .decanus,
            .lane = .command,
            .summary = "mission initialized",
        };
        self.state.runtime_session = .{};
        self.state.tasks = .{};
        ensureLoopBudget(self.state);
    }

    fn initializeRuntimeSession(self: StateManager, config: AppConfig) void {
        ensureLoopBudget(self.state);
        self.state.runtime_session.provider = config.provider.type;
        self.state.runtime_session.model = config.provider.model;
        self.state.runtime_session.endpoint = config.provider.base_url;
        self.state.runtime_session.approval_mode = config.policy.approval_mode;
        self.state.runtime_session.context_budget.context_window_tokens = config.context.estimated_context_window_tokens;
        self.state.runtime_session.context_budget.response_reserve_tokens = config.context.response_reserve_tokens;
        if (self.state.runtime_session.context_budget.estimated_prompt_tokens == 0) {
            self.state.runtime_session.context_budget.remaining_tokens = usablePromptTokenWindow(config.context);
            self.state.runtime_session.context_budget.used_percent = 0;
        }
        if (self.state.runtime_session.status == .idle) {
            self.state.runtime_session.status = .ready;
        }
    }

    fn beginTurn(self: StateManager, allocator: std.mem.Allocator, config: AppConfig) !void {
        self.state.agent_loop.iteration += 1;
        self.state.runtime_session.status = .running;
        self.clearFailure();
        self.state.runtime_session.provider = config.provider.type;
        self.state.runtime_session.model = config.provider.model;
        self.state.runtime_session.endpoint = config.provider.base_url;
        self.state.runtime_session.approval_mode = config.policy.approval_mode;
        self.state.runtime_session.last_actor = self.state.current_actor;
        self.state.runtime_session.current_turn_id = try makeTurnId(
            allocator,
            actorName(self.state.current_actor),
            self.state.agent_loop.iteration,
        );
    }

    fn beginCommanderThinking(self: StateManager) void {
        self.state.global_status = .planning;
        self.state.agent_loop.status = .thinking;
        setLoopStep(
            self.state,
            .think,
            .decanus,
            .command,
            if (self.state.mission.current_goal.len > 0) self.state.mission.current_goal else self.state.mission.initial_prompt,
        );
    }

    fn beginSpecialistExecution(self: StateManager, actor: Actor, lane: Lane, objective: []const u8) void {
        const task = taskForLane(self.state, lane);
        task.invocation.status = .running;
        self.state.global_status = .waiting_on_tool;
        self.state.agent_loop.status = .running_tool;
        setLoopStep(self.state, .execute, actor, lane, objective);
    }

    fn markBlocked(self: StateManager, actor: Actor, lane: Lane, summary: []const u8) void {
        self.state.global_status = .waiting_on_tool;
        self.state.agent_loop.status = .blocked;
        self.state.runtime_session.status = .blocked;
        setLoopStep(self.state, .blocked, actor, lane, summary);
    }

    fn markMissionComplete(self: StateManager, actor: Actor, lane: Lane, final_response: []const u8) void {
        self.state.mission.final_response = final_response;
        self.state.global_status = .complete;
        self.state.agent_loop.status = .complete;
        self.state.runtime_session.status = .complete;
        setLoopStep(self.state, .finish, actor, lane, final_response);
    }

    fn markInterrupted(self: StateManager) void {
        self.state.global_status = .interrupted;
        self.state.agent_loop.status = .interrupted;
        self.state.runtime_session.status = .interrupted;
        self.recordFailure(buildRuntimeFailure(
            self.state,
            self.state.current_actor,
            laneForActor(self.state.current_actor),
            "LOOP_INTERRUPTED",
            "operator interrupted the active loop",
            .{},
        ));
        setLoopStep(
            self.state,
            .blocked,
            self.state.current_actor,
            laneForActor(self.state.current_actor),
            self.state.runtime_session.last_error,
        );
    }

    fn setCurrentGoal(self: StateManager, goal: []const u8) void {
        if (goal.len == 0) return;
        self.state.mission.current_goal = goal;
    }

    fn setLastDecision(self: StateManager, decision: []const u8) void {
        self.state.agent_loop.last_decision = decision;
    }

    fn recordToolResult(self: StateManager, summary: []const u8) void {
        self.state.agent_loop.last_tool_result = summary;
    }

    fn recordRuntimeToolResultStep(
        self: StateManager,
        allocator: std.mem.Allocator,
        actor: Actor,
        lane: Lane,
        summary: []const u8,
    ) !void {
        self.recordToolResult(summary);
        if (actor == .decanus) {
            self.state.global_status = .planning;
            self.state.agent_loop.status = .thinking;
        } else {
            self.state.global_status = .waiting_on_tool;
            self.state.agent_loop.status = .running_tool;
            taskForLane(self.state, lane).invocation.status = .running;
        }
        setLoopStep(self.state, .result, actor, lane, summary);
        try self.appendIntermediateResult(allocator, "runtime_tool_result", actor, lane, summary);
        try appendHistory(allocator, self.state, .{
            .iteration = self.state.agent_loop.iteration,
            .type = "runtime_tool_result",
            .actor = actorName(actor),
            .lane = if (lane == .command) "" else laneName(lane),
            .summary = summary,
            .artifacts = &.{},
            .timestamp = try unixTimestampString(allocator),
        });
    }

    fn appendIntermediateResult(
        self: StateManager,
        allocator: std.mem.Allocator,
        kind: []const u8,
        actor: Actor,
        lane: Lane,
        summary: []const u8,
    ) !void {
        var results: std.ArrayList(IntermediateResult) = .empty;
        const previous = self.state.agent_loop.intermediate_results;
        try results.appendSlice(allocator, previous);
        try results.append(allocator, .{
            .iteration = self.state.agent_loop.iteration,
            .actor = actor,
            .lane = lane,
            .kind = kind,
            .summary = summary,
        });
        self.state.agent_loop.intermediate_results = try results.toOwnedSlice(allocator);
        if (previous.len > 0) allocator.free(previous);
    }

    fn beginApprovalRequest(
        self: StateManager,
        actor: Actor,
        lane: Lane,
        tool_name: []const u8,
        detail: []const u8,
        reason: []const u8,
        target: []const u8,
    ) void {
        self.state.runtime_session.active_approval = .{
            .status = .pending,
            .kind = protocol.approvalKindForToolName(tool_name),
            .requested_by = actor,
            .lane = lane,
            .tool_name = tool_name,
            .detail = detail,
            .reason = reason,
            .target = target,
        };
        self.state.runtime_session.status = .awaiting_approval;
        setLoopStep(self.state, .wait_for_approval, actor, lane, tool_name);
    }

    fn resolveApprovalRequest(self: StateManager, approved: bool) void {
        self.state.runtime_session.active_approval.status = if (approved) .approved else .denied;
        if (self.state.runtime_session.status == .awaiting_approval) {
            self.state.runtime_session.status = .running;
        }
    }

    fn prepareInvocation(
        self: StateManager,
        lane: Lane,
        actor: Actor,
        objective: []const u8,
        completion_signal: []const u8,
        dependencies: []const []const u8,
        agent_call: []const u8,
        action_name: []const u8,
    ) void {
        const task = taskForLane(self.state, lane);
        task.status = .in_progress;
        task.description = objective;
        task.invocation = .{
            .status = .ready,
            .requested_by = .decanus,
            .target = actor,
            .lane = lane,
            .agent_call = agent_call,
            .action_name = action_name,
            .iteration = self.state.agent_loop.iteration,
            .objective = objective,
            .completion_signal = completion_signal,
            .context = .{
                .project = self.state.project_name,
                .files = dependencies,
                .constraints = self.state.mission.constraints,
                .dependencies = dependencies,
            },
            .scope = .{
                .allowed_actions = protocol.allowedActionsForActor(actor),
                .restricted_actions = protocol.restrictedActionsForActor(actor),
            },
            .memory = .{
                .mission = if (self.state.mission.current_goal.len > 0) self.state.mission.current_goal else self.state.mission.initial_prompt,
                .project = self.state.agent_loop.last_tool_result,
                .relevant = dependencies,
            },
            .return_to = .decanus,
        };
        self.state.current_actor = actor;
        self.state.global_status = .waiting_on_tool;
        self.state.agent_loop.status = .running_tool;
        self.state.agent_loop.active_tool = actor;
        setLoopStep(self.state, .invoke, .decanus, lane, objective);
    }

    fn prepareInvocationWithHistory(
        self: StateManager,
        allocator: std.mem.Allocator,
        lane: Lane,
        actor: Actor,
        objective: []const u8,
        completion_signal: []const u8,
        dependencies: []const []const u8,
        agent_call: []const u8,
        action_name: []const u8,
    ) !void {
        self.prepareInvocation(lane, actor, objective, completion_signal, dependencies, agent_call, action_name);
        try appendHistory(allocator, self.state, .{
            .iteration = self.state.agent_loop.iteration,
            .type = "tool_call",
            .actor = "decanus",
            .lane = laneName(lane),
            .summary = objective,
            .artifacts = &.{},
            .timestamp = try unixTimestampString(allocator),
        });
    }

    fn finalizeInvocation(
        self: StateManager,
        lane: Lane,
        actor: Actor,
        result: InvocationResult,
        description: []const u8,
    ) void {
        const task = taskForLane(self.state, lane);
        task.status = if (result.status == .blocked) .blocked else .complete;
        task.description = if (description.len > 0) description else result.summary;
        task.artifacts = result.changes;
        task.invocation.result = result;
        task.invocation.status = protocol.invocationStatusForResult(result.status);
        self.state.current_actor = .decanus;
        self.state.global_status = if (result.status == .blocked) .waiting_on_tool else .planning;
        self.state.agent_loop.status = if (result.status == .blocked) .blocked else .thinking;
        self.state.agent_loop.active_tool = null;
        self.state.agent_loop.last_tool_result = result.summary;
        self.state.runtime_session.status = if (result.status == .blocked) .blocked else .idle;
        setLoopStep(self.state, if (result.status == .blocked) .blocked else .result, actor, lane, result.summary);
    }

    fn finalizeInvocationWithHistory(
        self: StateManager,
        allocator: std.mem.Allocator,
        lane: Lane,
        actor: Actor,
        result: InvocationResult,
        description: []const u8,
    ) !void {
        self.finalizeInvocation(lane, actor, result, description);
        try self.appendIntermediateResult(allocator, "invocation_result", actor, lane, result.summary);
        try appendHistory(allocator, self.state, .{
            .iteration = self.state.agent_loop.iteration,
            .type = "tool_result",
            .actor = actorName(actor),
            .lane = laneName(lane),
            .summary = result.summary,
            .artifacts = result.changes,
            .timestamp = try unixTimestampString(allocator),
        });
    }

    fn completeMissionWithHistory(
        self: StateManager,
        allocator: std.mem.Allocator,
        actor: Actor,
        lane: Lane,
        final_response: []const u8,
    ) !void {
        self.markMissionComplete(actor, lane, final_response);
        try appendHistory(allocator, self.state, .{
            .iteration = self.state.agent_loop.iteration,
            .type = "finish",
            .actor = actorName(actor),
            .lane = if (lane == .command) "" else laneName(lane),
            .summary = final_response,
            .artifacts = &.{},
            .timestamp = try unixTimestampString(allocator),
        });
    }

    fn applyPromptBudgetEstimate(self: StateManager, config: ContextConfig, estimate: PromptBudgetEstimate) void {
        self.state.runtime_session.context_budget.estimated_prompt_chars = estimate.prompt_chars;
        self.state.runtime_session.context_budget.estimated_prompt_tokens = estimate.prompt_tokens;
        self.state.runtime_session.context_budget.context_window_tokens = config.estimated_context_window_tokens;
        self.state.runtime_session.context_budget.response_reserve_tokens = config.response_reserve_tokens;
        self.state.runtime_session.context_budget.remaining_tokens = estimate.remaining_tokens;
        self.state.runtime_session.context_budget.used_percent = estimate.used_percent;
    }

    fn noteHealthCheck(self: StateManager, now: []const u8, config: AppConfig) void {
        self.state.runtime_session.last_health_check = now;
        self.state.runtime_session.provider = config.provider.type;
        self.state.runtime_session.model = config.provider.model;
        self.state.runtime_session.endpoint = config.provider.base_url;
        self.state.runtime_session.approval_mode = config.policy.approval_mode;
        self.clearFailure();
    }

    fn setActiveLogPath(self: StateManager, path: []const u8) void {
        self.state.runtime_session.active_log_path = path;
    }

    fn setRepairAttempts(self: StateManager, attempts: usize) void {
        self.state.runtime_session.repair_attempts = attempts;
    }
};

pub const ToolExecutionOutcome = struct {
    blocked: bool,
    summary: []const u8,
};

pub const ToolRequestExecution = struct {
    blocked: bool = false,
    summary: []const u8,
    failure: ?RuntimeFailure = null,
};

pub const RuntimeRunLog = struct {
    format_version: usize = 1,
    run_id: []const u8 = "",
    command: []const u8 = "",
    created_at: []const u8 = "",
    updated_at: []const u8 = "",
    project_name: []const u8 = "",
    provider: []const u8 = "",
    model: []const u8 = "",
    approval_mode: []const u8 = "",
    mission_prompt: []const u8 = "",
    events: []const RuntimeLogEvent = &.{},
};

pub const RuntimeLogEvent = struct {
    timestamp: []const u8 = "",
    iteration: usize = 0,
    turn_id: []const u8 = "",
    actor: []const u8 = "",
    lane: []const u8 = "",
    action: []const u8 = "",
    status: []const u8 = "",
    tool: []const u8 = "",
    summary: []const u8 = "",
    input: []const u8 = "",
    output: []const u8 = "",
    error_text: []const u8 = "",
    failure: ?RuntimeFailure = null,
    snapshot: ?StateSnapshot = null,
};

pub const RuntimeLogEventSpec = struct {
    actor: Actor = .decanus,
    lane: Lane = .command,
    action: []const u8,
    status: []const u8 = "info",
    tool: []const u8 = "",
    summary: []const u8 = "",
    input: []const u8 = "",
    output: []const u8 = "",
    error_text: []const u8 = "",
    failure: ?RuntimeFailure = null,
    include_snapshot: bool = false,
};

pub const ChatTone = enum {
    info,
    success,
    danger,
    mission,
    agent,
    tool,
    warning,
};

pub const HighlightKind = enum {
    plain,
    json,
    command,
    summary,
};

pub const TuiSnapshot = struct {
    project_name: []const u8 = "UNASSIGNED",
    provider_type: []const u8 = "",
    model: []const u8 = "",
    logs_dir: []const u8 = default_logs_dir,
    approval_mode: []const u8 = "",
    global_status: []const u8 = "idle",
    runtime_status: []const u8 = "idle",
    loop_status: []const u8 = "awaiting_initial_prompt",
    approval_status: []const u8 = "idle",
    current_actor: []const u8 = "decanus",
    active_tool: []const u8 = "",
    active_lane: []const u8 = "",
    last_step_kind: []const u8 = "think",
    last_step_summary: []const u8 = "",
    current_goal: []const u8 = "",
    last_tool_result: []const u8 = "",
    last_error: []const u8 = "",
    last_log_path: []const u8 = "",
    iteration: usize = 0,
    max_iterations: usize = default_max_iterations,
    estimated_prompt_chars: usize = 0,
    estimated_prompt_tokens: usize = 0,
    context_window_tokens: usize = default_context_window_tokens,
    response_reserve_tokens: usize = default_response_reserve_tokens,
    remaining_context_tokens: usize = default_context_window_tokens - default_response_reserve_tokens,
    context_used_percent: usize = 0,
    condensation_count: usize = 0,
    condensed_history_events: usize = 0,
};

pub fn cloneTuiSnapshot(allocator: std.mem.Allocator, snapshot: TuiSnapshot) !TuiSnapshot {
    return .{
        .project_name = try allocator.dupe(u8, snapshot.project_name),
        .provider_type = try allocator.dupe(u8, snapshot.provider_type),
        .model = try allocator.dupe(u8, snapshot.model),
        .logs_dir = try allocator.dupe(u8, snapshot.logs_dir),
        .approval_mode = try allocator.dupe(u8, snapshot.approval_mode),
        .global_status = try allocator.dupe(u8, snapshot.global_status),
        .runtime_status = try allocator.dupe(u8, snapshot.runtime_status),
        .loop_status = try allocator.dupe(u8, snapshot.loop_status),
        .approval_status = try allocator.dupe(u8, snapshot.approval_status),
        .current_actor = try allocator.dupe(u8, snapshot.current_actor),
        .active_tool = try allocator.dupe(u8, snapshot.active_tool),
        .active_lane = try allocator.dupe(u8, snapshot.active_lane),
        .last_step_kind = try allocator.dupe(u8, snapshot.last_step_kind),
        .last_step_summary = try allocator.dupe(u8, snapshot.last_step_summary),
        .current_goal = try allocator.dupe(u8, snapshot.current_goal),
        .last_tool_result = try allocator.dupe(u8, snapshot.last_tool_result),
        .last_error = try allocator.dupe(u8, snapshot.last_error),
        .last_log_path = try allocator.dupe(u8, snapshot.last_log_path),
        .iteration = snapshot.iteration,
        .max_iterations = snapshot.max_iterations,
        .estimated_prompt_chars = snapshot.estimated_prompt_chars,
        .estimated_prompt_tokens = snapshot.estimated_prompt_tokens,
        .context_window_tokens = snapshot.context_window_tokens,
        .response_reserve_tokens = snapshot.response_reserve_tokens,
        .remaining_context_tokens = snapshot.remaining_context_tokens,
        .context_used_percent = snapshot.context_used_percent,
        .condensation_count = snapshot.condensation_count,
        .condensed_history_events = snapshot.condensed_history_events,
    };
}

pub fn freeTuiSnapshot(allocator: std.mem.Allocator, snapshot: *TuiSnapshot) void {
    allocator.free(snapshot.project_name);
    allocator.free(snapshot.provider_type);
    allocator.free(snapshot.model);
    allocator.free(snapshot.logs_dir);
    allocator.free(snapshot.approval_mode);
    allocator.free(snapshot.global_status);
    allocator.free(snapshot.runtime_status);
    allocator.free(snapshot.loop_status);
    allocator.free(snapshot.approval_status);
    allocator.free(snapshot.current_actor);
    allocator.free(snapshot.active_tool);
    allocator.free(snapshot.active_lane);
    allocator.free(snapshot.last_step_kind);
    allocator.free(snapshot.last_step_summary);
    allocator.free(snapshot.current_goal);
    allocator.free(snapshot.last_tool_result);
    allocator.free(snapshot.last_error);
    allocator.free(snapshot.last_log_path);
    snapshot.* = .{};
}

pub fn setOwnedSnapshot(allocator: std.mem.Allocator, target: *TuiSnapshot, owns_snapshot: *bool, snapshot: TuiSnapshot) !void {
    var owned = try cloneTuiSnapshot(allocator, snapshot);
    errdefer freeTuiSnapshot(allocator, &owned);
    if (owns_snapshot.*) freeTuiSnapshot(allocator, target);
    target.* = owned;
    owns_snapshot.* = true;
}

pub const WorkerCommandKind = enum {
    mission,
    resume_run,
    doctor,
    models,
};

pub const RuntimeUiEventKind = enum {
    log,
    stream_start,
    stream_chunk,
    stream_finalize,
    state_snapshot,
    approval_request,
    model_roster,
};

pub const RuntimeUiEvent = struct {
    kind: RuntimeUiEventKind,
    tone: ChatTone = .info,
    actor: []const u8 = "",
    title: []const u8 = "",
    text: []const u8 = "",
    highlight: HighlightKind = .plain,
    project_name: []const u8 = "",
    provider_type: []const u8 = "",
    model: []const u8 = "",
    logs_dir: []const u8 = default_logs_dir,
    approval_mode: []const u8 = "",
    global_status: []const u8 = "",
    runtime_status: []const u8 = "",
    loop_status: []const u8 = "",
    approval_status: []const u8 = "",
    current_actor: []const u8 = "",
    active_tool: []const u8 = "",
    active_lane: []const u8 = "",
    last_step_kind: []const u8 = "",
    last_step_summary: []const u8 = "",
    current_goal: []const u8 = "",
    last_tool_result: []const u8 = "",
    last_error: []const u8 = "",
    last_log_path: []const u8 = "",
    iteration: usize = 0,
    max_iterations: usize = default_max_iterations,
    estimated_prompt_chars: usize = 0,
    estimated_prompt_tokens: usize = 0,
    context_window_tokens: usize = default_context_window_tokens,
    response_reserve_tokens: usize = default_response_reserve_tokens,
    remaining_context_tokens: usize = default_context_window_tokens - default_response_reserve_tokens,
    context_used_percent: usize = 0,
    condensation_count: usize = 0,
    condensed_history_events: usize = 0,
};

pub const RuntimeEventQueue = struct {
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex = .{},
    items: std.ArrayList(RuntimeUiEvent) = .empty,

    fn deinit(self: *RuntimeEventQueue) void {
        for (self.items.items) |event| {
            freeRuntimeUiEvent(self.allocator, event);
        }
        self.items.deinit(self.allocator);
    }

    fn push(self: *RuntimeEventQueue, event: RuntimeUiEvent) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        const owned = self.cloneEvent(event) catch return;
        self.items.append(self.allocator, owned) catch {};
    }

    fn drain(self: *RuntimeEventQueue, allocator: std.mem.Allocator) ![]RuntimeUiEvent {
        self.mutex.lock();
        defer self.mutex.unlock();
        var drained: std.ArrayList(RuntimeUiEvent) = .empty;
        for (self.items.items) |event| {
            try drained.append(allocator, try cloneRuntimeUiEvent(allocator, event));
            freeRuntimeUiEvent(self.allocator, event);
        }
        self.items.clearRetainingCapacity();
        return try drained.toOwnedSlice(allocator);
    }

    fn cloneEvent(self: *RuntimeEventQueue, event: RuntimeUiEvent) !RuntimeUiEvent {
        return try cloneRuntimeUiEvent(self.allocator, event);
    }
};

pub fn cloneRuntimeUiEvent(allocator: std.mem.Allocator, event: RuntimeUiEvent) !RuntimeUiEvent {
    return .{
        .kind = event.kind,
        .tone = event.tone,
        .actor = try allocator.dupe(u8, event.actor),
        .title = try allocator.dupe(u8, event.title),
        .text = try allocator.dupe(u8, event.text),
        .highlight = event.highlight,
        .project_name = try allocator.dupe(u8, event.project_name),
        .provider_type = try allocator.dupe(u8, event.provider_type),
        .model = try allocator.dupe(u8, event.model),
        .logs_dir = try allocator.dupe(u8, event.logs_dir),
        .approval_mode = try allocator.dupe(u8, event.approval_mode),
        .global_status = try allocator.dupe(u8, event.global_status),
        .runtime_status = try allocator.dupe(u8, event.runtime_status),
        .loop_status = try allocator.dupe(u8, event.loop_status),
        .approval_status = try allocator.dupe(u8, event.approval_status),
        .current_actor = try allocator.dupe(u8, event.current_actor),
        .active_tool = try allocator.dupe(u8, event.active_tool),
        .active_lane = try allocator.dupe(u8, event.active_lane),
        .last_step_kind = try allocator.dupe(u8, event.last_step_kind),
        .last_step_summary = try allocator.dupe(u8, event.last_step_summary),
        .current_goal = try allocator.dupe(u8, event.current_goal),
        .last_tool_result = try allocator.dupe(u8, event.last_tool_result),
        .last_error = try allocator.dupe(u8, event.last_error),
        .last_log_path = try allocator.dupe(u8, event.last_log_path),
        .iteration = event.iteration,
        .max_iterations = event.max_iterations,
        .estimated_prompt_chars = event.estimated_prompt_chars,
        .estimated_prompt_tokens = event.estimated_prompt_tokens,
        .context_window_tokens = event.context_window_tokens,
        .response_reserve_tokens = event.response_reserve_tokens,
        .remaining_context_tokens = event.remaining_context_tokens,
        .context_used_percent = event.context_used_percent,
        .condensation_count = event.condensation_count,
        .condensed_history_events = event.condensed_history_events,
    };
}

pub fn freeRuntimeUiEvent(allocator: std.mem.Allocator, event: RuntimeUiEvent) void {
    allocator.free(event.actor);
    allocator.free(event.title);
    allocator.free(event.text);
    allocator.free(event.project_name);
    allocator.free(event.provider_type);
    allocator.free(event.model);
    allocator.free(event.logs_dir);
    allocator.free(event.approval_mode);
    allocator.free(event.global_status);
    allocator.free(event.runtime_status);
    allocator.free(event.loop_status);
    allocator.free(event.approval_status);
    allocator.free(event.current_actor);
    allocator.free(event.active_tool);
    allocator.free(event.active_lane);
    allocator.free(event.last_step_kind);
    allocator.free(event.last_step_summary);
    allocator.free(event.current_goal);
    allocator.free(event.last_tool_result);
    allocator.free(event.last_error);
    allocator.free(event.last_log_path);
}

pub fn freeRuntimeUiEvents(allocator: std.mem.Allocator, events: []RuntimeUiEvent) void {
    for (events) |event| freeRuntimeUiEvent(allocator, event);
    allocator.free(events);
}

pub const RuntimeControl = struct {
    interrupt_requested: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    running: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    approval_mutex: std.Thread.Mutex = .{},
    approval_cond: std.Thread.Condition = .{},
    approval_pending: bool = false,
    approval_response: ?bool = null,
};

pub const WorkerTask = struct {
    allocator: std.mem.Allocator,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    command: WorkerCommandKind,
    mission_prompt: []const u8 = "",
    thread: ?std.Thread = null,
};

pub const RuntimeHooks = struct {
    context: ?*anyopaque = null,
    emit_fn: ?*const fn (?*anyopaque, RuntimeUiEvent) void = null,
    interrupted_fn: ?*const fn (?*anyopaque) bool = null,
    approval_fn: ?*const fn (?*anyopaque, []const u8, []const u8) bool = null,

    fn emit(self: RuntimeHooks, event: RuntimeUiEvent) void {
        if (self.emit_fn) |emit_fn| {
            emit_fn(self.context, event);
        }
    }

    fn isInterrupted(self: RuntimeHooks) bool {
        if (self.interrupted_fn) |interrupted_fn| {
            return interrupted_fn(self.context);
        }
        return false;
    }

    fn requestApproval(self: RuntimeHooks, tool_name: []const u8, detail: []const u8) ?bool {
        if (self.approval_fn) |approval_fn| {
            return approval_fn(self.context, tool_name, detail);
        }
        return null;
    }
};

pub const OllamaTagsResponse = struct {
    models: []const OllamaModel = &.{},
    @"error": []const u8 = "",
};

pub const OllamaModel = struct {
    name: []const u8 = "",
};

pub const OllamaChatResponse = struct {
    message: OllamaMessage = .{},
    @"error": []const u8 = "",
};

pub const OllamaChatStreamChunk = struct {
    message: OllamaMessage = .{},
    done: bool = false,
    @"error": []const u8 = "",
};

pub const OllamaMessage = struct {
    content: []const u8 = "",
    thinking: []const u8 = "",
    tool_calls: []const OllamaToolCall = &.{},
};

pub const OllamaToolCall = struct {
    function: OllamaToolFunction = .{},
};

pub const OllamaToolFunction = struct {
    name: []const u8 = "",
    arguments: OllamaToolArguments = .{},
};

pub const OllamaToolArguments = struct {
    description: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
    cmd: []const []const u8 = &.{},
};

pub const OpenAIModelsResponse = struct {
    data: []const OpenAIModel = &.{},
    @"error": OpenAIErrorEnvelope = .{},
};

pub const OpenAIModel = struct {
    id: []const u8 = "",
};

pub const OpenAIChatResponse = struct {
    choices: []const OpenAIChoice = &.{},
    @"error": OpenAIErrorEnvelope = .{},
};

pub const OpenAIChoice = struct {
    message: OpenAIMessage = .{},
};

pub const OpenAIMessage = struct {
    content: []const u8 = "",
    tool_calls: []const OpenAIToolCall = &.{},
};

pub const OpenAIErrorEnvelope = struct {
    message: []const u8 = "",
};

pub const OpenAIToolCall = struct {
    function: OpenAIToolFunction = .{},
};

pub const OpenAIToolFunction = struct {
    name: []const u8 = "",
    arguments: []const u8 = "",
};

pub fn usablePromptTokenWindow(config: ContextConfig) usize {
    if (config.estimated_context_window_tokens > config.response_reserve_tokens) {
        return config.estimated_context_window_tokens - config.response_reserve_tokens;
    }
    return config.estimated_context_window_tokens;
}

pub fn ensureLoopBudget(state: *AppState) void {
    if (state.agent_loop.max_iterations == 0 or state.agent_loop.max_iterations == legacy_default_max_iterations) {
        state.agent_loop.max_iterations = default_max_iterations;
    }
}

pub fn resolvedContextBudget(config: ContextConfig, budget: ContextBudgetState) ContextBudgetState {
    var resolved = budget;
    if (resolved.context_window_tokens == 0) {
        resolved.context_window_tokens = config.estimated_context_window_tokens;
    }
    if (resolved.response_reserve_tokens == 0) {
        resolved.response_reserve_tokens = config.response_reserve_tokens;
    }
    if (resolved.remaining_tokens == 0 and resolved.estimated_prompt_tokens == 0) {
        resolved.remaining_tokens = usablePromptTokenWindow(config);
    }
    return resolved;
}

pub fn buildStateSnapshot(config: AppConfig, state: AppState, project_name: []const u8) StateSnapshot {
    const budget = resolvedContextBudget(config.context, state.runtime_session.context_budget);
    return .{
        .project_name = project_name,
        .approval_mode = config.policy.approval_mode,
        .global_status = state.global_status,
        .runtime_status = state.runtime_session.status,
        .loop_status = state.agent_loop.status,
        .current_actor = state.current_actor,
        .active_tool = state.agent_loop.active_tool,
        .active_lane = if (state.agent_loop.active_tool) |active_tool| protocol.laneForActor(active_tool) else protocol.laneForActor(state.current_actor),
        .approval_status = state.runtime_session.active_approval.status,
        .last_step_kind = state.agent_loop.last_step.kind,
        .last_step_summary = state.agent_loop.last_step.summary,
        .current_goal = state.mission.current_goal,
        .last_tool_result = state.agent_loop.last_tool_result,
        .last_error = state.runtime_session.last_error,
        .last_log_path = state.runtime_session.active_log_path,
        .iteration = state.agent_loop.iteration,
        .max_iterations = if (state.agent_loop.max_iterations > 0) state.agent_loop.max_iterations else default_max_iterations,
        .estimated_prompt_chars = budget.estimated_prompt_chars,
        .estimated_prompt_tokens = budget.estimated_prompt_tokens,
        .context_window_tokens = budget.context_window_tokens,
        .response_reserve_tokens = budget.response_reserve_tokens,
        .remaining_context_tokens = budget.remaining_tokens,
        .context_used_percent = budget.used_percent,
        .condensation_count = budget.condensation_count,
        .condensed_history_events = budget.condensed_history_events,
    };
}

pub fn snapshotFromState(config: AppConfig, state: AppState, project_name: []const u8) TuiSnapshot {
    const snapshot = buildStateSnapshot(config, state, project_name);
    return .{
        .project_name = snapshot.project_name,
        .provider_type = config.provider.type,
        .model = if (state.runtime_session.model.len > 0) state.runtime_session.model else config.provider.model,
        .logs_dir = config.paths.logs_dir,
        .approval_mode = snapshot.approval_mode,
        .global_status = @tagName(snapshot.global_status),
        .runtime_status = @tagName(snapshot.runtime_status),
        .loop_status = @tagName(snapshot.loop_status),
        .approval_status = @tagName(snapshot.approval_status),
        .current_actor = actorName(snapshot.current_actor),
        .active_tool = maybeActorName(snapshot.active_tool),
        .active_lane = laneName(snapshot.active_lane),
        .last_step_kind = @tagName(snapshot.last_step_kind),
        .last_step_summary = snapshot.last_step_summary,
        .current_goal = snapshot.current_goal,
        .last_tool_result = snapshot.last_tool_result,
        .last_error = snapshot.last_error,
        .last_log_path = snapshot.last_log_path,
        .iteration = snapshot.iteration,
        .max_iterations = snapshot.max_iterations,
        .estimated_prompt_chars = snapshot.estimated_prompt_chars,
        .estimated_prompt_tokens = snapshot.estimated_prompt_tokens,
        .context_window_tokens = snapshot.context_window_tokens,
        .response_reserve_tokens = snapshot.response_reserve_tokens,
        .remaining_context_tokens = snapshot.remaining_context_tokens,
        .context_used_percent = snapshot.context_used_percent,
        .condensation_count = snapshot.condensation_count,
        .condensed_history_events = snapshot.condensed_history_events,
    };
}

pub fn compactTextForUi(allocator: std.mem.Allocator, text: []const u8, max_lines: usize, max_chars: usize) ![]const u8 {
    const trimmed = trimAscii(text);
    if (trimmed.len == 0) return try allocator.dupe(u8, "");

    const char_limited = safeUtf8PrefixByBytes(trimmed, max_chars);
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);

    var line_count: usize = 0;
    var truncated = trimmed.len > char_limited.len;
    var lines = std.mem.splitScalar(u8, char_limited, '\n');
    while (lines.next()) |line| {
        if (line_count >= max_lines) {
            truncated = true;
            break;
        }
        if (line_count > 0) try buffer.append(allocator, '\n');
        try buffer.appendSlice(allocator, line);
        line_count += 1;
    }

    if (truncated) try buffer.appendSlice(allocator, "\n...[truncated]...");
    return try buffer.toOwnedSlice(allocator);
}

pub fn pluralSuffix(count: usize) []const u8 {
    return if (count == 1) "" else "s";
}

pub fn writeToolRequestLabel(writer: anytype, request: ToolRequest) !void {
    const tool_name = canonicalToolName(request.tool);
    if (request.path.len > 0) {
        try writer.print("{s} {s}", .{ tool_name, request.path });
        return;
    }
    if (eql(tool_name, "list_files")) {
        try writer.print("{s} .", .{tool_name});
        return;
    }
    if (request.pattern.len > 0) {
        try writer.print("{s} pattern={s}", .{ tool_name, request.pattern });
        return;
    }
    if (request.command.len > 0) {
        try writer.print("{s} {s}", .{ tool_name, request.command });
        return;
    }
    if (request.description.len > 0) {
        try writer.print("{s} {s}", .{ tool_name, request.description });
        return;
    }
    try writer.writeAll(tool_name);
}

pub fn summarizeToolRequestsForUi(allocator: std.mem.Allocator, requests: []const ToolRequest) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    try writer.print("requested {d} runtime tool{s}", .{ requests.len, pluralSuffix(requests.len) });
    const preview_count = @min(requests.len, 4);
    for (requests[0..preview_count]) |request| {
        try writer.writeAll("\n- ");
        try writeToolRequestLabel(writer, request);
    }
    if (requests.len > preview_count) {
        try writer.print("\n- ... {d} more", .{requests.len - preview_count});
    }
    return try buffer.toOwnedSlice(allocator);
}

pub fn summarizeDecanusDecisionForUi(allocator: std.mem.Allocator, decision: DecanusDecision) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    const action = if (decision.action.len > 0) decision.action else "unknown";

    try writer.print("action: {s}", .{action});
    if (decision.current_goal.len > 0) {
        const goal = try compactTextForUi(allocator, decision.current_goal, 2, 220);
        defer allocator.free(goal);
        try writer.print("\ngoal: {s}", .{goal});
    }
    if (decision.reasoning.len > 0) {
        const reasoning = try compactTextForUi(allocator, decision.reasoning, 3, 320);
        defer allocator.free(reasoning);
        try writer.print("\nreason: {s}", .{reasoning});
    }

    if (eql(action, "tool_request")) {
        if (decision.tool_requests.len > 0) {
            const tools = try summarizeToolRequestsForUi(allocator, decision.tool_requests);
            defer allocator.free(tools);
            try writer.print("\n{s}", .{tools});
        }
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "invoke_specialist")) {
        const requested_actor = if (decision.actor.len > 0) parseActor(decision.actor) else null;
        const lane = if (decision.lane.len > 0)
            std.meta.stringToEnum(Lane, decision.lane) orelse (if (requested_actor) |actor| laneForActor(actor) else .bulk_ops)
        else if (requested_actor) |actor|
            laneForActor(actor)
        else
            .bulk_ops;
        const actor = requested_actor orelse actorForLane(lane);
        try writer.print("\nhandoff: {s} on {s}", .{ actorName(actor), laneName(lane) });
        if (decision.objective.len > 0) {
            const objective = try compactTextForUi(allocator, decision.objective, 4, 360);
            defer allocator.free(objective);
            try writer.print("\nobjective: {s}", .{objective});
        }
        if (decision.completion_signal.len > 0) {
            const signal = try compactTextForUi(allocator, decision.completion_signal, 3, 280);
            defer allocator.free(signal);
            try writer.print("\ndone when: {s}", .{signal});
        }
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "finish") and decision.final_response.len > 0) {
        const response = try compactTextForUi(allocator, decision.final_response, 8, 700);
        defer allocator.free(response);
        try writer.print("\nresponse:\n{s}", .{response});
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "ask_user") and decision.question.len > 0) {
        const question = try compactTextForUi(allocator, decision.question, 4, 320);
        defer allocator.free(question);
        try writer.print("\nquestion: {s}", .{question});
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "blocked")) {
        const blocked_reason = if (decision.blocked_reason.len > 0) decision.blocked_reason else "blocked";
        const reason = try compactTextForUi(allocator, blocked_reason, 4, 320);
        defer allocator.free(reason);
        try writer.print("\nblocked: {s}", .{reason});
    }

    return try buffer.toOwnedSlice(allocator);
}

pub fn summarizeSpecialistResultForUi(allocator: std.mem.Allocator, result: SpecialistResult) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    const action = if (result.action.len > 0) result.action else if (result.status.len > 0) result.status else "unknown";
    const summary = if (result.summary.len > 0) result.summary else result.result_summary;

    try writer.print("action: {s}", .{action});
    if (result.reasoning.len > 0) {
        const reasoning = try compactTextForUi(allocator, result.reasoning, 3, 320);
        defer allocator.free(reasoning);
        try writer.print("\nreason: {s}", .{reasoning});
    }

    if (eql(action, "tool_request")) {
        if (result.tool_requests.len > 0) {
            const tools = try summarizeToolRequestsForUi(allocator, result.tool_requests);
            defer allocator.free(tools);
            try writer.print("\n{s}", .{tools});
        }
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "complete") or eql(action, "partial")) {
        if (result.description.len > 0) {
            const description = try compactTextForUi(allocator, result.description, 3, 280);
            defer allocator.free(description);
            try writer.print("\ndescription: {s}", .{description});
        }
        if (summary.len > 0) {
            const compact_summary = try compactTextForUi(allocator, summary, 6, 520);
            defer allocator.free(compact_summary);
            try writer.print("\nsummary:\n{s}", .{compact_summary});
        }
        if (result.findings.len > 0) {
            const findings = try joinStrings(allocator, result.findings, "; ");
            defer allocator.free(findings);
            try writer.print("\nfindings: {s}", .{findings});
        }
        if (result.confidence > 0) {
            try writer.print("\nconfidence: {d:.2}", .{result.confidence});
        }
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "ask_user") and result.question.len > 0) {
        const question = try compactTextForUi(allocator, result.question, 4, 320);
        defer allocator.free(question);
        try writer.print("\nquestion: {s}", .{question});
        return try buffer.toOwnedSlice(allocator);
    }

    if (eql(action, "blocked")) {
        const blocked_reason = if (result.blockers.len > 0)
            result.blockers[0]
        else if (result.blocked_reason.len > 0)
            result.blocked_reason
        else
            "blocked";
        const reason = try compactTextForUi(allocator, blocked_reason, 4, 320);
        defer allocator.free(reason);
        try writer.print("\nblocked: {s}", .{reason});
    }

    return try buffer.toOwnedSlice(allocator);
}

pub fn pollInput(timeout_ms: i32) !bool {
    var fds = [_]std.posix.pollfd{
        .{
            .fd = std.posix.STDIN_FILENO,
            .events = std.posix.POLL.IN,
            .revents = 0,
        },
    };
    _ = try std.posix.poll(&fds, timeout_ms);
    return (fds[0].revents & std.posix.POLL.IN) != 0;
}

pub const DecodedScalar = struct {
    codepoint: u21,
    byte_len: usize,
};

pub fn decodeUtf8Scalar(text: []const u8, index: usize) DecodedScalar {
    if (index >= text.len) return .{ .codepoint = 0, .byte_len = 0 };

    const first = text[index];
    const byte_len = std.unicode.utf8ByteSequenceLength(first) catch return .{
        .codepoint = first,
        .byte_len = 1,
    };
    if (index + byte_len > text.len) return .{
        .codepoint = first,
        .byte_len = 1,
    };

    const codepoint = std.unicode.utf8Decode(text[index .. index + byte_len]) catch return .{
        .codepoint = first,
        .byte_len = 1,
    };
    return .{
        .codepoint = codepoint,
        .byte_len = byte_len,
    };
}

pub fn safeUtf8PrefixByBytes(text: []const u8, max_bytes: usize) []const u8 {
    if (text.len <= max_bytes) return text;

    var index: usize = 0;
    while (index < text.len and index < max_bytes) {
        const scalar = decodeUtf8Scalar(text, index);
        if (index + scalar.byte_len > max_bytes) break;
        index += scalar.byte_len;
    }
    return text[0..index];
}

pub fn actorName(actor: Actor) []const u8 {
    return @tagName(actor);
}

pub fn maybeActorName(actor: ?Actor) []const u8 {
    if (actor) |value| return actorName(value);
    return "";
}

pub fn laneName(lane: Lane) []const u8 {
    return @tagName(lane);
}

pub fn parseActor(text: []const u8) ?Actor {
    return std.meta.stringToEnum(Actor, text);
}

pub fn parseInvocationResultStatus(text: []const u8) ?InvocationResultStatus {
    return std.meta.stringToEnum(InvocationResultStatus, text);
}

pub fn buildRuntimeFailure(
    state: *const AppState,
    actor: Actor,
    lane: Lane,
    error_code: []const u8,
    message: []const u8,
    context_spec: RuntimeFailureContextSpec,
) RuntimeFailure {
    return .{
        .error_code = error_code,
        .message = message,
        .context = .{
            .actor = actorName(actor),
            .lane = laneName(lane),
            .tool = context_spec.tool,
            .target = context_spec.target,
            .command = context_spec.command,
            .detail = context_spec.detail,
            .provider = state.runtime_session.provider,
            .model = state.runtime_session.model,
            .turn_id = state.runtime_session.current_turn_id,
            .iteration = state.agent_loop.iteration,
        },
    };
}

pub fn stateManager(state: *AppState) StateManager {
    return StateManager.init(state);
}

pub fn recordRuntimeFailure(state: *AppState, failure: RuntimeFailure) void {
    stateManager(state).recordFailure(failure);
}

pub fn clearRuntimeFailure(state: *AppState) void {
    stateManager(state).clearFailure();
}

pub fn currentLaneForState(state: AppState) []const u8 {
    if (state.agent_loop.active_tool) |active_tool| return laneName(protocol.laneForActor(active_tool));
    return laneName(protocol.laneForActor(state.current_actor));
}

pub fn toneForOutcome(state: AppState) ChatTone {
    if (state.global_status == .complete) return .success;
    if (state.runtime_session.status == .blocked or state.runtime_session.status == .interrupted) return .danger;
    return .info;
}

pub fn emitLog(hooks: RuntimeHooks, tone: ChatTone, actor: []const u8, title: []const u8, text: []const u8, highlight: HighlightKind) void {
    hooks.emit(.{
        .kind = .log,
        .tone = tone,
        .actor = actor,
        .title = title,
        .text = text,
        .highlight = highlight,
    });
}

pub fn emitStreamStart(hooks: RuntimeHooks, actor: []const u8) void {
    hooks.emit(.{
        .kind = .stream_start,
        .actor = actor,
    });
}

pub fn emitStreamChunk(hooks: RuntimeHooks, actor: []const u8, text: []const u8) void {
    hooks.emit(.{
        .kind = .stream_chunk,
        .actor = actor,
        .text = text,
    });
}

pub fn emitStreamFinalize(hooks: RuntimeHooks, actor: []const u8, text: []const u8, highlight: HighlightKind) void {
    hooks.emit(.{
        .kind = .stream_finalize,
        .actor = actor,
        .text = text,
        .highlight = highlight,
    });
}

pub fn emitStateSnapshot(hooks: RuntimeHooks, config: AppConfig, state: AppState) void {
    const snapshot = buildStateSnapshot(config, state, if (!eql(state.project_name, "UNASSIGNED")) state.project_name else "");
    hooks.emit(.{
        .kind = .state_snapshot,
        .project_name = snapshot.project_name,
        .provider_type = config.provider.type,
        .model = if (state.runtime_session.model.len > 0) state.runtime_session.model else config.provider.model,
        .logs_dir = config.paths.logs_dir,
        .approval_mode = snapshot.approval_mode,
        .global_status = @tagName(snapshot.global_status),
        .runtime_status = @tagName(snapshot.runtime_status),
        .loop_status = @tagName(snapshot.loop_status),
        .approval_status = @tagName(snapshot.approval_status),
        .current_actor = actorName(snapshot.current_actor),
        .active_tool = maybeActorName(snapshot.active_tool),
        .active_lane = laneName(snapshot.active_lane),
        .last_step_kind = @tagName(snapshot.last_step_kind),
        .last_step_summary = snapshot.last_step_summary,
        .current_goal = snapshot.current_goal,
        .last_tool_result = snapshot.last_tool_result,
        .last_error = snapshot.last_error,
        .last_log_path = snapshot.last_log_path,
        .iteration = snapshot.iteration,
        .max_iterations = snapshot.max_iterations,
        .estimated_prompt_chars = snapshot.estimated_prompt_chars,
        .estimated_prompt_tokens = snapshot.estimated_prompt_tokens,
        .context_window_tokens = snapshot.context_window_tokens,
        .response_reserve_tokens = snapshot.response_reserve_tokens,
        .remaining_context_tokens = snapshot.remaining_context_tokens,
        .context_used_percent = snapshot.context_used_percent,
        .condensation_count = snapshot.condensation_count,
        .condensed_history_events = snapshot.condensed_history_events,
    });
}

pub fn markInterrupted(state: *AppState) void {
    stateManager(state).markInterrupted();
}

pub fn friendlyRuntimeError(allocator: std.mem.Allocator, err: anyerror) ![]const u8 {
    if (err == error.BackendUnavailable) {
        return try allocator.dupe(u8, "backend unavailable. Start your local model server, then run /doctor or /models again.");
    }
    if (err == error.ModelNotFound) {
        return try allocator.dupe(u8, "configured model was not found on the active backend. Use /models to list options, then /model <n|name>.");
    }
    if (err == error.EmptyModelOutput) {
        return try allocator.dupe(u8, "the model returned an empty response. Check the active model and inspect the latest turn log.");
    }
    if (err == error.ProviderRejectedRequest) {
        return try allocator.dupe(u8, "the provider rejected the request. Check the current model, endpoint, and backend logs.");
    }
    if (err == error.ModelListUnavailable) {
        return try allocator.dupe(u8, "no cached model roster is loaded. Run /models first or set /model <name> manually.");
    }
    if (err == error.ModelSelectionOutOfRange) {
        return try allocator.dupe(u8, "that model number is outside the current roster. Run /models and choose one of the listed entries.");
    }
    if (err == error.Interrupted) {
        return try allocator.dupe(u8, "the active loop was interrupted by the operator.");
    }
    if (err == error.FileNotFound) {
        return try allocator.dupe(u8, "requested path was not found inside the workspace.");
    }
    return try std.fmt.allocPrint(allocator, "runtime error: {s}", .{@errorName(err)});
}

pub fn runtimeErrorCode(err: anyerror) []const u8 {
    return switch (err) {
        error.BackendUnavailable => "BACKEND_UNAVAILABLE",
        error.ModelNotFound => "MODEL_NOT_FOUND",
        error.EmptyModelOutput => "EMPTY_MODEL_OUTPUT",
        error.ProviderRejectedRequest => "PROVIDER_REJECTED_REQUEST",
        error.ModelListUnavailable => "MODEL_LIST_UNAVAILABLE",
        error.ModelSelectionOutOfRange => "MODEL_SELECTION_OUT_OF_RANGE",
        error.Interrupted => "LOOP_INTERRUPTED",
        error.FileNotFound => "FILE_NOT_FOUND",
        error.MissingPath => "MISSING_PATH",
        error.MissingPattern => "MISSING_PATTERN",
        error.ContextBudgetExceeded => "CONTEXT_BUDGET_EXCEEDED",
        else => "RUNTIME_ERROR",
    };
}

pub fn freeOwnedToolRequest(allocator: std.mem.Allocator, request: ToolRequest) void {
    allocator.free(request.tool);
    allocator.free(request.description);
    allocator.free(request.path);
    allocator.free(request.pattern);
    allocator.free(request.command);
    allocator.free(request.content);
}

pub fn runCommandCapture(allocator: std.mem.Allocator, argv: []const []const u8) !CommandResult {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
    });

    return .{
        .stdout = result.stdout,
        .stderr = result.stderr,
        .exit_code = exitCode(result.term),
    };
}

pub fn freeCommandResult(allocator: std.mem.Allocator, result: CommandResult) void {
    allocator.free(result.stdout);
    allocator.free(result.stderr);
}

pub fn runCommandCaptureWithTimeout(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    timeout_ms: usize,
) !CommandResult {
    if (timeout_ms == 0) return try runCommandCapture(allocator, argv);

    var child = std.process.Child.init(argv, allocator);
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    try child.spawn();
    try child.waitForSpawn();
    errdefer {
        if (child.term == null) _ = child.kill() catch {};
    }

    var stdout_text: std.ArrayList(u8) = .empty;
    errdefer stdout_text.deinit(allocator);
    var stderr_text: std.ArrayList(u8) = .empty;
    errdefer stderr_text.deinit(allocator);

    var stdout_open = child.stdout != null;
    var stderr_open = child.stderr != null;
    const started = std.time.milliTimestamp();

    while (stdout_open or stderr_open) {
        const now = std.time.milliTimestamp();
        const elapsed_ms = if (now > started) @as(usize, @intCast(now - started)) else 0;
        if (elapsed_ms >= timeout_ms) {
            _ = child.kill() catch {};
            return error.ToolTimedOut;
        }

        var poll_items: [2]std.posix.pollfd = undefined;
        var poll_count: usize = 0;
        if (stdout_open) {
            poll_items[poll_count] = .{
                .fd = child.stdout.?.handle,
                .events = std.posix.POLL.IN | std.posix.POLL.HUP,
                .revents = 0,
            };
            poll_count += 1;
        }
        if (stderr_open) {
            poll_items[poll_count] = .{
                .fd = child.stderr.?.handle,
                .events = std.posix.POLL.IN | std.posix.POLL.HUP,
                .revents = 0,
            };
            poll_count += 1;
        }

        const remaining_ms = timeout_ms - elapsed_ms;
        const poll_timeout: i32 = @intCast(@min(remaining_ms, @as(usize, 100)));
        _ = try std.posix.poll(poll_items[0..poll_count], poll_timeout);

        var poll_index: usize = 0;
        if (stdout_open) {
            const item = poll_items[poll_index];
            if ((item.revents & (std.posix.POLL.IN | std.posix.POLL.HUP)) != 0) {
                var buffer: [4096]u8 = undefined;
                const read_len = try child.stdout.?.read(&buffer);
                if (read_len == 0) {
                    stdout_open = false;
                } else {
                    try stdout_text.appendSlice(allocator, buffer[0..read_len]);
                }
            }
            poll_index += 1;
        }
        if (stderr_open) {
            const item = poll_items[poll_index];
            if ((item.revents & (std.posix.POLL.IN | std.posix.POLL.HUP)) != 0) {
                var buffer: [1024]u8 = undefined;
                const read_len = try child.stderr.?.read(&buffer);
                if (read_len == 0) {
                    stderr_open = false;
                } else {
                    try stderr_text.appendSlice(allocator, buffer[0..read_len]);
                }
            }
        }
    }

    const term = try child.wait();
    return .{
        .stdout = try stdout_text.toOwnedSlice(allocator),
        .stderr = try stderr_text.toOwnedSlice(allocator),
        .exit_code = exitCode(term),
    };
}

pub fn runShellCommand(allocator: std.mem.Allocator, command: []const u8, timeout_ms: usize) !CommandResult {
    return try runCommandCaptureWithTimeout(allocator, &.{ "sh", "-lc", command }, timeout_ms);
}

pub fn resetStateForMission(state: *AppState, mission_prompt: []const u8) void {
    stateManager(state).resetForMission(mission_prompt);
}

pub fn initializeRuntimeSession(allocator: std.mem.Allocator, state: *AppState, config: AppConfig) void {
    _ = allocator;
    stateManager(state).initializeRuntimeSession(config);
}

pub fn appendHistory(allocator: std.mem.Allocator, state: *AppState, entry: HistoryEntry) !void {
    var history: std.ArrayList(HistoryEntry) = .empty;
    const previous = state.agent_loop.history;
    try history.appendSlice(allocator, previous);
    try history.append(allocator, entry);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
    if (previous.len > 0) allocator.free(previous);
}

pub fn taskForLane(state: *AppState, lane: Lane) *TaskLane {
    return switch (lane) {
        .backend => &state.tasks.backend,
        .frontend => &state.tasks.frontend,
        .systems => &state.tasks.systems,
        .qa => &state.tasks.qa,
        .research => &state.tasks.research,
        .brand => &state.tasks.brand,
        .media => &state.tasks.media,
        .docs => &state.tasks.docs,
        .bulk_ops => &state.tasks.bulk_ops,
        .command => &state.tasks.bulk_ops,
    };
}

pub fn taskForLaneConst(state: *const AppState, lane: Lane) *const TaskLane {
    return switch (lane) {
        .backend => &state.tasks.backend,
        .frontend => &state.tasks.frontend,
        .systems => &state.tasks.systems,
        .qa => &state.tasks.qa,
        .research => &state.tasks.research,
        .brand => &state.tasks.brand,
        .media => &state.tasks.media,
        .docs => &state.tasks.docs,
        .bulk_ops => &state.tasks.bulk_ops,
        .command => &state.tasks.bulk_ops,
    };
}

pub fn laneForActor(actor: Actor) Lane {
    return protocol.laneForActor(actor);
}

pub fn actorForLane(lane: Lane) Actor {
    return protocol.actorForLane(lane);
}

pub fn setLoopStep(state: *AppState, kind: LoopStepKind, actor: Actor, lane: Lane, summary: []const u8) void {
    state.agent_loop.last_step = .{
        .iteration = state.agent_loop.iteration,
        .kind = kind,
        .actor = actor,
        .lane = lane,
        .summary = summary,
    };
}

pub fn beginApprovalRequest(
    state: *AppState,
    actor: Actor,
    lane: Lane,
    tool_name: []const u8,
    detail: []const u8,
    reason: []const u8,
    target: []const u8,
) void {
    stateManager(state).beginApprovalRequest(actor, lane, tool_name, detail, reason, target);
}

pub fn resolveApprovalRequest(state: *AppState, approved: bool) void {
    stateManager(state).resolveApprovalRequest(approved);
}

pub fn singleItemSlice(allocator: std.mem.Allocator, value: []const u8) ![]const []const u8 {
    var items = try allocator.alloc([]const u8, 1);
    items[0] = value;
    return items;
}

pub fn invocationResultStatusFromText(text: []const u8, fallback: InvocationResultStatus) InvocationResultStatus {
    if (text.len == 0) return fallback;
    return parseInvocationResultStatus(text) orelse fallback;
}

pub fn materializeInvocationResult(
    allocator: std.mem.Allocator,
    result: SpecialistResult,
    fallback_status: InvocationResultStatus,
) !InvocationResult {
    const resolved_status = invocationResultStatusFromText(result.status, fallback_status);
    const resolved_summary = if (result.summary.len > 0)
        result.summary
    else if (result.result_summary.len > 0)
        result.result_summary
    else
        result.description;

    const resolved_changes = if (result.changes.len > 0) result.changes else result.artifacts;
    const resolved_findings = if (result.findings.len > 0)
        result.findings
    else if (result.description.len > 0 and !eql(result.description, resolved_summary))
        try singleItemSlice(allocator, result.description)
    else
        &.{};

    const resolved_blockers = if (result.blockers.len > 0)
        result.blockers
    else if (result.blocked_reason.len > 0)
        try singleItemSlice(allocator, result.blocked_reason)
    else if (result.question.len > 0)
        try singleItemSlice(allocator, result.question)
    else
        &.{};

    return .{
        .status = resolved_status,
        .summary = resolved_summary,
        .changes = resolved_changes,
        .findings = resolved_findings,
        .blockers = resolved_blockers,
        .next_recommended_agent = if (result.next_recommended_agent.len > 0) parseActor(result.next_recommended_agent) else null,
        .confidence = result.confidence,
    };
}

pub fn prepareInvocation(
    state: *AppState,
    lane: Lane,
    actor: Actor,
    objective: []const u8,
    completion_signal: []const u8,
    dependencies: []const []const u8,
) void {
    stateManager(state).prepareInvocation(lane, actor, objective, completion_signal, dependencies);
}

pub fn finalizeInvocation(
    state: *AppState,
    lane: Lane,
    actor: Actor,
    result: InvocationResult,
    description: []const u8,
) void {
    stateManager(state).finalizeInvocation(lane, actor, result, description);
}

pub fn taskSummaryText(allocator: std.mem.Allocator, tasks: Tasks) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "backend={s}, frontend={s}, systems={s}, qa={s}, research={s}, brand={s}, media={s}, docs={s}, bulk_ops={s}",
        .{
            @tagName(tasks.backend.status),
            @tagName(tasks.frontend.status),
            @tagName(tasks.systems.status),
            @tagName(tasks.qa.status),
            @tagName(tasks.research.status),
            @tagName(tasks.brand.status),
            @tagName(tasks.media.status),
            @tagName(tasks.docs.status),
            @tagName(tasks.bulk_ops.status),
        },
    );
}

pub fn recentHistoryText(allocator: std.mem.Allocator, history: []const HistoryEntry, max_events: usize) ![]const u8 {
    if (history.len == 0) return "none";
    const start = if (history.len > max_events) history.len - max_events else 0;
    var lines: std.ArrayList([]const u8) = .empty;
    for (history[start..]) |entry| {
        try lines.append(allocator, try std.fmt.allocPrint(
            allocator,
            "#{d} {s} actor={s} lane={s} summary={s}",
            .{ entry.iteration, entry.type, entry.actor, entry.lane, entry.summary },
        ));
    }
    return try joinStrings(allocator, lines.items, "\n");
}

pub fn estimateTokensFromText(text: []const u8) usize {
    if (text.len == 0) return 0;
    return (text.len + 3) / 4;
}

pub fn estimatePromptBudget(config: ContextConfig, system_prompt: []const u8, user_prompt: []const u8) PromptBudgetEstimate {
    const prompt_chars = system_prompt.len + user_prompt.len;
    const prompt_tokens = estimateTokensFromText(system_prompt) + estimateTokensFromText(user_prompt) + 32;
    const usable_prompt_tokens = usablePromptTokenWindow(config);
    const remaining_tokens = usable_prompt_tokens -| prompt_tokens;
    const used_percent = if (usable_prompt_tokens == 0)
        100
    else
        @min((prompt_tokens * 100 + usable_prompt_tokens - 1) / usable_prompt_tokens, 100);
    return .{
        .prompt_chars = prompt_chars,
        .prompt_tokens = prompt_tokens,
        .usable_prompt_tokens = usable_prompt_tokens,
        .remaining_tokens = remaining_tokens,
        .used_percent = used_percent,
        .should_warn = used_percent >= config.warn_at_percent,
        .should_condense = used_percent >= config.condense_at_percent,
        .exhausted = prompt_tokens >= usable_prompt_tokens,
    };
}

pub fn applyPromptBudgetEstimate(state: *AppState, config: ContextConfig, estimate: PromptBudgetEstimate) void {
    stateManager(state).applyPromptBudgetEstimate(config, estimate);
}

pub fn pathIsSafeForWorkspace(path: []const u8) bool {
    const trimmed = trimAscii(path);
    if (trimmed.len == 0) return true;
    if (std.fs.path.isAbsolute(trimmed)) return false;

    var parts = std.mem.splitScalar(u8, trimmed, '/');
    while (parts.next()) |part| {
        if (eql(part, "..")) return false;
    }
    return true;
}

pub fn pathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

pub fn pathIsSafeForWrite(path: []const u8) bool {
    return pathIsSafeForWorkspace(path);
}

pub fn commandIsBlocked(patterns: []const []const u8, command: []const u8) bool {
    for (patterns) |pattern| {
        if (std.mem.indexOf(u8, command, pattern) != null) return true;
    }
    return false;
}

pub fn timeoutSeconds(allocator: std.mem.Allocator, timeout_ms: usize) ![]const u8 {
    const seconds = if (timeout_ms < 1000) 1 else timeout_ms / 1000;
    return try std.fmt.allocPrint(allocator, "{d}", .{seconds});
}

pub fn joinArgs(allocator: std.mem.Allocator, args: []const []const u8) ![]const u8 {
    return try joinStrings(allocator, args, " ");
}

pub fn joinStrings(allocator: std.mem.Allocator, items: []const []const u8, separator: []const u8) ![]const u8 {
    if (items.len == 0) return "";
    return try std.mem.join(allocator, separator, items);
}

pub fn canonicalToolName(tool_name: []const u8) []const u8 {
    if (isSupportedToolName(tool_name)) return tool_name;
    if (std.mem.lastIndexOfScalar(u8, tool_name, '.')) |dot_index| {
        const suffix = tool_name[dot_index + 1 ..];
        if (isSupportedToolName(suffix)) return suffix;
    }
    return tool_name;
}

pub fn isSupportedToolName(tool_name: []const u8) bool {
    return eql(tool_name, "list_files") or
        eql(tool_name, "read_file") or
        eql(tool_name, "search_text") or
        eql(tool_name, "run_command") or
        eql(tool_name, "write_file") or
        eql(tool_name, "ask_user");
}

pub fn makeTurnId(allocator: std.mem.Allocator, actor: []const u8, iteration: usize) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d}-{d}-{s}", .{ std.time.timestamp(), iteration, actor });
}

pub fn truncateText(allocator: std.mem.Allocator, text: []const u8, max_chars: usize) ![]const u8 {
    if (text.len <= max_chars) return text;
    return try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{safeUtf8PrefixByBytes(text, max_chars)});
}

pub fn truncateOwnedText(allocator: std.mem.Allocator, owned_text: []const u8, max_chars: usize) ![]const u8 {
    const truncated = try truncateText(allocator, owned_text, max_chars);
    if (truncated.ptr != owned_text.ptr) allocator.free(owned_text);
    return truncated;
}

pub fn unixTimestampString(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d}", .{std.time.timestamp()});
}

pub fn parseJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const parsed = try std.json.parseFromSlice(T, allocator, text, .{
        .ignore_unknown_fields = true,
    });
    return parsed.value;
}

pub fn parseModelJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const normalized = try normalizeModelJson(text);
    if (T == DecanusDecision) return try parseDecanusDecisionModelJson(allocator, normalized);
    if (T == SpecialistResult) return try parseSpecialistResultModelJson(allocator, normalized);
    if (T == ToolRequest) return try parseToolRequestModelJson(allocator, normalized);
    return try parseJson(T, allocator, normalized);
}

pub fn parseDecanusDecisionModelJson(allocator: std.mem.Allocator, text: []const u8) !DecanusDecision {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();

    const object = try requireJsonObject(parsed.value);
    return .{
        .action = try dupJsonObjectStringFieldOrDefault(allocator, object, "action", ""),
        .reasoning = try dupJsonObjectStringFieldOrDefault(allocator, object, "reasoning", ""),
        .current_goal = try dupJsonObjectStringFieldOrDefault(allocator, object, "current_goal", ""),
        .agent_call = try dupJsonObjectStringFieldOrDefault(allocator, object, "agent_call", ""),
        .lane = try dupJsonObjectStringFieldOrDefault(allocator, object, "lane", ""),
        .actor = try dupJsonObjectStringFieldOrDefault(allocator, object, "actor", ""),
        .objective = try dupJsonObjectStringFieldOrDefault(allocator, object, "objective", ""),
        .completion_signal = try dupJsonObjectStringFieldOrDefault(allocator, object, "completion_signal", ""),
        .dependencies = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "dependencies"),
        .final_response = try dupJsonObjectStringFieldOrDefault(allocator, object, "final_response", ""),
        .question = try dupJsonObjectStringFieldOrDefault(allocator, object, "question", ""),
        .blocked_reason = try dupJsonObjectStringFieldOrDefault(allocator, object, "blocked_reason", ""),
        .tool_requests = try dupJsonObjectToolRequestsFieldOrDefault(allocator, object, "tool_requests"),
    };
}

pub fn parseSpecialistResultModelJson(allocator: std.mem.Allocator, text: []const u8) !SpecialistResult {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();

    const object = try requireJsonObject(parsed.value);
    return .{
        .action = try dupJsonObjectStringFieldOrDefault(allocator, object, "action", ""),
        .reasoning = try dupJsonObjectStringFieldOrDefault(allocator, object, "reasoning", ""),
        .status = try dupJsonObjectStringFieldOrDefault(allocator, object, "status", ""),
        .summary = try dupJsonObjectStringFieldOrDefault(allocator, object, "summary", ""),
        .changes = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "changes"),
        .findings = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "findings"),
        .blockers = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "blockers"),
        .next_recommended_agent = try dupJsonObjectStringFieldOrDefault(allocator, object, "next_recommended_agent", ""),
        .confidence = try jsonObjectFloatFieldOrDefault(object, "confidence", 0.0),
        .description = try dupJsonObjectStringFieldOrDefault(allocator, object, "description", ""),
        .result_summary = try dupJsonObjectStringFieldOrDefault(allocator, object, "result_summary", ""),
        .artifacts = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "artifacts"),
        .follow_up_needed = try dupJsonObjectStringFieldOrDefault(allocator, object, "follow_up_needed", ""),
        .question = try dupJsonObjectStringFieldOrDefault(allocator, object, "question", ""),
        .blocked_reason = try dupJsonObjectStringFieldOrDefault(allocator, object, "blocked_reason", ""),
        .tool_requests = try dupJsonObjectToolRequestsFieldOrDefault(allocator, object, "tool_requests"),
    };
}

pub fn parseToolRequestModelJson(allocator: std.mem.Allocator, text: []const u8) !ToolRequest {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();
    return try dupToolRequestFromJsonValue(allocator, parsed.value);
}

pub fn parseModelValueTree(allocator: std.mem.Allocator, text: []const u8) !std.json.Parsed(std.json.Value) {
    return try std.json.parseFromSlice(std.json.Value, allocator, text, .{
        .ignore_unknown_fields = true,
    });
}

pub fn requireJsonObject(value: std.json.Value) !std.json.ObjectMap {
    return switch (value) {
        .object => |object| object,
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectStringFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
    default_value: []const u8,
) ![]const u8 {
    const value = object.get(field_name) orelse return try allocator.dupe(u8, default_value);
    return try dupJsonStringValueOrDefault(allocator, value, default_value);
}

pub fn dupJsonStringValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
    default_value: []const u8,
) ![]const u8 {
    return switch (value) {
        .null => try allocator.dupe(u8, default_value),
        .string => |text| try allocator.dupe(u8, text),
        .number_string => |text| try allocator.dupe(u8, text),
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectStringArrayFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const []const u8 {
    const value = object.get(field_name) orelse return try allocator.alloc([]const u8, 0);
    return try dupJsonStringArrayValueOrDefault(allocator, value);
}

pub fn dupJsonStringArrayValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
) ![]const []const u8 {
    return switch (value) {
        .null => try allocator.alloc([]const u8, 0),
        .array => |array| {
            var items = try allocator.alloc([]const u8, array.items.len);
            errdefer allocator.free(items);

            var index: usize = 0;
            errdefer {
                while (index > 0) {
                    index -= 1;
                    allocator.free(items[index]);
                }
            }

            for (array.items, 0..) |item, i| {
                items[i] = try dupJsonStringValueOrDefault(allocator, item, "");
                index = i + 1;
            }
            return items;
        },
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectToolRequestsFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const ToolRequest {
    const value = object.get(field_name) orelse return try allocator.alloc(ToolRequest, 0);
    return try dupToolRequestsValueOrDefault(allocator, value);
}

pub fn dupToolRequestsValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
) ![]const ToolRequest {
    return switch (value) {
        .null => try allocator.alloc(ToolRequest, 0),
        .array => |array| {
            var items = try allocator.alloc(ToolRequest, array.items.len);
            errdefer allocator.free(items);

            var index: usize = 0;
            errdefer {
                while (index > 0) {
                    index -= 1;
                    freeOwnedToolRequest(allocator, items[index]);
                }
            }

            for (array.items, 0..) |item, i| {
                items[i] = try dupToolRequestFromJsonValue(allocator, item);
                index = i + 1;
            }
            return items;
        },
        else => error.UnexpectedToken,
    };
}

pub fn dupToolRequestFromJsonValue(allocator: std.mem.Allocator, value: std.json.Value) !ToolRequest {
    const object = try requireJsonObject(value);
    return .{
        .tool = try dupJsonObjectStringFieldOrDefault(allocator, object, "tool", ""),
        .description = try dupJsonObjectStringFieldOrDefault(allocator, object, "description", ""),
        .path = try dupJsonObjectStringFieldOrDefault(allocator, object, "path", ""),
        .pattern = try dupJsonObjectStringFieldOrDefault(allocator, object, "pattern", ""),
        .command = try dupJsonObjectStringFieldOrDefault(allocator, object, "command", ""),
        .content = try dupJsonObjectStringFieldOrDefault(allocator, object, "content", ""),
    };
}

pub fn jsonObjectFloatFieldOrDefault(
    object: std.json.ObjectMap,
    field_name: []const u8,
    default_value: f32,
) !f32 {
    const value = object.get(field_name) orelse return default_value;
    return switch (value) {
        .null => default_value,
        .integer => |integer| @as(f32, @floatFromInt(integer)),
        .float => |float| @as(f32, @floatCast(float)),
        .number_string, .string => |text| try std.fmt.parseFloat(f32, text),
        else => error.UnexpectedToken,
    };
}

pub fn prettyPrintJson(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    const normalized = try normalizeModelJson(text);
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, normalized, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();
    return try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(parsed.value, .{ .whitespace = .indent_2 })},
    );
}

pub fn normalizeModelJson(text: []const u8) ![]const u8 {
    var normalized = trimAscii(text);
    if (normalized.len == 0) return error.EmptyModelOutput;

    if (std.mem.startsWith(u8, normalized, "```")) {
        if (std.mem.indexOfScalar(u8, normalized, '\n')) |first_newline| {
            normalized = trimAscii(normalized[first_newline + 1 ..]);
            if (std.mem.lastIndexOf(u8, normalized, "```")) |last_fence| {
                normalized = trimAscii(normalized[0..last_fence]);
            }
        }
    }

    if (normalized.len == 0) return error.EmptyModelOutput;
    if (normalized[0] == '{' or normalized[0] == '[') return normalized;

    if (std.mem.indexOfScalar(u8, normalized, '{')) |start| {
        if (std.mem.lastIndexOfScalar(u8, normalized, '}')) |finish| {
            if (finish > start) return trimAscii(normalized[start .. finish + 1]);
        }
    }

    if (std.mem.indexOfScalar(u8, normalized, '[')) |start| {
        if (std.mem.lastIndexOfScalar(u8, normalized, ']')) |finish| {
            if (finish > start) return trimAscii(normalized[start .. finish + 1]);
        }
    }

    return normalized;
}

pub fn containsString(items: []const []const u8, needle: []const u8) bool {
    for (items) |item| {
        if (eql(item, needle)) return true;
    }
    return false;
}

pub fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

pub fn trimAscii(text: []const u8) []const u8 {
    return std.mem.trim(u8, text, " \t\r\n");
}

pub fn exitCode(term: std.process.Child.Term) i32 {
    return switch (term) {
        .Exited => |code| code,
        else => -1,
    };
}

pub fn testQueueEmit(context: ?*anyopaque, event: RuntimeUiEvent) void {
    const queue: *RuntimeEventQueue = @ptrCast(@alignCast(context.?));
    queue.push(event);
}

pub fn testDenyApproval(_: ?*anyopaque, _: []const u8, _: []const u8) bool {
    return false;
}

pub fn freeOwnedStringSlice(allocator: std.mem.Allocator, items: []const []const u8) void {
    for (items) |item| allocator.free(item);
    allocator.free(items);
}

pub fn freeOwnedDecanusDecision(allocator: std.mem.Allocator, decision: DecanusDecision) void {
    allocator.free(decision.action);
    allocator.free(decision.reasoning);
    allocator.free(decision.current_goal);
    allocator.free(decision.agent_call);
    allocator.free(decision.lane);
    allocator.free(decision.actor);
    allocator.free(decision.objective);
    allocator.free(decision.completion_signal);
    freeOwnedStringSlice(allocator, decision.dependencies);
    allocator.free(decision.final_response);
    allocator.free(decision.question);
    allocator.free(decision.blocked_reason);
    for (decision.tool_requests) |request| freeOwnedToolRequest(allocator, request);
    allocator.free(decision.tool_requests);
}

pub fn freeOwnedSpecialistResult(allocator: std.mem.Allocator, result: SpecialistResult) void {
    allocator.free(result.action);
    allocator.free(result.reasoning);
    allocator.free(result.status);
    allocator.free(result.summary);
    freeOwnedStringSlice(allocator, result.changes);
    freeOwnedStringSlice(allocator, result.findings);
    freeOwnedStringSlice(allocator, result.blockers);
    allocator.free(result.next_recommended_agent);
    allocator.free(result.description);
    allocator.free(result.result_summary);
    freeOwnedStringSlice(allocator, result.artifacts);
    allocator.free(result.follow_up_needed);
    allocator.free(result.question);
    allocator.free(result.blocked_reason);
    for (result.tool_requests) |request| freeOwnedToolRequest(allocator, request);
    allocator.free(result.tool_requests);
}

pub fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stdout().deprecatedWriter().print(fmt, args);
}

pub fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stderr().deprecatedWriter().print(fmt, args);
}
