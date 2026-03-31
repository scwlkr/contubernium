const std = @import("std");
const core = @import("runtime_core.zig");
const max_file_bytes = core.max_file_bytes;
const runtime_dir_name = core.runtime_dir_name;
const default_state_path = core.default_state_path;
const default_config_path = core.default_config_path;
const default_logs_dir = core.default_logs_dir;
const default_project_memory_path = core.default_project_memory_path;
const default_global_memory_path = core.default_global_memory_path;
const default_architecture_path = core.default_architecture_path;
const default_plan_path = core.default_plan_path;
const default_project_context_path = core.default_project_context_path;
const max_list_files_entries = core.max_list_files_entries;
const legacy_default_max_iterations = core.legacy_default_max_iterations;
const default_max_iterations = core.default_max_iterations;
const default_context_window_tokens = core.default_context_window_tokens;
const default_response_reserve_tokens = core.default_response_reserve_tokens;
const default_tool_timeout_ms = core.default_tool_timeout_ms;
const default_max_project_memory_chars = core.default_max_project_memory_chars;
const default_max_global_memory_chars = core.default_max_global_memory_chars;
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
const resolvedContextBudget = core.resolvedContextBudget;
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
const actorForLane = core.actorForLane;
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
const parseJson = core.parseJson;
const parseModelJson = core.parseModelJson;
const parseDecanusDecisionModelJson = core.parseDecanusDecisionModelJson;
const parseSpecialistResultModelJson = core.parseSpecialistResultModelJson;
const parseToolRequestModelJson = core.parseToolRequestModelJson;
const parseModelValueTree = core.parseModelValueTree;
const requireJsonObject = core.requireJsonObject;
const dupJsonObjectStringFieldOrDefault = core.dupJsonObjectStringFieldOrDefault;
const dupJsonStringValueOrDefault = core.dupJsonStringValueOrDefault;
const dupJsonObjectStringArrayFieldOrDefault = core.dupJsonObjectStringArrayFieldOrDefault;
const dupJsonStringArrayValueOrDefault = core.dupJsonStringArrayValueOrDefault;
const dupJsonObjectToolRequestsFieldOrDefault = core.dupJsonObjectToolRequestsFieldOrDefault;
const dupToolRequestsValueOrDefault = core.dupToolRequestsValueOrDefault;
const dupToolRequestFromJsonValue = core.dupToolRequestFromJsonValue;
const jsonObjectFloatFieldOrDefault = core.jsonObjectFloatFieldOrDefault;
const prettyPrintJson = core.prettyPrintJson;
const normalizeModelJson = core.normalizeModelJson;
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

pub fn providerListModels(allocator: std.mem.Allocator, provider: ProviderConfig) ![][]const u8 {
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

pub fn providerStructuredChat(
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

pub const MessagePayload = struct {
    role: []const u8,
    content: []const u8,
};

pub const OllamaChatRequest = struct {
    model: []const u8,
    stream: bool,
    think: bool = false,
    format: []const u8,
    messages: []const MessagePayload,
};

pub const OpenAIChatRequest = struct {
    model: []const u8,
    messages: []const MessagePayload,
};

pub fn buildOllamaChatBody(
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

pub fn stringifyJsonToString(allocator: std.mem.Allocator, value: anytype) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{f}", .{std.json.fmt(value, .{})});
}

pub fn providerStructuredChatOllamaNonStreaming(
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

pub fn ollamaMessageRawText(allocator: std.mem.Allocator, message: OllamaMessage) ![]const u8 {
    if (trimAscii(message.content).len > 0) return message.content;
    if (message.tool_calls.len > 0) return try ollamaToolCallsToStructuredJson(allocator, message);
    return error.EmptyModelOutput;
}

pub fn openAIMessageRawText(allocator: std.mem.Allocator, message: OpenAIMessage) ![]const u8 {
    if (trimAscii(message.content).len > 0) return message.content;
    if (message.tool_calls.len > 0) return try openAIToolCallsToStructuredJson(allocator, message.tool_calls);
    return error.EmptyModelOutput;
}

pub fn ollamaToolCallsToStructuredJson(allocator: std.mem.Allocator, message: OllamaMessage) ![]const u8 {
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

pub fn openAIToolCallsToStructuredJson(allocator: std.mem.Allocator, tool_calls: []const OpenAIToolCall) ![]const u8 {
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

pub fn cloneToolRequest(allocator: std.mem.Allocator, request: ToolRequest) !ToolRequest {
    return .{
        .tool = try allocator.dupe(u8, request.tool),
        .description = try allocator.dupe(u8, request.description),
        .path = try allocator.dupe(u8, request.path),
        .pattern = try allocator.dupe(u8, request.pattern),
        .command = try allocator.dupe(u8, request.command),
        .content = try allocator.dupe(u8, request.content),
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

pub fn toolRequestFromOllamaToolCall(function: OllamaToolFunction) !ToolRequest {
    return try toolRequestFromProviderToolCall(function.name, function.arguments);
}

pub fn toolRequestFromProviderToolCall(name: []const u8, arguments: OllamaToolArguments) !ToolRequest {
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

pub fn shellCommandFromOllamaToolArgs(arguments: OllamaToolArguments) []const u8 {
    if (arguments.command.len > 0) return arguments.command;
    if (arguments.cmd.len >= 3 and (eql(arguments.cmd[0], "bash") or eql(arguments.cmd[0], "sh")) and eql(arguments.cmd[1], "-lc")) {
        return arguments.cmd[2];
    }
    if (arguments.cmd.len == 1) return arguments.cmd[0];
    return "";
}

pub fn looksLikeListFilesCommand(command: []const u8) bool {
    return std.mem.indexOf(u8, command, "ls") != null or
        std.mem.indexOf(u8, command, "find") != null or
        std.mem.indexOf(u8, command, "rg --files") != null;
}

pub fn providerStructuredChatOllamaStreaming(
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

pub fn processOllamaPendingLines(
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

pub fn processOllamaPendingLine(
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
