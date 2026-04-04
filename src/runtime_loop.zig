const std = @import("std");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const assets_mod = @import("runtime_assets.zig");
const prompting_mod = @import("runtime_prompting.zig");
const provider_mod = @import("runtime_provider.zig");
const tools_mod = @import("runtime_tools.zig");
const commander_mod = @import("runtime_commander_loop.zig");
const specialist_mod = @import("runtime_specialist_loop.zig");
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
const ActiveModelRoute = core.ActiveModelRoute;
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
const resolveModelPolicy = core.resolveModelPolicy;
const initialModelRouteForActor = core.initialModelRouteForActor;
const escalationRouteForActor = core.escalationRouteForActor;
const fallbackRouteForActor = core.fallbackRouteForActor;
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
const parseModelJson = model_json.parseModelJson;
const prettyPrintJson = model_json.prettyPrintJson;
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
const logRuntimeEventWithUi = assets_mod.logRuntimeEventWithUi;
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

pub fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks, ext_cache: ?*prompting_mod.PromptCache) !void {
    var local_cache = prompting_mod.PromptCache{};
    const cache: *prompting_mod.PromptCache = ext_cache orelse &local_cache;
    defer if (ext_cache == null) local_cache.deinit(allocator);
    ensureLoopBudget(state);
    while (state.agent_loop.iteration < state.agent_loop.max_iterations) {
        if (hooks.isInterrupted()) {
            markInterrupted(state);
            try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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

        const outcome = try executeStep(allocator, config, state, hooks, cache);
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
    try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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

pub fn executeStep(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks, cache: ?*prompting_mod.PromptCache) !StepOutcome {
    if (state.mission.initial_prompt.len == 0) {
        try stderrPrint("mission prompt is empty; use `contubernium mission start`\n", .{});
        return error.MissionNotInitialized;
    }

    if (hooks.isInterrupted()) {
        markInterrupted(state);
        try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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
        return try executeSpecialistTurn(allocator, config, state, hooks, cache);
    }
    return try executeDecanusTurn(allocator, config, state, hooks, cache);
}

pub const executeDecanusTurn = commander_mod.executeDecanusTurn;
pub const resolvedDecanusControlAction = commander_mod.resolvedDecanusControlAction;
pub const executeSpecialistTurn = specialist_mod.executeSpecialistTurn;
pub const structuredChatWithRepair = provider_mod.structuredChatWithRepair;
