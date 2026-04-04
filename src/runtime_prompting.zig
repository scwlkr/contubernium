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
const logRuntimeEventWithUi = assets_mod.logRuntimeEventWithUi;

pub const PromptCache = struct {
    system_prompt: ?[]const u8 = null,
    cached_actor: ?Actor = null,
    cached_action_name: []const u8 = "",
    asset_layout: ?GlobalAssetLayout = null,
    routing_guide: ?[]const u8 = null,

    pub fn deinit(self: *PromptCache, allocator: std.mem.Allocator) void {
        if (self.system_prompt) |sp| allocator.free(sp);
        if (self.routing_guide) |rg| allocator.free(rg);
        if (self.asset_layout) |layout| deinitGlobalAssetLayout(allocator, layout);
        self.* = .{};
    }
};

fn currentActionNameForActor(state: *const AppState, actor: Actor) []const u8 {
    if (actor == .decanus) return "";
    const lane = laneForActor(actor);
    const task = taskForLaneConst(state, lane);
    return task.invocation.action_name;
}

pub fn resolveOrCacheAssetLayout(allocator: std.mem.Allocator, cache: *PromptCache) !GlobalAssetLayout {
    if (cache.asset_layout) |layout| return layout;
    const layout = try resolveGlobalAssetLayout(allocator);
    cache.asset_layout = layout;
    return layout;
}

pub fn assembleOrCacheSystemPrompt(
    allocator: std.mem.Allocator,
    layout: GlobalAssetLayout,
    state: *const AppState,
    actor: Actor,
    cache: *PromptCache,
) ![]const u8 {
    const current_action = currentActionNameForActor(state, actor);
    if (cache.system_prompt) |sp| {
        if (cache.cached_actor == actor and eql(cache.cached_action_name, current_action)) {
            return try allocator.dupe(u8, sp);
        }
        allocator.free(sp);
        cache.system_prompt = null;
    }
    const sp = try assembleSystemPrompt(allocator, layout, state, actor);
    cache.system_prompt = try allocator.dupe(u8, sp);
    cache.cached_actor = actor;
    cache.cached_action_name = current_action;
    return sp;
}

pub fn resolveOrCacheRoutingGuide(allocator: std.mem.Allocator, cache: *PromptCache) ![]const u8 {
    if (cache.routing_guide) |rg| return try allocator.dupe(u8, rg);
    const rg = try specialistRoutingGuideText(allocator);
    cache.routing_guide = try allocator.dupe(u8, rg);
    return rg;
}

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

const PromptMemoryKind = enum {
    architecture,
    plan,
    project_context,
    project,
    global,
};

const PromptEvidenceProfile = struct {
    ordered_kinds: []const PromptMemoryKind,
    max_layers: usize,
    excerpt_chars: usize,
};

const PromptEvidenceSelection = struct {
    kinds: [5]PromptMemoryKind = undefined,
    len: usize = 0,

    fn append(self: *PromptEvidenceSelection, kind: PromptMemoryKind) void {
        self.kinds[self.len] = kind;
        self.len += 1;
    }

    fn items(self: *const PromptEvidenceSelection) []const PromptMemoryKind {
        return self.kinds[0..self.len];
    }
};

fn maybeFreePromptText(allocator: std.mem.Allocator, text: []const u8, sentinel: []const u8) void {
    if (!eql(text, sentinel)) allocator.free(text);
}

const DecanusPromptStaticFragments = struct {
    constraints: []const u8,
    success_criteria: []const u8,
    task_summary: []const u8,
    routing: []const u8,
    memory_ledger: []const u8,
    selected_memory: []const u8,
    last_decision: []const u8,
    last_tool_result: []const u8,

    pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        maybeFreePromptText(allocator, self.constraints, "");
        maybeFreePromptText(allocator, self.success_criteria, "");
        maybeFreePromptText(allocator, self.task_summary, "none assigned");
        allocator.free(self.routing);
        allocator.free(self.memory_ledger);
        allocator.free(self.selected_memory);
        allocator.free(self.last_decision);
        allocator.free(self.last_tool_result);
    }
};

const SpecialistPromptStaticFragments = struct {
    context_files: []const u8,
    context_constraints: []const u8,
    context_dependencies: []const u8,
    allowed_actions: []const u8,
    restricted_actions: []const u8,
    relevant_memory: []const u8,
    memory_ledger: []const u8,
    selected_memory: []const u8,
    last_tool_result: []const u8,

    pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        maybeFreePromptText(allocator, self.context_files, "");
        maybeFreePromptText(allocator, self.context_constraints, "");
        maybeFreePromptText(allocator, self.context_dependencies, "");
        maybeFreePromptText(allocator, self.allowed_actions, "");
        maybeFreePromptText(allocator, self.restricted_actions, "");
        maybeFreePromptText(allocator, self.relevant_memory, "");
        allocator.free(self.memory_ledger);
        allocator.free(self.selected_memory);
        allocator.free(self.last_tool_result);
    }
};

const PromptStaticFragments = union(enum) {
    decanus: DecanusPromptStaticFragments,
    specialist: SpecialistPromptStaticFragments,

    pub fn deinit(self: @This(), allocator: std.mem.Allocator) void {
        switch (self) {
            .decanus => |fragments| fragments.deinit(allocator),
            .specialist => |fragments| fragments.deinit(allocator),
        }
    }
};

const decanus_memory_order = [_]PromptMemoryKind{
    .project_context,
    .project,
    .architecture,
    .global,
    .plan,
};

const backend_memory_order = [_]PromptMemoryKind{
    .architecture,
    .plan,
    .project_context,
    .project,
    .global,
};

const frontend_memory_order = [_]PromptMemoryKind{
    .project_context,
    .project,
    .architecture,
    .plan,
    .global,
};

const systems_memory_order = [_]PromptMemoryKind{
    .architecture,
    .plan,
    .project,
    .project_context,
    .global,
};

const qa_memory_order = [_]PromptMemoryKind{
    .architecture,
    .plan,
    .project_context,
    .project,
    .global,
};

const research_memory_order = [_]PromptMemoryKind{
    .project_context,
    .architecture,
    .plan,
    .global,
    .project,
};

const brand_memory_order = [_]PromptMemoryKind{
    .project_context,
    .project,
    .global,
    .plan,
    .architecture,
};

const docs_memory_order = [_]PromptMemoryKind{
    .project_context,
    .project,
    .plan,
    .architecture,
    .global,
};

const media_memory_order = [_]PromptMemoryKind{
    .project_context,
    .project,
    .global,
    .plan,
    .architecture,
};

const bulk_ops_memory_order = [_]PromptMemoryKind{
    .plan,
    .project,
    .project_context,
    .architecture,
    .global,
};

fn promptEvidenceProfile(mode: PromptMode, lane: Lane) PromptEvidenceProfile {
    return switch (mode) {
        .decanus => .{
            .ordered_kinds = &decanus_memory_order,
            .max_layers = 4,
            .excerpt_chars = 720,
        },
        .specialist => switch (lane) {
            .backend => .{
                .ordered_kinds = &backend_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .frontend => .{
                .ordered_kinds = &frontend_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .systems => .{
                .ordered_kinds = &systems_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .qa => .{
                .ordered_kinds = &qa_memory_order,
                .max_layers = 3,
                .excerpt_chars = 640,
            },
            .research => .{
                .ordered_kinds = &research_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .brand => .{
                .ordered_kinds = &brand_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .docs => .{
                .ordered_kinds = &docs_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .media => .{
                .ordered_kinds = &media_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .bulk_ops => .{
                .ordered_kinds = &bulk_ops_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
            .command => .{
                .ordered_kinds = &decanus_memory_order,
                .max_layers = 3,
                .excerpt_chars = 680,
            },
        },
    };
}

fn memoryKindLabel(kind: PromptMemoryKind) []const u8 {
    return switch (kind) {
        .architecture => "architecture",
        .plan => "plan",
        .project_context => "project_context",
        .project => "project",
        .global => "global",
    };
}

fn memoryTitle(kind: PromptMemoryKind) []const u8 {
    return switch (kind) {
        .architecture => "Architecture",
        .plan => "Plan",
        .project_context => "Project context",
        .project => "Project memory",
        .global => "Global memory",
    };
}

fn memoryLayerForKind(memory: RuntimeMemorySnapshot, kind: PromptMemoryKind) RuntimeMemoryLayer {
    return switch (kind) {
        .architecture => memory.architecture,
        .plan => memory.plan,
        .project_context => memory.project_context,
        .project => memory.project,
        .global => memory.global,
    };
}

fn selectedMemoryKinds(memory: RuntimeMemorySnapshot, profile: PromptEvidenceProfile) PromptEvidenceSelection {
    var selection = PromptEvidenceSelection{};
    for (profile.ordered_kinds) |kind| {
        if (selection.len >= profile.max_layers) break;
        const layer = memoryLayerForKind(memory, kind);
        if (layer.content.len == 0) continue;
        selection.append(kind);
    }
    return selection;
}

fn selectionContains(selection: PromptEvidenceSelection, kind: PromptMemoryKind) bool {
    for (selection.items()) |selected| {
        if (selected == kind) return true;
    }
    return false;
}

fn buildMemoryLedger(
    allocator: std.mem.Allocator,
    memory: RuntimeMemorySnapshot,
    selection: PromptEvidenceSelection,
) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    inline for ([_]PromptMemoryKind{ .architecture, .plan, .project_context, .project, .global }) |kind| {
        const layer = memoryLayerForKind(memory, kind);
        try writer.print(
            "- {s}: path={s} status={s} source_chars={d} prompt_chars={d} selected={s}\n",
            .{
                memoryKindLabel(kind),
                layer.path,
                runtimeMemoryStatusLabel(layer),
                layer.source_chars,
                layer.content.len,
                if (selectionContains(selection, kind)) "yes" else "no",
            },
        );
    }

    return try buffer.toOwnedSlice(allocator);
}

fn buildSelectedMemoryExcerpts(
    allocator: std.mem.Allocator,
    memory: RuntimeMemorySnapshot,
    selection: PromptEvidenceSelection,
    excerpt_chars: usize,
) ![]const u8 {
    if (selection.len == 0) return try allocator.dupe(u8, "none captured");

    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    for (selection.items()) |kind| {
        const layer = memoryLayerForKind(memory, kind);
        const excerpt = try truncateText(allocator, runtimeMemoryPromptText(layer), excerpt_chars);
        defer if (excerpt.ptr != layer.content.ptr) allocator.free(excerpt);

        try writer.print(
            "{s}: path={s} status={s} source_chars={d}\n{s}\n\n",
            .{
                memoryTitle(kind),
                layer.path,
                runtimeMemoryStatusLabel(layer),
                layer.source_chars,
                excerpt,
            },
        );
    }

    return try buffer.toOwnedSlice(allocator);
}

fn compactPromptField(
    allocator: std.mem.Allocator,
    value: []const u8,
    max_lines: usize,
    max_chars: usize,
    fallback: []const u8,
) ![]const u8 {
    const source = if (trimAscii(value).len > 0) value else fallback;
    return try compactTextForUi(allocator, source, max_lines, max_chars);
}

fn buildDecanusPromptStaticFragments(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
    cached_routing_guide: ?[]const u8,
) !DecanusPromptStaticFragments {
    const profile = promptEvidenceProfile(.decanus, .command);
    const selection = selectedMemoryKinds(memory, profile);
    const tool_result_limit = if (config.context.max_tool_result_chars < 420) config.context.max_tool_result_chars else 420;

    return .{
        .constraints = try joinStrings(allocator, state.mission.constraints, ", "),
        .success_criteria = try joinStrings(allocator, state.mission.success_criteria, ", "),
        .task_summary = try taskSummaryText(allocator, state.tasks),
        .routing = if (cached_routing_guide) |rg| try allocator.dupe(u8, rg) else try specialistRoutingGuideText(allocator),
        .memory_ledger = try buildMemoryLedger(allocator, memory, selection),
        .selected_memory = try buildSelectedMemoryExcerpts(allocator, memory, selection, profile.excerpt_chars),
        .last_decision = try compactPromptField(allocator, state.agent_loop.last_decision, 4, 320, "none"),
        .last_tool_result = try compactPromptField(allocator, state.agent_loop.last_tool_result, 5, tool_result_limit, "none"),
    };
}

fn buildSpecialistPromptStaticFragments(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
    lane: []const u8,
) !SpecialistPromptStaticFragments {
    const lane_value = std.meta.stringToEnum(Lane, lane) orelse .docs;
    const task = taskForLaneConst(state, lane_value);
    const profile = promptEvidenceProfile(.specialist, lane_value);
    const selection = selectedMemoryKinds(memory, profile);
    const tool_result_limit = if (config.context.max_tool_result_chars < 420) config.context.max_tool_result_chars else 420;

    return .{
        .context_files = try joinStrings(allocator, task.invocation.context.files, ", "),
        .context_constraints = try joinStrings(allocator, task.invocation.context.constraints, ", "),
        .context_dependencies = try joinStrings(allocator, task.invocation.context.dependencies, ", "),
        .allowed_actions = try joinStrings(allocator, task.invocation.scope.allowed_actions, ", "),
        .restricted_actions = try joinStrings(allocator, task.invocation.scope.restricted_actions, ", "),
        .relevant_memory = try joinStrings(allocator, task.invocation.memory.relevant, ", "),
        .memory_ledger = try buildMemoryLedger(allocator, memory, selection),
        .selected_memory = try buildSelectedMemoryExcerpts(allocator, memory, selection, profile.excerpt_chars),
        .last_tool_result = try compactPromptField(allocator, state.agent_loop.last_tool_result, 5, tool_result_limit, "none"),
    };
}

fn buildDecanusUserPromptFromFragments(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    fragments: DecanusPromptStaticFragments,
) ![]const u8 {
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    defer maybeFreePromptText(allocator, history, "none");

    const latest_operator_reply = latestOperatorReply(state.agent_loop.history);
    const active_ask = activeMissionAsk(state, latest_operator_reply);
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
        \\Memory ledger
        \\-------------
        \\{s}
        \\
        \\Selected evidence excerpts
        \\--------------------------
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
            active_ask,
            if (latest_operator_reply.len > 0) latest_operator_reply else "none",
            state.mission.current_goal,
            state.mission.initial_prompt,
            fragments.constraints,
            fragments.success_criteria,
            fragments.memory_ledger,
            fragments.selected_memory,
            fragments.routing,
            state.agent_loop.iteration,
            @tagName(state.agent_loop.status),
            maybeActorName(state.agent_loop.active_tool),
            fragments.last_decision,
            fragments.last_tool_result,
            fragments.task_summary,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

fn buildSpecialistUserPromptFromFragments(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    fragments: SpecialistPromptStaticFragments,
    lane: []const u8,
) ![]const u8 {
    const history = try recentHistoryText(allocator, state.agent_loop.history, config.context.max_history_events);
    defer maybeFreePromptText(allocator, history, "none");

    const lane_value = std.meta.stringToEnum(Lane, lane) orelse .docs;
    const task = taskForLaneConst(state, lane_value);
    var buffer: std.ArrayList(u8) = .empty;
    const writer = buffer.writer(allocator);

    try writer.print(
        \\Project Evidence
        \\----------------
        \\Memory ledger
        \\-------------
        \\{s}
        \\
        \\Selected evidence excerpts
        \\--------------------------
        \\{s}
        \\
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
            fragments.memory_ledger,
            fragments.selected_memory,
            state.mission.initial_prompt,
            state.mission.current_goal,
            lane,
            @tagName(task.invocation.status),
            task.invocation.agent_call,
            task.invocation.action_name,
            task.invocation.objective,
            task.invocation.completion_signal,
            task.invocation.context.project,
            fragments.context_files,
            fragments.context_constraints,
            fragments.context_dependencies,
            fragments.allowed_actions,
            fragments.restricted_actions,
            task.invocation.memory.mission,
            task.invocation.memory.project,
            fragments.relevant_memory,
            @tagName(task.invocation.tool_loop.status),
            task.invocation.tool_loop.cycle_count,
            task.invocation.tool_loop.last_request_summary,
            task.invocation.tool_loop.last_result_summary,
            actorName(task.invocation.return_to),
            fragments.last_tool_result,
            history,
        },
    );

    return try truncateOwnedText(allocator, try buffer.toOwnedSlice(allocator), config.context.max_prompt_chars);
}

pub fn buildDecanusUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
) ![]const u8 {
    const fragments = try buildDecanusPromptStaticFragments(allocator, config, state, memory, null);
    defer fragments.deinit(allocator);
    return try buildDecanusUserPromptFromFragments(allocator, config, state, fragments);
}

pub fn buildSpecialistUserPrompt(
    allocator: std.mem.Allocator,
    config: AppConfig,
    state: *const AppState,
    memory: RuntimeMemorySnapshot,
    lane: []const u8,
) ![]const u8 {
    const fragments = try buildSpecialistPromptStaticFragments(allocator, config, state, memory, lane);
    defer fragments.deinit(allocator);
    return try buildSpecialistUserPromptFromFragments(allocator, config, state, fragments, lane);
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
        try writer.print("\nMission handling rules\n----------------------\n{s}\n", .{decanusMissionHandlingGuidanceText()});
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
    try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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
    try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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
    cached_routing_guide: ?[]const u8,
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

    var static_fragments = switch (mode) {
        .decanus => PromptStaticFragments{
            .decanus = try buildDecanusPromptStaticFragments(allocator, config, state, memory, cached_routing_guide),
        },
        .specialist => PromptStaticFragments{
            .specialist = try buildSpecialistPromptStaticFragments(allocator, config, state, memory, lane),
        },
    };
    defer static_fragments.deinit(allocator);

    var attempt: usize = 0;
    while (true) {
        const user_prompt = switch (static_fragments) {
            .decanus => |fragments| try buildDecanusUserPromptFromFragments(allocator, config, state, fragments),
            .specialist => |fragments| try buildSpecialistUserPromptFromFragments(allocator, config, state, fragments, lane),
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
        try logRuntimeEventWithUi(allocator, config, state, hooks, .{
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

    try testing.expect(std.mem.indexOf(u8, prompt, "Memory ledger") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "- architecture: path=.contubernium/ARCHITECTURE.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "System structure lives here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "- project: path=.contubernium/project.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Architecture decisions live here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "- global: path=.contubernium/global.md") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Reusable strategies live here.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Current execution order lives here.") == null);
    try testing.expect(std.mem.indexOf(u8, prompt, "selected=no") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Core specialists (lane-default routing):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "faber -> lane=backend") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Helper specialists (explicit invocation only):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "praeco -> lane=media") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Valid fallback lane values: backend, frontend, systems, qa, research, brand, docs") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Helper specialists are explicit-only.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Active ask:") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Session seed (initial prompt):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Selected evidence excerpts") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Assigned specialist tasks") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "none assigned") != null);
}

test "buildDecanusUserPrompt foregrounds the latest operator turn ahead of background evidence" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.mission.initial_prompt = "what does this project do?";
    state.mission.current_goal = "what gaps do you see?";
    state.agent_loop.history = &.{
        .{
            .iteration = 2,
            .type = "operator_reply",
            .actor = "operator",
            .lane = "",
            .summary = "what gaps do you see?",
            .artifacts = &.{},
            .timestamp = "2",
        },
    };

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

    const active_ask_index = std.mem.indexOf(u8, prompt, "Active ask:\nwhat gaps do you see?") orelse return error.TestUnexpectedResult;
    const architecture_index = std.mem.indexOf(u8, prompt, "- architecture: path=.contubernium/ARCHITECTURE.md") orelse return error.TestUnexpectedResult;
    try testing.expect(active_ask_index < architecture_index);
    try testing.expect(std.mem.indexOf(u8, prompt, "Latest operator reply:\nwhat gaps do you see?") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Session seed (initial prompt):\nwhat does this project do?") != null);
}

test "buildSpecialistUserPrompt surfaces the subordinate tool loop contract" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.mission.initial_prompt = "ship phase 2";
    state.mission.current_goal = "formalize specialist subordinate execution";
    state.agent_loop.last_tool_result = "read_file src/runtime_loop.zig";
    state.tasks.backend.invocation = .{
        .status = .running,
        .requested_by = .decanus,
        .target = .faber,
        .lane = .backend,
        .agent_call = "faber::IMPLEMENT_BACKEND",
        .action_name = "IMPLEMENT_BACKEND",
        .iteration = 3,
        .objective = "make specialist tool execution explicit",
        .completion_signal = "return a structured result to decanus",
        .context = .{
            .project = "Contubernium",
            .files = &.{"src/runtime_loop.zig"},
            .constraints = &.{"preserve commander-first control"},
            .dependencies = &.{"src/runtime_core.zig"},
        },
        .scope = .{
            .allowed_actions = &.{ "execute_assigned_scope", "request_runtime_tools", "return_structured_result" },
            .restricted_actions = &.{ "chain_other_specialists", "expand_scope", "finalize_mission" },
        },
        .memory = .{
            .mission = "formalize specialist subordinate execution",
            .project = "read_file src/runtime_loop.zig",
            .relevant = &.{"docs/invocation-protocol.md"},
        },
        .tool_loop = .{
            .status = .result_available,
            .cycle_count = 1,
            .last_request_summary = "requested 1 runtime tool\n- read_file src/runtime_core.zig",
            .last_result_summary = "read_file src/runtime_core.zig",
        },
        .return_to = .decanus,
    };

    const prompt = try buildSpecialistUserPrompt(allocator, AppConfig{}, &state, .{
        .architecture = .{
            .kind = "architecture",
            .path = ".contubernium/ARCHITECTURE.md",
            .content = "Architecture note.",
            .source_chars = 18,
        },
        .plan = .{
            .kind = "plan",
            .path = ".contubernium/PLAN.md",
            .content = "Plan note.",
            .source_chars = 10,
        },
        .project_context = .{
            .kind = "project_context",
            .path = ".contubernium/PROJECT_CONTEXT.md",
            .content = "Context note.",
            .source_chars = 12,
        },
        .project = .{
            .kind = "project",
            .path = ".contubernium/project.md",
            .content = "Project note.",
            .source_chars = 12,
        },
        .global = .{
            .kind = "global",
            .path = ".contubernium/global.md",
            .content = "Global note.",
            .source_chars = 11,
        },
    }, "backend");

    try testing.expect(std.mem.indexOf(u8, prompt, "Project Evidence") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Memory ledger") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Architecture note.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Plan note.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Context note.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Project note.") == null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Global note.") == null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Subordinate tool loop") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Status: result_available") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Completed cycles: 1") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Last request summary: requested 1 runtime tool") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Last result summary: read_file src/runtime_core.zig") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Return to: decanus") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Scope.restricted_actions: chain_other_specialists, expand_scope, finalize_mission") != null);
}

test "buildDecanusUserPrompt keeps prompt weight on selected evidence only" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.mission.initial_prompt = "summarize the project";
    state.mission.current_goal = "reduce prompt weight";

    const architecture_text =
        "ARCHITECTURE:\nThis architecture excerpt should stay visible because decanus needs structural evidence.";
    const plan_text =
        "PLAN:\nThis plan excerpt should stay out of the selected evidence block for the default decanus profile.";
    const project_context_text =
        "PROJECT_CONTEXT:\nThis project context excerpt should stay visible because it defines the active mission frame.";
    const project_text =
        "PROJECT:\nThis project memory excerpt should stay visible because it holds durable project knowledge.";
    const global_text =
        "GLOBAL:\nThis global memory excerpt should stay visible because it carries constitutional operating guidance.";

    const prompt = try buildDecanusUserPrompt(allocator, AppConfig{}, &state, .{
        .architecture = .{
            .kind = "architecture",
            .path = ".contubernium/ARCHITECTURE.md",
            .content = architecture_text,
            .source_chars = architecture_text.len,
        },
        .plan = .{
            .kind = "plan",
            .path = ".contubernium/PLAN.md",
            .content = plan_text,
            .source_chars = plan_text.len,
        },
        .project_context = .{
            .kind = "project_context",
            .path = ".contubernium/PROJECT_CONTEXT.md",
            .content = project_context_text,
            .source_chars = project_context_text.len,
        },
        .project = .{
            .kind = "project",
            .path = ".contubernium/project.md",
            .content = project_text,
            .source_chars = project_text.len,
        },
        .global = .{
            .kind = "global",
            .path = ".contubernium/global.md",
            .content = global_text,
            .source_chars = global_text.len,
        },
    });

    try testing.expect(std.mem.indexOf(u8, prompt, project_context_text) != null);
    try testing.expect(std.mem.indexOf(u8, prompt, project_text) != null);
    try testing.expect(std.mem.indexOf(u8, prompt, architecture_text) != null);
    try testing.expect(std.mem.indexOf(u8, prompt, global_text) != null);
    try testing.expect(std.mem.indexOf(u8, prompt, plan_text) == null);
    try testing.expect(std.mem.indexOf(u8, prompt, "- plan: path=.contubernium/PLAN.md") != null);
}

test "buildDecanusUserPrompt keeps greeting-only mission intake in follow-up mode" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.mission.initial_prompt = "hello";
    state.mission.current_goal = "open the mission conversation";
    state.agent_loop.history = &.{
        .{
            .iteration = 1,
            .type = "operator_reply",
            .actor = "operator",
            .lane = "",
            .summary = "you decide what to inspect",
            .artifacts = &.{},
            .timestamp = "1",
        },
    };

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

    try testing.expect(std.mem.indexOf(u8, prompt, "Latest operator reply:") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "you decide what to inspect") != null);
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
        buildPromptWithContextBudget(allocator, config, &state, .{}, "system prompt", .decanus, "", null),
    );
    try testing.expectEqualStrings("MEMORY_LAYER_MISSING", state.runtime_session.last_failure.code);
    try testing.expectEqualStrings("global.md", state.runtime_session.last_failure.context.target);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("memory_load_blocked", state.agent_loop.history[0].type);
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
