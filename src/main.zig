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
};

const MessageKind = enum {
    user,
    agent,
    system,
    tool,
};

const TuiMessage = struct {
    kind: MessageKind = .system,
    tone: ChatTone = .info,
    actor: []const u8 = "",
    title: []const u8 = "",
    text: std.ArrayList(u8) = .empty,
    highlight: HighlightKind = .plain,
    streaming: bool = false,

    fn deinit(self: *TuiMessage, allocator: std.mem.Allocator) void {
        self.text.deinit(allocator);
    }
};

const TuiSnapshot = struct {
    project_name: []const u8 = "UNASSIGNED",
    provider_type: []const u8 = "",
    model: []const u8 = "",
    approval_mode: []const u8 = "",
    global_status: []const u8 = "idle",
    runtime_status: []const u8 = "idle",
    current_actor: []const u8 = "decanus",
    active_tool: []const u8 = "",
    active_lane: []const u8 = "",
    current_goal: []const u8 = "",
    last_error: []const u8 = "",
    last_log_path: []const u8 = "",
    iteration: usize = 0,
};

const ApprovalPrompt = struct {
    tool_name: []const u8 = "",
    detail: []const u8 = "",
};

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
    approval_mode: []const u8 = "",
    global_status: []const u8 = "",
    runtime_status: []const u8 = "",
    current_actor: []const u8 = "",
    active_tool: []const u8 = "",
    active_lane: []const u8 = "",
    current_goal: []const u8 = "",
    last_error: []const u8 = "",
    last_log_path: []const u8 = "",
    iteration: usize = 0,
};

const RuntimeEventQueue = struct {
    allocator: std.mem.Allocator,
    mutex: std.Thread.Mutex = .{},
    items: std.ArrayList(RuntimeUiEvent) = .empty,

    fn deinit(self: *RuntimeEventQueue) void {
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
        const drained = try allocator.dupe(RuntimeUiEvent, self.items.items);
        self.items.clearRetainingCapacity();
        return drained;
    }

    fn cloneEvent(self: *RuntimeEventQueue, event: RuntimeUiEvent) !RuntimeUiEvent {
        return .{
            .kind = event.kind,
            .tone = event.tone,
            .actor = try self.allocator.dupe(u8, event.actor),
            .title = try self.allocator.dupe(u8, event.title),
            .text = try self.allocator.dupe(u8, event.text),
            .highlight = event.highlight,
            .project_name = try self.allocator.dupe(u8, event.project_name),
            .provider_type = try self.allocator.dupe(u8, event.provider_type),
            .model = try self.allocator.dupe(u8, event.model),
            .approval_mode = try self.allocator.dupe(u8, event.approval_mode),
            .global_status = try self.allocator.dupe(u8, event.global_status),
            .runtime_status = try self.allocator.dupe(u8, event.runtime_status),
            .current_actor = try self.allocator.dupe(u8, event.current_actor),
            .active_tool = try self.allocator.dupe(u8, event.active_tool),
            .active_lane = try self.allocator.dupe(u8, event.active_lane),
            .current_goal = try self.allocator.dupe(u8, event.current_goal),
            .last_error = try self.allocator.dupe(u8, event.last_error),
            .last_log_path = try self.allocator.dupe(u8, event.last_log_path),
            .iteration = event.iteration,
        };
    }
};

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

const TerminalMode = struct {
    original: std.posix.termios,
    active: bool = false,

    fn enter() !TerminalMode {
        const original = try std.posix.tcgetattr(std.posix.STDIN_FILENO);
        var raw = original;
        raw.iflag.BRKINT = false;
        raw.iflag.ICRNL = false;
        raw.iflag.INPCK = false;
        raw.iflag.ISTRIP = false;
        raw.iflag.IXON = false;
        raw.oflag.OPOST = true;
        raw.cflag.CSIZE = .CS8;
        raw.lflag.ECHO = false;
        raw.lflag.ICANON = false;
        raw.lflag.IEXTEN = false;
        raw.lflag.ISIG = false;
        raw.cc[@intFromEnum(std.c.V.MIN)] = 0;
        raw.cc[@intFromEnum(std.c.V.TIME)] = 1;
        try std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, raw);
        return .{
            .original = original,
            .active = true,
        };
    }

    fn leave(self: *TerminalMode) !void {
        if (!self.active) return;
        try std.posix.tcsetattr(std.posix.STDIN_FILENO, .FLUSH, self.original);
        self.active = false;
    }
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

const TuiSession = struct {
    allocator: std.mem.Allocator,
    messages: std.ArrayList(TuiMessage) = .empty,
    input: std.ArrayList(u8) = .empty,
    cursor: usize = 0,
    scroll_offset: usize = 0,
    snapshot: TuiSnapshot = .{},
    cached_models: []const []const u8 = &.{},
    last_model_error: []const u8 = "",
    pending_approval: ?ApprovalPrompt = null,
    active_stream_actor: []const u8 = "",
    active_stream_index: ?usize = null,
    running_command: ?WorkerCommandKind = null,
    dirty: bool = true,

    fn deinit(self: *TuiSession) void {
        for (self.messages.items) |*message| {
            message.deinit(self.allocator);
        }
        self.messages.deinit(self.allocator);
        self.input.deinit(self.allocator);
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
    const allocator = std.heap.page_allocator;
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
    _ = try executeStep(allocator, config, &state, .{});
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try missionOutcomeSummary(allocator, state)});
}

fn cmdResume(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    initializeRuntimeSession(allocator, &state, config);
    try runLoop(allocator, config, &state, .{});
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint("{s}\n", .{try missionOutcomeSummary(allocator, state)});
}

fn cmdUi(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try interactiveUiLoop(allocator);
}

fn interactiveUiLoop(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    const cwd = try std.process.getCwdAlloc(allocator);

    var queue = RuntimeEventQueue{
        .allocator = allocator,
    };
    defer queue.deinit();

    var control = RuntimeControl{};
    var tui = TuiSession{
        .allocator = allocator,
    };
    defer tui.deinit();

    tui.snapshot = snapshotFromState(config, state, std.fs.path.basename(cwd));
    try appendChatMessage(
        &tui,
        .system,
        .info,
        "contubernium",
        "Command Tent",
        "Type a mission or use /resume, /doctor, /models, /model <n|name>, /status, /clear, /interrupt, /exit. Ctrl+C interrupts the active loop.",
        .plain,
    );

    var terminal = try TerminalMode.enter();
    defer terminal.leave() catch {};

    try enterTuiScreen();
    defer leaveTuiScreen() catch {};

    var worker: ?*WorkerTask = null;
    defer {
        if (worker) |task| {
            if (task.control.approval_pending) {
                submitApprovalResponse(task.control, false);
            }
            if (task.control.running.load(.seq_cst)) {
                task.control.interrupt_requested.store(true, .seq_cst);
            }
            if (task.thread) |thread| thread.join();
            allocator.destroy(task);
        }
    }

    var last_render_ms = std.time.milliTimestamp();

    while (true) {
        if (worker) |task| {
            if (!task.control.running.load(.seq_cst)) {
                if (task.thread) |thread| thread.join();
                allocator.destroy(task);
                worker = null;
                tui.running_command = null;
                tui.dirty = true;
            }
        }

        try processRuntimeEvents(allocator, &tui, &queue);

        const now_ms = std.time.milliTimestamp();
        if (tui.dirty or now_ms - last_render_ms >= 250) {
            try renderTui(allocator, &tui);
            last_render_ms = now_ms;
            tui.dirty = false;
        }

        if (!try pollInput(50)) continue;

        var input_buf: [128]u8 = undefined;
        const input_len = try std.posix.read(std.posix.STDIN_FILENO, &input_buf);
        if (input_len == 0) return;

        const keep_running = try handleInputBytes(
            allocator,
            &tui,
            &control,
            &queue,
            &worker,
            input_buf[0..input_len],
        );
        if (!keep_running) return;
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
    try saveState(allocator, config.paths.state_file, state);
    emitStateSnapshot(hooks, config, state);

    try runLoop(allocator, config, &state, hooks);
    try saveState(allocator, config.paths.state_file, state);
    emitStateSnapshot(hooks, config, state);
}

fn enterTuiScreen() !void {
    try stdoutPrint("\x1b[?1049h\x1b[2J\x1b[H\x1b[?25l", .{});
}

fn leaveTuiScreen() !void {
    try stdoutPrint("\x1b[0m\x1b[?25h\x1b[?1049l", .{});
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

fn renderStatusBlock(allocator: std.mem.Allocator, snapshot: TuiSnapshot) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "project: {s}\nprovider: {s}\nmodel: {s}\nactor: {s}\nlane: {s}\nglobal status: {s}\nruntime status: {s}\nturn: {d}\nlast error: {s}",
        .{
            snapshot.project_name,
            snapshot.provider_type,
            snapshot.model,
            snapshot.current_actor,
            snapshot.active_lane,
            snapshot.global_status,
            snapshot.runtime_status,
            snapshot.iteration,
            if (snapshot.last_error.len > 0) snapshot.last_error else "none",
        },
    );
}

const RenderLine = struct {
    text: []const u8 = "",
    tone: ChatTone = .info,
    highlight: HighlightKind = .plain,
};

const TerminalSize = struct {
    rows: usize,
    cols: usize,
};

fn snapshotFromState(config: AppConfig, state: AppState, project_name: []const u8) TuiSnapshot {
    return .{
        .project_name = project_name,
        .provider_type = config.provider.type,
        .model = if (state.runtime_session.model.len > 0) state.runtime_session.model else config.provider.model,
        .approval_mode = config.policy.approval_mode,
        .global_status = state.global_status,
        .runtime_status = state.runtime_session.status,
        .current_actor = state.current_actor,
        .active_tool = state.agent_loop.active_tool,
        .active_lane = currentLaneForState(state),
        .current_goal = state.mission.current_goal,
        .last_error = state.runtime_session.last_error,
        .last_log_path = state.runtime_session.active_log_path,
        .iteration = state.agent_loop.iteration,
    };
}

fn processRuntimeEvents(allocator: std.mem.Allocator, tui: *TuiSession, queue: *RuntimeEventQueue) !void {
    const events = try queue.drain(allocator);
    for (events) |event| {
        switch (event.kind) {
            .log => try appendChatMessage(
                tui,
                if (event.tone == .mission) .user else if (event.tone == .tool) .tool else .system,
                event.tone,
                event.actor,
                event.title,
                event.text,
                event.highlight,
            ),
            .stream_start => try beginStreamingMessage(tui, event.actor),
            .stream_chunk => try appendStreamChunk(tui, event.actor, event.text),
            .stream_finalize => try finalizeStreamingMessage(tui, event.actor, event.text, event.highlight),
            .state_snapshot => {
                tui.snapshot = .{
                    .project_name = if (event.project_name.len > 0) event.project_name else tui.snapshot.project_name,
                    .provider_type = if (event.provider_type.len > 0) event.provider_type else tui.snapshot.provider_type,
                    .model = if (event.model.len > 0) event.model else tui.snapshot.model,
                    .approval_mode = if (event.approval_mode.len > 0) event.approval_mode else tui.snapshot.approval_mode,
                    .global_status = if (event.global_status.len > 0) event.global_status else tui.snapshot.global_status,
                    .runtime_status = if (event.runtime_status.len > 0) event.runtime_status else tui.snapshot.runtime_status,
                    .current_actor = if (event.current_actor.len > 0) event.current_actor else tui.snapshot.current_actor,
                    .active_tool = event.active_tool,
                    .active_lane = if (event.active_lane.len > 0) event.active_lane else tui.snapshot.active_lane,
                    .current_goal = event.current_goal,
                    .last_error = event.last_error,
                    .last_log_path = event.last_log_path,
                    .iteration = event.iteration,
                };
                tui.dirty = true;
            },
            .approval_request => {
                tui.pending_approval = .{
                    .tool_name = event.title,
                    .detail = event.text,
                };
                try appendChatMessage(
                    tui,
                    .system,
                    .warning,
                    "approval",
                    "Approval Required",
                    try std.fmt.allocPrint(allocator, "{s}: {s}", .{ event.title, event.text }),
                    .plain,
                );
            },
            .model_roster => {
                try updateCachedModels(allocator, tui, event.text);
                tui.last_model_error = "";
                try appendChatMessage(tui, .system, .success, "models", "Model Roster", event.text, .plain);
            },
        }
    }
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

fn handleInputBytes(
    allocator: std.mem.Allocator,
    tui: *TuiSession,
    control: *RuntimeControl,
    queue: *RuntimeEventQueue,
    worker: *?*WorkerTask,
    bytes: []const u8,
) !bool {
    var index: usize = 0;
    while (index < bytes.len) {
        if (tui.pending_approval != null) {
            const keep_running = handleApprovalInput(tui, control, bytes[index]);
            tui.dirty = true;
            return keep_running;
        }

        const byte = bytes[index];
        switch (byte) {
            3 => {
                if (worker.* != null and control.running.load(.seq_cst)) {
                    control.interrupt_requested.store(true, .seq_cst);
                    submitApprovalResponse(control, false);
                    try appendChatMessage(tui, .system, .warning, "runtime", "Interrupt", "interrupt requested", .plain);
                    tui.dirty = true;
                    return true;
                }
                return false;
            },
            12 => {
                clearTuiMessages(tui);
                try appendChatMessage(tui, .system, .info, "contubernium", "Command Tent", "ledger cleared", .plain);
            },
            13, 10 => {
                const trimmed = trimAscii(tui.input.items);
                if (trimmed.len > 0) {
                    const keep_running = try handleSubmittedInput(allocator, tui, queue, control, worker, trimmed);
                    tui.input.clearRetainingCapacity();
                    tui.cursor = 0;
                    tui.dirty = true;
                    if (!keep_running) return false;
                }
            },
            127 => {
                if (tui.cursor > 0) {
                    _ = tui.input.orderedRemove(tui.cursor - 1);
                    tui.cursor -= 1;
                    tui.dirty = true;
                }
            },
            27 => {
                if (index + 1 < bytes.len and bytes[index + 1] == '[' and index + 2 < bytes.len) {
                    const final = bytes[index + 2];
                    switch (final) {
                        'A' => {
                            tui.scroll_offset +|= 3;
                            tui.dirty = true;
                            index += 2;
                        },
                        'B' => {
                            tui.scroll_offset = if (tui.scroll_offset > 3) tui.scroll_offset - 3 else 0;
                            tui.dirty = true;
                            index += 2;
                        },
                        'C' => {
                            if (tui.cursor < tui.input.items.len) tui.cursor += 1;
                            tui.dirty = true;
                            index += 2;
                        },
                        'D' => {
                            if (tui.cursor > 0) tui.cursor -= 1;
                            tui.dirty = true;
                            index += 2;
                        },
                        '5', '6' => {
                            if (index + 3 < bytes.len and bytes[index + 3] == '~') {
                                if (final == '5') {
                                    tui.scroll_offset +|= 12;
                                } else {
                                    tui.scroll_offset = if (tui.scroll_offset > 12) tui.scroll_offset - 12 else 0;
                                }
                                tui.dirty = true;
                                index += 3;
                            }
                        },
                        'H' => {
                            tui.cursor = 0;
                            tui.dirty = true;
                            index += 2;
                        },
                        'F' => {
                            tui.cursor = tui.input.items.len;
                            tui.dirty = true;
                            index += 2;
                        },
                        else => {},
                    }
                }
            },
            else => {
                if (byte >= 32 and byte != 127) {
                    try tui.input.insert(tui.allocator, tui.cursor, byte);
                    tui.cursor += 1;
                    tui.dirty = true;
                }
            },
        }
        index += 1;
    }
    return true;
}

fn handleApprovalInput(tui: *TuiSession, control: *RuntimeControl, byte: u8) bool {
    switch (byte) {
        3, 27, 'n', 'N' => submitApprovalResponse(control, false),
        'y', 'Y' => submitApprovalResponse(control, true),
        else => return true,
    }
    tui.pending_approval = null;
    return true;
}

fn handleSubmittedInput(
    allocator: std.mem.Allocator,
    tui: *TuiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
    input: []const u8,
) !bool {
    if (input[0] != '/') {
        if (worker.* != null and control.running.load(.seq_cst)) {
            try appendChatMessage(tui, .system, .danger, "runtime", "Busy", "the runtime is already executing a command", .plain);
            return true;
        }
        try appendChatMessage(tui, .user, .mission, "user", "Mission", input, .plain);
        worker.* = try startWorker(allocator, queue, control, .mission, try allocator.dupe(u8, input));
        tui.running_command = .mission;
        return true;
    }

    var parts = std.mem.tokenizeScalar(u8, input[1..], ' ');
    const command = parts.next() orelse return true;

    if (eql(command, "exit") or eql(command, "quit")) return false;

    if (eql(command, "help")) {
        try appendChatMessage(tui, .system, .info, "help", "Commands", "/doctor /resume /models /model <n|name> /status /clear /interrupt /exit", .plain);
        return true;
    }

    if (eql(command, "interrupt")) {
        if (worker.* != null and control.running.load(.seq_cst)) {
            control.interrupt_requested.store(true, .seq_cst);
            submitApprovalResponse(control, false);
            try appendChatMessage(tui, .system, .warning, "runtime", "Interrupt", "interrupt requested", .plain);
        } else {
            try appendChatMessage(tui, .system, .info, "runtime", "Interrupt", "no active command", .plain);
        }
        return true;
    }

    if (eql(command, "clear")) {
        clearTuiMessages(tui);
        try appendChatMessage(tui, .system, .info, "contubernium", "Command Tent", "ledger cleared", .plain);
        return true;
    }

    if (eql(command, "status")) {
        try appendChatMessage(tui, .system, .info, "status", "Snapshot", try renderStatusBlock(allocator, tui.snapshot), .plain);
        return true;
    }

    if (eql(command, "model")) {
        if (worker.* != null and control.running.load(.seq_cst)) {
            try appendChatMessage(tui, .system, .danger, "runtime", "Busy", "change the model after the active command finishes", .plain);
            return true;
        }
        const remainder = std.mem.trim(u8, input[1 + command.len ..], " ");
        if (remainder.len == 0) {
            try appendChatMessage(tui, .system, .info, "models", "Usage", "usage: /model <n|name>", .plain);
            return true;
        }
        const saved = saveSelectedModel(allocator, tui, remainder) catch |err| {
            try appendChatMessage(tui, .system, .danger, "models", "Model Change Failed", try friendlyRuntimeError(allocator, err), .plain);
            return true;
        };
        tui.snapshot.model = try resolveModelSelection(allocator, tui, remainder);
        try appendChatMessage(tui, .system, .success, "models", "Model Changed", saved, .plain);
        return true;
    }

    if (worker.* != null and control.running.load(.seq_cst)) {
        try appendChatMessage(tui, .system, .danger, "runtime", "Busy", "wait for the active command to finish or press Ctrl+C", .plain);
        return true;
    }

    if (eql(command, "doctor")) {
        worker.* = try startWorker(allocator, queue, control, .doctor, "");
        tui.running_command = .doctor;
        return true;
    }

    if (eql(command, "resume")) {
        worker.* = try startWorker(allocator, queue, control, .resume_run, "");
        tui.running_command = .resume_run;
        return true;
    }

    if (eql(command, "models")) {
        worker.* = try startWorker(allocator, queue, control, .models, "");
        tui.running_command = .models;
        return true;
    }

    try appendChatMessage(tui, .system, .danger, "help", "Unknown Command", try std.fmt.allocPrint(allocator, "unknown command: /{s}", .{command}), .plain);
    return true;
}

fn appendChatMessage(
    tui: *TuiSession,
    kind: MessageKind,
    tone: ChatTone,
    actor: []const u8,
    title: []const u8,
    text: []const u8,
    highlight: HighlightKind,
) !void {
    var message = TuiMessage{
        .kind = kind,
        .tone = tone,
        .actor = actor,
        .title = title,
        .highlight = highlight,
    };
    try message.text.appendSlice(tui.allocator, text);
    try tui.messages.append(tui.allocator, message);
    tui.scroll_offset = 0;
    tui.dirty = true;
}

fn clearTuiMessages(tui: *TuiSession) void {
    for (tui.messages.items) |*message| {
        message.deinit(tui.allocator);
    }
    tui.messages.clearRetainingCapacity();
    tui.active_stream_actor = "";
    tui.active_stream_index = null;
    tui.scroll_offset = 0;
    tui.dirty = true;
}

fn beginStreamingMessage(tui: *TuiSession, actor: []const u8) !void {
    const message = TuiMessage{
        .kind = .agent,
        .tone = .agent,
        .actor = actor,
        .title = actor,
        .highlight = .json,
        .streaming = true,
    };
    try tui.messages.append(tui.allocator, message);
    tui.active_stream_actor = actor;
    tui.active_stream_index = tui.messages.items.len - 1;
    tui.scroll_offset = 0;
    tui.dirty = true;
}

fn appendStreamChunk(tui: *TuiSession, actor: []const u8, text: []const u8) !void {
    if (tui.active_stream_index) |stream_index| {
        if (eql(tui.active_stream_actor, actor) and stream_index < tui.messages.items.len) {
            try tui.messages.items[stream_index].text.appendSlice(tui.allocator, text);
            tui.scroll_offset = 0;
            tui.dirty = true;
            return;
        }
    }
    try beginStreamingMessage(tui, actor);
    if (tui.active_stream_index) |stream_index| {
        try tui.messages.items[stream_index].text.appendSlice(tui.allocator, text);
    }
    tui.dirty = true;
}

fn finalizeStreamingMessage(tui: *TuiSession, actor: []const u8, text: []const u8, highlight: HighlightKind) !void {
    if (tui.active_stream_index) |stream_index| {
        if (eql(tui.active_stream_actor, actor) and stream_index < tui.messages.items.len) {
            var message = &tui.messages.items[stream_index];
            message.text.clearRetainingCapacity();
            try message.text.appendSlice(tui.allocator, text);
            message.highlight = highlight;
            message.streaming = false;
            tui.active_stream_index = null;
            tui.active_stream_actor = "";
            tui.scroll_offset = 0;
            tui.dirty = true;
            return;
        }
    }
    try appendChatMessage(tui, .agent, .agent, actor, actor, text, highlight);
}

fn updateCachedModels(allocator: std.mem.Allocator, tui: *TuiSession, text: []const u8) !void {
    var items: std.ArrayList([]const u8) = .empty;
    var lines = std.mem.tokenizeScalar(u8, text, '\n');
    while (lines.next()) |line| {
        const trimmed = trimAscii(line);
        if (trimmed.len == 0) continue;
        if (trimmed[0] == '[') {
            if (std.mem.indexOfScalar(u8, trimmed, ']')) |close_index| {
                const remainder = trimAscii(trimmed[close_index + 1 ..]);
                if (remainder.len == 0) continue;
                const current_index = std.mem.indexOf(u8, remainder, " (current)") orelse remainder.len;
                try items.append(allocator, try allocator.dupe(u8, trimAscii(remainder[0..current_index])));
                continue;
            }
        }
        try items.append(allocator, try allocator.dupe(u8, trimmed));
    }
    tui.cached_models = try items.toOwnedSlice(allocator);
    tui.dirty = true;
}

fn renderTui(allocator: std.mem.Allocator, tui: *const TuiSession) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const temp_allocator = arena.allocator();

    const size = terminalSize();
    const sidebar_width: usize = if (size.cols >= 118) 36 else 0;
    const gutter_width: usize = if (sidebar_width > 0) 3 else 0;
    const body_width = if (sidebar_width > 0 and size.cols > sidebar_width + gutter_width + 2) size.cols - sidebar_width - gutter_width else size.cols;
    const header_height: usize = 3;
    const footer_height: usize = 4;
    const chat_height: usize = if (size.rows > header_height + footer_height) size.rows - header_height - footer_height else 1;

    var chat_lines = std.ArrayList(RenderLine).empty;
    try buildChatLines(temp_allocator, tui, &chat_lines, if (body_width > 2) body_width - 2 else body_width);

    const total_chat_lines = chat_lines.items.len;
    const hidden_bottom = @min(tui.scroll_offset, if (total_chat_lines > 0) total_chat_lines - 1 else 0);
    const visible_end = total_chat_lines - hidden_bottom;
    const visible_start = if (visible_end > chat_height) visible_end - chat_height else 0;

    var side_lines = std.ArrayList(RenderLine).empty;
    if (sidebar_width > 0) {
        try buildSidebarLines(temp_allocator, tui, &side_lines, sidebar_width);
    }

    var screen = std.ArrayList(u8).empty;
    defer screen.deinit(allocator);

    const writer = screen.writer(allocator);
    try writer.writeAll("\x1b[H");

    try writeHeaderLine(writer, size.cols, " CONTUBERNIUM COMMAND TENT ", .info);
    try writeHeaderLine(
        writer,
        size.cols,
        try std.fmt.allocPrint(
            temp_allocator,
            " project {s} | actor {s} | lane {s} | global {s} | runtime {s} | turn {d} ",
            .{
                tui.snapshot.project_name,
                tui.snapshot.current_actor,
                tui.snapshot.active_lane,
                tui.snapshot.global_status,
                tui.snapshot.runtime_status,
                tui.snapshot.iteration,
            },
        ),
        .agent,
    );
    try writeHeaderLine(
        writer,
        size.cols,
        try std.fmt.allocPrint(
            temp_allocator,
            " provider {s} | model {s} | approval {s} | scroll {d} ",
            .{
                tui.snapshot.provider_type,
                tui.snapshot.model,
                tui.snapshot.approval_mode,
                tui.scroll_offset,
            },
        ),
        .info,
    );

    var body_row: usize = 0;
    while (body_row < chat_height) : (body_row += 1) {
        const chat_line = if (visible_start + body_row < visible_end) chat_lines.items[visible_start + body_row] else RenderLine{};
        if (sidebar_width > 0) {
            const side_line = if (body_row < side_lines.items.len) side_lines.items[body_row] else RenderLine{};
            try writePaddedLine(writer, chat_line, body_width);
            try writer.writeAll("\x1b[38;5;240m │ \x1b[0m");
            try writePaddedLine(writer, side_line, sidebar_width);
            try writer.writeByte('\n');
        } else {
            try writePaddedLine(writer, chat_line, body_width);
            try writer.writeByte('\n');
        }
    }

    try writeHeaderLine(writer, size.cols, " INPUT ", .warning);
    try writeFooterLine(writer, size.cols, " Enter submit | Up/Down scroll | PgUp/PgDn fast scroll | Ctrl+C interrupt/exit ");
    const prompt_width = if (size.cols > 10) size.cols - 10 else size.cols;
    const input_view = visibleInputWindow(tui.input.items, tui.cursor, prompt_width);
    try writer.writeAll("\x1b[38;5;220m mission>\x1b[0m ");
    try writePlain(writer, input_view.text, .mission, .plain);
    if (visibleLen(input_view.text) < prompt_width) {
        try writer.writeByteNTimes(' ', prompt_width - visibleLen(input_view.text));
    }
    try writer.writeAll("\n");
    const approval_text = if (tui.pending_approval) |approval|
        try std.fmt.allocPrint(temp_allocator, "approval pending: y/n for {s}", .{approval.tool_name})
    else if (tui.running_command) |command|
        try std.fmt.allocPrint(temp_allocator, "running: {s}", .{@tagName(command)})
    else
        "ready";
    try writeFooterLine(writer, size.cols, approval_text);

    const cursor_row = header_height + chat_height + 2;
    const cursor_col = 9 + input_view.cursor_col;
    try writer.print("\x1b[{d};{d}H\x1b[?25h", .{ cursor_row, cursor_col });
    try std.fs.File.stdout().writeAll(screen.items);
}

fn buildChatLines(
    allocator: std.mem.Allocator,
    tui: *const TuiSession,
    lines: *std.ArrayList(RenderLine),
    width: usize,
) !void {
    if (tui.messages.items.len == 0) {
        try lines.append(allocator, .{ .text = "no events yet", .tone = .info });
        return;
    }
    for (tui.messages.items) |message| {
        const header = switch (message.kind) {
            .user => try std.fmt.allocPrint(allocator, "USER | {s}", .{message.title}),
            .agent => try std.fmt.allocPrint(allocator, "{s} | streaming {s}", .{ toUpperAscii(allocator, message.actor) catch message.actor, if (message.streaming) "..." else "done" }),
            .tool => try std.fmt.allocPrint(allocator, "TOOL | {s}", .{message.title}),
            .system => try std.fmt.allocPrint(allocator, "SYSTEM | {s}", .{message.title}),
        };
        try lines.append(allocator, .{ .text = header, .tone = message.tone });
        try appendWrappedLines(allocator, lines, message.text.items, width, message.tone, message.highlight);
        try lines.append(allocator, .{});
    }
}

fn buildSidebarLines(
    allocator: std.mem.Allocator,
    tui: *const TuiSession,
    lines: *std.ArrayList(RenderLine),
    width: usize,
) !void {
    try lines.append(allocator, .{ .text = "LIVE CONTEXT", .tone = .warning });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "actor   {s}", .{tui.snapshot.current_actor}), .tone = .info });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "lane    {s}", .{tui.snapshot.active_lane}), .tone = .info });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "global  {s}", .{tui.snapshot.global_status}), .tone = .info });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "runtime {s}", .{tui.snapshot.runtime_status}), .tone = .info });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "turn    {d}", .{tui.snapshot.iteration}), .tone = .info });
    try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "tool    {s}", .{if (tui.snapshot.active_tool.len > 0) tui.snapshot.active_tool else "none"}), .tone = .info });
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "GOAL", .tone = .warning });
    try appendWrappedLines(allocator, lines, if (tui.snapshot.current_goal.len > 0) tui.snapshot.current_goal else "idle", width, .info, .plain);
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "ERROR", .tone = .warning });
    try appendWrappedLines(allocator, lines, if (tui.snapshot.last_error.len > 0) tui.snapshot.last_error else "none", width, .danger, .plain);
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "MODELS", .tone = .warning });
    if (tui.cached_models.len == 0) {
        try appendWrappedLines(allocator, lines, if (tui.last_model_error.len > 0) tui.last_model_error else "run /models", width, .info, .plain);
    } else {
        var model_index: usize = 0;
        while (model_index < tui.cached_models.len and model_index < 6) : (model_index += 1) {
            const marker = if (eql(tui.cached_models[model_index], tui.snapshot.model)) "*" else " ";
            try lines.append(allocator, .{ .text = try std.fmt.allocPrint(allocator, "{s} {d}. {s}", .{ marker, model_index + 1, tui.cached_models[model_index] }), .tone = .info });
        }
    }
}

fn appendWrappedLines(
    allocator: std.mem.Allocator,
    lines: *std.ArrayList(RenderLine),
    text: []const u8,
    width: usize,
    tone: ChatTone,
    highlight: HighlightKind,
) !void {
    if (width == 0) return;
    var source_lines = std.mem.splitScalar(u8, text, '\n');
    while (source_lines.next()) |source_line| {
        if (source_line.len == 0) {
            try lines.append(allocator, .{ .text = "", .tone = tone, .highlight = highlight });
            continue;
        }
        var remainder = source_line;
        while (remainder.len > width) {
            var split_at = width;
            if (std.mem.lastIndexOfScalar(u8, remainder[0..width], ' ')) |space_index| {
                if (space_index > 0) split_at = space_index;
            }
            try lines.append(allocator, .{
                .text = trimAscii(remainder[0..split_at]),
                .tone = tone,
                .highlight = highlight,
            });
            remainder = trimAscii(remainder[split_at..]);
        }
        try lines.append(allocator, .{
            .text = remainder,
            .tone = tone,
            .highlight = highlight,
        });
    }
}

fn terminalSize() TerminalSize {
    var winsize: std.posix.winsize = .{
        .row = 0,
        .col = 0,
        .xpixel = 0,
        .ypixel = 0,
    };
    const err = std.posix.system.ioctl(std.posix.STDOUT_FILENO, std.posix.T.IOCGWINSZ, @intFromPtr(&winsize));
    if (std.posix.errno(err) == .SUCCESS and winsize.col > 0 and winsize.row > 0) {
        return .{
            .rows = winsize.row,
            .cols = winsize.col,
        };
    }
    return .{ .rows = 32, .cols = 120 };
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

fn writeHeaderLine(writer: anytype, width: usize, text: []const u8, tone: ChatTone) !void {
    try writePaddedTone(writer, text, width, tone, true, .plain);
    try writer.writeByte('\n');
}

fn writeFooterLine(writer: anytype, width: usize, text: []const u8) !void {
    try writePaddedTone(writer, text, width, .info, false, .plain);
    try writer.writeByte('\n');
}

fn writePaddedLine(writer: anytype, line: RenderLine, width: usize) !void {
    try writePaddedTone(writer, line.text, width, line.tone, false, line.highlight);
}

fn writePaddedTone(writer: anytype, text: []const u8, width: usize, tone: ChatTone, bold: bool, highlight: HighlightKind) !void {
    const clipped = clipText(text, width);
    if (bold) {
        try writer.writeAll("\x1b[1m");
    }
    try writePlain(writer, clipped, tone, highlight);
    if (bold) {
        try writer.writeAll("\x1b[0m");
    }
    const fill = if (visibleLen(clipped) < width) width - visibleLen(clipped) else 0;
    if (fill > 0) try writer.writeByteNTimes(' ', fill);
}

fn writePlain(writer: anytype, text: []const u8, tone: ChatTone, highlight: HighlightKind) !void {
    switch (highlight) {
        .json => try writeJsonHighlighted(writer, text),
        else => {
            try writer.writeAll(colorForTone(tone));
            try writer.writeAll(text);
            try writer.writeAll("\x1b[0m");
        },
    }
}

fn writeJsonHighlighted(writer: anytype, text: []const u8) !void {
    var in_string = false;
    var escape = false;
    for (text) |char| {
        if (in_string) {
            try writer.writeAll("\x1b[38;5;114m");
            try writer.writeByte(char);
            try writer.writeAll("\x1b[0m");
            if (escape) {
                escape = false;
                continue;
            }
            if (char == '\\') {
                escape = true;
                continue;
            }
            if (char == '"') in_string = false;
            continue;
        }

        switch (char) {
            '"' => {
                in_string = true;
                try writer.writeAll("\x1b[38;5;114m\"");
                try writer.writeAll("\x1b[0m");
            },
            '{', '}', '[', ']', ':', ',' => {
                try writer.writeAll("\x1b[38;5;180m");
                try writer.writeByte(char);
                try writer.writeAll("\x1b[0m");
            },
            '0'...'9', '-', '.' => {
                try writer.writeAll("\x1b[38;5;81m");
                try writer.writeByte(char);
                try writer.writeAll("\x1b[0m");
            },
            else => {
                if (std.ascii.isAlphabetic(char)) {
                    try writer.writeAll("\x1b[38;5;223m");
                    try writer.writeByte(char);
                    try writer.writeAll("\x1b[0m");
                } else {
                    try writer.writeByte(char);
                }
            },
        }
    }
}

fn visibleInputWindow(text: []const u8, cursor: usize, width: usize) struct { text: []const u8, cursor_col: usize } {
    if (text.len <= width) return .{ .text = text, .cursor_col = cursor };
    const safe_cursor = @min(cursor, text.len);
    var start = if (safe_cursor > width - 1) safe_cursor - (width - 1) else 0;
    if (start + width > text.len) start = text.len - width;
    return .{
        .text = text[start .. start + width],
        .cursor_col = safe_cursor - start,
    };
}

fn visibleLen(text: []const u8) usize {
    return text.len;
}

fn clipText(text: []const u8, width: usize) []const u8 {
    if (text.len <= width) return text;
    return text[0..width];
}

fn colorForTone(tone: ChatTone) []const u8 {
    return switch (tone) {
        .danger => "\x1b[38;5;203m",
        .success => "\x1b[38;5;114m",
        .mission => "\x1b[38;5;223m",
        .agent => "\x1b[38;5;81m",
        .tool => "\x1b[38;5;179m",
        .warning => "\x1b[38;5;214m",
        else => "\x1b[38;5;252m",
    };
}

fn toUpperAscii(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    const buffer = try allocator.dupe(u8, text);
    for (buffer) |*char| {
        char.* = std.ascii.toUpper(char.*);
    }
    return buffer;
}

fn currentLaneForState(state: AppState) []const u8 {
    if (state.agent_loop.active_tool.len > 0) return laneForActor(state.agent_loop.active_tool);
    if (eql(state.current_actor, "decanus")) return "command";
    return laneForActor(state.current_actor);
}

fn toneForOutcome(state: AppState) ChatTone {
    if (eql(state.global_status, "complete")) return .success;
    if (eql(state.runtime_session.status, "blocked") or eql(state.runtime_session.status, "interrupted")) return .danger;
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

fn emitStreamFinalize(hooks: RuntimeHooks, actor: []const u8, text: []const u8) void {
    hooks.emit(.{
        .kind = .stream_finalize,
        .actor = actor,
        .text = text,
        .highlight = .json,
    });
}

fn emitStateSnapshot(hooks: RuntimeHooks, config: AppConfig, state: AppState) void {
    hooks.emit(.{
        .kind = .state_snapshot,
        .project_name = if (!eql(state.project_name, "UNASSIGNED")) state.project_name else "",
        .provider_type = config.provider.type,
        .model = if (state.runtime_session.model.len > 0) state.runtime_session.model else config.provider.model,
        .approval_mode = config.policy.approval_mode,
        .global_status = state.global_status,
        .runtime_status = state.runtime_session.status,
        .current_actor = state.current_actor,
        .active_tool = state.agent_loop.active_tool,
        .active_lane = currentLaneForState(state),
        .current_goal = state.mission.current_goal,
        .last_error = state.runtime_session.last_error,
        .last_log_path = state.runtime_session.active_log_path,
        .iteration = state.agent_loop.iteration,
    });
}

fn markInterrupted(state: *AppState) void {
    state.global_status = "interrupted";
    state.agent_loop.status = "interrupted";
    state.runtime_session.status = "interrupted";
    state.runtime_session.last_error = "operator interrupted the active loop";
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
    return try std.fmt.allocPrint(allocator, "runtime error: {s}", .{@errorName(err)});
}

fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !void {
    while (state.agent_loop.iteration < state.agent_loop.max_iterations) {
        if (hooks.isInterrupted()) {
            markInterrupted(state);
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

    state.global_status = "waiting_on_tool";
    state.agent_loop.status = "complete";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = "maximum iteration count reached";
    emitStateSnapshot(hooks, config, state.*);
}

fn executeStep(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    if (state.mission.initial_prompt.len == 0) {
        try stderrPrint("mission prompt is empty; use `contubernium run`\n", .{});
        return error.MissionNotInitialized;
    }

    if (hooks.isInterrupted()) {
        markInterrupted(state);
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
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
    emitStateSnapshot(hooks, config, state.*);

    if (eql(state.current_actor, "decanus")) {
        return try executeDecanusTurn(allocator, config, state, hooks);
    }
    return try executeSpecialistTurn(allocator, config, state, hooks);
}

fn executeDecanusTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    state.global_status = "planning";
    state.agent_loop.status = "thinking";
    emitStateSnapshot(hooks, config, state.*);

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
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            markInterrupted(state);
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "decanus turn failed: {s}", .{@errorName(err)});
        state.global_status = "waiting_on_tool";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = message;
        try writeTurnLog(state.runtime_session.active_log_path, "error", message);
        emitLog(hooks, .danger, "decanus", "Commander Failed", message, .plain);
        return .blocked;
    };
    const decision = response.value;
    try writeTurnLog(state.runtime_session.active_log_path, "model_output", response.raw_text);
    emitStreamFinalize(hooks, "decanus", prettyPrintJson(allocator, response.raw_text) catch response.raw_text);

    if (decision.current_goal.len > 0) {
        state.mission.current_goal = decision.current_goal;
    }
    state.agent_loop.last_decision = decision.action;
    emitStateSnapshot(hooks, config, state.*);

    if (decision.tool_requests.len > 0 or eql(decision.action, "tool_request")) {
        emitLog(hooks, .tool, "decanus", "Runtime Tool", "decanus requested runtime tools", .plain);
        const tool_result = try executeToolRequests(allocator, config, state, "decanus", "", decision.tool_requests, hooks);
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
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        emitLog(hooks, .tool, "decanus", "Tool Result", tool_result.summary, .plain);
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
        emitLog(hooks, .success, "decanus", "Final Response", decision.final_response, .plain);
        emitStateSnapshot(hooks, config, state.*);
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
        emitLog(
            hooks,
            .warning,
            "decanus",
            "Handoff",
            try std.fmt.allocPrint(allocator, "{s} -> {s} on {s}: {s}", .{ "decanus", actor, lane, decision.objective }),
            .plain,
        );
        emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (eql(decision.action, "ask_user")) {
        state.global_status = "waiting_on_tool";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = decision.question;
        emitLog(hooks, .warning, "decanus", "Question", decision.question, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    state.global_status = "waiting_on_tool";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (decision.blocked_reason.len > 0) decision.blocked_reason else "decanus returned a blocked state";
    emitLog(hooks, .danger, "decanus", "Blocked", state.runtime_session.last_error, .plain);
    emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}

fn executeSpecialistTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
    const actor = state.current_actor;
    const lane = laneForActor(actor);
    var task = taskForLane(state, lane);
    task.invocation.status = "running";
    state.global_status = "waiting_on_tool";
    state.agent_loop.status = "running_tool";
    emitStateSnapshot(hooks, config, state.*);

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
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            markInterrupted(state);
            task.invocation.status = "blocked";
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "{s} turn failed: {s}", .{ actor, @errorName(err) });
        task.invocation.status = "blocked";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = message;
        try writeTurnLog(state.runtime_session.active_log_path, "error", message);
        emitLog(hooks, .danger, actor, "Specialist Failed", message, .plain);
        return .blocked;
    };
    const result = response.value;
    try writeTurnLog(state.runtime_session.active_log_path, "model_output", response.raw_text);
    emitStreamFinalize(hooks, actor, prettyPrintJson(allocator, response.raw_text) catch response.raw_text);

    if (result.tool_requests.len > 0 or eql(result.action, "tool_request")) {
        emitLog(hooks, .tool, actor, "Runtime Tool", "specialist requested runtime tools", .plain);
        const tool_result = try executeToolRequests(allocator, config, state, actor, lane, result.tool_requests, hooks);
        state.agent_loop.last_tool_result = tool_result.summary;
        if (tool_result.blocked) {
            task.invocation.status = "blocked";
            state.runtime_session.status = "blocked";
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        task.invocation.status = "running";
        emitLog(hooks, .tool, actor, "Tool Result", tool_result.summary, .plain);
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
        emitLog(hooks, .success, actor, "Lane Complete", result.result_summary, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (eql(result.action, "ask_user")) {
        task.invocation.status = "blocked";
        state.runtime_session.status = "blocked";
        state.runtime_session.last_error = result.question;
        emitLog(hooks, .warning, actor, "Question", result.question, .plain);
        emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    task.invocation.status = "blocked";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = if (result.blocked_reason.len > 0) result.blocked_reason else "specialist returned a blocked state";
    emitLog(hooks, .danger, actor, "Blocked", state.runtime_session.last_error, .plain);
    emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}

fn executeToolRequests(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: []const u8,
    lane: []const u8,
    requests: []const ToolRequest,
    hooks: RuntimeHooks,
) !ToolExecutionOutcome {
    if (requests.len == 0) {
        return .{ .blocked = false, .summary = "no tool requests" };
    }

    var summaries: std.ArrayList([]const u8) = .empty;
    for (requests) |request| {
        const tool_name = request.tool;
        if (tool_name.len == 0) continue;
        emitLog(hooks, .tool, actor, tool_name, toolRequestDisplay(allocator, request) catch tool_name, .plain);

        if (eql(tool_name, "list_files")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, hooks, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "list_files denied by operator");
            }
            const output = try runCommandCapture(allocator, &.{ "find", if (request.path.len > 0) request.path else ".", "-maxdepth", "3" });
            try summaries.append(allocator, try summarizeCommandResult(allocator, "list_files", output, config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "read_file")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, hooks, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "read_file denied by operator");
            }
            const path = if (request.path.len > 0) request.path else return error.MissingPath;
            const content = try readFileLimited(allocator, path, config.context.max_file_read_bytes);
            try summaries.append(allocator, try truncateText(allocator, try std.fmt.allocPrint(allocator, "read_file {s}\n{s}", .{ path, content }), config.context.max_tool_result_chars));
            continue;
        }

        if (eql(tool_name, "search_text")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, hooks, tool_name, request.description)) {
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
            if (!config.policy.allow_shell_without_confirmation and !try confirmTool(allocator, hooks, tool_name, request.command)) {
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
            if (!config.policy.allow_workspace_writes_without_confirmation and !try confirmTool(allocator, hooks, tool_name, path)) {
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
            emitLog(hooks, .warning, actor, "Question", question, .plain);
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
    hooks: RuntimeHooks,
) !struct { value: T, raw_text: []const u8 } {
    var attempt: usize = 0;
    var repair_user_prompt = user_prompt;

    while (true) {
        if (hooks.isInterrupted()) return error.Interrupted;
        emitStreamStart(hooks, actor);
        const response = try providerStructuredChat(allocator, provider, system_prompt, repair_user_prompt, actor, hooks);
        try writeTurnLog(state.runtime_session.active_log_path, "provider_transport", response.transport_text);
        const parsed = parseModelJson(T, allocator, response.raw_text) catch |err| {
            try writeTurnLog(state.runtime_session.active_log_path, "invalid_model_output", response.raw_text);
            emitStreamFinalize(hooks, actor, response.raw_text);
            if (attempt >= max_retries) return err;
            attempt += 1;
            state.runtime_session.repair_attempts = attempt;
            state.runtime_session.last_error = if (response.raw_text.len == 0) "model returned an empty response" else "model returned invalid JSON";
            emitLog(hooks, .warning, actor, "Repair Retry", state.runtime_session.last_error, .plain);
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
        .{},
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
    hooks: RuntimeHooks,
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
                .stream = hooks.emit_fn != null,
                .format = provider.structured_output,
                .messages = &messages,
            },
        );
        const url = try std.fmt.allocPrint(allocator, "{s}/api/chat", .{provider.base_url});

        if (hooks.emit_fn != null) {
            return try providerStructuredChatOllamaStreaming(allocator, provider, schema_kind, body, url, started, hooks);
        }

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
    const chunk = try parseJson(OllamaChatStreamChunk, allocator, line);
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

fn toolRequestDisplay(allocator: std.mem.Allocator, request: ToolRequest) ![]const u8 {
    if (request.path.len > 0) {
        return try std.fmt.allocPrint(allocator, "{s} {s}", .{ request.tool, request.path });
    }
    if (request.pattern.len > 0) {
        return try std.fmt.allocPrint(allocator, "{s} pattern={s}", .{ request.tool, request.pattern });
    }
    if (request.command.len > 0) {
        return try std.fmt.allocPrint(allocator, "{s} {s}", .{ request.tool, request.command });
    }
    if (request.description.len > 0) {
        return try std.fmt.allocPrint(allocator, "{s} {s}", .{ request.tool, request.description });
    }
    return request.tool;
}

fn confirmTool(allocator: std.mem.Allocator, hooks: RuntimeHooks, tool_name: []const u8, detail: []const u8) !bool {
    if (hooks.requestApproval(tool_name, detail)) |decision| {
        return decision;
    }
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

fn prettyPrintJson(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    const normalized = try normalizeModelJson(text);
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, normalized, .{
        .ignore_unknown_fields = true,
    });
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

fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stdout().deprecatedWriter().print(fmt, args);
}

fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stderr().deprecatedWriter().print(fmt, args);
}
