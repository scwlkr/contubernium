const builtin = @import("builtin");
const std = @import("std");

pub fn renderJsonAlloc(allocator: std.mem.Allocator, value: anytype) ![]u8 {
    return try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(value, .{ .whitespace = .indent_2 })},
    );
}

pub fn writeJsonAtomic(allocator: std.mem.Allocator, path: []const u8, value: anytype) !void {
    const rendered = try renderJsonAlloc(allocator, value);
    defer allocator.free(rendered);
    try writeTextAtomic(path, rendered);
}

pub fn writeTextAtomic(path: []const u8, content: []const u8) !void {
    var write_buffer: [4096]u8 = undefined;
    var atomic_file = try std.fs.cwd().atomicFile(path, .{
        .make_path = true,
        .write_buffer = &write_buffer,
    });
    defer atomic_file.deinit();

    try atomic_file.file_writer.file.writeAll(content);
    try atomic_file.file_writer.file.sync();
    try atomic_file.renameIntoPlace();
    try syncContainingDirectory(atomic_file.dir);
}

fn syncContainingDirectory(dir: std.fs.Dir) !void {
    switch (builtin.os.tag) {
        .windows, .wasi => return,
        else => try std.posix.fsync(dir.fd),
    }
}

test "writeTextAtomic creates parent directories and replaces existing files" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    try writeTextAtomic(".contubernium/state.json", "first");
    try writeTextAtomic(".contubernium/state.json", "second");

    const saved = try std.fs.cwd().readFileAlloc(std.testing.allocator, ".contubernium/state.json", 128);
    defer std.testing.allocator.free(saved);

    try std.testing.expectEqualStrings("second", saved);
}

test "writeTextAtomic supports absolute paths" {
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const allocator = std.testing.allocator;
    const root = try tmp.dir.realpathAlloc(allocator, ".");
    defer allocator.free(root);

    const absolute_path = try std.fs.path.join(allocator, &.{ root, "home", "session-index.json" });
    defer allocator.free(absolute_path);

    try writeTextAtomic(absolute_path, "{\"ok\":true}");

    const saved = try std.fs.cwd().readFileAlloc(allocator, absolute_path, 128);
    defer allocator.free(saved);

    try std.testing.expectEqualStrings("{\"ok\":true}", saved);
}

test "writeJsonAtomic renders indented JSON" {
    const allocator = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    const payload = struct {
        enabled: bool,
        name: []const u8,
    }{
        .enabled = true,
        .name = "phase-4",
    };

    try writeJsonAtomic(allocator, ".contubernium/config.json", payload);

    const saved = try std.fs.cwd().readFileAlloc(allocator, ".contubernium/config.json", 256);
    defer allocator.free(saved);

    try std.testing.expect(std.mem.indexOf(u8, saved, "\n  \"enabled\": true") != null);
    try std.testing.expect(std.mem.indexOf(u8, saved, "\n  \"name\": \"phase-4\"") != null);
}

test "writeTextAtomic preserves the previous file when replacement fails" {
    if (builtin.os.tag == .windows or builtin.os.tag == .wasi) return error.SkipZigTest;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var original_cwd = try std.fs.cwd().openDir(".", .{});
    defer original_cwd.close();
    try tmp.dir.setAsCwd();
    defer original_cwd.setAsCwd() catch {};

    try writeTextAtomic("state.json", "first");

    try tmp.dir.chmod(0o555);
    defer tmp.dir.chmod(0o755) catch {};

    if (writeTextAtomic("state.json", "second")) |_| {
        return error.TestUnexpectedResult;
    } else |_| {}

    const saved = try std.fs.cwd().readFileAlloc(std.testing.allocator, "state.json", 128);
    defer std.testing.allocator.free(saved);

    try std.testing.expectEqualStrings("first", saved);
}
