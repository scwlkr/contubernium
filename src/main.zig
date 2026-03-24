const std = @import("std");
const embedded = @import("embedded_assets.zig");
const vaxis = @import("vaxis");

const max_file_bytes = 16 * 1024 * 1024;
const runtime_dir_name = ".contubernium";
const default_state_path = ".contubernium/state.json";
const default_config_path = ".contubernium/config.json";
const default_prompts_dir = ".contubernium/prompts";
const default_logs_dir = ".contubernium/logs";
const max_list_files_entries = 400;
const legacy_default_max_iterations = 12;
const default_max_iterations = 24;
const default_context_window_tokens = 32768;
const default_response_reserve_tokens = 4096;

const UiFlavor = enum {
    vaxis,
    legacy,
};

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
    max_iterations: usize = default_max_iterations,
    active_tool: []const u8 = "",
    last_decision: []const u8 = "",
    last_tool_result: []const u8 = "",
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
    summary,
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
        if (self.actor.len > 0) allocator.free(self.actor);
        if (self.title.len > 0) allocator.free(self.title);
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
        .approval_mode = try allocator.dupe(u8, snapshot.approval_mode),
        .global_status = try allocator.dupe(u8, snapshot.global_status),
        .runtime_status = try allocator.dupe(u8, snapshot.runtime_status),
        .current_actor = try allocator.dupe(u8, snapshot.current_actor),
        .active_tool = try allocator.dupe(u8, snapshot.active_tool),
        .active_lane = try allocator.dupe(u8, snapshot.active_lane),
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
    allocator.free(snapshot.approval_mode);
    allocator.free(snapshot.global_status);
    allocator.free(snapshot.runtime_status);
    allocator.free(snapshot.current_actor);
    allocator.free(snapshot.active_tool);
    allocator.free(snapshot.active_lane);
    allocator.free(snapshot.current_goal);
    allocator.free(snapshot.last_tool_result);
    allocator.free(snapshot.last_error);
    allocator.free(snapshot.last_log_path);
    snapshot.* = .{};
}

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
        .approval_mode = try allocator.dupe(u8, event.approval_mode),
        .global_status = try allocator.dupe(u8, event.global_status),
        .runtime_status = try allocator.dupe(u8, event.runtime_status),
        .current_actor = try allocator.dupe(u8, event.current_actor),
        .active_tool = try allocator.dupe(u8, event.active_tool),
        .active_lane = try allocator.dupe(u8, event.active_lane),
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
    allocator.free(event.approval_mode);
    allocator.free(event.global_status);
    allocator.free(event.runtime_status);
    allocator.free(event.current_actor);
    allocator.free(event.active_tool);
    allocator.free(event.active_lane);
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
    owns_snapshot: bool = false,
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
        if (self.owns_snapshot) freeTuiSnapshot(self.allocator, &self.snapshot);
        if (self.active_stream_actor.len > 0) self.allocator.free(self.active_stream_actor);
        if (self.pending_approval) |approval| {
            self.allocator.free(approval.tool_name);
            self.allocator.free(approval.detail);
        }
        for (self.cached_models) |model| {
            self.allocator.free(model);
        }
        if (self.cached_models.len > 0) self.allocator.free(self.cached_models);
    }
};

fn setTuiSnapshot(tui: *TuiSession, snapshot: TuiSnapshot) !void {
    var owned = try cloneTuiSnapshot(tui.allocator, snapshot);
    errdefer freeTuiSnapshot(tui.allocator, &owned);

    if (tui.owns_snapshot) {
        freeTuiSnapshot(tui.allocator, &tui.snapshot);
    }

    tui.snapshot = owned;
    tui.owns_snapshot = true;
}

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
    if (args.len < 2) {
        try cmdUi(allocator, &.{});
        return;
    }

    const command = args[1];
    if (eql(command, "help") or eql(command, "--help") or eql(command, "-h")) {
        try printUsage();
        return;
    }
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
        try cmdUi(allocator, args[2..]);
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
        \\  contubernium
        \\  contubernium init
        \\  contubernium doctor
        \\  contubernium models list
        \\  contubernium run "mission prompt"
        \\  contubernium step
        \\  contubernium resume
        \\  contubernium ui [--vaxis|--legacy]
        \\
        \\`contubernium` scaffolds .contubernium in the current directory if needed
        \\and starts the interactive UI.
        \\`contubernium init` only writes the runtime scaffold.
        \\
    , .{});
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

fn parseUiFlavor(args: []const []const u8) !UiFlavor {
    var flavor: UiFlavor = .vaxis;
    for (args) |arg| {
        if (eql(arg, "--vaxis")) {
            flavor = .vaxis;
            continue;
        }
        if (eql(arg, "--legacy")) {
            flavor = .legacy;
            continue;
        }
        try stderrPrint("usage: contubernium ui [--vaxis|--legacy]\n", .{});
        return error.InvalidArguments;
    }
    return flavor;
}

fn cmdUi(allocator: std.mem.Allocator, args: []const []const u8) !void {
    try scaffoldProject(allocator);
    switch (try parseUiFlavor(args)) {
        .vaxis => try interactiveUiLoopVaxis(allocator),
        .legacy => try interactiveUiLoopLegacy(allocator),
    }
}

fn interactiveUiLoopLegacy(allocator: std.mem.Allocator) !void {
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

    try setTuiSnapshot(&tui, snapshotFromState(config, state, std.fs.path.basename(cwd)));
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
    const model_name = try resolveModelSelection(allocator, tui, selector);
    return saveSelectedModelByName(allocator, model_name);
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
        "project: {s}\nprovider: {s}\nmodel: {s}\nactor: {s}\nlane: {s}\nglobal status: {s}\nruntime status: {s}\nturn: {d}/{d}\ncontext est: {d} tokens ({d}% used)\ncontext left: {d}\ncondensed: {d} runs / {d} events\nlast error: {s}",
        .{
            snapshot.project_name,
            snapshot.provider_type,
            snapshot.model,
            snapshot.current_actor,
            snapshot.active_lane,
            snapshot.global_status,
            snapshot.runtime_status,
            snapshot.iteration,
            snapshot.max_iterations,
            snapshot.estimated_prompt_tokens,
            snapshot.context_used_percent,
            snapshot.remaining_context_tokens,
            snapshot.condensation_count,
            snapshot.condensed_history_events,
            if (snapshot.last_error.len > 0) snapshot.last_error else "none",
        },
    );
}

const RenderLine = struct {
    text: []const u8 = "",
    tone: ChatTone = .info,
    highlight: HighlightKind = .plain,
    bold: bool = false,
};

const RenderFrame = struct {
    screen: []const u8,
    cursor_row: usize,
    cursor_col: usize,
};

const TerminalSize = struct {
    rows: usize,
    cols: usize,
};

const input_prompt = "mission> ";
const input_help = "Enter submit | Up/Down scroll | PgUp/PgDn fast scroll | Ctrl+C interrupt/exit";

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

fn snapshotFromState(config: AppConfig, state: AppState, project_name: []const u8) TuiSnapshot {
    const budget = resolvedContextBudget(config.context, state.runtime_session.context_budget);
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

fn processRuntimeEvents(allocator: std.mem.Allocator, tui: *TuiSession, queue: *RuntimeEventQueue) !void {
    const events = try queue.drain(allocator);
    defer freeRuntimeUiEvents(allocator, events);
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
                try setTuiSnapshot(tui, .{
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
                    .last_tool_result = event.last_tool_result,
                    .last_error = event.last_error,
                    .last_log_path = event.last_log_path,
                    .iteration = event.iteration,
                    .max_iterations = if (event.max_iterations > 0) event.max_iterations else tui.snapshot.max_iterations,
                    .estimated_prompt_chars = if (event.estimated_prompt_chars > 0) event.estimated_prompt_chars else tui.snapshot.estimated_prompt_chars,
                    .estimated_prompt_tokens = if (event.estimated_prompt_tokens > 0) event.estimated_prompt_tokens else tui.snapshot.estimated_prompt_tokens,
                    .context_window_tokens = if (event.context_window_tokens > 0) event.context_window_tokens else tui.snapshot.context_window_tokens,
                    .response_reserve_tokens = if (event.response_reserve_tokens > 0) event.response_reserve_tokens else tui.snapshot.response_reserve_tokens,
                    .remaining_context_tokens = if (event.remaining_context_tokens > 0 or event.estimated_prompt_tokens > 0) event.remaining_context_tokens else tui.snapshot.remaining_context_tokens,
                    .context_used_percent = if (event.context_used_percent > 0 or event.estimated_prompt_tokens > 0) event.context_used_percent else tui.snapshot.context_used_percent,
                    .condensation_count = if (event.condensation_count > 0) event.condensation_count else tui.snapshot.condensation_count,
                    .condensed_history_events = if (event.condensed_history_events > 0) event.condensed_history_events else tui.snapshot.condensed_history_events,
                });
                tui.dirty = true;
            },
            .approval_request => {
                if (tui.pending_approval) |approval| {
                    tui.allocator.free(approval.tool_name);
                    tui.allocator.free(approval.detail);
                }
                tui.pending_approval = .{
                    .tool_name = try tui.allocator.dupe(u8, event.title),
                    .detail = try tui.allocator.dupe(u8, event.text),
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
    if (tui.pending_approval) |approval| {
        tui.allocator.free(approval.tool_name);
        tui.allocator.free(approval.detail);
        tui.pending_approval = null;
    }
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
        .actor = try tui.allocator.dupe(u8, actor),
        .title = try tui.allocator.dupe(u8, title),
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
    if (tui.active_stream_actor.len > 0) tui.allocator.free(tui.active_stream_actor);
    tui.active_stream_actor = "";
    tui.active_stream_index = null;
    tui.scroll_offset = 0;
    tui.dirty = true;
}

fn beginStreamingMessage(tui: *TuiSession, actor: []const u8) !void {
    if (tui.active_stream_actor.len > 0) tui.allocator.free(tui.active_stream_actor);
    const message = TuiMessage{
        .kind = .agent,
        .tone = .agent,
        .actor = try tui.allocator.dupe(u8, actor),
        .title = try tui.allocator.dupe(u8, actor),
        .highlight = .json,
        .streaming = true,
    };
    try tui.messages.append(tui.allocator, message);
    tui.active_stream_actor = try tui.allocator.dupe(u8, actor);
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
            if (tui.active_stream_actor.len > 0) tui.allocator.free(tui.active_stream_actor);
            tui.active_stream_actor = "";
            tui.scroll_offset = 0;
            tui.dirty = true;
            return;
        }
    }
    try appendChatMessage(tui, .agent, .agent, actor, actor, text, highlight);
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
        const lane = if (decision.lane.len > 0) decision.lane else laneForActor(decision.actor);
        const actor = if (decision.actor.len > 0) decision.actor else actorForLane(lane);
        try writer.print("\nhandoff: {s} on {s}", .{ actor, lane });
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
    const action = if (result.action.len > 0) result.action else "unknown";

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

    if (eql(action, "complete")) {
        if (result.description.len > 0) {
            const description = try compactTextForUi(allocator, result.description, 3, 280);
            defer allocator.free(description);
            try writer.print("\ndescription: {s}", .{description});
        }
        if (result.result_summary.len > 0) {
            const summary = try compactTextForUi(allocator, result.result_summary, 6, 520);
            defer allocator.free(summary);
            try writer.print("\nsummary:\n{s}", .{summary});
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
        const blocked_reason = if (result.blocked_reason.len > 0) result.blocked_reason else "blocked";
        const reason = try compactTextForUi(allocator, blocked_reason, 4, 320);
        defer allocator.free(reason);
        try writer.print("\nblocked: {s}", .{reason});
    }

    return try buffer.toOwnedSlice(allocator);
}

fn updateCachedModels(allocator: std.mem.Allocator, tui: *TuiSession, text: []const u8) !void {
    for (tui.cached_models) |model| {
        allocator.free(model);
    }
    if (tui.cached_models.len > 0) allocator.free(tui.cached_models);

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
    const frame = try buildRenderFrame(allocator, tui, terminalSize());
    defer allocator.free(frame.screen);
    try std.fs.File.stdout().writeAll(frame.screen);
}

fn buildRenderFrame(allocator: std.mem.Allocator, tui: *const TuiSession, size: TerminalSize) !RenderFrame {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const temp_allocator = arena.allocator();

    const sidebar_width: usize = if (size.cols >= 124) 38 else 0;
    const gutter_width: usize = if (sidebar_width > 0) 4 else 0;
    const body_width = if (sidebar_width > 0 and size.cols > sidebar_width + gutter_width + 24) size.cols - sidebar_width - gutter_width else size.cols;
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
    try writer.writeAll("\x1b[?25l\x1b[2J\x1b[H");

    try writeHeaderLine(writer, size.cols, " CONTUBERNIUM COMMAND TENT ", .info);
    try writeHeaderLine(
        writer,
        size.cols,
        try std.fmt.allocPrint(
            temp_allocator,
            " project {s} | actor {s} | lane {s} | global {s} | runtime {s} | turn {d}/{d} ",
            .{
                tui.snapshot.project_name,
                tui.snapshot.current_actor,
                tui.snapshot.active_lane,
                tui.snapshot.global_status,
                tui.snapshot.runtime_status,
                tui.snapshot.iteration,
                tui.snapshot.max_iterations,
            },
        ),
        .agent,
    );
    try writeHeaderLine(
        writer,
        size.cols,
        try std.fmt.allocPrint(
            temp_allocator,
            " provider {s} | model {s} | approval {s} | ctx ~{d} left ({d}%) | scroll {d} ",
            .{
                tui.snapshot.provider_type,
                tui.snapshot.model,
                tui.snapshot.approval_mode,
                tui.snapshot.remaining_context_tokens,
                tui.snapshot.context_used_percent,
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
            try writer.writeAll("\x1b[38;5;238m  │ \x1b[0m");
            try writePaddedLine(writer, side_line, sidebar_width);
            try writer.writeByte('\n');
        } else {
            try writePaddedLine(writer, chat_line, body_width);
            try writer.writeByte('\n');
        }
    }

    try writeHeaderLine(writer, size.cols, " INPUT ", .warning);
    try writeFooterLine(writer, size.cols, input_help);
    const prompt_width = if (size.cols > input_prompt.len) size.cols - input_prompt.len else 0;
    const input_view = visibleInputWindow(tui.input.items, tui.cursor, prompt_width);
    try writer.writeAll("\x1b[38;5;220m");
    try writer.writeAll(input_prompt);
    try writer.writeAll("\x1b[0m");
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

    const cursor_row = @min(size.rows, header_height + chat_height + 3);
    const cursor_col = @min(size.cols, input_prompt.len + 1 + input_view.cursor_col);
    try writer.print("\x1b[{d};{d}H\x1b[?25h", .{ cursor_row, cursor_col });

    return .{
        .screen = try allocator.dupe(u8, screen.items),
        .cursor_row = cursor_row,
        .cursor_col = cursor_col,
    };
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
        const header = try messageHeading(allocator, message);
        try lines.append(allocator, .{ .text = header, .tone = message.tone, .bold = true });
        try appendWrappedLinesWithPrefix(allocator, lines, message.text.items, width, message.tone, message.highlight, "  ");
        try lines.append(allocator, .{});
    }
}

fn buildSidebarLines(
    allocator: std.mem.Allocator,
    tui: *const TuiSession,
    lines: *std.ArrayList(RenderLine),
    width: usize,
) !void {
    try appendSidebarSectionHeader(allocator, lines, "LIVE CONTEXT");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "actor: {s}", .{tui.snapshot.current_actor}), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "lane: {s}", .{tui.snapshot.active_lane}), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "global: {s}", .{tui.snapshot.global_status}), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "runtime: {s}", .{tui.snapshot.runtime_status}), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "loop: {d}/{d}", .{ tui.snapshot.iteration, tui.snapshot.max_iterations }), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "tool: {s}", .{if (tui.snapshot.active_tool.len > 0) tui.snapshot.active_tool else "none"}), width, .info, .plain, "  ");
    try lines.append(allocator, .{});
    try appendSidebarSectionHeader(allocator, lines, "BUDGET");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "prompt est: {d} tokens", .{tui.snapshot.estimated_prompt_tokens}), width, .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "context left: {d}", .{tui.snapshot.remaining_context_tokens}), width, if (tui.snapshot.context_used_percent >= 85) .danger else if (tui.snapshot.context_used_percent >= 70) .warning else .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "context used: {d}%", .{tui.snapshot.context_used_percent}), width, if (tui.snapshot.context_used_percent >= 85) .danger else if (tui.snapshot.context_used_percent >= 70) .warning else .info, .plain, "  ");
    try appendWrappedLinesWithPrefix(allocator, lines, try std.fmt.allocPrint(allocator, "condensed: {d} runs / {d} events", .{ tui.snapshot.condensation_count, tui.snapshot.condensed_history_events }), width, .info, .plain, "  ");
    try lines.append(allocator, .{});
    try appendSidebarSectionHeader(allocator, lines, "GOAL");
    try appendWrappedLinesWithPrefix(allocator, lines, if (tui.snapshot.current_goal.len > 0) tui.snapshot.current_goal else "idle", width, .info, .plain, "  ");
    try lines.append(allocator, .{});
    try appendSidebarSectionHeader(allocator, lines, "LATEST");
    const latest = try compactTextForUi(allocator, if (tui.snapshot.last_tool_result.len > 0) tui.snapshot.last_tool_result else "none", 7, 320);
    try appendWrappedLinesWithPrefix(allocator, lines, latest, width, .info, .plain, "  ");
    try lines.append(allocator, .{});
    try appendSidebarSectionHeader(allocator, lines, "ERROR");
    try appendWrappedLinesWithPrefix(allocator, lines, if (tui.snapshot.last_error.len > 0) tui.snapshot.last_error else "none", width, .danger, .plain, "  ");
    try lines.append(allocator, .{});
    try appendSidebarSectionHeader(allocator, lines, "MODELS");
    if (tui.cached_models.len == 0) {
        try appendWrappedLinesWithPrefix(allocator, lines, if (tui.last_model_error.len > 0) tui.last_model_error else "run /models", width, .info, .plain, "  ");
    } else {
        var model_index: usize = 0;
        while (model_index < tui.cached_models.len and model_index < 6) : (model_index += 1) {
            const marker = if (eql(tui.cached_models[model_index], tui.snapshot.model)) "*" else " ";
            try lines.append(allocator, .{
                .text = try std.fmt.allocPrint(allocator, "  {s} {d}. {s}", .{ marker, model_index + 1, tui.cached_models[model_index] }),
                .tone = .info,
            });
        }
    }
}

fn messageHeading(allocator: std.mem.Allocator, message: TuiMessage) ![]const u8 {
    return switch (message.kind) {
        .user => try std.fmt.allocPrint(allocator, "[USER] {s}", .{message.title}),
        .agent => blk: {
            const actor = try toUpperAscii(allocator, message.actor);
            const mode = if (message.streaming)
                "LIVE STREAM"
            else if (message.highlight == .summary)
                "REPORT"
            else
                "RESPONSE";
            break :blk try std.fmt.allocPrint(allocator, "[{s}] {s}", .{ actor, mode });
        },
        .tool => try std.fmt.allocPrint(allocator, "[TOOL] {s}", .{message.title}),
        .system => try std.fmt.allocPrint(allocator, "[SYSTEM] {s}", .{message.title}),
    };
}

fn appendSidebarSectionHeader(allocator: std.mem.Allocator, lines: *std.ArrayList(RenderLine), text: []const u8) !void {
    try lines.append(allocator, .{
        .text = try std.fmt.allocPrint(allocator, "{s}", .{text}),
        .tone = .warning,
        .bold = true,
    });
}

fn prefixedRenderText(allocator: std.mem.Allocator, prefix: []const u8, text: []const u8) ![]const u8 {
    if (prefix.len == 0) return text;
    if (text.len == 0) return prefix;
    return try std.fmt.allocPrint(allocator, "{s}{s}", .{ prefix, text });
}

fn appendWrappedLines(
    allocator: std.mem.Allocator,
    lines: *std.ArrayList(RenderLine),
    text: []const u8,
    width: usize,
    tone: ChatTone,
    highlight: HighlightKind,
) !void {
    try appendWrappedLinesWithPrefix(allocator, lines, text, width, tone, highlight, "");
}

fn appendWrappedLinesWithPrefix(
    allocator: std.mem.Allocator,
    lines: *std.ArrayList(RenderLine),
    text: []const u8,
    width: usize,
    tone: ChatTone,
    highlight: HighlightKind,
    prefix: []const u8,
) !void {
    if (width == 0) return;
    const prefix_width = displayWidth(prefix);
    const content_width = if (prefix_width >= width) 1 else width - prefix_width;
    var source_lines = std.mem.splitScalar(u8, text, '\n');
    while (source_lines.next()) |source_line| {
        if (source_line.len == 0) {
            try lines.append(allocator, .{ .text = "", .tone = tone, .highlight = highlight });
            continue;
        }
        var remainder = source_line;
        while (displayWidth(remainder) > content_width) {
            const split_at = wrapTextByteIndex(remainder, content_width);
            const segment = trimAscii(remainder[0..split_at]);
            try lines.append(allocator, .{
                .text = try prefixedRenderText(allocator, prefix, segment),
                .tone = tone,
                .highlight = highlight,
            });
            remainder = trimAscii(remainder[split_at..]);
        }
        try lines.append(allocator, .{
            .text = try prefixedRenderText(allocator, prefix, remainder),
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
    try writePaddedTone(writer, line.text, width, line.tone, line.bold, line.highlight);
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
        .summary => try writeSummaryHighlighted(writer, text, tone),
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

fn writeSummaryHighlighted(writer: anytype, text: []const u8, tone: ChatTone) !void {
    var lines = std.mem.splitScalar(u8, text, '\n');
    var first_line = true;
    while (lines.next()) |line| {
        if (!first_line) try writer.writeByte('\n');
        first_line = false;
        try writeSummaryLine(writer, line, tone);
    }
}

fn writeSummaryLine(writer: anytype, line: []const u8, tone: ChatTone) !void {
    const trimmed = trimAscii(line);
    if (trimmed.len == 0) return;

    if (std.mem.startsWith(u8, trimmed, "- ")) {
        try writer.writeAll("\x1b[38;5;214m- \x1b[0m");
        try writer.writeAll(colorForTone(tone));
        try writer.writeAll(trimmed[2..]);
        try writer.writeAll("\x1b[0m");
        return;
    }

    if (std.mem.indexOfScalar(u8, line, ':')) |colon_index| {
        const key = trimAscii(line[0..colon_index]);
        if (isSummaryKey(key)) {
            try writer.writeAll("\x1b[38;5;214m");
            try writer.writeAll(key);
            try writer.writeAll("\x1b[38;5;244m:\x1b[0m");
            const rest = trimAscii(line[colon_index + 1 ..]);
            if (rest.len > 0) {
                try writer.writeAll(" ");
                try writer.writeAll(colorForTone(tone));
                try writer.writeAll(rest);
                try writer.writeAll("\x1b[0m");
            }
            return;
        }
    }

    try writer.writeAll(colorForTone(tone));
    try writer.writeAll(line);
    try writer.writeAll("\x1b[0m");
}

fn isSummaryKey(text: []const u8) bool {
    if (text.len == 0 or text.len > 24) return false;
    for (text) |char| {
        if (!(std.ascii.isAlphanumeric(char) or char == ' ' or char == '_' or char == '-')) return false;
    }
    return true;
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

fn displayWidth(text: []const u8) usize {
    var width: usize = 0;
    var index: usize = 0;
    while (index < text.len) {
        const scalar = decodeUtf8Scalar(text, index);
        width += cellWidthForCodepoint(scalar.codepoint);
        index += scalar.byte_len;
    }
    return width;
}

fn wrapTextByteIndex(text: []const u8, width: usize) usize {
    if (text.len == 0 or width == 0) return 0;

    var used_width: usize = 0;
    var index: usize = 0;
    var last_space: ?usize = null;

    while (index < text.len) {
        const scalar = decodeUtf8Scalar(text, index);
        const scalar_width = cellWidthForCodepoint(scalar.codepoint);
        if (used_width + scalar_width > width) break;
        if (scalar.codepoint == ' ') last_space = index;
        used_width += scalar_width;
        index += scalar.byte_len;
    }

    if (index >= text.len) return text.len;
    if (last_space) |space_index| {
        if (space_index > 0) return space_index;
    }
    if (index == 0) return decodeUtf8Scalar(text, 0).byte_len;
    return index;
}

fn utf8PrefixByCellWidth(text: []const u8, width: usize) []const u8 {
    if (width == 0) return "";

    var used_width: usize = 0;
    var index: usize = 0;
    while (index < text.len) {
        const scalar = decodeUtf8Scalar(text, index);
        const scalar_width = cellWidthForCodepoint(scalar.codepoint);
        if (used_width + scalar_width > width) break;
        used_width += scalar_width;
        index += scalar.byte_len;
    }
    return text[0..index];
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

fn cellWidthForCodepoint(codepoint: u21) usize {
    if (codepoint == 0) return 0;
    if (codepoint < 32 or (codepoint >= 0x7f and codepoint < 0xa0)) return 0;
    if (isCombiningCodepoint(codepoint) or codepoint == 0x200d) return 0;
    if (isWideCodepoint(codepoint)) return 2;
    return 1;
}

fn isCombiningCodepoint(codepoint: u21) bool {
    return (codepoint >= 0x0300 and codepoint <= 0x036f) or
        (codepoint >= 0x0483 and codepoint <= 0x0489) or
        (codepoint >= 0x0591 and codepoint <= 0x05bd) or
        codepoint == 0x05bf or
        (codepoint >= 0x05c1 and codepoint <= 0x05c2) or
        (codepoint >= 0x05c4 and codepoint <= 0x05c5) or
        codepoint == 0x05c7 or
        (codepoint >= 0x0610 and codepoint <= 0x061a) or
        (codepoint >= 0x064b and codepoint <= 0x065f) or
        codepoint == 0x0670 or
        (codepoint >= 0x06d6 and codepoint <= 0x06dc) or
        (codepoint >= 0x06df and codepoint <= 0x06e4) or
        (codepoint >= 0x06e7 and codepoint <= 0x06e8) or
        (codepoint >= 0x06ea and codepoint <= 0x06ed) or
        (codepoint >= 0x0711 and codepoint <= 0x0711) or
        (codepoint >= 0x0730 and codepoint <= 0x074a) or
        (codepoint >= 0x07a6 and codepoint <= 0x07b0) or
        (codepoint >= 0x07eb and codepoint <= 0x07f3) or
        (codepoint >= 0x0816 and codepoint <= 0x0819) or
        (codepoint >= 0x081b and codepoint <= 0x0823) or
        (codepoint >= 0x0825 and codepoint <= 0x0827) or
        (codepoint >= 0x0829 and codepoint <= 0x082d) or
        (codepoint >= 0x0859 and codepoint <= 0x085b) or
        (codepoint >= 0x08d3 and codepoint <= 0x08e1) or
        (codepoint >= 0x08e3 and codepoint <= 0x0902) or
        codepoint == 0x093a or
        codepoint == 0x093c or
        (codepoint >= 0x0941 and codepoint <= 0x0948) or
        codepoint == 0x094d or
        (codepoint >= 0x0951 and codepoint <= 0x0957) or
        (codepoint >= 0x0962 and codepoint <= 0x0963) or
        (codepoint >= 0x0981 and codepoint <= 0x0981) or
        codepoint == 0x09bc or
        codepoint == 0x09c1 or
        codepoint == 0x09c4 or
        codepoint == 0x09cd or
        (codepoint >= 0x09e2 and codepoint <= 0x09e3) or
        codepoint == 0x0a01 or
        codepoint == 0x0a02 or
        codepoint == 0x0a3c or
        (codepoint >= 0x0a41 and codepoint <= 0x0a42) or
        (codepoint >= 0x0a47 and codepoint <= 0x0a48) or
        (codepoint >= 0x0a4b and codepoint <= 0x0a4d) or
        (codepoint >= 0x0a51 and codepoint <= 0x0a51) or
        (codepoint >= 0x0a70 and codepoint <= 0x0a71) or
        codepoint == 0x0a75 or
        codepoint == 0x0abc or
        (codepoint >= 0x0ac1 and codepoint <= 0x0ac5) or
        codepoint == 0x0ac7 or
        codepoint == 0x0acd or
        (codepoint >= 0x0ae2 and codepoint <= 0x0ae3) or
        codepoint == 0x0b3c or
        codepoint == 0x0b3f or
        codepoint == 0x0b41 or
        codepoint == 0x0b44 or
        codepoint == 0x0b4d or
        (codepoint >= 0x0b56 and codepoint <= 0x0b56) or
        (codepoint >= 0x0b62 and codepoint <= 0x0b63) or
        codepoint == 0x0b82 or
        codepoint == 0x0bc0 or
        codepoint == 0x0bcd or
        codepoint == 0x0c00 or
        codepoint == 0x0c04 or
        (codepoint >= 0x0c3e and codepoint <= 0x0c40) or
        (codepoint >= 0x0c46 and codepoint <= 0x0c48) or
        (codepoint >= 0x0c4a and codepoint <= 0x0c4d) or
        (codepoint >= 0x0c55 and codepoint <= 0x0c56) or
        (codepoint >= 0x0c62 and codepoint <= 0x0c63) or
        codepoint == 0x0c81 or
        codepoint == 0x0cbc or
        codepoint == 0x0cbf or
        codepoint == 0x0cc6 or
        (codepoint >= 0x0ccc and codepoint <= 0x0ccd) or
        (codepoint >= 0x0ce2 and codepoint <= 0x0ce3) or
        codepoint == 0x0d00 or
        codepoint == 0x0d01 or
        (codepoint >= 0x0d3b and codepoint <= 0x0d3c) or
        codepoint == 0x0d41 or
        (codepoint >= 0x0d44 and codepoint <= 0x0d44) or
        codepoint == 0x0d4d or
        (codepoint >= 0x0d62 and codepoint <= 0x0d63) or
        codepoint == 0x0dca or
        (codepoint >= 0x0dd2 and codepoint <= 0x0dd4) or
        codepoint == 0x0dd6 or
        codepoint == 0x0e31 or
        (codepoint >= 0x0e34 and codepoint <= 0x0e3a) or
        (codepoint >= 0x0e47 and codepoint <= 0x0e4e) or
        codepoint == 0x0eb1 or
        (codepoint >= 0x0eb4 and codepoint <= 0x0eb9) or
        (codepoint >= 0x0ebb and codepoint <= 0x0ebc) or
        (codepoint >= 0x0ec8 and codepoint <= 0x0ecd) or
        codepoint == 0x0f18 or
        codepoint == 0x0f19 or
        codepoint == 0x0f35 or
        codepoint == 0x0f37 or
        codepoint == 0x0f39 or
        (codepoint >= 0x0f71 and codepoint <= 0x0f7e) or
        (codepoint >= 0x0f80 and codepoint <= 0x0f84) or
        (codepoint >= 0x0f86 and codepoint <= 0x0f87) or
        (codepoint >= 0x0f8d and codepoint <= 0x0f97) or
        (codepoint >= 0x0f99 and codepoint <= 0x0fbc) or
        codepoint == 0x0fc6 or
        (codepoint >= 0x102d and codepoint <= 0x1030) or
        (codepoint >= 0x1032 and codepoint <= 0x1037) or
        codepoint == 0x1039 or
        codepoint == 0x103a or
        (codepoint >= 0x103d and codepoint <= 0x103e) or
        (codepoint >= 0x1058 and codepoint <= 0x1059) or
        (codepoint >= 0x105e and codepoint <= 0x1060) or
        (codepoint >= 0x1071 and codepoint <= 0x1074) or
        codepoint == 0x1082 or
        (codepoint >= 0x1085 and codepoint <= 0x1086) or
        codepoint == 0x108d or
        codepoint == 0x109d or
        (codepoint >= 0x135d and codepoint <= 0x135f) or
        (codepoint >= 0x1712 and codepoint <= 0x1714) or
        (codepoint >= 0x1732 and codepoint <= 0x1734) or
        (codepoint >= 0x1752 and codepoint <= 0x1753) or
        (codepoint >= 0x1772 and codepoint <= 0x1773) or
        (codepoint >= 0x17b4 and codepoint <= 0x17b5) or
        (codepoint >= 0x17b7 and codepoint <= 0x17bd) or
        codepoint == 0x17c6 or
        (codepoint >= 0x17c9 and codepoint <= 0x17d3) or
        codepoint == 0x17dd or
        (codepoint >= 0x180b and codepoint <= 0x180d) or
        codepoint == 0x1885 or
        codepoint == 0x1886 or
        (codepoint >= 0x18a9 and codepoint <= 0x18a9) or
        (codepoint >= 0x1920 and codepoint <= 0x1922) or
        (codepoint >= 0x1927 and codepoint <= 0x1928) or
        codepoint == 0x1932 or
        (codepoint >= 0x1939 and codepoint <= 0x193b) or
        (codepoint >= 0x1a17 and codepoint <= 0x1a18) or
        codepoint == 0x1a1b or
        codepoint == 0x1a56 or
        (codepoint >= 0x1a58 and codepoint <= 0x1a5e) or
        codepoint == 0x1a60 or
        codepoint == 0x1a62 or
        (codepoint >= 0x1a65 and codepoint <= 0x1a6c) or
        (codepoint >= 0x1a73 and codepoint <= 0x1a7c) or
        codepoint == 0x1a7f or
        (codepoint >= 0x1ab0 and codepoint <= 0x1aff) or
        (codepoint >= 0x1b00 and codepoint <= 0x1b03) or
        codepoint == 0x1b34 or
        codepoint == 0x1b36 or
        (codepoint >= 0x1b3c and codepoint <= 0x1b3c) or
        codepoint == 0x1b42 or
        (codepoint >= 0x1b6b and codepoint <= 0x1b73) or
        (codepoint >= 0x1b80 and codepoint <= 0x1b81) or
        (codepoint >= 0x1ba2 and codepoint <= 0x1ba5) or
        (codepoint >= 0x1ba8 and codepoint <= 0x1ba9) or
        codepoint == 0x1bab or
        codepoint == 0x1be6 or
        (codepoint >= 0x1be8 and codepoint <= 0x1be9) or
        codepoint == 0x1bed or
        (codepoint >= 0x1bef and codepoint <= 0x1bf1) or
        (codepoint >= 0x1c2c and codepoint <= 0x1c33) or
        (codepoint >= 0x1c36 and codepoint <= 0x1c37) or
        (codepoint >= 0x1cd0 and codepoint <= 0x1cd2) or
        (codepoint >= 0x1cd4 and codepoint <= 0x1ce0) or
        (codepoint >= 0x1ce2 and codepoint <= 0x1ce8) or
        codepoint == 0x1ced or
        codepoint == 0x1cf4 or
        codepoint == 0x1cf8 or
        codepoint == 0x1cf9 or
        (codepoint >= 0x1dc0 and codepoint <= 0x1dff) or
        (codepoint >= 0x20d0 and codepoint <= 0x20ff) or
        codepoint == 0x2cef or
        codepoint == 0x2cf1 or
        (codepoint >= 0x2d7f and codepoint <= 0x2d7f) or
        (codepoint >= 0x2de0 and codepoint <= 0x2dff) or
        (codepoint >= 0x302a and codepoint <= 0x302f) or
        codepoint == 0x3099 or
        codepoint == 0x309a or
        (codepoint >= 0xa66f and codepoint <= 0xa672) or
        (codepoint >= 0xa674 and codepoint <= 0xa67d) or
        codepoint == 0xa69e or
        codepoint == 0xa69f or
        (codepoint >= 0xa6f0 and codepoint <= 0xa6f1) or
        codepoint == 0xa802 or
        codepoint == 0xa806 or
        codepoint == 0xa80b or
        (codepoint >= 0xa825 and codepoint <= 0xa826) or
        codepoint == 0xa8c4 or
        (codepoint >= 0xa8e0 and codepoint <= 0xa8f1) or
        codepoint == 0xa926 or
        codepoint == 0xa92d or
        (codepoint >= 0xa947 and codepoint <= 0xa951) or
        (codepoint >= 0xa980 and codepoint <= 0xa982) or
        codepoint == 0xa9b3 or
        (codepoint >= 0xa9b6 and codepoint <= 0xa9b9) or
        codepoint == 0xa9bc or
        codepoint == 0xa9e5 or
        (codepoint >= 0xaa29 and codepoint <= 0xaa2e) or
        (codepoint >= 0xaa31 and codepoint <= 0xaa32) or
        (codepoint >= 0xaa35 and codepoint <= 0xaa36) or
        codepoint == 0xaa43 or
        codepoint == 0xaa4c or
        codepoint == 0xaa7c or
        codepoint == 0xaab0 or
        (codepoint >= 0xaab2 and codepoint <= 0xaab4) or
        (codepoint >= 0xaab7 and codepoint <= 0xaab8) or
        codepoint == 0xaabe or
        codepoint == 0xaabf or
        codepoint == 0xaac1 or
        (codepoint >= 0xaaec and codepoint <= 0xaaed) or
        codepoint == 0xaaf6 or
        (codepoint >= 0xabe5 and codepoint <= 0xabe5) or
        codepoint == 0xabe8 or
        codepoint == 0xabed or
        codepoint == 0xfb1e or
        (codepoint >= 0xfe00 and codepoint <= 0xfe0f) or
        (codepoint >= 0xfe20 and codepoint <= 0xfe2f) or
        (codepoint >= 0x101fd and codepoint <= 0x101fd) or
        (codepoint >= 0x102e0 and codepoint <= 0x102e0) or
        (codepoint >= 0x10376 and codepoint <= 0x1037a) or
        (codepoint >= 0x10a01 and codepoint <= 0x10a03) or
        (codepoint >= 0x10a05 and codepoint <= 0x10a06) or
        (codepoint >= 0x10a0c and codepoint <= 0x10a0f) or
        (codepoint >= 0x10a38 and codepoint <= 0x10a3a) or
        codepoint == 0x10a3f or
        (codepoint >= 0x10ae5 and codepoint <= 0x10ae6) or
        (codepoint >= 0x11001 and codepoint <= 0x11001) or
        (codepoint >= 0x11038 and codepoint <= 0x11046) or
        (codepoint >= 0x1107f and codepoint <= 0x11081) or
        (codepoint >= 0x110b3 and codepoint <= 0x110b6) or
        (codepoint >= 0x110b9 and codepoint <= 0x110ba) or
        codepoint == 0x11100 or
        (codepoint >= 0x11127 and codepoint <= 0x1112b) or
        (codepoint >= 0x1112d and codepoint <= 0x11134) or
        codepoint == 0x11173 or
        (codepoint >= 0x11180 and codepoint <= 0x11181) or
        (codepoint >= 0x111b6 and codepoint <= 0x111be) or
        codepoint == 0x111c9 or
        (codepoint >= 0x1122f and codepoint <= 0x11231) or
        codepoint == 0x11234 or
        (codepoint >= 0x11236 and codepoint <= 0x11237) or
        codepoint == 0x1123e or
        (codepoint >= 0x112df and codepoint <= 0x112df) or
        (codepoint >= 0x112e3 and codepoint <= 0x112ea) or
        codepoint == 0x11300 or
        codepoint == 0x11301 or
        codepoint == 0x1133c or
        codepoint == 0x11340 or
        codepoint == 0x11366 or
        (codepoint >= 0x11370 and codepoint <= 0x11374) or
        (codepoint >= 0x11438 and codepoint <= 0x1143f) or
        (codepoint >= 0x11442 and codepoint <= 0x11444) or
        codepoint == 0x11446 or
        (codepoint >= 0x114b3 and codepoint <= 0x114b8) or
        codepoint == 0x114ba or
        (codepoint >= 0x114bf and codepoint <= 0x114c0) or
        codepoint == 0x114c2 or
        (codepoint >= 0x115b2 and codepoint <= 0x115b5) or
        (codepoint >= 0x115bc and codepoint <= 0x115bd) or
        codepoint == 0x115bf or
        codepoint == 0x11633 or
        (codepoint >= 0x1163d and codepoint <= 0x1163d) or
        codepoint == 0x1163f or
        codepoint == 0x116ab or
        (codepoint >= 0x116ad and codepoint <= 0x116ad) or
        codepoint == 0x116b0 or
        (codepoint >= 0x116b2 and codepoint <= 0x116b5) or
        (codepoint >= 0x1171d and codepoint <= 0x1171f) or
        (codepoint >= 0x11722 and codepoint <= 0x11725) or
        codepoint == 0x11727 or
        codepoint == 0x1172b or
        (codepoint >= 0x1182f and codepoint <= 0x11837) or
        codepoint == 0x11839 or
        (codepoint >= 0x11a01 and codepoint <= 0x11a0a) or
        (codepoint >= 0x11a33 and codepoint <= 0x11a38) or
        (codepoint >= 0x11a3b and codepoint <= 0x11a3e) or
        codepoint == 0x11a47 or
        (codepoint >= 0x11a51 and codepoint <= 0x11a56) or
        codepoint == 0x11a59 or
        (codepoint >= 0x11a8a and codepoint <= 0x11a96) or
        codepoint == 0x11a98 or
        (codepoint >= 0x11c30 and codepoint <= 0x11c36) or
        (codepoint >= 0x11c38 and codepoint <= 0x11c3d) or
        codepoint == 0x11c3f or
        (codepoint >= 0x11c92 and codepoint <= 0x11ca7) or
        (codepoint >= 0x11caa and codepoint <= 0x11cb0) or
        (codepoint >= 0x11cb2 and codepoint <= 0x11cb3) or
        codepoint == 0x11cb5 or
        codepoint == 0x11cb6 or
        (codepoint >= 0x11d31 and codepoint <= 0x11d36) or
        codepoint == 0x11d3a or
        (codepoint >= 0x11d3c and codepoint <= 0x11d3d) or
        (codepoint >= 0x11d3f and codepoint <= 0x11d45) or
        codepoint == 0x11d47 or
        (codepoint >= 0x11d90 and codepoint <= 0x11d91) or
        codepoint == 0x11d95 or
        codepoint == 0x11d97 or
        codepoint == 0x11ef3 or
        codepoint == 0x11ef4 or
        (codepoint >= 0x16af0 and codepoint <= 0x16af4) or
        (codepoint >= 0x16b30 and codepoint <= 0x16b36) or
        (codepoint >= 0x16f8f and codepoint <= 0x16f92) or
        (codepoint >= 0x1bc9d and codepoint <= 0x1bc9e) or
        (codepoint >= 0x1d167 and codepoint <= 0x1d169) or
        (codepoint >= 0x1d17b and codepoint <= 0x1d182) or
        (codepoint >= 0x1d185 and codepoint <= 0x1d18b) or
        (codepoint >= 0x1d1aa and codepoint <= 0x1d1ad) or
        (codepoint >= 0x1d242 and codepoint <= 0x1d244) or
        (codepoint >= 0x1da00 and codepoint <= 0x1da36) or
        (codepoint >= 0x1da3b and codepoint <= 0x1da6c) or
        codepoint == 0x1da75 or
        codepoint == 0x1da84 or
        (codepoint >= 0x1da9b and codepoint <= 0x1da9f) or
        (codepoint >= 0x1daa1 and codepoint <= 0x1daaf) or
        (codepoint >= 0x1e000 and codepoint <= 0x1e006) or
        (codepoint >= 0x1e008 and codepoint <= 0x1e018) or
        (codepoint >= 0x1e01b and codepoint <= 0x1e021) or
        (codepoint >= 0x1e023 and codepoint <= 0x1e024) or
        (codepoint >= 0x1e026 and codepoint <= 0x1e02a) or
        (codepoint >= 0x1e130 and codepoint <= 0x1e136) or
        (codepoint >= 0x1e2ec and codepoint <= 0x1e2ef) or
        (codepoint >= 0x1e8d0 and codepoint <= 0x1e8d6) or
        (codepoint >= 0x1e944 and codepoint <= 0x1e94a) or
        (codepoint >= 0xe0100 and codepoint <= 0xe01ef);
}

fn isWideCodepoint(codepoint: u21) bool {
    return codepoint >= 0x1100 and
        (codepoint <= 0x115f or
            codepoint == 0x2329 or
            codepoint == 0x232a or
            (codepoint >= 0x2e80 and codepoint <= 0xa4cf and codepoint != 0x303f) or
            (codepoint >= 0xac00 and codepoint <= 0xd7a3) or
            (codepoint >= 0xf900 and codepoint <= 0xfaff) or
            (codepoint >= 0xfe10 and codepoint <= 0xfe19) or
            (codepoint >= 0xfe30 and codepoint <= 0xfe6f) or
            (codepoint >= 0xff00 and codepoint <= 0xff60) or
            (codepoint >= 0xffe0 and codepoint <= 0xffe6) or
            (codepoint >= 0x1f300 and codepoint <= 0x1f64f) or
            (codepoint >= 0x1f680 and codepoint <= 0x1f6ff) or
            (codepoint >= 0x1f900 and codepoint <= 0x1f9ff) or
            (codepoint >= 0x1fa70 and codepoint <= 0x1faff) or
            (codepoint >= 0x20000 and codepoint <= 0x3fffd));
}

fn visibleInputWindow(text: []const u8, cursor: usize, width: usize) struct { text: []const u8, cursor_col: usize } {
    if (width == 0) return .{ .text = "", .cursor_col = 0 };
    const safe_cursor = @min(cursor, text.len);
    if (displayWidth(text) <= width) {
        return .{
            .text = text,
            .cursor_col = displayWidth(text[0..safe_cursor]),
        };
    }

    var start: usize = 0;
    while (start < safe_cursor and displayWidth(text[start..safe_cursor]) > width) {
        start += decodeUtf8Scalar(text, start).byte_len;
    }

    var end = start;
    var used_width: usize = 0;
    while (end < text.len) {
        const scalar = decodeUtf8Scalar(text, end);
        const scalar_width = cellWidthForCodepoint(scalar.codepoint);
        if (used_width + scalar_width > width) break;
        used_width += scalar_width;
        end += scalar.byte_len;
    }
    return .{
        .text = text[start..end],
        .cursor_col = displayWidth(text[start..safe_cursor]),
    };
}

fn visibleLen(text: []const u8) usize {
    return displayWidth(text);
}

fn clipText(text: []const u8, width: usize) []const u8 {
    if (displayWidth(text) <= width) return text;
    return utf8PrefixByCellWidth(text, width);
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

fn emitStreamFinalize(hooks: RuntimeHooks, actor: []const u8, text: []const u8, highlight: HighlightKind) void {
    hooks.emit(.{
        .kind = .stream_finalize,
        .actor = actor,
        .text = text,
        .highlight = highlight,
    });
}

fn emitStateSnapshot(hooks: RuntimeHooks, config: AppConfig, state: AppState) void {
    const budget = resolvedContextBudget(config.context, state.runtime_session.context_budget);
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
    if (err == error.FileNotFound) {
        return try allocator.dupe(u8, "requested path was not found inside the workspace.");
    }
    return try std.fmt.allocPrint(allocator, "runtime error: {s}", .{@errorName(err)});
}

fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !void {
    ensureLoopBudget(state);
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
    state.agent_loop.status = "blocked";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = try progressDocumentationText(
        allocator,
        state,
        "maximum iteration count reached before the mission completed.",
        config.context.max_stop_summary_chars,
    );
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "loop_limit_reached",
        .actor = state.current_actor,
        .lane = currentLaneForState(state.*),
        .summary = state.runtime_session.last_error,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
    });
    try saveState(allocator, config.paths.state_file, state.*);
    emitLog(hooks, .danger, "runtime", "Loop Limit Reached", state.runtime_session.last_error, .plain);
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
    const user_prompt = buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .decanus, "") catch |err| {
        if (err == error.ContextBudgetExceeded) return .blocked;
        return err;
    };
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
    const decision_summary = summarizeDecanusDecisionForUi(allocator, decision) catch prettyPrintJson(allocator, response.raw_text) catch response.raw_text;
    emitStreamFinalize(hooks, "decanus", decision_summary, .summary);

    if (decision.current_goal.len > 0) {
        state.mission.current_goal = decision.current_goal;
    }
    state.agent_loop.last_decision = decision.action;
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
    const user_prompt = buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .specialist, lane) catch |err| {
        if (err == error.ContextBudgetExceeded) return .blocked;
        return err;
    };
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
    const result_summary = summarizeSpecialistResultForUi(allocator, result) catch prettyPrintJson(allocator, response.raw_text) catch response.raw_text;
    emitStreamFinalize(hooks, actor, result_summary, .summary);

    if (result.tool_requests.len > 0 or eql(result.action, "tool_request")) {
        emitLog(
            hooks,
            .tool,
            actor,
            "Runtime Tool",
            summarizeToolRequestsForUi(allocator, result.tool_requests) catch "specialist requested runtime tools",
            .plain,
        );
        const tool_result = try executeToolRequests(allocator, config, state, actor, lane, result.tool_requests, hooks);
        state.agent_loop.last_tool_result = tool_result.summary;
        if (tool_result.blocked) {
            task.invocation.status = "blocked";
            state.runtime_session.status = "blocked";
            emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        task.invocation.status = "running";
        emitLog(
            hooks,
            .tool,
            actor,
            "Tool Result",
            compactTextForUi(allocator, tool_result.summary, 12, 900) catch tool_result.summary,
            .plain,
        );
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
        const tool_name = canonicalToolName(request.tool);
        if (tool_name.len == 0) continue;
        emitLog(hooks, .tool, actor, tool_name, toolRequestDisplay(allocator, request) catch tool_name, .plain);

        if (eql(tool_name, "list_files")) {
            if (!config.policy.allow_read_tools_without_confirmation and !try confirmTool(allocator, hooks, tool_name, request.description)) {
                return try blockedToolOutcome(allocator, state, "list_files denied by operator");
            }
            const output = try listWorkspaceFiles(allocator, request.path);
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

        try summaries.append(allocator, try std.fmt.allocPrint(allocator, "unknown tool `{s}` requested by {s} on lane {s}", .{ request.tool, actor, lane }));
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
            emitStreamFinalize(hooks, actor, response.raw_text, .json);
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

fn runShellCommand(allocator: std.mem.Allocator, command: []const u8) !CommandResult {
    return try runCommandCapture(allocator, &.{ "sh", "-lc", command });
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
                .stderr = "",
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
    const stdout = if (truncated)
        try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{joined})
    else
        joined;

    return .{
        .stdout = stdout,
        .stderr = if (truncated) "truncated directory listing" else "",
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
    return try truncateText(allocator, combined, max_chars);
}

fn searchText(allocator: std.mem.Allocator, pattern: []const u8, path: []const u8, max_hits: usize) ![]const u8 {
    const rg_result = runCommandCapture(allocator, &.{ "rg", "-n", "--no-heading", "--max-count", try std.fmt.allocPrint(allocator, "{d}", .{max_hits}), pattern, path }) catch |err| switch (err) {
        error.FileNotFound => {
            const grep_result = try runCommandCapture(allocator, &.{ "grep", "-R", "-n", pattern, path });
            return grep_result.stdout;
        },
        else => return err,
    };
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
    ensureLoopBudget(state);
}

fn initializeRuntimeSession(allocator: std.mem.Allocator, state: *AppState, config: AppConfig) void {
    _ = allocator;
    ensureLoopBudget(state);
    state.runtime_session.provider = config.provider.type;
    state.runtime_session.model = config.provider.model;
    state.runtime_session.endpoint = config.provider.base_url;
    state.runtime_session.approval_mode = config.policy.approval_mode;
    state.runtime_session.context_budget.context_window_tokens = config.context.estimated_context_window_tokens;
    state.runtime_session.context_budget.response_reserve_tokens = config.context.response_reserve_tokens;
    if (state.runtime_session.context_budget.estimated_prompt_tokens == 0) {
        state.runtime_session.context_budget.remaining_tokens = usablePromptTokenWindow(config.context);
        state.runtime_session.context_budget.used_percent = 0;
    }
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
    state.runtime_session.context_budget.estimated_prompt_chars = estimate.prompt_chars;
    state.runtime_session.context_budget.estimated_prompt_tokens = estimate.prompt_tokens;
    state.runtime_session.context_budget.context_window_tokens = config.estimated_context_window_tokens;
    state.runtime_session.context_budget.response_reserve_tokens = config.response_reserve_tokens;
    state.runtime_session.context_budget.remaining_tokens = estimate.remaining_tokens;
    state.runtime_session.context_budget.used_percent = estimate.used_percent;
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

    return try truncateText(allocator, try joinStrings(allocator, lines.items, "\n"), max_chars);
}

fn condenseHistoryForContext(allocator: std.mem.Allocator, config: ContextConfig, state: *AppState) !bool {
    const keep_recent = @max(@as(usize, 1), config.condensed_keep_recent_events);
    if (state.agent_loop.history.len <= keep_recent + 1) return false;

    const split_index = state.agent_loop.history.len - keep_recent;
    const older = state.agent_loop.history[0..split_index];
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
    try history.appendSlice(allocator, state.agent_loop.history[split_index..]);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
    state.runtime_session.context_budget.condensation_count += 1;
    state.runtime_session.context_budget.condensed_history_events += older.len;
    state.runtime_session.context_budget.last_condensed_iteration = state.agent_loop.iteration;
    return true;
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
    return try truncateText(
        allocator,
        try std.fmt.allocPrint(
            allocator,
            "{s}\n\ncurrent goal: {s}\nloop: {d}/{d}\ncurrent actor: {s}\nactive tool: {s}\nlatest result: {s}\ntasks: {s}\nrecent progress:\n{s}",
            .{
                reason,
                if (state.mission.current_goal.len > 0) state.mission.current_goal else "idle",
                state.agent_loop.iteration,
                state.agent_loop.max_iterations,
                state.current_actor,
                if (state.agent_loop.active_tool.len > 0) state.agent_loop.active_tool else "none",
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
    state.global_status = "waiting_on_tool";
    state.agent_loop.status = "blocked";
    state.runtime_session.status = "blocked";
    state.runtime_session.last_error = message;
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "context_budget_blocked",
        .actor = state.current_actor,
        .lane = currentLaneForState(state.*),
        .summary = message,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
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
) ![]const u8 {
    var attempt: usize = 0;
    while (true) {
        const user_prompt = switch (mode) {
            .decanus => try buildDecanusUserPrompt(allocator, config, state),
            .specialist => try buildSpecialistUserPrompt(allocator, config, state, lane),
        };
        const estimate = estimatePromptBudget(config.context, system_prompt, user_prompt);
        applyPromptBudgetEstimate(state, config.context, estimate);
        emitStateSnapshot(hooks, config, state.*);

        if (!estimate.should_condense or attempt >= 3) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return user_prompt;
        }

        const condensed = try condenseHistoryForContext(allocator, config.context, state);
        if (!condensed) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return user_prompt;
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
        attempt += 1;
    }
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
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    try writeToolRequestLabel(buffer.writer(allocator), request);
    return try buffer.toOwnedSlice(allocator);
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
    return try std.fmt.allocPrint(allocator, "{s}\n...[truncated]...", .{safeUtf8PrefixByBytes(text, max_chars)});
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

const UiMode = enum {
    landing,
    session,
};

const OverlayKind = enum {
    none,
    command_palette,
    model_switcher,
    approval,
    status,
};

const FocusTarget = enum {
    transcript,
    composer,
    rail,
    overlay,
};

const TimelineEntryKind = enum {
    user,
    thinking,
    tool,
    report,
    final,
    system,
    failure,
};

const RailState = struct {
    pinned: bool = false,
};

const ComposerState = struct {
    placeholder: []const u8 = "Type a mission or /command",
};

const ViewportState = struct {
    scroll_offset: usize = 0,
    follow_latest: bool = true,
};

const TimelineEntry = struct {
    kind: TimelineEntryKind = .system,
    tone: ChatTone = .info,
    actor: []const u8 = "",
    title: []const u8 = "",
    text: std.ArrayList(u8) = .empty,
    highlight: HighlightKind = .plain,
    streaming: bool = false,
    collapsed: bool = false,

    fn deinit(self: *TimelineEntry, allocator: std.mem.Allocator) void {
        if (self.actor.len > 0) allocator.free(self.actor);
        if (self.title.len > 0) allocator.free(self.title);
        self.text.deinit(allocator);
    }
};

const PaletteCommand = struct {
    label: []const u8,
    command: []const u8,
    description: []const u8,
};

const palette_commands = [_]PaletteCommand{
    .{ .label = "Resume", .command = "/resume", .description = "Continue the active mission loop." },
    .{ .label = "Doctor", .command = "/doctor", .description = "Run diagnostics and backend checks." },
    .{ .label = "Models", .command = "/models", .description = "Refresh the available provider model roster." },
    .{ .label = "Status", .command = "/status", .description = "Inspect the current runtime snapshot." },
    .{ .label = "Clear", .command = "/clear", .description = "Clear the transcript and return to the atrium." },
    .{ .label = "Interrupt", .command = "/interrupt", .description = "Interrupt the active runtime loop." },
    .{ .label = "Exit", .command = "/exit", .description = "Leave the TUI." },
};

const VaxisEvent = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
    focus_in,
    focus_out,
};

const VaxisRenderLine = struct {
    text: []const u8 = "",
    tone: ChatTone = .info,
    highlight: HighlightKind = .plain,
    kind: TimelineEntryKind = .system,
    bold: bool = false,
};

const VaxisUiSession = struct {
    allocator: std.mem.Allocator,
    cwd: []const u8 = "",
    snapshot: TuiSnapshot = .{},
    owns_snapshot: bool = false,
    timeline: std.ArrayList(TimelineEntry) = .empty,
    composer: vaxis.widgets.TextInput,
    composer_state: ComposerState = .{},
    viewport: ViewportState = .{},
    rail: RailState = .{},
    mode: UiMode = .landing,
    overlay: OverlayKind = .none,
    focus: FocusTarget = .composer,
    dirty: bool = true,
    should_exit: bool = false,
    pending_approval: ?ApprovalPrompt = null,
    approval_choice: bool = true,
    cached_models: []const []const u8 = &.{},
    last_model_error: []const u8 = "",
    active_stream_actor: []const u8 = "",
    active_stream_index: ?usize = null,
    running_command: ?WorkerCommandKind = null,
    command_palette_index: usize = 0,
    model_overlay_index: usize = 0,

    fn init(allocator: std.mem.Allocator, cwd: []const u8) !VaxisUiSession {
        return .{
            .allocator = allocator,
            .cwd = try allocator.dupe(u8, cwd),
            .composer = vaxis.widgets.TextInput.init(allocator),
        };
    }

    fn deinit(self: *VaxisUiSession) void {
        for (self.timeline.items) |*entry| {
            entry.deinit(self.allocator);
        }
        self.timeline.deinit(self.allocator);
        self.composer.deinit();
        if (self.owns_snapshot) freeTuiSnapshot(self.allocator, &self.snapshot);
        if (self.active_stream_actor.len > 0) self.allocator.free(self.active_stream_actor);
        if (self.pending_approval) |approval| {
            self.allocator.free(approval.tool_name);
            self.allocator.free(approval.detail);
        }
        for (self.cached_models) |model| {
            self.allocator.free(model);
        }
        if (self.cached_models.len > 0) self.allocator.free(self.cached_models);
        if (self.last_model_error.len > 0) self.allocator.free(self.last_model_error);
        if (self.cwd.len > 0) self.allocator.free(self.cwd);
    }
};

fn setVaxisSnapshot(ui: *VaxisUiSession, snapshot: TuiSnapshot) !void {
    var owned = try cloneTuiSnapshot(ui.allocator, snapshot);
    errdefer freeTuiSnapshot(ui.allocator, &owned);

    if (ui.owns_snapshot) freeTuiSnapshot(ui.allocator, &ui.snapshot);
    ui.snapshot = owned;
    ui.owns_snapshot = true;
}

fn replaceOwnedString(allocator: std.mem.Allocator, target: *[]const u8, text: []const u8) !void {
    if (target.*.len > 0) allocator.free(target.*);
    target.* = if (text.len == 0) "" else try allocator.dupe(u8, text);
}

fn parseModelRoster(allocator: std.mem.Allocator, text: []const u8) ![]const []const u8 {
    var items: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (items.items) |item| allocator.free(item);
        items.deinit(allocator);
    }

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
    return try items.toOwnedSlice(allocator);
}

fn updateCachedModelsVaxis(allocator: std.mem.Allocator, ui: *VaxisUiSession, text: []const u8) !void {
    for (ui.cached_models) |model| allocator.free(model);
    if (ui.cached_models.len > 0) allocator.free(ui.cached_models);
    ui.cached_models = try parseModelRoster(allocator, text);
    ui.dirty = true;
}

fn resolveModelSelectionVaxis(allocator: std.mem.Allocator, ui: *VaxisUiSession, selector: []const u8) ![]const u8 {
    if (isUnsignedDecimal(selector)) {
        if (ui.cached_models.len == 0) return error.ModelListUnavailable;
        const index = try std.fmt.parseUnsigned(usize, selector, 10);
        if (index == 0 or index > ui.cached_models.len) return error.ModelSelectionOutOfRange;
        return try allocator.dupe(u8, ui.cached_models[index - 1]);
    }
    return try allocator.dupe(u8, selector);
}

fn clearTimeline(ui: *VaxisUiSession) void {
    for (ui.timeline.items) |*entry| {
        entry.deinit(ui.allocator);
    }
    ui.timeline.clearRetainingCapacity();
    if (ui.active_stream_actor.len > 0) ui.allocator.free(ui.active_stream_actor);
    ui.active_stream_actor = "";
    ui.active_stream_index = null;
    ui.viewport = .{};
    ui.mode = .landing;
    ui.overlay = .none;
    ui.focus = .composer;
    ui.dirty = true;
}

fn markTimelineMutation(ui: *VaxisUiSession) void {
    ui.mode = if (ui.timeline.items.len == 0 and ui.running_command == null) .landing else .session;
    if (ui.viewport.follow_latest) ui.viewport.scroll_offset = 0;
    ui.dirty = true;
}

fn appendTimelineEntry(
    ui: *VaxisUiSession,
    kind: TimelineEntryKind,
    tone: ChatTone,
    actor: []const u8,
    title: []const u8,
    text: []const u8,
    highlight: HighlightKind,
) !void {
    var entry = TimelineEntry{
        .kind = kind,
        .tone = tone,
        .actor = try ui.allocator.dupe(u8, actor),
        .title = try ui.allocator.dupe(u8, title),
        .highlight = highlight,
        .collapsed = kind == .tool or kind == .thinking,
    };
    try entry.text.appendSlice(ui.allocator, text);
    try ui.timeline.append(ui.allocator, entry);
    markTimelineMutation(ui);
}

fn beginStreamingEntryVaxis(ui: *VaxisUiSession, actor: []const u8) !void {
    if (ui.active_stream_actor.len > 0) ui.allocator.free(ui.active_stream_actor);
    const entry = TimelineEntry{
        .kind = .thinking,
        .tone = .info,
        .actor = try ui.allocator.dupe(u8, actor),
        .title = try ui.allocator.dupe(u8, actor),
        .highlight = .plain,
        .streaming = true,
        .collapsed = false,
    };
    try ui.timeline.append(ui.allocator, entry);
    ui.active_stream_actor = try ui.allocator.dupe(u8, actor);
    ui.active_stream_index = ui.timeline.items.len - 1;
    markTimelineMutation(ui);
}

fn appendStreamingChunkVaxis(ui: *VaxisUiSession, actor: []const u8, text: []const u8) !void {
    if (ui.active_stream_index) |stream_index| {
        if (eql(ui.active_stream_actor, actor) and stream_index < ui.timeline.items.len) {
            try ui.timeline.items[stream_index].text.appendSlice(ui.allocator, text);
            markTimelineMutation(ui);
            return;
        }
    }
    try beginStreamingEntryVaxis(ui, actor);
    if (ui.active_stream_index) |stream_index| {
        try ui.timeline.items[stream_index].text.appendSlice(ui.allocator, text);
    }
    markTimelineMutation(ui);
}

fn finalizeStreamingEntryVaxis(ui: *VaxisUiSession, actor: []const u8, text: []const u8, highlight: HighlightKind) !void {
    const final_kind: TimelineEntryKind = if (highlight == .summary) .report else .thinking;
    const final_tone: ChatTone = if (highlight == .summary) .agent else .info;

    if (ui.active_stream_index) |stream_index| {
        if (eql(ui.active_stream_actor, actor) and stream_index < ui.timeline.items.len) {
            var entry = &ui.timeline.items[stream_index];
            entry.text.clearRetainingCapacity();
            try entry.text.appendSlice(ui.allocator, text);
            entry.kind = final_kind;
            entry.tone = final_tone;
            entry.highlight = highlight;
            entry.streaming = false;
            entry.collapsed = final_kind == .thinking;
            ui.active_stream_index = null;
            if (ui.active_stream_actor.len > 0) ui.allocator.free(ui.active_stream_actor);
            ui.active_stream_actor = "";
            markTimelineMutation(ui);
            return;
        }
    }
    try appendTimelineEntry(ui, final_kind, final_tone, actor, actor, text, highlight);
}

fn timelineKindForRuntimeLog(event: RuntimeUiEvent) TimelineEntryKind {
    if (event.tone == .mission) return .user;
    if (event.tone == .danger) return .failure;
    if (event.tone == .tool) return .tool;
    if (eql(event.title, "Final Response")) return .final;
    if (event.tone == .success and event.actor.len > 0) return .report;
    return .system;
}

fn processRuntimeEventsVaxis(allocator: std.mem.Allocator, ui: *VaxisUiSession, queue: *RuntimeEventQueue) !void {
    const events = try queue.drain(allocator);
    defer freeRuntimeUiEvents(allocator, events);

    for (events) |event| {
        switch (event.kind) {
            .log => {
                const kind = timelineKindForRuntimeLog(event);
                try appendTimelineEntry(
                    ui,
                    kind,
                    if (kind == .final) .success else event.tone,
                    event.actor,
                    event.title,
                    event.text,
                    event.highlight,
                );
                if (eql(event.title, "Model Query Failed")) {
                    try replaceOwnedString(ui.allocator, &ui.last_model_error, event.text);
                }
            },
            .stream_start => try beginStreamingEntryVaxis(ui, event.actor),
            .stream_chunk => try appendStreamingChunkVaxis(ui, event.actor, event.text),
            .stream_finalize => try finalizeStreamingEntryVaxis(ui, event.actor, event.text, event.highlight),
            .state_snapshot => {
                try setVaxisSnapshot(ui, .{
                    .project_name = if (event.project_name.len > 0) event.project_name else ui.snapshot.project_name,
                    .provider_type = if (event.provider_type.len > 0) event.provider_type else ui.snapshot.provider_type,
                    .model = if (event.model.len > 0) event.model else ui.snapshot.model,
                    .approval_mode = if (event.approval_mode.len > 0) event.approval_mode else ui.snapshot.approval_mode,
                    .global_status = if (event.global_status.len > 0) event.global_status else ui.snapshot.global_status,
                    .runtime_status = if (event.runtime_status.len > 0) event.runtime_status else ui.snapshot.runtime_status,
                    .current_actor = if (event.current_actor.len > 0) event.current_actor else ui.snapshot.current_actor,
                    .active_tool = event.active_tool,
                    .active_lane = if (event.active_lane.len > 0) event.active_lane else ui.snapshot.active_lane,
                    .current_goal = event.current_goal,
                    .last_tool_result = event.last_tool_result,
                    .last_error = event.last_error,
                    .last_log_path = event.last_log_path,
                    .iteration = event.iteration,
                    .max_iterations = if (event.max_iterations > 0) event.max_iterations else ui.snapshot.max_iterations,
                    .estimated_prompt_chars = if (event.estimated_prompt_chars > 0) event.estimated_prompt_chars else ui.snapshot.estimated_prompt_chars,
                    .estimated_prompt_tokens = if (event.estimated_prompt_tokens > 0) event.estimated_prompt_tokens else ui.snapshot.estimated_prompt_tokens,
                    .context_window_tokens = if (event.context_window_tokens > 0) event.context_window_tokens else ui.snapshot.context_window_tokens,
                    .response_reserve_tokens = if (event.response_reserve_tokens > 0) event.response_reserve_tokens else ui.snapshot.response_reserve_tokens,
                    .remaining_context_tokens = if (event.remaining_context_tokens > 0 or event.estimated_prompt_tokens > 0) event.remaining_context_tokens else ui.snapshot.remaining_context_tokens,
                    .context_used_percent = if (event.context_used_percent > 0 or event.estimated_prompt_tokens > 0) event.context_used_percent else ui.snapshot.context_used_percent,
                    .condensation_count = if (event.condensation_count > 0) event.condensation_count else ui.snapshot.condensation_count,
                    .condensed_history_events = if (event.condensed_history_events > 0) event.condensed_history_events else ui.snapshot.condensed_history_events,
                });
                ui.dirty = true;
            },
            .approval_request => {
                if (ui.pending_approval) |approval| {
                    ui.allocator.free(approval.tool_name);
                    ui.allocator.free(approval.detail);
                }
                ui.pending_approval = .{
                    .tool_name = try ui.allocator.dupe(u8, event.title),
                    .detail = try ui.allocator.dupe(u8, event.text),
                };
                ui.approval_choice = true;
                ui.overlay = .approval;
                ui.focus = .overlay;
                ui.mode = .session;
                ui.dirty = true;
            },
            .model_roster => {
                try updateCachedModelsVaxis(allocator, ui, event.text);
                if (ui.last_model_error.len > 0) {
                    ui.allocator.free(ui.last_model_error);
                    ui.last_model_error = "";
                }
                try appendTimelineEntry(ui, .system, .success, "models", "Model Roster", event.text, .plain);
            },
        }
    }
}

fn vaxisInterruptOrExit(ui: *VaxisUiSession, control: *RuntimeControl, worker: ?*WorkerTask) !void {
    if (worker != null and control.running.load(.seq_cst)) {
        control.interrupt_requested.store(true, .seq_cst);
        submitApprovalResponse(control, false);
        try appendTimelineEntry(ui, .system, .warning, "runtime", "Interrupt", "interrupt requested", .plain);
        return;
    }
    ui.should_exit = true;
    ui.dirty = true;
}

fn scrollTimelineUp(ui: *VaxisUiSession, amount: usize) void {
    ui.viewport.scroll_offset +|= amount;
    ui.viewport.follow_latest = false;
    ui.dirty = true;
}

fn scrollTimelineDown(ui: *VaxisUiSession, amount: usize) void {
    if (ui.viewport.scroll_offset > amount) {
        ui.viewport.scroll_offset -= amount;
        ui.viewport.follow_latest = false;
    } else {
        ui.viewport.scroll_offset = 0;
        ui.viewport.follow_latest = true;
    }
    ui.dirty = true;
}

fn jumpTimelineToLatest(ui: *VaxisUiSession) void {
    ui.viewport.scroll_offset = 0;
    ui.viewport.follow_latest = true;
    ui.dirty = true;
}

fn nextFocusTarget(ui: *VaxisUiSession, terminal_cols: u16) FocusTarget {
    if (ui.overlay != .none) return .overlay;
    if (shouldShowRail(ui, terminal_cols)) {
        return switch (ui.focus) {
            .composer => .transcript,
            .transcript => .rail,
            .rail => .composer,
            .overlay => .composer,
        };
    }
    return switch (ui.focus) {
        .composer => .transcript,
        .transcript => .composer,
        .rail => .composer,
        .overlay => .composer,
    };
}

fn executePaletteSelection(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
) !void {
    const entry = palette_commands[ui.command_palette_index];
    ui.overlay = .none;
    ui.focus = .composer;
    if (eql(entry.command, "/status")) {
        ui.overlay = .status;
        ui.focus = .overlay;
        ui.dirty = true;
        return;
    }
    _ = try handleSubmittedInputVaxis(allocator, ui, queue, control, worker, entry.command);
}

fn openModelSwitcher(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
) !void {
    ui.overlay = .model_switcher;
    ui.focus = .overlay;
    ui.mode = .session;
    if (ui.cached_models.len == 0 and (worker.* == null or !control.running.load(.seq_cst))) {
        worker.* = try startWorker(allocator, queue, control, .models, "");
        ui.running_command = .models;
    }
    ui.dirty = true;
}

fn selectOverlayModel(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
) !void {
    if (ui.cached_models.len == 0) return;
    if (worker.* != null and control.running.load(.seq_cst)) {
        try appendTimelineEntry(ui, .failure, .danger, "models", "Busy", "change the model after the active command finishes", .plain);
        return;
    }
    const selection = ui.cached_models[@min(ui.model_overlay_index, ui.cached_models.len - 1)];
    const saved = saveSelectedModelByName(allocator, selection) catch |err| {
        const message = try friendlyRuntimeError(allocator, err);
        defer allocator.free(message);
        try replaceOwnedString(ui.allocator, &ui.last_model_error, message);
        try appendTimelineEntry(ui, .failure, .danger, "models", "Model Change Failed", ui.last_model_error, .plain);
        return;
    };
    defer allocator.free(saved);
    try setVaxisSnapshot(ui, .{
        .project_name = ui.snapshot.project_name,
        .provider_type = ui.snapshot.provider_type,
        .model = selection,
        .approval_mode = ui.snapshot.approval_mode,
        .global_status = ui.snapshot.global_status,
        .runtime_status = ui.snapshot.runtime_status,
        .current_actor = ui.snapshot.current_actor,
        .active_tool = ui.snapshot.active_tool,
        .active_lane = ui.snapshot.active_lane,
        .current_goal = ui.snapshot.current_goal,
        .last_tool_result = ui.snapshot.last_tool_result,
        .last_error = ui.snapshot.last_error,
        .last_log_path = ui.snapshot.last_log_path,
        .iteration = ui.snapshot.iteration,
    });
    try appendTimelineEntry(ui, .system, .success, "models", "Model Changed", saved, .plain);
    ui.overlay = .none;
    ui.focus = .composer;
}

fn submitApprovalVaxis(ui: *VaxisUiSession, control: *RuntimeControl, approved: bool) !void {
    submitApprovalResponse(control, approved);
    try appendTimelineEntry(
        ui,
        .system,
        if (approved) .success else .warning,
        "approval",
        if (approved) "Approval Granted" else "Approval Denied",
        if (ui.pending_approval) |approval| approval.detail else "approval handled",
        .plain,
    );
    if (ui.pending_approval) |approval| {
        ui.allocator.free(approval.tool_name);
        ui.allocator.free(approval.detail);
        ui.pending_approval = null;
    }
    ui.overlay = .none;
    ui.focus = .composer;
    ui.dirty = true;
}

fn handleSubmittedInputVaxis(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
    input: []const u8,
) !bool {
    if (input.len == 0) return true;

    if (input[0] != '/') {
        if (worker.* != null and control.running.load(.seq_cst)) {
            try appendTimelineEntry(ui, .failure, .danger, "runtime", "Busy", "the runtime is already executing a command", .plain);
            return true;
        }
        try appendTimelineEntry(ui, .user, .mission, "user", "Mission", input, .plain);
        worker.* = try startWorker(allocator, queue, control, .mission, try allocator.dupe(u8, input));
        ui.running_command = .mission;
        ui.mode = .session;
        ui.focus = .composer;
        return true;
    }

    var parts = std.mem.tokenizeScalar(u8, input[1..], ' ');
    const command = parts.next() orelse return true;

    if (eql(command, "exit") or eql(command, "quit")) return false;

    if (eql(command, "help")) {
        ui.overlay = .command_palette;
        ui.focus = .overlay;
        ui.dirty = true;
        return true;
    }

    if (eql(command, "interrupt")) {
        if (worker.* != null and control.running.load(.seq_cst)) {
            control.interrupt_requested.store(true, .seq_cst);
            submitApprovalResponse(control, false);
            try appendTimelineEntry(ui, .system, .warning, "runtime", "Interrupt", "interrupt requested", .plain);
        } else {
            try appendTimelineEntry(ui, .system, .info, "runtime", "Interrupt", "no active command", .plain);
        }
        return true;
    }

    if (eql(command, "clear")) {
        clearTimeline(ui);
        return true;
    }

    if (eql(command, "status")) {
        ui.overlay = .status;
        ui.focus = .overlay;
        ui.dirty = true;
        return true;
    }

    if (eql(command, "model")) {
        if (worker.* != null and control.running.load(.seq_cst)) {
            try appendTimelineEntry(ui, .failure, .danger, "runtime", "Busy", "change the model after the active command finishes", .plain);
            return true;
        }
        const remainder = std.mem.trim(u8, input[1 + command.len ..], " ");
        if (remainder.len == 0) {
            try appendTimelineEntry(ui, .system, .info, "models", "Usage", "usage: /model <n|name>", .plain);
            return true;
        }
        const model_name = resolveModelSelectionVaxis(allocator, ui, remainder) catch |err| {
            const message = try friendlyRuntimeError(allocator, err);
            defer allocator.free(message);
            try appendTimelineEntry(ui, .failure, .danger, "models", "Model Change Failed", message, .plain);
            return true;
        };
        defer allocator.free(model_name);
        const saved = saveSelectedModelByName(allocator, model_name) catch |err| {
            const message = try friendlyRuntimeError(allocator, err);
            defer allocator.free(message);
            try appendTimelineEntry(ui, .failure, .danger, "models", "Model Change Failed", message, .plain);
            return true;
        };
        defer allocator.free(saved);
        try setVaxisSnapshot(ui, .{
            .project_name = ui.snapshot.project_name,
            .provider_type = ui.snapshot.provider_type,
            .model = model_name,
            .approval_mode = ui.snapshot.approval_mode,
            .global_status = ui.snapshot.global_status,
            .runtime_status = ui.snapshot.runtime_status,
            .current_actor = ui.snapshot.current_actor,
            .active_tool = ui.snapshot.active_tool,
            .active_lane = ui.snapshot.active_lane,
            .current_goal = ui.snapshot.current_goal,
            .last_tool_result = ui.snapshot.last_tool_result,
            .last_error = ui.snapshot.last_error,
            .last_log_path = ui.snapshot.last_log_path,
            .iteration = ui.snapshot.iteration,
        });
        try appendTimelineEntry(ui, .system, .success, "models", "Model Changed", saved, .plain);
        return true;
    }

    if (worker.* != null and control.running.load(.seq_cst)) {
        try appendTimelineEntry(ui, .failure, .danger, "runtime", "Busy", "wait for the active command to finish or press Ctrl+C", .plain);
        return true;
    }

    if (eql(command, "doctor")) {
        worker.* = try startWorker(allocator, queue, control, .doctor, "");
        ui.running_command = .doctor;
        ui.mode = .session;
        return true;
    }

    if (eql(command, "resume")) {
        worker.* = try startWorker(allocator, queue, control, .resume_run, "");
        ui.running_command = .resume_run;
        ui.mode = .session;
        return true;
    }

    if (eql(command, "models")) {
        worker.* = try startWorker(allocator, queue, control, .models, "");
        ui.running_command = .models;
        ui.mode = .session;
        return true;
    }

    const message = try std.fmt.allocPrint(allocator, "unknown command: /{s}", .{command});
    defer allocator.free(message);
    try appendTimelineEntry(ui, .failure, .danger, "help", "Unknown Command", message, .plain);
    return true;
}

fn submitComposerVaxis(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
) !bool {
    const owned = try ui.composer.toOwnedSlice();
    defer allocator.free(owned);
    const trimmed = trimAscii(owned);
    if (trimmed.len == 0) return true;
    return try handleSubmittedInputVaxis(allocator, ui, queue, control, worker, trimmed);
}

fn handleOverlayKey(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
    key: vaxis.Key,
) !bool {
    switch (ui.overlay) {
        .approval => {
            if (key.matches(vaxis.Key.escape, .{})) {
                try submitApprovalVaxis(ui, control, false);
                return true;
            }
            if (key.matches(vaxis.Key.tab, .{}) or key.matches(vaxis.Key.left, .{}) or key.matches(vaxis.Key.right, .{})) {
                ui.approval_choice = !ui.approval_choice;
                ui.dirty = true;
                return true;
            }
            if (key.matches('y', .{}) or key.matches('Y', .{})) {
                try submitApprovalVaxis(ui, control, true);
                return true;
            }
            if (key.matches('n', .{}) or key.matches('N', .{})) {
                try submitApprovalVaxis(ui, control, false);
                return true;
            }
            if (key.matches(vaxis.Key.enter, .{})) {
                try submitApprovalVaxis(ui, control, ui.approval_choice);
                return true;
            }
        },
        .command_palette => {
            if (key.matches(vaxis.Key.escape, .{})) {
                ui.overlay = .none;
                ui.focus = .composer;
                ui.dirty = true;
                return true;
            }
            if (key.matches(vaxis.Key.up, .{})) {
                ui.command_palette_index = if (ui.command_palette_index == 0) palette_commands.len - 1 else ui.command_palette_index - 1;
                ui.dirty = true;
                return true;
            }
            if (key.matches(vaxis.Key.down, .{})) {
                ui.command_palette_index = (ui.command_palette_index + 1) % palette_commands.len;
                ui.dirty = true;
                return true;
            }
            if (key.matches(vaxis.Key.enter, .{})) {
                try executePaletteSelection(allocator, ui, queue, control, worker);
                return true;
            }
        },
        .model_switcher => {
            if (key.matches(vaxis.Key.escape, .{})) {
                ui.overlay = .none;
                ui.focus = .composer;
                ui.dirty = true;
                return true;
            }
            if (ui.cached_models.len > 0 and key.matches(vaxis.Key.up, .{})) {
                ui.model_overlay_index = if (ui.model_overlay_index == 0) ui.cached_models.len - 1 else ui.model_overlay_index - 1;
                ui.dirty = true;
                return true;
            }
            if (ui.cached_models.len > 0 and key.matches(vaxis.Key.down, .{})) {
                ui.model_overlay_index = (ui.model_overlay_index + 1) % ui.cached_models.len;
                ui.dirty = true;
                return true;
            }
            if (key.matches(vaxis.Key.enter, .{})) {
                try selectOverlayModel(allocator, ui, control, worker);
                return true;
            }
        },
        .status => {
            if (key.matches(vaxis.Key.escape, .{}) or key.matches(vaxis.Key.enter, .{})) {
                ui.overlay = .none;
                ui.focus = .composer;
                ui.dirty = true;
                return true;
            }
        },
        .none => {},
    }
    return true;
}

fn handleVaxisKey(
    allocator: std.mem.Allocator,
    ui: *VaxisUiSession,
    queue: *RuntimeEventQueue,
    control: *RuntimeControl,
    worker: *?*WorkerTask,
    terminal_cols: u16,
    key: vaxis.Key,
) !bool {
    if (key.matches('c', .{ .ctrl = true })) {
        try vaxisInterruptOrExit(ui, control, worker.*);
        return !ui.should_exit;
    }

    if (ui.overlay != .none) {
        return try handleOverlayKey(allocator, ui, queue, control, worker, key);
    }

    if (key.matches('p', .{ .ctrl = true })) {
        ui.overlay = .command_palette;
        ui.focus = .overlay;
        ui.dirty = true;
        return true;
    }

    if (key.matches('t', .{ .ctrl = true })) {
        try openModelSwitcher(allocator, ui, queue, control, worker);
        return true;
    }

    if (key.matches('r', .{ .ctrl = true })) {
        ui.rail.pinned = !ui.rail.pinned;
        ui.dirty = true;
        return true;
    }

    if (key.matches(vaxis.Key.escape, .{})) {
        ui.focus = .composer;
        ui.dirty = true;
        return true;
    }

    if (key.matches(vaxis.Key.tab, .{})) {
        ui.focus = nextFocusTarget(ui, terminal_cols);
        ui.dirty = true;
        return true;
    }

    if (key.matches(vaxis.Key.page_up, .{})) {
        scrollTimelineUp(ui, 12);
        return true;
    }

    if (key.matches(vaxis.Key.page_down, .{})) {
        scrollTimelineDown(ui, 12);
        return true;
    }

    if (key.matches(vaxis.Key.end, .{})) {
        jumpTimelineToLatest(ui);
        return true;
    }

    if (ui.focus == .transcript or ui.focus == .rail) {
        if (key.matches(vaxis.Key.up, .{})) {
            scrollTimelineUp(ui, 3);
            return true;
        }
        if (key.matches(vaxis.Key.down, .{})) {
            scrollTimelineDown(ui, 3);
            return true;
        }
    }

    if (ui.focus == .composer) {
        if (key.matches(vaxis.Key.up, .{})) {
            scrollTimelineUp(ui, 3);
            return true;
        }
        if (key.matches(vaxis.Key.down, .{})) {
            scrollTimelineDown(ui, 3);
            return true;
        }
        if (key.matches(vaxis.Key.enter, .{})) {
            const keep_running = try submitComposerVaxis(allocator, ui, queue, control, worker);
            ui.mode = if (ui.timeline.items.len == 0 and ui.running_command == null) .landing else .session;
            ui.dirty = true;
            return keep_running;
        }
        try ui.composer.update(.{ .key_press = key });
        ui.mode = .session;
        ui.dirty = true;
        return true;
    }

    return true;
}

fn interactiveUiLoopVaxis(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    const cwd = try std.process.getCwdAlloc(allocator);

    var queue = RuntimeEventQueue{ .allocator = allocator };
    defer queue.deinit();

    var control = RuntimeControl{};
    var ui = try VaxisUiSession.init(allocator, cwd);
    defer ui.deinit();

    try setVaxisSnapshot(&ui, snapshotFromState(config, state, std.fs.path.basename(cwd)));

    var tty_buffer: [4096]u8 = undefined;
    var tty = try vaxis.Tty.init(&tty_buffer);
    defer tty.deinit();

    var vx = try vaxis.init(allocator, .{
        .system_clipboard_allocator = allocator,
        .kitty_keyboard_flags = .{ .report_events = true },
    });
    defer vx.deinit(allocator, tty.writer());

    var loop: vaxis.Loop(VaxisEvent) = .{
        .tty = &tty,
        .vaxis = &vx,
    };
    try loop.init();
    defer loop.stop();
    try loop.start();

    const initial_winsize = try vaxis.Tty.getWinsize(tty.fd);
    try vx.enterAltScreen(tty.writer());
    try vx.queryTerminal(tty.writer(), 1 * std.time.ns_per_s);
    try vx.setBracketedPaste(tty.writer(), true);
    try vx.resize(allocator, tty.writer(), initial_winsize);

    var worker: ?*WorkerTask = null;
    defer {
        if (worker) |task| {
            if (task.control.approval_pending) submitApprovalResponse(task.control, false);
            if (task.control.running.load(.seq_cst)) task.control.interrupt_requested.store(true, .seq_cst);
            if (task.thread) |thread| thread.join();
            allocator.destroy(task);
        }
    }

    var last_render_ms = std.time.milliTimestamp();

    while (!ui.should_exit) {
        if (worker) |task| {
            if (!task.control.running.load(.seq_cst)) {
                if (task.thread) |thread| thread.join();
                allocator.destroy(task);
                worker = null;
                ui.running_command = null;
                if (ui.timeline.items.len == 0) ui.mode = .landing;
                ui.dirty = true;
            }
        }

        try processRuntimeEventsVaxis(allocator, &ui, &queue);

        while (loop.tryEvent()) |event| {
            switch (event) {
                .winsize => |winsize| {
                    try vx.resize(allocator, tty.writer(), winsize);
                    ui.dirty = true;
                },
                .key_press => |key| {
                    const keep_running = try handleVaxisKey(allocator, &ui, &queue, &control, &worker, vx.screen.width, key);
                    if (!keep_running) {
                        ui.should_exit = true;
                        break;
                    }
                },
                .focus_in, .focus_out => {},
            }
        }

        const now_ms = std.time.milliTimestamp();
        if (ui.dirty or now_ms - last_render_ms >= 100) {
            var render_arena = std.heap.ArenaAllocator.init(allocator);
            defer render_arena.deinit();
            try renderVaxisUi(render_arena.allocator(), &vx, &ui);
            try vx.render(tty.writer());
            last_render_ms = now_ms;
            ui.dirty = false;
        }

        std.Thread.sleep(16 * std.time.ns_per_ms);
    }
}

const roman_bg = vaxis.Color.rgbFromUint(0x08090b);
const roman_panel = vaxis.Color.rgbFromUint(0x111111);
const roman_panel_alt = vaxis.Color.rgbFromUint(0x1a1918);
const roman_border = vaxis.Color.rgbFromUint(0x2d2b28);
const roman_ivory = vaxis.Color.rgbFromUint(0xe7dfd2);
const roman_muted = vaxis.Color.rgbFromUint(0x8d877d);
const roman_gold = vaxis.Color.rgbFromUint(0xc8a65a);
const roman_blue = vaxis.Color.rgbFromUint(0x5e95d8);
const roman_success = vaxis.Color.rgbFromUint(0x8fd19a);
const roman_danger = vaxis.Color.rgbFromUint(0xd47b72);

fn clampU16(value: usize) u16 {
    return @intCast(@min(value, @as(usize, std.math.maxInt(u16))));
}

fn clampI17(value: usize) i17 {
    return @intCast(@min(value, @as(usize, std.math.maxInt(i17))));
}

fn fillStyled(win: vaxis.Window, style: vaxis.Style) void {
    win.fill(.{
        .char = .{ .grapheme = " ", .width = 1 },
        .style = style,
    });
}

fn segmentStyle(style: vaxis.Style, text: []const u8) vaxis.Segment {
    return .{
        .text = text,
        .style = style,
    };
}

fn drawText(win: vaxis.Window, row: usize, col: usize, text: []const u8, style: vaxis.Style) void {
    if (row >= win.height or col >= win.width) return;
    const available = @as(usize, win.width) - col;
    const clipped = clipText(text, available);
    _ = win.printSegment(segmentStyle(style, clipped), .{
        .row_offset = clampU16(row),
        .col_offset = clampU16(col),
        .wrap = .none,
    });
}

fn drawSegments(win: vaxis.Window, row: usize, col: usize, segments: []const vaxis.Segment) void {
    if (row >= win.height or col >= win.width) return;
    _ = win.print(segments, .{
        .row_offset = clampU16(row),
        .col_offset = clampU16(col),
        .wrap = .none,
    });
}

fn drawWrapped(win: vaxis.Window, row: usize, col: usize, text: []const u8, style: vaxis.Style) usize {
    if (row >= win.height or col >= win.width) return row;
    const child = win.child(.{
        .x_off = clampI17(col),
        .y_off = clampI17(row),
        .width = win.width - clampU16(col),
        .height = win.height - clampU16(row),
    });
    const result = child.printSegment(segmentStyle(style, text), .{
        .wrap = .word,
    });
    return row + result.row + @as(usize, if (result.col > 0 or text.len == 0) 1 else 0);
}

fn centeredCol(total_width: usize, text: []const u8) usize {
    const width = displayWidth(text);
    if (width >= total_width) return 0;
    return (total_width - width) / 2;
}

fn shellStyle() vaxis.Style {
    return .{ .fg = roman_ivory, .bg = roman_bg };
}

fn mutedStyle() vaxis.Style {
    return .{ .fg = roman_muted, .bg = roman_bg };
}

fn panelStyle() vaxis.Style {
    return .{ .fg = roman_ivory, .bg = roman_panel };
}

fn panelAltStyle() vaxis.Style {
    return .{ .fg = roman_ivory, .bg = roman_panel_alt };
}

fn borderStyle() vaxis.Style {
    return .{ .fg = roman_border, .bg = roman_panel };
}

fn accentStyle() vaxis.Style {
    return .{ .fg = roman_blue, .bg = roman_panel_alt, .bold = true };
}

fn brandStyle() vaxis.Style {
    return .{ .fg = roman_ivory, .bg = roman_bg, .bold = true };
}

fn headingStyle() vaxis.Style {
    return .{ .fg = roman_gold, .bg = roman_bg, .bold = true };
}

fn overlayStyle() vaxis.Style {
    return .{ .fg = roman_ivory, .bg = roman_panel_alt };
}

fn toneStyle(kind: TimelineEntryKind, tone: ChatTone, bold: bool, highlight: HighlightKind) vaxis.Style {
    var style: vaxis.Style = .{
        .fg = roman_ivory,
        .bg = roman_bg,
        .bold = bold,
    };

    switch (kind) {
        .thinking => {
            style.fg = roman_muted;
            style.dim = true;
        },
        .tool => style.fg = roman_gold,
        .report => style.fg = roman_ivory,
        .final => {
            style.fg = roman_success;
            style.bold = true;
        },
        .system => style.fg = roman_muted,
        .failure => {
            style.fg = roman_danger;
            style.bold = true;
        },
        .user => style.fg = roman_ivory,
    }

    switch (tone) {
        .warning => style.fg = roman_gold,
        .danger => style.fg = roman_danger,
        .success => style.fg = roman_success,
        .agent => style.fg = roman_ivory,
        .tool => style.fg = roman_gold,
        .mission => style.fg = roman_ivory,
        .info => {},
    }

    if (highlight == .summary and kind == .report) {
        style.fg = roman_ivory;
    }

    return style;
}

fn textInputIsEmpty(input: *const vaxis.widgets.TextInput) bool {
    return input.buf.firstHalf().len + input.buf.secondHalf().len == 0;
}

fn shouldShowRail(ui: *const VaxisUiSession, terminal_cols: u16) bool {
    if (terminal_cols < 132) return false;
    return ui.rail.pinned or
        ui.pending_approval != null or
        ui.snapshot.current_goal.len > 0 or
        ui.snapshot.last_error.len > 0 or
        ui.snapshot.last_tool_result.len > 0;
}

fn timelineHeadingText(allocator: std.mem.Allocator, entry: TimelineEntry) ![]const u8 {
    return switch (entry.kind) {
        .user => try allocator.dupe(u8, "Mission"),
        .thinking => if (entry.actor.len > 0)
            try std.fmt.allocPrint(allocator, "{s} thinking", .{entry.actor})
        else
            try allocator.dupe(u8, "Thinking"),
        .tool => if (entry.title.len > 0)
            try std.fmt.allocPrint(allocator, "Tool • {s}", .{entry.title})
        else
            try allocator.dupe(u8, "Tool"),
        .report => if (entry.actor.len > 0)
            try std.fmt.allocPrint(allocator, "{s} report", .{entry.actor})
        else if (entry.title.len > 0)
            try allocator.dupe(u8, entry.title)
        else
            try allocator.dupe(u8, "Report"),
        .final => try allocator.dupe(u8, "Final Response"),
        .system => if (entry.title.len > 0) try allocator.dupe(u8, entry.title) else try allocator.dupe(u8, "System"),
        .failure => if (entry.title.len > 0) try allocator.dupe(u8, entry.title) else try allocator.dupe(u8, "Error"),
    };
}

fn appendWrappedVaxisLinesWithPrefix(
    allocator: std.mem.Allocator,
    lines: *std.ArrayList(VaxisRenderLine),
    text: []const u8,
    width: usize,
    tone: ChatTone,
    highlight: HighlightKind,
    kind: TimelineEntryKind,
    prefix: []const u8,
) !void {
    if (width == 0) return;
    const prefix_width = displayWidth(prefix);
    const content_width = if (prefix_width >= width) 1 else width - prefix_width;
    var source_lines = std.mem.splitScalar(u8, text, '\n');
    while (source_lines.next()) |source_line| {
        if (source_line.len == 0) {
            try lines.append(allocator, .{ .kind = kind, .tone = tone, .highlight = highlight });
            continue;
        }
        var remainder = source_line;
        while (displayWidth(remainder) > content_width) {
            const split_at = wrapTextByteIndex(remainder, content_width);
            const segment = trimAscii(remainder[0..split_at]);
            try lines.append(allocator, .{
                .text = try prefixedRenderText(allocator, prefix, segment),
                .kind = kind,
                .tone = tone,
                .highlight = highlight,
            });
            remainder = trimAscii(remainder[split_at..]);
        }
        try lines.append(allocator, .{
            .text = try prefixedRenderText(allocator, prefix, remainder),
            .kind = kind,
            .tone = tone,
            .highlight = highlight,
        });
    }
}

fn buildTimelineLinesVaxis(
    allocator: std.mem.Allocator,
    ui: *const VaxisUiSession,
    lines: *std.ArrayList(VaxisRenderLine),
    width: usize,
) !void {
    if (ui.timeline.items.len == 0) {
        try lines.append(allocator, .{
            .text = "No missions yet. Start with a brief objective or open the palette.",
            .kind = .system,
            .tone = .info,
        });
        return;
    }

    for (ui.timeline.items) |entry| {
        const heading = try timelineHeadingText(allocator, entry);
        try lines.append(allocator, .{
            .text = heading,
            .kind = entry.kind,
            .tone = entry.tone,
            .bold = true,
        });

        var preview_text: []const u8 = entry.text.items;
        if (entry.collapsed and !entry.streaming) {
            preview_text = try compactTextForUi(
                allocator,
                entry.text.items,
                if (entry.kind == .tool) 2 else 1,
                if (entry.kind == .tool) 200 else 140,
            );
        }
        try appendWrappedVaxisLinesWithPrefix(
            allocator,
            lines,
            preview_text,
            width,
            entry.tone,
            entry.highlight,
            entry.kind,
            "  ",
        );
        if (entry.collapsed and !entry.streaming) {
            try lines.append(allocator, .{
                .text = "  … secondary details collapsed",
                .kind = .thinking,
                .tone = .info,
            });
        }
        try lines.append(allocator, .{});
    }
}

fn buildRailLinesVaxis(
    allocator: std.mem.Allocator,
    ui: *const VaxisUiSession,
    lines: *std.ArrayList(VaxisRenderLine),
    width: usize,
) !void {
    const budget_tone: ChatTone = if (ui.snapshot.context_used_percent >= 85)
        .danger
    else if (ui.snapshot.context_used_percent >= 70)
        .warning
    else
        .info;
    try lines.append(allocator, .{ .text = "LIVE CONTEXT", .kind = .tool, .tone = .warning, .bold = true });
    const actor_line = try std.fmt.allocPrint(allocator, "actor  {s}", .{ui.snapshot.current_actor});
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, actor_line, width, .info, .plain, .system, "");
    const lane_line = try std.fmt.allocPrint(allocator, "lane   {s}", .{ui.snapshot.active_lane});
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, lane_line, width, .info, .plain, .system, "");
    const global_line = try std.fmt.allocPrint(allocator, "global {s}", .{ui.snapshot.global_status});
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, global_line, width, .info, .plain, .system, "");
    const runtime_line = try std.fmt.allocPrint(allocator, "runtime {s}", .{ui.snapshot.runtime_status});
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, runtime_line, width, .info, .plain, .system, "");
    const turn_line = try std.fmt.allocPrint(allocator, "loop   {d}/{d}", .{ ui.snapshot.iteration, ui.snapshot.max_iterations });
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, turn_line, width, .info, .plain, .system, "");
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "BUDGET", .kind = .tool, .tone = .warning, .bold = true });
    try appendWrappedVaxisLinesWithPrefix(
        allocator,
        lines,
        try std.fmt.allocPrint(allocator, "prompt est  {d} tok", .{ui.snapshot.estimated_prompt_tokens}),
        width,
        budget_tone,
        .plain,
        .system,
        "",
    );
    try appendWrappedVaxisLinesWithPrefix(
        allocator,
        lines,
        try std.fmt.allocPrint(allocator, "context left {d}", .{ui.snapshot.remaining_context_tokens}),
        width,
        budget_tone,
        .plain,
        .system,
        "",
    );
    try appendWrappedVaxisLinesWithPrefix(
        allocator,
        lines,
        try std.fmt.allocPrint(allocator, "used   {d}%", .{ui.snapshot.context_used_percent}),
        width,
        budget_tone,
        .plain,
        .system,
        "",
    );
    try appendWrappedVaxisLinesWithPrefix(
        allocator,
        lines,
        try std.fmt.allocPrint(allocator, "condensed {d}/{d}", .{ ui.snapshot.condensation_count, ui.snapshot.condensed_history_events }),
        width,
        .info,
        .plain,
        .system,
        "",
    );
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "GOAL", .kind = .tool, .tone = .warning, .bold = true });
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, if (ui.snapshot.current_goal.len > 0) ui.snapshot.current_goal else "idle", width, .info, .plain, .system, "");
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "LATEST", .kind = .tool, .tone = .warning, .bold = true });
    const latest = try compactTextForUi(allocator, if (ui.snapshot.last_tool_result.len > 0) ui.snapshot.last_tool_result else "none", 6, 260);
    try appendWrappedVaxisLinesWithPrefix(allocator, lines, latest, width, .info, .plain, .system, "");
    try lines.append(allocator, .{});
    try lines.append(allocator, .{ .text = "MODELS", .kind = .tool, .tone = .warning, .bold = true });
    if (ui.cached_models.len == 0) {
        try appendWrappedVaxisLinesWithPrefix(
            allocator,
            lines,
            if (ui.last_model_error.len > 0) ui.last_model_error else "Ctrl+T to inspect models",
            width,
            if (ui.last_model_error.len > 0) .danger else .info,
            .plain,
            if (ui.last_model_error.len > 0) .failure else .system,
            "",
        );
    } else {
        var index: usize = 0;
        while (index < ui.cached_models.len and index < 6) : (index += 1) {
            try lines.append(allocator, .{
                .text = try std.fmt.allocPrint(
                    allocator,
                    "{s} {d}. {s}",
                    .{ if (eql(ui.cached_models[index], ui.snapshot.model)) "*" else " ", index + 1, ui.cached_models[index] },
                ),
                .kind = .system,
                .tone = .info,
            });
        }
    }
    if (ui.snapshot.last_error.len > 0) {
        try lines.append(allocator, .{});
        try lines.append(allocator, .{ .text = "ERROR", .kind = .failure, .tone = .danger, .bold = true });
        try appendWrappedVaxisLinesWithPrefix(allocator, lines, ui.snapshot.last_error, width, .danger, .plain, .failure, "");
    }
}

fn drawSummaryStyled(win: vaxis.Window, row: usize, text: []const u8, style: vaxis.Style) void {
    if (row >= win.height) return;
    const clipped = clipText(text, win.width);
    if (std.mem.startsWith(u8, trimAscii(clipped), "- ")) {
        const segments = [_]vaxis.Segment{
            segmentStyle(.{ .fg = roman_gold, .bg = roman_bg, .bold = true }, "- "),
            segmentStyle(style, trimAscii(clipped)[2..]),
        };
        drawSegments(win, row, 0, &segments);
        return;
    }
    if (std.mem.indexOfScalar(u8, clipped, ':')) |colon_index| {
        const key = trimAscii(clipped[0..colon_index]);
        const rest = trimAscii(clipped[colon_index + 1 ..]);
        if (isSummaryKey(key)) {
            const segments = [_]vaxis.Segment{
                segmentStyle(.{ .fg = roman_gold, .bg = roman_bg, .bold = true }, key),
                segmentStyle(.{ .fg = roman_muted, .bg = roman_bg }, ": "),
                segmentStyle(style, rest),
            };
            drawSegments(win, row, 0, &segments);
            return;
        }
    }
    drawText(win, row, 0, clipped, style);
}

fn drawVaxisRenderLine(win: vaxis.Window, row: usize, line: VaxisRenderLine) void {
    const style = toneStyle(line.kind, line.tone, line.bold, line.highlight);
    switch (line.highlight) {
        .summary => drawSummaryStyled(win, row, line.text, style),
        .json => drawText(win, row, 0, line.text, .{ .fg = roman_blue, .bg = roman_bg, .dim = true }),
        else => drawText(win, row, 0, line.text, style),
    }
}

fn drawComposerCard(win: vaxis.Window, ui: *VaxisUiSession, title: []const u8, footer: []const u8) void {
    const outer = win.child(.{
        .width = win.width,
        .height = win.height,
        .border = .{
            .where = .all,
            .style = borderStyle(),
        },
    });
    fillStyled(outer, panelStyle());
    drawText(outer, 0, 0, title, .{ .fg = roman_gold, .bg = roman_panel, .bold = true });

    const input_row_y: usize = if (outer.height > 2) 1 else 0;
    const input_row = outer.child(.{
        .x_off = 0,
        .y_off = clampI17(input_row_y),
        .width = outer.width,
        .height = 1,
    });
    fillStyled(input_row, panelAltStyle());
    drawText(input_row, 0, 0, "▍", accentStyle());

    const input_field = input_row.child(.{
        .x_off = 2,
        .y_off = 0,
        .width = input_row.width -| 2,
        .height = 1,
    });
    fillStyled(input_field, panelAltStyle());

    if (textInputIsEmpty(&ui.composer)) {
        drawText(input_field, 0, 0, ui.composer_state.placeholder, .{ .fg = roman_muted, .bg = roman_panel_alt, .dim = true });
        if (ui.focus == .composer and ui.overlay == .none) input_field.showCursor(0, 0);
    } else {
        ui.composer.drawWithStyle(input_field, .{ .fg = roman_ivory, .bg = roman_panel_alt });
    }

    if (outer.height > 2) {
        drawText(outer, outer.height - 1, 0, footer, .{ .fg = roman_muted, .bg = roman_panel, .dim = true });
    }
}

fn renderLandingUi(allocator: std.mem.Allocator, root: vaxis.Window, ui: *VaxisUiSession) !void {
    _ = allocator;
    drawText(root, 1, 2, "contubernium", .{ .fg = roman_muted, .bg = roman_bg, .bold = true });

    const wordmark = "CONTUBERNIUM";
    const subtitle = "Roman command structure for modern local-first missions";
    const brand_row = if (root.height > 18) (@as(usize, root.height) / 2) - 6 else 3;
    drawText(root, brand_row, centeredCol(root.width, wordmark), wordmark, brandStyle());
    drawText(root, brand_row + 2, centeredCol(root.width, subtitle), subtitle, .{ .fg = roman_gold, .bg = roman_bg });

    const composer_width = @min(@as(usize, root.width) -| 10, 78);
    const composer_height: usize = 4;
    const composer_x = if (root.width > composer_width) (@as(usize, root.width) - composer_width) / 2 else 0;
    const composer_y = brand_row + 4;
    const composer_win = root.child(.{
        .x_off = clampI17(composer_x),
        .y_off = clampI17(composer_y),
        .width = clampU16(composer_width),
        .height = clampU16(composer_height),
    });
    drawComposerCard(composer_win, ui, "Mission", "Enter submit  •  Ctrl+P palette  •  Ctrl+T models");

    drawText(root, composer_y + composer_height + 1, centeredCol(root.width, "Resume   Doctor   Models"), "Resume   Doctor   Models", .{ .fg = roman_blue, .bg = roman_bg });
    drawText(root, root.height - 2, 2, ui.cwd, .{ .fg = roman_muted, .bg = roman_bg, .dim = true });
    drawText(root, root.height - 2, @max(@as(usize, root.width), 24) -| 18, "tab focus  •  ctrl+c", .{ .fg = roman_muted, .bg = roman_bg, .dim = true });
}

fn renderSessionUi(allocator: std.mem.Allocator, root: vaxis.Window, ui: *VaxisUiSession) !void {
    const shell = root.child(.{
        .x_off = 1,
        .y_off = 1,
        .width = root.width -| 2,
        .height = root.height -| 2,
    });
    fillStyled(shell, shellStyle());

    const top_strip = shell.child(.{
        .x_off = 1,
        .y_off = 0,
        .width = shell.width -| 2,
        .height = 1,
    });
    const strip_text = try std.fmt.allocPrint(
        allocator,
        "Contubernium  •  actor {s}  •  lane {s}  •  global {s}",
        .{ ui.snapshot.current_actor, ui.snapshot.active_lane, ui.snapshot.global_status },
    );
    drawText(top_strip, 0, 0, strip_text, .{ .fg = roman_ivory, .bg = roman_bg, .bold = true });

    const meta_text = try std.fmt.allocPrint(
        allocator,
        "{s}  •  {s}  •  ctx ~{d} left  •  turn {d}/{d}",
        .{
            ui.snapshot.provider_type,
            ui.snapshot.model,
            ui.snapshot.remaining_context_tokens,
            ui.snapshot.iteration,
            ui.snapshot.max_iterations,
        },
    );
    const meta_col = if (displayWidth(meta_text) + 1 < top_strip.width) @as(usize, top_strip.width) - displayWidth(meta_text) else 0;
    drawText(top_strip, 0, meta_col, meta_text, .{ .fg = roman_muted, .bg = roman_bg });

    const composer_height: usize = 4;
    const main_top: usize = 2;
    const composer_y = @as(usize, shell.height) -| composer_height;
    const rail_width: usize = if (shouldShowRail(ui, shell.width)) 30 else 0;
    const gap_width: usize = if (rail_width > 0) 2 else 0;
    const transcript_width = @as(usize, shell.width) -| 2 -| rail_width -| gap_width;
    const transcript_height = composer_y -| main_top;

    const transcript_win = shell.child(.{
        .x_off = 1,
        .y_off = clampI17(main_top),
        .width = clampU16(transcript_width),
        .height = clampU16(transcript_height),
    });
    fillStyled(transcript_win, shellStyle());

    var timeline_lines: std.ArrayList(VaxisRenderLine) = .empty;
    defer timeline_lines.deinit(allocator);
    try buildTimelineLinesVaxis(allocator, ui, &timeline_lines, transcript_width);

    var row_offset: usize = 0;
    if (!ui.viewport.follow_latest) {
        drawText(transcript_win, 0, 0, "Detached from live output  •  End jumps to latest", .{ .fg = roman_blue, .bg = roman_bg });
        row_offset = 1;
    }

    const visible_height = transcript_height -| row_offset;
    const total_lines = timeline_lines.items.len;
    const hidden_bottom = @min(ui.viewport.scroll_offset, if (total_lines > 0) total_lines - 1 else 0);
    const visible_end = total_lines - hidden_bottom;
    const visible_start = if (visible_end > visible_height) visible_end - visible_height else 0;
    var row: usize = 0;
    while (row < visible_height and visible_start + row < visible_end) : (row += 1) {
        drawVaxisRenderLine(transcript_win.child(.{
            .x_off = 0,
            .y_off = clampI17(row + row_offset),
            .width = transcript_win.width,
            .height = 1,
        }), 0, timeline_lines.items[visible_start + row]);
    }

    if (rail_width > 0) {
        const rail_shell = shell.child(.{
            .x_off = clampI17(1 + transcript_width + gap_width),
            .y_off = clampI17(main_top),
            .width = clampU16(rail_width),
            .height = clampU16(transcript_height),
            .border = .{
                .where = .all,
                .style = .{ .fg = roman_border, .bg = roman_panel },
            },
        });
        fillStyled(rail_shell, panelStyle());
        var rail_lines: std.ArrayList(VaxisRenderLine) = .empty;
        defer rail_lines.deinit(allocator);
        try buildRailLinesVaxis(allocator, ui, &rail_lines, rail_width - 2);
        var rail_row: usize = 0;
        while (rail_row < rail_shell.height and rail_row < rail_lines.items.len) : (rail_row += 1) {
            drawVaxisRenderLine(rail_shell.child(.{
                .x_off = 0,
                .y_off = clampI17(rail_row),
                .width = rail_shell.width,
                .height = 1,
            }), 0, rail_lines.items[rail_row]);
        }
    }

    const composer_win = shell.child(.{
        .x_off = 1,
        .y_off = clampI17(composer_y),
        .width = shell.width -| 2,
        .height = clampU16(composer_height),
    });
    drawComposerCard(composer_win, ui, "Mission", "Tab focus  •  Ctrl+P palette  •  Ctrl+T models  •  Ctrl+R rail  •  Ctrl+C interrupt");
}

fn renderStatusOverlay(allocator: std.mem.Allocator, root: vaxis.Window, ui: *const VaxisUiSession) !void {
    const panel_width = @min(@as(usize, root.width) -| 8, 72);
    const panel_height: usize = 12;
    const panel = root.child(.{
        .x_off = clampI17((@as(usize, root.width) -| panel_width) / 2),
        .y_off = clampI17((@as(usize, root.height) -| panel_height) / 2),
        .width = clampU16(panel_width),
        .height = clampU16(panel_height),
        .border = .{
            .where = .all,
            .style = .{ .fg = roman_blue, .bg = roman_panel_alt },
        },
    });
    fillStyled(panel, overlayStyle());
    drawText(panel, 0, 0, "Runtime Status", .{ .fg = roman_gold, .bg = roman_panel_alt, .bold = true });

    const status = try renderStatusBlock(allocator, ui.snapshot);
    _ = drawWrapped(panel, 2, 0, status, .{ .fg = roman_ivory, .bg = roman_panel_alt });
    drawText(panel, panel.height - 1, 0, "Esc closes", .{ .fg = roman_muted, .bg = roman_panel_alt, .dim = true });
}

fn renderCommandOverlay(allocator: std.mem.Allocator, root: vaxis.Window, ui: *const VaxisUiSession) !void {
    const panel_width = @min(@as(usize, root.width) -| 8, 64);
    const panel_height = palette_commands.len + 4;
    const panel = root.child(.{
        .x_off = clampI17((@as(usize, root.width) -| panel_width) / 2),
        .y_off = clampI17((@as(usize, root.height) -| panel_height) / 2),
        .width = clampU16(panel_width),
        .height = clampU16(panel_height),
        .border = .{
            .where = .all,
            .style = .{ .fg = roman_blue, .bg = roman_panel_alt },
        },
    });
    fillStyled(panel, overlayStyle());
    drawText(panel, 0, 0, "Command Palette", .{ .fg = roman_gold, .bg = roman_panel_alt, .bold = true });
    for (palette_commands, 0..) |entry, index| {
        const selected = index == ui.command_palette_index;
        const line = try std.fmt.allocPrint(allocator, "{s} {s}  {s}", .{ if (selected) ">" else " ", entry.label, entry.description });
        drawText(
            panel,
            index + 2,
            0,
            line,
            .{
                .fg = if (selected) roman_blue else roman_ivory,
                .bg = roman_panel_alt,
                .bold = selected,
            },
        );
    }
}

fn renderModelsOverlay(allocator: std.mem.Allocator, root: vaxis.Window, ui: *const VaxisUiSession) !void {
    const panel_width = @min(@as(usize, root.width) -| 8, 72);
    const panel_height: usize = 12;
    const panel = root.child(.{
        .x_off = clampI17((@as(usize, root.width) -| panel_width) / 2),
        .y_off = clampI17((@as(usize, root.height) -| panel_height) / 2),
        .width = clampU16(panel_width),
        .height = clampU16(panel_height),
        .border = .{
            .where = .all,
            .style = .{ .fg = roman_blue, .bg = roman_panel_alt },
        },
    });
    fillStyled(panel, overlayStyle());
    drawText(panel, 0, 0, "Model Switcher", .{ .fg = roman_gold, .bg = roman_panel_alt, .bold = true });
    if (ui.cached_models.len == 0) {
        drawText(panel, 2, 0, "Fetching provider model roster…", .{ .fg = roman_muted, .bg = roman_panel_alt, .dim = true });
        if (ui.last_model_error.len > 0) drawText(panel, 4, 0, ui.last_model_error, .{ .fg = roman_danger, .bg = roman_panel_alt });
        return;
    }
    var row: usize = 0;
    while (row < ui.cached_models.len and row < panel.height - 3) : (row += 1) {
        const model = ui.cached_models[row];
        const selected = row == ui.model_overlay_index;
        const line = try std.fmt.allocPrint(
            allocator,
            "{s} {d}. {s}{s}",
            .{ if (selected) ">" else " ", row + 1, model, if (eql(model, ui.snapshot.model)) "  (current)" else "" },
        );
        drawText(
            panel,
            row + 2,
            0,
            line,
            .{
                .fg = if (selected) roman_blue else roman_ivory,
                .bg = roman_panel_alt,
                .bold = selected,
            },
        );
    }
}

fn renderApprovalOverlay(root: vaxis.Window, ui: *const VaxisUiSession) void {
    const panel_width = @min(@as(usize, root.width) -| 8, 76);
    const panel_height: usize = 11;
    const panel = root.child(.{
        .x_off = clampI17((@as(usize, root.width) -| panel_width) / 2),
        .y_off = clampI17((@as(usize, root.height) -| panel_height) / 2),
        .width = clampU16(panel_width),
        .height = clampU16(panel_height),
        .border = .{
            .where = .all,
            .style = .{ .fg = roman_gold, .bg = roman_panel_alt },
        },
    });
    fillStyled(panel, overlayStyle());
    drawText(panel, 0, 0, "Approval Required", .{ .fg = roman_gold, .bg = roman_panel_alt, .bold = true });
    if (ui.pending_approval) |approval| {
        drawText(panel, 2, 0, approval.tool_name, .{ .fg = roman_ivory, .bg = roman_panel_alt, .bold = true });
        _ = drawWrapped(panel, 4, 0, approval.detail, .{ .fg = roman_ivory, .bg = roman_panel_alt });
    }
    const approve_style: vaxis.Style = .{
        .fg = if (ui.approval_choice) roman_panel_alt else roman_ivory,
        .bg = if (ui.approval_choice) roman_success else roman_panel_alt,
        .bold = true,
    };
    const deny_style: vaxis.Style = .{
        .fg = if (!ui.approval_choice) roman_panel_alt else roman_ivory,
        .bg = if (!ui.approval_choice) roman_danger else roman_panel_alt,
        .bold = true,
    };
    const button_row = panel.height - 2;
    drawSegments(panel, button_row, 0, &.{
        segmentStyle(approve_style, " Approve "),
        segmentStyle(.{ .fg = roman_muted, .bg = roman_panel_alt }, "   "),
        segmentStyle(deny_style, " Deny "),
    });
}

fn renderOverlay(allocator: std.mem.Allocator, root: vaxis.Window, ui: *const VaxisUiSession) !void {
    switch (ui.overlay) {
        .none => {},
        .command_palette => try renderCommandOverlay(allocator, root, ui),
        .model_switcher => try renderModelsOverlay(allocator, root, ui),
        .approval => renderApprovalOverlay(root, ui),
        .status => try renderStatusOverlay(allocator, root, ui),
    }
}

fn renderVaxisUi(allocator: std.mem.Allocator, vx: *vaxis.Vaxis, ui: *VaxisUiSession) !void {
    var root = vx.window();
    fillStyled(root, shellStyle());
    if (ui.mode == .landing and ui.timeline.items.len == 0 and ui.running_command == null and ui.overlay == .none) {
        try renderLandingUi(allocator, root, ui);
    } else {
        try renderSessionUi(allocator, root, ui);
    }
    try renderOverlay(allocator, root, ui);
    if (ui.focus != .composer or ui.overlay != .none) root.hideCursor();
}

fn makeTestSnapshot() TuiSnapshot {
    return .{
        .project_name = "Contubernium",
        .provider_type = "ollama-native",
        .model = "qwen2.5-coder:7b",
        .approval_mode = "guarded",
        .global_status = "idle",
        .runtime_status = "ready",
        .current_actor = "decanus",
        .active_lane = "command",
        .current_goal = "Test the command tent",
    };
}

fn initTestTui(allocator: std.mem.Allocator) TuiSession {
    return .{
        .allocator = allocator,
        .snapshot = makeTestSnapshot(),
    };
}

fn testQueueEmit(context: ?*anyopaque, event: RuntimeUiEvent) void {
    const queue: *RuntimeEventQueue = @ptrCast(@alignCast(context.?));
    queue.push(event);
}

test "parseUiFlavor defaults to vaxis" {
    const testing = std.testing;
    try testing.expectEqual(UiFlavor.vaxis, try parseUiFlavor(&.{}));
}

test "parseUiFlavor accepts legacy flag" {
    const testing = std.testing;
    try testing.expectEqual(UiFlavor.legacy, try parseUiFlavor(&.{"--legacy"}));
}

test "timelineKindForRuntimeLog maps final and danger entries" {
    const testing = std.testing;
    try testing.expectEqual(TimelineEntryKind.final, timelineKindForRuntimeLog(.{
        .kind = .log,
        .tone = .success,
        .title = "Final Response",
    }));
    try testing.expectEqual(TimelineEntryKind.failure, timelineKindForRuntimeLog(.{
        .kind = .log,
        .tone = .danger,
        .title = "Runtime Error",
    }));
}

test "shouldShowRail stays contextual" {
    const testing = std.testing;
    var ui = try VaxisUiSession.init(testing.allocator, "/tmp/project");
    defer ui.deinit();

    try setVaxisSnapshot(&ui, .{
        .project_name = "Contubernium",
        .provider_type = "ollama-native",
        .model = "gpt-oss:20b",
        .approval_mode = "guarded",
        .global_status = "running",
        .runtime_status = "running",
        .current_actor = "decanus",
        .active_tool = "",
        .active_lane = "command",
        .current_goal = "Investigate the redesign",
        .last_tool_result = "",
        .last_error = "",
        .last_log_path = "",
        .iteration = 3,
    });

    try testing.expect(shouldShowRail(&ui, 140));
    try testing.expect(!shouldShowRail(&ui, 100));
}

test "visibleInputWindow handles zero width" {
    const testing = std.testing;
    const view = visibleInputWindow("salve", 3, 0);
    try testing.expectEqualStrings("", view.text);
    try testing.expectEqual(@as(usize, 0), view.cursor_col);
}

test "visibleInputWindow keeps cursor visible at tail" {
    const testing = std.testing;
    const view = visibleInputWindow("abcdefghij", 10, 4);
    try testing.expectEqualStrings("ghij", view.text);
    try testing.expectEqual(@as(usize, 4), view.cursor_col);
}

test "currentLaneForState returns command for decanus" {
    const testing = std.testing;
    var state = AppState{};
    state.current_actor = "decanus";
    try testing.expectEqualStrings("command", currentLaneForState(state));
}

test "updateCachedModels parses formatted roster" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    try updateCachedModels(testing.allocator, &tui, "[1] gpt-oss:20b\n[2] qwen3-coder:latest (current)\n");
    try testing.expectEqual(@as(usize, 2), tui.cached_models.len);
    try testing.expectEqualStrings("gpt-oss:20b", tui.cached_models[0]);
    try testing.expectEqualStrings("qwen3-coder:latest", tui.cached_models[1]);
}

test "appendWrappedLines respects width boundaries" {
    const testing = std.testing;
    var lines: std.ArrayList(RenderLine) = .empty;
    defer lines.deinit(testing.allocator);

    try appendWrappedLines(testing.allocator, &lines, "alpha beta gamma", 5, .info, .plain);
    try testing.expect(lines.items.len >= 3);
    for (lines.items) |line| {
        try testing.expect(line.text.len <= 5);
    }
}

test "displayWidth counts wide glyphs as terminal cells" {
    const testing = std.testing;
    try testing.expectEqual(@as(usize, 4), displayWidth("A🚀B"));
}

test "appendWrappedLines keeps wide glyphs inside the target width" {
    const testing = std.testing;
    var lines: std.ArrayList(RenderLine) = .empty;
    defer lines.deinit(testing.allocator);

    try appendWrappedLines(testing.allocator, &lines, "alpha 🚀 beta gamma", 8, .info, .plain);
    try testing.expect(lines.items.len >= 2);
    for (lines.items) |line| {
        try testing.expect(displayWidth(line.text) <= 8);
    }
}

test "buildRenderFrame places cursor after prompt and input" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    try tui.input.appendSlice(testing.allocator, "salve");
    tui.cursor = tui.input.items.len;

    const frame = try buildRenderFrame(testing.allocator, &tui, .{ .rows = 24, .cols = 80 });
    defer testing.allocator.free(frame.screen);

    try testing.expectEqual(@as(usize, 23), frame.cursor_row);
    try testing.expectEqual(input_prompt.len + 1 + tui.cursor, frame.cursor_col);
    try testing.expect(std.mem.indexOf(u8, frame.screen, input_prompt) != null);
    try testing.expect(std.mem.indexOf(u8, frame.screen, "salve") != null);
}

test "buildRenderFrame includes sidebar on wide terminals" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    const frame = try buildRenderFrame(testing.allocator, &tui, .{ .rows = 24, .cols = 140 });
    defer testing.allocator.free(frame.screen);

    try testing.expect(std.mem.indexOf(u8, frame.screen, "LIVE CONTEXT") != null);
}

test "buildRenderFrame omits sidebar on narrow terminals" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    const frame = try buildRenderFrame(testing.allocator, &tui, .{ .rows = 24, .cols = 90 });
    defer testing.allocator.free(frame.screen);

    try testing.expect(std.mem.indexOf(u8, frame.screen, "LIVE CONTEXT") == null);
}

test "buildRenderFrame keeps cursor inside tiny terminal bounds" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    try tui.input.appendSlice(testing.allocator, "abc");
    tui.cursor = tui.input.items.len;

    const frame = try buildRenderFrame(testing.allocator, &tui, .{ .rows = 8, .cols = 12 });
    defer testing.allocator.free(frame.screen);

    try testing.expect(frame.cursor_row <= 8);
    try testing.expect(frame.cursor_col <= 12);
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
    defer testing.allocator.free(result.stdout);

    try testing.expect(result.exit_code == 0);
    try testing.expect(std.mem.indexOf(u8, result.stdout, "README.md") != null);
    try testing.expect(std.mem.indexOf(u8, result.stdout, ".git/") == null);
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
    state.current_actor = "artifex";
    state.agent_loop.active_tool = "artifex";
    state.agent_loop.iteration = 4;
    state.agent_loop.max_iterations = 24;
    state.agent_loop.last_tool_result = "read_file README.md";
    state.runtime_session.status = "running";
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

test "setTuiSnapshot clones strings" {
    const testing = std.testing;
    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    var actor = try testing.allocator.dupe(u8, "artifex");
    defer testing.allocator.free(actor);

    try setTuiSnapshot(&tui, .{
        .project_name = "Contubernium",
        .provider_type = "ollama-native",
        .model = "qwen2.5-coder:7b",
        .approval_mode = "guarded",
        .global_status = "planning",
        .runtime_status = "running",
        .current_actor = actor,
        .active_tool = "artifex",
        .active_lane = "frontend",
        .current_goal = "Investigate crash",
        .last_error = "",
        .last_log_path = "",
        .iteration = 2,
    });

    actor[0] = 'X';
    try testing.expectEqualStrings("artifex", tui.snapshot.current_actor);
    try testing.expectEqualStrings("Investigate crash", tui.snapshot.current_goal);
}

test "processRuntimeEvents keeps snapshot data after freeing events" {
    const testing = std.testing;
    var queue = RuntimeEventQueue{ .allocator = testing.allocator };
    defer queue.deinit();

    var tui = initTestTui(testing.allocator);
    defer tui.deinit();

    queue.push(.{
        .kind = .state_snapshot,
        .global_status = "waiting_on_tool",
        .runtime_status = "running_tool",
        .current_actor = "artifex",
        .active_tool = "artifex",
        .active_lane = "frontend",
        .current_goal = "Repair the command tent",
        .last_tool_result = "read_file README.md\nContubernium is a Roman-command scaffold.",
        .iteration = 7,
    });

    try processRuntimeEvents(testing.allocator, &tui, &queue);

    try testing.expectEqualStrings("artifex", tui.snapshot.current_actor);
    try testing.expectEqualStrings("frontend", tui.snapshot.active_lane);
    try testing.expectEqualStrings("Repair the command tent", tui.snapshot.current_goal);
    try testing.expect(std.mem.indexOf(u8, tui.snapshot.last_tool_result, "README.md") != null);
    try testing.expectEqual(@as(usize, 7), tui.snapshot.iteration);

    const frame = try buildRenderFrame(testing.allocator, &tui, .{ .rows = 24, .cols = 140 });
    defer testing.allocator.free(frame.screen);
    try testing.expect(std.mem.indexOf(u8, frame.screen, "actor: artifex") != null);
    try testing.expect(std.mem.indexOf(u8, frame.screen, "BUDGET") != null);
}

test "toneForOutcome treats interrupted runs as danger" {
    const testing = std.testing;
    var state = AppState{};
    state.runtime_session.status = "interrupted";
    try testing.expectEqual(ChatTone.danger, toneForOutcome(state));
}

fn stdoutPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stdout().deprecatedWriter().print(fmt, args);
}

fn stderrPrint(comptime fmt: []const u8, args: anytype) !void {
    try std.fs.File.stderr().deprecatedWriter().print(fmt, args);
}
