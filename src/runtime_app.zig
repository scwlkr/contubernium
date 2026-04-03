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
const logRuntimeEvent = assets_mod.logRuntimeEvent;

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
            .mission_compose => try ui_mod.cmdMissionCompose(allocator),
            .mission_start => try ui_mod.cmdMissionStart(allocator, invocation.args),
            .mission_continue => try ui_mod.cmdMissionContinue(allocator),
            .mission_step => try ui_mod.cmdMissionStep(allocator),
            .sessions_list => try ui_mod.cmdSessionsList(allocator, invocation.args),
            .sessions_show => try ui_mod.cmdSessionsShow(allocator, invocation.args),
            .sessions_resume => try ui_mod.cmdSessionsResume(allocator, invocation.args),
            .sessions_approvals => {
                const enabled = invocation.args.len > 0 and (eql(trimAscii(invocation.args[0]), "on") or eql(trimAscii(invocation.args[0]), "true"));
                if (!enabled and invocation.args.len > 0 and !eql(trimAscii(invocation.args[0]), "off") and !eql(trimAscii(invocation.args[0]), "false")) {
                    return error.InvalidArguments;
                }
                try ui_mod.cmdSessionsApprovals(allocator, enabled);
            },
            .ui => try ui_mod.cmdUi(allocator),
            .ui_bridge => try ui_mod.cmdUiBridge(allocator),
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
    try testing.expectEqualStrings("TOOL_POLICY_BLOCKED", state.runtime_session.last_failure.code);
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
    try testing.expectEqualStrings("MISSING_PATH", state.runtime_session.last_failure.code);
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
    try testing.expectEqualStrings("TOOL_DENIED", state.runtime_session.last_failure.code);
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

test "resetStateForMission resets canonical phase 3 state surfaces" {
    const testing = std.testing;
    var state = AppState{};
    state.current_actor = .artifex;
    state.global_status = .waiting_on_tool;
    state.mission.current_goal = "stale follow-up";
    state.mission.final_response = "stale response";
    state.agent_loop.iteration = 9;
    state.agent_loop.last_tool_result = "stale";
    state.agent_loop.history = &.{
        .{
            .iteration = 7,
            .type = "operator_reply",
            .actor = "operator",
            .lane = "",
            .summary = "stale reply",
            .artifacts = &.{},
            .timestamp = "7",
        },
    };
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
    try testing.expectEqual(@as(usize, 0), state.agent_loop.history.len);
    try testing.expectEqual(@as(usize, 0), state.agent_loop.intermediate_results.len);
    try testing.expectEqual(RuntimeStatus.idle, state.runtime_session.status);
    try testing.expectEqual(TaskStatus.pending, state.tasks.backend.status);
}

test "approval transitions update canonical state ownership" {
    const testing = std.testing;
    var state = AppState{};

    beginApprovalRequest(&state, .decanus, .command, .shell, "run_command", "zig build test", "zig build test", "zig build test");
    try testing.expectEqual(RuntimeStatus.awaiting_approval, state.runtime_session.status);
    try testing.expectEqual(ApprovalStatus.pending, state.runtime_session.active_approval.status);
    try testing.expectEqual(ApprovalKind.shell, state.runtime_session.active_approval.kind);
    try testing.expectEqual(LoopStepKind.wait_for_approval, state.agent_loop.last_step.kind);

    resolveApprovalRequest(&state, true);
    try testing.expectEqual(ApprovalStatus.approved, state.runtime_session.active_approval.status);
    try testing.expectEqual(RuntimeStatus.running, state.runtime_session.status);
}

test "runtime tool contracts publish permission class schemas and timeout behavior" {
    const testing = std.testing;
    const contracts = runtimeToolContracts();

    try testing.expectEqual(@as(usize, 6), contracts.len);

    const run_command = runtimeToolSpec("run_command").?;
    try testing.expectEqual(RuntimePermissionClass.execute, run_command.permission_class);
    try testing.expectEqual(ApprovalKind.shell, run_command.approval_kind);
    try testing.expectEqual(ToolConfirmationMode.policy_guarded, run_command.confirmation_mode);
    try testing.expectEqual(RuntimeToolTimeoutBehavior.policy_default, run_command.timeout_behavior);
    try testing.expect(run_command.input_schema.len > 0);
    try testing.expect(run_command.output_schema.len > 0);

    const ask_user = runtimeToolSpec("ask_user").?;
    try testing.expectEqual(RuntimePermissionClass.execute, ask_user.permission_class);
    try testing.expectEqual(ToolConfirmationMode.none, ask_user.confirmation_mode);
    try testing.expectEqual(RuntimeToolTimeoutBehavior.none, ask_user.timeout_behavior);
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

test "resumeAfterOperatorReply clears the blocked state and records operator history" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.current_actor = .faber;
    state.global_status = .waiting_on_tool;
    state.agent_loop.status = .blocked;
    state.agent_loop.active_tool = .faber;
    state.agent_loop.iteration = 2;
    state.runtime_session.status = .blocked;
    state.runtime_session.last_error = "Need clarification";
    state.runtime_session.last_failure = .{
        .code = "USER_INPUT_REQUIRED",
        .cause = "Need clarification",
    };

    try resumeAfterOperatorReply(allocator, &state, "keep this conversational");

    try testing.expectEqual(Actor.decanus, state.current_actor);
    try testing.expectEqual(GlobalStatus.planning, state.global_status);
    try testing.expectEqual(LoopStatus.thinking, state.agent_loop.status);
    try testing.expectEqual(RuntimeStatus.ready, state.runtime_session.status);
    try testing.expect(state.agent_loop.active_tool == null);
    try testing.expectEqualStrings("", state.runtime_session.last_error);
    try testing.expectEqualStrings("", state.runtime_session.last_failure.code);
    try testing.expectEqualStrings("keep this conversational", state.mission.current_goal);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("operator_reply", state.agent_loop.history[0].type);
    try testing.expectEqualStrings("operator", state.agent_loop.history[0].actor);
    try testing.expectEqualStrings("backend", state.agent_loop.history[0].lane);
    try testing.expectEqualStrings("keep this conversational", state.agent_loop.history[0].summary);
}

test "resumeAfterOperatorReply clears stale completion state" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.current_actor = .decanus;
    state.global_status = .complete;
    state.agent_loop.status = .complete;
    state.runtime_session.status = .complete;
    state.mission.final_response = "previous answer";

    try resumeAfterOperatorReply(allocator, &state, "what else does it do?");

    try testing.expectEqual(GlobalStatus.planning, state.global_status);
    try testing.expectEqual(LoopStatus.thinking, state.agent_loop.status);
    try testing.expectEqual(RuntimeStatus.ready, state.runtime_session.status);
    try testing.expectEqualStrings("what else does it do?", state.mission.current_goal);
    try testing.expectEqualStrings("", state.mission.final_response);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("operator_reply", state.agent_loop.history[0].type);
    try testing.expectEqualStrings("what else does it do?", state.agent_loop.history[0].summary);
}

test "resumeAfterOperatorReply clears stale intermediate summaries for the next ask" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.global_status = .complete;
    state.mission.final_response = "previous answer";
    state.agent_loop.intermediate_results = try allocator.dupe(core.IntermediateResult, &.{
        .{
            .iteration = 2,
            .actor = .decanus,
            .lane = .command,
            .kind = "decision_summary",
            .summary = "action: tool_request",
        },
        .{
            .iteration = 2,
            .actor = .faber,
            .lane = .backend,
            .kind = "specialist_summary",
            .summary = "action: complete",
        },
    });

    try resumeAfterOperatorReply(allocator, &state, "what should happen next?");

    try testing.expectEqual(@as(usize, 0), state.agent_loop.intermediate_results.len);
    try testing.expectEqualStrings("what should happen next?", state.mission.current_goal);
}

test "resumeAfterOperatorReply ignores empty replies" {
    const testing = std.testing;
    const allocator = std.heap.page_allocator;
    var state = AppState{};
    state.global_status = .complete;
    state.mission.initial_prompt = "what does this project do?";
    state.mission.current_goal = "what gaps do you see?";
    state.mission.final_response = "previous answer";
    state.runtime_session.status = .complete;
    state.agent_loop.status = .complete;

    try resumeAfterOperatorReply(allocator, &state, "   \n\t ");

    try testing.expectEqual(GlobalStatus.complete, state.global_status);
    try testing.expectEqual(LoopStatus.complete, state.agent_loop.status);
    try testing.expectEqual(RuntimeStatus.complete, state.runtime_session.status);
    try testing.expectEqualStrings("what gaps do you see?", state.mission.current_goal);
    try testing.expectEqualStrings("previous answer", state.mission.final_response);
    try testing.expectEqual(@as(usize, 0), state.agent_loop.history.len);
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
    try testing.expect(std.mem.indexOf(u8, prompt, "Core specialists (lane-default routing):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "faber -> lane=backend") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Helper specialists (explicit invocation only):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "praeco -> lane=media") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Valid fallback lane values: backend, frontend, systems, qa, research, brand, docs") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Helper specialists are explicit-only.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Active ask:") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Session seed (initial prompt):") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Mission handling rules") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Background evidence") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Treat the latest non-empty operator reply as the active ask by default.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "If the prompt is only a greeting, presence check, or other conversational opener") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "If the operator asks what the project does, what problem it solves, or requests a plain-language summary") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "If the operator explicitly asks to brainstorm, ideate, or explore what could take the project further") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "technical, philosophical, product, UX, operational, advertising, distribution, or messaging gaps") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Do not bounce open-ended creative exploration back to the operator just because the scope is broad.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "prefer markdown-lite operator output") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Use fenced code blocks for commands, snippets, or exact terminal text when verbatim formatting helps.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Keep trivial one-line replies short.") != null);
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
    const architecture_index = std.mem.indexOf(u8, prompt, "Architecture file: .contubernium/ARCHITECTURE.md") orelse return error.TestUnexpectedResult;
    try testing.expect(active_ask_index < architecture_index);
    try testing.expect(std.mem.indexOf(u8, prompt, "Latest operator reply:\nwhat gaps do you see?") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Session seed (initial prompt):\nwhat does this project do?") != null);
}

test "searchText includes hidden project context while pruning runtime noise" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    try tmp.dir.makePath(".contubernium/logs");

    var project_context = try tmp.dir.createFile(".contubernium/PROJECT_CONTEXT.md", .{ .truncate = true });
    defer project_context.close();
    try project_context.writeAll("Business domain: commander-first execution system.\n");

    var noisy_log = try tmp.dir.createFile(".contubernium/logs/run.log", .{ .truncate = true });
    defer noisy_log.close();
    try noisy_log.writeAll("Business domain: log noise.\n");

    const output = try searchText(testing.allocator, "Business domain", ".", 20, 5000);
    defer testing.allocator.free(output);

    try testing.expect(std.mem.indexOf(u8, output, ".contubernium/PROJECT_CONTEXT.md") != null);
    try testing.expect(std.mem.indexOf(u8, output, ".contubernium/logs/run.log") == null);
}

test "searchText truncates root-search hits to the configured limit" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    var first = try tmp.dir.createFile("first.md", .{ .truncate = true });
    defer first.close();
    try first.writeAll("goal one\n");

    var second = try tmp.dir.createFile("second.md", .{ .truncate = true });
    defer second.close();
    try second.writeAll("goal two\n");

    var third = try tmp.dir.createFile("third.md", .{ .truncate = true });
    defer third.close();
    try third.writeAll("goal three\n");

    const output = try searchText(testing.allocator, "goal", ".", 2, 5000);
    defer testing.allocator.free(output);

    try testing.expect(std.mem.indexOf(u8, output, "first.md") != null or std.mem.indexOf(u8, output, "second.md") != null or std.mem.indexOf(u8, output, "third.md") != null);
    try testing.expect(std.mem.indexOf(u8, output, "...[truncated]...") != null);
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

    try testing.expect(std.mem.indexOf(u8, prompt, "return `action: \"ask_user\"`") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "keep the mission alive by leaving `final_response` empty") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "`Hello! What can I help with?`") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Latest operator reply:") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "you decide what to inspect") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Treat the initial prompt as session origin and durable provenance") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Treat the latest non-empty operator reply as the active ask by default.") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "If the operator asks for a read-only exploratory assessment or explicitly says to choose the scope yourself") != null);
    try testing.expect(std.mem.indexOf(u8, prompt, "Exploratory answers still keep commander-first control") != null);
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
    try testing.expectEqualStrings("MEMORY_LAYER_MISSING", state.runtime_session.last_failure.code);
    try testing.expectEqualStrings("global.md", state.runtime_session.last_failure.context.target);
    try testing.expectEqual(@as(usize, 1), state.agent_loop.history.len);
    try testing.expectEqualStrings("memory_load_blocked", state.agent_loop.history[0].type);
}

test "scaffoldProject creates canonical runtime and context assets" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

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
    try testing.expect(pathExists(".contubernium/sessions/index.json"));
    try testing.expect(!pathExists(".contubernium/prompts"));
    try testing.expect(!pathExists(".agents"));

    const global_memory = try std.fs.cwd().readFileAlloc(scratch, ".contubernium/global.md", max_file_bytes);
    try testing.expect(std.mem.indexOf(u8, global_memory, "format_version=1") != null);

    const session_index = try loadSessionIndex(scratch, ".contubernium/sessions/index.json");
    try testing.expectEqual(@as(usize, session_index_format_version), session_index.format_version);
}

test "init.sh fallback scaffold creates session index and versioned global memory" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const repo_root = try std.fs.cwd().realpathAlloc(scratch, ".");
    const tmp_root = try tmp.dir.realpathAlloc(scratch, ".");
    const script_path = try std.fs.path.join(scratch, &.{ repo_root, "init.sh" });
    const project_path = try std.fs.path.join(scratch, &.{ tmp_root, "project" });
    const fake_home = try std.fs.path.join(scratch, &.{ tmp_root, "missing-home" });

    var env_map = try std.process.getEnvMap(scratch);
    try env_map.put("CONTUBERNIUM_HOME", fake_home);

    const result = try std.process.Child.run(.{
        .allocator = scratch,
        .argv = &.{ "bash", script_path, project_path },
        .cwd = repo_root,
        .env_map = &env_map,
    });
    try testing.expectEqual(@as(i32, 0), exitCode(result.term));

    const session_index_path = try std.fs.path.join(scratch, &.{ project_path, ".contubernium", "sessions", "index.json" });
    const global_memory_path = try std.fs.path.join(scratch, &.{ project_path, ".contubernium", "global.md" });

    try testing.expect(pathExists(session_index_path));
    try testing.expect(pathExists(global_memory_path));

    const session_index = try loadSessionIndex(scratch, session_index_path);
    try testing.expectEqual(@as(usize, session_index_format_version), session_index.format_version);

    const global_memory = try std.fs.cwd().readFileAlloc(scratch, global_memory_path, max_file_bytes);
    try testing.expect(std.mem.indexOf(u8, global_memory, "format_version=1") != null);
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
    try testing.expectEqualStrings("TOOL_TIMEOUT", state.runtime_session.last_failure.code);
    try testing.expectEqualStrings("Tool execution exceeded 5s", state.runtime_session.last_failure.cause);
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

test "loadConfig mirrors model_policy routes into legacy provider fields" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const config_json =
        \\{
        \\  "runtime_version": 1,
        \\  "model_policy": {
        \\    "enabled": true,
        \\    "strategy": "smallest-capable",
        \\    "primary": {
        \\      "enabled": true,
        \\      "type": "ollama-native",
        \\      "base_url": "http://127.0.0.1:11434",
        \\      "model": "qwen2.5-coder:7b",
        \\      "timeout_ms": 120000,
        \\      "max_retries": 2,
        \\      "structured_output": "json"
        \\    },
        \\    "fallback": {
        \\      "enabled": true,
        \\      "type": "openrouter",
        \\      "base_url": "https://openrouter.ai/api",
        \\      "model": "openai/gpt-5.2-mini",
        \\      "timeout_ms": 120000,
        \\      "max_retries": 1,
        \\      "structured_output": "json",
        \\      "api_key_env": "OPENROUTER_API_KEY",
        \\      "app_name": "Contubernium"
        \\    }
        \\  }
        \\}
    ;

    var file = try tmp.dir.createFile("config.json", .{ .truncate = true });
    defer file.close();
    try file.writeAll(config_json);

    const root = try tmp.dir.realpathAlloc(scratch, ".");
    const path = try std.fs.path.join(scratch, &.{ root, "config.json" });

    const loaded = try loadConfig(scratch, path);
    try testing.expectEqualStrings("ollama-native", loaded.provider.type);
    try testing.expectEqualStrings("qwen2.5-coder:7b", loaded.provider.model);
    try testing.expectEqualStrings("openrouter", loaded.fallback_provider.type);
    try testing.expectEqualStrings("openai/gpt-5.2-mini", loaded.fallback_provider.model);
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

test "initializeRuntimeRunLog stores model policy metadata" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();
    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    var state = AppState{};
    state.project_name = "Contubernium";
    state.mission.initial_prompt = "implement phase 3";

    const config = AppConfig{
        .model_policy = .{
            .enabled = true,
            .strategy = "smallest-capable",
            .primary = .{
                .type = "ollama-native",
                .base_url = "http://127.0.0.1:11434",
                .model = "qwen2.5-coder:7b",
            },
            .escalation = .{
                .enabled = true,
                .provider = .{
                    .enabled = true,
                    .type = "ollama-native",
                    .base_url = "http://127.0.0.1:11434",
                    .model = "qwen2.5-coder:14b",
                    .max_retries = 1,
                },
            },
            .fallback = .{
                .enabled = true,
                .type = "openrouter",
                .base_url = "https://openrouter.ai/api",
                .model = "openai/gpt-5.2-mini",
                .max_retries = 1,
                .api_key_env = "OPENROUTER_API_KEY",
                .app_name = "Contubernium",
            },
        },
        .paths = .{
            .logs_dir = "logs",
        },
    };

    try initializeRuntimeRunLog(scratch, config, &state, "mission");

    const loaded = try loadRuntimeRunLog(scratch, state.runtime_session.active_log_path);
    try testing.expectEqualStrings("ollama-native", loaded.provider);
    try testing.expectEqualStrings("qwen2.5-coder:7b", loaded.model);
    try testing.expectEqualStrings("smallest-capable", loaded.model_policy.strategy);
    try testing.expectEqualStrings("qwen2.5-coder:14b", loaded.model_policy.escalation_model);
    try testing.expectEqualStrings("openrouter", loaded.model_policy.fallback_provider);
    try testing.expectEqualStrings("openai/gpt-5.2-mini", loaded.model_policy.fallback_model);
}

test "normalizeLegacyStateJson migrates legacy failure envelope keys" {
    const testing = std.testing;
    const normalized = try normalizeLegacyStateJson(testing.allocator,
        \\{
        \\  "agent_loop": {
        \\    "active_tool": "",
        \\    "history": []
        \\  },
        \\  "tasks": {
        \\    "backend": {
        \\      "invocation": {
        \\        "result": {
        \\          "next_recommended_agent": ""
        \\        }
        \\      }
        \\    }
        \\  },
        \\  "runtime_session": {
        \\    "last_failure": {
        \\      "error_code": "TOOL_TIMEOUT",
        \\      "message": "timed out"
        \\    }
        \\  }
        \\}
    );
    defer testing.allocator.free(normalized);

    try testing.expect(std.mem.indexOf(u8, normalized, "\"code\": \"TOOL_TIMEOUT\"") != null);
    try testing.expect(std.mem.indexOf(u8, normalized, "\"cause\": \"timed out\"") != null);
    try testing.expect(std.mem.indexOf(u8, normalized, "\"active_tool\": null") != null);
    try testing.expect(std.mem.indexOf(u8, normalized, "\"next_recommended_agent\": null") != null);
}

test "loadRuntimeRunLog normalizes legacy failure envelope keys" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const root = try tmp.dir.realpathAlloc(scratch, ".");
    const path = try std.fs.path.join(scratch, &.{ root, "legacy-run-log.json" });

    try tmp.dir.writeFile(.{
        .sub_path = "legacy-run-log.json",
        .data =
        \\{
        \\  "format_version": 1,
        \\  "run_id": "run-legacy",
        \\  "command": "mission",
        \\  "created_at": "1",
        \\  "updated_at": "1",
        \\  "project_name": "Contubernium",
        \\  "provider": "ollama-native",
        \\  "model": "qwen2.5-coder:7b",
        \\  "approval_mode": "guarded",
        \\  "mission_prompt": "resume session",
        \\  "events": [
        \\    {
        \\      "timestamp": "2",
        \\      "iteration": 1,
        \\      "turn_id": "turn-1",
        \\      "actor": "decanus",
        \\      "lane": "command",
        \\      "action": "tool_result",
        \\      "status": "blocked",
        \\      "summary": "timed out",
        \\      "failure": {
        \\        "error_code": "TOOL_TIMEOUT",
        \\        "message": "timed out",
        \\        "context": {
        \\          "tool": "read_file"
        \\        }
        \\      }
        \\    }
        \\  ]
        \\}
        ,
    });

    const loaded = try loadRuntimeRunLog(scratch, path);
    const failure = loaded.events[0].failure.?;
    try testing.expectEqualStrings("TOOL_TIMEOUT", failure.code);
    try testing.expectEqualStrings("timed out", failure.cause);
    try testing.expectEqualStrings("read_file", failure.context.tool);
}

test "loadSessionIndex migrates legacy unversioned format to the current version" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const root = try tmp.dir.realpathAlloc(scratch, ".");
    const path = try std.fs.path.join(scratch, &.{ root, "sessions-index.json" });

    try tmp.dir.writeFile(.{
        .sub_path = "sessions-index.json",
        .data =
        \\{
        \\  "current_session_id": "session-legacy",
        \\  "sessions": []
        \\}
        ,
    });

    const index = try loadSessionIndex(scratch, path);
    try testing.expectEqual(@as(usize, session_index_format_version), index.format_version);
    try testing.expectEqualStrings("session-legacy", index.current_session_id);
}

test "loadSessionRecord migrates legacy unversioned format to the current version" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const root = try tmp.dir.realpathAlloc(scratch, ".");
    const path = try std.fs.path.join(scratch, &.{ root, "session-record.json" });

    try tmp.dir.writeFile(.{
        .sub_path = "session-record.json",
        .data =
        \\{
        \\  "session_id": "session-legacy",
        \\  "mission_prompt": "resume mission",
        \\  "state_snapshot": {}
        \\}
        ,
    });

    const record = try loadSessionRecord(scratch, path);
    try testing.expectEqual(@as(usize, session_record_format_version), record.format_version);
    try testing.expectEqualStrings("session-legacy", record.session_id);
    try testing.expectEqualStrings("resume mission", record.mission_prompt);
}

test "loadGlobalSessionIndex rejects unsupported future format versions" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const root = try tmp.dir.realpathAlloc(scratch, ".");
    const path = try std.fs.path.join(scratch, &.{ root, "global-session-index.json" });

    try tmp.dir.writeFile(.{
        .sub_path = "global-session-index.json",
        .data =
        \\{
        \\  "format_version": 99,
        \\  "sessions": []
        \\}
        ,
    });

    _ = loadGlobalSessionIndex(scratch, path) catch |err| {
        try testing.expectEqual(error.UnsupportedMemoryFormatVersion, err);
        return;
    };
    return error.TestUnexpectedResult;
}

test "normalizeGlobalMemoryMarkdown adds a version marker and strips it for prompt use" {
    const testing = std.testing;
    const normalized = try normalizeGlobalMemoryMarkdown(testing.allocator,
        \\# Global Memory
        \\
        \\Keep the rules concise.
    );
    defer testing.allocator.free(normalized);

    try testing.expect(std.mem.indexOf(u8, normalized, "format_version=1") != null);
    try testing.expectEqual(@as(usize, global_memory_format_version), 1);
    try testing.expectEqualStrings(
        "# Global Memory\n\nKeep the rules concise.",
        stripGlobalMemoryVersionHeader(normalized),
    );
}

test "resolveContuberniumHome falls back to USERPROFILE when HOME is unavailable" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    const userprofile_path = try tmp.dir.realpathAlloc(scratch, ".");
    const original_contubernium_home = std.posix.getenv("CONTUBERNIUM_HOME");
    const original_home = std.posix.getenv("HOME");
    const original_userprofile = std.posix.getenv("USERPROFILE");

    const contubernium_home_name = try scratch.dupeZ(u8, "CONTUBERNIUM_HOME");
    const home_name = try scratch.dupeZ(u8, "HOME");
    const userprofile_name = try scratch.dupeZ(u8, "USERPROFILE");
    const userprofile_value = try scratch.dupeZ(u8, userprofile_path);

    defer {
        if (original_contubernium_home) |value| {
            _ = setenv(contubernium_home_name.ptr, value, 1);
        } else {
            _ = unsetenv(contubernium_home_name.ptr);
        }
        if (original_home) |value| {
            _ = setenv(home_name.ptr, value, 1);
        } else {
            _ = unsetenv(home_name.ptr);
        }
        if (original_userprofile) |value| {
            _ = setenv(userprofile_name.ptr, value, 1);
        } else {
            _ = unsetenv(userprofile_name.ptr);
        }
    }

    _ = unsetenv(contubernium_home_name.ptr);
    _ = unsetenv(home_name.ptr);
    try testing.expectEqual(@as(c_int, 0), setenv(userprofile_name.ptr, userprofile_value.ptr, 1));

    const resolved = try resolveContuberniumHome(scratch);
    const expected = try std.fs.path.join(scratch, &.{ userprofile_path, ".contubernium" });
    try testing.expectEqualStrings(expected, resolved);
}

test "snapshotFromState prefers the active routed provider over the primary config" {
    const testing = std.testing;
    const config = AppConfig{
        .model_policy = .{
            .enabled = true,
            .primary = .{
                .type = "ollama-native",
                .model = "qwen2.5-coder:7b",
            },
            .fallback = .{
                .enabled = true,
                .type = "openrouter",
                .base_url = "https://openrouter.ai/api",
                .model = "openai/gpt-5.2-mini",
                .api_key_env = "OPENROUTER_API_KEY",
                .app_name = "Contubernium",
            },
        },
    };

    var state = AppState{};
    state.runtime_session.provider = "openrouter";
    state.runtime_session.model = "openai/gpt-5.2-mini";

    const snapshot = snapshotFromState(config, state, "Contubernium");
    try testing.expectEqualStrings("openrouter", snapshot.provider_type);
    try testing.expectEqualStrings("openai/gpt-5.2-mini", snapshot.model);
}

test "persistSessionMemory writes durable local and global session indexes" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var arena = std.heap.ArenaAllocator.init(testing.allocator);
    defer arena.deinit();
    const scratch = arena.allocator();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    try tmp.dir.makePath("home");
    const home_path = try tmp.dir.realpathAlloc(scratch, "home");
    const home_z = try scratch.dupeZ(u8, home_path);
    const env_name = try scratch.dupeZ(u8, "CONTUBERNIUM_HOME");
    try testing.expectEqual(@as(c_int, 0), setenv(env_name.ptr, home_z.ptr, 1));
    defer _ = unsetenv(env_name.ptr);

    try scaffoldProject(scratch);
    const config = try loadProjectConfig(scratch);
    var state = try loadState(scratch, config.paths.state_file);
    resetStateForMission(&state, "resume phase 4");
    initializeRuntimeSession(scratch, &state, config);
    state.runtime_session.status = .blocked;
    state.runtime_session.active_log_path = ".contubernium/logs/run-1.json";

    try persistSessionMemory(scratch, config, &state, "mission");

    const index = try loadSessionIndex(scratch, config.paths.session_index_file);
    try testing.expectEqual(@as(usize, 1), index.sessions.len);
    try testing.expect(index.current_session_id.len > 0);
    try testing.expectEqualStrings(index.current_session_id, state.runtime_session.session_id);

    const record_path = try sessionRecordPath(scratch, config.paths.sessions_dir, index.current_session_id);
    const record = try loadSessionRecord(scratch, record_path);
    try testing.expectEqualStrings("resume phase 4", record.mission_prompt);
    try testing.expectEqualStrings(".contubernium/logs/run-1.json", record.last_log_path);
    try testing.expectEqual(@as(usize, 1), record.run_log_paths.len);
    try testing.expect(record.project_id.len > 0);

    const global_index_path = try resolveGlobalSessionIndexPath(scratch);
    const global_index = try loadGlobalSessionIndex(scratch, global_index_path);
    try testing.expectEqual(@as(usize, 1), global_index.sessions.len);
    try testing.expectEqualStrings(record.session_id, global_index.sessions[0].session_id);
}

test "executeToolRequests honors session approval bypass for guarded tools" {
    const testing = std.testing;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    var state = AppState{};
    state.runtime_session.approval_bypass_enabled = true;
    state.runtime_session.approval_mode = "session-bypass";

    const outcome = try executeToolRequests(testing.allocator, AppConfig{}, &state, .decanus, .command, &.{
        .{
            .tool = "write_file",
            .path = "notes.txt",
            .content = "phase 4 durable session test",
        },
    }, .{ .approval_fn = testDenyApproval });
    defer testing.allocator.free(outcome.summary);

    try testing.expect(!outcome.blocked);
    try testing.expect(pathExists("notes.txt"));
    try testing.expectEqual(ApprovalStatus.idle, state.runtime_session.active_approval.status);
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
