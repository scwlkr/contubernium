const std = @import("std");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const assets_mod = @import("runtime_assets.zig");
const prompting_mod = @import("runtime_prompting.zig");
const provider_mod = @import("runtime_provider.zig");
const tools_mod = @import("runtime_tools.zig");

const prettyPrintJson = model_json.prettyPrintJson;

fn decanusHasInvocationPayload(decision: core.DecanusDecision) bool {
    return decision.agent_call.len > 0 or
        decision.actor.len > 0 or
        decision.lane.len > 0 or
        decision.objective.len > 0 or
        decision.completion_signal.len > 0 or
        decision.dependencies.len > 0;
}

pub fn resolvedDecanusControlAction(decision: core.DecanusDecision) []const u8 {
    if (core.eql(decision.action, "finish") or
        core.eql(decision.action, "invoke_specialist") or
        core.eql(decision.action, "tool_request") or
        core.eql(decision.action, "ask_user") or
        core.eql(decision.action, "blocked"))
    {
        return decision.action;
    }

    if (core.eql(decision.action, "finish_mission")) return "finish";
    if (core.eql(decision.action, "request_tools") or core.eql(decision.action, "use_tools")) return "tool_request";
    if (core.eql(decision.action, "request_user") or core.eql(decision.action, "question")) return "ask_user";

    if (decision.tool_requests.len > 0) return "tool_request";
    if (decision.final_response.len > 0) return "finish";
    if (decision.question.len > 0) return "ask_user";
    if (decision.blocked_reason.len > 0) return "blocked";
    if (decanusHasInvocationPayload(decision)) return "invoke_specialist";

    return "";
}

pub fn executeDecanusTurn(
    allocator: std.mem.Allocator,
    config: core.AppConfig,
    state: *core.AppState,
    hooks: core.RuntimeHooks,
) !core.StepOutcome {
    core.stateManager(state).beginCommanderThinking();
    core.emitStateSnapshot(hooks, config, state.*);
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "turn_started",
        .status = "running",
        .summary = if (state.mission.current_goal.len > 0) state.mission.current_goal else state.mission.initial_prompt,
        .include_snapshot = true,
    });

    const asset_layout = try assets_mod.resolveGlobalAssetLayout(allocator);
    defer assets_mod.deinitGlobalAssetLayout(allocator, asset_layout);
    const system_prompt = try prompting_mod.assembleSystemPrompt(allocator, asset_layout, state, .decanus);
    defer allocator.free(system_prompt);
    const prompt_build = prompting_mod.buildPromptWithContextBudget(allocator, config, state, hooks, system_prompt, .decanus, "") catch |err| {
        if (err == error.ContextBudgetExceeded or err == error.MemoryLoadBlocked) return .blocked;
        return err;
    };
    defer prompt_build.deinit(allocator);
    const user_prompt = prompt_build.user_prompt;
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "memory_layers_loaded",
        .status = "success",
        .summary = try prompting_mod.summarizeRuntimeMemorySnapshot(allocator, prompt_build.memory),
    });
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "system_prompt",
        .status = "captured",
        .summary = "assembled decanus system prompt",
        .output = system_prompt,
    });
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "user_prompt",
        .status = "captured",
        .summary = "assembled decanus user prompt",
        .output = user_prompt,
    });

    var response = provider_mod.structuredChatWithRepair(
        allocator,
        config,
        system_prompt,
        user_prompt,
        "decanus",
        config.provider.max_retries,
        core.DecanusDecision,
        state,
        hooks,
    ) catch |err| {
        if (err == error.Interrupted) {
            core.markInterrupted(state);
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_interrupted",
                .status = "blocked",
                .summary = "decanus turn interrupted",
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        const message = try std.fmt.allocPrint(allocator, "decanus turn failed: {s}", .{@errorName(err)});
        const failure = core.buildRuntimeFailure(state, .decanus, .command, "DECANUS_TURN_FAILED", message, .{
            .detail = @errorName(err),
        });
        core.recordRuntimeFailure(state, failure);
        core.stateManager(state).markBlocked(.decanus, .command, message);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_failed",
            .status = "error",
            .summary = "decanus turn failed",
            .error_text = message,
            .failure = failure,
            .include_snapshot = true,
        });
        core.emitLog(hooks, .danger, "decanus", "Commander Failed", message, .plain);
        return .blocked;
    };
    var owned_response_raw_text: ?[]const u8 = response.raw_text;
    defer if (owned_response_raw_text) |text| allocator.free(text);
    var decision = response.value;
    var decision_raw_text = owned_response_raw_text.?;
    var normalized_action = resolvedDecanusControlAction(decision);
    var repaired_decision = false;
    if (normalized_action.len == 0) {
        const action_label = if (decision.action.len > 0) decision.action else "(empty)";
        const repair_message = try std.fmt.allocPrint(
            allocator,
            "decanus returned unsupported action `{s}`; requesting corrected JSON",
            .{action_label},
        );
        defer allocator.free(repair_message);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "semantic_repair",
            .status = "retrying",
            .summary = repair_message,
            .output = response.raw_text,
            .error_text = repair_message,
        });
        core.emitLog(hooks, .warning, "decanus", "Repair Retry", repair_message, .plain);

        const repair_prompt = try std.fmt.allocPrint(
            allocator,
            "{s}\n\nYour previous response used an unsupported JSON action value `{s}`. Keep the same intent, but return corrected `DecanusDecision` JSON only. The `action` field must be one of: `finish`, `invoke_specialist`, `tool_request`, `ask_user`, or `blocked`. Do not use action file names such as `EVALUATE_LOOP`, `INVOKE_SPECIALIST`, or `FINISH_MISSION`.",
            .{ user_prompt, action_label },
        );
        defer allocator.free(repair_prompt);
        core.freeOwnedDecanusDecision(allocator, decision);
        allocator.free(owned_response_raw_text.?);
        owned_response_raw_text = null;

        const repaired_response = provider_mod.structuredChatWithRepair(
            allocator,
            config,
            system_prompt,
            repair_prompt,
            "decanus",
            @min(@as(usize, 1), config.provider.max_retries),
            core.DecanusDecision,
            state,
            hooks,
        ) catch |err| {
            const message = try std.fmt.allocPrint(allocator, "decanus repair failed: {s}", .{@errorName(err)});
            const failure = core.buildRuntimeFailure(state, .decanus, .command, "DECANUS_ACTION_INVALID", message, .{
                .detail = "unsupported decanus action",
            });
            core.recordRuntimeFailure(state, failure);
            core.stateManager(state).markBlocked(.decanus, .command, message);
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = message,
                .error_text = message,
                .failure = failure,
                .include_snapshot = true,
            });
            core.emitLog(hooks, .danger, "decanus", "Blocked", message, .plain);
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        };
        response = repaired_response;
        owned_response_raw_text = response.raw_text;
        decision = response.value;
        decision_raw_text = owned_response_raw_text.?;
        normalized_action = resolvedDecanusControlAction(decision);
        repaired_decision = true;
    }
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "model_output",
        .status = if (repaired_decision) "repaired" else "success",
        .summary = "raw decanus response",
        .output = decision_raw_text,
    });
    const decision_summary = core.summarizeDecanusDecisionForUi(allocator, decision) catch prettyPrintJson(allocator, decision_raw_text) catch decision_raw_text;
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "parsed_output",
        .status = if (repaired_decision) "repaired" else "success",
        .summary = decision_summary,
        .output = prettyPrintJson(allocator, decision_raw_text) catch decision_raw_text,
    });
    try core.stateManager(state).appendIntermediateResult(allocator, "decision_summary", .decanus, .command, decision_summary);
    core.emitStreamFinalize(hooks, "decanus", "decision", decision_summary, .summary);

    core.stateManager(state).setCurrentGoal(decision.current_goal);
    core.stateManager(state).setLastDecision(if (normalized_action.len > 0) normalized_action else decision.action);
    core.emitStateSnapshot(hooks, config, state.*);

    if (decision.tool_requests.len > 0 or core.eql(normalized_action, "tool_request")) {
        core.emitLog(
            hooks,
            .tool,
            "decanus",
            "Runtime Tool",
            core.summarizeToolRequestsForUi(allocator, decision.tool_requests) catch "decanus requested runtime tools",
            .plain,
        );
        const tool_result = try tools_mod.executeToolRequests(allocator, config, state, .decanus, .command, decision.tool_requests, hooks);
        try core.stateManager(state).recordRuntimeToolResultStep(allocator, .decanus, .command, tool_result.summary);
        core.emitStreamFinalize(hooks, "decanus", "runtime tool", tool_result.summary, .summary);
        if (tool_result.blocked) {
            core.stateManager(state).markBlocked(.decanus, .command, tool_result.summary);
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = tool_result.summary,
                .error_text = state.runtime_session.last_error,
                .failure = state.runtime_session.last_failure,
                .include_snapshot = true,
            });
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        }
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_advanced",
            .status = "success",
            .summary = tool_result.summary,
            .include_snapshot = true,
        });
        core.emitLog(
            hooks,
            .tool,
            "decanus",
            "Tool Result",
            core.compactTextForUi(allocator, tool_result.summary, 12, 900) catch tool_result.summary,
            .plain,
        );
        return .advanced;
    }

    if (core.eql(normalized_action, "finish")) {
        try core.stateManager(state).completeMissionWithHistory(allocator, .decanus, .command, decision.final_response);
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "run_completed",
            .status = "complete",
            .summary = decision.final_response,
            .output = decision.final_response,
            .include_snapshot = true,
        });
        core.emitLog(hooks, .success, "decanus", "Final Response", decision.final_response, .plain);
        core.emitStateSnapshot(hooks, config, state.*);
        return .complete;
    }

    if (core.eql(normalized_action, "invoke_specialist")) {
        const invocation_resolution = assets_mod.resolveSpecialistInvocationFromDecision(allocator, asset_layout, decision) catch |err| {
            const message = try assets_mod.specialistInvocationResolutionMessage(allocator, decision, err);
            const failure = core.buildRuntimeFailure(state, .decanus, .command, "SPECIALIST_RESOLUTION_FAILED", message, .{
                .target = if (decision.agent_call.len > 0) decision.agent_call else if (decision.actor.len > 0) decision.actor else decision.lane,
                .detail = @errorName(err),
            });
            core.recordRuntimeFailure(state, failure);
            core.stateManager(state).markBlocked(.decanus, .command, message);
            try assets_mod.logRuntimeEvent(allocator, config, state, .{
                .actor = .decanus,
                .lane = .command,
                .action = "turn_blocked",
                .status = "blocked",
                .summary = message,
                .error_text = message,
                .failure = failure,
                .include_snapshot = true,
            });
            core.emitLog(hooks, .danger, "decanus", "Resolver Blocked", message, .plain);
            core.emitStateSnapshot(hooks, config, state.*);
            return .blocked;
        };
        try core.stateManager(state).prepareInvocationWithHistory(
            allocator,
            invocation_resolution.lane,
            invocation_resolution.actor,
            if (decision.objective.len > 0) decision.objective else "complete the assigned scope",
            if (decision.completion_signal.len > 0) decision.completion_signal else "return a structured result to decanus",
            decision.dependencies,
            invocation_resolution.agent_call,
            invocation_resolution.action_name,
        );
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "specialist_invoked",
            .status = "success",
            .tool = core.actorName(invocation_resolution.actor),
            .summary = invocation_resolution.agent_call,
            .input = decision.objective,
            .include_snapshot = true,
        });
        core.emitLog(
            hooks,
            .tool,
            "decanus",
            "Specialist Invoked",
            invocation_resolution.agent_call,
            .plain,
        );
        core.emitStateSnapshot(hooks, config, state.*);
        return .advanced;
    }

    if (core.eql(normalized_action, "ask_user")) {
        const failure = core.buildRuntimeFailure(state, .decanus, .command, "USER_INPUT_REQUIRED", decision.question, .{
            .detail = "decanus requested user input",
        });
        core.recordRuntimeFailure(state, failure);
        core.stateManager(state).markBlocked(.decanus, .command, decision.question);
        try core.appendHistory(allocator, state, .{
            .iteration = state.agent_loop.iteration,
            .type = "ask_user",
            .actor = "decanus",
            .lane = "",
            .summary = decision.question,
            .artifacts = &.{},
            .timestamp = try core.unixTimestampString(allocator),
        });
        try assets_mod.logRuntimeEvent(allocator, config, state, .{
            .actor = .decanus,
            .lane = .command,
            .action = "turn_blocked",
            .status = "blocked",
            .summary = decision.question,
            .error_text = decision.question,
            .failure = failure,
            .include_snapshot = true,
        });
        core.emitLog(hooks, .warning, "decanus", "Question", decision.question, .plain);
        core.emitStateSnapshot(hooks, config, state.*);
        return .blocked;
    }

    const blocked_message = if (normalized_action.len == 0)
        try std.fmt.allocPrint(
            allocator,
            "decanus returned unsupported action `{s}`",
            .{if (decision.action.len > 0) decision.action else "(empty)"},
        )
    else if (decision.blocked_reason.len > 0)
        decision.blocked_reason
    else
        "decanus returned a blocked state";
    const blocked_failure = core.buildRuntimeFailure(state, .decanus, .command, "DECANUS_BLOCKED", blocked_message, .{
        .detail = if (normalized_action.len == 0) "unsupported decanus action" else "decanus returned a blocked state",
    });
    core.recordRuntimeFailure(state, blocked_failure);
    core.stateManager(state).markBlocked(.decanus, .command, state.runtime_session.last_error);
    try assets_mod.logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "turn_blocked",
        .status = "blocked",
        .summary = state.runtime_session.last_error,
        .error_text = state.runtime_session.last_error,
        .failure = blocked_failure,
        .include_snapshot = true,
    });
    core.emitLog(hooks, .danger, "decanus", "Blocked", state.runtime_session.last_error, .plain);
    core.emitStateSnapshot(hooks, config, state.*);
    return .blocked;
}
