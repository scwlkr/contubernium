const std = @import("std");

pub const Actor = enum {
    decanus,
    faber,
    artifex,
    architectus,
    tesserarius,
    explorator,
    signifer,
    praeco,
    calo,
    mulus,
};

pub const Lane = enum {
    command,
    backend,
    frontend,
    systems,
    qa,
    research,
    brand,
    media,
    docs,
    bulk_ops,
};

pub const GlobalStatus = enum {
    idle,
    planning,
    waiting_on_tool,
    complete,
    interrupted,
};

pub const LoopStatus = enum {
    awaiting_initial_prompt,
    thinking,
    running_tool,
    blocked,
    complete,
    interrupted,
};

pub const RuntimeStatus = enum {
    idle,
    ready,
    running,
    awaiting_approval,
    blocked,
    complete,
    interrupted,
};

pub const TaskStatus = enum {
    pending,
    in_progress,
    complete,
    blocked,
};

pub const InvocationStatus = enum {
    idle,
    ready,
    running,
    awaiting_approval,
    complete,
    partial,
    blocked,
};

pub const InvocationResultStatus = enum {
    idle,
    complete,
    partial,
    blocked,
};

pub const ApprovalStatus = enum {
    idle,
    pending,
    approved,
    denied,
};

pub const ApprovalKind = enum {
    read,
    write,
    shell,
    destructive_change,
    external_mutation,
    deployment,
};

pub const LoopStepKind = enum {
    think,
    invoke,
    wait_for_approval,
    execute,
    result,
    finish,
    blocked,
};

pub const Mission = struct {
    initial_prompt: []const u8 = "",
    current_goal: []const u8 = "",
    success_criteria: []const []const u8 = &.{},
    constraints: []const []const u8 = &.{},
    final_response: []const u8 = "",
};

pub const InvocationContext = struct {
    project: []const u8 = "",
    files: []const []const u8 = &.{},
    constraints: []const []const u8 = &.{},
    dependencies: []const []const u8 = &.{},
};

pub const InvocationScope = struct {
    allowed_actions: []const []const u8 = &.{},
    restricted_actions: []const []const u8 = &.{},
};

pub const InvocationMemory = struct {
    mission: []const u8 = "",
    project: []const u8 = "",
    relevant: []const []const u8 = &.{},
};

pub const InvocationResult = struct {
    status: InvocationResultStatus = .idle,
    summary: []const u8 = "",
    changes: []const []const u8 = &.{},
    findings: []const []const u8 = &.{},
    blockers: []const []const u8 = &.{},
    next_recommended_agent: ?Actor = null,
    confidence: f32 = 0.0,
};

pub const Invocation = struct {
    status: InvocationStatus = .idle,
    requested_by: Actor = .decanus,
    target: Actor = .decanus,
    lane: Lane = .command,
    iteration: usize = 0,
    objective: []const u8 = "",
    completion_signal: []const u8 = "",
    context: InvocationContext = .{},
    scope: InvocationScope = .{},
    memory: InvocationMemory = .{},
    result: InvocationResult = .{},
    return_to: Actor = .decanus,
};

pub const ApprovalRequest = struct {
    status: ApprovalStatus = .idle,
    kind: ApprovalKind = .read,
    requested_by: Actor = .decanus,
    lane: Lane = .command,
    tool_name: []const u8 = "",
    detail: []const u8 = "",
    reason: []const u8 = "",
    target: []const u8 = "",
};

pub const LoopStep = struct {
    iteration: usize = 0,
    kind: LoopStepKind = .think,
    actor: Actor = .decanus,
    lane: Lane = .command,
    summary: []const u8 = "",
};

pub const StateSnapshot = struct {
    project_name: []const u8 = "UNASSIGNED",
    approval_mode: []const u8 = "",
    global_status: GlobalStatus = .idle,
    runtime_status: RuntimeStatus = .idle,
    loop_status: LoopStatus = .awaiting_initial_prompt,
    current_actor: Actor = .decanus,
    active_tool: ?Actor = null,
    active_lane: Lane = .command,
    approval_status: ApprovalStatus = .idle,
    last_step_kind: LoopStepKind = .think,
    last_step_summary: []const u8 = "",
    current_goal: []const u8 = "",
    last_tool_result: []const u8 = "",
    last_error: []const u8 = "",
    last_log_path: []const u8 = "",
    iteration: usize = 0,
    max_iterations: usize = 0,
    estimated_prompt_chars: usize = 0,
    estimated_prompt_tokens: usize = 0,
    context_window_tokens: usize = 0,
    response_reserve_tokens: usize = 0,
    remaining_context_tokens: usize = 0,
    context_used_percent: usize = 0,
    condensation_count: usize = 0,
    condensed_history_events: usize = 0,
};

pub fn laneForActor(actor: Actor) Lane {
    return switch (actor) {
        .decanus => .command,
        .faber => .backend,
        .artifex => .frontend,
        .architectus => .systems,
        .tesserarius => .qa,
        .explorator => .research,
        .signifer => .brand,
        .praeco => .media,
        .calo => .docs,
        .mulus => .bulk_ops,
    };
}

pub fn actorForLane(lane: Lane) Actor {
    return switch (lane) {
        .command => .decanus,
        .backend => .faber,
        .frontend => .artifex,
        .systems => .architectus,
        .qa => .tesserarius,
        .research => .explorator,
        .brand => .signifer,
        .media => .praeco,
        .docs => .calo,
        .bulk_ops => .mulus,
    };
}

pub fn allowedActionsForActor(actor: Actor) []const []const u8 {
    return switch (actor) {
        .decanus => &.{
            "interpret_mission",
            "invoke_one_specialist",
            "request_runtime_tools",
            "request_approval",
            "ask_user",
            "finish_mission",
        },
        else => &.{
            "execute_assigned_scope",
            "request_runtime_tools",
            "request_approval",
            "return_structured_result",
            "ask_user",
        },
    };
}

pub fn restrictedActionsForActor(actor: Actor) []const []const u8 {
    return switch (actor) {
        .decanus => &.{
            "delegate_control",
            "perform_multi_domain_specialist_work",
            "skip_loop_accounting",
        },
        else => &.{
            "chain_other_specialists",
            "expand_scope",
            "write_canonical_memory",
            "finalize_mission",
        },
    };
}

pub fn approvalKindForToolName(tool_name: []const u8) ApprovalKind {
    if (std.mem.eql(u8, tool_name, "run_command")) return .shell;
    if (std.mem.eql(u8, tool_name, "write_file")) return .write;
    if (std.mem.eql(u8, tool_name, "deploy")) return .deployment;
    return .read;
}

pub fn invocationStatusForResult(status: InvocationResultStatus) InvocationStatus {
    return switch (status) {
        .idle => .idle,
        .complete => .complete,
        .partial => .partial,
        .blocked => .blocked,
    };
}
