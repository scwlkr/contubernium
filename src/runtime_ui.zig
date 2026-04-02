const std = @import("std");
const core = @import("runtime_core.zig");
const model_json = @import("runtime_model_json.zig");
const assets_mod = @import("runtime_assets.zig");
const provider_mod = @import("runtime_provider.zig");
const loop_mod = @import("runtime_loop.zig");

const ProviderConfig = core.ProviderConfig;
const AppState = core.AppState;
const SessionRecord = core.SessionRecord;
const SessionIndex = core.SessionIndex;
const SessionIndexEntry = core.SessionIndexEntry;
const RuntimeUiEvent = core.RuntimeUiEvent;
const RuntimeEventQueue = core.RuntimeEventQueue;
const RuntimeControl = core.RuntimeControl;
const WorkerCommandKind = core.WorkerCommandKind;
const WorkerTask = core.WorkerTask;
const RuntimeHooks = core.RuntimeHooks;
const ChatTone = core.ChatTone;
const HighlightKind = core.HighlightKind;
const TuiSnapshot = core.TuiSnapshot;
const actorName = core.actorName;
const buildStateSnapshot = core.buildStateSnapshot;
const emitLog = core.emitLog;
const emitStateSnapshot = core.emitStateSnapshot;
const eql = core.eql;
const friendlyRuntimeError = core.friendlyRuntimeError;
const freeRuntimeUiEvents = core.freeRuntimeUiEvents;
const freeTuiSnapshot = core.freeTuiSnapshot;
const initializeRuntimeSession = core.initializeRuntimeSession;
const joinArgs = core.joinArgs;
const joinStrings = core.joinStrings;
const pathExists = core.pathExists;
const pollInput = core.pollInput;
const resolvedApprovalMode = core.resolvedApprovalMode;
const resetStateForMission = core.resetStateForMission;
const setOwnedSnapshot = core.setOwnedSnapshot;
const snapshotFromState = core.snapshotFromState;
const stdoutPrint = core.stdoutPrint;
const stderrPrint = core.stderrPrint;
const toneForOutcome = core.toneForOutcome;
const trimAscii = core.trimAscii;
const decodeUtf8Scalar = core.decodeUtf8Scalar;
const containsString = core.containsString;

const parseJson = model_json.parseJson;

const loadConfig = assets_mod.loadConfig;
const loadProjectConfig = assets_mod.loadProjectConfig;
const loadSessionIndex = assets_mod.loadSessionIndex;
const loadSessionRecord = assets_mod.loadSessionRecord;
const loadState = assets_mod.loadState;
const persistSessionMemory = assets_mod.persistSessionMemory;
const saveConfig = assets_mod.saveConfig;
const saveState = assets_mod.saveState;
const runDoctorCheck = assets_mod.runDoctorCheck;
const missionOutcomeSummary = assets_mod.missionOutcomeSummary;
const scaffoldProject = assets_mod.scaffoldProject;
const resolveContuberniumHome = assets_mod.resolveContuberniumHome;
const resolveConfigPath = assets_mod.resolveConfigPath;
const resolveProjectIdentity = assets_mod.resolveProjectIdentity;
const sessionIdIsSafe = assets_mod.sessionIdIsSafe;
const sessionRecordPath = assets_mod.sessionRecordPath;
const initializeRuntimeRunLog = assets_mod.initializeRuntimeRunLog;
const logRuntimeEvent = assets_mod.logRuntimeEvent;

const providerListModels = provider_mod.providerListModels;

const runLoop = loop_mod.runLoop;
const executeStep = loop_mod.executeStep;

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

const MissionComposerRoster = struct {
    models: []const []const u8,
    selected_index: usize,
    note: []const u8,
};

pub const CliSpinnerState = struct {
    mutex: std.Thread.Mutex = .{},
    active: bool = false,
    rendered: bool = false,
    shutdown: bool = false,
    phase: usize = 0,
    actor_len: usize = 0,
    actor_buf: [32]u8 = [_]u8{0} ** 32,
};

pub const CliSpinner = struct {
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

pub fn cmdMissionCompose(allocator: std.mem.Allocator) !void {
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

pub fn cmdMissionStart(allocator: std.mem.Allocator, prompt_args: []const []const u8) !void {
    const mission_prompt = try joinArgs(allocator, prompt_args);
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    try runMissionInternal(allocator, mission_prompt, spinner.hooks());
    const config = try loadProjectConfig(allocator);
    const state = try loadState(allocator, config.paths.state_file);
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

pub fn cmdMissionStep(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    if (state.mission.initial_prompt.len == 0) return error.MissionNotInitialized;
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    try startRunFromState(allocator, config, &state, "mission_step", "single-step execution requested", "", true, spinner.hooks());
    _ = try executeStep(allocator, config, &state, spinner.hooks());
    try finishRunState(allocator, config, &state, "mission_step", spinner.hooks());
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

pub fn cmdMissionContinue(allocator: std.mem.Allocator) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    if (state.mission.initial_prompt.len == 0) return error.MissionNotInitialized;
    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    try startRunFromState(allocator, config, &state, "mission_continue", "active session resume requested", "", true, spinner.hooks());
    try runLoop(allocator, config, &state, spinner.hooks());
    try finishRunState(allocator, config, &state, "mission_continue", spinner.hooks());
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

pub fn cmdSessionsList(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const restore_cwd = try maybeChangeProjectRoot(allocator, if (args.len > 0) args[0] else null);
    defer restoreProjectRoot(allocator, restore_cwd);

    try scaffoldProject(allocator);
    const config = try loadProjectConfig(allocator);
    const index = try loadSessionIndex(allocator, config.paths.session_index_file);
    try stdoutPrint("{s}\n", .{try renderSessionIndex(allocator, index)});
}

pub fn cmdSessionsShow(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const session_id = trimAscii(args[0]);
    if (!sessionIdIsSafe(session_id)) return error.InvalidSessionId;

    const restore_cwd = try maybeChangeProjectRoot(allocator, if (args.len > 1) args[1] else null);
    defer restoreProjectRoot(allocator, restore_cwd);

    try scaffoldProject(allocator);
    const config = try loadProjectConfig(allocator);
    const record = try loadSessionRecordForProject(allocator, config, session_id);
    try stdoutPrint("{s}\n", .{try renderSessionRecord(allocator, record)});
}

pub fn cmdSessionsResume(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const session_id = trimAscii(args[0]);
    if (!sessionIdIsSafe(session_id)) return error.InvalidSessionId;

    const restore_cwd = try maybeChangeProjectRoot(allocator, if (args.len > 1) args[1] else null);
    defer restoreProjectRoot(allocator, restore_cwd);

    try scaffoldProject(allocator);
    const config = try loadProjectConfig(allocator);
    const record = try loadSessionRecordForProject(allocator, config, session_id);
    var state = record.state_snapshot;

    if (state.runtime_session.session_id.len == 0) state.runtime_session.session_id = record.session_id;
    if (state.runtime_session.session_started_at.len == 0) state.runtime_session.session_started_at = record.created_at;
    state.runtime_session.resume_count = if (state.runtime_session.resume_count >= record.resume_count)
        state.runtime_session.resume_count
    else
        record.resume_count;

    if (state.mission.initial_prompt.len == 0) return error.MissionNotInitialized;

    if (state.global_status == .complete or state.runtime_session.status == .complete) {
        try persistSessionMemory(allocator, config, &state, "sessions_resume");
        try saveState(allocator, config.paths.state_file, state);
        try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
        return;
    }

    var spinner = try CliSpinner.init(allocator);
    defer spinner.deinit();
    try startRunFromState(allocator, config, &state, "sessions_resume", "stored session resume requested", "", true, spinner.hooks());
    try runLoop(allocator, config, &state, spinner.hooks());
    try finishRunState(allocator, config, &state, "sessions_resume", spinner.hooks());
    try stdoutPrint("{s}\n", .{try renderCliMissionOutcome(allocator, state)});
}

pub fn cmdSessionsApprovals(allocator: std.mem.Allocator, enabled: bool) !void {
    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);
    if (state.mission.initial_prompt.len == 0 and state.runtime_session.session_id.len == 0) {
        return error.MissionNotInitialized;
    }

    state.runtime_session.approval_bypass_enabled = enabled;
    state.runtime_session.approval_mode = resolvedApprovalMode(config.policy.approval_mode, enabled);
    initializeRuntimeSession(allocator, &state, config);
    try persistSessionMemory(allocator, config, &state, "sessions_approvals");
    try saveState(allocator, config.paths.state_file, state);
    try stdoutPrint(
        "session approvals {s} for {s}\n",
        .{
            if (enabled) "enabled" else "disabled",
            if (state.runtime_session.session_id.len > 0) state.runtime_session.session_id else "pending-session",
        },
    );
}

pub fn cmdUi(allocator: std.mem.Allocator) !void {
    try scaffoldProject(allocator);
    try launchOpenTuiFrontend(allocator);
}

pub fn cmdUiBridge(allocator: std.mem.Allocator) !void {
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

fn loadMissionComposerRoster(allocator: std.mem.Allocator, provider: ProviderConfig) !MissionComposerRoster {
    var collected: std.ArrayList([]const u8) = .empty;
    errdefer collected.deinit(allocator);

    var note: []const u8 = "";
    const configured_model = trimAscii(provider.model);

    const listed_models = providerListModels(allocator, provider) catch |err| blk: {
        note = try friendlyRuntimeError(allocator, err);
        break :blk &.{};
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
        try writeCliMissionSection(writer, styled, "status", status_text, interactive_color_blue, false);
        return try buffer.toOwnedSlice(allocator);
    }

    const status_text = try std.fmt.allocPrint(allocator, "status: {s}\ncurrent actor: {s}\niteration: {d}", .{
        @tagName(state.global_status),
        actorName(state.current_actor),
        state.agent_loop.iteration,
    });
    defer allocator.free(status_text);
    try writeCliMissionSection(writer, styled, "status", status_text, interactive_color_blue, false);
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

fn runMissionInternal(allocator: std.mem.Allocator, mission_prompt: []const u8, hooks: RuntimeHooks) !void {
    try scaffoldProject(allocator);

    const config = try loadProjectConfig(allocator);
    var state = try loadState(allocator, config.paths.state_file);

    resetStateForMission(&state, mission_prompt);
    try startRunFromState(allocator, config, &state, "mission", "mission initialized", mission_prompt, false, hooks);

    try runLoop(allocator, config, &state, hooks);
    try finishRunState(allocator, config, &state, "mission", hooks);
}

fn startRunFromState(
    allocator: std.mem.Allocator,
    config: core.AppConfig,
    state: *AppState,
    command_label: []const u8,
    summary: []const u8,
    input_text: []const u8,
    count_as_resume: bool,
    hooks: RuntimeHooks,
) !void {
    if (count_as_resume and state.runtime_session.session_id.len > 0) {
        state.runtime_session.resume_count += 1;
    }
    initializeRuntimeSession(allocator, state, config);
    try initializeRuntimeRunLog(allocator, config, state, command_label);
    try persistSessionMemory(allocator, config, state, command_label);
    try logRuntimeEvent(allocator, config, state, .{
        .actor = .decanus,
        .lane = .command,
        .action = "run_started",
        .status = "running",
        .summary = summary,
        .input = input_text,
        .include_snapshot = true,
    });
    try saveState(allocator, config.paths.state_file, state.*);
    emitStateSnapshot(hooks, config, state.*);
}

fn finishRunState(
    allocator: std.mem.Allocator,
    config: core.AppConfig,
    state: *AppState,
    command_label: []const u8,
    hooks: RuntimeHooks,
) !void {
    try persistSessionMemory(allocator, config, state, command_label);
    try saveState(allocator, config.paths.state_file, state.*);
    emitStateSnapshot(hooks, config, state.*);
}

fn maybeChangeProjectRoot(allocator: std.mem.Allocator, project_root: ?[]const u8) !?[]const u8 {
    const target = project_root orelse return null;
    const trimmed = trimAscii(target);
    if (trimmed.len == 0) return null;

    const original_cwd = try std.process.getCwdAlloc(allocator);
    errdefer allocator.free(original_cwd);
    try std.posix.chdir(trimmed);
    return original_cwd;
}

fn restoreProjectRoot(allocator: std.mem.Allocator, original_cwd: ?[]const u8) void {
    if (original_cwd) |cwd| {
        std.posix.chdir(cwd) catch {};
        allocator.free(cwd);
    }
}

fn loadSessionRecordForProject(allocator: std.mem.Allocator, config: core.AppConfig, session_id: []const u8) !SessionRecord {
    const record_path = try sessionRecordPath(allocator, config.paths.sessions_dir, session_id);
    defer allocator.free(record_path);
    const record = try loadSessionRecord(allocator, record_path);

    const identity = try resolveProjectIdentity(allocator);
    defer allocator.free(identity.project_root);
    defer allocator.free(identity.project_id);
    defer allocator.free(identity.project_label);

    if (record.project_id.len > 0 and !eql(record.project_id, identity.project_id)) {
        return error.SessionProjectMismatch;
    }
    return record;
}

fn renderSessionIndex(allocator: std.mem.Allocator, index: SessionIndex) ![]const u8 {
    if (index.sessions.len == 0) return try allocator.dupe(u8, "no sessions recorded");

    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    for (index.sessions, 0..) |session, index_value| {
        const marker = if (eql(session.session_id, index.current_session_id)) "*" else " ";
        try writer.print(
            "{s} {s}  {s}  {s}  {s}\n",
            .{
                marker,
                session.session_id,
                if (session.status.len > 0) session.status else "unknown",
                if (session.updated_at.len > 0) session.updated_at else "0",
                if (session.model.len > 0) session.model else "unassigned-model",
            },
        );
        if (session.mission_prompt_excerpt.len > 0) {
            try writer.print("  {s}\n", .{session.mission_prompt_excerpt});
        }
        if (index_value + 1 < index.sessions.len) try writer.writeAll("\n");
    }

    return try buffer.toOwnedSlice(allocator);
}

fn renderSessionRecord(allocator: std.mem.Allocator, record: SessionRecord) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    try writer.print("session: {s}\n", .{record.session_id});
    try writer.print("project: {s} ({s})\n", .{ record.project_label, record.project_id });
    try writer.print("status: {s}\n", .{record.status});
    try writer.print("command: {s}\n", .{record.command});
    try writer.print("created: {s}\n", .{record.created_at});
    try writer.print("updated: {s}\n", .{record.updated_at});
    try writer.print("provider: {s}\n", .{record.provider});
    try writer.print("model: {s}\n", .{record.model});
    try writer.print("approval mode: {s}\n", .{record.approval_mode});
    try writer.print("approval bypass: {s}\n", .{if (record.approval_bypass_enabled) "on" else "off"});
    try writer.print("resume count: {d}\n", .{record.resume_count});
    try writer.print("last log: {s}\n", .{if (record.last_log_path.len > 0) record.last_log_path else "none"});

    if (record.mission_prompt.len > 0) {
        try writer.print("\nmission prompt\n{s}\n", .{record.mission_prompt});
    }
    if (record.state_snapshot.mission.final_response.len > 0) {
        try writer.print("\nfinal response\n{s}\n", .{record.state_snapshot.mission.final_response});
    } else if (record.last_error.len > 0) {
        try writer.print("\nlast error\n{s}\n", .{record.last_error});
    }
    if (record.run_log_paths.len > 0) {
        try writer.writeAll("\nrun logs\n");
        for (record.run_log_paths) |path| {
            try writer.print("{s}\n", .{path});
        }
    }

    return try buffer.toOwnedSlice(allocator);
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
            if (state.mission.initial_prompt.len == 0) {
                emitLog(hooks, .danger, "", "Resume Failed", "no active session is available to resume", .plain);
                return;
            }
            startRunFromState(task.allocator, config, &state, "resume", "active session resume requested", "", true, hooks) catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            runLoop(task.allocator, config, &state, hooks) catch |err| {
                emitLog(hooks, .danger, "", "Resume Failed", friendlyRuntimeError(task.allocator, err) catch @errorName(err), .plain);
                return;
            };
            finishRunState(task.allocator, config, &state, "resume", hooks) catch {};
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

fn bridgeSetSessionApprovals(bridge: *OpenTuiBridge, enabled: bool) !void {
    const config = try loadProjectConfig(bridge.allocator);
    var state = try loadState(bridge.allocator, config.paths.state_file);
    if (state.mission.initial_prompt.len == 0 and state.runtime_session.session_id.len == 0) {
        try bridgeEmitLog(.warning, "runtime", "No Session", "start or resume a session before changing approval bypass", .plain);
        return;
    }

    state.runtime_session.approval_bypass_enabled = enabled;
    state.runtime_session.approval_mode = resolvedApprovalMode(config.policy.approval_mode, enabled);
    initializeRuntimeSession(bridge.allocator, &state, config);
    try persistSessionMemory(bridge.allocator, config, &state, "sessions_approvals");
    try saveState(bridge.allocator, config.paths.state_file, state);
    try bridgeEmitLog(
        .success,
        "runtime",
        "Approval Mode Updated",
        if (enabled) "session approval bypass enabled" else "session approval bypass disabled",
        .plain,
    );
    try bridgeRefreshSnapshot(bridge);
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

    if (eql(command.type, "approvals")) {
        if (command.approved) |approved| {
            try bridgeSetSessionApprovals(bridge, approved);
        } else {
            try bridgeEmitLog(.warning, "runtime", "Usage", "approvals commands require an approved boolean", .plain);
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
