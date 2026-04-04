const std = @import("std");
const cli = @import("cli.zig");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const ui_mod = @import("runtime_ui.zig");
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
const RuntimePermissionClass = core.RuntimePermissionClass;
const ToolApprovalGate = core.ToolApprovalGate;
const ToolConfirmationMode = core.ToolConfirmationMode;
const RuntimeToolTimeoutBehavior = core.RuntimeToolTimeoutBehavior;
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
const SessionIndex = core.SessionIndex;
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
const providerUsesOpenAICompatibleTransport = core.providerUsesOpenAICompatibleTransport;
const initialModelRouteForActor = core.initialModelRouteForActor;
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
const resumeAfterOperatorReply = core.resumeAfterOperatorReply;
const appendHistory = core.appendHistory;
const taskForLane = core.taskForLane;
const taskForLaneConst = core.taskForLaneConst;
const laneForActor = core.laneForActor;
const coreRoster = core.coreRoster;
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
const parseJson = model_json.parseJson;
const parseModelJson = model_json.parseModelJson;
const prettyPrintJson = model_json.prettyPrintJson;
const CliSpinner = ui_mod.CliSpinner;
const CliSpinnerState = ui_mod.CliSpinnerState;
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
const loadSessionIndex = assets_mod.loadSessionIndex;
const loadSessionRecord = assets_mod.loadSessionRecord;
const loadGlobalSessionIndex = assets_mod.loadGlobalSessionIndex;
const loadRuntimeRunLog = assets_mod.loadRuntimeRunLog;
const saveRuntimeRunLog = assets_mod.saveRuntimeRunLog;
const normalizeGlobalMemoryMarkdown = assets_mod.normalizeGlobalMemoryMarkdown;
const stripGlobalMemoryVersionHeader = assets_mod.stripGlobalMemoryVersionHeader;
const persistSessionMemory = assets_mod.persistSessionMemory;
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
const makeSessionId = assets_mod.makeSessionId;
const logPathForRun = assets_mod.logPathForRun;
const sessionRecordPath = assets_mod.sessionRecordPath;
const resolveGlobalSessionIndexPath = assets_mod.resolveGlobalSessionIndexPath;
const initializeRuntimeRunLog = assets_mod.initializeRuntimeRunLog;
const appendRuntimeRunLogEvent = assets_mod.appendRuntimeRunLogEvent;
const logRuntimeEventWithUi = assets_mod.logRuntimeEventWithUi;

extern fn setenv(name: [*:0]const u8, value: [*:0]const u8, overwrite: c_int) c_int;
extern fn unsetenv(name: [*:0]const u8) c_int;
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
const runtimeToolContracts = tools_mod.runtimeToolContracts;
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
const resolvedDecanusControlAction = loop_mod.resolvedDecanusControlAction;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    runMain(allocator, args) catch |err| {
        const message = friendlyRuntimeError(allocator, err) catch {
            try stderrPrint("{s}\n", .{@errorName(err)});
            std.process.exit(1);
        };
        defer allocator.free(message);
        try stderrPrint("{s}\n", .{message});
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
        .action => |invocation| {
            var arena = std.heap.ArenaAllocator.init(allocator);
            defer arena.deinit();
            const scratch = arena.allocator();

            switch (invocation.action) {
                .init => try cmdInit(scratch),
                .doctor => try cmdDoctor(scratch),
                .models_list => try cmdModelsList(scratch),
                .mission_compose => try ui_mod.cmdMissionCompose(scratch),
                .mission_start => try ui_mod.cmdMissionStart(scratch, invocation.args),
                .mission_continue => try ui_mod.cmdMissionContinue(scratch),
                .mission_step => try ui_mod.cmdMissionStep(scratch),
                .sessions_list => try ui_mod.cmdSessionsList(scratch, invocation.args),
                .sessions_show => try ui_mod.cmdSessionsShow(scratch, invocation.args),
                .sessions_resume => try ui_mod.cmdSessionsResume(scratch, invocation.args),
                .sessions_approvals => {
                    const enabled = invocation.args.len > 0 and (eql(trimAscii(invocation.args[0]), "on") or eql(trimAscii(invocation.args[0]), "true"));
                    if (!enabled and invocation.args.len > 0 and !eql(trimAscii(invocation.args[0]), "off") and !eql(trimAscii(invocation.args[0]), "false")) {
                        return error.InvalidArguments;
                    }
                    try ui_mod.cmdSessionsApprovals(scratch, enabled);
                },
                .ui => try ui_mod.cmdUi(scratch),
                .ui_bridge => try ui_mod.cmdUiBridge(scratch),
            }
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

const MockLlamaCppServer = struct {
    child: std.process.Child,

    fn deinit(self: *MockLlamaCppServer) void {
        _ = self.child.kill() catch {};
        _ = self.child.wait() catch {};
    }
};

fn startMockLlamaCppServer(allocator: std.mem.Allocator, port: u16) !MockLlamaCppServer {
    const script = try std.fmt.allocPrint(
        allocator,
        \\import json
        \\from http.server import BaseHTTPRequestHandler, HTTPServer
        \\
        \\class Handler(BaseHTTPRequestHandler):
        \\    def do_GET(self):
        \\        if self.path != "/v1/models":
        \\            self.send_error(404)
        \\            return
        \\        payload = json.dumps({{
        \\            "data": [
        \\                {{"id": "gemma-4-4b-it"}},
        \\                {{"id": "gemma-4-12b-it"}}
        \\            ]
        \\        }}).encode()
        \\        self.send_response(200)
        \\        self.send_header("Content-Type", "application/json")
        \\        self.send_header("Content-Length", str(len(payload)))
        \\        self.end_headers()
        \\        self.wfile.write(payload)
        \\
        \\    def do_POST(self):
        \\        if self.path != "/v1/chat/completions":
        \\            self.send_error(404)
        \\            return
        \\        length = int(self.headers.get("Content-Length", "0"))
        \\        self.rfile.read(length)
        \\        payload = json.dumps({{
        \\            "choices": [
        \\                {{
        \\                    "message": {{
        \\                        "content": "{{\\"status\\":\\"ok\\"}}"
        \\                    }}
        \\                }}
        \\            ]
        \\        }}).encode()
        \\        self.send_response(200)
        \\        self.send_header("Content-Type", "application/json")
        \\        self.send_header("Content-Length", str(len(payload)))
        \\        self.end_headers()
        \\        self.wfile.write(payload)
        \\
        \\    def log_message(self, format, *args):
        \\        pass
        \\
        \\class Server(HTTPServer):
        \\    allow_reuse_address = True
        \\
        \\Server(("127.0.0.1", {d}), Handler).serve_forever()
    ,
        .{port},
    );
    defer allocator.free(script);

    var child = std.process.Child.init(&.{ "python3", "-c", script }, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    child.spawn() catch |err| switch (err) {
        error.FileNotFound => return error.SkipZigTest,
        else => return err,
    };

    std.Thread.sleep(250 * std.time.ns_per_ms);
    return .{ .child = child };
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

test "resolvedDecanusControlAction infers supported control actions from payload" {
    const testing = std.testing;

    const tool_action = resolvedDecanusControlAction(.{
        .action = "evaluate_loop",
        .tool_requests = &.{.{ .tool = "read_file", .path = "src/main.zig" }},
    });
    try testing.expectEqualStrings("tool_request", tool_action);

    const finish_action = resolvedDecanusControlAction(.{
        .action = "finish_mission",
        .final_response = "done",
    });
    try testing.expectEqualStrings("finish", finish_action);

    const invalid_action = resolvedDecanusControlAction(.{
        .action = "evaluate_loop",
    });
    try testing.expectEqualStrings("", invalid_action);
}

test "assembleSystemPrompt distinguishes decanus action files from JSON action values" {
    const testing = std.testing;
    const layout = try resolveGlobalAssetLayout(testing.allocator);
    defer deinitGlobalAssetLayout(testing.allocator, layout);

    var state = AppState{};
    const prompt = try assembleSystemPrompt(testing.allocator, layout, &state, .decanus);
    defer testing.allocator.free(prompt);

    try testing.expect(std.mem.indexOf(u8, prompt, "The JSON `action` field must be one of: `finish`, `invoke_specialist`, `tool_request`, `ask_user`, or `blocked`.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Do not use action file names such as `EVALUATE_LOOP`, `INVOKE_SPECIALIST`, or `FINISH_MISSION`") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Mission handling rules") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Treat the latest non-empty operator reply as the active ask by default.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "If the prompt is only a greeting, presence check, or other conversational opener") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "prefer markdown-lite operator output") != null);
}

test "taskSummaryText hides unassigned default lanes" {
    const testing = std.testing;

    const summary = try taskSummaryText(testing.allocator, Tasks{});
    try testing.expectEqualStrings("none assigned", summary);
}

test "taskSummaryText shows explicit lane status once work is assigned" {
    const testing = std.testing;
    var tasks = Tasks{};
    tasks.backend.status = .in_progress;
    tasks.backend.description = "implement runtime repair";

    const summary = try taskSummaryText(testing.allocator, tasks);
    defer testing.allocator.free(summary);

    try testing.expect(std.mem.indexOf(u8, summary, "core: backend=in_progress") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "frontend=pending") != null);
    try testing.expect(std.mem.indexOf(u8, summary, "helpers: none assigned") != null);
}

test "agent topology keeps constitutional core and helper counts" {
    const testing = std.testing;

    try testing.expectEqual(core.constitutional_core_agent_count, coreRoster().len);
    try testing.expect(helperRoster().len >= core.minimum_helper_agent_count);
    try testing.expectEqual(Actor.decanus, coreRoster()[0]);
    try testing.expectEqual(Actor.calo, coreRoster()[coreRoster().len - 1]);
    try testing.expectEqual(Actor.praeco, helperRoster()[0]);
    try testing.expectEqual(Actor.mulus, helperRoster()[1]);
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
    try testing.expect(std.mem.indexOf(u8, streaming_body, "\"think\":true") != null);
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
    try testing.expect(std.mem.indexOf(u8, summary, "Need to inspect the workspace before reading docs.") == null);
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

test "processOllamaPendingLines emits bounded thinking chunks separately from content" {
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

    try pending.appendSlice(testing.allocator, "{\"message\":{\"thinking\":\"Need to inspect docs. \",\"content\":\"{\\\"action\\\":\"},\"done\":false}\n");
    try processOllamaPendingLines(testing.allocator, &pending, &full_text, "decanus", hooks);

    try testing.expectEqualStrings("{\"action\":", full_text.items);

    const events = try queue.drain(testing.allocator);
    defer freeRuntimeUiEvents(testing.allocator, events);
    try testing.expectEqual(@as(usize, 2), events.len);
    try testing.expectEqual(RuntimeUiEventKind.thinking_chunk, events[0].kind);
    try testing.expectEqualStrings("Need to inspect docs. ", events[0].text);
    try testing.expectEqual(RuntimeUiEventKind.stream_chunk, events[1].kind);
    try testing.expectEqualStrings("{\"action\":", events[1].text);
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

test "resolveSpecialistInvocationFromDecision requires explicit helper targeting" {
    const testing = std.testing;
    const allocator = testing.allocator;
    const layout = try resolveGlobalAssetLayout(allocator);
    defer deinitGlobalAssetLayout(allocator, layout);

    try testing.expectError(
        error.HelperLaneRequiresExplicitAgent,
        resolveSpecialistInvocationFromDecision(allocator, layout, .{
            .action = "invoke_specialist",
            .lane = "media",
        }),
    );

    const resolved = try resolveSpecialistInvocationFromDecision(allocator, layout, .{
        .action = "invoke_specialist",
        .agent_call = "praeco",
    });
    try testing.expectEqual(Actor.praeco, resolved.actor);
    try testing.expectEqual(Lane.media, resolved.lane);
    try testing.expectEqualStrings("praeco", resolved.agent_call);
    try testing.expectEqualStrings("WRITE_MESSAGE", resolved.action_name);
}

test "providerUsesOpenAICompatibleTransport recognizes llama.cpp" {
    const testing = std.testing;
    try testing.expect(providerUsesOpenAICompatibleTransport(.{
        .type = "llama.cpp",
        .base_url = "http://127.0.0.1:8080",
        .model = "gemma-4-4b-it",
    }));
}

test "initialModelRouteForActor resolves the smallest capable registry model per actor" {
    const testing = std.testing;

    const registry = [_]core.ModelRegistryEntry{
        .{
            .id = "gemma-4-4b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = "http://127.0.0.1:8080",
                .model = "gemma-4-4b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration" },
            .size_score = 4,
            .context_window_tokens = 32768,
        },
        .{
            .id = "gemma-4-12b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = "http://127.0.0.1:8080",
                .model = "gemma-4-12b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration", "coding" },
            .size_score = 12,
            .context_window_tokens = 65536,
        },
    };

    const config = AppConfig{
        .model_policy = .{
            .enabled = true,
            .strategy = "smallest-capable",
            .primary = registry[0].provider,
            .registry = registry[0..],
        },
    };

    var state = AppState{};
    const decanus_route = initialModelRouteForActor(config, &state, .decanus);
    try testing.expectEqualStrings("llama.cpp", decanus_route.provider.type);
    try testing.expectEqualStrings("gemma-4-4b-it", decanus_route.provider.model);

    const faber_route = initialModelRouteForActor(config, &state, .faber);
    try testing.expectEqualStrings("llama.cpp", faber_route.provider.type);
    try testing.expectEqualStrings("gemma-4-12b-it", faber_route.provider.model);
}

test "fallbackRouteForActor selects an alternate registry model when explicit fallback is absent" {
    const testing = std.testing;

    const registry = [_]core.ModelRegistryEntry{
        .{
            .id = "gemma-4-4b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = "http://127.0.0.1:8080",
                .model = "gemma-4-4b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration" },
            .size_score = 4,
            .context_window_tokens = 32768,
        },
        .{
            .id = "gemma-4-12b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = "http://127.0.0.1:8080",
                .model = "gemma-4-12b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration" },
            .size_score = 12,
            .context_window_tokens = 65536,
        },
    };

    const config = AppConfig{
        .model_policy = .{
            .enabled = true,
            .strategy = "smallest-capable",
            .primary = registry[0].provider,
            .registry = registry[0..],
        },
    };

    const route = fallbackRouteForActor(
        config,
        .decanus,
        .{},
        registry[0].provider,
        "provider_transport_failed",
    ) orelse return error.TestUnexpectedResult;

    try testing.expectEqualStrings("fallback", route.role);
    try testing.expectEqualStrings("gemma-4-12b-it", route.provider.model);
}

test "structuredChatWithRepair resolves llama.cpp registry route for smoke response" {
    const testing = std.testing;
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const port = @as(u16, 18000 + @as(u16, @intCast(@mod(std.time.milliTimestamp(), 1000))));
    var server = try startMockLlamaCppServer(scratch, port);
    defer server.deinit();

    const base_url = try std.fmt.allocPrint(scratch, "http://127.0.0.1:{d}", .{port});
    const registry = [_]core.ModelRegistryEntry{
        .{
            .id = "gemma-4-4b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = base_url,
                .model = "gemma-4-4b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration" },
            .size_score = 4,
            .context_window_tokens = 32768,
        },
        .{
            .id = "gemma-4-12b-it",
            .provider = .{
                .type = "llama.cpp",
                .base_url = base_url,
                .model = "gemma-4-12b-it",
            },
            .capabilities = &.{ "structured-output", "analysis", "tool-use", "orchestration", "coding" },
            .size_score = 12,
            .context_window_tokens = 65536,
        },
    };

    const config = AppConfig{
        .model_policy = .{
            .enabled = true,
            .strategy = "smallest-capable",
            .primary = registry[0].provider,
            .registry = registry[0..],
        },
    };

    const models = try providerListModels(scratch, registry[0].provider);
    try testing.expect(containsString(models, "gemma-4-4b-it"));
    try testing.expect(containsString(models, "gemma-4-12b-it"));

    var state = AppState{};
    const response = try structuredChatWithRepair(
        scratch,
        config,
        "Return valid JSON only.",
        "Return exactly {\"status\":\"ok\"}.",
        "faber",
        1,
        SmokeResponse,
        &state,
        .{},
    );

    try testing.expectEqualStrings("ok", response.value.status);
    try testing.expectEqualStrings("llama.cpp", state.runtime_session.provider);
    try testing.expectEqualStrings("gemma-4-12b-it", state.runtime_session.model);
    try testing.expectEqualStrings("primary", state.runtime_session.last_model_role);
}

test "provider transport paths release owned buffers under a scoped allocator" {
    const testing = std.testing;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const status = gpa.deinit();
        testing.expect(status == .ok) catch @panic("gpa leaked");
    }
    const allocator = gpa.allocator();

    const port = @as(u16, 19000 + @as(u16, @intCast(@mod(std.time.milliTimestamp(), 1000))));
    var server = try startMockLlamaCppServer(allocator, port);
    defer server.deinit();

    const base_url = try std.fmt.allocPrint(allocator, "http://127.0.0.1:{d}", .{port});
    defer allocator.free(base_url);

    const provider = core.ProviderConfig{
        .type = "llama.cpp",
        .base_url = base_url,
        .model = "gemma-4-12b-it",
    };

    const models = try providerListModels(allocator, provider);
    defer freeOwnedStringSlice(allocator, models);
    try testing.expect(containsString(models, "gemma-4-4b-it"));
    try testing.expect(containsString(models, "gemma-4-12b-it"));

    const response = try providerStructuredChat(
        allocator,
        provider,
        "Return valid JSON only.",
        "Return exactly {\"status\":\"ok\"}.",
        "faber",
        .{},
    );
    defer response.deinit(allocator);

    try testing.expectEqualStrings("{\"status\":\"ok\"}", response.raw_text);
    try testing.expect(std.mem.indexOf(u8, response.transport_text, "\"choices\"") != null);
}
