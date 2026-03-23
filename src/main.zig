const std = @import("std");
const embedded = @import("embedded_assets.zig");

const max_file_bytes = 16 * 1024 * 1024;
const runtime_dir_name = ".contubernium";
const default_state_path = ".contubernium/state.json";
const default_config_path = ".contubernium/config.json";
const default_prompts_dir = ".contubernium/prompts";
const default_logs_dir = ".contubernium/logs";

const EmbeddedAsset = struct {
    relative_path: []const u8,
    content: []const u8,
};

const embedded_assets = [_]EmbeddedAsset{
    .{ .relative_path = "state.json", .content = embedded.state_json },
    .{ .relative_path = "config.json", .content = embedded.config_json },
    .{ .relative_path = "prompts/shared/base.md", .content = embedded.base_prompt },
    .{ .relative_path = "prompts/shared/tool-policy.md", .content = embedded.tool_policy_prompt },
    .{ .relative_path = "prompts/shared/decanus-schema.json", .content = embedded.decanus_schema },
    .{ .relative_path = "prompts/shared/specialist-schema.json", .content = embedded.specialist_schema },
    .{ .relative_path = "prompts/decanus.md", .content = embedded.decanus_prompt },
    .{ .relative_path = "prompts/faber.md", .content = embedded.faber_prompt },
    .{ .relative_path = "prompts/artifex.md", .content = embedded.artifex_prompt },
    .{ .relative_path = "prompts/architectus.md", .content = embedded.architectus_prompt },
    .{ .relative_path = "prompts/tesserarius.md", .content = embedded.tesserarius_prompt },
    .{ .relative_path = "prompts/explorator.md", .content = embedded.explorator_prompt },
    .{ .relative_path = "prompts/signifer.md", .content = embedded.signifer_prompt },
    .{ .relative_path = "prompts/praeco.md", .content = embedded.praeco_prompt },
    .{ .relative_path = "prompts/calo.md", .content = embedded.calo_prompt },
    .{ .relative_path = "prompts/mulus.md", .content = embedded.mulus_prompt },
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
    prompts_dir: []const u8 = default_prompts_dir,
    logs_dir: []const u8 = default_logs_dir,
};

const PolicyConfig = struct {
    approval_mode: []const u8 = "guarded",
    allow_read_tools_without_confirmation: bool = true,
    allow_workspace_writes_without_confirmation: bool = false,
    allow_shell_without_confirmation: bool = false,
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
    success_criteria: []const []const u8 = &.{},
    constraints: []const []const u8 = &.{},
    final_response: []const u8 = "",
};

const AgentLoop = struct {
    status: []const u8 = "awaiting_initial_prompt",
    iteration: usize = 0,
    max_iterations: usize = 12,
    active_tool: []const u8 = "",
    last_decision: []const u8 = "",
    last_tool_result: []const u8 = "",
    history: []const HistoryEntry = &.{},
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
    artifacts: []const []const u8 = &.{},
    timestamp: []const u8 = "",
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

const Invocation = struct {
    status: []const u8 = "idle",
    requested_by: []const u8 = "decanus",
    iteration: usize = 0,
    objective: []const u8 = "",
    completion_signal: []const u8 = "",
    dependencies: []const []const u8 = &.{},
    result_summary: []const u8 = "",
    return_to: []const u8 = "decanus",
};

const TaskLane = struct {
    status: []const u8 = "pending",
    assigned_to: []const u8 = "",
    description: []const u8 = "",
    artifacts: []const []const u8 = &.{},
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
    dependencies: []const []const u8 = &.{},
    final_response: []const u8 = "",
    question: []const u8 = "",
    blocked_reason: []const u8 = "",
    tool_requests: []const ToolRequest = &.{},
};

const SpecialistResult = struct {
    action: []const u8 = "",
    reasoning: []const u8 = "",
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

const ToolExecutionOutcome = struct {
    blocked: bool,
    summary: []const u8,
};

const TuiEvent = struct {
    tone: []const u8 = "info",
    text: []const u8 = "",
};

const TuiSession = struct {
    events: std.ArrayList(TuiEvent) = .empty,
    cached_models: []const []const u8 = &.{},
    last_model_error: []const u8 = "",
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

const OllamaMessage = struct {
    content: []const u8 = "",
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
};

const OpenAIErrorEnvelope = struct {
    message: []const u8 = "",
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    runMain(allocator, args) catch |err| {
        try stderrPrint("{s}\n", .{try friendlyRuntimeError(allocator, err)});
        std.process.exit(1);
    };
}

fn runMain(allocator: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len < 2) {
        try cmdUi(allocator);
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
    if (eql(command, "ui") or eql(command, "chat")) {
        try cmdUi(allocator);
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
        \\  contubernium ui
        \\
    , .{});
}

fn cmdInit(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try stdoutPrint("initialized project runtime in {s}\n", .{runtime_dir_name});
    if (shouldLaunchInteractiveUi()) {
        try stdoutPrint("starting interactive mode\n", .{});
        try interactiveUiLoop(allocator);
    }
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

fn cmdRun(allocator: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len < 3) {
        try stderrPrint("usage: contubernium run \"mission prompt\"\n", .{});
        return error.InvalidArguments;
    }

    const mission_prompt = try joinArgs(allocator, args[2..]);
    try runMission(allocator, mission_prompt);
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    try stdoutPrint("{s}\n", .{try missionOutcomeSummary(allocator, state)});
}

fn cmdStep(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    initializeRuntimeSession(allocator, &state, config);
    _ = try executeStep(allocator, config, &state);
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try missionOutcomeSummary(allocator, state)});
}

fn cmdResume(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    initializeRuntimeSession(allocator, &state, config);
    try runLoop(allocator, config, &state);
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try missionOutcomeSummary(allocator, state)});
}

fn cmdUi(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try interactiveUiLoop(allocator);
}

fn interactiveUiLoop(allocator: std.mem.Allocator) !void {
    var tui = TuiSession{};
    defer tui.events.deinit(allocator);

    try appendTuiEvent(
        allocator,
        &tui,
        "info",
        "Ave. Type a mission prompt to start work, or use /models and /model <n|name> to manage your local model.",
    );

    try enterTuiScreen();
    defer leaveTuiScreen() catch {};

    while (true) {
        try renderTui(allocator, &tui);
        const line = try std.fs.File.stdin().deprecatedReader().readUntilDelimiterOrEofAlloc(allocator, '\n', 16 * 1024);
        if (line == null) return;
        const input = trimAscii(line.?);
        if (input.len == 0) continue;
        const keep_running = try handleTuiInput(allocator, &tui, input);
        if (!keep_running) return;
    }
}

fn runMission(allocator: std.mem.Allocator, mission_prompt: []const u8) !void {
    try scaffoldProject(allocator);

    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);

    resetStateForMission(&state, mission_prompt);
    initializeRuntimeSession(allocator, &state, config);
    try saveState(allocator, config.paths.state_file, state);

    try runLoop(allocator, config, &state);
    try saveState(allocator, config.paths.state_file, state);
}

fn handleTuiInput(allocator: std.mem.Allocator, tui: *TuiSession, input: []const u8) !bool {
    if (input[0] != '/') {
        try appendTuiEvent(allocator, tui, "mission", try std.fmt.allocPrint(allocator, "mission> {s}", .{input}));
        runMission(allocator, input) catch |err| {
            try appendTuiEvent(allocator, tui, "error", try friendlyRuntimeError(allocator, err));
            return true;
        };
        const config = try loadProjectConfig(allocator);
        const state = try loadState(allocator, config.paths.state_file);
        try appendTuiEvent(allocator, tui, toneForState(state), try missionOutcomeSummary(allocator, state));
        return true;
    }

    var parts = std.mem.tokenizeScalar(u8, input[1..], ' ');
    const command = parts.next() orelse return true;

    if (eql(command, "exit") or eql(command, "quit")) return false;

    if (eql(command, "help")) {
        try appendTuiEvent(
            allocator,
            tui,
            "info",
            "commands: /doctor, /resume, /models, /model <n|name>, /status, /clear, /exit",
        );
        return true;
    }

    if (eql(command, "clear")) {
        tui.events.clearRetainingCapacity();
        try appendTuiEvent(allocator, tui, "info", "ledger cleared");
        return true;
    }

    if (eql(command, "doctor")) {
        const report = runDoctorCheck(allocator) catch |err| {
            try appendTuiEvent(allocator, tui, "error", try friendlyRuntimeError(allocator, err));
            return true;
        };
        try appendTuiEvent(allocator, tui, "success", report);
        return true;
    }

    if (eql(command, "resume")) {
        const config = try loadProjectConfig(allocator);
        var state = try loadState(allocator, config.paths.state_file);
        initializeRuntimeSession(allocator, &state, config);
        runLoop(allocator, config, &state) catch |err| {
            try appendTuiEvent(allocator, tui, "error", try friendlyRuntimeError(allocator, err));
            return true;
        };
        try saveState(allocator, config.paths.state_file, state);
        try appendTuiEvent(allocator, tui, toneForState(state), try missionOutcomeSummary(allocator, state));
        return true;
    }

    if (eql(command, "models")) {
        const config = try loadProjectConfig(allocator);
        const models = providerListModels(allocator, config.provider) catch |err| {
            tui.last_model_error = try friendlyRuntimeError(allocator, err);
            try appendTuiEvent(allocator, tui, "error", tui.last_model_error);
            return true;
        };
        tui.cached_models = models;
        tui.last_model_error = "";
        try appendTuiEvent(allocator, tui, "success", try formatModelRoster(allocator, models, config.provider.model));
        return true;
    }

    if (eql(command, "model")) {
        const remainder = std.mem.trim(u8, input[1 + command.len ..], " ");
        if (remainder.len == 0) {
            try appendTuiEvent(allocator, tui, "info", "usage: /model <n|name>");
            return true;
        }
        const saved = saveSelectedModel(allocator, tui, remainder) catch |err| {
            try appendTuiEvent(allocator, tui, "error", try friendlyRuntimeError(allocator, err));
            return true;
        };
        try appendTuiEvent(allocator, tui, "success", saved);
        return true;
    }

    if (eql(command, "status")) {
        const config = try loadProjectConfig(allocator);
        const state = try loadState(allocator, config.paths.state_file);
        try appendTuiEvent(allocator, tui, "info", try renderStatusBlock(allocator, config, state));
        return true;
    }

    try appendTuiEvent(allocator, tui, "error", try std.fmt.allocPrint(allocator, "unknown command: /{s}", .{command}));
    return true;
}

fn renderTui(allocator: std.mem.Allocator, tui: *const TuiSession) !void {
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    const cwd = try std.process.getCwdAlloc(allocator);
    const project_name = std.fs.path.basename(cwd);

    try stdoutPrint("\x1b[2J\x1b[H", .{});
    try stdoutPrint("\x1b[38;5;180m+======================================================================================+\x1b[0m\n", .{});
    try stdoutPrint("\x1b[1;38;5;220m| CONTUBERNIUM COMMAND TENT                                                            |\x1b[0m\n", .{});
    try stdoutPrint(
        "project: {s} | actor: {s} | status: {s} | turn: {d}\n",
        .{ project_name, state.current_actor, state.global_status, state.agent_loop.iteration },
    );
    try stdoutPrint(
        "provider: {s} | model: {s} | approval: {s}\n",
        .{ config.provider.type, config.provider.model, config.policy.approval_mode },
    );
    try stdoutPrint("\x1b[38;5;180m+-------------------------------------- STATUS ----------------------------------------+\x1b[0m\n", .{});
    try stdoutPrint("goal: {s}\n", .{if (state.mission.current_goal.len > 0) state.mission.current_goal else "idle"});
    try stdoutPrint("last error: {s}\n", .{if (state.runtime_session.last_error.len > 0) state.runtime_session.last_error else "none"});
    try stdoutPrint("last log: {s}\n", .{if (state.runtime_session.active_log_path.len > 0) state.runtime_session.active_log_path else "none"});
    try stdoutPrint("\x1b[38;5;180m+----------------------------------- MODEL ROSTER -------------------------------------+\x1b[0m\n", .{});
    if (tui.cached_models.len == 0) {
        if (tui.last_model_error.len > 0) {
            try stdoutPrint("{s}\n", .{tui.last_model_error});
        } else {
            try stdoutPrint("use /models to query the active local backend and /model <n|name> to switch.\n", .{});
        }
    } else {
        var index: usize = 0;
        while (index < tui.cached_models.len and index < 8) : (index += 1) {
            const marker = if (eql(tui.cached_models[index], config.provider.model)) "current" else "";
            try stdoutPrint("[{d}] {s} {s}\n", .{ index + 1, tui.cached_models[index], marker });
        }
    }
    try stdoutPrint("\x1b[38;5;180m+---------------------------------- LEGION LEDGER -------------------------------------+\x1b[0m\n", .{});
    try renderRecentTuiEvents(tui);
    try stdoutPrint("\x1b[38;5;180m+------------------------------------ COMMANDS ----------------------------------------+\x1b[0m\n", .{});
    try stdoutPrint("/doctor  /resume  /models  /model <n|name>  /status  /clear  /exit\n", .{});
    try stdoutPrint("\x1b[38;5;180m+======================================================================================+\x1b[0m\n", .{});
    try stdoutPrint("\x1b[1;38;5;220mPrompt>\x1b[0m ", .{});
}

fn renderRecentTuiEvents(tui: *const TuiSession) !void {
    const start = if (tui.events.items.len > 8) tui.events.items.len - 8 else 0;
    if (tui.events.items.len == 0) {
        try stdoutPrint("no events yet\n", .{});
        return;
    }
    for (tui.events.items[start..]) |event| {
        const color = if (eql(event.tone, "error"))
            "\x1b[38;5;203m"
        else if (eql(event.tone, "success"))
            "\x1b[38;5;114m"
        else if (eql(event.tone, "mission"))
            "\x1b[38;5;223m"
        else
            "\x1b[38;5;252m";
        try stdoutPrint("{s}{s}\x1b[0m\n", .{ color, event.text });
    }
}

fn appendTuiEvent(allocator: std.mem.Allocator, tui: *TuiSession, tone: []const u8, text: []const u8) !void {
    try tui.events.append(allocator, .{
        .tone = tone,
        .text = try allocator.dupe(u8, text),
    });
}

fn enterTuiScreen() !void {
    try stdoutPrint("\x1b[?1049h\x1b[2J\x1b[H", .{});
}

fn leaveTuiScreen() !void {
    try stdoutPrint("\x1b[0m\x1b[?1049l", .{});
}

fn toneForState(state: AppState) []const u8 {
    if (eql(state.global_status, "complete")) return "success";
    if (eql(state.runtime_session.status, "blocked")) return "error";
    return "info";
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

fn saveSelectedModel(allocator: std.mem.Allocator, tui: *TuiSession, selector: []const u8) ![]const u8 {
    const config_path = try resolveConfigPath(allocator);
    var config = try loadConfig(allocator, config_path);
    const model_name = try resolveModelSelection(allocator, tui, selector);
    config.provider.model = model_name;
    try saveConfig(allocator, config_path, config);

    var state = try loadState(allocator, config.paths.state_file);
    state.runtime_session.model = model_name;
    try saveState(allocator, config.paths.state_file, state);

    return try std.fmt.allocPrint(allocator, "active model set to {s}", .{model_name});
}

fn resolveModelSelection(allocator: std.mem.Allocator, tui: *TuiSession, selector: []const u8) ![]const u8 {
    if (isUnsignedDecimal(selector)) {
        if (tui.cached_models.len == 0) return error.ModelListUnavailable;
        const index = try std.fmt.parseUnsigned(usize, selector, 10);
        if (index == 0 or index > tui.cached_models.len) return error.ModelSelectionOutOfRange;
        return try allocator.dupe(u8, tui.cached_models[index - 1]);
    }
    return try allocator.dupe(u8, selector);
}

fn isUnsignedDecimal(text: []const u8) bool {
    if (text.len == 0) return false;
    for (text) |char| {
        if (char < '0' or char > '9') return false;
    }
    return true;
}

fn renderStatusBlock(allocator: std.mem.Allocator, config: AppConfig, state: AppState) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "project status\nprovider: {s}\nmodel: {s}\nactor: {s}\nglobal status: {s}\nturn: {d}\nlast error: {s}",
        .{
            config.provider.type,
            config.provider.model,
            state.current_actor,
            state.global_status,
            state.agent_loop.iteration,
            if (state.runtime_session.last_error.len > 0) state.runtime_session.last_error else "none",
        },
    );
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
    return try std.fmt.allocPrint(allocator, "runtime error: {s}", .{@errorName(err)});
}

fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState) !void {
    while (state.agent_loop.iteration < state.agent_loop.max_iterations) {
        const outcome = try executeStep(allocator, config, state);
        try saveState(allocator, config.paths.state_file, state.*);
        switch (outcome) {
            .advanced => {},
            .complete => return,
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
        return .blocked;
    }

    state.global_status = "waiting_on_tool";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (decision.blocked_reason.len > 0) decision.blocked_reason else "decanus returned a blocked state";
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
        return .blocked;
    }

    task.invocation.status = "blocked";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (result.blocked_reason.len > 0) result.blocked_reason else "specialist returned a blocked state";
    return .blocked;
}

fn executeToolRequests(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: []const u8,
    lane: []const u8,
    requests: []const ToolRequest,
) !ToolExecutionOutcome {
    if (requests.len == 0) {
        return .{ .blocked = false, .summary = "no tool requests" };
    }

    var summaries: std.ArrayList([]const u8) = .empty;
    for (requests) |request| {
        const tool_name = request.tool;
        if (tool_name.len == 0) continue;

        if (eql(tool_name, "list_files")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "list_files denied by operator");
            }
            const output = try runCommandCapture(allocator, &.{ "find", if (request.path.len > 0) request.path else ".", "-maxdepth", "3" });
            try summaries.append(allocator, try summarizeCommandResult(allocator, "list_files", output, config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "read_file")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "read_file denied by operator");
            }
            const path = if (request.path.len > 0) request.path else return error.MissingPath;
            const content = try readFileLimited(allocator, path, config.context.max_file_read_bytes);
            try summaries.append(allocator, try truncateText(allocator, try std.fmt.allocPrint(allocator, "read_file {s}\n{s}", .{ path, content }), config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "search_text")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "search_text denied by operator");
            }
            const path = if (request.path.len > 0) request.path else ".";
            const pattern = if (request.pattern.len > 0) request.pattern else return error.MissingPattern;
            const output = try searchText(allocator, pattern, path, config.context.max_search_hits);
            try summaries.append(allocator, try truncateText(allocator, try std.fmt.allocPrint(allocator, "search_text {s} in {s}\n{s}", .{ pattern, path, output }), config.context.max_tool_result_chars));
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
            try summaries.append(allocator, try summarizeCommandResult(allocator, "run_command", output, config.context.max_tool_result_chars));
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
            try summaries.append(allocator, try std.fmt.allocPrint(allocator, "write_file {s} ({d} bytes)", .{ path, request.content.len }));
            continue;
        }

        if (eql(tool_name, "ask_user")) {
            const question = if (request.description.len > 0) request.description else "tool requested user input";
            state.runtime_session.status = "blocked";
            state.runtime_session.last_error = question;
            try summaries.append(allocator, try std.fmt.allocPrint(allocator, "ask_user {s}", .{question}));
            return .{
                .blocked = true,
                .summary = try joinStrings(allocator, summaries.items, "\n"),
            };
        }

        try summaries.append(allocator, try std.fmt.allocPrint(allocator, "unknown tool `{s}` requested by {s} on lane {s}", .{ tool_name, actor, lane }));
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
        try writeTurnLog(state.runtime_session.active_log_path, "provider_transport", response.transport_text);
        const parsed = parseModelJson(T, allocator, response.raw_text) catch |err| {
            try writeTurnLog(state.runtime_session.active_log_path, "invalid_model_output", response.raw_text);
            if (attempt >= max_retries) return err;
            attempt += 1;
            state.runtime_session.repair_attempts = attempt;
            state.runtime_session.last_error = if (response.raw_text.len == 0) "model returned an empty response" else "model returned invalid JSON";
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
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

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

    return try truncateText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

fn buildSpecialistUserPrompt(allocator: std.mem.Allocator, config: AppConfig, state: *const AppState, lane: []const u8) ![]const u8 {
    const task = taskForLaneConst(state, lane);
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

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

    return try truncateText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
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

fn loadProjectConfig(allocator: std.mem.Allocator) !AppConfig {
    try scaffoldProject(allocator);
    const config_path = try resolveConfigPath(allocator);
    return try loadConfig(allocator, config_path);
}

fn loadState(allocator: std.mem.Allocator, path: []const u8) !AppState {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    return try parseJson(AppState, allocator, data);
}

fn saveState(allocator: std.mem.Allocator, path: []const u8, state: AppState) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(state, .{ .whitespace = .indent_2 })},
    );
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
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

fn runDoctorCheck(allocator: std.mem.Allocator) ![]const u8 {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);

    try ensurePromptFiles(config.paths.prompts_dir);

    const models = try providerListModels(allocator, config.provider);
    if (!containsString(models, config.provider.model)) return error.ModelNotFound;

    const smoke_response = try providerStructuredChat(
        allocator,
        config.provider,
        "Return valid JSON only.",
        "Return exactly this JSON object and nothing else: {\"status\":\"ok\"}",
        "doctor",
    );
    const parsed = try parseModelJson(SmokeResponse, allocator, smoke_response.raw_text);
    if (!eql(parsed.status, "ok")) return error.StructuredOutputFailed;

    const now = try unixTimestampString(allocator);
    state.runtime_session.last_health_check = now;
    state.runtime_session.provider = config.provider.type;
    state.runtime_session.model = config.provider.model;
    state.runtime_session.endpoint = config.provider.base_url;
    state.runtime_session.approval_mode = config.policy.approval_mode;
    state.runtime_session.last_error = "";
    try saveState(allocator, config.paths.state_file, state);

    return try std.fmt.allocPrint(
        allocator,
        "prompt assets: ok\nbackend reachable: ok ({s})\nconfigured model: ok ({s})\nstructured output smoke test: ok",
        .{ config.provider.type, config.provider.model },
    );
}

fn missionOutcomeSummary(allocator: std.mem.Allocator, state: AppState) ![]const u8 {
    if (state.mission.final_response.len > 0 and eql(state.global_status, "complete")) {
        return try std.fmt.allocPrint(allocator, "complete\n\n{s}", .{state.mission.final_response});
    }
    if (state.runtime_session.last_error.len > 0 and eql(state.runtime_session.status, "blocked")) {
        return try std.fmt.allocPrint(allocator, "blocked\n\n{s}", .{state.runtime_session.last_error});
    }
    if (state.agent_loop.active_tool.len > 0) {
        return try std.fmt.allocPrint(
            allocator,
            "in progress\n\ncurrent actor: {s}\nactive tool: {s}\niteration: {d}",
            .{ state.current_actor, state.agent_loop.active_tool, state.agent_loop.iteration },
        );
    }
    return try std.fmt.allocPrint(
        allocator,
        "status: {s}\ncurrent actor: {s}\niteration: {d}",
        .{ state.global_status, state.current_actor, state.agent_loop.iteration },
    );
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
        if (trimAscii(parsed.message.content).len == 0) return error.EmptyModelOutput;
        return .{
            .raw_text = parsed.message.content,
            .transport_text = result.stdout,
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
        if (trimAscii(parsed.choices[0].message.content).len == 0) return error.EmptyModelOutput;
        return .{
            .raw_text = parsed.choices[0].message.content,
            .transport_text = result.stdout,
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
    return try std.fmt.allocPrint(allocator, "{f}", .{std.json.fmt(value, .{})});
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
    var history: std.ArrayList(HistoryEntry) = .empty;
    try history.appendSlice(allocator, state.agent_loop.history);
    try history.append(allocator, entry);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
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

fn blockedToolOutcome(allocator: std.mem.Allocator, state: *AppState, reason: []const u8) !ToolExecutionOutcome {
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = reason;
    return .{
        .blocked = true,
        .summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{reason}),
    };
}

fn confirmTool(allocator: std.mem.Allocator, tool_name: []const u8, detail: []const u8) !bool {
    try stdoutPrint("allow {s}? {s} [y/N]: ", .{ tool_name, detail });
    const input = try std.fs.File.stdin().deprecatedReader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
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

fn scaffoldProject(allocator: std.mem.Allocator) !void {
    try std.fs.cwd().makePath(default_logs_dir);
    for (embedded_assets) |asset| {
        const destination = try runtimePath(allocator, asset.relative_path);
        try writeFileIfMissing(destination, asset.content);
    }
}

fn runtimePath(allocator: std.mem.Allocator, relative_path: []const u8) ![]const u8 {
    return try std.fs.path.join(allocator, &.{ runtime_dir_name, relative_path });
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
    if (pathExists("contubernium.config.json")) return "contubernium.config.json";
    return default_config_path;
}

fn pathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

fn shouldLaunchInteractiveUi() bool {
    return std.posix.isatty(std.posix.STDIN_FILENO) and std.posix.isatty(std.posix.STDOUT_FILENO);
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
    try file.deprecatedWriter().print("[{s}]\n{s}\n\n", .{ section, content });
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

fn parseModelJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const normalized = try normalizeModelJson(text);
    return try parseJson(T, allocator, normalized);
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

fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stdout().deprecatedWriter().print(fmt, args);
}

fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stderr().deprecatedWriter().print(fmt, args);
}
