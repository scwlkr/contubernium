const std = @import("std");
const cli = @import("cli.zig");
const core = @import("runtime_core.zig");
const assets_mod = @import("runtime_assets.zig");
const provider_mod = @import("runtime_provider.zig");
const prompting_mod = @import("runtime_prompting.zig");
const tools_mod = @import("runtime_tools.zig");
const loop_mod = @import("runtime_loop.zig");
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
const pathIsSafeForWorkspace = core.pathIsSafeForWorkspace;
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
const providerListModels = provider_mod.providerListModels;
const providerStructuredChat = provider_mod.providerStructuredChat;
const MessagePayload = provider_mod.MessagePayload;
const OllamaChatRequest = provider_mod.OllamaChatRequest;
const OpenAIChatRequest = provider_mod.OpenAIChatRequest;
const buildOllamaChatBody = provider_mod.buildOllamaChatBody;
const stringifyJsonToString = provider_mod.stringifyJsonToString;
const providerStructuredChatOllamaNonStreaming = provider_mod.providerStructuredChatOllamaNonStreaming;
const ollamaMessageRawText = provider_mod.ollamaMessageRawText;
const openAIMessageRawText = provider_mod.openAIMessageRawText;
const ollamaToolCallsToStructuredJson = provider_mod.ollamaToolCallsToStructuredJson;
const openAIToolCallsToStructuredJson = provider_mod.openAIToolCallsToStructuredJson;
const cloneToolRequest = provider_mod.cloneToolRequest;
const toolRequestFromOllamaToolCall = provider_mod.toolRequestFromOllamaToolCall;
const toolRequestFromProviderToolCall = provider_mod.toolRequestFromProviderToolCall;
const shellCommandFromOllamaToolArgs = provider_mod.shellCommandFromOllamaToolArgs;
const looksLikeListFilesCommand = provider_mod.looksLikeListFilesCommand;
const providerStructuredChatOllamaStreaming = provider_mod.providerStructuredChatOllamaStreaming;
const processOllamaPendingLines = provider_mod.processOllamaPendingLines;
const processOllamaPendingLine = provider_mod.processOllamaPendingLine;
const runtimeMemoryStatusLabel = prompting_mod.runtimeMemoryStatusLabel;
const runtimeMemoryPromptText = prompting_mod.runtimeMemoryPromptText;
const summarizeRuntimeMemorySnapshot = prompting_mod.summarizeRuntimeMemorySnapshot;
const specialistRoutingGuideText = prompting_mod.specialistRoutingGuideText;
const buildDecanusUserPrompt = prompting_mod.buildDecanusUserPrompt;
const buildSpecialistUserPrompt = prompting_mod.buildSpecialistUserPrompt;
const assembleSystemPrompt = prompting_mod.assembleSystemPrompt;
const buildCondensedHistorySummary = prompting_mod.buildCondensedHistorySummary;
const condenseHistoryForContext = prompting_mod.condenseHistoryForContext;
const projectMemorySpec = prompting_mod.projectMemorySpec;
const globalMemorySpec = prompting_mod.globalMemorySpec;
const architectureSpec = prompting_mod.architectureSpec;
const planSpec = prompting_mod.planSpec;
const projectContextSpec = prompting_mod.projectContextSpec;
const loadRuntimeMemoryLayer = prompting_mod.loadRuntimeMemoryLayer;
const blockForMemoryLoadFailure = prompting_mod.blockForMemoryLoadFailure;
const loadPromptMemorySnapshot = prompting_mod.loadPromptMemorySnapshot;
const progressDocumentationText = prompting_mod.progressDocumentationText;
const blockForContextLimit = prompting_mod.blockForContextLimit;
const buildPromptWithContextBudget = prompting_mod.buildPromptWithContextBudget;
const executeToolRequests = tools_mod.executeToolRequests;
const shouldSkipWorkspacePath = tools_mod.shouldSkipWorkspacePath;
const appendWorkspaceEntries = tools_mod.appendWorkspaceEntries;
const sortStringsAsc = tools_mod.sortStringsAsc;
const sortStringsDesc = tools_mod.sortStringsDesc;
const listWorkspaceFiles = tools_mod.listWorkspaceFiles;
const summarizeCommandResult = tools_mod.summarizeCommandResult;
const searchText = tools_mod.searchText;
const readFileLimited = tools_mod.readFileLimited;
const writeFile = tools_mod.writeFile;
const runtimeToolSpec = tools_mod.runtimeToolSpec;
const toolAllowsWithoutConfirmation = tools_mod.toolAllowsWithoutConfirmation;
const toolRequestContextSpec = tools_mod.toolRequestContextSpec;
const validatedToolContextSpec = tools_mod.validatedToolContextSpec;
const validateToolRequest = tools_mod.validateToolRequest;
const buildToolExecutionFailure = tools_mod.buildToolExecutionFailure;
const executeValidatedToolRequest = tools_mod.executeValidatedToolRequest;
const toolRequestDisplay = tools_mod.toolRequestDisplay;
const confirmTool = tools_mod.confirmTool;
const runLoop = loop_mod.runLoop;
const executeStep = loop_mod.executeStep;
const executeDecanusTurn = loop_mod.executeDecanusTurn;
const executeSpecialistTurn = loop_mod.executeSpecialistTurn;
const structuredChatWithRepair = loop_mod.structuredChatWithRepair;

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
