const std = @import("std");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const assets_mod = @import("runtime_assets.zig");
const prompting_mod = @import("runtime_prompting.zig");
const provider_mod = @import("runtime_provider.zig");
const tools_mod = @import("runtime_tools.zig");

const prettyPrintJson = model_json.prettyPrintJson;

pub fn executeSpecialistTurn(
    allocator: std.mem.Allocator,
    config: core.AppConfig,
    state: *core.AppState,
    hooks: core.RuntimeHooks,
    cache: ?*prompting_mod.PromptCache,
) !core.StepOutcome {
    const actor = state.current_actor;
    const lane = core.laneForActor(actor);
    var task = core.taskForLane(state, lane);
    core.stateManager(state).beginSpecialistExecution(actor, lane, task.invocation.objective);
    core.emitStateSnapshot(hooks, config, state.*);
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "turn_started",
        .status = "running",
        .summary = task.invocation.objective,
        .include_snapshot = true,
    });

    const layout_cached = cache != null;
    const asset_layout = if (cache) |c|
        try prompting_mod.resolveOrCacheAssetLayout(allocator, c)
    else
        try assets_mod.resolveGlobalAssetLayout(allocator);
    defer if (!layout_cached) assets_mod.deinitGlobalAssetLayout(allocator, asset_layout);
    const system_prompt = if (cache) |c|
        try prompting_mod.assembleOrCacheSystemPrompt(allocator, asset_layout, state, actor, c)
    else
        try prompting_mod.assembleSystemPrompt(allocator, asset_layout, state, actor);
    defer allocator.free(system_prompt);
    const prompt_build = prompting_mod.buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .specialist, core.laneName(lane), null) catch |err| {
        if (err == error.ContextBudgetExceeded or err == error.MemoryLoadBlocked) return .blocked;
        return err;
    };
    defer prompt_build.deinit(allocator);
    const user_prompt = prompt_build.user_prompt;
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "memory_layers_loaded",
        .status = "success",
        .summary = try prompting_mod.summarizeRuntimeMemorySnapshot(allocator, prompt_build.memory),
    });
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "system_prompt",
        .status = "captured",
        .summary = "assembled specialist system prompt",
        .output = system_prompt,
    });
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "user_prompt",
        .status = "captured",
        .summary = "assembled specialist user prompt",
        .output = user_prompt,
    });

    const response = provider_mod.structuredChatWithRepair(
        allocator,
        config,
        system_prompt,
        user_prompt,
        core.actorName(actor),
        config.provider.max_retries,
        core.SpecialistResult,
        state,
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            core.markInterrupted(state);
            task.invocation.status = .blocked;
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "turn_interrupted",
                .status = "blocked",
                .summary = "specialist turn interrupted",
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "{s} turn failed: {s}", .{ core.actorName(actor), @errorName(err) });
        const failure = core.buildRuntimeFailure(state, actor, lane, "SPECIALIST_TURN_FAILED", message, .{
            .detail = @errorName(err),
        });
        task.invocation.status = .blocked;
        core.recordRuntimeFailure(state, failure);
        core.stateManager(state).markBlocked(actor, lane, message);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_failed",
            .status = "error",
            .summary = "specialist turn failed",
            .error_text = message,
            .failure = failure,
            .include_snapshot = true,
        });
        core.emitLog(hooks, .danger, core.actorName(actor), "Specialist Failed", message, .plain);
        return .blocked;
    };
    defer allocator.free(response.raw_text);
    const result = response.value;
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "model_output",
        .status = "success",
        .summary = "raw specialist response",
        .output = response.raw_text,
    });
    const result_summary = core.summarizeSpecialistResultForUi(allocator, result) catch prettyPrintJson(allocator, response.raw_text) catch response.raw_text;
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "parsed_output",
        .status = "success",
        .summary = result_summary,
        .output = prettyPrintJson(allocator, response.raw_text) catch response.raw_text,
    });
    try core.stateManager(state).appendIntermediateResult(allocator, "specialist_summary", actor, lane, result_summary);
    core.emitStreamFinalize(hooks, core.actorName(actor), "summary", result_summary, .summary);

    if (result.tool_requests.len > 0 or core.eql(result.action, "tool_request")) {
        const tool_request_summary_owned = core.summarizeToolRequestsForUi(allocator, result.tool_requests) catch null;
        const tool_request_summary = tool_request_summary_owned orelse "specialist requested runtime tools";
        core.stateManager(state).beginSubordinateToolLoop(lane, tool_request_summary);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "subordinate_tool_loop_requested",
            .status = "running",
            .summary = tool_request_summary,
            .include_snapshot = true,
        });
        core.emitStateSnapshot(hooks, config, state.*);
        core.emitLog(
            hooks,
            .tool,
            core.actorName(actor),
            "Runtime Tool",
            tool_request_summary,
            .plain,
        );
        const tool_result = try tools_mod.executeToolRequests(allocator, config, state, actor, lane, result.tool_requests, hooks);
        try core.stateManager(state).recordRuntimeToolResultStep(allocator, actor, lane, tool_result.summary);
        core.emitStreamFinalize(hooks, core.actorName(actor), "runtime tool", tool_result.summary, .summary);
        if (tool_result.blocked) {
            task.invocation.status = .blocked;
            core.stateManager(state).markSubordinateToolLoopBlocked(lane, tool_result.summary);
            core.stateManager(state).markBlocked(actor, lane, tool_result.summary);
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = actor,
                .lane = lane,
                .action = "subordinate_tool_loop_blocked",
                .status = "blocked",
                .summary = tool_result.summary,
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        task.invocation.status = .running;
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "subordinate_tool_loop_result_available",
            .status = "success",
            .summary = tool_result.summary,
            .include_snapshot = true,
        });
        core.emitStateSnapshot(hooks, config, state.*);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "turn_advanced",
            .status = "success",
            .summary = tool_result.summary,
            .include_snapshot = true,
        });
        core.emitLog(
            hooks,
            .tool,
            core.actorName(actor),
            "Tool Result",
            core.compactTextForUi(allocator, tool_result.summary, 12, 900) catch tool_result.summary,
            .plain,
        );
        return .advanced;
    }

    if (core.eql(result.action, "complete") or core.eql(result.status, "complete") or core.eql(result.status, "partial")) {
        const invocation_result = try core.materializeInvocationResult(
            allocator,
            result,
            if (core.eql(result.status, "partial")) .partial else .complete,
        );
        try core.stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "invocation_returned",
            .status = if (invocation_result.status == .partial) "partial" else "complete",
            .summary = invocation_result.summary,
            .output = invocation_result.summary,
            .include_snapshot = true,
        });
        core.emitStreamFinalize(hooks, core.actorName(actor), "result", invocation_result.summary, .summary);
        core.emitLog(hooks, .success, core.actorName(actor), "Lane Complete", invocation_result.summary, .plain);
        core.emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (core.eql(result.action, "ask_user")) {
        const invocation_result = try core.materializeInvocationResult(allocator, result, .blocked);
        const failure = core.buildRuntimeFailure(state, actor, lane, "USER_INPUT_REQUIRED", result.question, .{
            .detail = "specialist requested user input",
        });
        try core.stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
        core.emitStreamFinalize(hooks, core.actorName(actor), "result", invocation_result.summary, .summary);
        core.recordRuntimeFailure(state, failure);
        core.stateManager(state).markBlocked(actor, lane, result.question);
        try core.appendHistory(allocator, state, .{
            .iteration = state.agent_loop.iteration,
            .type = "ask_user",
            .actor = core.actorName(actor),
            .lane = if (lane == .command) "" else core.laneName(lane),
            .summary = result.question,
            .artifacts = &.{},
            .timestamp = try core.unixTimestampString(allocator),
        });
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = actor,
            .lane = lane,
            .action = "invocation_returned",
            .status = "blocked",
            .summary = result.question,
            .error_text = result.question,
            .failure = failure,
            .include_snapshot = true,
        });
        core.emitLog(hooks, .warning, core.actorName(actor), "Question", result.question, .plain);
        core.emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    const invocation_result = try core.materializeInvocationResult(allocator, result, .blocked);
    const blocked_message = if (invocation_result.blockers.len > 0) invocation_result.blockers[0] else "specialist returned a blocked state";
    const blocked_failure = core.buildRuntimeFailure(state, actor, lane, "SPECIALIST_BLOCKED", blocked_message, .{
        .detail = "specialist returned a blocked state",
    });
    try core.stateManager(state).finalizeInvocationWithHistory(allocator, lane, actor, invocation_result, result.description);
    core.emitStreamFinalize(hooks, core.actorName(actor), "result", invocation_result.summary, .summary);
    core.recordRuntimeFailure(state, blocked_failure);
    core.stateManager(state).markBlocked(actor, lane, state.runtime_session.last_error);
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = actor,
        .lane = lane,
        .action = "invocation_returned",
        .status = "blocked",
        .summary = state.runtime_session.last_error,
        .error_text = state.runtime_session.last_error,
        .failure = blocked_failure,
        .include_snapshot = true,
    });
    core.emitLog(hooks, .danger, core.actorName(actor), "Blocked", state.runtime_session.last_error, .plain);
    core.emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}
