const std = @import("std");
const core = @import("runtime_core.zig");
const assets_mod = @import("runtime_assets.zig");
const prompting_mod = @import("runtime_prompting.zig");
const provider_mod = @import("runtime_provider.zig");
const tools_mod = @import("runtime_tools.zig");
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

pub fn runLoop(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !void {
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

pub fn executeStep(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
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

pub fn executeDecanusTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
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

pub fn executeSpecialistTurn(allocator: std.mem.Allocator, config: AppConfig, state: *AppState, hooks: RuntimeHooks) !StepOutcome {
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

pub fn structuredChatWithRepair(
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
