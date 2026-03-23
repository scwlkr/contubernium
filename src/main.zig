const std = @import("std");

const max_file_bytes = 16 * 1024 * 1024;

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
    state_file: []const u8 = "contubernium_state.json",
    prompts_dir: []const u8 = "prompts",
    logs_dir: []const u8 = ".contubernium/logs",
};

const PolicyConfig = struct {
    approval_mode: []const u8 = "guarded",
    allow_read_tools_without_confirmation: bool = true,
    allow_workspace_writes_without_confirmation: bool = false,
    allow_shell_without_confirmation: bool = false,
    blocked_command_patterns: [][]const u8 = &.{
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
};

const AppState = struct {
    project_name: []const u8 = "UNASSIGNED",
    global_status: []const u8 = "idle",
    current_actor: []const u8 = "decanus",
    mission: Mission = .{},
    agent_loop: AgentLoop = .{},
    runtime_session: RuntimeSession = .{},
    agent_tools: AgentTools = .{},
    tasks: Tasks = .{},
};

const Mission = struct {
    initial_prompt: []const u8 = "",
    current_goal: []const u8 = "",
    success_criteria: [][]const u8 = &.{},
    constraints: [][]const u8 = &.{},
    final_response: []const u8 = "",
};

const AgentLoop = struct {
    status: []const u8 = "awaiting_initial_prompt",
    iteration: usize = 0,
    max_iterations: usize = 12,
    active_tool: []const u8 = "",
    last_decision: []const u8 = "",
    last_tool_result: []const u8 = "",
    history: []HistoryEntry = &.{},
};

const RuntimeSession = struct {
    status: []const u8 = "idle",
    provider: []const u8 = "",
    model: []const u8 = "",
    endpoint: []const u8 = "",
    approval_mode: []const u8 = "guarded",
    current_turn_id: []const u8 = "",
    last_health_check: []const u8 = "",
    last_error: []const u8 = "",
    active_log_path: []const u8 = "",
    last_actor: []const u8 = "",
    repair_attempts: usize = 0,
};

const HistoryEntry = struct {
    iteration: usize = 0,
    type: []const u8 = "",
    actor: []const u8 = "",
    lane: []const u8 = "",
    summary: []const u8 = "",
    artifacts: [][]const u8 = &.{},
    timestamp: []const u8 = "",
};

const AgentTool = struct {
    lane: []const u8 = "",
    purpose: []const u8 = "",
    use_when: [][]const u8 = &.{},
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

const Invocation = struct {
    status: []const u8 = "idle",
    requested_by: []const u8 = "decanus",
    iteration: usize = 0,
    objective: []const u8 = "",
    completion_signal: []const u8 = "",
    dependencies: [][]const u8 = &.{},
    result_summary: []const u8 = "",
    return_to: []const u8 = "decanus",
};

const TaskLane = struct {
    status: []const u8 = "pending",
    assigned_to: []const u8 = "",
    description: []const u8 = "",
    artifacts: [][]const u8 = &.{},
    invocation: Invocation = .{},
};

const Tasks = struct {
    backend: TaskLane = .{ .assigned_to = "faber" },
    frontend: TaskLane = .{ .assigned_to = "artifex" },
    systems: TaskLane = .{ .assigned_to = "architectus" },
    qa: TaskLane = .{ .assigned_to = "tesserarius" },
    research: TaskLane = .{ .assigned_to = "explorator" },
    brand: TaskLane = .{ .assigned_to = "signifer" },
    media: TaskLane = .{ .assigned_to = "praeco" },
    docs: TaskLane = .{ .assigned_to = "calo" },
    bulk_ops: TaskLane = .{ .assigned_to = "mulus" },
};

const ToolRequest = struct {
    tool: []const u8 = "",
    description: []const u8 = "",
    path: []const u8 = "",
    pattern: []const u8 = "",
    command: []const u8 = "",
    content: []const u8 = "",
};

const DecanusDecision = struct {
    action: []const u8 = "",
    reasoning: []const u8 = "",
    current_goal: []const u8 = "",
    lane: []const u8 = "",
    actor: []const u8 = "",
    objective: []const u8 = "",
    completion_signal: []const u8 = "",
    dependencies: [][]const u8 = &.{},
    final_response: []const u8 = "",
    question: []const u8 = "",
    blocked_reason: []const u8 = "",
    tool_requests: []ToolRequest = &.{},
};

const SpecialistResult = struct {
    action: []const u8 = "",
    reasoning: []const u8 = "",
    description: []const u8 = "",
    result_summary: []const u8 = "",
    artifacts: [][]const u8 = &.{},
    follow_up_needed: []const u8 = "",
    question: []const u8 = "",
    blocked_reason: []const u8 = "",
    tool_requests: []ToolRequest = &.{},
};

const SmokeResponse = struct {
    status: []const u8 = "",
};

const ProviderResponse = struct {
    raw_text: []const u8,
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

const ToolExecutionOutcome = struct {
    blocked: bool,
    summary: []const u8,
};

const OllamaTagsResponse = struct {
    models: []OllamaModel = &.{},
};

const OllamaModel = struct {
    name: []const u8 = "",
};

const OllamaChatResponse = struct {
    message: OllamaMessage = .{},
};

const OllamaMessage = struct {
    content: []const u8 = "",
};

const OpenAIModelsResponse = struct {
    data: []OpenAIModel = &.{},
};

const OpenAIModel = struct {
    id: []const u8 = "",
};

const OpenAIChatResponse = struct {
    choices: []OpenAIChoice = &.{},
};

const OpenAIChoice = struct {
    message: OpenAIMessage = .{},
};

const OpenAIMessage = struct {
    content: []const u8 = "",
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    if (args.len < 2) {
        try printUsage();
        return;
    }

    const command = args[1];
    if (eql(command, "init")) {
        try cmdInit(allocator);
        return;
    }
    if (eql(command, "doctor")) {
        try cmdDoctor(allocator);
        return;
    }
    if (eql(command, "models")) {
        if (args.len < 3 or !eql(args[2], "list")) {
            try stderrPrint("usage: contubernium models list\n", .{});
            return error.InvalidArguments;
        }
        try cmdModelsList(allocator);
        return;
    }
    if (eql(command, "run")) {
        try cmdRun(allocator, args);
        return;
    }
    if (eql(command, "step")) {
        try cmdStep(allocator);
        return;
    }
    if (eql(command, "resume")) {
        try cmdResume(allocator);
        return;
    }

    try stderrPrint("unknown command: {s}\n", .{command});
    try printUsage();
    return error.InvalidArguments;
}

fn printUsage() !void {
    try stdoutPrint(
        \\Contubernium local runtime
        \\
        \\usage:
        \\  contubernium init
        \\  contubernium doctor
        \\  contubernium models list
        \\  contubernium run "mission prompt"
        \\  contubernium step
        \\  contubernium resume
        \\
    , .{});
}

fn cmdInit(allocator: std.mem.Allocator) !void {
    try copyFileIfMissing(allocator, "templates/contubernium_state.template.json", "contubernium_state.json");
    try copyFileIfMissing(allocator, "templates/contubernium.config.template.json", "contubernium.config.json");
    try std.fs.cwd().makePath(".contubernium/logs");
    try ensurePromptFiles("prompts");
    try stdoutPrint("initialized runtime scaffolding\n", .{});
}

fn cmdDoctor(allocator: std.mem.Allocator) !void {
    const config = try loadConfig(allocator, "contubernium.config.json");
    var state = try loadState(allocator, config.paths.state_file);

    try ensurePromptFiles(config.paths.prompts_dir);
    try stdoutPrint("prompt assets: ok\n", .{});

    const models = try providerListModels(allocator, config.provider);
    try stdoutPrint("backend reachable: ok ({s})\n", .{config.provider.type});

    if (!containsString(models, config.provider.model)) {
        try stderrPrint("configured model missing: {s}\n", .{config.provider.model});
        return error.ModelNotFound;
    }
    try stdoutPrint("configured model: ok ({s})\n", .{config.provider.model});

    const smoke_response = try providerStructuredChat(
        allocator,
        config.provider,
        "Return valid JSON only.",
        "Return exactly this JSON object and nothing else: {\"status\":\"ok\"}",
        "doctor",
    );
    const parsed = try parseJson(SmokeResponse, allocator, smoke_response.raw_text);
    if (!eql(parsed.status, "ok")) {
        try stderrPrint("structured output smoke test failed\n", .{});
        return error.StructuredOutputFailed;
    }
    try stdoutPrint("structured output smoke test: ok\n", .{});

    const now = try unixTimestampString(allocator);
    state.runtime_session.last_health_check = now;
    state.runtime_session.provider = config.provider.type;
    state.runtime_session.model = config.provider.model;
    state.runtime_session.endpoint = config.provider.base_url;
    state.runtime_session.approval_mode = config.policy.approval_mode;
    try saveState(config.paths.state_file, state);
}

fn cmdModelsList(allocator: std.mem.Allocator) !void {
    const config = try loadConfig(allocator, "contubernium.config.json");
    const models = try providerListModels(allocator, config.provider);
    for (models) |model| {
        try stdoutPrint("{s}\n", .{model});
    }
}

fn cmdRun(allocator: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len < 3) {
        try stderrPrint("usage: contubernium run \"mission prompt\"\n", .{});
        return error.InvalidArguments;
    }

    const mission_prompt = try joinArgs(allocator, args[2..]);
    const config = try loadConfig(allocator, "contubernium.config.json");
    var state = try loadState(allocator, config.paths.state_file);

    resetStateForMission(&state, mission_prompt);
    initializeRuntimeSession(allocator, &state, config);
    try saveState(config.paths.state_file, state);

    try runLoop(allocator, config, &state);
    try saveState(config.paths.state_file, state);
}

fn cmdStep(allocator: std.mem.Allocator) !void {
    const config = try loadConfig(allocator, "contubernium.config.json");
    var state = try loadState(allocator, config.paths.state_file);
    initializeRuntimeSession(allocator, &state, config);
    _ = try executeStep(allocator, config, &state);
    try saveState(config.paths.state_file, state);
}

fn cmdResume(allocator: std.mem.Allocator) !void {
    const config = try loadConfig(allocator, "contubernium.config.json");
    var state = try loadState(allocator, config.paths.state_file);
    initializeRuntimeSession(allocator, &state, config);
    try runLoop(allocator, config, &state);
    try saveState(config.paths.state_file, state);
}

fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState) !void {
    while (state.agent_loop.iteration < state.agent_loop.max_iterations) {
        const outcome = try executeStep(allocator, config, state);
        try saveState(config.paths.state_file, state.*);
        switch (outcome) {
            .advanced => {},
            .complete => {
                if (state.mission.final_response.len > 0) {
                    try stdoutPrint("{s}\n", .{state.mission.final_response});
                }
                return;
            },
            .blocked => return,
        }
    }

    state.global_status = "waiting_on_tool";
    state.agent_loop.status = "complete";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = "maximum iteration count reached";
}

fn executeStep(allocator: std.mem.Allocator, config: AppConfig, state: *AppState) !StepOutcome {
    if (state.mission.initial_prompt.len == 0) {
        try stderrPrint("mission prompt is empty; use `contubernium run`\n", .{});
        return error.MissionNotInitialized;
    }

    state.agent_loop.iteration += 1;
    state.runtime_session.status = "running";
    state.runtime_session.provider = config.provider.type;
    state.runtime_session.model = config.provider.model;
    state.runtime_session.endpoint = config.provider.base_url;
    state.runtime_session.approval_mode = config.policy.approval_mode;
    state.runtime_session.last_actor = state.current_actor;
    state.runtime_session.current_turn_id = try makeTurnId(allocator, state.current_actor, state.agent_loop.iteration);
    state.runtime_session.active_log_path = try logPathForTurn(allocator, config.paths.logs_dir, state.runtime_session.current_turn_id);

    if (eql(state.current_actor, "decanus")) {
        return try executeDecanusTurn(allocator, config, state);
    }
    return try executeSpecialistTurn(allocator, config, state);
}

fn executeDecanusTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState) !StepOutcome {
    state.global_status = "planning";
    state.agent_loop.status = "thinking";

    const system_prompt = try assembleSystemPrompt(
        allocator,
        config.paths.prompts_dir,
        "decanus",
        "shared/decanus-schema.json",
    );
    const user_prompt = try buildDecanusUserPrompt(allocator, config, state);
    try writeTurnLog(state.runtime_session.active_log_path, "system_prompt", system_prompt);
    try writeTurnLog(state.runtime_session.active_log_path, "user_prompt", user_prompt);

    const response = structuredChatWithRepair(
        allocator,
        config.provider,
        system_prompt,
        user_prompt,
        "decanus",
        config.provider.max_retries,
        DecanusDecision,
        state,
    ) catch |err| {
        const message = try std.fmt.allocPrint(allocator, "decanus turn failed: {s}", .{@errorName(err)});
        state.global_status = "waiting_on_tool";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = message;
        try writeTurnLog(state.runtime_session.active_log_path, "error", message);
        try stdoutPrint("blocked: {s}\n", .{message});
        return .blocked;
    };
    const decision = response.value;
    try writeTurnLog(state.runtime_session.active_log_path, "model_output", response.raw_text);

    if (decision.current_goal.len > 0) {
        state.mission.current_goal = decision.current_goal;
    }
    state.agent_loop.last_decision = decision.action;

    if (decision.tool_requests.len > 0 or eql(decision.action, "tool_request")) {
        const tool_result = try executeToolRequests(allocator, config, state, "decanus", "", decision.tool_requests);
        state.agent_loop.last_tool_result = tool_result.summary;
        try appendHistory(
            allocator,
            state,
            .{
                .iteration = state.agent_loop.iteration,
                .type = "runtime_tool_result",
                .actor = "decanus",
                .lane = "",
                .summary = tool_result.summary,
                .artifacts = &.{},
                .timestamp = try unixTimestampString(allocator),
            },
        );
        if (tool_result.blocked) {
            state.global_status = "waiting_on_tool";
            state.runtime_session.status = "blocked";
            return .blocked;
        }
        return .advanced;
    }

    if (eql(decision.action, "finish")) {
        state.mission.final_response = decision.final_response;
        state.global_status = "complete";
        state.agent_loop.status = "complete";
        state.runtime_session.status = "complete";
        try appendHistory(
            allocator,
            state,
            .{
                .iteration = state.agent_loop.iteration,
                .type = "finish",
                .actor = "decanus",
                .lane = "",
                .summary = decision.final_response,
                .artifacts = &.{},
                .timestamp = try unixTimestampString(allocator),
            },
        );
        return .complete;
    }

    if (eql(decision.action, "invoke_specialist")) {
        const lane = if (decision.lane.len > 0) decision.lane else laneForActor(decision.actor);
        const actor = if (decision.actor.len > 0) decision.actor else actorForLane(lane);
        var task = taskForLane(state, lane);
        task.status = "in_progress";
        task.description = decision.objective;
        task.invocation.status = "ready";
        task.invocation.requested_by = "decanus";
        task.invocation.iteration = state.agent_loop.iteration;
        task.invocation.objective = decision.objective;
        task.invocation.completion_signal = decision.completion_signal;
        task.invocation.dependencies = decision.dependencies;
        task.invocation.result_summary = "";
        task.invocation.return_to = "decanus";

        state.current_actor = actor;
        state.global_status = "waiting_on_tool";
        state.agent_loop.status = "running_tool";
        state.agent_loop.active_tool = actor;
        try appendHistory(
            allocator,
            state,
            .{
                .iteration = state.agent_loop.iteration,
                .type = "tool_call",
                .actor = "decanus",
                .lane = lane,
                .summary = decision.objective,
                .artifacts = &.{},
                .timestamp = try unixTimestampString(allocator),
            },
        );
        return .advanced;
    }

    if (eql(decision.action, "ask_user")) {
        state.global_status = "waiting_on_tool";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = decision.question;
        try stdoutPrint("user input required: {s}\n", .{decision.question});
        return .blocked;
    }

    state.global_status = "waiting_on_tool";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (decision.blocked_reason.len > 0) decision.blocked_reason else "decanus returned a blocked state";
    try stdoutPrint("blocked: {s}\n", .{state.runtime_session.last_error});
    return .blocked;
}

fn executeSpecialistTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState) !StepOutcome {
    const actor = state.current_actor;
    const lane = laneForActor(actor);
    var task = taskForLane(state, lane);
    task.invocation.status = "running";
    state.global_status = "waiting_on_tool";
    state.agent_loop.status = "running_tool";

    const schema_path = "shared/specialist-schema.json";
    const system_prompt = try assembleSystemPrompt(allocator, config.paths.prompts_dir, actor, schema_path);
    const user_prompt = try buildSpecialistUserPrompt(allocator, config, state, lane);
    try writeTurnLog(state.runtime_session.active_log_path, "system_prompt", system_prompt);
    try writeTurnLog(state.runtime_session.active_log_path, "user_prompt", user_prompt);

    const response = structuredChatWithRepair(
        allocator,
        config.provider,
        system_prompt,
        user_prompt,
        actor,
        config.provider.max_retries,
        SpecialistResult,
        state,
    ) catch |err| {
        const message = try std.fmt.allocPrint(allocator, "{s} turn failed: {s}", .{ actor, @errorName(err) });
        task.invocation.status = "blocked";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = message;
        try writeTurnLog(state.runtime_session.active_log_path, "error", message);
        try stdoutPrint("blocked: {s}\n", .{message});
        return .blocked;
    };
    const result = response.value;
    try writeTurnLog(state.runtime_session.active_log_path, "model_output", response.raw_text);

    if (result.tool_requests.len > 0 or eql(result.action, "tool_request")) {
        const tool_result = try executeToolRequests(allocator, config, state, actor, lane, result.tool_requests);
        state.agent_loop.last_tool_result = tool_result.summary;
        if (tool_result.blocked) {
            task.invocation.status = "blocked";
            state.runtime_session.status = "blocked";
            return .blocked;
        }
        task.invocation.status = "running";
        return .advanced;
    }

    if (eql(result.action, "complete")) {
        task.status = "complete";
        task.description = result.description;
        task.artifacts = result.artifacts;
        task.invocation.status = "complete";
        task.invocation.result_summary = result.result_summary;
        state.current_actor = "decanus";
        state.global_status = "planning";
        state.agent_loop.status = "thinking";
        state.agent_loop.active_tool = "";
        state.agent_loop.last_tool_result = result.result_summary;
        state.runtime_session.status = "idle";
        try appendHistory(
            allocator,
            state,
            .{
                .iteration = state.agent_loop.iteration,
                .type = "tool_result",
                .actor = actor,
                .lane = lane,
                .summary = result.result_summary,
                .artifacts = result.artifacts,
                .timestamp = try unixTimestampString(allocator),
            },
        );
        return .advanced;
    }

    if (eql(result.action, "ask_user")) {
        task.invocation.status = "blocked";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = result.question;
        try stdoutPrint("user input required: {s}\n", .{result.question});
        return .blocked;
    }

    task.invocation.status = "blocked";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (result.blocked_reason.len > 0) result.blocked_reason else "specialist returned a blocked state";
    try stdoutPrint("blocked: {s}\n", .{state.runtime_session.last_error});
    return .blocked;
}

fn executeToolRequests(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: []const u8,
    lane: []const u8,
    requests: []ToolRequest,
) !ToolExecutionOutcome {
    if (requests.len == 0) {
        return .{ .blocked = false, .summary = "no tool requests" };
    }

    var summaries = std.ArrayList([]const u8).init(allocator);
    for (requests) |request| {
        const tool_name = request.tool;
        if (tool_name.len == 0) continue;

        if (eql(tool_name, "list_files")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "list_files denied by operator");
            }
            const output = try runCommandCapture(allocator, &.{ "find", if (request.path.len > 0) request.path else ".", "-maxdepth", "3" });
            try summaries.append(try summarizeCommandResult(allocator, "list_files", output, config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "read_file")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "read_file denied by operator");
            }
            const path = if (request.path.len > 0) request.path else return error.MissingPath;
            const content = try readFileLimited(allocator, path, config.context.max_file_read_bytes);
            try summaries.append(try truncateText(allocator, try std.fmt.allocPrint(allocator, "read_file {s}\n{s}", .{ path, content }), config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "search_text")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "search_text denied by operator");
            }
            const path = if (request.path.len > 0) request.path else ".";
            const pattern = if (request.pattern.len > 0) request.pattern else return error.MissingPattern;
            const output = try searchText(allocator, pattern, path, config.context.max_search_hits);
            try summaries.append(try truncateText(allocator, try std.fmt.allocPrint(allocator, "search_text {s} in {s}\n{s}", .{ pattern, path, output }), config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "run_command")) {
            if (commandIsBlocked(config.policy.blocked_command_patterns, request.command)) {
                return try blockedToolOutcome(allocator, state, "run_command blocked by policy");
            }
            if (!config.policy.allow_shell_without_confirmation and !try confirmTool(allocator, tool_name, request.command)) {
                return try blockedToolOutcome(allocator, state, "run_command denied by operator");
            }
            const output = try runShellCommand(allocator, request.command);
            try summaries.append(try summarizeCommandResult(allocator, "run_command", output, config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "write_file")) {
            const path = if (request.path.len > 0) request.path else return error.MissingPath;
            if (!pathIsSafeForWrite(path)) {
                return try blockedToolOutcome(allocator, state, "write_file path outside workspace policy");
            }
            if (!config.policy.allow_workspace_writes_without_confirmation and !try confirmTool(allocator, tool_name, path)) {
                return try blockedToolOutcome(allocator, state, "write_file denied by operator");
            }
            try writeFile(path, request.content);
            try summaries.append(try std.fmt.allocPrint(allocator, "write_file {s} ({d} bytes)", .{ path, request.content.len }));
            continue;
        }

        if (eql(tool_name, "ask_user")) {
            const question = if (request.description.len > 0) request.description else "tool requested user input";
            state.runtime_session.status = "blocked";
            state.runtime_session.last_error = question;
            try summaries.append(try std.fmt.allocPrint(allocator, "ask_user {s}", .{question}));
            try stdoutPrint("user input required: {s}\n", .{question});
            return .{
                .blocked = true,
                .summary = try joinStrings(allocator, summaries.items, "\n"),
            };
        }

        try summaries.append(try std.fmt.allocPrint(allocator, "unknown tool `{s}` requested by {s} on lane {s}", .{ tool_name, actor, lane }));
    }

    return .{
        .blocked = false,
        .summary = try joinStrings(allocator, summaries.items, "\n"),
    };
}

fn structuredChatWithRepair(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    system_prompt: []const u8,
    user_prompt: []const u8,
    actor: []const u8,
    max_retries: usize,
    comptime T: type,
    state: *AppState,
) !struct { value: T, raw_text: []const u8 } {
    var attempt: usize = 0;
    var repair_user_prompt = user_prompt;

    while (true) {
        const response = try providerStructuredChat(allocator, provider, system_prompt, repair_user_prompt, actor);
        const parsed = parseJson(T, allocator, response.raw_text) catch |err| {
            if (attempt >= max_retries) return err;
            attempt += 1;
            state.runtime_session.repair_attempts = attempt;
            state.runtime_session.last_error = "model returned invalid JSON";
            repair_user_prompt = try std.fmt.allocPrint(
                allocator,
                "{s}\n\nYour previous response was invalid JSON. Return valid JSON only. Do not use markdown fences. Preserve the intended structure.",
                .{user_prompt},
            );
            continue;
        };
        state.runtime_session.repair_attempts = attempt;
        return .{ .value = parsed, .raw_text = response.raw_text };
    }
}

fn buildDecanusUserPrompt(allocator: std.mem.Allocator, config: AppConfig, state: *const AppState) ![]const u8 {
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    const task_summary = try taskSummaryText(allocator, state.tasks);
    var buffer = std.ArrayList(u8).init(allocator);
    const writer = buffer.writer();

    try writer.print(
        \\Mission
        \\-------
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
        \\Loop state
        \\----------
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
            try joinStrings(allocator, state.mission.constraints, ", "),
            try joinStrings(allocator, state.mission.success_criteria, ", "),
            state.agent_loop.iteration,
            state.agent_loop.status,
            state.agent_loop.active_tool,
            state.agent_loop.last_decision,
            state.agent_loop.last_tool_result,
            task_summary,
            history,
        },
    );

    return try truncateText(allocator, try buffer.toOwnedSlice(), config.context.max_prompt_chars);
}

fn buildSpecialistUserPrompt(allocator: std.mem.Allocator, config: AppConfig, state: *const AppState, lane: []const u8) ![]const u8 {
    const task = taskForLaneConst(state, lane);
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    var buffer = std.ArrayList(u8).init(allocator);
    const writer = buffer.writer();

    try writer.print(
        \\Mission
        \\-------
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
        \\Objective: {s}
        \\Completion signal: {s}
        \\Dependencies: {s}
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
            task.invocation.status,
            task.invocation.objective,
            task.invocation.completion_signal,
            try joinStrings(allocator, task.invocation.dependencies, ", "),
            state.agent_loop.last_tool_result,
            history,
        },
    );

    return try truncateText(allocator, try buffer.toOwnedSlice(), config.context.max_prompt_chars);
}

fn assembleSystemPrompt(
    allocator: std.mem.Allocator,
    prompts_dir: []const u8,
    actor: []const u8,
    schema_relative_path: []const u8,
) ![]const u8 {
    const base = try readPrompt(allocator, prompts_dir, "shared/base.md");
    const policy = try readPrompt(allocator, prompts_dir, "shared/tool-policy.md");
    const role_file = try std.fmt.allocPrint(allocator, "{s}.md", .{actor});
    const role_prompt = try readPrompt(allocator, prompts_dir, role_file);
    const schema = try readPrompt(allocator, prompts_dir, schema_relative_path);
    return try std.fmt.allocPrint(
        allocator,
        "{s}\n\n{s}\n\n{s}\n\nResponse schema reference:\n{s}\n",
        .{ base, policy, role_prompt, schema },
    );
}

fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !AppConfig {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    return try parseJson(AppConfig, allocator, data);
}

fn loadState(allocator: std.mem.Allocator, path: []const u8) !AppState {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    return try parseJson(AppState, allocator, data);
}

fn saveState(path: []const u8, state: AppState) !void {
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try std.json.stringify(state, .{ .whitespace = .indent_2 }, file.writer());
}

fn ensurePromptFiles(prompts_dir: []const u8) !void {
    const required = [_][]const u8{
        "shared/base.md",
        "shared/tool-policy.md",
        "shared/decanus-schema.json",
        "shared/specialist-schema.json",
        "decanus.md",
        "faber.md",
        "artifex.md",
        "architectus.md",
        "tesserarius.md",
        "explorator.md",
        "signifer.md",
        "praeco.md",
        "calo.md",
        "mulus.md",
    };

    for (required) |relative| {
        const full_path = try std.fs.path.join(std.heap.page_allocator, &.{ prompts_dir, relative });
        defer std.heap.page_allocator.free(full_path);
        std.fs.cwd().access(full_path, .{}) catch {
            stderrPrint("missing prompt asset: {s}\n", .{full_path}) catch {};
            return error.MissingPromptAsset;
        };
    }
}

fn readPrompt(allocator: std.mem.Allocator, prompts_dir: []const u8, relative_path: []const u8) ![]const u8 {
    const full_path = try std.fs.path.join(allocator, &.{ prompts_dir, relative_path });
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

fn providerListModels(allocator: std.mem.Allocator, provider: ProviderConfig) ![][]const u8 {
    if (eql(provider.type, "ollama-native")) {
        const url = try std.fmt.allocPrint(allocator, "{s}/api/tags", .{provider.base_url});
        const result = try runCommandCapture(allocator, &.{ "curl", "-sS", "--max-time", try timeoutSeconds(allocator, provider.timeout_ms), url });
        if (result.exit_code != 0) return error.BackendUnavailable;
        const parsed = try parseJson(OllamaTagsResponse, allocator, result.stdout);
        var models = std.ArrayList([]const u8).init(allocator);
        for (parsed.models) |model| {
            try models.append(model.name);
        }
        return try models.toOwnedSlice();
    }

    if (eql(provider.type, "openai-compatible")) {
        const url = try std.fmt.allocPrint(allocator, "{s}/v1/models", .{provider.base_url});
        const result = try runCommandCapture(allocator, &.{ "curl", "-sS", "--max-time", try timeoutSeconds(allocator, provider.timeout_ms), url });
        if (result.exit_code != 0) return error.BackendUnavailable;
        const parsed = try parseJson(OpenAIModelsResponse, allocator, result.stdout);
        var models = std.ArrayList([]const u8).init(allocator);
        for (parsed.data) |model| {
            try models.append(model.id);
        }
        return try models.toOwnedSlice();
    }

    return error.UnsupportedProvider;
}

fn providerStructuredChat(
    allocator: std.mem.Allocator,
    provider: ProviderConfig,
    system_prompt: []const u8,
    user_prompt: []const u8,
    schema_kind: []const u8,
) !ProviderResponse {
    const started = std.time.milliTimestamp();

    if (eql(provider.type, "ollama-native")) {
        const messages = [_]MessagePayload{
            .{ .role = "system", .content = system_prompt },
            .{ .role = "user", .content = user_prompt },
        };
        const body = try stringifyJsonToString(
            allocator,
            OllamaChatRequest{
                .model = provider.model,
                .stream = false,
                .format = provider.structured_output,
                .messages = &messages,
            },
        );
        const url = try std.fmt.allocPrint(allocator, "{s}/api/chat", .{provider.base_url});
        const result = try runCommandCapture(
            allocator,
            &.{
                "curl",
                "-sS",
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
        return .{
            .raw_text = parsed.message.content,
            .provider_name = provider.type,
            .model_name = provider.model,
            .latency_ms = std.time.milliTimestamp() - started,
        };
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
                "-sS",
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
        if (parsed.choices.len == 0) return error.EmptyProviderResponse;
        return .{
            .raw_text = parsed.choices[0].message.content,
            .provider_name = provider.type,
            .model_name = provider.model,
            .latency_ms = std.time.milliTimestamp() - started,
        };
    }

    _ = schema_kind;
    return error.UnsupportedProvider;
}

const MessagePayload = struct {
    role: []const u8,
    content: []const u8,
};

const OllamaChatRequest = struct {
    model: []const u8,
    stream: bool,
    format: []const u8,
    messages: []const MessagePayload,
};

const OpenAIChatRequest = struct {
    model: []const u8,
    messages: []const MessagePayload,
};

fn stringifyJsonToString(allocator: std.mem.Allocator, value: anytype) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    try std.json.stringify(value, .{}, list.writer());
    return try list.toOwnedSlice();
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

fn runShellCommand(allocator: std.mem.Allocator, command: []const u8) !CommandResult {
    return try runCommandCapture(allocator, &.{ "sh", "-lc", command });
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
    return try truncateText(allocator, combined, max_chars);
}

fn searchText(allocator: std.mem.Allocator, pattern: []const u8, path: []const u8, max_hits: usize) ![]const u8 {
    const rg_result = try runCommandCapture(allocator, &.{ "rg", "-n", "--no-heading", "--max-count", try std.fmt.allocPrint(allocator, "{d}", .{max_hits}), pattern, path });
    if (rg_result.exit_code == 0 or rg_result.exit_code == 1) {
        return rg_result.stdout;
    }
    const grep_result = try runCommandCapture(allocator, &.{ "grep", "-R", "-n", pattern, path });
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
    state.global_status = "planning";
    state.current_actor = "decanus";
    state.mission.initial_prompt = mission_prompt;
    state.mission.current_goal = mission_prompt;
    state.mission.success_criteria = &.{};
    state.mission.constraints = &.{};
    state.mission.final_response = "";
    state.agent_loop = .{};
    state.runtime_session = .{};
    state.tasks = .{};
}

fn initializeRuntimeSession(allocator: std.mem.Allocator, state: *AppState, config: AppConfig) void {
    _ = allocator;
    state.runtime_session.provider = config.provider.type;
    state.runtime_session.model = config.provider.model;
    state.runtime_session.endpoint = config.provider.base_url;
    state.runtime_session.approval_mode = config.policy.approval_mode;
    if (state.runtime_session.status.len == 0 or eql(state.runtime_session.status, "idle")) {
        state.runtime_session.status = "ready";
    }
}

fn appendHistory(allocator: std.mem.Allocator, state: *AppState, entry: HistoryEntry) !void {
    var history = std.ArrayList(HistoryEntry).init(allocator);
    try history.appendSlice(state.agent_loop.history);
    try history.append(entry);
    state.agent_loop.history = try history.toOwnedSlice();
}

fn taskForLane(state: *AppState, lane: []const u8) *TaskLane {
    if (eql(lane, "backend")) return &state.tasks.backend;
    if (eql(lane, "frontend")) return &state.tasks.frontend;
    if (eql(lane, "systems")) return &state.tasks.systems;
    if (eql(lane, "qa")) return &state.tasks.qa;
    if (eql(lane, "research")) return &state.tasks.research;
    if (eql(lane, "brand")) return &state.tasks.brand;
    if (eql(lane, "media")) return &state.tasks.media;
    if (eql(lane, "docs")) return &state.tasks.docs;
    return &state.tasks.bulk_ops;
}

fn taskForLaneConst(state: *const AppState, lane: []const u8) *const TaskLane {
    if (eql(lane, "backend")) return &state.tasks.backend;
    if (eql(lane, "frontend")) return &state.tasks.frontend;
    if (eql(lane, "systems")) return &state.tasks.systems;
    if (eql(lane, "qa")) return &state.tasks.qa;
    if (eql(lane, "research")) return &state.tasks.research;
    if (eql(lane, "brand")) return &state.tasks.brand;
    if (eql(lane, "media")) return &state.tasks.media;
    if (eql(lane, "docs")) return &state.tasks.docs;
    return &state.tasks.bulk_ops;
}

fn laneForActor(actor: []const u8) []const u8 {
    if (eql(actor, "faber")) return "backend";
    if (eql(actor, "artifex")) return "frontend";
    if (eql(actor, "architectus")) return "systems";
    if (eql(actor, "tesserarius")) return "qa";
    if (eql(actor, "explorator")) return "research";
    if (eql(actor, "signifer")) return "brand";
    if (eql(actor, "praeco")) return "media";
    if (eql(actor, "calo")) return "docs";
    return "bulk_ops";
}

fn actorForLane(lane: []const u8) []const u8 {
    if (eql(lane, "backend")) return "faber";
    if (eql(lane, "frontend")) return "artifex";
    if (eql(lane, "systems")) return "architectus";
    if (eql(lane, "qa")) return "tesserarius";
    if (eql(lane, "research")) return "explorator";
    if (eql(lane, "brand")) return "signifer";
    if (eql(lane, "media")) return "praeco";
    if (eql(lane, "docs")) return "calo";
    return "mulus";
}

fn taskSummaryText(allocator: std.mem.Allocator, tasks: Tasks) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "backend={s}, frontend={s}, systems={s}, qa={s}, research={s}, brand={s}, media={s}, docs={s}, bulk_ops={s}",
        .{
            tasks.backend.status,
            tasks.frontend.status,
            tasks.systems.status,
            tasks.qa.status,
            tasks.research.status,
            tasks.brand.status,
            tasks.media.status,
            tasks.docs.status,
            tasks.bulk_ops.status,
        },
    );
}

fn recentHistoryText(allocator: std.mem.Allocator, history: []const HistoryEntry, max_events: usize) ![]const u8 {
    if (history.len == 0) return "none";
    const start = if (history.len > max_events) history.len - max_events else 0;
    var lines = std.ArrayList([]const u8).init(allocator);
    for (history[start..]) |entry| {
        try lines.append(try std.fmt.allocPrint(
            allocator,
            "#{d} {s} actor={s} lane={s} summary={s}",
            .{ entry.iteration, entry.type, entry.actor, entry.lane, entry.summary },
        ));
    }
    return try joinStrings(allocator, lines.items, "\n");
}

fn blockedToolOutcome(allocator: std.mem.Allocator, state: *AppState, reason: []const u8) !ToolExecutionOutcome {
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = reason;
    try stdoutPrint("blocked: {s}\n", .{reason});
    return .{
        .blocked = true,
        .summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{reason}),
    };
}

fn confirmTool(allocator: std.mem.Allocator, tool_name: []const u8, detail: []const u8) !bool {
    try stdoutPrint("allow {s}? {s} [y/N]: ", .{ tool_name, detail });
    const input = try std.io.getStdIn().reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
    if (input == null) return false;
    return eql(trimAscii(input.?), "y") or eql(trimAscii(input.?), "yes");
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

fn pathIsSafeForWrite(path: []const u8) bool {
    if (std.fs.path.isAbsolute(path)) return false;
    if (eql(path, "..")) return false;
    if (std.mem.startsWith(u8, path, "../")) return false;
    if (std.mem.indexOf(u8, path, "/../") != null) return false;
    return true;
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

fn makeTurnId(allocator: std.mem.Allocator, actor: []const u8, iteration: usize) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{d}-{d}-{s}", .{ std.time.timestamp(), iteration, actor });
}

fn logPathForTurn(allocator: std.mem.Allocator, logs_dir: []const u8, turn_id: []const u8) ![]const u8 {
    try std.fs.cwd().makePath(logs_dir);
    return try std.fmt.allocPrint(allocator, "{s}/{s}.log", .{ logs_dir, turn_id });
}

fn writeTurnLog(path: []const u8, section: []const u8, content: []const u8) !void {
    var file = try std.fs.cwd().createFile(path, .{ .truncate = false });
    defer file.close();
    try file.seekFromEnd(0);
    try file.writer().print("[{s}]\n{s}\n\n", .{ section, content });
}

fn truncateText(allocator: std.mem.Allocator, text: []const u8, max_chars: usize) ![]const u8 {
    if (text.len <= max_chars) return text;
    return try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{text[0..max_chars]});
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

fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.io.getStdOut().writer().print(fmt, args);
}

fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.io.getStdErr().writer().print(fmt, args);
}
