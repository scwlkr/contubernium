const std = @import("std");
const core = @import("runtime_core.zig");
const assets_mod = @import("runtime_assets.zig");
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
const RuntimePermissionClass = core.RuntimePermissionClass;
const ToolApprovalGate = core.ToolApprovalGate;
const ToolConfirmationMode = core.ToolConfirmationMode;
const RuntimeToolTimeoutBehavior = core.RuntimeToolTimeoutBehavior;
const RuntimeToolFieldKind = core.RuntimeToolFieldKind;
const RuntimeToolSchemaField = core.RuntimeToolSchemaField;
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
const freeOwnedToolRequest = core.freeOwnedToolRequest;
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
const EmbeddedAsset = assets_mod.EmbeddedAsset;
const embedded_assets = assets_mod.embedded_assets;
const loadConfig = assets_mod.loadConfig;
const loadProjectConfig = assets_mod.loadProjectConfig;
const loadState = assets_mod.loadState;
const normalizeLegacyStateJson = assets_mod.normalizeLegacyStateJson;
const saveState = assets_mod.saveState;
const saveConfig = assets_mod.saveConfig;
const loadRuntimeRunLog = assets_mod.loadRuntimeRunLog;
const saveRuntimeRunLog = assets_mod.saveRuntimeRunLog;
const runDoctorCheck = assets_mod.runDoctorCheck;
const missionOutcomeSummary = assets_mod.missionOutcomeSummary;
const ensureGlobalAssetFiles = assets_mod.ensureGlobalAssetFiles;
const ensureMemoryFiles = assets_mod.ensureMemoryFiles;
const readSharedAsset = assets_mod.readSharedAsset;
const resolveAgentAssetPath = assets_mod.resolveAgentAssetPath;
const readAgentAsset = assets_mod.readAgentAsset;
const isCanonicalActionName = assets_mod.isCanonicalActionName;
const resolveAgentActionPath = assets_mod.resolveAgentActionPath;
const readAgentActionAsset = assets_mod.readAgentActionAsset;
const defaultActionNameForActor = assets_mod.defaultActionNameForActor;
const requiredActionNamesForActor = assets_mod.requiredActionNamesForActor;
const parseAgentCall = assets_mod.parseAgentCall;
const validateAgentCoreAssets = assets_mod.validateAgentCoreAssets;
const resolveAgentCallTarget = assets_mod.resolveAgentCallTarget;
const resolveSpecialistInvocationFromDecision = assets_mod.resolveSpecialistInvocationFromDecision;
const specialistInvocationResolutionMessage = assets_mod.specialistInvocationResolutionMessage;
const appendActionSection = assets_mod.appendActionSection;
const appendSelectedActionSections = assets_mod.appendSelectedActionSections;
const copyFileIfMissing = assets_mod.copyFileIfMissing;
const scaffoldProject = assets_mod.scaffoldProject;
const runtimePath = assets_mod.runtimePath;
const resolveContuberniumHome = assets_mod.resolveContuberniumHome;
const deinitGlobalAssetLayout = assets_mod.deinitGlobalAssetLayout;
const resolveSourceAssetRoot = assets_mod.resolveSourceAssetRoot;
const resolveGlobalAssetLayout = assets_mod.resolveGlobalAssetLayout;
const writeFileIfMissing = assets_mod.writeFileIfMissing;
const resolveConfigPath = assets_mod.resolveConfigPath;
const makeRunId = assets_mod.makeRunId;
const logPathForRun = assets_mod.logPathForRun;
const initializeRuntimeRunLog = assets_mod.initializeRuntimeRunLog;
const appendRuntimeRunLogEvent = assets_mod.appendRuntimeRunLogEvent;
const logRuntimeEvent = assets_mod.logRuntimeEvent;

pub fn executeToolRequests(
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
                const blocked_summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{failure.cause});
                try summaries.append(allocator, blocked_summary);
                try logRuntimeEvent(allocator, config, state, .{
                    .actor = actor,
                    .lane = lane,
                    .action = "tool_result",
                    .status = "blocked",
                    .tool = if (tool_name.len > 0) tool_name else request.tool,
                    .summary = failure.cause,
                    .error_text = failure.cause,
                    .failure = failure,
                    .include_snapshot = true,
                });
                recordRuntimeFailure(state, failure);
                stateManager(state).markBlocked(actor, lane, failure.cause);
                return .{
                    .blocked = true,
                    .summary = try joinStrings(allocator, summaries.items, "\n"),
                };
            },
        };

        const execution = executeValidatedToolRequest(allocator, config, state, actor, lane, validated, hooks) catch |err| {
            const failure = try buildToolExecutionFailure(allocator, config, state, actor, lane, validated, err);
            const blocked_summary = try std.fmt.allocPrint(allocator, "blocked: {s}", .{failure.cause});
            try summaries.append(allocator, blocked_summary);
            try logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "tool_result",
                .status = if (err == error.ToolTimedOut) "blocked" else "error",
                .tool = validated.spec.name,
                .summary = failure.cause,
                .error_text = failure.cause,
                .failure = failure,
                .include_snapshot = true,
            });
            recordRuntimeFailure(state, failure);
            stateManager(state).markBlocked(actor, lane, failure.cause);
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
                .error_text = failure.cause,
                .failure = failure,
                .include_snapshot = true,
            });
            recordRuntimeFailure(state, failure);
            stateManager(state).markBlocked(actor, lane, failure.cause);
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

pub fn shouldSkipWorkspacePath(path: []const u8, prune_noise: bool) bool {
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

pub fn appendWorkspaceEntries(
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

pub fn sortStringsAsc(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, lhs, rhs);
}

pub fn sortStringsDesc(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.lessThan(u8, rhs, lhs);
}

pub fn listWorkspaceFiles(allocator: std.mem.Allocator, path: []const u8) !CommandResult {
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

pub fn summarizeCommandResult(
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

pub fn searchText(allocator: std.mem.Allocator, pattern: []const u8, path: []const u8, max_hits: usize, timeout_ms: usize) ![]const u8 {
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

pub fn readFileLimited(allocator: std.mem.Allocator, path: []const u8, limit: usize) ![]const u8 {
    return try std.fs.cwd().readFileAlloc(allocator, path, limit);
}

pub fn writeFile(path: []const u8, content: []const u8) !void {
    if (std.fs.path.dirname(path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }
    var file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(content);
}

const summary_output_schema = [_]RuntimeToolSchemaField{
    .{
        .name = "summary",
        .kind = .text,
        .required = true,
        .description = "Human-readable result text returned to the active agent turn.",
    },
};

const list_files_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "path", .required = false, .description = "Workspace-relative directory path. Defaults to the current workspace root." },
    .{ .name = "description", .required = false, .description = "Optional reason for the listing request." },
};

const read_file_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "path", .required = true, .description = "Workspace-relative file path to read." },
    .{ .name = "description", .required = false, .description = "Optional reason for the file read request." },
};

const search_text_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "pattern", .required = true, .description = "Literal or regex search pattern." },
    .{ .name = "path", .required = false, .description = "Workspace-relative path to search. Defaults to the current workspace root." },
    .{ .name = "description", .required = false, .description = "Optional reason for the search request." },
};

const run_command_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "command", .required = true, .description = "Shell command executed through `sh -lc`." },
    .{ .name = "description", .required = false, .description = "Optional operator-facing justification shown during approval." },
};

const write_file_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "path", .required = true, .description = "Workspace-relative file path to create or replace." },
    .{ .name = "content", .kind = .text, .required = true, .description = "Full file content written to the target path." },
    .{ .name = "description", .required = false, .description = "Optional operator-facing justification shown during approval." },
};

const ask_user_input_schema = [_]RuntimeToolSchemaField{
    .{ .name = "description", .kind = .text, .required = true, .description = "Question or clarification that must be returned to the operator." },
};

const runtime_tool_specs = [_]RuntimeToolSpec{
    .{
        .kind = .list_files,
        .name = "list_files",
        .permission_class = .read,
        .approval_gate = .read,
        .approval_kind = .read,
        .confirmation_mode = .policy_guarded,
        .timeout_behavior = .none,
        .input_schema = list_files_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
    .{
        .kind = .read_file,
        .name = "read_file",
        .permission_class = .read,
        .approval_gate = .read,
        .approval_kind = .read,
        .confirmation_mode = .policy_guarded,
        .timeout_behavior = .none,
        .input_schema = read_file_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
    .{
        .kind = .search_text,
        .name = "search_text",
        .permission_class = .read,
        .approval_gate = .read,
        .approval_kind = .read,
        .confirmation_mode = .policy_guarded,
        .timeout_behavior = .policy_default,
        .input_schema = search_text_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
    .{
        .kind = .run_command,
        .name = "run_command",
        .permission_class = .execute,
        .approval_gate = .shell,
        .approval_kind = .shell,
        .confirmation_mode = .policy_guarded,
        .timeout_behavior = .policy_default,
        .input_schema = run_command_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
    .{
        .kind = .write_file,
        .name = "write_file",
        .permission_class = .write,
        .approval_gate = .write,
        .approval_kind = .write,
        .confirmation_mode = .policy_guarded,
        .timeout_behavior = .none,
        .input_schema = write_file_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
    .{
        .kind = .ask_user,
        .name = "ask_user",
        .permission_class = .execute,
        .approval_gate = .none,
        .approval_kind = .read,
        .confirmation_mode = .none,
        .timeout_behavior = .none,
        .input_schema = ask_user_input_schema[0..],
        .output_schema = summary_output_schema[0..],
    },
};

pub fn runtimeToolContracts() []const RuntimeToolSpec {
    return runtime_tool_specs[0..];
}

pub fn runtimeToolSpec(tool_name: []const u8) ?RuntimeToolSpec {
    const normalized = canonicalToolName(tool_name);
    for (runtime_tool_specs) |spec| {
        if (eql(normalized, spec.name)) return spec;
    }
    return null;
}

pub fn toolAllowsWithoutConfirmation(spec: RuntimeToolSpec, policy: PolicyConfig) bool {
    return switch (spec.confirmation_mode) {
        .none => true,
        .policy_guarded => switch (spec.permission_class) {
            .read => policy.allow_read_tools_without_confirmation,
            .write => policy.allow_workspace_writes_without_confirmation,
            .execute => policy.allow_shell_without_confirmation,
        },
    };
}

pub fn toolTimeoutMs(spec: RuntimeToolSpec, policy: PolicyConfig) ?usize {
    return switch (spec.timeout_behavior) {
        .none => null,
        .policy_default => policy.tool_timeout_ms,
    };
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

pub fn toolRequestContextSpec(request: ToolRequest, spec: RuntimeToolSpec) RuntimeFailureContextSpec {
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

pub fn validatedToolContextSpec(request: ValidatedToolRequest) RuntimeFailureContextSpec {
    return .{
        .tool = request.spec.name,
        .target = request.target,
        .command = request.command,
        .detail = request.detail,
    };
}

pub fn validateToolRequest(
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

pub fn buildToolExecutionFailure(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    request: ValidatedToolRequest,
    err: anyerror,
) !RuntimeFailure {
    if (err == error.ToolTimedOut) {
        const timeout_ms = toolTimeoutMs(request.spec, config.policy) orelse config.policy.tool_timeout_ms;
        return buildRuntimeFailure(
            state,
            actor,
            lane,
            "TOOL_TIMEOUT",
            try std.fmt.allocPrint(allocator, "{s} exceeded the {d}ms runtime limit", .{ request.spec.name, timeout_ms }),
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

pub fn executeValidatedToolRequest(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    actor: Actor,
    lane: Lane,
    request: ValidatedToolRequest,
    hooks: RuntimeHooks,
) !ToolRequestExecution {
    if (!toolAllowsWithoutConfirmation(request.spec, config.policy) and
        !try confirmTool(allocator, config, state, hooks, actor, lane, request.spec.approval_kind, request.spec.name, request.detail, request.target))
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
            const timeout_ms = toolTimeoutMs(request.spec, config.policy) orelse config.policy.tool_timeout_ms;
            const output = try searchText(allocator, request.pattern, request.path, config.context.max_search_hits, timeout_ms);
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
            const timeout_ms = toolTimeoutMs(request.spec, config.policy) orelse config.policy.tool_timeout_ms;
            const output = try runShellCommand(allocator, request.command, timeout_ms);
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

pub fn toolRequestDisplay(allocator: std.mem.Allocator, request: ToolRequest) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    try writeToolRequestLabel(buffer.writer(allocator), request);
    return try buffer.toOwnedSlice(allocator);
}

pub fn confirmTool(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    actor: Actor,
    lane: Lane,
    approval_kind: ApprovalKind,
    tool_name: []const u8,
    detail: []const u8,
    target: []const u8,
) !bool {
    beginApprovalRequest(state, actor, lane, approval_kind, tool_name, detail, detail, target);
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
