const std = @import("std");

pub const Action = enum {
    init,
    doctor,
    models_list,
    mission_compose,
    mission_start,
    mission_continue,
    mission_step,
    ui,
    ui_bridge,
};

const ArgSpec = struct {
    name: []const u8,
    description: []const u8,
};

const FlagSpec = struct {
    syntax: []const u8,
    description: []const u8,
};

const Example = struct {
    command: []const u8,
    description: []const u8,
};

pub const Command = struct {
    name: []const u8,
    path_label: []const u8,
    summary: []const u8,
    description: []const u8 = "",
    usage: []const []const u8 = &.{},
    args: []const ArgSpec = &.{},
    flags: []const FlagSpec = help_flags[0..],
    examples: []const Example = &.{},
    children: []const *const Command = &.{},
    action: ?Action = null,
    hidden: bool = false,
    suggestable: bool = true,
    help_exposed: bool = true,
    canonical: ?*const Command = null,
};

pub const Invocation = struct {
    command: *const Command,
    action: Action,
    args: []const []const u8,
};

const FailureKind = enum {
    unknown_command,
    unknown_help_topic,
    missing_subcommand,
    invalid_flag,
    missing_argument,
    unexpected_argument,
};

pub const Failure = struct {
    kind: FailureKind,
    command: *const Command,
    token: []const u8 = "",
    suggestion: ?*const Command = null,
    argument: []const u8 = "",
};

pub const Decision = union(enum) {
    action: Invocation,
    help: *const Command,
    failure: Failure,
};

const help_flags = [_]FlagSpec{
    .{ .syntax = "-h, --help", .description = "Show help." },
};

const mission_prompt_args = [_]ArgSpec{
    .{ .name = "<prompt>", .description = "Mission objective to hand to decanus." },
};

const root_usage = [_][]const u8{
    "contubernium <command>",
    "contubernium mission",
    "contubernium ui",
    "contubernium mission start \"<prompt>\"",
};

const mission_usage = [_][]const u8{
    "contubernium mission",
    "contubernium mission <command>",
};

const mission_start_usage = [_][]const u8{
    "contubernium mission start <prompt>",
};

const mission_continue_usage = [_][]const u8{
    "contubernium mission continue",
};

const mission_step_usage = [_][]const u8{
    "contubernium mission step",
};

const ui_usage = [_][]const u8{
    "contubernium ui",
};

const init_usage = [_][]const u8{
    "contubernium init",
};

const doctor_usage = [_][]const u8{
    "contubernium doctor",
};

const models_usage = [_][]const u8{
    "contubernium models",
};

const ui_examples = [_]Example{
    .{ .command = "contubernium ui", .description = "Open the terminal UI." },
    .{ .command = "contubernium", .description = "Open the terminal UI with the default shortcut." },
};

const init_examples = [_]Example{
    .{ .command = "contubernium init", .description = "Create or repair the local project scaffold." },
};

const doctor_examples = [_]Example{
    .{ .command = "contubernium doctor", .description = "Check provider connectivity and runtime prerequisites." },
};

const models_examples = [_]Example{
    .{ .command = "contubernium models", .description = "List models reported by the active provider." },
};

const mission_examples = [_]Example{
    .{ .command = "contubernium mission", .description = "Choose a model, type a mission, and start it interactively." },
    .{ .command = "contubernium mission start \"Add a release checklist to the docs\"", .description = "Start a new mission from the command line." },
    .{ .command = "contubernium mission continue", .description = "Continue the current mission after a block or interruption." },
    .{ .command = "contubernium mission step", .description = "Advance one loop step and stop." },
};

const mission_start_examples = [_]Example{
    .{ .command = "contubernium mission start \"Add a release checklist to the docs\"", .description = "Start a new mission from a concrete objective." },
    .{ .command = "contubernium mission start \"Audit the CLI docs and remove stale commands\"", .description = "Use scripted control instead of the terminal UI." },
};

const mission_continue_examples = [_]Example{
    .{ .command = "contubernium mission continue", .description = "Continue the mission stored in .contubernium/state.json." },
};

const mission_step_examples = [_]Example{
    .{ .command = "contubernium mission step", .description = "Execute exactly one loop step for inspection or debugging." },
};

const root_examples = [_]Example{
    .{ .command = "contubernium", .description = "Open the terminal UI." },
    .{ .command = "contubernium init", .description = "Bootstrap the current project." },
    .{ .command = "contubernium mission", .description = "Choose a model, type a mission, and start it interactively." },
    .{ .command = "contubernium mission start \"Add a release checklist to the docs\"", .description = "Start a new mission from the command line." },
    .{ .command = "contubernium mission continue", .description = "Continue the current mission after a block or interruption." },
    .{ .command = "contubernium models", .description = "Show models available through the active provider." },
};

const ui_command = Command{
    .name = "ui",
    .path_label = "ui",
    .summary = "Open the interactive terminal.",
    .description = "Launch the OpenTUI interface. The project scaffold is created if it is missing.",
    .usage = ui_usage[0..],
    .examples = ui_examples[0..],
    .action = .ui,
};

const init_command = Command{
    .name = "init",
    .path_label = "init",
    .summary = "Create or repair the .contubernium scaffold.",
    .description = "Write the canonical local runtime files into the current directory without launching the UI or running a mission.",
    .usage = init_usage[0..],
    .examples = init_examples[0..],
    .action = .init,
};

const doctor_command = Command{
    .name = "doctor",
    .path_label = "doctor",
    .summary = "Check provider connectivity and runtime state.",
    .description = "Verify the local runtime can load configuration, read state, and talk to the active model provider.",
    .usage = doctor_usage[0..],
    .examples = doctor_examples[0..],
    .action = .doctor,
};

const mission_start_command = Command{
    .name = "start",
    .path_label = "mission start",
    .summary = "Start a new mission and run until complete or blocked.",
    .description = "Reset the current mission state, write the new prompt, and hand control to decanus.",
    .usage = mission_start_usage[0..],
    .args = mission_prompt_args[0..],
    .examples = mission_start_examples[0..],
    .action = .mission_start,
};

const mission_continue_command = Command{
    .name = "continue",
    .path_label = "mission continue",
    .summary = "Continue the current mission from state.",
    .description = "Resume execution from .contubernium/state.json and run until completion or the next blocking condition.",
    .usage = mission_continue_usage[0..],
    .examples = mission_continue_examples[0..],
    .action = .mission_continue,
};

const mission_step_command = Command{
    .name = "step",
    .path_label = "mission step",
    .summary = "Execute exactly one loop step.",
    .description = "Advance one turn through the commander loop and stop. Use this when you need tight control or inspection.",
    .usage = mission_step_usage[0..],
    .examples = mission_step_examples[0..],
    .action = .mission_step,
};

const mission_run_alias = Command{
    .name = "run",
    .path_label = "run",
    .summary = "",
    .hidden = true,
    .canonical = &mission_start_command,
};

const mission_resume_alias = Command{
    .name = "resume",
    .path_label = "resume",
    .summary = "",
    .hidden = true,
    .canonical = &mission_continue_command,
};

const mission_children = [_]*const Command{
    &mission_start_command,
    &mission_continue_command,
    &mission_step_command,
    &mission_run_alias,
    &mission_resume_alias,
};

const mission_command = Command{
    .name = "mission",
    .path_label = "mission",
    .summary = "Compose a mission interactively, or use subcommands for direct control.",
    .description = "Launch the plain terminal mission composer, or use subcommands when you want explicit scripted control.",
    .usage = mission_usage[0..],
    .examples = mission_examples[0..],
    .children = mission_children[0..],
    .action = .mission_compose,
};

const models_list_alias = Command{
    .name = "list",
    .path_label = "models list",
    .summary = "List models reported by the active provider.",
    .description = "Legacy alias for `contubernium models`.",
    .usage = &.{"contubernium models list"},
    .examples = &.{.{ .command = "contubernium models list", .description = "Legacy alias for `contubernium models`." }},
    .hidden = true,
    .action = .models_list,
};

const models_children = [_]*const Command{
    &models_list_alias,
};

const models_command = Command{
    .name = "models",
    .path_label = "models",
    .summary = "List models reported by the active provider.",
    .description = "Query the configured provider and print the models it currently exposes.",
    .usage = models_usage[0..],
    .examples = models_examples[0..],
    .children = models_children[0..],
    .action = .models_list,
};

const root_run_alias = Command{
    .name = "run",
    .path_label = "run",
    .summary = "",
    .hidden = true,
    .canonical = &mission_start_command,
};

const root_resume_alias = Command{
    .name = "resume",
    .path_label = "resume",
    .summary = "",
    .hidden = true,
    .canonical = &mission_continue_command,
};

const root_step_alias = Command{
    .name = "step",
    .path_label = "step",
    .summary = "",
    .hidden = true,
    .canonical = &mission_step_command,
};

const root_chat_alias = Command{
    .name = "chat",
    .path_label = "chat",
    .summary = "",
    .hidden = true,
    .canonical = &ui_command,
};

const ui_bridge_command = Command{
    .name = "ui-bridge",
    .path_label = "ui-bridge",
    .summary = "",
    .hidden = true,
    .suggestable = false,
    .help_exposed = false,
    .action = .ui_bridge,
};

const root_children = [_]*const Command{
    &ui_command,
    &init_command,
    &mission_command,
    &doctor_command,
    &models_command,
    &root_run_alias,
    &root_resume_alias,
    &root_step_alias,
    &root_chat_alias,
    &ui_bridge_command,
};

const root_command = Command{
    .name = "contubernium",
    .path_label = "",
    .summary = "Commander-led local runtime for structured software execution.",
    .description = "Use the terminal UI for interactive work, or use mission commands when you want explicit scripted control.",
    .usage = root_usage[0..],
    .examples = root_examples[0..],
    .children = root_children[0..],
};

const RootGroup = struct {
    title: []const u8,
    entries: []const *const Command,
};

const start_group_entries = [_]*const Command{
    &ui_command,
    &init_command,
};

const mission_group_entries = [_]*const Command{
    &mission_command,
    &mission_start_command,
    &mission_continue_command,
    &mission_step_command,
};

const runtime_group_entries = [_]*const Command{
    &doctor_command,
    &models_command,
};

const root_groups = [_]RootGroup{
    .{ .title = "Start", .entries = start_group_entries[0..] },
    .{ .title = "Mission Control", .entries = mission_group_entries[0..] },
    .{ .title = "Runtime", .entries = runtime_group_entries[0..] },
};

pub fn parse(argv: []const []const u8) Decision {
    if (argv.len == 0) {
        return .{ .action = .{
            .command = &ui_command,
            .action = .ui,
            .args = &.{},
        } };
    }

    if (isHelpToken(argv[0])) return resolveHelp(argv[1..]);
    return resolveAction(argv);
}

pub fn renderHelp(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    const target = effectiveCommand(command);
    if (target == &root_command) return renderRootHelp(allocator);
    return renderCommandHelp(allocator, target);
}

pub fn renderFailure(allocator: std.mem.Allocator, failure: Failure) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    const target = effectiveCommand(failure.command);
    const usage = try formatUsageName(allocator, target);
    defer allocator.free(usage);
    const help = try formatHelpHint(allocator, target);
    defer allocator.free(help);

    switch (failure.kind) {
        .unknown_command => {
            if (target == &root_command) {
                try writer.print("unknown command `{s}`", .{failure.token});
            } else {
                try writer.print("unknown subcommand `{s}` for `{s}`", .{ failure.token, usage });
            }
        },
        .unknown_help_topic => {
            if (target == &root_command) {
                try writer.print("unknown help topic `{s}`", .{failure.token});
            } else {
                try writer.print("unknown help topic `{s}` for `{s}`", .{ failure.token, usage });
            }
        },
        .missing_subcommand => {
            try writer.print("missing subcommand for `{s}`", .{usage});
            const subcommands = try visibleSubcommandList(allocator, target);
            defer allocator.free(subcommands);
            if (subcommands.len > 0) {
                try writer.print("\nAvailable subcommands: {s}", .{subcommands});
            }
        },
        .invalid_flag => {
            try writer.print("unknown flag `{s}` for `{s}`", .{ failure.token, usage });
        },
        .missing_argument => {
            try writer.print("missing {s} for `{s}`", .{ failure.argument, usage });
        },
        .unexpected_argument => {
            try writer.print("unexpected argument `{s}` for `{s}`", .{ failure.token, usage });
        },
    }

    if (failure.suggestion) |suggestion| {
        const suggestion_path = try formatDisplayPath(allocator, effectiveCommand(suggestion));
        defer allocator.free(suggestion_path);
        try writer.print("\nDid you mean `{s}`?", .{suggestion_path});
    }

    try writer.print("\nSee `{s}`.", .{help});
    return try buffer.toOwnedSlice(allocator);
}

fn resolveAction(tokens: []const []const u8) Decision {
    var current: *const Command = &root_command;
    var index: usize = 0;

    while (index < tokens.len) {
        const token = tokens[index];
        const target = effectiveCommand(current);

        if (isHelpToken(token)) {
            if (!target.help_exposed) {
                return .{ .failure = .{
                    .kind = .unknown_help_topic,
                    .command = &root_command,
                    .token = current.name,
                } };
            }
            return .{ .help = target };
        }

        if (findChild(current, token)) |child| {
            current = child;
            index += 1;
            continue;
        }

        if (target.action != null) break;

        if (isFlag(token)) {
            return .{ .failure = .{
                .kind = .invalid_flag,
                .command = target,
                .token = token,
            } };
        }

        return .{ .failure = .{
            .kind = .unknown_command,
            .command = target,
            .token = token,
            .suggestion = suggestChild(current, token),
        } };
    }

    const target = effectiveCommand(current);
    if (target.action == null) {
        return .{ .failure = .{
            .kind = .missing_subcommand,
            .command = target,
        } };
    }

    return validateInvocation(target, tokens[index..]);
}

fn resolveHelp(tokens: []const []const u8) Decision {
    if (tokens.len == 0) return .{ .help = &root_command };

    var current: *const Command = &root_command;
    var index: usize = 0;

    while (index < tokens.len) : (index += 1) {
        const token = tokens[index];
        if (isHelpToken(token)) break;

        if (findChild(current, token)) |child| {
            current = child;
            continue;
        }

        return .{ .failure = .{
            .kind = .unknown_help_topic,
            .command = effectiveCommand(current),
            .token = token,
            .suggestion = suggestChild(current, token),
        } };
    }

    const target = effectiveCommand(current);
    if (!target.help_exposed) {
        return .{ .failure = .{
            .kind = .unknown_help_topic,
            .command = &root_command,
            .token = current.name,
        } };
    }

    return .{ .help = target };
}

fn validateInvocation(command: *const Command, args: []const []const u8) Decision {
    const action = command.action.?;
    switch (action) {
        .mission_start => {
            if (args.len == 0) {
                return .{ .failure = .{
                    .kind = .missing_argument,
                    .command = command,
                    .argument = "<prompt>",
                } };
            }

            if (args.len == 1 and isHelpToken(args[0])) return .{ .help = command };
            if (isFlag(args[0])) {
                return .{ .failure = .{
                    .kind = .invalid_flag,
                    .command = command,
                    .token = args[0],
                } };
            }

            return .{ .action = .{
                .command = command,
                .action = action,
                .args = args,
            } };
        },
        else => {
            if (args.len == 0) {
                return .{ .action = .{
                    .command = command,
                    .action = action,
                    .args = args,
                } };
            }

            if (isHelpToken(args[0])) return .{ .help = command };
            if (isFlag(args[0])) {
                return .{ .failure = .{
                    .kind = .invalid_flag,
                    .command = command,
                    .token = args[0],
                } };
            }

            return .{ .failure = .{
                .kind = .unexpected_argument,
                .command = command,
                .token = args[0],
            } };
        },
    }
}

fn renderRootHelp(allocator: std.mem.Allocator) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);

    try writer.writeAll("Contubernium\n");
    try writer.writeAll(root_command.summary);
    try writer.writeAll("\n");
    try writer.writeAll(root_command.description);
    try writer.writeAll("\n\nUsage:\n");
    try writeUsageLines(writer, root_command.usage);

    for (root_groups) |group| {
        try writer.print("\n{s}:\n", .{group.title});
        try writeCommandRows(writer, group.entries, .path);
    }

    try writer.writeAll("\nFlags:\n");
    try writeFlagRows(writer, root_command.flags);

    try writer.writeAll("\nExamples:\n");
    try writeExamples(writer, root_command.examples);

    try writer.writeAll("\n\nHelp:\n");
    try writer.writeAll("  contubernium help <command>\n");
    try writer.writeAll("  contubernium <command> --help");

    return try buffer.toOwnedSlice(allocator);
}

fn renderCommandHelp(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    const title = try formatDisplayPath(allocator, command);
    defer allocator.free(title);

    try writer.print("{s}\n", .{title});
    try writer.writeAll(command.summary);
    if (command.description.len > 0) {
        try writer.writeAll("\n");
        try writer.writeAll(command.description);
    }

    try writer.writeAll("\n\nUsage:\n");
    try writeUsageLines(writer, command.usage);

    const visible_children = countVisibleChildren(command);
    if (visible_children > 0) {
        try writer.writeAll("\nSubcommands:\n");
        try writeVisibleChildren(writer, command);
    }

    if (command.args.len > 0) {
        try writer.writeAll("\nArguments:\n");
        try writeArgRows(writer, command.args);
    }

    if (command.flags.len > 0) {
        try writer.writeAll("\nFlags:\n");
        try writeFlagRows(writer, command.flags);
    }

    if (command.examples.len > 0) {
        try writer.writeAll("\nExamples:\n");
        try writeExamples(writer, command.examples);
    }

    return try buffer.toOwnedSlice(allocator);
}

const LabelMode = enum {
    name,
    path,
};

fn writeUsageLines(writer: anytype, lines: []const []const u8) !void {
    for (lines) |line| {
        try writer.print("  {s}\n", .{line});
    }
}

fn writeExamples(writer: anytype, examples: []const Example) !void {
    for (examples, 0..) |example, index| {
        try writer.print("  {s}\n", .{example.command});
        try writer.print("    {s}", .{example.description});
        if (index + 1 < examples.len) try writer.writeAll("\n");
    }
}

fn writeArgRows(writer: anytype, args: []const ArgSpec) !void {
    const width = maxArgWidth(args);
    for (args) |arg| {
        try writer.print("  {s}", .{arg.name});
        try writePadding(writer, width - arg.name.len + 2);
        try writer.print("{s}\n", .{arg.description});
    }
}

fn writeFlagRows(writer: anytype, flags: []const FlagSpec) !void {
    const width = maxFlagWidth(flags);
    for (flags) |flag| {
        try writer.print("  {s}", .{flag.syntax});
        try writePadding(writer, width - flag.syntax.len + 2);
        try writer.print("{s}\n", .{flag.description});
    }
}

fn writeCommandRows(writer: anytype, commands: []const *const Command, mode: LabelMode) !void {
    const width = maxCommandLabelWidth(commands, mode);
    for (commands) |command| {
        const target = effectiveCommand(command);
        const label = switch (mode) {
            .name => target.name,
            .path => target.path_label,
        };
        try writer.print("  {s}", .{label});
        try writePadding(writer, width - label.len + 2);
        try writer.print("{s}\n", .{target.summary});
    }
}

fn writeVisibleChildren(writer: anytype, command: *const Command) !void {
    var visible: [16]*const Command = undefined;
    var count: usize = 0;
    for (command.children) |child| {
        const target = effectiveCommand(child);
        if (child.hidden or !target.help_exposed) continue;
        visible[count] = target;
        count += 1;
    }
    try writeCommandRows(writer, visible[0..count], .name);
}

fn writePadding(writer: anytype, count: usize) !void {
    var index: usize = 0;
    while (index < count) : (index += 1) {
        try writer.writeByte(' ');
    }
}

fn maxArgWidth(args: []const ArgSpec) usize {
    var width: usize = 0;
    for (args) |arg| width = @max(width, arg.name.len);
    return width;
}

fn maxFlagWidth(flags: []const FlagSpec) usize {
    var width: usize = 0;
    for (flags) |flag| width = @max(width, flag.syntax.len);
    return width;
}

fn maxCommandLabelWidth(commands: []const *const Command, mode: LabelMode) usize {
    var width: usize = 0;
    for (commands) |command| {
        const target = effectiveCommand(command);
        const label = switch (mode) {
            .name => target.name,
            .path => target.path_label,
        };
        width = @max(width, label.len);
    }
    return width;
}

fn countVisibleChildren(command: *const Command) usize {
    var count: usize = 0;
    for (command.children) |child| {
        const target = effectiveCommand(child);
        if (child.hidden or !target.help_exposed) continue;
        count += 1;
    }
    return count;
}

fn visibleSubcommandList(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    var buffer: std.ArrayList(u8) = .empty;
    errdefer buffer.deinit(allocator);
    const writer = buffer.writer(allocator);
    var wrote_any = false;

    for (command.children) |child| {
        const target = effectiveCommand(child);
        if (child.hidden or !target.help_exposed) continue;
        if (wrote_any) try writer.writeAll(", ");
        try writer.writeAll(target.name);
        wrote_any = true;
    }

    return try buffer.toOwnedSlice(allocator);
}

fn effectiveCommand(command: *const Command) *const Command {
    return command.canonical orelse command;
}

fn findChild(command: *const Command, token: []const u8) ?*const Command {
    const target = effectiveCommand(command);
    for (target.children) |child| {
        if (std.mem.eql(u8, child.name, token)) return child;
    }
    return null;
}

fn suggestChild(command: *const Command, token: []const u8) ?*const Command {
    const target = effectiveCommand(command);
    var best: ?*const Command = null;
    var best_score: usize = std.math.maxInt(usize);

    for (target.children) |child| {
        if (!child.suggestable) continue;
        const score = suggestionScore(token, child.name);
        if (score < best_score) {
            best = effectiveCommand(child);
            best_score = score;
        }
    }

    if (best) |_| {
        const limit = @max(@as(usize, 2), (token.len + 1) / 2);
        if (best_score <= limit) return best;
    }

    return null;
}

fn suggestionScore(input: []const u8, candidate: []const u8) usize {
    if (std.mem.eql(u8, input, candidate)) return 0;
    if (std.mem.startsWith(u8, candidate, input) or std.mem.startsWith(u8, input, candidate)) {
        return if (candidate.len > input.len) candidate.len - input.len else input.len - candidate.len;
    }
    return levenshteinDistance(input, candidate);
}

fn levenshteinDistance(a: []const u8, b: []const u8) usize {
    if (a.len == 0) return b.len;
    if (b.len == 0) return a.len;
    if (b.len + 1 > 64) return @max(a.len, b.len);

    var previous: [64]usize = undefined;
    var current: [64]usize = undefined;

    var index: usize = 0;
    while (index <= b.len) : (index += 1) {
        previous[index] = index;
    }

    var row: usize = 0;
    while (row < a.len) : (row += 1) {
        current[0] = row + 1;
        var column: usize = 0;
        while (column < b.len) : (column += 1) {
            const substitution_cost: usize = if (a[row] == b[column]) 0 else 1;
            current[column + 1] = @min(
                @min(current[column] + 1, previous[column + 1] + 1),
                previous[column] + substitution_cost,
            );
        }

        var swap_index: usize = 0;
        while (swap_index <= b.len) : (swap_index += 1) {
            previous[swap_index] = current[swap_index];
        }
    }

    return previous[b.len];
}

fn isHelpToken(token: []const u8) bool {
    return std.mem.eql(u8, token, "help") or
        std.mem.eql(u8, token, "-h") or
        std.mem.eql(u8, token, "--help");
}

fn isFlag(token: []const u8) bool {
    return token.len > 0 and token[0] == '-';
}

fn formatUsageName(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    return formatDisplayPath(allocator, command);
}

fn formatDisplayPath(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    if (command == &root_command) return try allocator.dupe(u8, "contubernium");
    return try std.fmt.allocPrint(allocator, "contubernium {s}", .{command.path_label});
}

fn formatHelpHint(allocator: std.mem.Allocator, command: *const Command) ![]const u8 {
    if (command == &root_command) return try allocator.dupe(u8, "contubernium help");
    return try std.fmt.allocPrint(allocator, "contubernium help {s}", .{command.path_label});
}

test "parse defaults to the ui command" {
    const testing = std.testing;
    const decision = parse(&.{});
    switch (decision) {
        .action => |invocation| try testing.expectEqual(Action.ui, invocation.action),
        else => return error.UnexpectedValue,
    }
}

test "parse routes mission aliases to canonical commands" {
    const testing = std.testing;
    const decision = parse(&.{ "run", "Add", "docs" });
    switch (decision) {
        .action => |invocation| {
            try testing.expectEqual(Action.mission_start, invocation.action);
            try testing.expectEqualStrings("mission start", invocation.command.path_label);
            try testing.expectEqual(@as(usize, 2), invocation.args.len);
        },
        else => return error.UnexpectedValue,
    }
}

test "parse accepts models as the public command" {
    const testing = std.testing;
    const decision = parse(&.{ "models" });
    switch (decision) {
        .action => |invocation| {
            try testing.expectEqual(Action.models_list, invocation.action);
            try testing.expectEqualStrings("models", invocation.command.path_label);
        },
        else => return error.UnexpectedValue,
    }
}

test "parse accepts legacy models list alias" {
    const testing = std.testing;
    const decision = parse(&.{ "models", "list" });
    switch (decision) {
        .action => |invocation| try testing.expectEqual(Action.models_list, invocation.action),
        else => return error.UnexpectedValue,
    }
}

test "parse returns mission help for inline help flags" {
    const testing = std.testing;
    const decision = parse(&.{ "mission", "--help" });
    switch (decision) {
        .help => |command| try testing.expectEqualStrings("mission", command.path_label),
        else => return error.UnexpectedValue,
    }
}

test "parse reports missing mission subcommands" {
    const testing = std.testing;
    const decision = parse(&.{ "mission" });
    switch (decision) {
        .action => |invocation| try testing.expectEqual(Action.mission_compose, invocation.action),
        else => return error.UnexpectedValue,
    }
}

test "parse rejects stray flags for mission start" {
    const testing = std.testing;
    const decision = parse(&.{ "mission", "start", "--json" });
    switch (decision) {
        .failure => |failure| try testing.expectEqual(FailureKind.invalid_flag, failure.kind),
        else => return error.UnexpectedValue,
    }
}

test "render root help lists the public command tree" {
    const testing = std.testing;
    const text = try renderHelp(testing.allocator, &root_command);
    defer testing.allocator.free(text);

    try testing.expect(std.mem.indexOf(u8, text, "Mission Control:") != null);
    try testing.expect(std.mem.indexOf(u8, text, "mission start") != null);
    try testing.expect(std.mem.indexOf(u8, text, "contubernium models") != null);
}

test "render failure suggests the canonical command" {
    const testing = std.testing;
    const text = try renderFailure(testing.allocator, .{
        .kind = .unknown_command,
        .command = &root_command,
        .token = "resum",
        .suggestion = &mission_continue_command,
    });
    defer testing.allocator.free(text);

    try testing.expect(std.mem.indexOf(u8, text, "Did you mean `contubernium mission continue`?") != null);
}
