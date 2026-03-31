const std = @import("std");
const cli = @import("cli.zig");
const embedded = @import("embedded_assets.zig");
const protocol = @import("runtime_protocol.zig");

const max_file_bytes = 16 * 1024 * 1024;
const runtime_dir_name = ".contubernium";
const default_state_path = ".contubernium/state.json";
const default_config_path = ".contubernium/config.json";
const default_logs_dir = ".contubernium/logs";
const default_project_memory_path = ".contubernium/project.md";
const default_global_memory_path = ".contubernium/global.md";
const default_architecture_path = ".contubernium/ARCHITECTURE.md";
const default_plan_path = ".contubernium/PLAN.md";
const default_project_context_path = ".contubernium/PROJECT_CONTEXT.md";
const max_list_files_entries = 400;
const legacy_default_max_iterations = 12;
const default_max_iterations = 24;
const default_context_window_tokens = 32768;
const default_response_reserve_tokens = 4096;
const default_tool_timeout_ms = 120000;
const default_max_project_memory_chars = 4000;
const default_max_global_memory_chars = 4000;

const Actor = protocol.Actor;
const Lane = protocol.Lane;
const GlobalStatus = protocol.GlobalStatus;
const LoopStatus = protocol.LoopStatus;
const RuntimeStatus = protocol.RuntimeStatus;
const TaskStatus = protocol.TaskStatus;
const InvocationStatus = protocol.InvocationStatus;
const InvocationResultStatus = protocol.InvocationResultStatus;
const ApprovalStatus = protocol.ApprovalStatus;
const ApprovalKind = protocol.ApprovalKind;
const LoopStepKind = protocol.LoopStepKind;
const Mission = protocol.Mission;
const Invocation = protocol.Invocation;
const InvocationResult = protocol.InvocationResult;
const ApprovalRequest = protocol.ApprovalRequest;
const LoopStep = protocol.LoopStep;
const StateSnapshot = protocol.StateSnapshot;

const EmbeddedAsset = struct {
    relative_path: []const u8,
    content: []const u8,
};

const embedded_assets = [_]EmbeddedAsset{
    .{ .relative_path = "state.json", .content = embedded.state_json },
    .{ .relative_path = "config.json", .content = embedded.config_json },
    .{ .relative_path = "project.md", .content = embedded.project_memory_md },
    .{ .relative_path = "global.md", .content = embedded.global_memory_md },
    .{ .relative_path = "ARCHITECTURE.md", .content = embedded.architecture_md },
    .{ .relative_path = "PLAN.md", .content = embedded.plan_md },
    .{ .relative_path = "PROJECT_CONTEXT.md", .content = embedded.project_context_md },
};

const AppConfig = struct {
    runtime_version: usize = 1,
    provider: ProviderConfig = .{},
    fallback_provider: ProviderConfig = .{},
    paths: PathsConfig = .{},
    policy: PolicyConfig = .{},
    context: ContextConfig = .{},
};

const ProviderConfig = struct {
    enabled: bool = true,
    type: []const u8 = "ollama-native",
    base_url: []const u8 = "http://127.0.0.1:11434",
    model: []const u8 = "qwen2.5-coder:7b",
    timeout_ms: usize = 120000,
    max_retries: usize = 2,
    structured_output: []const u8 = "json",
};

const PathsConfig = struct {
    state_file: []const u8 = default_state_path,
    logs_dir: []const u8 = default_logs_dir,
    project_memory_file: []const u8 = default_project_memory_path,
    global_memory_file: []const u8 = default_global_memory_path,
    architecture_file: []const u8 = default_architecture_path,
    plan_file: []const u8 = default_plan_path,
    project_context_file: []const u8 = default_project_context_path,
};

const PolicyConfig = struct {
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

const ContextConfig = struct {
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

const AppState = struct {
    project_name: []const u8 = "UNASSIGNED",
    global_status: GlobalStatus = .idle,
    current_actor: Actor = .decanus,
    mission: Mission = .{},
    agent_loop: AgentLoop = .{},
    runtime_session: RuntimeSession = .{},
    agent_tools: AgentTools = .{},
    tasks: Tasks = .{},
};

const AgentLoop = struct {
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

const ContextBudgetState = struct {
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

const RuntimeErrorContext = struct {
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

const RuntimeFailure = struct {
    error_code: []const u8 = "",
    message: []const u8 = "",
    context: RuntimeErrorContext = .{},
};

const RuntimeFailureContextSpec = struct {
    tool: []const u8 = "",
    target: []const u8 = "",
    command: []const u8 = "",
    detail: []const u8 = "",
};

const RuntimeSession = struct {
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

const HistoryEntry = struct {
    iteration: usize = 0,
    type: []const u8 = "",
    actor: []const u8 = "",
    lane: []const u8 = "",
    summary: []const u8 = "",
    artifacts: []const []const u8 = &.{},
    timestamp: []const u8 = "",
};

const IntermediateResult = struct {
    iteration: usize = 0,
    actor: Actor = .decanus,
    lane: Lane = .command,
    kind: []const u8 = "",
    summary: []const u8 = "",
};

const AgentTool = struct {
    lane: []const u8 = "",
    purpose: []const u8 = "",
    use_when: []const []const u8 = &.{},
};

const AgentTools = struct {
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

const TaskLane = struct {
    status: TaskStatus = .pending,
    assigned_to: Actor = .decanus,
    description: []const u8 = "",
    artifacts: []const []const u8 = &.{},
    invocation: Invocation = .{},
};

const Tasks = struct {
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

const ToolRequest = struct {
    tool: []const u8 = "",
    description: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
};

const RuntimeToolKind = enum {
    list_files,
    read_file,
    search_text,
    run_command,
    write_file,
    ask_user,
};

const ToolApprovalGate = enum {
    none,
    read,
    shell,
    write,
};

const RuntimeToolSpec = struct {
    kind: RuntimeToolKind,
    name: []const u8,
    approval_gate: ToolApprovalGate = .none,
};

const ValidatedToolRequest = struct {
    spec: RuntimeToolSpec,
    detail: []const u8 = "",
    target: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
};

const ToolRequestValidation = union(enum) {
    ok: ValidatedToolRequest,
    blocked: RuntimeFailure,
};

const DecanusDecision = struct {
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

const SpecialistResult = struct {
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

const SmokeResponse = struct {
    status: []const u8 = "",
};

const ProviderResponse = struct {
    raw_text: []const u8,
    transport_text: []const u8,
    provider_name: []const u8,
    model_name: []const u8,
    latency_ms: i64,
};

const CommandResult = struct {
    stdout: []const u8,
    stderr: []const u8,
    exit_code: i32,
};

const StepOutcome = enum {
    advanced,
    complete,
    blocked,
};

const PromptMode = enum {
    decanus,
    specialist,
};

const PromptBudgetEstimate = struct {
    prompt_chars: usize,
    prompt_tokens: usize,
    usable_prompt_tokens: usize,
    remaining_tokens: usize,
    used_percent: usize,
    should_warn: bool,
    should_condense: bool,
    exhausted: bool,
};

const RuntimeMemorySpec = struct {
    kind: []const u8,
    path: []const u8,
    max_chars: usize,
};

const RuntimeMemoryLayer = struct {
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

const RuntimeMemorySnapshot = struct {
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

const PromptBuildResult = struct {
    user_prompt: []const u8,
    memory: RuntimeMemorySnapshot,
};

const GlobalAssetLayout = struct {
    root: []const u8,
    agents_root: []const u8,
    shared_root: []const u8,
    adapters_root: []const u8,
};

const AgentCallSpec = struct {
    actor: Actor,
    action_name: []const u8 = "",
    explicit_action: bool = false,
};

const ResolvedAgentCall = struct {
    actor: Actor,
    action_name: []const u8,
    agent_call: []const u8,
};

const ResolvedSpecialistInvocation = struct {
    actor: Actor,
    lane: Lane,
    agent_call: []const u8,
    action_name: []const u8,
};

const StateManager = struct {
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

const ToolExecutionOutcome = struct {
    blocked: bool,
    summary: []const u8,
};

const ToolRequestExecution = struct {
    blocked: bool = false,
    summary: []const u8,
    failure: ?RuntimeFailure = null,
};

const RuntimeRunLog = struct {
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

const RuntimeLogEvent = struct {
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

const RuntimeLogEventSpec = struct {
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

const ChatTone = enum {
    info,
    success,
    danger,
    mission,
    agent,
    tool,
    warning,
};

const HighlightKind = enum {
    plain,
    json,
    command,
    summary,
};

const TuiSnapshot = struct {
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

fn cloneTuiSnapshot(allocator: std.mem.Allocator, snapshot: TuiSnapshot) !TuiSnapshot {
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

fn freeTuiSnapshot(allocator: std.mem.Allocator, snapshot: *TuiSnapshot) void {
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

fn setOwnedSnapshot(allocator: std.mem.Allocator, target: *TuiSnapshot, owns_snapshot: *bool, snapshot: TuiSnapshot) !void {
    var owned = try cloneTuiSnapshot(allocator, snapshot);
    errdefer freeTuiSnapshot(allocator, &owned);
    if (owns_snapshot.*) freeTuiSnapshot(allocator, target);
    target.* = owned;
    owns_snapshot.* = true;
}

const WorkerCommandKind = enum {
    mission,
    resume_run,
    doctor,
    models,
};

const RuntimeUiEventKind = enum {
    log,
    stream_start,
    stream_chunk,
    stream_finalize,
    state_snapshot,
    approval_request,
    model_roster,
};

const RuntimeUiEvent = struct {
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

const RuntimeEventQueue = struct {
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

fn cloneRuntimeUiEvent(allocator: std.mem.Allocator, event: RuntimeUiEvent) !RuntimeUiEvent {
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

fn freeRuntimeUiEvent(allocator: std.mem.Allocator, event: RuntimeUiEvent) void {
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

fn freeRuntimeUiEvents(allocator: std.mem.Allocator, events: []RuntimeUiEvent) void {
    for (events) |event| freeRuntimeUiEvent(allocator, event);
    allocator.free(events);
}

const RuntimeControl = struct {
    interrupt_requested: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    running: std.atomic.Value(bool) = std.atomic.Value(bool).init(false),
    approval_mutex: std.Thread.Mutex = .{},
    approval_cond: std.Thread.Condition = .{},
    approval_pending: bool = false,
    approval_response: ?bool = null,
};

const WorkerTask = struct {
    allocator: std.mem.Allocator,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    command: WorkerCommandKind,
    mission_prompt: []const u8 = "",
    thread: ?std.Thread = null,
};

const RuntimeHooks = struct {
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

const OllamaTagsResponse = struct {
    models: []const OllamaModel = &.{},
    @"error": []const u8 = "",
};

const OllamaModel = struct {
    name: []const u8 = "",
};

const OllamaChatResponse = struct {
    message: OllamaMessage = .{},
    @"error": []const u8 = "",
};

const OllamaChatStreamChunk = struct {
    message: OllamaMessage = .{},
    done: bool = false,
    @"error": []const u8 = "",
};

const OllamaMessage = struct {
    content: []const u8 = "",
    thinking: []const u8 = "",
    tool_calls: []const OllamaToolCall = &.{},
};

const OllamaToolCall = struct {
    function: OllamaToolFunction = .{},
};

const OllamaToolFunction = struct {
    name: []const u8 = "",
    arguments: OllamaToolArguments = .{},
};

const OllamaToolArguments = struct {
    description: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
    cmd: []const []const u8 = &.{},
};

const OpenAIModelsResponse = struct {
    data: []const OpenAIModel = &.{},
    @"error": OpenAIErrorEnvelope = .{},
};

const OpenAIModel = struct {
    id: []const u8 = "",
};

const OpenAIChatResponse = struct {
    choices: []const OpenAIChoice = &.{},
    @"error": OpenAIErrorEnvelope = .{},
};

const OpenAIChoice = struct {
    message: OpenAIMessage = .{},
};

const OpenAIMessage = struct {
    content: []const u8 = "",
    tool_calls: []const OpenAIToolCall = &.{},
};

const OpenAIErrorEnvelope = struct {
    message: []const u8 = "",
};

const OpenAIToolCall = struct {
    function: OpenAIToolFunction = .{},
};

const OpenAIToolFunction = struct {
    name: []const u8 = "",
    arguments: []const u8 = "",
};

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    runMain(allocator, args) catch |err| {
        try stderrPrint("{s}\n", .{try friendlyRuntimeError(allocator, err)});
        std.process.exit(1);
    };
}

fn runMain(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const decision = cli.parse(if (args.len > 1) args[1..] else &.{});
    switch (decision) {
        .help => |command| {
            const text = try cli.renderHelp(allocator, command);
            defer allocator.free(text);
            try stdoutPrint("{s}\n", .{text});
        },
        .failure => |failure| {
            const text = try cli.renderFailure(allocator, failure);
            defer allocator.free(text);
            try stderrPrint("{s}\n", .{text});
            return error.InvalidArguments;
        },
        .action => |invocation| switch (invocation.action) {
            .init => try cmdInit(allocator),
            .doctor => try cmdDoctor(allocator),
            .models_list => try cmdModelsList(allocator),
            .mission_compose => try cmdMissionCompose(allocator),
            .mission_start => try cmdMissionStart(allocator, invocation.args),
            .mission_continue => try cmdMissionContinue(allocator),
            .mission_step => try cmdMissionStep(allocator),
            .ui => try cmdUi(allocator),
            .ui_bridge => try cmdUiBridge(allocator),
        },
    }
}

fn cmdInit(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try stdoutPrint("initialized project runtime in {s}\n", .{runtime_dir_name});
}

fn cmdDoctor(allocator: std.mem.Allocator) !void {
    const report = try runDoctorCheck(allocator);
    try stdoutPrint("{s}\n", .{report});
}

fn cmdModelsList(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    const models = try providerListModels(allocator, config.provider);
    for (models) |model| {
        try stdoutPrint("{s}\n", .{model});
    }
}

const interactive_alt_screen_on = "\x1b[?1049h";
const interactive_alt_screen_off = "\x1b[?1049l";
const interactive_cursor_hide = "\x1b[?25l";
const interactive_cursor_show = "\x1b[?25h";
const interactive_clear_home = "\x1b[2J\x1b[H";
const interactive_reset = "\x1b[0m";
const interactive_color_gold = "\x1b[38;5;179m";
const interactive_color_ivory = "\x1b[38;5;230m";
const interactive_color_muted = "\x1b[38;5;245m";
const interactive_color_blue = "\x1b[38;5;75m";
const interactive_color_prompt = "\x1b[38;5;215m";
const interactive_color_cursor = "\x1b[38;5;220m";
const interactive_color_danger = "\x1b[38;5;203m";
const interactive_color_success = "\x1b[38;5;114m";
const interactive_style_italic = "\x1b[3m";
const interactive_clear_line = "\r\x1b[2K";

const InteractiveKey = union(enum) {
    character: u8,
    enter,
    escape,
    backspace,
    delete,
    left,
    right,
    up,
    down,
    ctrl_c,
    ignore,
};

const RawTerminalMode = struct {
    original: std.posix.termios,
    active: bool = false,

    fn enter() !RawTerminalMode {
        const original = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
        var raw = original;
        raw.iflag.ICRNL = false;
        raw.iflag.IXON = false;
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;
        raw.lflag.IEXTEN = false;
        raw.lflag.ISIG = false;
        raw.cc[@intFromEnum(std.c.V.MIN)] = 1;
        raw.cc[@intFromEnum(std.c.V.TIME)] = 0;
        try std.posix.tcsetattr(std.posix.STDIN_FILENO, .NOW, raw);
        return .{
            .original = original,
            .active = true,
        };
    }

    fn restore(self: *RawTerminalMode) void {
        if (!self.active) return;
        std.posix.tcsetattr(std.posix.STDIN_FILENO, .NOW, self.original) catch {};
        self.active = false;
    }
};

const MissionComposerState = struct {
    prompt: std.ArrayList(u8) = .empty,
    cursor: usize = 0,
    models: []const []const u8 = &.{},
    selected_model: usize = 0,
    provider_name: []const u8 = "",
    roster_note: []const u8 = "",
};

const MissionComposerResult = struct {
    prompt: []const u8,
    selected_model: []const u8,
};

fn cmdMissionCompose(allocator: std.mem.Allocator) !void {
    if (!std.posix.isatty(std.posix.STDIN_FILENO) or !std.posix.isatty(std.posix.STDOUT_FILENO)) {
        try stderrPrint("interactive mission launcher requires a TTY; use `contubernium mission start \"...\"`\n", .{});
        return error.InvalidArguments;
    }

    try scaffoldProject(allocator);
    const config = try loadProjectConfig(allocator);

    const roster = try loadMissionComposerRoster(allocator, config.provider);
    var state = MissionComposerState{
        .models = roster.models,
        .selected_model = roster.selected_index,
        .provider_name = config.provider.type,
        .roster_note = roster.note,
    };
    defer state.prompt.deinit(allocator);

    var raw_mode = try RawTerminalMode.enter();
    defer raw_mode.restore();

    try stdoutPrint("{s}{s}", .{ interactive_alt_screen_on, interactive_cursor_hide });
    var screen_active = true;
    defer if (screen_active) {
        stdoutPrint("{s}{s}", .{ interactive_cursor_show, interactive_alt_screen_off }) catch {};
    };

    const result = try runMissionComposer(allocator, &state);

    try stdoutPrint("{s}{s}", .{ interactive_cursor_show, interactive_alt_screen_off });
    screen_active = false;
    raw_mode.restore();

    if (result == null) {
        try stdoutPrint("mission canceled\n", .{});
        return;
    }

    const launch = result.?;
    if (launch.selected_model.len > 0 and !eql(launch.selected_model, config.provider.model)) {
        _ = try saveSelectedModelByName(allocator, launch.selected_model);
    }

    try cmdMissionStart(allocator, &.{launch.prompt});
}

const MissionComposerRoster = struct {
    models: []const []const u8,
    selected_index: usize,
    note: []const u8,
};

fn loadMissionComposerRoster(allocator: std.mem.Allocator, provider: ProviderConfig) !MissionComposerRoster {
    var collected: std.ArrayList([]const u8) = .empty;
    errdefer collected.deinit(allocator);

    var note: []const u8 = "";
    const configured_model = trimAscii(provider.model);

    const listed_models = providerListModels(allocator, provider) catch |err| blk: {
        note = try friendlyRuntimeError(allocator, err);
        break :blk &.{}; // fall back to configured model only
    };

    for (listed_models) |model| {
        if (!containsString(collected.items, model)) {
            try collected.append(allocator, model);
        }
    }

    if (configured_model.len > 0 and !containsString(collected.items, configured_model)) {
        try collected.append(allocator, configured_model);
    }

    if (collected.items.len == 0) {
        try collected.append(allocator, if (configured_model.len > 0) configured_model else "unconfigured");
    }

    var selected_index: usize = 0;
    if (configured_model.len > 0) {
        for (collected.items, 0..) |model, index| {
            if (eql(model, configured_model)) {
                selected_index = index;
                break;
            }
        }
    }

    return .{
        .models = try collected.toOwnedSlice(allocator),
        .selected_index = selected_index,
        .note = note,
    };
}

fn runMissionComposer(allocator: std.mem.Allocator, state: *MissionComposerState) !?MissionComposerResult {
    while (true) {
        const screen = try renderMissionComposerScreen(allocator, state.*);
        defer allocator.free(screen);
        try stdoutPrint("{s}", .{screen});

        switch (try readInteractiveKey()) {
            .enter => {
                const prompt = trimAscii(state.prompt.items);
                if (prompt.len == 0) continue;
                return .{
                    .prompt = try allocator.dupe(u8, prompt),
                    .selected_model = state.models[state.selected_model],
                };
            },
            .escape, .ctrl_c => return null,
            .backspace => deletePromptBackward(state),
            .delete => deletePromptForward(state),
            .left => state.cursor = previousUtf8Index(state.prompt.items, state.cursor),
            .right => state.cursor = nextUtf8Index(state.prompt.items, state.cursor),
            .up => {
                if (state.models.len > 0) {
                    state.selected_model = if (state.selected_model == 0) state.models.len - 1 else state.selected_model - 1;
                }
            },
            .down => {
                if (state.models.len > 0) {
                    state.selected_model = (state.selected_model + 1) % state.models.len;
                }
            },
            .character => |char| try insertPromptCharacter(allocator, state, char),
            .ignore => {},
        }
    }
}

fn renderMissionComposerScreen(allocator: std.mem.Allocator, state: MissionComposerState) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    const selected_model = state.models[state.selected_model];
    const prompt_before = state.prompt.items[0..state.cursor];
    const prompt_after = state.prompt.items[state.cursor..];
    const prompt_empty = state.prompt.items.len == 0;

    try writer.writeAll(interactive_clear_home);
    try writer.print("{s}CONTUBERNIUM MISSION{s}\n", .{ interactive_color_gold, interactive_reset });
    try writer.print("{s}Interactive launcher for the plain CLI.{s}\n\n", .{ interactive_color_muted, interactive_reset });
    try writer.print("{s}Model{s}    {s}{d}/{d}{s}  {s}{s}{s}\n", .{
        interactive_color_muted,
        interactive_reset,
        interactive_color_blue,
        state.selected_model + 1,
        state.models.len,
        interactive_reset,
        interactive_color_ivory,
        selected_model,
        interactive_reset,
    });
    try writer.print("{s}Provider{s} {s}{s}{s}\n", .{
        interactive_color_muted,
        interactive_reset,
        interactive_color_ivory,
        if (state.provider_name.len > 0) state.provider_name else "unconfigured",
        interactive_reset,
    });
    if (state.roster_note.len > 0) {
        try writer.print("{s}Note{s}     {s}{s}{s}\n", .{
            interactive_color_muted,
            interactive_reset,
            interactive_color_danger,
            state.roster_note,
            interactive_reset,
        });
    }
    try writer.writeAll("\n");
    try writer.print("{s}Prompt{s}\n", .{ interactive_color_muted, interactive_reset });
    try writer.writeAll("  ");
    if (prompt_empty) {
        try writer.print("{s}|Describe the mission...{s}\n", .{ interactive_color_cursor, interactive_reset });
    } else {
        try writer.print("{s}{s}{s}|{s}{s}{s}\n", .{
            interactive_color_prompt,
            prompt_before,
            interactive_color_cursor,
            interactive_color_prompt,
            prompt_after,
            interactive_reset,
        });
    }
    try writer.writeAll("\n");
    try writer.print("{s}Enter{s} start mission  {s}Up/Down{s} switch model  {s}Left/Right{s} move cursor  {s}Esc{s} cancel\n", .{
        interactive_color_gold,
        interactive_reset,
        interactive_color_gold,
        interactive_reset,
        interactive_color_gold,
        interactive_reset,
        interactive_color_gold,
        interactive_reset,
    });

    return try buffer.toOwnedSlice(allocator);
}

fn insertPromptCharacter(allocator: std.mem.Allocator, state: *MissionComposerState, char: u8) !void {
    if (char < 32 or char == 127) return;
    try state.prompt.insert(allocator, state.cursor, char);
    state.cursor += 1;
}

fn deletePromptBackward(state: *MissionComposerState) void {
    if (state.cursor == 0) return;
    const start = previousUtf8Index(state.prompt.items, state.cursor);
    deletePromptRange(state, start, state.cursor);
    state.cursor = start;
}

fn deletePromptForward(state: *MissionComposerState) void {
    if (state.cursor >= state.prompt.items.len) return;
    const finish = nextUtf8Index(state.prompt.items, state.cursor);
    deletePromptRange(state, state.cursor, finish);
}

fn deletePromptRange(state: *MissionComposerState, start: usize, finish: usize) void {
    if (finish <= start or finish > state.prompt.items.len) return;
    const tail = state.prompt.items[finish..];
    std.mem.copyForwards(u8, state.prompt.items[start .. start + tail.len], tail);
    state.prompt.shrinkRetainingCapacity(state.prompt.items.len - (finish - start));
}

fn previousUtf8Index(text: []const u8, index: usize) usize {
    if (index == 0) return 0;
    var cursor = index - 1;
    while (cursor > 0 and (text[cursor] & 0b1100_0000) == 0b1000_0000) : (cursor -= 1) {}
    return cursor;
}

fn nextUtf8Index(text: []const u8, index: usize) usize {
    if (index >= text.len) return text.len;
    const scalar = decodeUtf8Scalar(text, index);
    if (scalar.byte_len == 0) return text.len;
    return @min(text.len, index + scalar.byte_len);
}

fn readInteractiveByte() !u8 {
    var byte: [1]u8 = undefined;
    const read_len = try std.posix.read(std.posix.STDIN_FILENO, &byte);
    if (read_len == 0) return error.EndOfStream;
    return byte[0];
}

fn readInteractiveKey() !InteractiveKey {
    const byte = try readInteractiveByte();
    return switch (byte) {
        3 => .ctrl_c,
        10, 13 => .enter,
        8, 127 => .backspace,
        27 => blk: {
            if (!try pollInput(20)) break :blk .escape;
            const first = try readInteractiveByte();
            if (first != '[') break :blk .escape;
            const second = try readInteractiveByte();
            break :blk switch (second) {
                'A' => .up,
                'B' => .down,
                'C' => .right,
                'D' => .left,
                '3' => del: {
                    if (try pollInput(20) and (try readInteractiveByte()) == '~') break :del .delete;
                    break :del .ignore;
                },
                else => .ignore,
            };
        },
        else => if (byte >= 32) .{ .character = byte } else .ignore,
    };
}

const CliSpinnerState = struct {
    mutex: std.Thread.Mutex = .{},
    active: bool = false,
    rendered: bool = false,
    shutdown: bool = false,
    phase: usize = 0,
    actor_len: usize = 0,
    actor_buf: [32]u8 = [_]u8{0} ** 32,
};

const CliSpinner = struct {
    allocator: ?std.mem.Allocator = null,
    state: ?*CliSpinnerState = null,
    thread: ?std.Thread = null,
    enabled: bool = false,

    fn init(allocator: std.mem.Allocator) !CliSpinner {
        return initWithEnabled(allocator, terminalUiEnabled(std.posix.STDERR_FILENO));
    }

    fn initWithEnabled(allocator: std.mem.Allocator, enabled: bool) !CliSpinner {
        if (!enabled) return .{};

        const state = try allocator.create(CliSpinnerState);
        errdefer allocator.destroy(state);
        state.* = .{};

        var spinner = CliSpinner{
            .allocator = allocator,
            .state = state,
            .enabled = true,
        };
        spinner.thread = try std.Thread.spawn(.{}, cliSpinnerMain, .{state});
        return spinner;
    }

    fn hooks(self: *CliSpinner) RuntimeHooks {
        if (!self.enabled or self.state == null) return .{};
        return .{
            .context = self.state.?,
            .emit_fn = cliSpinnerEmit,
        };
    }

    fn deinit(self: *CliSpinner) void {
        if (!self.enabled or self.state == null) return;
        const state = self.state.?;
        state.mutex.lock();
        state.shutdown = true;
        state.active = false;
        state.mutex.unlock();
        if (self.thread) |thread| thread.join();
        if (self.allocator) |allocator| allocator.destroy(state);
        self.allocator = null;
        self.state = null;
        self.thread = null;
        self.enabled = false;
    }
};

fn cliSpinnerEmit(context: ?*anyopaque, event: RuntimeUiEvent) void {
    const state: *CliSpinnerState = @ptrCast(@alignCast(context.?));
    state.mutex.lock();
    defer state.mutex.unlock();

    switch (event.kind) {
        .stream_start => {
            state.active = true;
            state.phase = 0;
            const actor = if (event.actor.len > 0) event.actor else "decanus";
            const actor_len = @min(actor.len, state.actor_buf.len);
            @memcpy(state.actor_buf[0..actor_len], actor[0..actor_len]);
            state.actor_len = actor_len;
        },
        .stream_finalize, .approval_request => {
            state.active = false;
        },
        .state_snapshot => {
            if (eql(event.runtime_status, "blocked") or eql(event.runtime_status, "complete") or eql(event.runtime_status, "idle")) {
                state.active = false;
            }
        },
        else => {},
    }
}

fn cliSpinnerMain(state: *CliSpinnerState) void {
    const frames = [_][]const u8{ "I", "II", "III", "IV", "V", "VI" };

    while (true) {
        var shutdown = false;
        var active = false;
        var clear_line = false;
        var actor_len: usize = 0;
        var actor_buf: [32]u8 = undefined;
        var frame: []const u8 = "";

        state.mutex.lock();
        shutdown = state.shutdown;
        active = state.active;
        clear_line = state.rendered and !state.active;
        if (active) {
            frame = frames[state.phase % frames.len];
            state.phase = (state.phase + 1) % frames.len;
            state.rendered = true;
            actor_len = state.actor_len;
            @memcpy(actor_buf[0..actor_len], state.actor_buf[0..actor_len]);
        } else if (clear_line) {
            state.rendered = false;
        }
        state.mutex.unlock();

        if (shutdown) {
            cliClearSpinnerLine();
            return;
        }

        if (active) {
            cliRenderSpinnerFrame(frame, actor_buf[0..actor_len]);
            std.Thread.sleep(120 * std.time.ns_per_ms);
            continue;
        }

        if (clear_line) {
            cliClearSpinnerLine();
        }
        std.Thread.sleep(60 * std.time.ns_per_ms);
    }
}

fn cliRenderSpinnerFrame(frame: []const u8, actor: []const u8) void {
    const label = if (actor.len > 0) actor else "decanus";
    stderrPrint("{s}{s}{s}{s} {s}testudo advancing{s} {s}{s}{s}", .{
        interactive_clear_line,
        interactive_color_gold,
        frame,
        interactive_reset,
        interactive_color_muted,
        interactive_reset,
        interactive_color_blue,
        label,
        interactive_reset,
    }) catch {};
}

fn cliClearSpinnerLine() void {
    stderrPrint("{s}", .{interactive_clear_line}) catch {};
}

fn envFlagEnabled(name: [:0]const u8) bool {
    const value = std.posix.getenv(name) orelse return false;
    const text = std.mem.trim(u8, value, " \t\r\n");
    if (text.len == 0) return false;
    if (eql(text, "0")) return false;
    if (std.ascii.eqlIgnoreCase(text, "false")) return false;
    if (std.ascii.eqlIgnoreCase(text, "no")) return false;
    return true;
}

fn envFlagPresent(name: [:0]const u8) bool {
    return std.posix.getenv(name) != null;
}

fn terminalUiEnabled(file_no: std.posix.fd_t) bool {
    if (!std.posix.isatty(file_no)) return false;
    const term = std.posix.getenv("TERM") orelse return true;
    return !eql(term, "dumb");
}

fn cliStylesEnabled(file_no: std.posix.fd_t) bool {
    if (envFlagPresent("NO_COLOR")) return false;
    if (envFlagEnabled("CLICOLOR_FORCE")) return true;
    if (envFlagEnabled("FORCE_COLOR")) return true;
    return terminalUiEnabled(file_no);
}

fn renderCliMissionOutcome(allocator: std.mem.Allocator, state: AppState) ![]const u8 {
    const styled = cliStylesEnabled(std.posix.STDOUT_FILENO);
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    if (state.mission.final_response.len > 0 and state.global_status == .complete) {
        try writeCliMissionStatus(writer, styled, "complete", interactive_color_success);
        try writeCliMissionSection(writer, styled, "prompt", state.mission.initial_prompt, interactive_color_prompt, true);
        try writeCliMissionSection(writer, styled, "response", state.mission.final_response, interactive_color_blue, false);
        return try buffer.toOwnedSlice(allocator);
    }

    if (state.runtime_session.last_error.len > 0 and state.runtime_session.status == .blocked) {
        try writeCliMissionStatus(writer, styled, "blocked", interactive_color_danger);
        try writeCliMissionSection(writer, styled, "prompt", state.mission.initial_prompt, interactive_color_prompt, true);
        try writeCliMissionSection(writer, styled, "error", state.runtime_session.last_error, interactive_color_danger, false);
        return try buffer.toOwnedSlice(allocator);
    }

    try writeCliMissionStatus(writer, styled, "in progress", interactive_color_gold);
    try writeCliMissionSection(writer, styled, "prompt", state.mission.initial_prompt, interactive_color_prompt, true);
    if (state.agent_loop.active_tool) |active_tool| {
        const status_text = try std.fmt.allocPrint(allocator, "current actor: {s}\nactive tool: {s}\niteration: {d}", .{
            actorName(state.current_actor),
            actorName(active_tool),
            state.agent_loop.iteration,
        });
        defer allocator.free(status_text);
        try writeCliMissionSection(
            writer,
            styled,
            "status",
            status_text,
            interactive_color_blue,
            false,
        );
        return try buffer.toOwnedSlice(allocator);
    }

    const status_text = try std.fmt.allocPrint(allocator, "status: {s}\ncurrent actor: {s}\niteration: {d}", .{
        @tagName(state.global_status),
        actorName(state.current_actor),
        state.agent_loop.iteration,
    });
    defer allocator.free(status_text);
    try writeCliMissionSection(
        writer,
        styled,
        "status",
        status_text,
        interactive_color_blue,
        false,
    );
    return try buffer.toOwnedSlice(allocator);
}

fn writeCliMissionStatus(writer: anytype, styled: bool, status: []const u8, color: []const u8) !void {
    if (styled) {
        try writer.print("{s}{s}{s}", .{ color, status, interactive_reset });
    } else {
        try writer.writeAll(status);
    }
}

fn writeCliMissionSection(
    writer: anytype,
    styled: bool,
    label: []const u8,
    body: []const u8,
    color: []const u8,
    italic: bool,
) !void {
    if (body.len == 0) return;
    if (styled) {
        try writer.print("\n\n{s}{s}{s}\n  {s}", .{ interactive_color_muted, label, interactive_reset, color });
        if (italic) try writer.writeAll(interactive_style_italic);
        try writer.print("{s}{s}", .{ body, interactive_reset });
    } else {
        try writer.print("\n\n{s}\n  {s}", .{ label, body });
    }
}

fn cmdMissionStart(allocator: std.mem.Allocator, prompt_args: []const []const u8) !void {
    const mission_prompt = try joinArgs(allocator, prompt_args);
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    try runMissionInternal(allocator, mission_prompt, spinner.hooks());
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

fn cmdMissionStep(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    initializeRuntimeSession(allocator, &state, config);
    _ = try executeStep(allocator, config, &state, spinner.hooks());
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

fn cmdMissionContinue(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    initializeRuntimeSession(allocator, &state, config);
    try runLoop(allocator, config, &state, spinner.hooks());
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

fn cmdUi(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try launchOpenTuiFrontend(allocator);
}

fn resolveOpenTuiFrontendRoot(allocator: std.mem.Allocator) ![]const u8 {
    const configured = std.process.getEnvVarOwned(allocator, "CONTUBERNIUM_OPENTUI_DIR") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => null,
        else => return err,
    };
    if (configured) |root| {
        const manifest = try std.fs.path.join(allocator, &.{ root, "package.json" });
        defer allocator.free(manifest);
        if (pathExists(manifest)) return root;
        allocator.free(root);
    }

    const repo_manifest = "opentui/package.json";
    if (pathExists(repo_manifest)) {
        return try allocator.dupe(u8, "opentui");
    }

    const home = try resolveContuberniumHome(allocator);
    defer allocator.free(home);
    const installed_root = try std.fs.path.join(allocator, &.{ home, "opentui" });
    errdefer allocator.free(installed_root);
    const installed_manifest = try std.fs.path.join(allocator, &.{ installed_root, "package.json" });
    defer allocator.free(installed_manifest);
    if (pathExists(installed_manifest)) return installed_root;

    return error.OpenTuiFrontendMissing;
}

fn launchOpenTuiFrontend(allocator: std.mem.Allocator) !void {
    const frontend_root = try resolveOpenTuiFrontendRoot(allocator);
    defer allocator.free(frontend_root);

    const cwd = try std.process.getCwdAlloc(allocator);
    defer allocator.free(cwd);

    const self_exe = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(self_exe);

    var env_map = try std.process.getEnvMap(allocator);
    defer env_map.deinit();
    try env_map.put("CONTUBERNIUM_BRIDGE_EXE", self_exe);
    try env_map.put("CONTUBERNIUM_PROJECT_CWD", cwd);
    try env_map.put("CONTUBERNIUM_OPENTUI_DIR", frontend_root);

    var child = std.process.Child.init(&.{ "bun", "run", "main.tsx" }, allocator);
    child.cwd = frontend_root;
    child.env_map = &env_map;
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = child.spawnAndWait() catch |err| switch (err) {
        error.FileNotFound => {
            try stderrPrint("OpenTUI launch failed: bun is required on PATH.\n", .{});
            return error.BunMissing;
        },
        else => return err,
    };

    switch (term) {
        .Exited => |code| {
            if (code != 0) return error.OpenTuiFailed;
        },
        else => return error.OpenTuiFailed,
    }
}

fn runMission(allocator: std.mem.Allocator, mission_prompt: []const u8) !void {
    try runMissionInternal(allocator, mission_prompt, .{});
}

fn runMissionInternal(allocator: std.mem.Allocator, mission_prompt: []const u8, hooks: RuntimeHooks) !void {
    try scaffoldProject(allocator);

    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);

    resetStateForMission(&state, mission_prompt);
    initializeRuntimeSession(allocator, &state, config);
    try initializeRuntimeRunLog(allocator, config, &state, "mission");
    try logRuntimeEvent(allocator, config, &state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "run_started",
        .status = "running",
        .summary = "mission initialized",
        .input = mission_prompt,
        .include_snapshot = true,
    });
    try saveState(allocator, config.paths.state_file, state);
    emitStateSnapshot(hooks, config, state);

    try runLoop(allocator, config, &state, hooks);
    try saveState(allocator, config.paths.state_file, state);
    emitStateSnapshot(hooks, config, state);
}

fn formatModelRoster(allocator: std.mem.Allocator, models: []const []const u8, current_model: []const u8) ![]const u8 {
    if (models.len == 0) return "no models reported by backend";
    var lines: std.ArrayList([]const u8) = .empty;
    for (models, 0..) |model, index| {
        const suffix = if (eql(model, current_model)) " (current)" else "";
        try lines.append(allocator, try std.fmt.allocPrint(allocator, "[{d}] {s}{s}", .{ index + 1, model, suffix }));
    }
    return try joinStrings(allocator, lines.items, "\n");
}

fn saveSelectedModelByName(allocator: std.mem.Allocator, model_name: []const u8) ![]const u8 {
    const config_path = try resolveConfigPath(allocator);
    var config = try loadConfig(allocator, config_path);
    config.provider.model = model_name;
    try saveConfig(allocator, config_path, config);

    var state = try loadState(allocator, config.paths.state_file);
    state.runtime_session.model = model_name;
    try saveState(allocator, config.paths.state_file, state);

    return try std.fmt.allocPrint(allocator, "active model set to {s}", .{model_name});
}

fn isUnsignedDecimal(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |char| {
        if (char < '0' or char > '9') return false;
    }
    return true;
}

fn renderStatusBlock(allocator: std.mem.Allocator, snapshot: TuiSnapshot) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "project: {s}\nprovider: {s}\nmodel: {s}\nlogs dir: {s}\nactor: {s}\nlane: {s}\nglobal status: {s}\nruntime status: {s}\nloop status: {s}\napproval status: {s}\nstep: {s}\nstep detail: {s}\nturn: {d}/{d}\ncontext est: {d} tokens ({d}% used)\ncontext left: {d}\ncondensed: {d} runs / {d} events\nactive log: {s}\nlast error: {s}",
        .{
            snapshot.project_name,
            snapshot.provider_type,
            snapshot.model,
            snapshot.logs_dir,
            snapshot.current_actor,
            snapshot.active_lane,
            snapshot.global_status,
            snapshot.runtime_status,
            snapshot.loop_status,
            snapshot.approval_status,
            snapshot.last_step_kind,
            if (snapshot.last_step_summary.len > 0) snapshot.last_step_summary else "none",
            snapshot.iteration,
            snapshot.max_iterations,
            snapshot.estimated_prompt_tokens,
            snapshot.context_used_percent,
            snapshot.remaining_context_tokens,
            snapshot.condensation_count,
            snapshot.condensed_history_events,
            if (snapshot.last_log_path.len > 0) snapshot.last_log_path else "none",
            if (snapshot.last_error.len > 0) snapshot.last_error else "none",
        },
    );
}

fn usablePromptTokenWindow(config: ContextConfig) usize {
    if (config.estimated_context_window_tokens > config.response_reserve_tokens) {
        return config.estimated_context_window_tokens - config.response_reserve_tokens;
    }
    return config.estimated_context_window_tokens;
}

fn ensureLoopBudget(state: *AppState) void {
    if (state.agent_loop.max_iterations == 0 or state.agent_loop.max_iterations == legacy_default_max_iterations) {
        state.agent_loop.max_iterations = default_max_iterations;
    }
}

fn resolvedContextBudget(config: ContextConfig, budget: ContextBudgetState) ContextBudgetState {
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

fn buildStateSnapshot(config: AppConfig, state: AppState, project_name: []const u8) StateSnapshot {
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

fn snapshotFromState(config: AppConfig, state: AppState, project_name: []const u8) TuiSnapshot {
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

fn startWorker(
    allocator: std.mem.Allocator,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    command: WorkerCommandKind,
    mission_prompt: []const u8,
) !*WorkerTask {
    const task = try allocator.create(WorkerTask);
    task.* = .{
        .allocator = allocator,
        .queue = queue,
        .control = control,
        .command = command,
        .mission_prompt = mission_prompt,
    };
    control.interrupt_requested.store(false, .seq_cst);
    control.running.store(true, .seq_cst);
    control.approval_mutex.lock();
    control.approval_pending = false;
    control.approval_response = null;
    control.approval_mutex.unlock();
    task.thread = try std.Thread.spawn(.{}, workerMain, .{task});
    return task;
}

fn workerMain(task: *WorkerTask) void {
    defer task.control.running.store(false, .seq_cst);

    const hooks = RuntimeHooks{
        .context = task,
        .emit_fn = workerEmitEvent,
        .interrupted_fn = workerIsInterrupted,
        .approval_fn = workerRequestApproval,
    };

    switch (task.command) {
        .mission => {
            runMissionInternal(task.allocator, task.mission_prompt, hooks) catch |err| {
                emitLog(hooks, .danger, "", "Runtime Error", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
            };
        },
        .resume_run => {
            const config = loadProjectConfig(task.allocator) catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            var state = loadState(task.allocator, config.paths.state_file) catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            initializeRuntimeSession(task.allocator, &state, config);
            initializeRuntimeRunLog(task.allocator, config, &state, "resume") catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            logRuntimeEvent(task.allocator, config, &state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "run_started",
                .status = "running",
                .summary = "resume requested",
                .include_snapshot = true,
            }) catch {};
            runLoop(task.allocator, config, &state, hooks) catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            saveState(task.allocator, config.paths.state_file, state) catch {};
            emitStateSnapshot(hooks, config, state);
            const summary = missionOutcomeSummary(task.allocator, state) catch "resume completed";
            emitLog(hooks, toneForOutcome(state), "", "Loop Status", summary, .plain);
        },
        .doctor => {
            const report = runDoctorCheck(task.allocator) catch |err| {
                emitLog(hooks, .danger, "", "Doctor Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            emitLog(hooks, .success, "", "Doctor", report, .plain);
            const config = loadProjectConfig(task.allocator) catch return;
            const state = loadState(task.allocator, config.paths.state_file) catch return;
            emitStateSnapshot(hooks, config, state);
        },
        .models => {
            const config = loadProjectConfig(task.allocator) catch |err| {
                emitLog(hooks, .danger, "", "Model Query Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            const models = providerListModels(task.allocator, config.provider) catch |err| {
                emitLog(hooks, .danger, "", "Model Query Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            const roster = formatModelRoster(task.allocator, models, config.provider.model) catch "unable to format models";
            hooks.emit(.{
                .kind = .model_roster,
                .title = "models",
                .text = roster,
            });
        },
    }
}

fn workerEmitEvent(context: ?*anyopaque, event: RuntimeUiEvent) void {
    const task: *WorkerTask = @ptrCast(@alignCast(context.?));
    task.queue.push(event);
}

fn workerIsInterrupted(context: ?*anyopaque) bool {
    const task: *WorkerTask = @ptrCast(@alignCast(context.?));
    return task.control.interrupt_requested.load(.seq_cst);
}

fn workerRequestApproval(context: ?*anyopaque, tool_name: []const u8, detail: []const u8) bool {
    const task: *WorkerTask = @ptrCast(@alignCast(context.?));
    const control = task.control;

    control.approval_mutex.lock();
    defer control.approval_mutex.unlock();

    control.approval_pending = true;
    control.approval_response = null;

    task.queue.push(.{
        .kind = .approval_request,
        .title = tool_name,
        .text = detail,
        .tone = .warning,
    });

    while (control.approval_response == null and !control.interrupt_requested.load(.seq_cst)) {
        control.approval_cond.wait(&control.approval_mutex);
    }

    const decision = control.approval_response orelse false;
    control.approval_pending = false;
    control.approval_response = null;
    return decision;
}

fn submitApprovalResponse(control: *RuntimeControl, approved: bool) void {
    control.approval_mutex.lock();
    defer control.approval_mutex.unlock();
    if (!control.approval_pending) return;
    control.approval_response = approved;
    control.approval_cond.signal();
}

const OpenTuiBridgeCommand = struct {
    type: []const u8 = "",
    prompt: []const u8 = "",
    model: []const u8 = "",
    approved: ?bool = null,
};

const OpenTuiBridge = struct {
    allocator: std.mem.Allocator,
    queue: RuntimeEventQueue,
    control: RuntimeControl = .{},
    snapshot: TuiSnapshot = .{},
    owns_snapshot: bool = false,
    pending_input: std.ArrayList(u8) = .empty,
    worker: ?*WorkerTask = null,

    fn init(allocator: std.mem.Allocator) OpenTuiBridge {
        return .{
            .allocator = allocator,
            .queue = .{ .allocator = allocator },
        };
    }

    fn deinit(self: *OpenTuiBridge) void {
        self.stopWorker();
        self.pending_input.deinit(self.allocator);
        if (self.owns_snapshot) freeTuiSnapshot(self.allocator, &self.snapshot);
        self.queue.deinit();
    }

    fn stopWorker(self: *OpenTuiBridge) void {
        if (self.worker) |task| {
            if (task.control.approval_pending) submitApprovalResponse(task.control, false);
            if (task.control.running.load(.seq_cst)) task.control.interrupt_requested.store(true, .seq_cst);
            if (task.thread) |thread| thread.join();
            self.allocator.destroy(task);
            self.worker = null;
        }
    }

    fn collectFinishedWorker(self: *OpenTuiBridge) void {
        if (self.worker) |task| {
            if (!task.control.running.load(.seq_cst)) {
                if (task.thread) |thread| thread.join();
                self.allocator.destroy(task);
                self.worker = null;
            }
        }
    }

    fn isBusy(self: *const OpenTuiBridge) bool {
        return self.worker != null and self.control.running.load(.seq_cst);
    }
};

fn snapshotAfterRuntimeEvent(current: TuiSnapshot, event: RuntimeUiEvent) TuiSnapshot {
    return .{
        .project_name = if (event.project_name.len > 0) event.project_name else current.project_name,
        .provider_type = if (event.provider_type.len > 0) event.provider_type else current.provider_type,
        .model = if (event.model.len > 0) event.model else current.model,
        .logs_dir = if (event.logs_dir.len > 0) event.logs_dir else current.logs_dir,
        .approval_mode = if (event.approval_mode.len > 0) event.approval_mode else current.approval_mode,
        .global_status = if (event.global_status.len > 0) event.global_status else current.global_status,
        .runtime_status = if (event.runtime_status.len > 0) event.runtime_status else current.runtime_status,
        .loop_status = if (event.loop_status.len > 0) event.loop_status else current.loop_status,
        .approval_status = if (event.approval_status.len > 0) event.approval_status else current.approval_status,
        .current_actor = if (event.current_actor.len > 0) event.current_actor else current.current_actor,
        .active_tool = event.active_tool,
        .active_lane = if (event.active_lane.len > 0) event.active_lane else current.active_lane,
        .last_step_kind = if (event.last_step_kind.len > 0) event.last_step_kind else current.last_step_kind,
        .last_step_summary = if (event.last_step_summary.len > 0) event.last_step_summary else current.last_step_summary,
        .current_goal = event.current_goal,
        .last_tool_result = event.last_tool_result,
        .last_error = event.last_error,
        .last_log_path = event.last_log_path,
        .iteration = event.iteration,
        .max_iterations = if (event.max_iterations > 0) event.max_iterations else current.max_iterations,
        .estimated_prompt_chars = if (event.estimated_prompt_chars > 0) event.estimated_prompt_chars else current.estimated_prompt_chars,
        .estimated_prompt_tokens = if (event.estimated_prompt_tokens > 0) event.estimated_prompt_tokens else current.estimated_prompt_tokens,
        .context_window_tokens = if (event.context_window_tokens > 0) event.context_window_tokens else current.context_window_tokens,
        .response_reserve_tokens = if (event.response_reserve_tokens > 0) event.response_reserve_tokens else current.response_reserve_tokens,
        .remaining_context_tokens = if (event.remaining_context_tokens > 0 or event.estimated_prompt_tokens > 0) event.remaining_context_tokens else current.remaining_context_tokens,
        .context_used_percent = if (event.context_used_percent > 0 or event.estimated_prompt_tokens > 0) event.context_used_percent else current.context_used_percent,
        .condensation_count = if (event.condensation_count > 0) event.condensation_count else current.condensation_count,
        .condensed_history_events = if (event.condensed_history_events > 0) event.condensed_history_events else current.condensed_history_events,
    };
}

fn runtimeEventFromSnapshot(snapshot: TuiSnapshot) RuntimeUiEvent {
    return .{
        .kind = .state_snapshot,
        .project_name = snapshot.project_name,
        .provider_type = snapshot.provider_type,
        .model = snapshot.model,
        .logs_dir = snapshot.logs_dir,
        .approval_mode = snapshot.approval_mode,
        .global_status = snapshot.global_status,
        .runtime_status = snapshot.runtime_status,
        .loop_status = snapshot.loop_status,
        .approval_status = snapshot.approval_status,
        .current_actor = snapshot.current_actor,
        .active_tool = snapshot.active_tool,
        .active_lane = snapshot.active_lane,
        .last_step_kind = snapshot.last_step_kind,
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

fn writeBridgeRuntimeEvent(event: RuntimeUiEvent) !void {
    var buffer: [4096]u8 = undefined;
    var writer = std.fs.File.stdout().writer(&buffer);
    try std.json.Stringify.value(.{
        .kind = @tagName(event.kind),
        .tone = @tagName(event.tone),
        .actor = event.actor,
        .title = event.title,
        .text = event.text,
        .highlight = @tagName(event.highlight),
        .project_name = event.project_name,
        .provider_type = event.provider_type,
        .model = event.model,
        .logs_dir = event.logs_dir,
        .approval_mode = event.approval_mode,
        .global_status = event.global_status,
        .runtime_status = event.runtime_status,
        .loop_status = event.loop_status,
        .approval_status = event.approval_status,
        .current_actor = event.current_actor,
        .active_tool = event.active_tool,
        .active_lane = event.active_lane,
        .last_step_kind = event.last_step_kind,
        .last_step_summary = event.last_step_summary,
        .current_goal = event.current_goal,
        .last_tool_result = event.last_tool_result,
        .last_error = event.last_error,
        .last_log_path = event.last_log_path,
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
    }, .{}, &writer.interface);
    try writer.interface.writeByte('\n');
    try writer.interface.flush();
}

fn bridgeEmitLog(tone: ChatTone, actor: []const u8, title: []const u8, text: []const u8, highlight: HighlightKind) !void {
    try writeBridgeRuntimeEvent(.{
        .kind = .log,
        .tone = tone,
        .actor = actor,
        .title = title,
        .text = text,
        .highlight = highlight,
    });
}

fn bridgeRefreshSnapshot(bridge: *OpenTuiBridge) !void {
    const config = try loadProjectConfig(bridge.allocator);
    const state = try loadState(bridge.allocator, config.paths.state_file);
    const cwd = try std.process.getCwdAlloc(bridge.allocator);
    defer bridge.allocator.free(cwd);

    try setOwnedSnapshot(
        bridge.allocator,
        &bridge.snapshot,
        &bridge.owns_snapshot,
        snapshotFromState(config, state, std.fs.path.basename(cwd)),
    );
    try writeBridgeRuntimeEvent(runtimeEventFromSnapshot(bridge.snapshot));
}

fn bridgeFlushRuntimeEvents(bridge: *OpenTuiBridge) !void {
    const events = try bridge.queue.drain(bridge.allocator);
    defer freeRuntimeUiEvents(bridge.allocator, events);

    for (events) |event| {
        if (event.kind == .state_snapshot) {
            try setOwnedSnapshot(
                bridge.allocator,
                &bridge.snapshot,
                &bridge.owns_snapshot,
                snapshotAfterRuntimeEvent(bridge.snapshot, event),
            );
        }
        try writeBridgeRuntimeEvent(event);
    }
}

fn bridgeStartWorker(bridge: *OpenTuiBridge, command: WorkerCommandKind, mission_prompt: []const u8) !void {
    bridge.worker = try startWorker(bridge.allocator, &bridge.queue, &bridge.control, command, mission_prompt);
}

fn bridgeHandleCommand(bridge: *OpenTuiBridge, line: []const u8) !bool {
    const command = parseJson(OpenTuiBridgeCommand, bridge.allocator, line) catch {
        try bridgeEmitLog(.danger, "opentui", "Bridge Command Failed", "invalid OpenTUI bridge command JSON", .plain);
        return true;
    };

    if (eql(command.type, "exit")) return false;

    if (eql(command.type, "snapshot")) {
        try bridgeRefreshSnapshot(bridge);
        return true;
    }

    if (eql(command.type, "approval")) {
        if (command.approved) |approved| {
            submitApprovalResponse(&bridge.control, approved);
        } else {
            try bridgeEmitLog(.warning, "opentui", "Approval Pending", "approval commands require an approved boolean", .plain);
        }
        return true;
    }

    if (eql(command.type, "interrupt")) {
        if (bridge.isBusy()) {
            bridge.control.interrupt_requested.store(true, .seq_cst);
            submitApprovalResponse(&bridge.control, false);
            try bridgeEmitLog(.warning, "runtime", "Interrupt", "interrupt requested", .plain);
        } else {
            try bridgeEmitLog(.info, "runtime", "Interrupt", "no active command", .plain);
        }
        return true;
    }

    if (eql(command.type, "set_model")) {
        if (bridge.isBusy()) {
            try bridgeEmitLog(.danger, "runtime", "Busy", "change the model after the active command finishes", .plain);
            return true;
        }
        if (trimAscii(command.model).len == 0) {
            try bridgeEmitLog(.warning, "models", "Usage", "set_model requires a model name", .plain);
            return true;
        }
        const saved = saveSelectedModelByName(bridge.allocator, trimAscii(command.model)) catch |err| {
            try bridgeEmitLog(.danger, "models", "Model Change Failed", try friendlyRuntimeError(bridge.allocator, err), .plain);
            return true;
        };
        try bridgeEmitLog(.success, "models", "Model Changed", saved, .plain);
        try bridgeRefreshSnapshot(bridge);
        return true;
    }

    if (bridge.isBusy()) {
        try bridgeEmitLog(.danger, "runtime", "Busy", "wait for the active command to finish or interrupt it first", .plain);
        return true;
    }

    if (eql(command.type, "mission")) {
        if (trimAscii(command.prompt).len == 0) {
            try bridgeEmitLog(.warning, "runtime", "Mission Missing", "mission commands require a prompt", .plain);
            return true;
        }
        try bridgeStartWorker(bridge, .mission, try bridge.allocator.dupe(u8, trimAscii(command.prompt)));
        return true;
    }

    if (eql(command.type, "resume")) {
        try bridgeStartWorker(bridge, .resume_run, "");
        return true;
    }

    if (eql(command.type, "doctor")) {
        try bridgeStartWorker(bridge, .doctor, "");
        return true;
    }

    if (eql(command.type, "models")) {
        try bridgeStartWorker(bridge, .models, "");
        return true;
    }

    try bridgeEmitLog(.danger, "opentui", "Unknown Command", try std.fmt.allocPrint(bridge.allocator, "unknown bridge command: {s}", .{command.type}), .plain);
    return true;
}

fn bridgeProcessInputBytes(bridge: *OpenTuiBridge, bytes: []const u8) !bool {
    try bridge.pending_input.appendSlice(bridge.allocator, bytes);
    while (std.mem.indexOfScalar(u8, bridge.pending_input.items, '\n')) |newline_index| {
        const line = trimAscii(bridge.pending_input.items[0..newline_index]);
        const owned_line = try bridge.allocator.dupe(u8, line);
        defer bridge.allocator.free(owned_line);
        const remainder = bridge.pending_input.items[newline_index + 1 ..];
        std.mem.copyForwards(u8, bridge.pending_input.items[0..remainder.len], remainder);
        bridge.pending_input.shrinkRetainingCapacity(remainder.len);
        if (owned_line.len == 0) continue;
        const keep_running = try bridgeHandleCommand(bridge, owned_line);
        if (!keep_running) return false;
    }
    return true;
}

fn cmdUiBridge(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);

    var bridge = OpenTuiBridge.init(allocator);
    defer bridge.deinit();

    try bridgeRefreshSnapshot(&bridge);

    while (true) {
        bridge.collectFinishedWorker();
        try bridgeFlushRuntimeEvents(&bridge);

        if (!try pollInput(50)) continue;

        var input_buf: [1024]u8 = undefined;
        const input_len = try std.posix.read(std.posix.STDIN_FILENO, &input_buf);
        if (input_len == 0) return;

        const keep_running = try bridgeProcessInputBytes(&bridge, input_buf[0..input_len]);
        if (!keep_running) return;
    }
}

fn compactTextForUi(allocator: std.mem.Allocator, text: []const u8, max_lines: usize, max_chars: usize) ![]const u8 {
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

fn pluralSuffix(count: usize) []const u8 {
    return if (count == 1) "" else "s";
}

fn writeToolRequestLabel(writer: anytype, request: ToolRequest) !void {
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

fn summarizeToolRequestsForUi(allocator: std.mem.Allocator, requests: []const ToolRequest) ![]const u8 {
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

fn summarizeDecanusDecisionForUi(allocator: std.mem.Allocator, decision: DecanusDecision) ![]const u8 {
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

fn summarizeSpecialistResultForUi(allocator: std.mem.Allocator, result: SpecialistResult) ![]const u8 {
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

fn pollInput(timeout_ms: i32) !bool {
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

const DecodedScalar = struct {
    codepoint: u21,
    byte_len: usize,
};

fn decodeUtf8Scalar(text: []const u8, index: usize) DecodedScalar {
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

fn safeUtf8PrefixByBytes(text: []const u8, max_bytes: usize) []const u8 {
    if (text.len <= max_bytes) return text;

    var index: usize = 0;
    while (index < text.len and index < max_bytes) {
        const scalar = decodeUtf8Scalar(text, index);
        if (index + scalar.byte_len > max_bytes) break;
        index += scalar.byte_len;
    }
    return text[0..index];
}

fn actorName(actor: Actor) []const u8 {
    return @tagName(actor);
}

fn maybeActorName(actor: ?Actor) []const u8 {
    if (actor) |value| return actorName(value);
    return "";
}

fn laneName(lane: Lane) []const u8 {
    return @tagName(lane);
}

fn parseActor(text: []const u8) ?Actor {
    return std.meta.stringToEnum(Actor, text);
}

fn parseInvocationResultStatus(text: []const u8) ?InvocationResultStatus {
    return std.meta.stringToEnum(InvocationResultStatus, text);
}

fn buildRuntimeFailure(
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

fn stateManager(state: *AppState) StateManager {
    return StateManager.init(state);
}

fn recordRuntimeFailure(state: *AppState, failure: RuntimeFailure) void {
    stateManager(state).recordFailure(failure);
}

fn clearRuntimeFailure(state: *AppState) void {
    stateManager(state).clearFailure();
}

fn currentLaneForState(state: AppState) []const u8 {
    if (state.agent_loop.active_tool) |active_tool| return laneName(protocol.laneForActor(active_tool));
    return laneName(protocol.laneForActor(state.current_actor));
}

fn toneForOutcome(state: AppState) ChatTone {
    if (state.global_status == .complete) return .success;
    if (state.runtime_session.status == .blocked or state.runtime_session.status == .interrupted) return .danger;
    return .info;
}

fn emitLog(hooks: RuntimeHooks, tone: ChatTone, actor: []const u8, title: []const u8, text: []const u8, highlight: HighlightKind) void {
    hooks.emit(.{
        .kind = .log,
        .tone = tone,
        .actor = actor,
        .title = title,
        .text = text,
        .highlight = highlight,
    });
}

fn emitStreamStart(hooks: RuntimeHooks, actor: []const u8) void {
    hooks.emit(.{
        .kind = .stream_start,
        .actor = actor,
    });
}

fn emitStreamChunk(hooks: RuntimeHooks, actor: []const u8, text: []const u8) void {
    hooks.emit(.{
        .kind = .stream_chunk,
        .actor = actor,
        .text = text,
    });
}

fn emitStreamFinalize(hooks: RuntimeHooks, actor: []const u8, text: []const u8, highlight: HighlightKind) void {
    hooks.emit(.{
        .kind = .stream_finalize,
        .actor = actor,
        .text = text,
        .highlight = highlight,
    });
}

fn emitStateSnapshot(hooks: RuntimeHooks, config: AppConfig, state: AppState) void {
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

fn markInterrupted(state: *AppState) void {
    stateManager(state).markInterrupted();
}

fn friendlyRuntimeError(allocator: std.mem.Allocator, err: anyerror) ![]const u8 {
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

fn runtimeErrorCode(err: anyerror) []const u8 {
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

fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !void {
    ensureLoopBudget(state);
    while (state.agent_loop.iteration < state.agent_loop.max_iterations) {
        if (hooks.isInterrupted()) {
            markInterrupted(state);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = state.current_actor,
                .lane = laneForActor(state.current_actor),
                .action = "run_interrupted",
                .status = "blocked",
                .summary = "operator interrupted the active loop",
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            emitStateSnapshot(hooks, config, state.*);
            return;
        }

        const outcome = try executeStep(allocator, config, state, hooks);
        try saveState(allocator, config.paths.state_file, state.*);
        emitStateSnapshot(hooks, config, state.*);
        switch (outcome) {
            .advanced => {},
            .complete => return,
            .blocked => return,
        }
    }

    const loop_limit_message = try progressDocumentationText(
        allocator,
        state,
        "maximum iteration count reached before the mission completed.",
        config.context.max_stop_summary_chars,
    );
    const loop_limit_failure = buildRuntimeFailure(
        state,
        state.current_actor,
        laneForActor(state.current_actor),
        "LOOP_LIMIT_REACHED",
        loop_limit_message,
        .{},
    );
    recordRuntimeFailure(state, loop_limit_failure);
    stateManager(state).markBlocked(state.current_actor, laneForActor(state.current_actor), state.runtime_session.last_error);
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "loop_limit_reached",
        .actor = actorName(state.current_actor),
        .lane = currentLaneForState(state.*),
        .summary = state.runtime_session.last_error,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = state.current_actor,
        .lane = laneForActor(state.current_actor),
        .action = "loop_limit_reached",
        .status = "blocked",
        .summary = state.runtime_session.last_error,
        .error_text = state.runtime_session.last_error,
        .failure = loop_limit_failure,
        .include_snapshot = true,
    });
    try saveState(allocator, config.paths.state_file, state.*);
    emitLog(hooks, .danger, "runtime", "Loop Limit Reached", state.runtime_session.last_error, .plain);
    emitStateSnapshot(hooks, config, state.*);
}

fn executeStep(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    if (state.mission.initial_prompt.len == 0) {
        try stderrPrint("mission prompt is empty; use `contubernium mission start`\n", .{});
        return error.MissionNotInitialized;
    }

    if (hooks.isInterrupted()) {
        markInterrupted(state);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = state.current_actor,
            .lane = laneForActor(state.current_actor),
            .action = "run_interrupted",
            .status = "blocked",
            .summary = "operator interrupted the active loop",
            .error_text = state.runtime_session.last_error,
            .failure = state.runtime_session.last_failure,
            .include_snapshot = true,
        });
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    try stateManager(state).beginTurn(allocator, config);
    emitStateSnapshot(hooks, config, state.*);

    if (state.current_actor != .decanus) {
        return try executeSpecialistTurn(allocator, config, state, hooks);
    }
    return try executeDecanusTurn(allocator, config, state, hooks);
}

fn executeDecanusTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    stateManager(state).beginCommanderThinking();
    emitStateSnapshot(hooks, config, state.*);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "turn_started",
        .status = "running",
        .summary = if (state.mission.current_goal.len > 0) state.mission.current_goal else state.mission.initial_prompt,
        .include_snapshot = true,
    });

    const asset_layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, asset_layout);
    const system_prompt = try assembleSystemPrompt(allocator, asset_layout, state, .decanus);
    const prompt_build = buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .decanus, "") catch |err| {
        if (err == error.ContextBudgetExceeded or err == error.MemoryLoadBlocked) return .blocked;
        return err;
    };
    defer prompt_build.memory.deinit(allocator);
    const user_prompt = prompt_build.user_prompt;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "memory_layers_loaded",
        .status = "success",
        .summary = try summarizeRuntimeMemorySnapshot(allocator, prompt_build.memory),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "system_prompt",
        .status = "captured",
        .summary = "assembled decanus system prompt",
        .output = system_prompt,
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "user_prompt",
        .status = "captured",
        .summary = "assembled decanus user prompt",
        .output = user_prompt,
    });

    const response = structuredChatWithRepair(
        allocator,
        config,
        system_prompt,
        user_prompt,
        "decanus",
        config.provider.max_retries,
        DecanusDecision,
        state,
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            markInterrupted(state);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_interrupted",
                .status = "blocked",
                .summary = "decanus turn interrupted",
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "decanus turn failed: {s}", .{@errorName(err)});
        const failure = buildRuntimeFailure(state, .decanus, .command, "DECANUS_TURN_FAILED", message, .{
            .detail = @errorName(err),
        });
        recordRuntimeFailure(state, failure);
        stateManager(state).markBlocked(.decanus, .command, message);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_failed",
            .status = "error",
            .summary = "decanus turn failed",
            .error_text = message,
            .failure = failure,
            .include_snapshot = true,
        });
        emitLog(hooks, .danger, "decanus", "Commander Failed", message, .plain);
        return .blocked;
    };
    const decision = response.value;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "model_output",
        .status = "success",
        .summary = "raw decanus response",
        .output = response.raw_text,
    });
    const decision_summary = summarizeDecanusDecisionForUi(allocator, decision) catch prettyPrintJson(allocator, response.raw_text) catch response.raw_text;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "parsed_output",
        .status = "success",
        .summary = decision_summary,
        .output = prettyPrintJson(allocator, response.raw_text) catch response.raw_text,
    });
    emitStreamFinalize(hooks, "decanus", decision_summary, .summary);

    stateManager(state).setCurrentGoal(decision.current_goal);
    stateManager(state).setLastDecision(decision.action);
    emitStateSnapshot(hooks, config, state.*);

    if (decision.tool_requests.len > 0 or eql(decision.action, "tool_request")) {
        emitLog(
            hooks,
            .tool,
            "decanus",
            "Runtime Tool",
            summarizeToolRequestsForUi(allocator, decision.tool_requests) catch "decanus requested runtime tools",
            .plain,
        );
        const tool_result = try executeToolRequests(allocator, config, state, .decanus, .command, decision.tool_requests, hooks);
        try stateManager(state).recordRuntimeToolResultStep(allocator, .decanus, .command, tool_result.summary);
        if (tool_result.blocked) {
            stateManager(state).markBlocked(.decanus, .command, tool_result.summary);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = tool_result.summary,
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        try logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_advanced",
            .status = "success",
            .summary = tool_result.summary,
            .include_snapshot = true,
        });
        emitLog(
            hooks,
            .tool,
            "decanus",
            "Tool Result",
            compactTextForUi(allocator, tool_result.summary, 12, 900) catch tool_result.summary,
            .plain,
        );
        return .advanced;
    }

    if (eql(decision.action, "finish")) {
        try stateManager(state).completeMissionWithHistory(allocator, .decanus, .command, decision.final_response);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "run_completed",
            .status = "complete",
            .summary = decision.final_response,
            .output = decision.final_response,
            .include_snapshot = true,
        });
        emitLog(hooks, .success, "decanus", "Final Response", decision.final_response, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .complete;
    }

    if (eql(decision.action, "invoke_specialist")) {
        const invocation_resolution = resolveSpecialistInvocationFromDecision(allocator, asset_layout, decision) catch |err| {
            const message = try specialistInvocationResolutionMessage(allocator, decision, err);
            const failure = buildRuntimeFailure(state, .decanus, .command, "SPECIALIST_RESOLUTION_FAILED", message, .{
                .target = if (decision.agent_call.len > 0) decision.agent_call else if (decision.actor.len > 0) decision.actor else decision.lane,
                .detail = @errorName(err),
            });
            recordRuntimeFailure(state, failure);
            stateManager(state).markBlocked(.decanus, .command, message);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = message,
                .error_text = message,
                .failure = failure,
                .include_snapshot = true,
            });
            emitLog(hooks, .danger, "decanus", "Resolver Blocked", message, .plain);
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        };
        try stateManager(state).prepareInvocationWithHistory(
            allocator,
            invocation_resolution.lane,
            invocation_resolution.actor,
            if (decision.objective.len > 0) decision.objective else "complete the assigned scope",
            if (decision.completion_signal.len > 0) decision.completion_signal else "return a structured result to decanus",
            decision.dependencies,
            invocation_resolution.agent_call,
            invocation_resolution.action_name,
        );
        try logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "specialist_invoked",
            .status = "success",
            .tool = actorName(invocation_resolution.actor),
            .summary = invocation_resolution.agent_call,
            .input = decision.objective,
            .include_snapshot = true,
        });
        emitLog(
            hooks,
            .tool,
            "decanus",
            "Specialist Invoked",
            invocation_resolution.agent_call,
            .plain,
        );
        emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (eql(decision.action, "ask_user")) {
        const failure = buildRuntimeFailure(state, .decanus, .command, "USER_INPUT_REQUIRED", decision.question, .{
            .detail = "decanus requested user input",
        });
        recordRuntimeFailure(state, failure);
        stateManager(state).markBlocked(.decanus, .command, decision.question);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_blocked",
            .status = "blocked",
            .summary = decision.question,
            .error_text = decision.question,
            .failure = failure,
            .include_snapshot = true,
        });
        emitLog(hooks, .warning, "decanus", "Question", decision.question, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    const blocked_message = if (decision.blocked_reason.len > 0) decision.blocked_reason else "decanus returned a blocked state";
    const blocked_failure = buildRuntimeFailure(state, .decanus, .command, "DECANUS_BLOCKED", blocked_message, .{
        .detail = "decanus returned a blocked state",
    });
    recordRuntimeFailure(state, blocked_failure);
    stateManager(state).markBlocked(.decanus, .command, state.runtime_session.last_error);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "turn_blocked",
        .status = "blocked",
        .summary = state.runtime_session.last_error,
        .error_text = state.runtime_session.last_error,
        .failure = blocked_failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, "decanus", "Blocked", state.runtime_session.last_error, .plain);
    emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}

fn executeSpecialistTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    const actor = state.current_actor;
    const lane = laneForActor(actor);
    var task = taskForLane(state, lane);
    stateManager(state).beginSpecialistExecution(actor, lane, task.invocation.objective);
    emitStateSnapshot(hooks, config, state.*);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "turn_started",
        .status = "running",
        .summary = task.invocation.objective,
        .include_snapshot = true,
    });

    const asset_layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, asset_layout);
    const system_prompt = try assembleSystemPrompt(allocator, asset_layout, state, actor);
    const prompt_build = buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .specialist, laneName(lane)) catch |err| {
        if (err == error.ContextBudgetExceeded or err == error.MemoryLoadBlocked) return .blocked;
        return err;
    };
    defer prompt_build.memory.deinit(allocator);
    const user_prompt = prompt_build.user_prompt;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "memory_layers_loaded",
        .status = "success",
        .summary = try summarizeRuntimeMemorySnapshot(allocator, prompt_build.memory),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "system_prompt",
        .status = "captured",
        .summary = "assembled specialist system prompt",
        .output = system_prompt,
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "user_prompt",
        .status = "captured",
        .summary = "assembled specialist user prompt",
        .output = user_prompt,
    });

    const response = structuredChatWithRepair(
        allocator,
        config,
        system_prompt,
        user_prompt,
        actorName(actor),
        config.provider.max_retries,
        SpecialistResult,
        state,
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            markInterrupted(state);
            task.invocation.status = .blocked;
            try logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "turn_interrupted",
                .status = "blocked",
                .summary = "specialist turn interrupted",
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "{s} turn failed: {s}", .{ actorName(actor), @errorName(err) });
        const failure = buildRuntimeFailure(state, actor, lane, "SPECIALIST_TURN_FAILED", message, .{
            .detail = @errorName(err),
        });
        task.invocation.status = .blocked;
        recordRuntimeFailure(state, failure);
        stateManager(state).markBlocked(actor, lane, message);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_failed",
            .status = "error",
            .summary = "specialist turn failed",
            .error_text = message,
            .failure = failure,
            .include_snapshot = true,
        });
        emitLog(hooks, .danger, actorName(actor), "Specialist Failed", message, .plain);
        return .blocked;
    };
    const result = response.value;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "model_output",
        .status = "success",
        .summary = "raw specialist response",
        .output = response.raw_text,
    });
    const result_summary = summarizeSpecialistResultForUi(allocator, result) catch prettyPrintJson(allocator, response.raw_text) catch response.raw_text;
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "parsed_output",
        .status = "success",
        .summary = result_summary,
        .output = prettyPrintJson(allocator, response.raw_text) catch response.raw_text,
    });
    emitStreamFinalize(hooks, actorName(actor), result_summary, .summary);

    if (result.tool_requests.len > 0 or eql(result.action, "tool_request")) {
        emitLog(
            hooks,
            .tool,
            actorName(actor),
            "Runtime Tool",
            summarizeToolRequestsForUi(allocator, result.tool_requests) catch "specialist requested runtime tools",
            .plain,
        );
        const tool_result = try executeToolRequests(allocator, config, state, actor, lane, result.tool_requests, hooks);
        try stateManager(state).recordRuntimeToolResultStep(allocator, actor, lane, tool_result.summary);
        if (tool_result.blocked) {
            task.invocation.status = .blocked;
            stateManager(state).markBlocked(actor, lane, tool_result.summary);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = tool_result.summary,
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        task.invocation.status = .running;
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_advanced",
            .status = "success",
            .summary = tool_result.summary,
            .include_snapshot = true,
        });
        emitLog(
            hooks,
            .tool,
            actorName(actor),
            "Tool Result",
            compactTextForUi(allocator, tool_result.summary, 12, 900) catch tool_result.summary,
            .plain,
        );
        return .advanced;
    }

    if (eql(result.action, "complete") or eql(result.status, "complete") or eql(result.status, "partial")) {
        const invocation_result = try materializeInvocationResult(
            allocator,
            result,
            if (eql(result.status, "partial")) .partial else .complete,
        );
        try stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_completed",
            .status = "complete",
            .summary = invocation_result.summary,
            .output = invocation_result.summary,
            .include_snapshot = true,
        });
        emitLog(hooks, .success, actorName(actor), "Lane Complete", invocation_result.summary, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (eql(result.action, "ask_user")) {
        const invocation_result = try materializeInvocationResult(allocator, result, .blocked);
        const failure = buildRuntimeFailure(state, actor, lane, "USER_INPUT_REQUIRED", result.question, .{
            .detail = "specialist requested user input",
        });
        try stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
        recordRuntimeFailure(state, failure);
        stateManager(state).markBlocked(actor, lane, result.question);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_blocked",
            .status = "blocked",
            .summary = result.question,
            .error_text = result.question,
            .failure = failure,
            .include_snapshot = true,
        });
        emitLog(hooks, .warning, actorName(actor), "Question", result.question, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    const invocation_result = try materializeInvocationResult(allocator, result, .blocked);
    const blocked_message = if (invocation_result.blockers.len > 0) invocation_result.blockers[0] else "specialist returned a blocked state";
    const blocked_failure = buildRuntimeFailure(state, actor, lane, "SPECIALIST_BLOCKED", blocked_message, .{
        .detail = "specialist returned a blocked state",
    });
    try stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
    recordRuntimeFailure(state, blocked_failure);
    stateManager(state).markBlocked(actor, lane, state.runtime_session.last_error);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "turn_blocked",
        .status = "blocked",
        .summary = state.runtime_session.last_error,
        .error_text = state.runtime_session.last_error,
        .failure = blocked_failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, actorName(actor), "Blocked", state.runtime_session.last_error, .plain);
    emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}

fn executeToolRequests(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    requests: []const ToolRequest,
    hooks: RuntimeHooks,
) !ToolExecutionOutcome {
    if (requests.len == 0) {
        return .{ .blocked = false, .summary = "no tool requests" };
    }

    var summaries: std.ArrayList([]const u8) = .empty;
    defer {
        for (summaries.items) |summary| allocator.free(summary);
        summaries.deinit(allocator);
    }

    for (requests) |request| {
        const tool_name = canonicalToolName(request.tool);
        if (tool_name.len == 0) continue;

        const request_summary_owned = toolRequestDisplay(allocator, request) catch null;
        const request_summary = request_summary_owned orelse tool_name;
        defer if (request_summary_owned) |owned| allocator.free(owned);

        emitLog(hooks, .tool, actorName(actor), tool_name, request_summary, .plain);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "tool_request",
            .status = "requested",
            .tool = tool_name,
            .summary = request_summary,
            .input = request_summary,
        });

        const validated = switch (validateToolRequest(config, state, actor, lane, request)) {
            .ok => |value| value,
            .blocked => |failure| {
                const blocked_summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{failure.message});
                try summaries.append(allocator, blocked_summary);
                try logRuntimeEvent(allocator, config, state, .{
                    .actor = actor,
                    .lane = lane,
                    .action = "tool_result",
                    .status = "blocked",
                    .tool = if (tool_name.len > 0) tool_name else request.tool,
                    .summary = failure.message,
                    .error_text = failure.message,
                    .failure = failure,
                    .include_snapshot = true,
                });
                recordRuntimeFailure(state, failure);
                stateManager(state).markBlocked(actor, lane, failure.message);
                return .{
                    .blocked = true,
                    .summary = try joinStrings(allocator, summaries.items, "\n"),
                };
            },
        };

        const execution = executeValidatedToolRequest(allocator, config, state, actor, lane, validated, hooks) catch |err| {
            const failure = try buildToolExecutionFailure(allocator, config, state, actor, lane, validated, err);
            const blocked_summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{failure.message});
            try summaries.append(allocator, blocked_summary);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "tool_result",
                .status = if (err == error.ToolTimedOut) "blocked" else "error",
                .tool = validated.spec.name,
                .summary = failure.message,
                .error_text = failure.message,
                .failure = failure,
                .include_snapshot = true,
            });
            recordRuntimeFailure(state, failure);
            stateManager(state).markBlocked(actor, lane, failure.message);
            return .{
                .blocked = true,
                .summary = try joinStrings(allocator, summaries.items, "\n"),
            };
        };

        try summaries.append(allocator, execution.summary);

        if (execution.blocked) {
            const failure = execution.failure.?;
            try logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "tool_result",
                .status = "blocked",
                .tool = validated.spec.name,
                .summary = execution.summary,
                .error_text = failure.message,
                .failure = failure,
                .include_snapshot = true,
            });
            recordRuntimeFailure(state, failure);
            stateManager(state).markBlocked(actor, lane, failure.message);
            return .{
                .blocked = true,
                .summary = try joinStrings(allocator, summaries.items, "\n"),
            };
        }

        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "tool_result",
            .status = "success",
            .tool = validated.spec.name,
            .summary = execution.summary,
            .output = execution.summary,
        });
    }

    return .{
        .blocked = false,
        .summary = try joinStrings(allocator, summaries.items, "\n"),
    };
}

fn structuredChatWithRepair(
    allocator: std.mem.Allocator,
    config: AppConfig,
    system_prompt: []const u8,
    user_prompt: []const u8,
    actor: []const u8,
    max_retries: usize,
    comptime T: type,
    state: *AppState,
    hooks: RuntimeHooks,
) !struct { value: T, raw_text: []const u8 } {
    var attempt: usize = 0;
    var repair_user_prompt = user_prompt;
    const resolved_actor = parseActor(actor) orelse .decanus;
    const resolved_lane = laneForActor(resolved_actor);

    while (true) {
        if (hooks.isInterrupted()) return error.Interrupted;
        emitStreamStart(hooks, actor);
        const response = try providerStructuredChat(allocator, config.provider, system_prompt, repair_user_prompt, actor, hooks);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = resolved_actor,
            .lane = resolved_lane,
            .action = "provider_transport",
            .status = "success",
            .summary = "provider transport captured",
            .output = response.transport_text,
        });
        const parsed = parseModelJson(T, allocator, response.raw_text) catch |err| {
            const failure = buildRuntimeFailure(
                state,
                resolved_actor,
                resolved_lane,
                "MODEL_OUTPUT_INVALID",
                if (response.raw_text.len == 0) "model returned an empty response" else "model returned invalid JSON",
                .{
                    .detail = @errorName(err),
                },
            );
            recordRuntimeFailure(state, failure);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = resolved_actor,
                .lane = resolved_lane,
                .action = "invalid_model_output",
                .status = "error",
                .summary = "model returned invalid JSON",
                .output = response.raw_text,
                .error_text = failure.message,
                .failure = failure,
            });
            emitStreamFinalize(hooks, actor, response.raw_text, .json);
            if (attempt >= max_retries) return err;
            attempt += 1;
            stateManager(state).setRepairAttempts(attempt);
            emitLog(hooks, .warning, actor, "Repair Retry", state.runtime_session.last_error, .plain);
            repair_user_prompt = try std.fmt.allocPrint(
                allocator,
                "{s}\n\nYour previous response was invalid JSON. Return valid JSON only. Do not use markdown fences. Preserve the intended structure.",
                .{user_prompt},
            );
            try logRuntimeEvent(allocator, config, state, .{
                .actor = resolved_actor,
                .lane = resolved_lane,
                .action = "repair_retry",
                .status = "retrying",
                .summary = state.runtime_session.last_error,
                .input = repair_user_prompt,
                .error_text = state.runtime_session.last_error,
                .failure = failure,
            });
            continue;
        };
        stateManager(state).setRepairAttempts(attempt);
        return .{ .value = parsed, .raw_text = response.raw_text };
    }
}

fn runtimeMemoryStatusLabel(layer: RuntimeMemoryLayer) []const u8 {
    if (layer.content.len == 0) return "empty";
    if (layer.truncated) return "loaded_truncated";
    return "loaded";
}

fn runtimeMemoryPromptText(layer: RuntimeMemoryLayer) []const u8 {
    if (layer.content.len == 0) return "none captured";
    return layer.content;
}

fn summarizeRuntimeMemorySnapshot(allocator: std.mem.Allocator, memory: RuntimeMemorySnapshot) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "architecture={s} status={s} source_chars={d} prompt_chars={d}\nplan={s} status={s} source_chars={d} prompt_chars={d}\nproject_context={s} status={s} source_chars={d} prompt_chars={d}\nproject_memory={s} status={s} source_chars={d} prompt_chars={d}\nglobal_memory={s} status={s} source_chars={d} prompt_chars={d}",
        .{
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            memory.architecture.content.len,
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            memory.plan.content.len,
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            memory.project_context.content.len,
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            memory.project.content.len,
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            memory.global.content.len,
        },
    );
}

fn specialistRoutingGuideText(allocator: std.mem.Allocator) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);
    const specialists = [_]Actor{
        .faber,
        .artifex,
        .architectus,
        .tesserarius,
        .explorator,
        .signifer,
        .praeco,
        .calo,
        .mulus,
    };

    for (specialists) |actor| {
        try writer.print(
            "- {s} -> lane={s} -> prefer `agent_call: \"{s}\"` -> exact default action `{s}::{s}`\n",
            .{
                actorName(actor),
                laneName(laneForActor(actor)),
                actorName(actor),
                actorName(actor),
                defaultActionNameForActor(actor),
            },
        );
    }

    return try buffer.toOwnedSlice(allocator);
}

fn buildDecanusUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
) ![]const u8 {
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    const task_summary = try taskSummaryText(allocator, state.tasks);
    const constraints = try joinStrings(allocator, state.mission.constraints, ", ");
    const success_criteria = try joinStrings(allocator, state.mission.success_criteria, ", ");
    const specialist_routing = try specialistRoutingGuideText(allocator);
    defer allocator.free(specialist_routing);
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

    try writer.print(
        \\Project Context
        \\---------------
        \\Architecture file: {s}
        \\Architecture status: {s}
        \\Architecture source chars: {d}
        \\Architecture:
        \\{s}
        \\
        \\Plan file: {s}
        \\Plan status: {s}
        \\Plan source chars: {d}
        \\Plan:
        \\{s}
        \\
        \\Project context file: {s}
        \\Project context status: {s}
        \\Project context source chars: {d}
        \\Project context:
        \\{s}
        \\
        \\Project memory file: {s}
        \\Project memory status: {s}
        \\Project memory source chars: {d}
        \\Project memory:
        \\{s}
        \\
        \\Global memory file: {s}
        \\Global memory status: {s}
        \\Global memory source chars: {d}
        \\Global memory:
        \\{s}
        \\
    ,
        .{
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            runtimeMemoryPromptText(memory.architecture),
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            runtimeMemoryPromptText(memory.plan),
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            runtimeMemoryPromptText(memory.project_context),
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            runtimeMemoryPromptText(memory.project),
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            runtimeMemoryPromptText(memory.global),
        },
    );
    try writer.print(
        \\Live State
        \\----------
        \\Initial prompt:
        \\{s}
        \\
        \\Current goal:
        \\{s}
        \\
        \\Constraints:
        \\{s}
        \\
        \\Success criteria:
        \\{s}
        \\
        \\Specialist routing
        \\-----------------
        \\{s}
        \\Valid lane values: backend, frontend, systems, qa, research, brand, media, docs, bulk_ops
        \\When `action` is `invoke_specialist`, prefer a bare agent name in `agent_call`. Use an exact `agent::ACTION` only when it matches a real Contubernium action file.
        \\
        \\Iteration: {d}
        \\Status: {s}
        \\Active tool: {s}
        \\Last decision: {s}
        \\Last tool result: {s}
        \\
        \\Tasks
        \\-----
        \\{s}
        \\
        \\Recent history
        \\--------------
        \\{s}
        \\
        \\Return a valid DecanusDecision JSON object.
        \\
    ,
        .{
            state.mission.initial_prompt,
            state.mission.current_goal,
            constraints,
            success_criteria,
            specialist_routing,
            state.agent_loop.iteration,
            @tagName(state.agent_loop.status),
            maybeActorName(state.agent_loop.active_tool),
            state.agent_loop.last_decision,
            state.agent_loop.last_tool_result,
            task_summary,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

fn buildSpecialistUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
    lane: []const u8,
) ![]const u8 {
    const lane_value = std.meta.stringToEnum(Lane, lane) orelse .bulk_ops;
    const task = taskForLaneConst(state, lane_value);
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    const context_files = try joinStrings(allocator, task.invocation.context.files, ", ");
    const context_constraints = try joinStrings(allocator, task.invocation.context.constraints, ", ");
    const context_dependencies = try joinStrings(allocator, task.invocation.context.dependencies, ", ");
    const allowed_actions = try joinStrings(allocator, task.invocation.scope.allowed_actions, ", ");
    const restricted_actions = try joinStrings(allocator, task.invocation.scope.restricted_actions, ", ");
    const relevant_memory = try joinStrings(allocator, task.invocation.memory.relevant, ", ");
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

    try writer.print(
        \\Project Context
        \\---------------
        \\Architecture file: {s}
        \\Architecture status: {s}
        \\Architecture source chars: {d}
        \\Architecture:
        \\{s}
        \\
        \\Plan file: {s}
        \\Plan status: {s}
        \\Plan source chars: {d}
        \\Plan:
        \\{s}
        \\
        \\Project context file: {s}
        \\Project context status: {s}
        \\Project context source chars: {d}
        \\Project context:
        \\{s}
        \\
        \\Project memory file: {s}
        \\Project memory status: {s}
        \\Project memory source chars: {d}
        \\Project memory:
        \\{s}
        \\
        \\Global memory file: {s}
        \\Global memory status: {s}
        \\Global memory source chars: {d}
        \\Global memory:
        \\{s}
        \\
    ,
        .{
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            runtimeMemoryPromptText(memory.architecture),
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            runtimeMemoryPromptText(memory.plan),
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            runtimeMemoryPromptText(memory.project_context),
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            runtimeMemoryPromptText(memory.project),
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            runtimeMemoryPromptText(memory.global),
        },
    );
    try writer.print(
        \\Live State
        \\----------
        \\Initial prompt:
        \\{s}
        \\
        \\Current goal:
        \\{s}
        \\
        \\Active lane:
        \\{s}
        \\
        \\Invocation
        \\----------
        \\Status: {s}
        \\Agent call: {s}
        \\Selected action: {s}
        \\Objective: {s}
        \\Completion signal: {s}
        \\Context.project: {s}
        \\Context.files: {s}
        \\Context.constraints: {s}
        \\Context.dependencies: {s}
        \\Scope.allowed_actions: {s}
        \\Scope.restricted_actions: {s}
        \\Memory.mission: {s}
        \\Memory.project: {s}
        \\Memory.relevant: {s}
        \\
        \\Last tool result:
        \\{s}
        \\
        \\Recent history
        \\--------------
        \\{s}
        \\
        \\Return a valid SpecialistResult JSON object.
        \\
    ,
        .{
            state.mission.initial_prompt,
            state.mission.current_goal,
            lane,
            @tagName(task.invocation.status),
            task.invocation.agent_call,
            task.invocation.action_name,
            task.invocation.objective,
            task.invocation.completion_signal,
            task.invocation.context.project,
            context_files,
            context_constraints,
            context_dependencies,
            allowed_actions,
            restricted_actions,
            task.invocation.memory.mission,
            task.invocation.memory.project,
            relevant_memory,
            state.agent_loop.last_tool_result,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

fn assembleSystemPrompt(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    state: *const AppState,
    actor: Actor,
) ![]const u8 {
    const base = try readSharedAsset(allocator, layout, "patterns/RUNTIME_BASE.md");
    defer allocator.free(base);
    const policy = try readSharedAsset(allocator, layout, "patterns/TOOL_POLICY.md");
    defer allocator.free(policy);
    const soul = try readAgentAsset(allocator, layout, actor, "SOUL.md");
    defer allocator.free(soul);
    const contract = try readAgentAsset(allocator, layout, actor, "CONTRACT.md");
    defer allocator.free(contract);
    const skill = try readAgentAsset(allocator, layout, actor, "SKILL.md");
    defer allocator.free(skill);
    const schema = try readSharedAsset(
        allocator,
        layout,
        if (actor == .decanus) "templates/DECANUS_DECISION_SCHEMA.json" else "templates/SPECIALIST_RESULT_SCHEMA.json",
    );
    defer allocator.free(schema);

    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);
    try writer.print("{s}\n\n{s}\n\n{s}\n\n{s}\n\n{s}\n", .{ base, policy, soul, contract, skill });
    try appendSelectedActionSections(allocator, writer, layout, state, actor);
    try writer.print("\nResponse schema reference:\n{s}\n", .{schema});
    return try buffer.toOwnedSlice(allocator);
}

fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !AppConfig {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    return try parseJson(AppConfig, allocator, data);
}

fn loadProjectConfig(allocator: std.mem.Allocator) !AppConfig {
    try scaffoldProject(allocator);
    const config_path = try resolveConfigPath(allocator);
    return try loadConfig(allocator, config_path);
}

fn loadState(allocator: std.mem.Allocator, path: []const u8) !AppState {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);

    return parseJson(AppState, allocator, data) catch |err| switch (err) {
        error.InvalidEnumTag => {
            const normalized = try normalizeLegacyStateJson(allocator, data);
            return try parseJson(AppState, allocator, normalized);
        },
        else => return err,
    };
}

fn normalizeLegacyStateJson(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const without_empty_active_tool = try std.mem.replaceOwned(u8, allocator, data, "\"active_tool\": \"\"", "\"active_tool\": null");
    errdefer allocator.free(without_empty_active_tool);

    const normalized = try std.mem.replaceOwned(u8, allocator, without_empty_active_tool, "\"next_recommended_agent\": \"\"", "\"next_recommended_agent\": null");
    allocator.free(without_empty_active_tool);
    return normalized;
}

fn saveState(allocator: std.mem.Allocator, path: []const u8, state: AppState) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(state, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

fn saveConfig(allocator: std.mem.Allocator, path: []const u8, config: AppConfig) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(config, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

fn loadRuntimeRunLog(allocator: std.mem.Allocator, path: []const u8) !RuntimeRunLog {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    return try parseJson(RuntimeRunLog, allocator, data);
}

fn saveRuntimeRunLog(allocator: std.mem.Allocator, path: []const u8, log: RuntimeRunLog) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(log, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

fn runDoctorCheck(allocator: std.mem.Allocator) ![]const u8 {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    const asset_layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, asset_layout);

    try ensureGlobalAssetFiles(allocator, asset_layout);
    try ensureMemoryFiles(config.paths);

    const models = try providerListModels(allocator, config.provider);
    if (!containsString(models, config.provider.model)) return error.ModelNotFound;

    const smoke_response = try providerStructuredChat(
        allocator,
        config.provider,
        "Return valid JSON only.",
        "Return exactly this JSON object and nothing else: {\"status\":\"ok\"}",
        "doctor",
        .{},
    );
    const parsed = try parseModelJson(SmokeResponse, allocator, smoke_response.raw_text);
    if (!eql(parsed.status, "ok")) return error.StructuredOutputFailed;

    const now = try unixTimestampString(allocator);
    stateManager(&state).noteHealthCheck(now, config);
    try saveState(allocator, config.paths.state_file, state);

    return try std.fmt.allocPrint(
        allocator,
        "global agent assets: ok\nproject context files: ok\nbackend reachable: ok ({s})\nconfigured model: ok ({s})\nstructured output smoke test: ok",
        .{ config.provider.type, config.provider.model },
    );
}

fn missionOutcomeSummary(allocator: std.mem.Allocator, state: AppState) ![]const u8 {
    if (state.mission.final_response.len > 0 and state.global_status == .complete) {
        return try std.fmt.allocPrint(allocator, "complete\n\n{s}", .{state.mission.final_response});
    }
    if (state.runtime_session.last_error.len > 0 and state.runtime_session.status == .blocked) {
        return try std.fmt.allocPrint(allocator, "blocked\n\n{s}", .{state.runtime_session.last_error});
    }
    if (state.agent_loop.active_tool) |active_tool| {
        return try std.fmt.allocPrint(
            allocator,
            "in progress\n\ncurrent actor: {s}\nactive tool: {s}\niteration: {d}",
            .{ actorName(state.current_actor), actorName(active_tool), state.agent_loop.iteration },
        );
    }
    return try std.fmt.allocPrint(
        allocator,
        "status: {s}\ncurrent actor: {s}\niteration: {d}",
        .{ @tagName(state.global_status), actorName(state.current_actor), state.agent_loop.iteration },
    );
}

fn ensureGlobalAssetFiles(allocator: std.mem.Allocator, layout: GlobalAssetLayout) !void {
    const required_agent_docs = [_][]const u8{
        "AGENT_LOOP.md",
        "AGENT_ARCHITECTURE.md",
        "AGENT_COMPATIBILITY.md",
        "_schemas/SOUL_SCHEMA.md",
        "_schemas/CONTRACT_SCHEMA.md",
        "_schemas/SKILL_SCHEMA.md",
        "_schemas/ACTION_SCHEMA.md",
    };

    for (required_agent_docs) |relative| {
        const full_path = try std.fs.path.join(allocator, &.{ layout.agents_root, relative });
        defer allocator.free(full_path);
        std.fs.cwd().access(full_path, .{}) catch {
            stderrPrint("missing global agent asset: {s}\n", .{full_path}) catch {};
            return error.MissingAgentAsset;
        };
    }

    const shared_required = [_][]const u8{
        "patterns/RUNTIME_BASE.md",
        "patterns/TOOL_POLICY.md",
        "templates/DECANUS_DECISION_SCHEMA.json",
        "templates/SPECIALIST_RESULT_SCHEMA.json",
    };
    for (shared_required) |relative| {
        const full_path = try std.fs.path.join(allocator, &.{ layout.shared_root, relative });
        defer allocator.free(full_path);
        std.fs.cwd().access(full_path, .{}) catch {
            stderrPrint("missing shared asset: {s}\n", .{full_path}) catch {};
            return error.MissingAgentAsset;
        };
    }

    const actors = [_]Actor{
        .decanus,
        .faber,
        .artifex,
        .architectus,
        .tesserarius,
        .explorator,
        .signifer,
        .praeco,
        .calo,
        .mulus,
    };
    const core_assets = [_][]const u8{
        "SOUL.md",
        "CONTRACT.md",
        "SKILL.md",
    };

    for (actors) |actor| {
        for (core_assets) |relative| {
            const full_path = resolveAgentAssetPath(allocator, layout, actor, relative) catch {
                stderrPrint("missing global agent asset: {s}/{s}\n", .{ actorName(actor), relative }) catch {};
                return error.MissingAgentAsset;
            };
            allocator.free(full_path);
        }

        const required_actions = requiredActionNamesForActor(actor);
        for (required_actions) |action_name| {
            const full_path = resolveAgentActionPath(allocator, layout, actor, action_name) catch {
                stderrPrint("missing global agent action: {s}/{s}.md\n", .{ actorName(actor), action_name }) catch {};
                return error.MissingAgentAsset;
            };
            allocator.free(full_path);
        }
    }
}

fn ensureMemoryFiles(paths: PathsConfig) !void {
    const required = [_][]const u8{
        paths.architecture_file,
        paths.plan_file,
        paths.project_context_file,
        paths.project_memory_file,
        paths.global_memory_file,
    };

    for (required) |path| {
        std.fs.cwd().access(path, .{}) catch {
            stderrPrint("missing memory asset: {s}\n", .{path}) catch {};
            return error.MissingMemoryAsset;
        };
    }
}

fn readSharedAsset(allocator: std.mem.Allocator, layout: GlobalAssetLayout, relative_path: []const u8) ![]const u8 {
    const full_path = try std.fs.path.join(allocator, &.{ layout.shared_root, relative_path });
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

fn resolveAgentAssetPath(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    relative_path: []const u8,
) ![]const u8 {
    const full_path = try std.fs.path.join(allocator, &.{ layout.agents_root, actorName(actor), relative_path });
    errdefer allocator.free(full_path);
    if (!pathExists(full_path)) return error.MissingAgentAsset;
    return full_path;
}

fn readAgentAsset(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    relative_path: []const u8,
) ![]const u8 {
    const full_path = try resolveAgentAssetPath(allocator, layout, actor, relative_path);
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

fn isCanonicalActionName(text: []const u8) bool {
    const trimmed = trimAscii(text);
    if (trimmed.len == 0) return false;
    if (trimmed[0] < 'A' or trimmed[0] > 'Z') return false;
    if (trimmed[trimmed.len - 1] == '_') return false;

    var previous_was_underscore = false;
    for (trimmed) |char| {
        if (char >= 'A' and char <= 'Z') {
            previous_was_underscore = false;
            continue;
        }
        if (char >= '0' and char <= '9') {
            previous_was_underscore = false;
            continue;
        }
        if (char == '_') {
            if (previous_was_underscore) return false;
            previous_was_underscore = true;
            continue;
        }
        return false;
    }

    return true;
}

fn resolveAgentActionPath(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    action_name: []const u8,
) ![]const u8 {
    const trimmed_action = trimAscii(action_name);
    if (!isCanonicalActionName(trimmed_action)) return error.InvalidActionName;

    const file_name = try std.fmt.allocPrint(allocator, "{s}.md", .{trimmed_action});
    defer allocator.free(file_name);
    const full_path = try std.fs.path.join(allocator, &.{ layout.agents_root, actorName(actor), "actions", file_name });
    errdefer allocator.free(full_path);
    if (!pathExists(full_path)) return error.MissingAgentAsset;
    return full_path;
}

fn readAgentActionAsset(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    action_name: []const u8,
) ![]const u8 {
    const full_path = try resolveAgentActionPath(allocator, layout, actor, action_name);
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

fn defaultActionNameForActor(actor: Actor) []const u8 {
    return switch (actor) {
        .decanus => "EVALUATE_LOOP",
        .faber => "IMPLEMENT_BACKEND",
        .artifex => "IMPLEMENT_INTERFACE",
        .architectus => "CONFIGURE_SYSTEM",
        .tesserarius => "VALIDATE_SCOPE",
        .explorator => "RESEARCH_SCOPE",
        .signifer => "DEFINE_VISUAL_SYSTEM",
        .praeco => "WRITE_MESSAGE",
        .calo => "UPDATE_DOCUMENTATION",
        .mulus => "APPLY_BULK_TRANSFORM",
    };
}

fn requiredActionNamesForActor(actor: Actor) []const []const u8 {
    return switch (actor) {
        .decanus => &.{
            "EVALUATE_LOOP",
            "INVOKE_SPECIALIST",
            "FINISH_MISSION",
        },
        else => &.{defaultActionNameForActor(actor)},
    };
}

fn parseAgentCall(agent_call: []const u8) ?AgentCallSpec {
    const trimmed = trimAscii(agent_call);
    if (trimmed.len == 0) return null;
    if (std.mem.indexOf(u8, trimmed, "::")) |separator| {
        const actor_value = parseActor(trimAscii(trimmed[0..separator])) orelse return null;
        const action_name = trimAscii(trimmed[separator + 2 ..]);
        if (action_name.len == 0) return null;
        return .{
            .actor = actor_value,
            .action_name = action_name,
            .explicit_action = true,
        };
    }
    return .{
        .actor = parseActor(trimmed) orelse return null,
        .action_name = "",
        .explicit_action = false,
    };
}

fn validateAgentCoreAssets(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
) !void {
    const core_assets = [_][]const u8{
        "SOUL.md",
        "CONTRACT.md",
        "SKILL.md",
    };

    for (core_assets) |relative_path| {
        const full_path = try resolveAgentAssetPath(allocator, layout, actor, relative_path);
        allocator.free(full_path);
    }
}

fn resolveAgentCallTarget(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    agent_call: []const u8,
) !ResolvedAgentCall {
    const parsed = parseAgentCall(agent_call) orelse return error.InvalidAgentCall;
    try validateAgentCoreAssets(allocator, layout, parsed.actor);
    const selected_action = if (parsed.explicit_action) parsed.action_name else defaultActionNameForActor(parsed.actor);
    const action_path = try resolveAgentActionPath(allocator, layout, parsed.actor, selected_action);
    allocator.free(action_path);

    return .{
        .actor = parsed.actor,
        .action_name = selected_action,
        .agent_call = if (parsed.explicit_action) trimAscii(agent_call) else actorName(parsed.actor),
    };
}

fn resolveSpecialistInvocationFromDecision(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    decision: DecanusDecision,
) !ResolvedSpecialistInvocation {
    const requested_actor = if (decision.actor.len > 0)
        parseActor(decision.actor) orelse return error.InvalidAgentCall
    else
        null;
    const requested_lane = if (decision.lane.len > 0)
        std.meta.stringToEnum(Lane, decision.lane) orelse return error.InvalidLane
    else
        null;

    if (requested_actor) |actor| {
        if (requested_lane) |lane| {
            if (lane != laneForActor(actor)) return error.AgentLaneConflict;
        }
    }

    if (decision.agent_call.len > 0) {
        const resolved = try resolveAgentCallTarget(allocator, layout, decision.agent_call);
        if (requested_actor) |actor| {
            if (actor != resolved.actor) return error.AgentCallConflict;
        }
        if (requested_lane) |lane| {
            if (lane != laneForActor(resolved.actor)) return error.AgentLaneConflict;
        }
        return .{
            .actor = resolved.actor,
            .lane = laneForActor(resolved.actor),
            .agent_call = resolved.agent_call,
            .action_name = resolved.action_name,
        };
    }

    const actor = if (requested_actor) |value|
        value
    else if (requested_lane) |lane|
        actorForLane(lane)
    else
        return error.MissingSpecialistTarget;

    const resolved = try resolveAgentCallTarget(allocator, layout, actorName(actor));
    return .{
        .actor = resolved.actor,
        .lane = laneForActor(resolved.actor),
        .agent_call = resolved.agent_call,
        .action_name = resolved.action_name,
    };
}

fn specialistInvocationResolutionMessage(
    allocator: std.mem.Allocator,
    decision: DecanusDecision,
    err: anyerror,
) ![]const u8 {
    const call_label = if (decision.agent_call.len > 0)
        decision.agent_call
    else if (decision.actor.len > 0)
        decision.actor
    else if (decision.lane.len > 0)
        decision.lane
    else
        "none";

    return switch (err) {
        error.MissingSpecialistTarget => try allocator.dupe(
            u8,
            "invoke_specialist requires a resolvable target in `agent` or `agent::ACTION` form.",
        ),
        error.InvalidAgentCall => try std.fmt.allocPrint(
            allocator,
            "invalid specialist target `{s}`; use `agent` or `agent::ACTION` with a known agent name.",
            .{call_label},
        ),
        error.InvalidLane => try std.fmt.allocPrint(
            allocator,
            "invalid specialist lane `{s}`; the lane must match a known Contubernium agent lane.",
            .{decision.lane},
        ),
        error.InvalidActionName => try std.fmt.allocPrint(
            allocator,
            "invalid action in `{s}`; action names must be uppercase snake case and map to a real action file.",
            .{call_label},
        ),
        error.AgentLaneConflict => try std.fmt.allocPrint(
            allocator,
            "specialist target conflict: `{s}` does not match the requested lane `{s}`.",
            .{ call_label, decision.lane },
        ),
        error.AgentCallConflict => try std.fmt.allocPrint(
            allocator,
            "specialist target conflict: `{s}` does not match the requested actor `{s}`.",
            .{ call_label, decision.actor },
        ),
        error.MissingAgentAsset => try std.fmt.allocPrint(
            allocator,
            "resolved agent assets for `{s}` are incomplete; required core files or action files are missing.",
            .{call_label},
        ),
        else => try std.fmt.allocPrint(
            allocator,
            "failed to resolve specialist target `{s}`: {s}",
            .{ call_label, @errorName(err) },
        ),
    };
}

fn appendActionSection(
    allocator: std.mem.Allocator,
    writer: anytype,
    layout: GlobalAssetLayout,
    actor: Actor,
    action_name: []const u8,
) !void {
    const action_text = try readAgentActionAsset(allocator, layout, actor, action_name);
    defer allocator.free(action_text);
    try writer.print("\nSelected action: {s}::{s}\n{s}\n", .{ actorName(actor), action_name, action_text });
}

fn appendSelectedActionSections(
    allocator: std.mem.Allocator,
    writer: anytype,
    layout: GlobalAssetLayout,
    state: *const AppState,
    actor: Actor,
) !void {
    try writer.writeAll("\nSelected actions:\n");
    if (actor == .decanus) {
        try appendActionSection(allocator, writer, layout, actor, "EVALUATE_LOOP");
        try appendActionSection(allocator, writer, layout, actor, "INVOKE_SPECIALIST");
        try appendActionSection(allocator, writer, layout, actor, "FINISH_MISSION");
        return;
    }

    const lane = laneForActor(actor);
    const task = taskForLaneConst(state, lane);
    const selected_action = if (task.invocation.action_name.len > 0) task.invocation.action_name else defaultActionNameForActor(actor);
    try appendActionSection(allocator, writer, layout, actor, selected_action);
}

fn providerListModels(allocator: std.mem.Allocator, provider: ProviderConfig) ![][]const u8 {
    if (eql(provider.type, "ollama-native")) {
        const url = try std.fmt.allocPrint(allocator, "{s}/api/tags", .{provider.base_url});
        const result = try runCommandCapture(allocator, &.{ "curl", "-fsS", "--max-time", try timeoutSeconds(allocator, provider.timeout_ms), url });
        if (result.exit_code != 0) return error.BackendUnavailable;
        const parsed = try parseJson(OllamaTagsResponse, allocator, result.stdout);
        if (parsed.@"error".len > 0) return error.BackendUnavailable;
        var models: std.ArrayList([]const u8) = .empty;
        for (parsed.models) |model| {
            try models.append(allocator, model.name);
        }
        return try models.toOwnedSlice(allocator);
    }

    if (eql(provider.type, "openai-compatible")) {
        const url = try std.fmt.allocPrint(allocator, "{s}/v1/models", .{provider.base_url});
        const result = try runCommandCapture(allocator, &.{ "curl", "-fsS", "--max-time", try timeoutSeconds(allocator, provider.timeout_ms), url });
        if (result.exit_code != 0) return error.BackendUnavailable;
        const parsed = try parseJson(OpenAIModelsResponse, allocator, result.stdout);
        if (parsed.@"error".message.len > 0) return error.BackendUnavailable;
        var models: std.ArrayList([]const u8) = .empty;
        for (parsed.data) |model| {
            try models.append(allocator, model.id);
        }
        return try models.toOwnedSlice(allocator);
    }

    return error.UnsupportedProvider;
}

fn providerStructuredChat(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    system_prompt: []const u8,
    user_prompt: []const u8,
    schema_kind: []const u8,
    hooks: RuntimeHooks,
) !ProviderResponse {
    const started = std.time.milliTimestamp();

    if (eql(provider.type, "ollama-native")) {
        const url = try std.fmt.allocPrint(allocator, "{s}/api/chat", .{provider.base_url});
        const stream = hooks.emit_fn != null;
        const body = try buildOllamaChatBody(allocator, provider, system_prompt, user_prompt, stream);

        if (stream) {
            return providerStructuredChatOllamaStreaming(allocator, provider, schema_kind, body, url, started, hooks) catch |err| {
                if (err != error.EmptyModelOutput) return err;
                emitLog(hooks, .warning, schema_kind, "Streaming Retry", "streaming returned no content; retrying once without streaming", .plain);
                const retry_body = try buildOllamaChatBody(allocator, provider, system_prompt, user_prompt, false);
                return try providerStructuredChatOllamaNonStreaming(allocator, provider, retry_body, url, started);
            };
        }

        return try providerStructuredChatOllamaNonStreaming(allocator, provider, body, url, started);
    }

    if (eql(provider.type, "openai-compatible")) {
        const messages = [_]MessagePayload{
            .{ .role = "system", .content = system_prompt },
            .{ .role = "user", .content = user_prompt },
        };
        const body = try stringifyJsonToString(
            allocator,
            OpenAIChatRequest{
                .model = provider.model,
                .messages = &messages,
            },
        );
        const url = try std.fmt.allocPrint(allocator, "{s}/v1/chat/completions", .{provider.base_url});
        const result = try runCommandCapture(
            allocator,
            &.{
                "curl",
                "-fsS",
                "--max-time",
                try timeoutSeconds(allocator, provider.timeout_ms),
                "-H",
                "Content-Type: application/json",
                "-X",
                "POST",
                "-d",
                body,
                url,
            },
        );
        if (result.exit_code != 0) return error.BackendUnavailable;
        const parsed = try parseJson(OpenAIChatResponse, allocator, result.stdout);
        if (parsed.@"error".message.len > 0) return error.ProviderRejectedRequest;
        if (parsed.choices.len == 0) return error.EmptyProviderResponse;
        const raw_text = try openAIMessageRawText(allocator, parsed.choices[0].message);
        return .{
            .raw_text = raw_text,
            .transport_text = result.stdout,
            .provider_name = provider.type,
            .model_name = provider.model,
            .latency_ms = std.time.milliTimestamp() - started,
        };
    }

    return error.UnsupportedProvider;
}

const MessagePayload = struct {
    role: []const u8,
    content: []const u8,
};

const OllamaChatRequest = struct {
    model: []const u8,
    stream: bool,
    think: bool = false,
    format: []const u8,
    messages: []const MessagePayload,
};

const OpenAIChatRequest = struct {
    model: []const u8,
    messages: []const MessagePayload,
};

fn buildOllamaChatBody(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    system_prompt: []const u8,
    user_prompt: []const u8,
    stream: bool,
) ![]const u8 {
    const messages = [_]MessagePayload{
        .{ .role = "system", .content = system_prompt },
        .{ .role = "user", .content = user_prompt },
    };
    return try stringifyJsonToString(
        allocator,
        OllamaChatRequest{
            .model = provider.model,
            .stream = stream,
            .format = provider.structured_output,
            .messages = &messages,
        },
    );
}

fn stringifyJsonToString(allocator: std.mem.Allocator, value: anytype) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{f}", .{std.json.fmt(value, .{})});
}

fn providerStructuredChatOllamaNonStreaming(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    body: []const u8,
    url: []const u8,
    started: i64,
) !ProviderResponse {
    const result = try runCommandCapture(
        allocator,
        &.{
            "curl",
            "-fsS",
            "--max-time",
            try timeoutSeconds(allocator, provider.timeout_ms),
            "-H",
            "Content-Type: application/json",
            "-X",
            "POST",
            "-d",
            body,
            url,
        },
    );
    if (result.exit_code != 0) return error.BackendUnavailable;
    const parsed = try parseJson(OllamaChatResponse, allocator, result.stdout);
    if (parsed.@"error".len > 0) return error.ProviderRejectedRequest;
    const raw_text = try ollamaMessageRawText(allocator, parsed.message);
    return .{
        .raw_text = raw_text,
        .transport_text = result.stdout,
        .provider_name = provider.type,
        .model_name = provider.model,
        .latency_ms = std.time.milliTimestamp() - started,
    };
}

fn ollamaMessageRawText(allocator: std.mem.Allocator, message: OllamaMessage) ![]const u8 {
    if (trimAscii(message.content).len > 0) return message.content;
    if (message.tool_calls.len > 0) return try ollamaToolCallsToStructuredJson(allocator, message);
    return error.EmptyModelOutput;
}

fn openAIMessageRawText(allocator: std.mem.Allocator, message: OpenAIMessage) ![]const u8 {
    if (trimAscii(message.content).len > 0) return message.content;
    if (message.tool_calls.len > 0) return try openAIToolCallsToStructuredJson(allocator, message.tool_calls);
    return error.EmptyModelOutput;
}

fn ollamaToolCallsToStructuredJson(allocator: std.mem.Allocator, message: OllamaMessage) ![]const u8 {
    var requests: std.ArrayList(ToolRequest) = .empty;
    defer requests.deinit(allocator);
    for (message.tool_calls) |tool_call| {
        try requests.append(allocator, try toolRequestFromOllamaToolCall(tool_call.function));
    }

    const reasoning = if (trimAscii(message.thinking).len > 0)
        trimAscii(message.thinking)
    else
        "model emitted tool_calls";

    return try std.fmt.allocPrint(
        allocator,
        "{{\"action\":\"tool_request\",\"reasoning\":{f},\"tool_requests\":{f}}}",
        .{
            std.json.fmt(reasoning, .{}),
            std.json.fmt(requests.items, .{}),
        },
    );
}

fn openAIToolCallsToStructuredJson(allocator: std.mem.Allocator, tool_calls: []const OpenAIToolCall) ![]const u8 {
    var requests: std.ArrayList(ToolRequest) = .empty;
    defer {
        for (requests.items) |request| freeOwnedToolRequest(allocator, request);
        requests.deinit(allocator);
    }
    for (tool_calls) |tool_call| {
        if (tool_call.function.arguments.len > 0) {
            const parsed = try std.json.parseFromSlice(OllamaToolArguments, allocator, tool_call.function.arguments, .{
                .ignore_unknown_fields = true,
            });
            defer parsed.deinit();
            const request = try toolRequestFromProviderToolCall(tool_call.function.name, parsed.value);
            try requests.append(allocator, try cloneToolRequest(allocator, request));
            continue;
        }
        const request = try toolRequestFromProviderToolCall(tool_call.function.name, .{});
        try requests.append(allocator, try cloneToolRequest(allocator, request));
    }

    return try std.fmt.allocPrint(
        allocator,
        "{{\"action\":\"tool_request\",\"reasoning\":\"model emitted tool_calls\",\"tool_requests\":{f}}}",
        .{std.json.fmt(requests.items, .{})},
    );
}

fn cloneToolRequest(allocator: std.mem.Allocator, request: ToolRequest) !ToolRequest {
    return .{
        .tool = try allocator.dupe(u8, request.tool),
        .description = try allocator.dupe(u8, request.description),
        .path = try allocator.dupe(u8, request.path),
        .pattern = try allocator.dupe(u8, request.pattern),
        .command = try allocator.dupe(u8, request.command),
        .content = try allocator.dupe(u8, request.content),
    };
}

fn freeOwnedToolRequest(allocator: std.mem.Allocator, request: ToolRequest) void {
    allocator.free(request.tool);
    allocator.free(request.description);
    allocator.free(request.path);
    allocator.free(request.pattern);
    allocator.free(request.command);
    allocator.free(request.content);
}

fn toolRequestFromOllamaToolCall(function: OllamaToolFunction) !ToolRequest {
    return try toolRequestFromProviderToolCall(function.name, function.arguments);
}

fn toolRequestFromProviderToolCall(name: []const u8, arguments: OllamaToolArguments) !ToolRequest {
    const normalized_name = canonicalToolName(name);
    if (!eql(normalized_name, name)) {
        return .{
            .tool = normalized_name,
            .description = arguments.description,
            .path = arguments.path,
            .pattern = arguments.pattern,
            .command = arguments.command,
            .content = arguments.content,
        };
    }

    if (eql(name, "container.exec")) {
        const command = shellCommandFromOllamaToolArgs(arguments);
        if (looksLikeListFilesCommand(command)) {
            return .{
                .tool = "list_files",
                .description = "inferred from container.exec",
                .path = ".",
            };
        }
        return .{
            .tool = "run_command",
            .description = "inferred from container.exec",
            .command = command,
        };
    }

    return .{
        .tool = name,
        .description = arguments.description,
        .path = arguments.path,
        .pattern = arguments.pattern,
        .command = arguments.command,
        .content = arguments.content,
    };
}

fn shellCommandFromOllamaToolArgs(arguments: OllamaToolArguments) []const u8 {
    if (arguments.command.len > 0) return arguments.command;
    if (arguments.cmd.len >= 3 and (eql(arguments.cmd[0], "bash") or eql(arguments.cmd[0], "sh")) and eql(arguments.cmd[1], "-lc")) {
        return arguments.cmd[2];
    }
    if (arguments.cmd.len == 1) return arguments.cmd[0];
    return "";
}

fn looksLikeListFilesCommand(command: []const u8) bool {
    return std.mem.indexOf(u8, command, "ls") != null or
        std.mem.indexOf(u8, command, "find") != null or
        std.mem.indexOf(u8, command, "rg --files") != null;
}

fn providerStructuredChatOllamaStreaming(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    actor: []const u8,
    body: []const u8,
    url: []const u8,
    started: i64,
    hooks: RuntimeHooks,
) !ProviderResponse {
    var child = std.process.Child.init(
        &.{
            "curl",
            "-fsS",
            "--no-buffer",
            "--max-time",
            try timeoutSeconds(allocator, provider.timeout_ms),
            "-H",
            "Content-Type: application/json",
            "-X",
            "POST",
            "-d",
            body,
            url,
        },
        allocator,
    );
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    try child.spawn();

    var stdout_open = true;
    var stderr_open = true;
    var pending = std.ArrayList(u8).empty;
    var full_text = std.ArrayList(u8).empty;
    var transport = std.ArrayList(u8).empty;
    var stderr_text = std.ArrayList(u8).empty;

    while (stdout_open or stderr_open) {
        if (hooks.isInterrupted()) {
            _ = child.kill() catch {};
            _ = child.wait() catch {};
            return error.Interrupted;
        }

        var poll_items = [_]std.posix.pollfd{
            .{ .fd = child.stdout.?.handle, .events = std.posix.POLL.IN, .revents = 0 },
            .{ .fd = child.stderr.?.handle, .events = std.posix.POLL.IN, .revents = 0 },
        };
        _ = try std.posix.poll(&poll_items, 100);

        if (stdout_open and (poll_items[0].revents & (std.posix.POLL.IN | std.posix.POLL.HUP)) != 0) {
            var buffer: [4096]u8 = undefined;
            const read_len = try child.stdout.?.read(&buffer);
            if (read_len == 0) {
                stdout_open = false;
            } else {
                try transport.appendSlice(allocator, buffer[0..read_len]);
                try pending.appendSlice(allocator, buffer[0..read_len]);
                try processOllamaPendingLines(allocator, &pending, &full_text, actor, hooks);
            }
        }

        if (stderr_open and (poll_items[1].revents & (std.posix.POLL.IN | std.posix.POLL.HUP)) != 0) {
            var buffer: [1024]u8 = undefined;
            const read_len = try child.stderr.?.read(&buffer);
            if (read_len == 0) {
                stderr_open = false;
            } else {
                try stderr_text.appendSlice(allocator, buffer[0..read_len]);
            }
        }
    }

    if (pending.items.len > 0) {
        try processOllamaPendingLine(allocator, trimAscii(pending.items), &full_text, actor, hooks);
    }

    const term = try child.wait();
    if (exitCode(term) != 0) return error.BackendUnavailable;
    if (trimAscii(stderr_text.items).len > 0 and full_text.items.len == 0) return error.BackendUnavailable;
    if (trimAscii(full_text.items).len == 0) return error.EmptyModelOutput;

    return .{
        .raw_text = try full_text.toOwnedSlice(allocator),
        .transport_text = try transport.toOwnedSlice(allocator),
        .provider_name = provider.type,
        .model_name = provider.model,
        .latency_ms = std.time.milliTimestamp() - started,
    };
}

fn processOllamaPendingLines(
    allocator: std.mem.Allocator,
    pending: *std.ArrayList(u8),
    full_text: *std.ArrayList(u8),
    actor: []const u8,
    hooks: RuntimeHooks,
) !void {
    var consumed: usize = 0;
    while (std.mem.indexOfScalar(u8, pending.items[consumed..], '\n')) |line_end_rel| {
        const line_end = consumed + line_end_rel;
        const line = trimAscii(pending.items[consumed..line_end]);
        if (line.len > 0) {
            try processOllamaPendingLine(allocator, line, full_text, actor, hooks);
        }
        consumed = line_end + 1;
        if (consumed >= pending.items.len) break;
    }

    if (consumed > 0 and consumed <= pending.items.len) {
        const remaining = pending.items.len - consumed;
        std.mem.copyForwards(u8, pending.items[0..remaining], pending.items[consumed..]);
        pending.items.len = remaining;
    }
}

fn processOllamaPendingLine(
    allocator: std.mem.Allocator,
    line: []const u8,
    full_text: *std.ArrayList(u8),
    actor: []const u8,
    hooks: RuntimeHooks,
) !void {
    if (line.len == 0) return;
    const parsed = try std.json.parseFromSlice(OllamaChatStreamChunk, allocator, line, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();
    const chunk = parsed.value;
    if (chunk.@"error".len > 0) return error.ProviderRejectedRequest;
    if (chunk.message.content.len > 0) {
        try full_text.appendSlice(allocator, chunk.message.content);
        emitStreamChunk(hooks, actor, chunk.message.content);
    }
}

fn runCommandCapture(allocator: std.mem.Allocator, argv: []const []const u8) !CommandResult {
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

fn freeCommandResult(allocator: std.mem.Allocator, result: CommandResult) void {
    allocator.free(result.stdout);
    allocator.free(result.stderr);
}

fn runCommandCaptureWithTimeout(
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

fn runShellCommand(allocator: std.mem.Allocator, command: []const u8, timeout_ms: usize) !CommandResult {
    return try runCommandCaptureWithTimeout(allocator, &.{ "sh", "-lc", command }, timeout_ms);
}

fn shouldSkipWorkspacePath(path: []const u8, prune_noise: bool) bool {
    if (!prune_noise) return false;
    return eql(path, ".git") or
        std.mem.startsWith(u8, path, ".git/") or
        eql(path, ".zig-cache") or
        std.mem.startsWith(u8, path, ".zig-cache/") or
        eql(path, "zig-out") or
        std.mem.startsWith(u8, path, "zig-out/") or
        eql(path, "node_modules") or
        std.mem.startsWith(u8, path, "node_modules/") or
        eql(path, ".contubernium/logs") or
        std.mem.startsWith(u8, path, ".contubernium/logs/");
}

fn appendWorkspaceEntries(
    allocator: std.mem.Allocator,
    dir: std.fs.Dir,
    prefix: []const u8,
    prune_noise: bool,
    lines: *std.ArrayList([]const u8),
    truncated: *bool,
) !void {
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        if (truncated.*) return;

        const relative_path = if (prefix.len == 0)
            try allocator.dupe(u8, entry.name)
        else
            try std.fmt.allocPrint(allocator, "{s}/{s}", .{ prefix, entry.name });
        errdefer allocator.free(relative_path);

        if (shouldSkipWorkspacePath(relative_path, prune_noise)) {
            allocator.free(relative_path);
            continue;
        }

        if (entry.kind == .directory) {
            const display_path = try std.fmt.allocPrint(allocator, "{s}/", .{relative_path});
            if (lines.items.len >= max_list_files_entries) {
                allocator.free(display_path);
                allocator.free(relative_path);
                truncated.* = true;
                return;
            }
            try lines.append(allocator, display_path);

            var child = try dir.openDir(entry.name, .{ .iterate = true });
            defer child.close();
            try appendWorkspaceEntries(allocator, child, relative_path, prune_noise, lines, truncated);
            allocator.free(relative_path);
            continue;
        }

        if (lines.items.len >= max_list_files_entries) {
            allocator.free(relative_path);
            truncated.* = true;
            return;
        }
        try lines.append(allocator, relative_path);
    }
}

fn sortStringsAsc(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, lhs, rhs);
}

fn sortStringsDesc(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, rhs, lhs);
}

fn listWorkspaceFiles(allocator: std.mem.Allocator, path: []const u8) !CommandResult {
    const root = if (trimAscii(path).len > 0) trimAscii(path) else ".";

    var lines: std.ArrayList([]const u8) = .empty;
    defer {
        for (lines.items) |line| allocator.free(line);
        lines.deinit(allocator);
    }

    const prune_noise = eql(root, ".");
    var truncated = false;

    const dir = std.fs.cwd().openDir(root, .{ .iterate = true }) catch |err| switch (err) {
        error.NotDir => {
            const stdout = try allocator.dupe(u8, root);
            return .{
                .stdout = stdout,
                .stderr = try allocator.dupe(u8, ""),
                .exit_code = 0,
            };
        },
        else => return err,
    };
    var root_dir = dir;
    defer root_dir.close();

    const prefix = if (eql(root, ".")) "" else root;
    try appendWorkspaceEntries(allocator, root_dir, prefix, prune_noise, &lines, &truncated);
    std.mem.sort([]const u8, lines.items, {}, sortStringsAsc);

    const joined = if (lines.items.len == 0)
        try allocator.dupe(u8, "no files found")
    else
        try joinStrings(allocator, lines.items, "\n");
    const stdout = if (truncated) blk: {
        defer allocator.free(joined);
        break :blk try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{joined});
    } else joined;

    return .{
        .stdout = stdout,
        .stderr = if (truncated)
            try allocator.dupe(u8, "truncated directory listing")
        else
            try allocator.dupe(u8, ""),
        .exit_code = 0,
    };
}

fn summarizeCommandResult(
    allocator: std.mem.Allocator,
    label: []const u8,
    result: CommandResult,
    max_chars: usize,
) ![]const u8 {
    const combined = try std.fmt.allocPrint(
        allocator,
        "{s} (exit {d})\nstdout:\n{s}\n\nstderr:\n{s}",
        .{ label, result.exit_code, result.stdout, result.stderr },
    );
    return try truncateOwnedText(allocator, combined, max_chars);
}

fn searchText(allocator: std.mem.Allocator, pattern: []const u8, path: []const u8, max_hits: usize, timeout_ms: usize) ![]const u8 {
    const max_count = try std.fmt.allocPrint(allocator, "{d}", .{max_hits});
    defer allocator.free(max_count);

    const rg_result = runCommandCaptureWithTimeout(allocator, &.{ "rg", "-n", "--no-heading", "--max-count", max_count, pattern, path }, timeout_ms) catch |err| switch (err) {
        error.FileNotFound => {
            const grep_result = try runCommandCaptureWithTimeout(allocator, &.{ "grep", "-R", "-n", pattern, path }, timeout_ms);
            allocator.free(grep_result.stderr);
            return grep_result.stdout;
        },
        else => return err,
    };
    if (rg_result.exit_code == 0 or rg_result.exit_code == 1) {
        allocator.free(rg_result.stderr);
        return rg_result.stdout;
    }
    freeCommandResult(allocator, rg_result);
    const grep_result = try runCommandCaptureWithTimeout(allocator, &.{ "grep", "-R", "-n", pattern, path }, timeout_ms);
    allocator.free(grep_result.stderr);
    return grep_result.stdout;
}

fn readFileLimited(allocator: std.mem.Allocator, path: []const u8, limit: usize) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(allocator, path, limit);
}

fn writeFile(path: []const u8, content: []const u8) !void {
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(content);
}

fn resetStateForMission(state: *AppState, mission_prompt: []const u8) void {
    stateManager(state).resetForMission(mission_prompt);
}

fn initializeRuntimeSession(allocator: std.mem.Allocator, state: *AppState, config: AppConfig) void {
    _ = allocator;
    stateManager(state).initializeRuntimeSession(config);
}

fn appendHistory(allocator: std.mem.Allocator, state: *AppState, entry: HistoryEntry) !void {
    var history: std.ArrayList(HistoryEntry) = .empty;
    const previous = state.agent_loop.history;
    try history.appendSlice(allocator, previous);
    try history.append(allocator, entry);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
    if (previous.len > 0) allocator.free(previous);
}

fn taskForLane(state: *AppState, lane: Lane) *TaskLane {
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

fn taskForLaneConst(state: *const AppState, lane: Lane) *const TaskLane {
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

fn laneForActor(actor: Actor) Lane {
    return protocol.laneForActor(actor);
}

fn actorForLane(lane: Lane) Actor {
    return protocol.actorForLane(lane);
}

fn setLoopStep(state: *AppState, kind: LoopStepKind, actor: Actor, lane: Lane, summary: []const u8) void {
    state.agent_loop.last_step = .{
        .iteration = state.agent_loop.iteration,
        .kind = kind,
        .actor = actor,
        .lane = lane,
        .summary = summary,
    };
}

fn beginApprovalRequest(
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

fn resolveApprovalRequest(state: *AppState, approved: bool) void {
    stateManager(state).resolveApprovalRequest(approved);
}

fn singleItemSlice(allocator: std.mem.Allocator, value: []const u8) ![]const []const u8 {
    var items = try allocator.alloc([]const u8, 1);
    items[0] = value;
    return items;
}

fn invocationResultStatusFromText(text: []const u8, fallback: InvocationResultStatus) InvocationResultStatus {
    if (text.len == 0) return fallback;
    return parseInvocationResultStatus(text) orelse fallback;
}

fn materializeInvocationResult(
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

fn prepareInvocation(
    state: *AppState,
    lane: Lane,
    actor: Actor,
    objective: []const u8,
    completion_signal: []const u8,
    dependencies: []const []const u8,
) void {
    stateManager(state).prepareInvocation(lane, actor, objective, completion_signal, dependencies);
}

fn finalizeInvocation(
    state: *AppState,
    lane: Lane,
    actor: Actor,
    result: InvocationResult,
    description: []const u8,
) void {
    stateManager(state).finalizeInvocation(lane, actor, result, description);
}

fn taskSummaryText(allocator: std.mem.Allocator, tasks: Tasks) ![]const u8 {
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

fn recentHistoryText(allocator: std.mem.Allocator, history: []const HistoryEntry, max_events: usize) ![]const u8 {
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

fn estimateTokensFromText(text: []const u8) usize {
    if (text.len == 0) return 0;
    return (text.len + 3) / 4;
}

fn estimatePromptBudget(config: ContextConfig, system_prompt: []const u8, user_prompt: []const u8) PromptBudgetEstimate {
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

fn applyPromptBudgetEstimate(state: *AppState, config: ContextConfig, estimate: PromptBudgetEstimate) void {
    stateManager(state).applyPromptBudgetEstimate(config, estimate);
}

fn buildCondensedHistorySummary(
    allocator: std.mem.Allocator,
    entries: []const HistoryEntry,
    max_chars: usize,
) ![]const u8 {
    if (entries.len == 0) return "condensed prior progress";

    var lines: std.ArrayList([]const u8) = .empty;
    defer lines.deinit(allocator);
    try lines.append(allocator, try std.fmt.allocPrint(allocator, "condensed {d} earlier events", .{entries.len}));

    var artifacts: std.ArrayList([]const u8) = .empty;
    defer artifacts.deinit(allocator);
    for (entries) |entry| {
        for (entry.artifacts) |artifact| {
            if (artifact.len == 0 or containsString(artifacts.items, artifact)) continue;
            try artifacts.append(allocator, artifact);
        }
    }
    if (artifacts.items.len > 0) {
        try lines.append(allocator, try std.fmt.allocPrint(
            allocator,
            "artifacts: {s}",
            .{try joinStrings(allocator, artifacts.items, ", ")},
        ));
    }

    try lines.append(allocator, "milestones:");
    const milestone_start = if (entries.len > 6) entries.len - 6 else 0;
    for (entries[milestone_start..]) |entry| {
        const summary = try compactTextForUi(allocator, entry.summary, 2, 180);
        try lines.append(allocator, try std.fmt.allocPrint(
            allocator,
            "- #{d} {s}/{s}: {s}",
            .{
                entry.iteration,
                if (entry.actor.len > 0) entry.actor else "runtime",
                if (entry.lane.len > 0) entry.lane else "command",
                summary,
            },
        ));
    }

    return try truncateOwnedText(allocator, try joinStrings(allocator, lines.items, "\n"), max_chars);
}

fn condenseHistoryForContext(allocator: std.mem.Allocator, config: ContextConfig, state: *AppState) !bool {
    const keep_recent = @max(@as(usize, 1), config.condensed_keep_recent_events);
    if (state.agent_loop.history.len <= keep_recent + 1) return false;

    const previous = state.agent_loop.history;
    const split_index = previous.len - keep_recent;
    const older = previous[0..split_index];
    const summary = try buildCondensedHistorySummary(allocator, older, config.max_condensed_summary_chars);

    var history: std.ArrayList(HistoryEntry) = .empty;
    try history.append(allocator, .{
        .iteration = older[older.len - 1].iteration,
        .type = "condensed_context",
        .actor = "decanus",
        .lane = "command",
        .summary = summary,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
    });
    try history.appendSlice(allocator, previous[split_index..]);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
    allocator.free(previous);
    state.runtime_session.context_budget.condensation_count += 1;
    state.runtime_session.context_budget.condensed_history_events += older.len;
    state.runtime_session.context_budget.last_condensed_iteration = state.agent_loop.iteration;
    return true;
}

fn projectMemorySpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "project",
        .path = config.paths.project_memory_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

fn globalMemorySpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "global",
        .path = config.paths.global_memory_file,
        .max_chars = config.context.max_global_memory_chars,
    };
}

fn architectureSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "architecture",
        .path = config.paths.architecture_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

fn planSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "plan",
        .path = config.paths.plan_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

fn projectContextSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "project_context",
        .path = config.paths.project_context_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

fn loadRuntimeMemoryLayer(allocator: std.mem.Allocator, spec: RuntimeMemorySpec) !RuntimeMemoryLayer {
    const memory_path = trimAscii(spec.path);
    if (memory_path.len == 0 or !pathIsSafeForWorkspace(memory_path)) {
        return error.MemoryPathInvalid;
    }

    const data = std.fs.cwd().readFileAlloc(allocator, memory_path, max_file_bytes) catch |err| switch (err) {
        error.FileNotFound => return error.MemoryLayerMissing,
        else => return err,
    };
    defer allocator.free(data);

    const trimmed = trimAscii(data);
    const truncated = spec.max_chars > 0 and trimmed.len > spec.max_chars;
    const content = if (trimmed.len == 0)
        ""
    else if (truncated)
        try truncateText(allocator, trimmed, spec.max_chars)
    else
        try allocator.dupe(u8, trimmed);

    return .{
        .kind = spec.kind,
        .path = memory_path,
        .content = content,
        .source_chars = trimmed.len,
        .truncated = truncated,
        .owns_content = content.len > 0,
    };
}

fn blockForMemoryLoadFailure(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    spec: RuntimeMemorySpec,
    err: anyerror,
) !void {
    const error_code = switch (err) {
        error.MemoryPathInvalid => "MEMORY_PATH_INVALID",
        error.MemoryLayerMissing => "MEMORY_LAYER_MISSING",
        error.FileTooBig => "MEMORY_LAYER_TOO_LARGE",
        else => "MEMORY_LOAD_FAILED",
    };
    const message = switch (err) {
        error.MemoryPathInvalid => try std.fmt.allocPrint(
            allocator,
            "{s} memory path must stay inside the workspace: {s}",
            .{ spec.kind, spec.path },
        ),
        error.MemoryLayerMissing => try std.fmt.allocPrint(
            allocator,
            "{s} memory file is missing: {s}",
            .{ spec.kind, spec.path },
        ),
        error.FileTooBig => try std.fmt.allocPrint(
            allocator,
            "{s} memory file exceeds the runtime load ceiling: {s}",
            .{ spec.kind, spec.path },
        ),
        else => try std.fmt.allocPrint(
            allocator,
            "failed to load {s} memory from {s}",
            .{ spec.kind, spec.path },
        ),
    };

    const failure = buildRuntimeFailure(state, state.current_actor, laneForActor(state.current_actor), error_code, message, .{
        .target = spec.path,
        .detail = @errorName(err),
    });
    recordRuntimeFailure(state, failure);
    stateManager(state).markBlocked(state.current_actor, laneForActor(state.current_actor), message);
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "memory_load_blocked",
        .actor = actorName(state.current_actor),
        .lane = currentLaneForState(state.*),
        .summary = message,
        .artifacts = &.{spec.path},
        .timestamp = try unixTimestampString(allocator),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = state.current_actor,
        .lane = laneForActor(state.current_actor),
        .action = "memory_load_failed",
        .status = "blocked",
        .summary = message,
        .error_text = message,
        .failure = failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, "runtime", "Memory Load Failed", message, .plain);
    emitStateSnapshot(hooks, config, state.*);
}

fn loadPromptMemorySnapshot(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
) !RuntimeMemorySnapshot {
    const architecture_spec = architectureSpec(config);
    const architecture = loadRuntimeMemoryLayer(allocator, architecture_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, architecture_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer architecture.deinit(allocator);

    const plan_spec = planSpec(config);
    const plan = loadRuntimeMemoryLayer(allocator, plan_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, plan_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer plan.deinit(allocator);

    const project_context_spec = projectContextSpec(config);
    const project_context = loadRuntimeMemoryLayer(allocator, project_context_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, project_context_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer project_context.deinit(allocator);

    const project_spec = projectMemorySpec(config);
    const project = loadRuntimeMemoryLayer(allocator, project_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, project_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer project.deinit(allocator);

    const global_spec = globalMemorySpec(config);
    const global = loadRuntimeMemoryLayer(allocator, global_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, global_spec, err);
        return error.MemoryLoadBlocked;
    };

    return .{
        .architecture = architecture,
        .plan = plan,
        .project_context = project_context,
        .project = project,
        .global = global,
    };
}

fn progressDocumentationText(
    allocator: std.mem.Allocator,
    state: *const AppState,
    reason: []const u8,
    max_chars: usize,
) ![]const u8 {
    const task_summary = try taskSummaryText(allocator, state.tasks);
    const recent_history = try recentHistoryText(allocator, state.agent_loop.history, 5);
    const latest_result = try compactTextForUi(
        allocator,
        if (state.agent_loop.last_tool_result.len > 0) state.agent_loop.last_tool_result else "none",
        5,
        420,
    );
    return try truncateOwnedText(
        allocator,
        try std.fmt.allocPrint(
            allocator,
            "{s}\n\ncurrent goal: {s}\nloop: {d}/{d}\ncurrent actor: {s}\nactive tool: {s}\nlatest result: {s}\ntasks: {s}\nrecent progress:\n{s}",
            .{
                reason,
                if (state.mission.current_goal.len > 0) state.mission.current_goal else "idle",
                state.agent_loop.iteration,
                state.agent_loop.max_iterations,
                actorName(state.current_actor),
                if (state.agent_loop.active_tool) |active_tool| actorName(active_tool) else "none",
                latest_result,
                task_summary,
                recent_history,
            },
        ),
        max_chars,
    );
}

fn blockForContextLimit(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    estimate: PromptBudgetEstimate,
) !void {
    const message = try progressDocumentationText(
        allocator,
        state,
        try std.fmt.allocPrint(
            allocator,
            "estimated prompt budget exhausted before the next model turn ({d} tokens against {d} usable).",
            .{ estimate.prompt_tokens, estimate.usable_prompt_tokens },
        ),
        config.context.max_stop_summary_chars,
    );
    const failure = buildRuntimeFailure(state, state.current_actor, laneForActor(state.current_actor), "CONTEXT_BUDGET_EXCEEDED", message, .{});
    recordRuntimeFailure(state, failure);
    stateManager(state).markBlocked(state.current_actor, laneForActor(state.current_actor), message);
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "context_budget_blocked",
        .actor = actorName(state.current_actor),
        .lane = currentLaneForState(state.*),
        .summary = message,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = state.current_actor,
        .lane = laneForActor(state.current_actor),
        .action = "context_budget_blocked",
        .status = "blocked",
        .summary = message,
        .error_text = message,
        .failure = failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, "runtime", "Context Budget Reached", message, .plain);
    emitStateSnapshot(hooks, config, state.*);
}

fn buildPromptWithContextBudget(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    system_prompt: []const u8,
    mode: PromptMode,
    lane: []const u8,
) !PromptBuildResult {
    const memory = try loadPromptMemorySnapshot(allocator, config, state, hooks);
    errdefer memory.deinit(allocator);

    if (memory.architecture.truncated or
        memory.plan.truncated or
        memory.project_context.truncated or
        memory.project.truncated or
        memory.global.truncated)
    {
        emitLog(
            hooks,
            .warning,
            "runtime",
            "Memory Trimmed",
            try summarizeRuntimeMemorySnapshot(allocator, memory),
            .plain,
        );
    }

    var attempt: usize = 0;
    while (true) {
        const user_prompt = switch (mode) {
            .decanus => try buildDecanusUserPrompt(allocator, config, state, memory),
            .specialist => try buildSpecialistUserPrompt(allocator, config, state, memory, lane),
        };
        const estimate = estimatePromptBudget(config.context, system_prompt, user_prompt);
        applyPromptBudgetEstimate(state, config.context, estimate);
        emitStateSnapshot(hooks, config, state.*);

        if (!estimate.should_condense or attempt >= 3) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return .{
                .user_prompt = user_prompt,
                .memory = memory,
            };
        }

        const condensed = try condenseHistoryForContext(allocator, config.context, state);
        if (!condensed) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return .{
                .user_prompt = user_prompt,
                .memory = memory,
            };
        }

        emitLog(
            hooks,
            .warning,
            "runtime",
            "Context Condensed",
            try std.fmt.allocPrint(
                allocator,
                "condensed {d} earlier events and rebuilt the prompt budget",
                .{
                    state.runtime_session.context_budget.condensed_history_events,
                },
            ),
            .plain,
        );
        try logRuntimeEvent(allocator, config, state, .{
            .actor = state.current_actor,
            .lane = laneForActor(state.current_actor),
            .action = "context_condensed",
            .status = "success",
            .summary = try std.fmt.allocPrint(
                allocator,
                "condensed {d} earlier events and rebuilt the prompt budget",
                .{
                    state.runtime_session.context_budget.condensed_history_events,
                },
            ),
            .include_snapshot = true,
        });
        attempt += 1;
    }
}

fn runtimeToolSpec(tool_name: []const u8) ?RuntimeToolSpec {
    const normalized = canonicalToolName(tool_name);
    if (eql(normalized, "list_files")) return .{ .kind = .list_files, .name = "list_files", .approval_gate = .read };
    if (eql(normalized, "read_file")) return .{ .kind = .read_file, .name = "read_file", .approval_gate = .read };
    if (eql(normalized, "search_text")) return .{ .kind = .search_text, .name = "search_text", .approval_gate = .read };
    if (eql(normalized, "run_command")) return .{ .kind = .run_command, .name = "run_command", .approval_gate = .shell };
    if (eql(normalized, "write_file")) return .{ .kind = .write_file, .name = "write_file", .approval_gate = .write };
    if (eql(normalized, "ask_user")) return .{ .kind = .ask_user, .name = "ask_user", .approval_gate = .none };
    return null;
}

fn toolAllowsWithoutConfirmation(spec: RuntimeToolSpec, policy: PolicyConfig) bool {
    return switch (spec.approval_gate) {
        .none => true,
        .read => policy.allow_read_tools_without_confirmation,
        .shell => policy.allow_shell_without_confirmation,
        .write => policy.allow_workspace_writes_without_confirmation,
    };
}

fn pathIsSafeForWorkspace(path: []const u8) bool {
    const trimmed = trimAscii(path);
    if (trimmed.len == 0) return true;
    if (std.fs.path.isAbsolute(trimmed)) return false;

    var parts = std.mem.splitScalar(u8, trimmed, '/');
    while (parts.next()) |part| {
        if (eql(part, "..")) return false;
    }
    return true;
}

fn toolRequestContextSpec(request: ToolRequest, spec: RuntimeToolSpec) RuntimeFailureContextSpec {
    const target = if (request.path.len > 0)
        request.path
    else if (request.pattern.len > 0)
        request.pattern
    else if (request.command.len > 0)
        request.command
    else
        request.description;
    const detail = if (request.description.len > 0)
        request.description
    else if (request.pattern.len > 0)
        request.pattern
    else if (request.command.len > 0)
        request.command
    else
        request.path;
    return .{
        .tool = spec.name,
        .target = target,
        .command = request.command,
        .detail = detail,
    };
}

fn validatedToolContextSpec(request: ValidatedToolRequest) RuntimeFailureContextSpec {
    return .{
        .tool = request.spec.name,
        .target = request.target,
        .command = request.command,
        .detail = request.detail,
    };
}

fn validateToolRequest(
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    request: ToolRequest,
) ToolRequestValidation {
    const spec = runtimeToolSpec(request.tool) orelse return .{
        .blocked = buildRuntimeFailure(state, actor, lane, "UNKNOWN_TOOL_REQUEST", "runtime tool is not supported", .{
            .tool = canonicalToolName(request.tool),
            .detail = request.description,
        }),
    };

    switch (spec.kind) {
        .list_files => {
            const path = if (trimAscii(request.path).len > 0) trimAscii(request.path) else ".";
            if (!pathIsSafeForWorkspace(path)) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "TOOL_PATH_UNSAFE", "tool path escapes workspace policy", .{
                        .tool = spec.name,
                        .target = path,
                        .detail = request.description,
                    }),
                };
            }
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = if (request.description.len > 0) request.description else path,
                    .target = path,
                    .path = path,
                },
            };
        },
        .read_file => {
            const path = trimAscii(request.path);
            if (path.len == 0) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "MISSING_PATH", "read_file requires a path", toolRequestContextSpec(request, spec)),
                };
            }
            if (!pathIsSafeForWorkspace(path)) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "TOOL_PATH_UNSAFE", "tool path escapes workspace policy", .{
                        .tool = spec.name,
                        .target = path,
                        .detail = request.description,
                    }),
                };
            }
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = if (request.description.len > 0) request.description else path,
                    .target = path,
                    .path = path,
                },
            };
        },
        .search_text => {
            const pattern = trimAscii(request.pattern);
            if (pattern.len == 0) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "MISSING_PATTERN", "search_text requires a pattern", toolRequestContextSpec(request, spec)),
                };
            }
            const path = if (trimAscii(request.path).len > 0) trimAscii(request.path) else ".";
            if (!pathIsSafeForWorkspace(path)) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "TOOL_PATH_UNSAFE", "tool path escapes workspace policy", .{
                        .tool = spec.name,
                        .target = path,
                        .detail = pattern,
                    }),
                };
            }
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = if (request.description.len > 0) request.description else pattern,
                    .target = path,
                    .path = path,
                    .pattern = pattern,
                },
            };
        },
        .run_command => {
            const command = trimAscii(request.command);
            if (command.len == 0) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "MISSING_COMMAND", "run_command requires a command", toolRequestContextSpec(request, spec)),
                };
            }
            if (commandIsBlocked(config.policy.blocked_command_patterns, command)) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "TOOL_POLICY_BLOCKED", "run_command blocked by policy", .{
                        .tool = spec.name,
                        .command = command,
                        .detail = request.description,
                    }),
                };
            }
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = if (request.description.len > 0) request.description else command,
                    .target = command,
                    .command = command,
                },
            };
        },
        .write_file => {
            const path = trimAscii(request.path);
            if (path.len == 0) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "MISSING_PATH", "write_file requires a path", toolRequestContextSpec(request, spec)),
                };
            }
            if (!pathIsSafeForWorkspace(path)) {
                return .{
                    .blocked = buildRuntimeFailure(state, actor, lane, "TOOL_PATH_UNSAFE", "tool path escapes workspace policy", .{
                        .tool = spec.name,
                        .target = path,
                        .detail = request.description,
                    }),
                };
            }
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = if (request.description.len > 0) request.description else path,
                    .target = path,
                    .path = path,
                    .content = request.content,
                },
            };
        },
        .ask_user => {
            const question = if (trimAscii(request.description).len > 0) trimAscii(request.description) else "tool requested user input";
            return .{
                .ok = .{
                    .spec = spec,
                    .detail = question,
                    .target = question,
                },
            };
        },
    }
}

fn buildToolExecutionFailure(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    request: ValidatedToolRequest,
    err: anyerror,
) !RuntimeFailure {
    if (err == error.ToolTimedOut) {
        return buildRuntimeFailure(
            state,
            actor,
            lane,
            "TOOL_TIMEOUT",
            try std.fmt.allocPrint(allocator, "{s} exceeded the {d}ms runtime limit", .{ request.spec.name, config.policy.tool_timeout_ms }),
            validatedToolContextSpec(request),
        );
    }
    if (err == error.FileNotFound) {
        return buildRuntimeFailure(state, actor, lane, "FILE_NOT_FOUND", "requested path was not found inside the workspace", validatedToolContextSpec(request));
    }
    if (err == error.IsDir) {
        return buildRuntimeFailure(state, actor, lane, "TOOL_TARGET_INVALID", "tool expected a file but received a directory", validatedToolContextSpec(request));
    }
    if (err == error.AccessDenied) {
        return buildRuntimeFailure(state, actor, lane, "TOOL_ACCESS_DENIED", "tool access was denied by the operating system", validatedToolContextSpec(request));
    }
    return buildRuntimeFailure(
        state,
        actor,
        lane,
        "TOOL_EXECUTION_FAILED",
        try std.fmt.allocPrint(allocator, "{s} failed: {s}", .{ request.spec.name, @errorName(err) }),
        validatedToolContextSpec(request),
    );
}

fn executeValidatedToolRequest(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    request: ValidatedToolRequest,
    hooks: RuntimeHooks,
) !ToolRequestExecution {
    if (!toolAllowsWithoutConfirmation(request.spec, config.policy) and
        !try confirmTool(allocator, config, state, hooks, actor, lane, request.spec.name, request.detail, request.target))
    {
        return .{
            .blocked = true,
            .failure = buildRuntimeFailure(state, actor, lane, "TOOL_DENIED", "runtime tool denied by operator", validatedToolContextSpec(request)),
            .summary = try std.fmt.allocPrint(allocator, "blocked: {s} denied by operator", .{request.spec.name}),
        };
    }

    switch (request.spec.kind) {
        .list_files => {
            const output = try listWorkspaceFiles(allocator, request.path);
            defer freeCommandResult(allocator, output);
            return .{
                .summary = try summarizeCommandResult(allocator, request.spec.name, output, config.context.max_tool_result_chars),
            };
        },
        .read_file => {
            const content = try readFileLimited(allocator, request.path, config.context.max_file_read_bytes);
            defer allocator.free(content);
            return .{
                .summary = try truncateOwnedText(
                    allocator,
                    try std.fmt.allocPrint(allocator, "read_file {s}\n{s}", .{ request.path, content }),
                    config.context.max_tool_result_chars,
                ),
            };
        },
        .search_text => {
            const output = try searchText(allocator, request.pattern, request.path, config.context.max_search_hits, config.policy.tool_timeout_ms);
            defer allocator.free(output);
            return .{
                .summary = try truncateOwnedText(
                    allocator,
                    try std.fmt.allocPrint(allocator, "search_text {s} in {s}\n{s}", .{ request.pattern, request.path, output }),
                    config.context.max_tool_result_chars,
                ),
            };
        },
        .run_command => {
            const output = try runShellCommand(allocator, request.command, config.policy.tool_timeout_ms);
            defer freeCommandResult(allocator, output);
            return .{
                .summary = try summarizeCommandResult(allocator, request.spec.name, output, config.context.max_tool_result_chars),
            };
        },
        .write_file => {
            try writeFile(request.path, request.content);
            return .{
                .summary = try std.fmt.allocPrint(allocator, "write_file {s} ({d} bytes)", .{ request.path, request.content.len }),
            };
        },
        .ask_user => {
            const failure = buildRuntimeFailure(state, actor, lane, "USER_INPUT_REQUIRED", request.detail, validatedToolContextSpec(request));
            emitLog(hooks, .warning, actorName(actor), "Question", request.detail, .plain);
            return .{
                .blocked = true,
                .failure = failure,
                .summary = try std.fmt.allocPrint(allocator, "ask_user {s}", .{request.detail}),
            };
        },
    }
}

fn toolRequestDisplay(allocator: std.mem.Allocator, request: ToolRequest) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    try writeToolRequestLabel(buffer.writer(allocator), request);
    return try buffer.toOwnedSlice(allocator);
}

fn confirmTool(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    actor: Actor,
    lane: Lane,
    tool_name: []const u8,
    detail: []const u8,
    target: []const u8,
) !bool {
    beginApprovalRequest(state, actor, lane, tool_name, detail, detail, target);
    emitStateSnapshot(hooks, config, state.*);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "approval_requested",
        .status = "pending",
        .tool = tool_name,
        .summary = detail,
        .input = target,
        .include_snapshot = true,
    });
    if (hooks.requestApproval(tool_name, detail)) |decision| {
        resolveApprovalRequest(state, decision);
        emitStateSnapshot(hooks, config, state.*);
        try logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "approval_resolved",
            .status = if (decision) "approved" else "denied",
            .tool = tool_name,
            .summary = detail,
            .include_snapshot = true,
        });
        return decision;
    }
    try stdoutPrint("allow {s}? {s} [y/N]: ", .{ tool_name, detail });
    const input = try std.fs.File.stdin().deprecatedReader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
    const approved = input != null and (eql(trimAscii(input.?), "y") or eql(trimAscii(input.?), "yes"));
    resolveApprovalRequest(state, approved);
    emitStateSnapshot(hooks, config, state.*);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "approval_resolved",
        .status = if (approved) "approved" else "denied",
        .tool = tool_name,
        .summary = detail,
        .include_snapshot = true,
    });
    return approved;
}

fn copyFileIfMissing(allocator: std.mem.Allocator, source_path: []const u8, target_path: []const u8) !void {
    _ = allocator;
    std.fs.cwd().access(target_path, .{}) catch {
        const content = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, source_path, max_file_bytes);
        defer std.heap.page_allocator.free(content);
        if (std.fs.path.dirname(target_path)) |dir_name| {
            try std.fs.cwd().makePath(dir_name);
        }
        var file = try std.fs.cwd().createFile(target_path, .{ .truncate = true });
        defer file.close();
        try file.writeAll(content);
        return;
    };
}

fn scaffoldProject(allocator: std.mem.Allocator) !void {
    try std.fs.cwd().makePath(default_logs_dir);
    for (embedded_assets) |asset| {
        const destination = try runtimePath(allocator, asset.relative_path);
        defer allocator.free(destination);
        try writeFileIfMissing(destination, asset.content);
    }
}

fn runtimePath(allocator: std.mem.Allocator, relative_path: []const u8) ![]const u8 {
    return try std.fs.path.join(allocator, &.{ runtime_dir_name, relative_path });
}

fn resolveContuberniumHome(allocator: std.mem.Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(allocator, "CONTUBERNIUM_HOME") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => {
            const home = try std.process.getEnvVarOwned(allocator, "HOME");
            defer allocator.free(home);
            return try std.fs.path.join(allocator, &.{ home, ".contubernium" });
        },
        else => return err,
    };
}

fn deinitGlobalAssetLayout(allocator: std.mem.Allocator, layout: GlobalAssetLayout) void {
    allocator.free(layout.root);
    allocator.free(layout.agents_root);
    allocator.free(layout.shared_root);
    allocator.free(layout.adapters_root);
}

fn resolveSourceAssetRoot(allocator: std.mem.Allocator) ![]const u8 {
    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);
    const exe_dir = std.fs.path.dirname(exe_path) orelse return error.AgentAssetSourceNotFound;

    var current_dir = try allocator.dupe(u8, exe_dir);
    errdefer allocator.free(current_dir);

    while (true) {
        const candidate_agents = try std.fs.path.join(allocator, &.{ current_dir, ".agents" });
        errdefer allocator.free(candidate_agents);
        const candidate_loop = try std.fs.path.join(allocator, &.{ candidate_agents, "AGENT_LOOP.md" });
        defer allocator.free(candidate_loop);
        const candidate_shared = try std.fs.path.join(allocator, &.{ current_dir, "shared", "patterns", "RUNTIME_BASE.md" });
        defer allocator.free(candidate_shared);
        if (pathExists(candidate_loop) and pathExists(candidate_shared)) {
            allocator.free(current_dir);
            return candidate_agents;
        }
        allocator.free(candidate_agents);

        const parent = std.fs.path.dirname(current_dir) orelse break;
        if (parent.len == current_dir.len and eql(parent, current_dir)) break;
        if (parent.len == 0) break;

        const next_dir = try allocator.dupe(u8, parent);
        allocator.free(current_dir);
        current_dir = next_dir;
    }

    allocator.free(current_dir);

    return error.AgentAssetSourceNotFound;
}

fn resolveGlobalAssetLayout(allocator: std.mem.Allocator) !GlobalAssetLayout {
    const contubernium_home = try resolveContuberniumHome(allocator);
    errdefer allocator.free(contubernium_home);

    const home_agents = try std.fs.path.join(allocator, &.{ contubernium_home, "agents" });
    errdefer allocator.free(home_agents);
    const home_shared = try std.fs.path.join(allocator, &.{ contubernium_home, "shared" });
    errdefer allocator.free(home_shared);
    const home_adapters = try std.fs.path.join(allocator, &.{ contubernium_home, "adapters" });
    errdefer allocator.free(home_adapters);
    const home_loop = try std.fs.path.join(allocator, &.{ home_agents, "AGENT_LOOP.md" });
    defer allocator.free(home_loop);
    const home_base = try std.fs.path.join(allocator, &.{ home_shared, "patterns", "RUNTIME_BASE.md" });
    defer allocator.free(home_base);
    if (pathExists(home_loop) and pathExists(home_base)) {
        return .{
            .root = contubernium_home,
            .agents_root = home_agents,
            .shared_root = home_shared,
            .adapters_root = home_adapters,
        };
    }
    allocator.free(home_adapters);
    allocator.free(home_shared);
    allocator.free(home_agents);
    allocator.free(contubernium_home);

    const source_agents = try resolveSourceAssetRoot(allocator);
    errdefer allocator.free(source_agents);
    const source_root = std.fs.path.dirname(source_agents) orelse return error.AgentAssetSourceNotFound;
    const root = try allocator.dupe(u8, source_root);
    errdefer allocator.free(root);
    const shared_root = try std.fs.path.join(allocator, &.{ root, "shared" });
    errdefer allocator.free(shared_root);
    const adapters_root = try std.fs.path.join(allocator, &.{ root, "adapters" });
    errdefer allocator.free(adapters_root);
    return .{
        .root = root,
        .agents_root = source_agents,
        .shared_root = shared_root,
        .adapters_root = adapters_root,
    };
}

fn writeFileIfMissing(path: []const u8, content: []const u8) !void {
    std.fs.cwd().access(path, .{}) catch {
        if (std.fs.path.dirname(path)) |dir_name| {
            try std.fs.cwd().makePath(dir_name);
        }
        var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
        defer file.close();
        try file.writeAll(content);
        return;
    };
}

fn resolveConfigPath(allocator: std.mem.Allocator) ![]const u8 {
    _ = allocator;
    if (pathExists(default_config_path)) return default_config_path;
    return default_config_path;
}

fn pathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

fn pathIsSafeForWrite(path: []const u8) bool {
    return pathIsSafeForWorkspace(path);
}

fn commandIsBlocked(patterns: []const []const u8, command: []const u8) bool {
    for (patterns) |pattern| {
        if (std.mem.indexOf(u8, command, pattern) != null) return true;
    }
    return false;
}

fn timeoutSeconds(allocator: std.mem.Allocator, timeout_ms: usize) ![]const u8 {
    const seconds = if (timeout_ms < 1000) 1 else timeout_ms / 1000;
    return try std.fmt.allocPrint(allocator, "{d}", .{seconds});
}

fn joinArgs(allocator: std.mem.Allocator, args: []const []const u8) ![]const u8 {
    return try joinStrings(allocator, args, " ");
}

fn joinStrings(allocator: std.mem.Allocator, items: []const []const u8, separator: []const u8) ![]const u8 {
    if (items.len == 0) return "";
    return try std.mem.join(allocator, separator, items);
}

fn canonicalToolName(tool_name: []const u8) []const u8 {
    if (isSupportedToolName(tool_name)) return tool_name;
    if (std.mem.lastIndexOfScalar(u8, tool_name, '.')) |dot_index| {
        const suffix = tool_name[dot_index + 1 ..];
        if (isSupportedToolName(suffix)) return suffix;
    }
    return tool_name;
}

fn isSupportedToolName(tool_name: []const u8) bool {
    return eql(tool_name, "list_files") or
        eql(tool_name, "read_file") or
        eql(tool_name, "search_text") or
        eql(tool_name, "run_command") or
        eql(tool_name, "write_file") or
        eql(tool_name, "ask_user");
}

fn makeTurnId(allocator: std.mem.Allocator, actor: []const u8, iteration: usize) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d}-{d}-{s}", .{ std.time.timestamp(), iteration, actor });
}

fn makeRunId(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "run-{d}", .{std.time.milliTimestamp()});
}

fn logPathForRun(allocator: std.mem.Allocator, logs_dir: []const u8, run_id: []const u8) ![]const u8 {
    try std.fs.cwd().makePath(logs_dir);
    return try std.fmt.allocPrint(allocator, "{s}/{s}.json", .{ logs_dir, run_id });
}

fn initializeRuntimeRunLog(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    command: []const u8,
) !void {
    const run_id = try makeRunId(allocator);
    stateManager(state).setActiveLogPath(try logPathForRun(allocator, config.paths.logs_dir, run_id));

    const timestamp = try unixTimestampString(allocator);
    const log = RuntimeRunLog{
        .run_id = run_id,
        .command = command,
        .created_at = timestamp,
        .updated_at = timestamp,
        .project_name = state.project_name,
        .provider = config.provider.type,
        .model = config.provider.model,
        .approval_mode = config.policy.approval_mode,
        .mission_prompt = state.mission.initial_prompt,
        .events = &.{},
    };
    try saveRuntimeRunLog(allocator, state.runtime_session.active_log_path, log);
}

fn appendRuntimeRunLogEvent(allocator: std.mem.Allocator, path: []const u8, event: RuntimeLogEvent) !void {
    if (path.len == 0) return;

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    var log = try loadRuntimeRunLog(scratch, path);
    var events: std.ArrayList(RuntimeLogEvent) = .empty;
    try events.appendSlice(scratch, log.events);
    try events.append(scratch, event);
    log.updated_at = event.timestamp;
    log.events = try events.toOwnedSlice(scratch);
    try saveRuntimeRunLog(scratch, path, log);
}

fn logRuntimeEvent(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    spec: RuntimeLogEventSpec,
) !void {
    if (state.runtime_session.active_log_path.len == 0) return;

    const project_name = if (!eql(state.project_name, "UNASSIGNED")) state.project_name else "";
    const snapshot = if (spec.include_snapshot)
        buildStateSnapshot(config, state.*, project_name)
    else
        null;

    try appendRuntimeRunLogEvent(allocator, state.runtime_session.active_log_path, .{
        .timestamp = try unixTimestampString(allocator),
        .iteration = state.agent_loop.iteration,
        .turn_id = state.runtime_session.current_turn_id,
        .actor = actorName(spec.actor),
        .lane = laneName(spec.lane),
        .action = spec.action,
        .status = spec.status,
        .tool = spec.tool,
        .summary = spec.summary,
        .input = spec.input,
        .output = spec.output,
        .error_text = spec.error_text,
        .failure = spec.failure,
        .snapshot = snapshot,
    });
}

fn truncateText(allocator: std.mem.Allocator, text: []const u8, max_chars: usize) ![]const u8 {
    if (text.len <= max_chars) return text;
    return try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{safeUtf8PrefixByBytes(text, max_chars)});
}

fn truncateOwnedText(allocator: std.mem.Allocator, owned_text: []const u8, max_chars: usize) ![]const u8 {
    const truncated = try truncateText(allocator, owned_text, max_chars);
    if (truncated.ptr != owned_text.ptr) allocator.free(owned_text);
    return truncated;
}

fn unixTimestampString(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d}", .{std.time.timestamp()});
}

fn parseJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const parsed = try std.json.parseFromSlice(T, allocator, text, .{
        .ignore_unknown_fields = true,
    });
    return parsed.value;
}

fn parseModelJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const normalized = try normalizeModelJson(text);
    if (T == DecanusDecision) return try parseDecanusDecisionModelJson(allocator, normalized);
    if (T == SpecialistResult) return try parseSpecialistResultModelJson(allocator, normalized);
    if (T == ToolRequest) return try parseToolRequestModelJson(allocator, normalized);
    return try parseJson(T, allocator, normalized);
}

fn parseDecanusDecisionModelJson(allocator: std.mem.Allocator, text: []const u8) !DecanusDecision {
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

fn parseSpecialistResultModelJson(allocator: std.mem.Allocator, text: []const u8) !SpecialistResult {
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

fn parseToolRequestModelJson(allocator: std.mem.Allocator, text: []const u8) !ToolRequest {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();
    return try dupToolRequestFromJsonValue(allocator, parsed.value);
}

fn parseModelValueTree(allocator: std.mem.Allocator, text: []const u8) !std.json.Parsed(std.json.Value) {
    return try std.json.parseFromSlice(std.json.Value, allocator, text, .{
        .ignore_unknown_fields = true,
    });
}

fn requireJsonObject(value: std.json.Value) !std.json.ObjectMap {
    return switch (value) {
        .object => |object| object,
        else => error.UnexpectedToken,
    };
}

fn dupJsonObjectStringFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
    default_value: []const u8,
) ![]const u8 {
    const value = object.get(field_name) orelse return try allocator.dupe(u8, default_value);
    return try dupJsonStringValueOrDefault(allocator, value, default_value);
}

fn dupJsonStringValueOrDefault(
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

fn dupJsonObjectStringArrayFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const []const u8 {
    const value = object.get(field_name) orelse return try allocator.alloc([]const u8, 0);
    return try dupJsonStringArrayValueOrDefault(allocator, value);
}

fn dupJsonStringArrayValueOrDefault(
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

fn dupJsonObjectToolRequestsFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const ToolRequest {
    const value = object.get(field_name) orelse return try allocator.alloc(ToolRequest, 0);
    return try dupToolRequestsValueOrDefault(allocator, value);
}

fn dupToolRequestsValueOrDefault(
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

fn dupToolRequestFromJsonValue(allocator: std.mem.Allocator, value: std.json.Value) !ToolRequest {
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

fn jsonObjectFloatFieldOrDefault(
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

fn prettyPrintJson(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
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

fn normalizeModelJson(text: []const u8) ![]const u8 {
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

fn containsString(items: []const []const u8, needle: []const u8) bool {
    for (items) |item| {
        if (eql(item, needle)) return true;
    }
    return false;
}

fn eql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn trimAscii(text: []const u8) []const u8 {
    return std.mem.trim(u8, text, " \t\r\n");
}

fn exitCode(term: std.process.Child.Term) i32 {
    return switch (term) {
        .Exited => |code| code,
        else => -1,
    };
}

fn testQueueEmit(context: ?*anyopaque, event: RuntimeUiEvent) void {
    const queue: *RuntimeEventQueue = @ptrCast(@alignCast(context.?));
    queue.push(event);
}

fn testDenyApproval(_: ?*anyopaque, _: []const u8, _: []const u8) bool {
    return false;
}

fn freeOwnedStringSlice(allocator: std.mem.Allocator, items: []const []const u8) void {
    for (items) |item| allocator.free(item);
    allocator.free(items);
}

fn freeOwnedDecanusDecision(allocator: std.mem.Allocator, decision: DecanusDecision) void {
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

fn freeOwnedSpecialistResult(allocator: std.mem.Allocator, result: SpecialistResult) void {
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

test "toolRequestDisplay prefers command and path fields" {
    const testing = std.testing;
    const command_text = try toolRequestDisplay(testing.allocator, .{ .tool = "run_command", .command = "zig build" });
    defer testing.allocator.free(command_text);
    try testing.expectEqualStrings("run_command zig build", command_text);

    const path_text = try toolRequestDisplay(testing.allocator, .{ .tool = "read_file", .path = "src/main.zig" });
    defer testing.allocator.free(path_text);
    try testing.expectEqualStrings("read_file src/main.zig", path_text);

    const list_text = try toolRequestDisplay(testing.allocator, .{ .tool = "list_files" });
    defer testing.allocator.free(list_text);
    try testing.expectEqualStrings("list_files .", list_text);
}

test "canonicalToolName maps repo_browser aliases" {
    const testing = std.testing;
    try testing.expectEqualStrings("list_files", canonicalToolName("repo_browser.list_files"));
    try testing.expectEqualStrings("read_file", canonicalToolName("repo_browser.read_file"));
    try testing.expectEqualStrings("search_text", canonicalToolName("repo_browser.search_text"));
    try testing.expectEqualStrings("write_file", canonicalToolName("write_file"));
}

test "prettyPrintJson indents normalized model output" {
    const testing = std.testing;
    const text = try prettyPrintJson(testing.allocator, "```json\n{\"status\":\"ok\",\"nested\":{\"value\":1}}\n```");
    defer testing.allocator.free(text);
    try testing.expect(std.mem.indexOf(u8, text, "\n  \"status\"") != null);
    try testing.expect(std.mem.indexOf(u8, text, "\n  \"nested\"") != null);
}

test "parseModelJson accepts null specialist fields" {
    const testing = std.testing;
    const parsed = try parseModelJson(SpecialistResult, testing.allocator,
        \\{
        \\  "action": "complete",
        \\  "reasoning": "done",
        \\  "status": "complete",
        \\  "summary": "ok",
        \\  "changes": null,
        \\  "findings": [],
        \\  "blockers": null,
        \\  "next_recommended_agent": null,
        \\  "confidence": 1.0,
        \\  "description": "desc",
        \\  "result_summary": "sum",
        \\  "artifacts": null,
        \\  "follow_up_needed": null,
        \\  "question": null,
        \\  "blocked_reason": null,
        \\  "tool_requests": [
        \\    {
        \\      "tool": "read_file",
        \\      "description": null,
        \\      "path": "src/main.zig",
        \\      "pattern": null,
        \\      "command": null,
        \\      "content": null
        \\    }
        \\  ]
        \\}
    );
    defer freeOwnedSpecialistResult(testing.allocator, parsed);

    try testing.expectEqualStrings("complete", parsed.action);
    try testing.expectEqual(@as(usize, 0), parsed.changes.len);
    try testing.expectEqual(@as(usize, 0), parsed.blockers.len);
    try testing.expectEqualStrings("", parsed.next_recommended_agent);
    try testing.expectEqualStrings("", parsed.question);
    try testing.expectEqualStrings("", parsed.blocked_reason);
    try testing.expectEqual(@as(usize, 1), parsed.tool_requests.len);
    try testing.expectEqualStrings("read_file", parsed.tool_requests[0].tool);
    try testing.expectEqualStrings("", parsed.tool_requests[0].description);
    try testing.expectEqualStrings("", parsed.tool_requests[0].pattern);
}

test "parseModelJson accepts null decanus fields" {
    const testing = std.testing;
    const parsed = try parseModelJson(DecanusDecision, testing.allocator,
        \\{
        \\  "action": "finish",
        \\  "reasoning": "complete",
        \\  "current_goal": "hello",
        \\  "agent_call": null,
        \\  "lane": null,
        \\  "actor": null,
        \\  "objective": null,
        \\  "completion_signal": null,
        \\  "dependencies": null,
        \\  "final_response": "done",
        \\  "question": null,
        \\  "blocked_reason": null,
        \\  "tool_requests": null
        \\}
    );
    defer freeOwnedDecanusDecision(testing.allocator, parsed);

    try testing.expectEqualStrings("finish", parsed.action);
    try testing.expectEqualStrings("hello", parsed.current_goal);
    try testing.expectEqualStrings("", parsed.agent_call);
    try testing.expectEqualStrings("", parsed.lane);
    try testing.expectEqualStrings("", parsed.actor);
    try testing.expectEqual(@as(usize, 0), parsed.dependencies.len);
    try testing.expectEqualStrings("done", parsed.final_response);
    try testing.expectEqual(@as(usize, 0), parsed.tool_requests.len);
}

test "buildOllamaChatBody preserves structured output settings across stream modes" {
    const testing = std.testing;
    const provider = ProviderConfig{
        .model = "gpt-oss:20b",
        .structured_output = "json",
    };

    const streaming_body = try buildOllamaChatBody(
        testing.allocator,
        provider,
        "Return valid JSON only.",
        "{\"status\":\"ok\"}",
        true,
    );
    defer testing.allocator.free(streaming_body);

    const non_streaming_body = try buildOllamaChatBody(
        testing.allocator,
        provider,
        "Return valid JSON only.",
        "{\"status\":\"ok\"}",
        false,
    );
    defer testing.allocator.free(non_streaming_body);

    try testing.expect(std.mem.indexOf(u8, streaming_body, "\"stream\":true") != null);
    try testing.expect(std.mem.indexOf(u8, non_streaming_body, "\"stream\":false") != null);
    try testing.expect(std.mem.indexOf(u8, streaming_body, "\"think\":false") != null);
    try testing.expect(std.mem.indexOf(u8, non_streaming_body, "\"think\":false") != null);
}

test "ollamaMessageRawText converts tool calls into structured tool_request JSON" {
    const testing = std.testing;
    const raw = try ollamaMessageRawText(testing.allocator, .{
        .thinking = "Need to inspect the README.",
        .tool_calls = &.{
            .{
                .function = .{
                    .name = "repo_browser.read_file",
                    .arguments = .{
                        .path = "README.md",
                    },
                },
            },
        },
    });
    defer testing.allocator.free(raw);

    try testing.expect(std.mem.indexOf(u8, raw, "\"action\":\"tool_request\"") != null);
    try testing.expect(std.mem.indexOf(u8, raw, "\"tool\":\"read_file\"") != null);
    try testing.expect(std.mem.indexOf(u8, raw, "\"path\":\"README.md\"") != null);
}

test "toolRequestFromOllamaToolCall maps container exec ls to list_files" {
    const testing = std.testing;
    const request = try toolRequestFromOllamaToolCall(.{
        .name = "container.exec",
        .arguments = .{
            .cmd = &.{ "bash", "-lc", "ls -R" },
        },
    });
    try testing.expectEqualStrings("list_files", request.tool);
    try testing.expectEqualStrings(".", request.path);
}

test "openAIMessageRawText converts tool calls into structured tool_request JSON" {
    const testing = std.testing;
    const raw = try openAIMessageRawText(testing.allocator, .{
        .tool_calls = &.{
            .{
                .function = .{
                    .name = "repo_browser.read_file",
                    .arguments = "{\"path\":\"README.md\"}",
                },
            },
        },
    });
    defer testing.allocator.free(raw);

    try testing.expect(std.mem.indexOf(u8, raw, "\"tool\":\"read_file\"") != null);
    try testing.expect(std.mem.indexOf(u8, raw, "\"path\":\"README.md\"") != null);
}

test "listWorkspaceFiles defaults empty path and skips noisy roots" {
    const testing = std.testing;
    const result = try listWorkspaceFiles(testing.allocator, "");
    defer freeCommandResult(testing.allocator, result);

    try testing.expect(result.exit_code == 0);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "README.md") != null);
    try testing.expect(std.mem.indexOf(u8, result.stdout, ".git/") == null);
}

test "executeToolRequests mediates valid list_files execution through the runtime tool layer" {
    const testing = std.testing;
    var state = AppState{};

    const outcome = try executeToolRequests(testing.allocator, AppConfig{}, &state, .decanus, .command, &.{
        .{ .tool = "list_files" },
    }, .{});
    defer testing.allocator.free(outcome.summary);

    try testing.expect(!outcome.blocked);
    try testing.expect(std.mem.indexOf(u8, outcome.summary, "list_files (exit 0)") != null);
}

test "executeToolRequests blocks policy-denied commands with structured failure state" {
    const testing = std.testing;
    var state = AppState{};

    const outcome = try executeToolRequests(testing.allocator, AppConfig{}, &state, .decanus, .command, &.{
        .{ .tool = "run_command", .command = "git reset --hard" },
    }, .{});
    defer testing.allocator.free(outcome.summary);

    try testing.expect(outcome.blocked);
    try testing.expectEqualStrings("TOOL_POLICY_BLOCKED", state.runtime_session.last_failure.error_code);
    try testing.expectEqualStrings("run_command", state.runtime_session.last_failure.context.tool);
    try testing.expect(std.mem.indexOf(u8, outcome.summary, "blocked: run_command blocked by policy") != null);
}

test "executeToolRequests converts malformed read_file requests into structured failures" {
    const testing = std.testing;
    var state = AppState{};

    const outcome = try executeToolRequests(testing.allocator, AppConfig{}, &state, .decanus, .command, &.{
        .{ .tool = "read_file" },
    }, .{});
    defer testing.allocator.free(outcome.summary);

    try testing.expect(outcome.blocked);
    try testing.expectEqualStrings("MISSING_PATH", state.runtime_session.last_failure.error_code);
    try testing.expectEqualStrings("read_file", state.runtime_session.last_failure.context.tool);
    try testing.expect(std.mem.indexOf(u8, outcome.summary, "blocked: read_file requires a path") != null);
}

test "executeToolRequests records approval denials through the mediated write_file path" {
    const testing = std.testing;
    var state = AppState{};
    const hooks = RuntimeHooks{
        .approval_fn = testDenyApproval,
    };

    const outcome = try executeToolRequests(testing.allocator, AppConfig{}, &state, .decanus, .command, &.{
        .{ .tool = "write_file", .path = "phase5-test.txt", .content = "salve" },
    }, hooks);
    defer testing.allocator.free(outcome.summary);

    try testing.expect(outcome.blocked);
    try testing.expectEqualStrings("TOOL_DENIED", state.runtime_session.last_failure.error_code);
    try testing.expectEqualStrings("write_file", state.runtime_session.last_failure.context.tool);
    try testing.expectEqual(ApprovalStatus.denied, state.runtime_session.active_approval.status);
}

test "summarizeDecanusDecisionForUi renders compact tool request summary" {
    const testing = std.testing;
    const summary = try summarizeDecanusDecisionForUi(testing.allocator, .{
        .action = "tool_request",
        .reasoning = "Need to inspect the workspace before reading docs.",
        .current_goal = "read docs and explain the project",
        .tool_requests = &.{
            .{ .tool = "list_files" },
        },
    });
    defer testing.allocator.free(summary);

    try testing.expect(std.mem.indexOf(u8, summary, "action: tool_request") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "requested 1 runtime tool") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "- list_files .") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "\"action\"") == null);
}

test "processOllamaPendingLines emits stream chunks and preserves partial tail" {
    const testing = std.testing;
    var queue = RuntimeEventQueue{ .allocator = testing.allocator };
    defer queue.deinit();

    var pending: std.ArrayList(u8) = .empty;
    defer pending.deinit(testing.allocator);
    var full_text: std.ArrayList(u8) = .empty;
    defer full_text.deinit(testing.allocator);

    const hooks = RuntimeHooks{
        .context = &queue,
        .emit_fn = testQueueEmit,
    };

    try pending.appendSlice(testing.allocator, "{\"message\":{\"content\":\"hel\"},\"done\":false}\n{\"message\":{\"content\":\"lo\"},\"done\":false}");
    try processOllamaPendingLines(testing.allocator, &pending, &full_text, "decanus", hooks);

    try testing.expectEqualStrings("hel", full_text.items);
    try testing.expect(pending.items.len > 0);

    const first_events = try queue.drain(testing.allocator);
    defer freeRuntimeUiEvents(testing.allocator, first_events);
    try testing.expectEqual(@as(usize, 1), first_events.len);
    try testing.expectEqual(RuntimeUiEventKind.stream_chunk, first_events[0].kind);
    try testing.expectEqualStrings("hel", first_events[0].text);
}

test "processOllamaPendingLines completes buffered stream output" {
    const testing = std.testing;
    var queue = RuntimeEventQueue{ .allocator = testing.allocator };
    defer queue.deinit();

    var pending: std.ArrayList(u8) = .empty;
    defer pending.deinit(testing.allocator);
    var full_text: std.ArrayList(u8) = .empty;
    defer full_text.deinit(testing.allocator);

    const hooks = RuntimeHooks{
        .context = &queue,
        .emit_fn = testQueueEmit,
    };

    try pending.appendSlice(testing.allocator, "{\"message\":{\"content\":\"hel\"},\"done\":false}\n{\"message\":{\"content\":\"lo\"},\"done\":false}\n{\"message\":{\"content\":\"\"},\"done\":true}\n");
    try processOllamaPendingLines(testing.allocator, &pending, &full_text, "decanus", hooks);

    try testing.expectEqualStrings("hello", full_text.items);
    try testing.expectEqual(@as(usize, 0), pending.items.len);

    const events = try queue.drain(testing.allocator);
    defer freeRuntimeUiEvents(testing.allocator, events);
    try testing.expectEqual(@as(usize, 2), events.len);
    try testing.expectEqualStrings("hel", events[0].text);
    try testing.expectEqualStrings("lo", events[1].text);
}

test "CliSpinner keeps thread state on the heap" {
    const testing = std.testing;
    var spinner = try CliSpinner.initWithEnabled(testing.allocator, true);
    defer spinner.deinit();

    try testing.expect(spinner.enabled);
    try testing.expect(spinner.state != null);
    try testing.expect(spinner.thread != null);

    const hooks = spinner.hooks();
    try testing.expect(hooks.context != null);
    try testing.expectEqual(@intFromPtr(spinner.state.?), @intFromPtr(@as(*CliSpinnerState, @ptrCast(@alignCast(hooks.context.?)))));
}

test "initializeRuntimeSession upgrades the legacy loop budget and seeds context defaults" {
    const testing = std.testing;
    const config = AppConfig{};
    var state = AppState{};
    state.agent_loop.max_iterations = legacy_default_max_iterations;

    initializeRuntimeSession(testing.allocator, &state, config);

    try testing.expectEqual(@as(usize, default_max_iterations), state.agent_loop.max_iterations);
    try testing.expectEqual(@as(usize, default_context_window_tokens), state.runtime_session.context_budget.context_window_tokens);
    try testing.expectEqual(@as(usize, default_response_reserve_tokens), state.runtime_session.context_budget.response_reserve_tokens);
    try testing.expectEqual(@as(usize, default_context_window_tokens - default_response_reserve_tokens), state.runtime_session.context_budget.remaining_tokens);
}

test "resetStateForMission resets canonical phase 3 state surfaces" {
    const testing = std.testing;
    var state = AppState{};
    state.current_actor = .artifex;
    state.global_status = .waiting_on_tool;
    state.mission.final_response = "stale response";
    state.agent_loop.iteration = 9;
    state.agent_loop.last_tool_result = "stale";
    state.agent_loop.intermediate_results = &.{
        .{
            .iteration = 1,
            .actor = .decanus,
            .lane = .command,
            .kind = "runtime_tool_result",
            .summary = "stale intermediate result",
        },
    };
    state.runtime_session.status = .blocked;
    state.tasks.backend.status = .complete;

    resetStateForMission(&state, "implement phase 3");

    try testing.expectEqual(GlobalStatus.planning, state.global_status);
    try testing.expectEqual(Actor.decanus, state.current_actor);
    try testing.expectEqualStrings("implement phase 3", state.mission.initial_prompt);
    try testing.expectEqualStrings("implement phase 3", state.mission.current_goal);
    try testing.expectEqualStrings("", state.mission.final_response);
    try testing.expectEqual(LoopStatus.awaiting_initial_prompt, state.agent_loop.status);
    try testing.expectEqual(@as(usize, 0), state.agent_loop.iteration);
    try testing.expectEqual(@as(usize, 0), state.agent_loop.intermediate_results.len);
    try testing.expectEqual(RuntimeStatus.idle, state.runtime_session.status);
    try testing.expectEqual(TaskStatus.pending, state.tasks.backend.status);
}

test "approval transitions update canonical state ownership" {
    const testing = std.testing;
    var state = AppState{};

    beginApprovalRequest(&state, .decanus, .command, "run_command", "zig build test", "zig build test", "zig build test");
    try testing.expectEqual(RuntimeStatus.awaiting_approval, state.runtime_session.status);
    try testing.expectEqual(ApprovalStatus.pending, state.runtime_session.active_approval.status);
    try testing.expectEqual(ApprovalKind.shell, state.runtime_session.active_approval.kind);
    try testing.expectEqual(LoopStepKind.wait_for_approval, state.agent_loop.last_step.kind);

    resolveApprovalRequest(&state, true);
    try testing.expectEqual(ApprovalStatus.approved, state.runtime_session.active_approval.status);
    try testing.expectEqual(RuntimeStatus.running, state.runtime_session.status);
}

test "blocked transition keeps loop and runtime state aligned" {
    const testing = std.testing;
    var state = AppState{};
    state.current_actor = .decanus;

    stateManager(&state).markBlocked(.decanus, .command, "waiting on operator");

    try testing.expectEqual(GlobalStatus.waiting_on_tool, state.global_status);
    try testing.expectEqual(LoopStatus.blocked, state.agent_loop.status);
    try testing.expectEqual(RuntimeStatus.blocked, state.runtime_session.status);
    try testing.expectEqual(LoopStepKind.blocked, state.agent_loop.last_step.kind);
    try testing.expectEqualStrings("waiting on operator", state.agent_loop.last_step.summary);
}

test "runtime tool result records an explicit loop result step" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.current_actor = .decanus;
    state.global_status = .planning;
    state.agent_loop.status = .thinking;
    state.agent_loop.iteration = 2;

    try stateManager(&state).recordRuntimeToolResultStep(allocator, .decanus, .command, "read_file docs/FEATURES.md");

    try testing.expectEqual(GlobalStatus.planning, state.global_status);
    try testing.expectEqual(LoopStatus.thinking, state.agent_loop.status);
    try testing.expectEqual(LoopStepKind.result, state.agent_loop.last_step.kind);
    try testing.expectEqualStrings("read_file docs/FEATURES.md", state.agent_loop.last_step.summary);
    try testing.expectEqualStrings("read_file docs/FEATURES.md", state.agent_loop.last_tool_result);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.intermediate_results.len);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("runtime_tool_result", state.agent_loop.history[0].type);
}

test "invocation loop transitions keep shared state and history aligned" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.project_name = "Contubernium";
    state.agent_loop.iteration = 3;
    state.mission.initial_prompt = "ship phase 3";
    state.mission.current_goal = "centralize state transitions";
    state.mission.constraints = &.{"keep compatibility"};
    state.agent_loop.last_tool_result = "read_file src/main.zig";

    try stateManager(&state).prepareInvocationWithHistory(
        allocator,
        .backend,
        .faber,
        "implement state helpers",
        "return structured result",
        &.{"src/main.zig"},
        "faber::IMPLEMENT_BACKEND",
        "IMPLEMENT_BACKEND",
    );

    try testing.expectEqual(Actor.faber, state.current_actor);
    try testing.expectEqual(GlobalStatus.waiting_on_tool, state.global_status);
    try testing.expectEqual(LoopStatus.running_tool, state.agent_loop.status);
    try testing.expectEqual(LoopStepKind.invoke, state.agent_loop.last_step.kind);
    try testing.expectEqual(Actor.faber, state.agent_loop.active_tool.?);
    try testing.expectEqual(TaskStatus.in_progress, state.tasks.backend.status);
    try testing.expectEqual(InvocationStatus.ready, state.tasks.backend.invocation.status);
    try testing.expectEqualStrings("faber::IMPLEMENT_BACKEND", state.tasks.backend.invocation.agent_call);
    try testing.expectEqualStrings("IMPLEMENT_BACKEND", state.tasks.backend.invocation.action_name);
    try testing.expectEqualStrings("centralize state transitions", state.tasks.backend.invocation.memory.mission);
    try testing.expectEqualStrings("read_file src/main.zig", state.tasks.backend.invocation.memory.project);
    try testing.expectEqual(@as(usize, 1), state.tasks.backend.invocation.context.files.len);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("tool_call", state.agent_loop.history[0].type);

    try stateManager(&state).finalizeInvocationWithHistory(allocator, .backend, .faber, .{
        .status = .complete,
        .summary = "implemented state helpers",
        .changes = &.{"src/main.zig"},
    }, "");

    try testing.expectEqual(Actor.decanus, state.current_actor);
    try testing.expectEqual(GlobalStatus.planning, state.global_status);
    try testing.expectEqual(LoopStatus.thinking, state.agent_loop.status);
    try testing.expectEqual(LoopStepKind.result, state.agent_loop.last_step.kind);
    try testing.expect(state.agent_loop.active_tool == null);
    try testing.expectEqual(RuntimeStatus.idle, state.runtime_session.status);
    try testing.expectEqual(TaskStatus.complete, state.tasks.backend.status);
    try testing.expectEqual(InvocationStatus.complete, state.tasks.backend.invocation.status);
    try testing.expectEqualStrings("implemented state helpers", state.agent_loop.last_tool_result);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.intermediate_results.len);
    try testing.expectEqual(@as(usize, 2), state.agent_loop.history.len);
    try testing.expectEqualStrings("tool_result", state.agent_loop.history[1].type);
}

test "parseAgentCall extracts actor and action name" {
    const testing = std.testing;
    const parsed = parseAgentCall("architectus::CONFIGURE_SYSTEM").?;
    try testing.expectEqual(Actor.architectus, parsed.actor);
    try testing.expectEqualStrings("CONFIGURE_SYSTEM", parsed.action_name);
    try testing.expect(parsed.explicit_action);
}

test "parseAgentCall handles bare agent targets" {
    const testing = std.testing;
    const parsed = parseAgentCall("faber").?;
    try testing.expectEqual(Actor.faber, parsed.actor);
    try testing.expectEqualStrings("", parsed.action_name);
    try testing.expect(!parsed.explicit_action);
}

test "parseAgentCall rejects an empty explicit action" {
    const testing = std.testing;
    try testing.expect(parseAgentCall("artifex::") == null);
}

test "resolveAgentCallTarget resolves bare agent calls to a default action" {
    const testing = std.testing;
    const allocator = testing.allocator;
    const layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, layout);

    const resolved = try resolveAgentCallTarget(allocator, layout, "artifex");
    try testing.expectEqual(Actor.artifex, resolved.actor);
    try testing.expectEqualStrings("IMPLEMENT_INTERFACE", resolved.action_name);
    try testing.expectEqualStrings("artifex", resolved.agent_call);
}

test "resolveAgentCallTarget resolves explicit agent actions" {
    const testing = std.testing;
    const allocator = testing.allocator;
    const layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, layout);

    const resolved = try resolveAgentCallTarget(allocator, layout, "artifex::WIRE_USER_FLOW");
    try testing.expectEqual(Actor.artifex, resolved.actor);
    try testing.expectEqualStrings("WIRE_USER_FLOW", resolved.action_name);
    try testing.expectEqualStrings("artifex::WIRE_USER_FLOW", resolved.agent_call);
}

test "resolveAgentCallTarget rejects invalid action casing" {
    const testing = std.testing;
    const allocator = testing.allocator;
    const layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, layout);

    try testing.expectError(error.InvalidActionName, resolveAgentCallTarget(allocator, layout, "artifex::wire_user_flow"));
}

test "mission completion records the finish step and history" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.current_actor = .decanus;
    state.agent_loop.iteration = 5;

    try stateManager(&state).completeMissionWithHistory(allocator, .decanus, .command, "phase 4 complete");

    try testing.expectEqual(GlobalStatus.complete, state.global_status);
    try testing.expectEqual(LoopStatus.complete, state.agent_loop.status);
    try testing.expectEqual(RuntimeStatus.complete, state.runtime_session.status);
    try testing.expectEqual(LoopStepKind.finish, state.agent_loop.last_step.kind);
    try testing.expectEqualStrings("phase 4 complete", state.mission.final_response);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("finish", state.agent_loop.history[0].type);
}

test "intermediate results are recorded canonically in state" {
    const testing = std.testing;
    var state = AppState{};
    state.agent_loop.iteration = 4;
    defer if (state.agent_loop.intermediate_results.len > 0) testing.allocator.free(state.agent_loop.intermediate_results);

    try stateManager(&state).appendIntermediateResult(testing.allocator, "runtime_tool_result", .decanus, .command, "read_file docs/FEATURES.md");
    try stateManager(&state).appendIntermediateResult(testing.allocator, "invocation_result", .faber, .backend, "state manager complete");

    try testing.expectEqual(@as(usize, 2), state.agent_loop.intermediate_results.len);
    try testing.expectEqualStrings("runtime_tool_result", state.agent_loop.intermediate_results[0].kind);
    try testing.expectEqualStrings("read_file docs/FEATURES.md", state.agent_loop.intermediate_results[0].summary);
    try testing.expectEqual(Actor.faber, state.agent_loop.intermediate_results[1].actor);
    try testing.expectEqual(Lane.backend, state.agent_loop.intermediate_results[1].lane);
    try testing.expectEqualStrings("state manager complete", state.agent_loop.intermediate_results[1].summary);
}

test "loadRuntimeMemoryLayer truncates oversized external memory content" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    var file = try tmp.dir.createFile("project.md", .{ .truncate = true });
    defer file.close();
    try file.writeAll("Architecture:\n0123456789012345678901234567890123456789");

    const layer = try loadRuntimeMemoryLayer(testing.allocator, .{
        .kind = "project",
        .path = "project.md",
        .max_chars = 24,
    });
    defer layer.deinit(testing.allocator);

    try testing.expectEqualStrings("project", layer.kind);
    try testing.expect(layer.truncated);
    try testing.expect(layer.source_chars > 24);
    try testing.expect(std.mem.indexOf(u8, layer.content, "...[truncated]...") != null);
}

test "buildDecanusUserPrompt includes project context and memory layers" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.mission.initial_prompt = "complete phase 7";
    state.mission.current_goal = "hook memory layers into the runtime";

    const prompt = try buildDecanusUserPrompt(allocator, AppConfig{}, &state, .{
        .architecture = .{
            .kind = "architecture",
            .path = ".contubernium/ARCHITECTURE.md",
            .content = "System structure lives here.",
            .source_chars = 26,
        },
        .plan = .{
            .kind = "plan",
            .path = ".contubernium/PLAN.md",
            .content = "Current execution order lives here.",
            .source_chars = 35,
        },
        .project_context = .{
            .kind = "project_context",
            .path = ".contubernium/PROJECT_CONTEXT.md",
            .content = "Goals and constraints live here.",
            .source_chars = 32,
        },
        .project = .{
            .kind = "project",
            .path = ".contubernium/project.md",
            .content = "Architecture decisions live here.",
            .source_chars = 32,
        },
        .global = .{
            .kind = "global",
            .path = ".contubernium/global.md",
            .content = "Reusable strategies live here.",
            .source_chars = 30,
        },
    });

    try testing.expect(std.mem.indexOf(u8, prompt, "Architecture file: .contubernium/ARCHITECTURE.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "System structure lives here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Project memory file: .contubernium/project.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Architecture decisions live here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Global memory file: .contubernium/global.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Reusable strategies live here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "faber -> lane=backend") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Valid lane values: backend, frontend, systems, qa, research, brand, media, docs, bulk_ops") != null);
}

test "buildPromptWithContextBudget blocks when a required memory layer is missing" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    var architecture_file = try tmp.dir.createFile("ARCHITECTURE.md", .{ .truncate = true });
    defer architecture_file.close();
    try architecture_file.writeAll("Architecture");

    var plan_file = try tmp.dir.createFile("PLAN.md", .{ .truncate = true });
    defer plan_file.close();
    try plan_file.writeAll("Plan");

    var project_context_file = try tmp.dir.createFile("PROJECT_CONTEXT.md", .{ .truncate = true });
    defer project_context_file.close();
    try project_context_file.writeAll("Project context");

    var project_file = try tmp.dir.createFile("project.md", .{ .truncate = true });
    defer project_file.close();
    try project_file.writeAll("Project memory");

    var state = AppState{};
    state.current_actor = .decanus;
    state.mission.initial_prompt = "complete phase 7";
    state.mission.current_goal = "hook memory";

    const config = AppConfig{
        .paths = .{
            .architecture_file = "ARCHITECTURE.md",
            .plan_file = "PLAN.md",
            .project_context_file = "PROJECT_CONTEXT.md",
            .project_memory_file = "project.md",
            .global_memory_file = "global.md",
        },
    };

    try testing.expectError(
        error.MemoryLoadBlocked,
        buildPromptWithContextBudget(allocator, config, &state, .{}, "system prompt", .decanus, ""),
    );
    try testing.expectEqualStrings("MEMORY_LAYER_MISSING", state.runtime_session.last_failure.error_code);
    try testing.expectEqualStrings("global.md", state.runtime_session.last_failure.context.target);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("memory_load_blocked", state.agent_loop.history[0].type);
}

test "scaffoldProject creates canonical runtime and context assets" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    try scaffoldProject(testing.allocator);

    try testing.expect(pathExists(".contubernium/state.json"));
    try testing.expect(pathExists(".contubernium/config.json"));
    try testing.expect(pathExists(".contubernium/ARCHITECTURE.md"));
    try testing.expect(pathExists(".contubernium/PLAN.md"));
    try testing.expect(pathExists(".contubernium/PROJECT_CONTEXT.md"));
    try testing.expect(pathExists(".contubernium/project.md"));
    try testing.expect(pathExists(".contubernium/global.md"));
    try testing.expect(!pathExists(".contubernium/prompts"));
    try testing.expect(!pathExists(".agents"));
}

test "estimatePromptBudget reserves response headroom" {
    const testing = std.testing;
    const config = ContextConfig{
        .estimated_context_window_tokens = 1200,
        .response_reserve_tokens = 200,
    };

    const estimate = estimatePromptBudget(config, "system prompt", "user prompt");
    try testing.expectEqual(@as(usize, 1000), estimate.usable_prompt_tokens);
    try testing.expect(estimate.prompt_tokens > 0);
    try testing.expect(estimate.remaining_tokens < estimate.usable_prompt_tokens);
}

test "recordRuntimeFailure preserves structured and legacy error surfaces" {
    const testing = std.testing;
    var state = AppState{};
    state.runtime_session.provider = "ollama-native";
    state.runtime_session.model = "qwen2.5-coder:7b";
    state.runtime_session.current_turn_id = "turn-42";
    state.agent_loop.iteration = 4;

    const failure = buildRuntimeFailure(&state, .decanus, .command, "TOOL_TIMEOUT", "Tool execution exceeded 5s", .{
        .tool = "read_file",
        .detail = "timeout while reading README.md",
    });
    recordRuntimeFailure(&state, failure);

    try testing.expectEqualStrings("Tool execution exceeded 5s", state.runtime_session.last_error);
    try testing.expectEqualStrings("TOOL_TIMEOUT", state.runtime_session.last_failure.error_code);
    try testing.expectEqualStrings("Tool execution exceeded 5s", state.runtime_session.last_failure.message);
    try testing.expectEqualStrings("decanus", state.runtime_session.last_failure.context.actor);
    try testing.expectEqualStrings("command", state.runtime_session.last_failure.context.lane);
    try testing.expectEqualStrings("read_file", state.runtime_session.last_failure.context.tool);
    try testing.expectEqualStrings("turn-42", state.runtime_session.last_failure.context.turn_id);
    try testing.expectEqual(@as(usize, 4), state.runtime_session.last_failure.context.iteration);
}

test "runtime run log stores structured events" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const root = try tmp.dir.realpathAlloc(scratch, ".");

    const path = try std.fs.path.join(scratch, &.{ root, "run-log.json" });

    try saveRuntimeRunLog(scratch, path, .{
        .run_id = "run-1",
        .command = "mission",
        .created_at = "1",
        .updated_at = "1",
        .project_name = "Contubernium",
        .provider = "ollama-native",
        .model = "qwen2.5-coder:7b",
        .approval_mode = "guarded",
        .mission_prompt = "implement phase 1 logging",
        .events = &.{},
    });

    try appendRuntimeRunLogEvent(scratch, path, .{
        .timestamp = "2",
        .iteration = 1,
        .turn_id = "turn-1",
        .actor = "decanus",
        .lane = "command",
        .action = "turn_started",
        .status = "running",
        .summary = "phase 1 logging",
    });

    const loaded = try loadRuntimeRunLog(scratch, path);
    try testing.expectEqualStrings("run-1", loaded.run_id);
    try testing.expectEqual(@as(usize, 1), loaded.events.len);
    try testing.expectEqualStrings("turn_started", loaded.events[0].action);
    try testing.expectEqualStrings("running", loaded.events[0].status);
    try testing.expectEqualStrings("phase 1 logging", loaded.events[0].summary);
}

test "condenseHistoryForContext replaces older entries with a retained digest" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    var index: usize = 0;
    while (index < 6) : (index += 1) {
        try appendHistory(allocator, &state, .{
            .iteration = index + 1,
            .type = "tool_result",
            .actor = "artifex",
            .lane = "frontend",
            .summary = try std.fmt.allocPrint(allocator, "completed slice {d}", .{index + 1}),
            .artifacts = &.{},
            .timestamp = "1",
        });
    }

    const condensed = try condenseHistoryForContext(allocator, ContextConfig{
        .condensed_keep_recent_events = 2,
        .max_condensed_summary_chars = 600,
    }, &state);

    try testing.expect(condensed);
    try testing.expectEqual(@as(usize, 3), state.agent_loop.history.len);
    try testing.expectEqualStrings("condensed_context", state.agent_loop.history[0].type);
    try testing.expect(std.mem.indexOf(u8, state.agent_loop.history[0].summary, "milestones:") != null);
    try testing.expectEqual(@as(usize, 1), state.runtime_session.context_budget.condensation_count);
    try testing.expectEqual(@as(usize, 4), state.runtime_session.context_budget.condensed_history_events);
}

test "snapshotFromState uses config and loop state" {
    const testing = std.testing;
    const config = AppConfig{};
    var state = AppState{};
    state.current_actor = .artifex;
    state.agent_loop.active_tool = .artifex;
    state.agent_loop.iteration = 4;
    state.agent_loop.max_iterations = 24;
    state.agent_loop.last_tool_result = "read_file README.md";
    state.runtime_session.status = .running;
    state.runtime_session.model = "custom-model";
    state.runtime_session.context_budget = .{
        .estimated_prompt_chars = 1200,
        .estimated_prompt_tokens = 300,
        .context_window_tokens = 32768,
        .response_reserve_tokens = 4096,
        .remaining_tokens = 28372,
        .used_percent = 10,
        .condensation_count = 1,
        .condensed_history_events = 5,
        .last_condensed_iteration = 3,
    };

    const snapshot = snapshotFromState(config, state, "Contubernium");
    try testing.expectEqualStrings("Contubernium", snapshot.project_name);
    try testing.expectEqualStrings("custom-model", snapshot.model);
    try testing.expectEqualStrings("frontend", snapshot.active_lane);
    try testing.expectEqualStrings("read_file README.md", snapshot.last_tool_result);
    try testing.expectEqual(@as(usize, 4), snapshot.iteration);
    try testing.expectEqual(@as(usize, 24), snapshot.max_iterations);
    try testing.expectEqual(@as(usize, 300), snapshot.estimated_prompt_tokens);
    try testing.expectEqual(@as(usize, 28372), snapshot.remaining_context_tokens);
}
test "toneForOutcome treats interrupted runs as danger" {
    const testing = std.testing;
    var state = AppState{};
    state.runtime_session.status = .interrupted;
    try testing.expectEqual(ChatTone.danger, toneForOutcome(state));
}

fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stdout().deprecatedWriter().print(fmt, args);
}

fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stderr().deprecatedWriter().print(fmt, args);
}
