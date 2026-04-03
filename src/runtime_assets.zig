const std = @import("std");
const embedded = @import("embedded_assets.zig");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const provider = @import("runtime_provider.zig");
const max_file_bytes = core.max_file_bytes;
const runtime_dir_name = core.runtime_dir_name;
const default_state_path = core.default_state_path;
const default_config_path = core.default_config_path;
const default_logs_dir = core.default_logs_dir;
const default_sessions_dir = core.default_sessions_dir;
const default_session_index_path = core.default_session_index_path;
const default_project_memory_path = core.default_project_memory_path;
const default_global_memory_path = core.default_global_memory_path;
const default_architecture_path = core.default_architecture_path;
const default_plan_path = core.default_plan_path;
const default_project_context_path = core.default_project_context_path;
const global_session_index_filename = core.global_session_index_filename;
const max_list_files_entries = core.max_list_files_entries;
const legacy_default_max_iterations = core.legacy_default_max_iterations;
const default_max_iterations = core.default_max_iterations;
const default_context_window_tokens = core.default_context_window_tokens;
const default_response_reserve_tokens = core.default_response_reserve_tokens;
const default_tool_timeout_ms = core.default_tool_timeout_ms;
const default_max_project_memory_chars = core.default_max_project_memory_chars;
const default_max_global_memory_chars = core.default_max_global_memory_chars;
const legacy_memory_format_version = core.legacy_memory_format_version;
const global_memory_format_version = core.global_memory_format_version;
const session_record_format_version = core.session_record_format_version;
const session_index_format_version = core.session_index_format_version;
const global_session_index_format_version = core.global_session_index_format_version;
const Actor = core.Actor;
const Lane = core.Lane;
const GlobalStatus = core.GlobalStatus;
const LoopStatus = core.LoopStatus;
const RuntimeStatus = core.RuntimeStatus;
const TaskStatus = core.TaskStatus;
const InvocationStatus = core.InvocationStatus;
const InvocationResultStatus = core.InvocationResultStatus;
const ApprovalStatus = core.ApprovalStatus;
const ApprovalKind = core.ApprovalKind;
const LoopStepKind = core.LoopStepKind;
const Mission = core.Mission;
const Invocation = core.Invocation;
const InvocationResult = core.InvocationResult;
const ApprovalRequest = core.ApprovalRequest;
const LoopStep = core.LoopStep;
const StateSnapshot = core.StateSnapshot;
const AppConfig = core.AppConfig;
const ProviderConfig = core.ProviderConfig;
const PathsConfig = core.PathsConfig;
const PolicyConfig = core.PolicyConfig;
const ContextConfig = core.ContextConfig;
const AppState = core.AppState;
const AgentLoop = core.AgentLoop;
const ContextBudgetState = core.ContextBudgetState;
const RuntimeErrorContext = core.RuntimeErrorContext;
const RuntimeFailure = core.RuntimeFailure;
const RuntimeFailureContextSpec = core.RuntimeFailureContextSpec;
const RuntimeSession = core.RuntimeSession;
const HistoryEntry = core.HistoryEntry;
const IntermediateResult = core.IntermediateResult;
const AgentTool = core.AgentTool;
const AgentTools = core.AgentTools;
const TaskLane = core.TaskLane;
const Tasks = core.Tasks;
const ToolRequest = core.ToolRequest;
const RuntimeToolKind = core.RuntimeToolKind;
const ToolApprovalGate = core.ToolApprovalGate;
const RuntimeToolSpec = core.RuntimeToolSpec;
const ValidatedToolRequest = core.ValidatedToolRequest;
const ToolRequestValidation = core.ToolRequestValidation;
const DecanusDecision = core.DecanusDecision;
const SpecialistResult = core.SpecialistResult;
const SmokeResponse = core.SmokeResponse;
const ProviderResponse = core.ProviderResponse;
const CommandResult = core.CommandResult;
const StepOutcome = core.StepOutcome;
const PromptMode = core.PromptMode;
const PromptBudgetEstimate = core.PromptBudgetEstimate;
const RuntimeMemorySpec = core.RuntimeMemorySpec;
const RuntimeMemoryLayer = core.RuntimeMemoryLayer;
const RuntimeMemorySnapshot = core.RuntimeMemorySnapshot;
const PromptBuildResult = core.PromptBuildResult;
const GlobalAssetLayout = core.GlobalAssetLayout;
const AgentCallSpec = core.AgentCallSpec;
const ResolvedAgentCall = core.ResolvedAgentCall;
const ResolvedSpecialistInvocation = core.ResolvedSpecialistInvocation;
const StateManager = core.StateManager;
const ToolExecutionOutcome = core.ToolExecutionOutcome;
const ToolRequestExecution = core.ToolRequestExecution;
const RuntimeRunLog = core.RuntimeRunLog;
const SessionRecord = core.SessionRecord;
const SessionIndexEntry = core.SessionIndexEntry;
const SessionIndex = core.SessionIndex;
const GlobalSessionIndexEntry = core.GlobalSessionIndexEntry;
const GlobalSessionIndex = core.GlobalSessionIndex;
const RuntimeLogEvent = core.RuntimeLogEvent;
const RuntimeLogEventSpec = core.RuntimeLogEventSpec;
const ChatTone = core.ChatTone;
const HighlightKind = core.HighlightKind;
const TuiSnapshot = core.TuiSnapshot;
const cloneTuiSnapshot = core.cloneTuiSnapshot;
const freeTuiSnapshot = core.freeTuiSnapshot;
const setOwnedSnapshot = core.setOwnedSnapshot;
const WorkerCommandKind = core.WorkerCommandKind;
const RuntimeUiEventKind = core.RuntimeUiEventKind;
const RuntimeUiEvent = core.RuntimeUiEvent;
const RuntimeEventQueue = core.RuntimeEventQueue;
const cloneRuntimeUiEvent = core.cloneRuntimeUiEvent;
const freeRuntimeUiEvent = core.freeRuntimeUiEvent;
const freeRuntimeUiEvents = core.freeRuntimeUiEvents;
const RuntimeControl = core.RuntimeControl;
const WorkerTask = core.WorkerTask;
const RuntimeHooks = core.RuntimeHooks;
const OllamaTagsResponse = core.OllamaTagsResponse;
const OllamaModel = core.OllamaModel;
const OllamaChatResponse = core.OllamaChatResponse;
const OllamaChatStreamChunk = core.OllamaChatStreamChunk;
const OllamaMessage = core.OllamaMessage;
const OllamaToolCall = core.OllamaToolCall;
const OllamaToolFunction = core.OllamaToolFunction;
const OllamaToolArguments = core.OllamaToolArguments;
const OpenAIModelsResponse = core.OpenAIModelsResponse;
const OpenAIModel = core.OpenAIModel;
const OpenAIChatResponse = core.OpenAIChatResponse;
const OpenAIChoice = core.OpenAIChoice;
const OpenAIMessage = core.OpenAIMessage;
const OpenAIErrorEnvelope = core.OpenAIErrorEnvelope;
const OpenAIToolCall = core.OpenAIToolCall;
const OpenAIToolFunction = core.OpenAIToolFunction;
const usablePromptTokenWindow = core.usablePromptTokenWindow;
const ensureLoopBudget = core.ensureLoopBudget;
const resolvedApprovalMode = core.resolvedApprovalMode;
const resolvedContextBudget = core.resolvedContextBudget;
const resolveModelPolicy = core.resolveModelPolicy;
const syncConfigProviderMirrors = core.syncConfigProviderMirrors;
const runtimeModelPolicyLog = core.runtimeModelPolicyLog;
const buildStateSnapshot = core.buildStateSnapshot;
const snapshotFromState = core.snapshotFromState;
const compactTextForUi = core.compactTextForUi;
const pluralSuffix = core.pluralSuffix;
const writeToolRequestLabel = core.writeToolRequestLabel;
const summarizeToolRequestsForUi = core.summarizeToolRequestsForUi;
const summarizeDecanusDecisionForUi = core.summarizeDecanusDecisionForUi;
const summarizeSpecialistResultForUi = core.summarizeSpecialistResultForUi;
const pollInput = core.pollInput;
const DecodedScalar = core.DecodedScalar;
const decodeUtf8Scalar = core.decodeUtf8Scalar;
const safeUtf8PrefixByBytes = core.safeUtf8PrefixByBytes;
const actorName = core.actorName;
const maybeActorName = core.maybeActorName;
const laneName = core.laneName;
const parseActor = core.parseActor;
const parseInvocationResultStatus = core.parseInvocationResultStatus;
const buildRuntimeFailure = core.buildRuntimeFailure;
const stateManager = core.stateManager;
const recordRuntimeFailure = core.recordRuntimeFailure;
const clearRuntimeFailure = core.clearRuntimeFailure;
const currentLaneForState = core.currentLaneForState;
const toneForOutcome = core.toneForOutcome;
const emitLog = core.emitLog;
const emitStreamStart = core.emitStreamStart;
const emitStreamChunk = core.emitStreamChunk;
const emitStreamFinalize = core.emitStreamFinalize;
const emitStateSnapshot = core.emitStateSnapshot;
const markInterrupted = core.markInterrupted;
const friendlyRuntimeError = core.friendlyRuntimeError;
const runtimeErrorCode = core.runtimeErrorCode;
const runCommandCapture = core.runCommandCapture;
const freeCommandResult = core.freeCommandResult;
const runCommandCaptureWithTimeout = core.runCommandCaptureWithTimeout;
const runShellCommand = core.runShellCommand;
const resetStateForMission = core.resetStateForMission;
const initializeRuntimeSession = core.initializeRuntimeSession;
const appendHistory = core.appendHistory;
const taskForLane = core.taskForLane;
const taskForLaneConst = core.taskForLaneConst;
const laneForActor = core.laneForActor;
const fallbackActorForLane = core.fallbackActorForLane;
const coreRoster = core.coreRoster;
const helperRoster = core.helperRoster;
const installableRoster = core.installableRoster;
const constitutional_core_agent_count = core.constitutional_core_agent_count;
const minimum_helper_agent_count = core.minimum_helper_agent_count;
const setLoopStep = core.setLoopStep;
const beginApprovalRequest = core.beginApprovalRequest;
const resolveApprovalRequest = core.resolveApprovalRequest;
const singleItemSlice = core.singleItemSlice;
const invocationResultStatusFromText = core.invocationResultStatusFromText;
const materializeInvocationResult = core.materializeInvocationResult;
const prepareInvocation = core.prepareInvocation;
const finalizeInvocation = core.finalizeInvocation;
const taskSummaryText = core.taskSummaryText;
const recentHistoryText = core.recentHistoryText;
const estimateTokensFromText = core.estimateTokensFromText;
const estimatePromptBudget = core.estimatePromptBudget;
const applyPromptBudgetEstimate = core.applyPromptBudgetEstimate;
const pathExists = core.pathExists;
const pathIsSafeForWrite = core.pathIsSafeForWrite;
const commandIsBlocked = core.commandIsBlocked;
const timeoutSeconds = core.timeoutSeconds;
const joinArgs = core.joinArgs;
const joinStrings = core.joinStrings;
const canonicalToolName = core.canonicalToolName;
const isSupportedToolName = core.isSupportedToolName;
const makeTurnId = core.makeTurnId;
const truncateText = core.truncateText;
const truncateOwnedText = core.truncateOwnedText;
const unixTimestampString = core.unixTimestampString;
const parseJson = model_json.parseJson;
const parseModelJson = model_json.parseModelJson;
const containsString = core.containsString;
const eql = core.eql;
const trimAscii = core.trimAscii;
const exitCode = core.exitCode;
const testQueueEmit = core.testQueueEmit;
const testDenyApproval = core.testDenyApproval;
const freeOwnedStringSlice = core.freeOwnedStringSlice;
const freeOwnedDecanusDecision = core.freeOwnedDecanusDecision;
const freeOwnedSpecialistResult = core.freeOwnedSpecialistResult;
const stdoutPrint = core.stdoutPrint;
const stderrPrint = core.stderrPrint;
const providerListModels = provider.providerListModels;
const providerStructuredChat = provider.providerStructuredChat;
const MessagePayload = provider.MessagePayload;
const OllamaChatRequest = provider.OllamaChatRequest;
const OpenAIChatRequest = provider.OpenAIChatRequest;
const buildOllamaChatBody = provider.buildOllamaChatBody;
const stringifyJsonToString = provider.stringifyJsonToString;
const providerStructuredChatOllamaNonStreaming = provider.providerStructuredChatOllamaNonStreaming;
const ollamaMessageRawText = provider.ollamaMessageRawText;
const openAIMessageRawText = provider.openAIMessageRawText;
const ollamaToolCallsToStructuredJson = provider.ollamaToolCallsToStructuredJson;
const openAIToolCallsToStructuredJson = provider.openAIToolCallsToStructuredJson;
const cloneToolRequest = provider.cloneToolRequest;
const freeOwnedToolRequest = provider.freeOwnedToolRequest;
const toolRequestFromOllamaToolCall = provider.toolRequestFromOllamaToolCall;
const toolRequestFromProviderToolCall = provider.toolRequestFromProviderToolCall;
const shellCommandFromOllamaToolArgs = provider.shellCommandFromOllamaToolArgs;
const looksLikeListFilesCommand = provider.looksLikeListFilesCommand;
const providerStructuredChatOllamaStreaming = provider.providerStructuredChatOllamaStreaming;
const processOllamaPendingLines = provider.processOllamaPendingLines;
const processOllamaPendingLine = provider.processOllamaPendingLine;

const global_memory_version_prefix = "<!-- contubernium:global-memory format_version=";
const global_memory_version_suffix = " -->";
const global_memory_version_header = std.fmt.comptimePrint(
    "{s}{d}{s}",
    .{ global_memory_version_prefix, global_memory_format_version, global_memory_version_suffix },
);

pub const EmbeddedAsset = struct {
    relative_path: []const u8,
    content: []const u8,
};

pub const ProjectIdentity = struct {
    project_root: []const u8,
    project_id: []const u8,
    project_label: []const u8,
};

pub const embedded_assets = [_]EmbeddedAsset{
    .{ .relative_path = "state.json", .content = embedded.state_json },
    .{ .relative_path = "config.json", .content = embedded.config_json },
    .{ .relative_path = "sessions/index.json", .content = embedded.session_index_json },
    .{ .relative_path = "project.md", .content = embedded.project_memory_md },
    .{ .relative_path = "global.md", .content = embedded.global_memory_md },
    .{ .relative_path = "ARCHITECTURE.md", .content = embedded.architecture_md },
    .{ .relative_path = "PLAN.md", .content = embedded.plan_md },
    .{ .relative_path = "PROJECT_CONTEXT.md", .content = embedded.project_context_md },
};
pub fn loadConfig(allocator: std.mem.Allocator, path: []const u8) !AppConfig {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    var config = try parseJson(AppConfig, allocator, data);
    syncConfigProviderMirrors(&config);
    return config;
}

pub fn loadProjectConfig(allocator: std.mem.Allocator) !AppConfig {
    try scaffoldProject(allocator);
    const config_path = try resolveConfigPath(allocator);
    return try loadConfig(allocator, config_path);
}

pub fn loadState(allocator: std.mem.Allocator, path: []const u8) !AppState {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    defer allocator.free(data);

    const normalized = try normalizeLegacyStateJson(allocator, data);
    defer allocator.free(normalized);
    return try parseJson(AppState, allocator, normalized);
}

pub fn normalizeLegacyStateJson(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const without_empty_active_tool = try std.mem.replaceOwned(u8, allocator, data, "\"active_tool\": \"\"", "\"active_tool\": null");
    errdefer allocator.free(without_empty_active_tool);

    const without_empty_next_agent = try std.mem.replaceOwned(u8, allocator, without_empty_active_tool, "\"next_recommended_agent\": \"\"", "\"next_recommended_agent\": null");
    allocator.free(without_empty_active_tool);
    errdefer allocator.free(without_empty_next_agent);

    const normalized = try normalizeLegacyFailureJson(allocator, without_empty_next_agent);
    allocator.free(without_empty_next_agent);
    return normalized;
}

pub fn normalizeLegacyFailureJson(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const without_error_code = try std.mem.replaceOwned(u8, allocator, data, "\"error_code\":", "\"code\":");
    errdefer allocator.free(without_error_code);

    const normalized = try std.mem.replaceOwned(u8, allocator, without_error_code, "\"message\":", "\"cause\":");
    allocator.free(without_error_code);
    return normalized;
}

fn formatVersionFromJsonValue(value: std.json.Value) !?usize {
    return switch (value) {
        .null => null,
        .integer => |number| {
            if (number < 0) return error.InvalidMemoryFormat;
            return @as(usize, @intCast(number));
        },
        .number_string, .string => |text| try std.fmt.parseInt(usize, trimAscii(text), 10),
        else => error.InvalidMemoryFormat,
    };
}

fn normalizeVersionedJsonObject(
    allocator: std.mem.Allocator,
    data: []const u8,
    current_version: usize,
) ![]u8 {
    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, data, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();

    const root = switch (parsed.value) {
        .object => |*object| object,
        else => return error.InvalidMemoryFormat,
    };

    const detected_version = if (root.get("format_version")) |value|
        try formatVersionFromJsonValue(value)
    else
        null;

    if (detected_version) |version| {
        if (version == current_version) {
            return try allocator.dupe(u8, data);
        }
        if (version != legacy_memory_format_version) {
            return error.UnsupportedMemoryFormatVersion;
        }
    }

    try root.put("format_version", .{ .integer = @as(i64, @intCast(current_version)) });
    return try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(parsed.value, .{ .whitespace = .indent_2 })},
    );
}

fn parsedGlobalMemoryFormatVersion(text: []const u8) !?usize {
    const trimmed = trimAscii(text);
    if (!std.mem.startsWith(u8, trimmed, global_memory_version_prefix)) return null;

    const suffix_index = std.mem.indexOf(u8, trimmed, global_memory_version_suffix) orelse return error.InvalidMemoryFormat;
    const version_text = trimAscii(trimmed[global_memory_version_prefix.len..suffix_index]);
    if (version_text.len == 0) return error.InvalidMemoryFormat;
    return try std.fmt.parseInt(usize, version_text, 10);
}

pub fn stripGlobalMemoryVersionHeader(text: []const u8) []const u8 {
    const trimmed = trimAscii(text);
    if (!std.mem.startsWith(u8, trimmed, global_memory_version_prefix)) return trimmed;

    const suffix_index = std.mem.indexOf(u8, trimmed, global_memory_version_suffix) orelse return trimmed;
    var remainder = trimmed[suffix_index + global_memory_version_suffix.len ..];

    while (remainder.len > 0 and (remainder[0] == '\n' or remainder[0] == '\r')) {
        remainder = remainder[1..];
    }
    return trimAscii(remainder);
}

pub fn normalizeGlobalMemoryMarkdown(allocator: std.mem.Allocator, data: []const u8) ![]u8 {
    const trimmed = trimAscii(data);
    const detected_version = try parsedGlobalMemoryFormatVersion(trimmed);

    if (detected_version) |version| {
        if (version == global_memory_format_version) {
            return try allocator.dupe(u8, trimmed);
        }
        if (version != legacy_memory_format_version) {
            return error.UnsupportedMemoryFormatVersion;
        }
    }

    if (trimmed.len == 0) return try allocator.dupe(u8, global_memory_version_header);
    return try std.fmt.allocPrint(allocator, "{s}\n\n{s}", .{
        global_memory_version_header,
        stripGlobalMemoryVersionHeader(trimmed),
    });
}

pub fn saveState(allocator: std.mem.Allocator, path: []const u8, state: AppState) !void {
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

pub fn saveConfig(allocator: std.mem.Allocator, path: []const u8, config: AppConfig) !void {
    var normalized = config;
    syncConfigProviderMirrors(&normalized);
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(normalized, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

pub fn loadRuntimeRunLog(allocator: std.mem.Allocator, path: []const u8) !RuntimeRunLog {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    defer allocator.free(data);

    const normalized = try normalizeLegacyFailureJson(allocator, data);
    defer allocator.free(normalized);
    return try parseJson(RuntimeRunLog, allocator, normalized);
}

pub fn saveRuntimeRunLog(allocator: std.mem.Allocator, path: []const u8, log: RuntimeRunLog) !void {
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

pub fn loadSessionIndex(allocator: std.mem.Allocator, path: []const u8) !SessionIndex {
    const data = std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes) catch |err| switch (err) {
        error.FileNotFound => return .{},
        else => return err,
    };
    defer allocator.free(data);

    const normalized = try normalizeVersionedJsonObject(allocator, data, session_index_format_version);
    defer allocator.free(normalized);
    return try parseJson(SessionIndex, allocator, normalized);
}

pub fn saveSessionIndex(allocator: std.mem.Allocator, path: []const u8, index: SessionIndex) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(index, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

pub fn loadSessionRecord(allocator: std.mem.Allocator, path: []const u8) !SessionRecord {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes);
    defer allocator.free(data);

    const normalized = try normalizeVersionedJsonObject(allocator, data, session_record_format_version);
    defer allocator.free(normalized);
    return try parseJson(SessionRecord, allocator, normalized);
}

pub fn saveSessionRecord(allocator: std.mem.Allocator, path: []const u8, record: SessionRecord) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(record, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

pub fn loadGlobalSessionIndex(allocator: std.mem.Allocator, path: []const u8) !GlobalSessionIndex {
    const data = std.fs.cwd().readFileAlloc(allocator, path, max_file_bytes) catch |err| switch (err) {
        error.FileNotFound => return .{},
        else => return err,
    };
    defer allocator.free(data);

    const normalized = try normalizeVersionedJsonObject(allocator, data, global_session_index_format_version);
    defer allocator.free(normalized);
    return try parseJson(GlobalSessionIndex, allocator, normalized);
}

pub fn saveGlobalSessionIndex(allocator: std.mem.Allocator, path: []const u8, index: GlobalSessionIndex) !void {
    const rendered = try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(index, .{ .whitespace = .indent_2 })},
    );
    defer allocator.free(rendered);
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(rendered);
}

pub fn makeSessionId(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "session-{d}", .{std.time.milliTimestamp()});
}

pub fn sessionIdIsSafe(session_id: []const u8) bool {
    const trimmed = trimAscii(session_id);
    if (trimmed.len == 0) return false;
    if (std.mem.indexOfScalar(u8, trimmed, '/')) |_| return false;
    if (std.mem.indexOfScalar(u8, trimmed, '\\')) |_| return false;
    return std.mem.indexOf(u8, trimmed, "..") == null;
}

pub fn sessionRecordPath(allocator: std.mem.Allocator, sessions_dir: []const u8, session_id: []const u8) ![]const u8 {
    if (!sessionIdIsSafe(session_id)) return error.InvalidSessionId;
    const file_name = try std.fmt.allocPrint(allocator, "{s}.json", .{trimAscii(session_id)});
    defer allocator.free(file_name);
    return try std.fs.path.join(allocator, &.{ sessions_dir, file_name });
}

pub fn resolveGlobalSessionIndexPath(allocator: std.mem.Allocator) ![]const u8 {
    const home = try resolveContuberniumHome(allocator);
    defer allocator.free(home);
    return try std.fs.path.join(allocator, &.{ home, global_session_index_filename });
}

pub fn resolveProjectIdentity(allocator: std.mem.Allocator) !ProjectIdentity {
    const project_root = try std.fs.cwd().realpathAlloc(allocator, ".");
    errdefer allocator.free(project_root);
    return .{
        .project_root = project_root,
        .project_id = try std.fmt.allocPrint(allocator, "project-{x}", .{std.hash.Wyhash.hash(0, project_root)}),
        .project_label = try allocator.dupe(u8, std.fs.path.basename(project_root)),
    };
}

fn sessionPromptExcerpt(allocator: std.mem.Allocator, prompt: []const u8) ![]const u8 {
    return try truncateOwnedText(allocator, try allocator.dupe(u8, prompt), 120);
}

fn mergedSessionLogPaths(
    allocator: std.mem.Allocator,
    existing_paths: []const []const u8,
    active_log_path: []const u8,
) ![]const []const u8 {
    var items: std.ArrayList([]const u8) = .empty;
    errdefer {
        for (items.items) |item| allocator.free(item);
        items.deinit(allocator);
    }

    if (active_log_path.len > 0) {
        try items.append(allocator, try allocator.dupe(u8, active_log_path));
    }
    for (existing_paths) |path| {
        if (containsString(items.items, path)) continue;
        try items.append(allocator, try allocator.dupe(u8, path));
    }
    return try items.toOwnedSlice(allocator);
}

fn upsertSessionIndexEntry(
    allocator: std.mem.Allocator,
    path: []const u8,
    current_session_id: []const u8,
    entry: SessionIndexEntry,
) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const existing = try loadSessionIndex(scratch, path);
    var sessions: std.ArrayList(SessionIndexEntry) = .empty;
    errdefer sessions.deinit(allocator);

    try sessions.append(allocator, entry);
    for (existing.sessions) |session| {
        if (eql(session.session_id, entry.session_id)) continue;
        try sessions.append(allocator, .{
            .session_id = try allocator.dupe(u8, session.session_id),
            .project_id = try allocator.dupe(u8, session.project_id),
            .project_label = try allocator.dupe(u8, session.project_label),
            .created_at = try allocator.dupe(u8, session.created_at),
            .updated_at = try allocator.dupe(u8, session.updated_at),
            .command = try allocator.dupe(u8, session.command),
            .status = try allocator.dupe(u8, session.status),
            .provider = try allocator.dupe(u8, session.provider),
            .model = try allocator.dupe(u8, session.model),
            .approval_mode = try allocator.dupe(u8, session.approval_mode),
            .approval_bypass_enabled = session.approval_bypass_enabled,
            .resume_count = session.resume_count,
            .mission_prompt_excerpt = try allocator.dupe(u8, session.mission_prompt_excerpt),
            .last_error = try allocator.dupe(u8, session.last_error),
        });
    }

    try saveSessionIndex(allocator, path, .{
        .current_session_id = current_session_id,
        .sessions = try sessions.toOwnedSlice(allocator),
    });
}

fn upsertGlobalSessionIndexEntry(
    allocator: std.mem.Allocator,
    path: []const u8,
    entry: GlobalSessionIndexEntry,
) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const existing = try loadGlobalSessionIndex(scratch, path);
    var sessions: std.ArrayList(GlobalSessionIndexEntry) = .empty;
    errdefer sessions.deinit(allocator);

    try sessions.append(allocator, entry);
    for (existing.sessions) |session| {
        if (eql(session.session_id, entry.session_id)) continue;
        try sessions.append(allocator, .{
            .session_id = try allocator.dupe(u8, session.session_id),
            .project_id = try allocator.dupe(u8, session.project_id),
            .project_label = try allocator.dupe(u8, session.project_label),
            .created_at = try allocator.dupe(u8, session.created_at),
            .updated_at = try allocator.dupe(u8, session.updated_at),
            .status = try allocator.dupe(u8, session.status),
            .provider = try allocator.dupe(u8, session.provider),
            .model = try allocator.dupe(u8, session.model),
        });
    }

    try saveGlobalSessionIndex(allocator, path, .{
        .sessions = try sessions.toOwnedSlice(allocator),
    });
}

pub fn persistSessionMemory(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    command: []const u8,
) !void {
    if (state.mission.initial_prompt.len == 0 and state.runtime_session.session_id.len == 0) return;

    const now = try unixTimestampString(allocator);
    if (state.runtime_session.session_id.len == 0) {
        state.runtime_session.session_id = try makeSessionId(allocator);
    }
    if (state.runtime_session.session_started_at.len == 0) {
        state.runtime_session.session_started_at = now;
    }
    state.runtime_session.session_updated_at = now;
    state.runtime_session.approval_mode = resolvedApprovalMode(config.policy.approval_mode, state.runtime_session.approval_bypass_enabled);

    const project_identity = try resolveProjectIdentity(allocator);
    defer allocator.free(project_identity.project_root);
    defer allocator.free(project_identity.project_id);
    defer allocator.free(project_identity.project_label);

    const record_path = try sessionRecordPath(allocator, config.paths.sessions_dir, state.runtime_session.session_id);
    defer allocator.free(record_path);

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const existing_record = loadSessionRecord(scratch, record_path) catch |err| switch (err) {
        error.FileNotFound => null,
        else => return err,
    };

    const run_log_paths = try mergedSessionLogPaths(
        allocator,
        if (existing_record) |record| record.run_log_paths else &.{},
        if (state.runtime_session.active_log_path.len > 0)
            state.runtime_session.active_log_path
        else if (existing_record) |record|
            record.last_log_path
        else
            "",
    );

    const command_text = if (command.len > 0)
        command
    else if (existing_record) |record|
        record.command
    else
        "mission";

    const provider_name = if (state.runtime_session.provider.len > 0) state.runtime_session.provider else config.provider.type;
    const model_name = if (state.runtime_session.model.len > 0) state.runtime_session.model else config.provider.model;
    const last_log_path = if (state.runtime_session.active_log_path.len > 0)
        state.runtime_session.active_log_path
    else if (existing_record) |record|
        record.last_log_path
    else
        "";

    const record: SessionRecord = .{
        .session_id = state.runtime_session.session_id,
        .project_id = project_identity.project_id,
        .project_label = project_identity.project_label,
        .created_at = if (existing_record) |value| value.created_at else state.runtime_session.session_started_at,
        .updated_at = now,
        .command = command_text,
        .mission_prompt = state.mission.initial_prompt,
        .provider = provider_name,
        .model = model_name,
        .approval_mode = state.runtime_session.approval_mode,
        .approval_bypass_enabled = state.runtime_session.approval_bypass_enabled,
        .resume_count = state.runtime_session.resume_count,
        .status = @tagName(state.runtime_session.status),
        .last_log_path = last_log_path,
        .run_log_paths = run_log_paths,
        .last_error = state.runtime_session.last_error,
        .state_snapshot = state.*,
    };
    try saveSessionRecord(allocator, record_path, record);

    try upsertSessionIndexEntry(allocator, config.paths.session_index_file, state.runtime_session.session_id, .{
        .session_id = record.session_id,
        .project_id = record.project_id,
        .project_label = record.project_label,
        .created_at = record.created_at,
        .updated_at = record.updated_at,
        .command = record.command,
        .status = record.status,
        .provider = record.provider,
        .model = record.model,
        .approval_mode = record.approval_mode,
        .approval_bypass_enabled = record.approval_bypass_enabled,
        .resume_count = record.resume_count,
        .mission_prompt_excerpt = try sessionPromptExcerpt(allocator, record.mission_prompt),
        .last_error = record.last_error,
    });

    const global_index_path = try resolveGlobalSessionIndexPath(allocator);
    defer allocator.free(global_index_path);
    try upsertGlobalSessionIndexEntry(allocator, global_index_path, .{
        .session_id = record.session_id,
        .project_id = record.project_id,
        .project_label = record.project_label,
        .created_at = record.created_at,
        .updated_at = record.updated_at,
        .status = record.status,
        .provider = record.provider,
        .model = record.model,
    });
}

pub fn runDoctorCheck(allocator: std.mem.Allocator) ![]const u8 {
    const config = try loadProjectConfig(allocator);
    const model_policy = resolveModelPolicy(config);
    var state = try loadState(allocator, config.paths.state_file);
    const asset_layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, asset_layout);

    try ensureGlobalAssetFiles(allocator, asset_layout);
    try ensureMemoryFiles(config.paths);

    const models = try providerListModels(allocator, model_policy.primary);
    if (!containsString(models, model_policy.primary.model)) return error.ModelNotFound;

    const smoke_response = try providerStructuredChat(
        allocator,
        model_policy.primary,
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
        .{ model_policy.primary.type, model_policy.primary.model },
    );
}

pub fn missionOutcomeSummary(allocator: std.mem.Allocator, state: AppState) ![]const u8 {
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

pub fn ensureGlobalAssetFiles(allocator: std.mem.Allocator, layout: GlobalAssetLayout) !void {
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

    const core_agents = coreRoster();
    if (core_agents.len != constitutional_core_agent_count) {
        stderrPrint(
            "invalid core roster: expected {d} core agents including decanus, found {d}\n",
            .{ constitutional_core_agent_count, core_agents.len },
        ) catch {};
        return error.InvalidAgentRoster;
    }

    const helpers = helperRoster();
    if (helpers.len < minimum_helper_agent_count) {
        stderrPrint(
            "invalid helper roster: expected at least {d} helper agents, found {d}\n",
            .{ minimum_helper_agent_count, helpers.len },
        ) catch {};
        return error.InvalidAgentRoster;
    }

    const actors = installableRoster();
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

pub fn ensureMemoryFiles(paths: PathsConfig) !void {
    const required = [_][]const u8{
        paths.session_index_file,
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

pub fn readSharedAsset(allocator: std.mem.Allocator, layout: GlobalAssetLayout, relative_path: []const u8) ![]const u8 {
    const full_path = try std.fs.path.join(allocator, &.{ layout.shared_root, relative_path });
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

pub fn resolveAgentAssetPath(
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

pub fn readAgentAsset(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    relative_path: []const u8,
) ![]const u8 {
    const full_path = try resolveAgentAssetPath(allocator, layout, actor, relative_path);
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

pub fn isCanonicalActionName(text: []const u8) bool {
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

pub fn resolveAgentActionPath(
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

pub fn readAgentActionAsset(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    actor: Actor,
    action_name: []const u8,
) ![]const u8 {
    const full_path = try resolveAgentActionPath(allocator, layout, actor, action_name);
    defer allocator.free(full_path);
    return try std.fs.cwd().readFileAlloc(allocator, full_path, max_file_bytes);
}

pub fn defaultActionNameForActor(actor: Actor) []const u8 {
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

pub fn requiredActionNamesForActor(actor: Actor) []const []const u8 {
    return switch (actor) {
        .decanus => &.{
            "EVALUATE_LOOP",
            "INVOKE_SPECIALIST",
            "FINISH_MISSION",
        },
        else => &.{defaultActionNameForActor(actor)},
    };
}

pub fn parseAgentCall(agent_call: []const u8) ?AgentCallSpec {
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

pub fn validateAgentCoreAssets(
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

pub fn resolveAgentCallTarget(
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

pub fn resolveSpecialistInvocationFromDecision(
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
        fallbackActorForLane(lane) orelse return error.HelperLaneRequiresExplicitAgent
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

pub fn specialistInvocationResolutionMessage(
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
        error.HelperLaneRequiresExplicitAgent => try std.fmt.allocPrint(
            allocator,
            "helper lane `{s}` requires an explicit helper target in `agent` or `agent::ACTION` form.",
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

pub fn appendActionSection(
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

pub fn appendSelectedActionSections(
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

pub fn copyFileIfMissing(allocator: std.mem.Allocator, source_path: []const u8, target_path: []const u8) !void {
    std.fs.cwd().access(target_path, .{}) catch {
        const content = try std.fs.cwd().readFileAlloc(allocator, source_path, max_file_bytes);
        defer allocator.free(content);
        if (std.fs.path.dirname(target_path)) |dir_name| {
            try std.fs.cwd().makePath(dir_name);
        }
        var file = try std.fs.cwd().createFile(target_path, .{ .truncate = true });
        defer file.close();
        try file.writeAll(content);
        return;
    };
}

pub fn scaffoldProject(allocator: std.mem.Allocator) !void {
    try std.fs.cwd().makePath(default_logs_dir);
    try std.fs.cwd().makePath(default_sessions_dir);
    for (embedded_assets) |asset| {
        const destination = try runtimePath(allocator, asset.relative_path);
        defer allocator.free(destination);
        try writeFileIfMissing(destination, asset.content);
    }
}

pub fn runtimePath(allocator: std.mem.Allocator, relative_path: []const u8) ![]const u8 {
    return try std.fs.path.join(allocator, &.{ runtime_dir_name, relative_path });
}

pub fn resolveContuberniumHome(allocator: std.mem.Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(allocator, "CONTUBERNIUM_HOME") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => {
            const home = std.process.getEnvVarOwned(allocator, "HOME") catch |home_err| switch (home_err) {
                error.EnvironmentVariableNotFound => try std.process.getEnvVarOwned(allocator, "USERPROFILE"),
                else => return home_err,
            };
            defer allocator.free(home);
            return try std.fs.path.join(allocator, &.{ home, ".contubernium" });
        },
        else => return err,
    };
}

pub fn deinitGlobalAssetLayout(allocator: std.mem.Allocator, layout: GlobalAssetLayout) void {
    allocator.free(layout.root);
    allocator.free(layout.agents_root);
    allocator.free(layout.shared_root);
    allocator.free(layout.adapters_root);
}

pub fn resolveSourceAssetRoot(allocator: std.mem.Allocator) ![]const u8 {
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

pub fn resolveGlobalAssetLayout(allocator: std.mem.Allocator) !GlobalAssetLayout {
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

pub fn writeFileIfMissing(path: []const u8, content: []const u8) !void {
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

pub fn resolveConfigPath(allocator: std.mem.Allocator) ![]const u8 {
    _ = allocator;
    if (pathExists(default_config_path)) return default_config_path;
    return default_config_path;
}

pub fn makeRunId(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "run-{d}", .{std.time.milliTimestamp()});
}

pub fn logPathForRun(allocator: std.mem.Allocator, logs_dir: []const u8, run_id: []const u8) ![]const u8 {
    try std.fs.cwd().makePath(logs_dir);
    return try std.fmt.allocPrint(allocator, "{s}/{s}.json", .{ logs_dir, run_id });
}

pub fn initializeRuntimeRunLog(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    command: []const u8,
) !void {
    const run_id = try makeRunId(allocator);
    stateManager(state).setActiveLogPath(try logPathForRun(allocator, config.paths.logs_dir, run_id));

    const model_policy = resolveModelPolicy(config);
    const timestamp = try unixTimestampString(allocator);
    const log = RuntimeRunLog{
        .run_id = run_id,
        .command = command,
        .created_at = timestamp,
        .updated_at = timestamp,
        .project_name = state.project_name,
        .provider = model_policy.primary.type,
        .model = model_policy.primary.model,
        .model_policy = runtimeModelPolicyLog(config),
        .approval_mode = if (state.runtime_session.approval_mode.len > 0)
            state.runtime_session.approval_mode
        else
            resolvedApprovalMode(config.policy.approval_mode, state.runtime_session.approval_bypass_enabled),
        .mission_prompt = state.mission.initial_prompt,
        .events = &.{},
    };
    try saveRuntimeRunLog(allocator, state.runtime_session.active_log_path, log);
}

pub fn appendRuntimeRunLogEvent(allocator: std.mem.Allocator, path: []const u8, event: RuntimeLogEvent) !void {
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

pub fn logRuntimeEvent(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    spec: RuntimeLogEventSpec,
) !void {
    if (state.runtime_session.active_log_path.len == 0) return;

    const project_name = if (!eql(state.project_name, "UNASSIGNED")) state.project_name else "";
    const resolved_provider = if (spec.provider.len > 0) spec.provider else state.runtime_session.provider;
    const resolved_model = if (spec.model.len > 0) spec.model else state.runtime_session.model;
    const resolved_policy_role = if (spec.policy_role.len > 0) spec.policy_role else state.runtime_session.last_model_role;
    const resolved_policy_reason = if (spec.policy_reason.len > 0) spec.policy_reason else state.runtime_session.last_model_reason;
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
        .provider = resolved_provider,
        .model = resolved_model,
        .policy_role = resolved_policy_role,
        .policy_reason = resolved_policy_reason,
        .summary = spec.summary,
        .input = spec.input,
        .output = spec.output,
        .error_text = spec.error_text,
        .failure = spec.failure,
        .snapshot = snapshot,
    });
}
