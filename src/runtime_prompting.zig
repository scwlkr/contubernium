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
const coreSpecialists = core.coreSpecialists;
const helperRoster = core.helperRoster;
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
const normalizeGlobalMemoryMarkdown = assets_mod.normalizeGlobalMemoryMarkdown;
const stripGlobalMemoryVersionHeader = assets_mod.stripGlobalMemoryVersionHeader;
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

pub fn runtimeMemoryStatusLabel(layer: RuntimeMemoryLayer) []const u8 {
    if (layer.content.len == 0) return "empty";
    if (layer.truncated) return "loaded_truncated";
    return "loaded";
}

pub fn runtimeMemoryPromptText(layer: RuntimeMemoryLayer) []const u8 {
    if (layer.content.len == 0) return "none captured";
    return layer.content;
}

pub fn summarizeRuntimeMemorySnapshot(allocator: std.mem.Allocator, memory: RuntimeMemorySnapshot) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "architecture={s} status={s} source_chars={d} prompt_chars={d}\nplan={s} status={s} source_chars={d} prompt_chars={d}\nproject_context={s} status={s} source_chars={d} prompt_chars={d}\nproject_memory={s} status={s} source_chars={d} prompt_chars={d}\nglobal_memory={s} status={s} source_chars={d} prompt_chars={d}",
        .{
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            memory.architecture.content.len,
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            memory.plan.content.len,
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            memory.project_context.content.len,
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            memory.project.content.len,
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            memory.global.content.len,
        },
    );
}

fn latestOperatorReply(history: []const HistoryEntry) []const u8 {
    var index = history.len;
    while (index > 0) {
        index -= 1;
        const entry = history[index];
        if (eql(entry.type, "operator_reply") and entry.summary.len > 0) return entry.summary;
    }
    return "";
}

fn activeMissionAsk(state: *const AppState, latest_operator_reply: []const u8) []const u8 {
    if (latest_operator_reply.len > 0) return latest_operator_reply;
    if (state.mission.current_goal.len > 0) return state.mission.current_goal;
    return state.mission.initial_prompt;
}

pub fn specialistRoutingGuideText(allocator: std.mem.Allocator) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);
    try writer.writeAll("Core specialists (lane-default routing):\n");
    for (coreSpecialists()) |actor| {
        try writer.print(
            "- {s} -> lane={s} -> prefer `lane: \"{s}\"` or `agent_call: \"{s}\"` -> exact default action `{s}::{s}`\n",
            .{
                actorName(actor),
                laneName(laneForActor(actor)),
                laneName(laneForActor(actor)),
                actorName(actor),
                actorName(actor),
                defaultActionNameForActor(actor),
            },
        );
    }

    try writer.writeAll("Helper specialists (explicit invocation only):\n");
    for (helperRoster()) |actor| {
        try writer.print(
            "- {s} -> lane={s} -> invoke only with explicit `agent_call: \"{s}\"` or `actor: \"{s}\"` -> exact default action `{s}::{s}`\n",
            .{
                actorName(actor),
                laneName(laneForActor(actor)),
                actorName(actor),
                actorName(actor),
                actorName(actor),
                defaultActionNameForActor(actor),
            },
        );
    }

    return try buffer.toOwnedSlice(allocator);
}

pub fn decanusMissionHandlingGuidanceText() []const u8 {
    return "- Treat the latest non-empty operator reply as the active ask by default.\n" ++
        "- Treat the initial prompt as session origin and durable provenance, not as a sticky override of newer operator replies.\n" ++
        "- Use the current goal as the active interpretation of the latest meaningful operator turn.\n" ++
        "- Follow-up replies override stale mission framing unless they directly conflict with explicit prior constraints.\n" ++
        "- Prior plan files, history, and memory layers are background context and evidence, not controlling instructions unless the operator explicitly reaffirms them.\n" ++
        "- Keep commander orchestration in the background unless you need to surface a real block, required approval, or necessary clarification.\n" ++
        "- Reserve `action: \"ask_user\"` for real ambiguity, missing required constraints, or approvals that actually require the operator.\n" ++
        "- If the prompt is only a greeting, presence check, or other conversational opener that does not ask for project work yet, return `action: \"ask_user\"`.\n" ++
        "- For that greeting-only opener, keep the mission alive by leaving `final_response` empty and setting `question` to a short direct follow-up such as `Hello! What can I help with?`.\n" ++
        "- If the operator asks what the project does, what problem it solves, or requests a plain-language summary, use the already-loaded architecture, plan, project context, project memory, and global memory as evidence before asking follow-up questions or requesting more tools.\n" ++
        "- When that loaded memory already answers the question, prefer `action: \"finish\"` with a concise summary instead of broad repository searches.\n" ++
        "- If a search is still necessary, target the narrowest path that can answer the question. Do not leave `search_text` at the workspace root when the intent is to inspect project context files.\n" ++
        "- If the operator explicitly asks to brainstorm, ideate, or explore what could take the project further, you may return a direct exploratory response grounded in loaded evidence plus clearly signposted inference.\n" ++
        "- In that exploratory mode, you may surface technical, philosophical, product, UX, operational, advertising, distribution, or messaging gaps when they materially relate to the project.\n" ++
        "- Do not bounce open-ended creative exploration back to the operator just because the scope is broad. Pick a reasonable read-only lens, state assumptions briefly, and proceed.\n" ++
        "- If the operator asks for a read-only exploratory assessment or explicitly says to choose the scope yourself, pick a reasonable bounded review lens and proceed with a bounded read-only assessment. Do not bounce harmless prioritization back to the operator.\n" ++
        "- Exploratory answers still keep commander-first control: do not invent hidden implementation work or silently widen into execution the operator did not ask for.\n" ++
        "- When `final_response`, `question`, or blocked text needs multiple points, prefer markdown-lite operator output: a short lead sentence, then bullets or short headings when they improve scanability.\n" ++
        "- Use fenced code blocks for commands, snippets, or exact terminal text when verbatim formatting helps.\n" ++
        "- Keep trivial one-line replies short. Do not force headings or bullets when they add no value.\n" ++
        "- Do not invoke a specialist just because routing options exist.\n" ++
        "- Do not invent follow-on implementation work from the routing table or from unassigned task lanes.\n" ++
        "- The task summary only reflects specialist work that has been explicitly assigned during this mission.\n";
}

pub fn buildDecanusUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
) ![]const u8 {
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    const task_summary = try taskSummaryText(allocator, state.tasks);
    const constraints = try joinStrings(allocator, state.mission.constraints, ", ");
    const success_criteria = try joinStrings(allocator, state.mission.success_criteria, ", ");
    const latest_operator_reply = latestOperatorReply(state.agent_loop.history);
    const active_ask = activeMissionAsk(state, latest_operator_reply);
    const specialist_routing = try specialistRoutingGuideText(allocator);
    defer allocator.free(specialist_routing);
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

    try writer.print(
        \\Live State
        \\----------
        \\Active ask:
        \\{s}
        \\
        \\Latest operator reply:
        \\{s}
        \\
        \\Current goal:
        \\{s}
        \\
        \\Session seed (initial prompt):
        \\{s}
        \\
        \\Constraints:
        \\{s}
        \\
        \\Success criteria:
        \\{s}
        \\
        \\Mission handling rules
        \\----------------------
        \\{s}
        \\
    ,
        .{
            active_ask,
            if (latest_operator_reply.len > 0) latest_operator_reply else "none",
            state.mission.current_goal,
            state.mission.initial_prompt,
            constraints,
            success_criteria,
            decanusMissionHandlingGuidanceText(),
        },
    );

    try writer.print(
        \\Background evidence
        \\-------------------
        \\Architecture file: {s}
        \\Architecture status: {s}
        \\Architecture source chars: {d}
        \\Architecture:
        \\{s}
        \\
        \\Plan file: {s}
        \\Plan status: {s}
        \\Plan source chars: {d}
        \\Plan:
        \\{s}
        \\
        \\Project context file: {s}
        \\Project context status: {s}
        \\Project context source chars: {d}
        \\Project context:
        \\{s}
        \\
        \\Project memory file: {s}
        \\Project memory status: {s}
        \\Project memory source chars: {d}
        \\Project memory:
        \\{s}
        \\
        \\Global memory file: {s}
        \\Global memory status: {s}
        \\Global memory source chars: {d}
        \\Global memory:
        \\{s}
        \\
        \\Specialist routing
        \\-----------------
        \\{s}
        \\Valid fallback lane values: backend, frontend, systems, qa, research, brand, docs
        \\Helper specialists are explicit-only. Use `agent_call` or `actor` for helpers; helper work records its own lane after the target is resolved.
        \\When `action` is `invoke_specialist`, prefer a bare agent name in `agent_call`. Use an exact `agent::ACTION` only when it matches a real Contubernium action file.
        \\
        \\Iteration: {d}
        \\Status: {s}
        \\Active tool: {s}
        \\Last decision: {s}
        \\Last tool result: {s}
        \\
        \\Assigned specialist tasks
        \\-------------------------
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
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            runtimeMemoryPromptText(memory.architecture),
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            runtimeMemoryPromptText(memory.plan),
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            runtimeMemoryPromptText(memory.project_context),
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            runtimeMemoryPromptText(memory.project),
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            runtimeMemoryPromptText(memory.global),
            specialist_routing,
            state.agent_loop.iteration,
            @tagName(state.agent_loop.status),
            maybeActorName(state.agent_loop.active_tool),
            state.agent_loop.last_decision,
            state.agent_loop.last_tool_result,
            task_summary,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

pub fn buildSpecialistUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
    lane: []const u8,
) ![]const u8 {
    const lane_value = std.meta.stringToEnum(Lane, lane) orelse .docs;
    const task = taskForLaneConst(state, lane_value);
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    const context_files = try joinStrings(allocator, task.invocation.context.files, ", ");
    const context_constraints = try joinStrings(allocator, task.invocation.context.constraints, ", ");
    const context_dependencies = try joinStrings(allocator, task.invocation.context.dependencies, ", ");
    const allowed_actions = try joinStrings(allocator, task.invocation.scope.allowed_actions, ", ");
    const restricted_actions = try joinStrings(allocator, task.invocation.scope.restricted_actions, ", ");
    const relevant_memory = try joinStrings(allocator, task.invocation.memory.relevant, ", ");
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

    try writer.print(
        \\Project Context
        \\---------------
        \\Architecture file: {s}
        \\Architecture status: {s}
        \\Architecture source chars: {d}
        \\Architecture:
        \\{s}
        \\
        \\Plan file: {s}
        \\Plan status: {s}
        \\Plan source chars: {d}
        \\Plan:
        \\{s}
        \\
        \\Project context file: {s}
        \\Project context status: {s}
        \\Project context source chars: {d}
        \\Project context:
        \\{s}
        \\
        \\Project memory file: {s}
        \\Project memory status: {s}
        \\Project memory source chars: {d}
        \\Project memory:
        \\{s}
        \\
        \\Global memory file: {s}
        \\Global memory status: {s}
        \\Global memory source chars: {d}
        \\Global memory:
        \\{s}
        \\
    ,
        .{
            memory.architecture.path,
            runtimeMemoryStatusLabel(memory.architecture),
            memory.architecture.source_chars,
            runtimeMemoryPromptText(memory.architecture),
            memory.plan.path,
            runtimeMemoryStatusLabel(memory.plan),
            memory.plan.source_chars,
            runtimeMemoryPromptText(memory.plan),
            memory.project_context.path,
            runtimeMemoryStatusLabel(memory.project_context),
            memory.project_context.source_chars,
            runtimeMemoryPromptText(memory.project_context),
            memory.project.path,
            runtimeMemoryStatusLabel(memory.project),
            memory.project.source_chars,
            runtimeMemoryPromptText(memory.project),
            memory.global.path,
            runtimeMemoryStatusLabel(memory.global),
            memory.global.source_chars,
            runtimeMemoryPromptText(memory.global),
        },
    );
    try writer.print(
        \\Live State
        \\----------
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
        \\Agent call: {s}
        \\Selected action: {s}
        \\Objective: {s}
        \\Completion signal: {s}
        \\Context.project: {s}
        \\Context.files: {s}
        \\Context.constraints: {s}
        \\Context.dependencies: {s}
        \\Scope.allowed_actions: {s}
        \\Scope.restricted_actions: {s}
        \\Memory.mission: {s}
        \\Memory.project: {s}
        \\Memory.relevant: {s}
        \\
        \\Subordinate tool loop
        \\---------------------
        \\Status: {s}
        \\Completed cycles: {d}
        \\Last request summary: {s}
        \\Last result summary: {s}
        \\Return to: {s}
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
            @tagName(task.invocation.status),
            task.invocation.agent_call,
            task.invocation.action_name,
            task.invocation.objective,
            task.invocation.completion_signal,
            task.invocation.context.project,
            context_files,
            context_constraints,
            context_dependencies,
            allowed_actions,
            restricted_actions,
            task.invocation.memory.mission,
            task.invocation.memory.project,
            relevant_memory,
            @tagName(task.invocation.tool_loop.status),
            task.invocation.tool_loop.cycle_count,
            task.invocation.tool_loop.last_request_summary,
            task.invocation.tool_loop.last_result_summary,
            actorName(task.invocation.return_to),
            state.agent_loop.last_tool_result,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

pub fn assembleSystemPrompt(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    state: *const AppState,
    actor: Actor,
) ![]const u8 {
    const base = try readSharedAsset(allocator, layout, "patterns/RUNTIME_BASE.md");
    defer allocator.free(base);
    const policy = try readSharedAsset(allocator, layout, "patterns/TOOL_POLICY.md");
    defer allocator.free(policy);
    const soul = try readAgentAsset(allocator, layout, actor, "SOUL.md");
    defer allocator.free(soul);
    const contract = try readAgentAsset(allocator, layout, actor, "CONTRACT.md");
    defer allocator.free(contract);
    const skill = try readAgentAsset(allocator, layout, actor, "SKILL.md");
    defer allocator.free(skill);
    const schema = try readSharedAsset(
        allocator,
        layout,
        if (actor == .decanus) "templates/DECANUS_DECISION_SCHEMA.json" else "templates/SPECIALIST_RESULT_SCHEMA.json",
    );
    defer allocator.free(schema);

    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);
    try writer.print("{s}\n\n{s}\n\n{s}\n\n{s}\n\n{s}\n", .{ base, policy, soul, contract, skill });
    try appendSelectedActionSections(allocator, writer, layout, state, actor);
    if (actor == .decanus) {
        try writer.writeAll(
            "\nDecision output rules:\n" ++
                "- The JSON `action` field must be one of: `finish`, `invoke_specialist`, `tool_request`, `ask_user`, or `blocked`.\n" ++
                "- Do not use action file names such as `EVALUATE_LOOP`, `INVOKE_SPECIALIST`, or `FINISH_MISSION` as the JSON `action` value.\n",
        );
    }
    try writer.print("\nResponse schema reference:\n{s}\n", .{schema});
    return try buffer.toOwnedSlice(allocator);
}

pub fn buildCondensedHistorySummary(
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

    return try truncateOwnedText(allocator, try joinStrings(allocator, lines.items, "\n"), max_chars);
}

pub fn condenseHistoryForContext(allocator: std.mem.Allocator, config: ContextConfig, state: *AppState) !bool {
    const keep_recent = @max(@as(usize, 1), config.condensed_keep_recent_events);
    if (state.agent_loop.history.len <= keep_recent + 1) return false;

    const previous = state.agent_loop.history;
    const split_index = previous.len - keep_recent;
    const older = previous[0..split_index];
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
    try history.appendSlice(allocator, previous[split_index..]);
    state.agent_loop.history = try history.toOwnedSlice(allocator);
    allocator.free(previous);
    state.runtime_session.context_budget.condensation_count += 1;
    state.runtime_session.context_budget.condensed_history_events += older.len;
    state.runtime_session.context_budget.last_condensed_iteration = state.agent_loop.iteration;
    return true;
}

pub fn projectMemorySpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "project",
        .path = config.paths.project_memory_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

pub fn globalMemorySpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "global",
        .path = config.paths.global_memory_file,
        .max_chars = config.context.max_global_memory_chars,
    };
}

pub fn architectureSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "architecture",
        .path = config.paths.architecture_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

pub fn planSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "plan",
        .path = config.paths.plan_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

pub fn projectContextSpec(config: AppConfig) RuntimeMemorySpec {
    return .{
        .kind = "project_context",
        .path = config.paths.project_context_file,
        .max_chars = config.context.max_project_memory_chars,
    };
}

pub fn loadRuntimeMemoryLayer(allocator: std.mem.Allocator, spec: RuntimeMemorySpec) !RuntimeMemoryLayer {
    const memory_path = trimAscii(spec.path);
    if (memory_path.len == 0 or !pathIsSafeForWorkspace(memory_path)) {
        return error.MemoryPathInvalid;
    }

    const data = std.fs.cwd().readFileAlloc(allocator, memory_path, max_file_bytes) catch |err| switch (err) {
        error.FileNotFound => return error.MemoryLayerMissing,
        else => return err,
    };
    defer allocator.free(data);

    const normalized = if (eql(spec.kind, "global"))
        try normalizeGlobalMemoryMarkdown(allocator, data)
    else
        try allocator.dupe(u8, data);
    defer allocator.free(normalized);

    const trimmed = if (eql(spec.kind, "global"))
        stripGlobalMemoryVersionHeader(normalized)
    else
        trimAscii(normalized);
    const truncated = spec.max_chars > 0 and trimmed.len > spec.max_chars;
    const content = if (trimmed.len == 0)
        ""
    else if (truncated)
        try truncateText(allocator, trimmed, spec.max_chars)
    else
        try allocator.dupe(u8, trimmed);

    return .{
        .kind = spec.kind,
        .path = memory_path,
        .content = content,
        .source_chars = trimmed.len,
        .truncated = truncated,
        .owns_content = content.len > 0,
    };
}

pub fn blockForMemoryLoadFailure(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    spec: RuntimeMemorySpec,
    err: anyerror,
) !void {
    const error_code = switch (err) {
        error.MemoryPathInvalid => "MEMORY_PATH_INVALID",
        error.MemoryLayerMissing => "MEMORY_LAYER_MISSING",
        error.FileTooBig => "MEMORY_LAYER_TOO_LARGE",
        else => "MEMORY_LOAD_FAILED",
    };
    const message = switch (err) {
        error.MemoryPathInvalid => try std.fmt.allocPrint(
            allocator,
            "{s} memory path must stay inside the workspace: {s}",
            .{ spec.kind, spec.path },
        ),
        error.MemoryLayerMissing => try std.fmt.allocPrint(
            allocator,
            "{s} memory file is missing: {s}",
            .{ spec.kind, spec.path },
        ),
        error.FileTooBig => try std.fmt.allocPrint(
            allocator,
            "{s} memory file exceeds the runtime load ceiling: {s}",
            .{ spec.kind, spec.path },
        ),
        else => try std.fmt.allocPrint(
            allocator,
            "failed to load {s} memory from {s}",
            .{ spec.kind, spec.path },
        ),
    };

    const failure = buildRuntimeFailure(state, state.current_actor, laneForActor(state.current_actor), error_code, message, .{
        .target = spec.path,
        .detail = @errorName(err),
    });
    recordRuntimeFailure(state, failure);
    stateManager(state).markBlocked(state.current_actor, laneForActor(state.current_actor), message);
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "memory_load_blocked",
        .actor = actorName(state.current_actor),
        .lane = currentLaneForState(state.*),
        .summary = message,
        .artifacts = &.{spec.path},
        .timestamp = try unixTimestampString(allocator),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = state.current_actor,
        .lane = laneForActor(state.current_actor),
        .action = "memory_load_failed",
        .status = "blocked",
        .summary = message,
        .error_text = message,
        .failure = failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, "runtime", "Memory Load Failed", message, .plain);
    emitStateSnapshot(hooks, config, state.*);
}

pub fn loadPromptMemorySnapshot(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
) !RuntimeMemorySnapshot {
    const architecture_spec = architectureSpec(config);
    const architecture = loadRuntimeMemoryLayer(allocator, architecture_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, architecture_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer architecture.deinit(allocator);

    const plan_spec = planSpec(config);
    const plan = loadRuntimeMemoryLayer(allocator, plan_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, plan_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer plan.deinit(allocator);

    const project_context_spec = projectContextSpec(config);
    const project_context = loadRuntimeMemoryLayer(allocator, project_context_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, project_context_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer project_context.deinit(allocator);

    const project_spec = projectMemorySpec(config);
    const project = loadRuntimeMemoryLayer(allocator, project_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, project_spec, err);
        return error.MemoryLoadBlocked;
    };
    errdefer project.deinit(allocator);

    const global_spec = globalMemorySpec(config);
    const global = loadRuntimeMemoryLayer(allocator, global_spec) catch |err| {
        try blockForMemoryLoadFailure(allocator, config, state, hooks, global_spec, err);
        return error.MemoryLoadBlocked;
    };

    return .{
        .architecture = architecture,
        .plan = plan,
        .project_context = project_context,
        .project = project,
        .global = global,
    };
}

pub fn progressDocumentationText(
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
    return try truncateOwnedText(
        allocator,
        try std.fmt.allocPrint(
            allocator,
            "{s}\n\ncurrent goal: {s}\nloop: {d}/{d}\ncurrent actor: {s}\nactive tool: {s}\nlatest result: {s}\ntasks: {s}\nrecent progress:\n{s}",
            .{
                reason,
                if (state.mission.current_goal.len > 0) state.mission.current_goal else "idle",
                state.agent_loop.iteration,
                state.agent_loop.max_iterations,
                actorName(state.current_actor),
                if (state.agent_loop.active_tool) |active_tool| actorName(active_tool) else "none",
                latest_result,
                task_summary,
                recent_history,
            },
        ),
        max_chars,
    );
}

pub fn blockForContextLimit(
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
    const failure = buildRuntimeFailure(state, state.current_actor, laneForActor(state.current_actor), "CONTEXT_BUDGET_EXCEEDED", message, .{});
    recordRuntimeFailure(state, failure);
    stateManager(state).markBlocked(state.current_actor, laneForActor(state.current_actor), message);
    try appendHistory(allocator, state, .{
        .iteration = state.agent_loop.iteration,
        .type = "context_budget_blocked",
        .actor = actorName(state.current_actor),
        .lane = currentLaneForState(state.*),
        .summary = message,
        .artifacts = &.{},
        .timestamp = try unixTimestampString(allocator),
    });
    try logRuntimeEvent(allocator, config, state, .{
        .actor = state.current_actor,
        .lane = laneForActor(state.current_actor),
        .action = "context_budget_blocked",
        .status = "blocked",
        .summary = message,
        .error_text = message,
        .failure = failure,
        .include_snapshot = true,
    });
    emitLog(hooks, .danger, "runtime", "Context Budget Reached", message, .plain);
    emitStateSnapshot(hooks, config, state.*);
}

pub fn buildPromptWithContextBudget(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *AppState,
    hooks: RuntimeHooks,
    system_prompt: []const u8,
    mode: PromptMode,
    lane: []const u8,
) !PromptBuildResult {
    const memory = try loadPromptMemorySnapshot(allocator, config, state, hooks);
    errdefer memory.deinit(allocator);

    if (memory.architecture.truncated or
        memory.plan.truncated or
        memory.project_context.truncated or
        memory.project.truncated or
        memory.global.truncated)
    {
        emitLog(
            hooks,
            .warning,
            "runtime",
            "Memory Trimmed",
            try summarizeRuntimeMemorySnapshot(allocator, memory),
            .plain,
        );
    }

    var attempt: usize = 0;
    while (true) {
        const user_prompt = switch (mode) {
            .decanus => try buildDecanusUserPrompt(allocator, config, state, memory),
            .specialist => try buildSpecialistUserPrompt(allocator, config, state, memory, lane),
        };
        const estimate = estimatePromptBudget(config.context, system_prompt, user_prompt);
        applyPromptBudgetEstimate(state, config.context, estimate);
        emitStateSnapshot(hooks, config, state.*);

        if (!estimate.should_condense or attempt >= 3) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return .{
                .user_prompt = user_prompt,
                .memory = memory,
            };
        }

        const condensed = try condenseHistoryForContext(allocator, config.context, state);
        if (!condensed) {
            if (estimate.exhausted) {
                try blockForContextLimit(allocator, config, state, hooks, estimate);
                return error.ContextBudgetExceeded;
            }
            return .{
                .user_prompt = user_prompt,
                .memory = memory,
            };
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
        try logRuntimeEvent(allocator, config, state, .{
            .actor = state.current_actor,
            .lane = laneForActor(state.current_actor),
            .action = "context_condensed",
            .status = "success",
            .summary = try std.fmt.allocPrint(
                allocator,
                "condensed {d} earlier events and rebuilt the prompt budget",
                .{
                    state.runtime_session.context_budget.condensed_history_events,
                },
            ),
            .include_snapshot = true,
        });
        attempt += 1;
    }
}
