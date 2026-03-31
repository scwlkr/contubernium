const std = @import("std");
const core = @import("runtime_core.zig");

const DecanusDecision = core.DecanusDecision;
const SpecialistResult = core.SpecialistResult;
const ToolRequest = core.ToolRequest;
const freeOwnedToolRequest = core.freeOwnedToolRequest;
const trimAscii = core.trimAscii;

pub fn parseJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const parsed = try std.json.parseFromSlice(T, allocator, text, .{
        .ignore_unknown_fields = true,
    });
    return parsed.value;
}

pub fn parseModelJson(comptime T: type, allocator: std.mem.Allocator, text: []const u8) !T {
    const normalized = try normalizeModelJson(text);
    if (T == DecanusDecision) return try parseDecanusDecisionModelJson(allocator, normalized);
    if (T == SpecialistResult) return try parseSpecialistResultModelJson(allocator, normalized);
    if (T == ToolRequest) return try parseToolRequestModelJson(allocator, normalized);
    return try parseJson(T, allocator, normalized);
}

pub fn parseDecanusDecisionModelJson(allocator: std.mem.Allocator, text: []const u8) !DecanusDecision {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();

    const object = try requireJsonObject(parsed.value);
    return .{
        .action = try dupJsonObjectStringFieldOrDefault(allocator, object, "action", ""),
        .reasoning = try dupJsonObjectStringFieldOrDefault(allocator, object, "reasoning", ""),
        .current_goal = try dupJsonObjectStringFieldOrDefault(allocator, object, "current_goal", ""),
        .agent_call = try dupJsonObjectStringFieldOrDefault(allocator, object, "agent_call", ""),
        .lane = try dupJsonObjectStringFieldOrDefault(allocator, object, "lane", ""),
        .actor = try dupJsonObjectStringFieldOrDefault(allocator, object, "actor", ""),
        .objective = try dupJsonObjectStringFieldOrDefault(allocator, object, "objective", ""),
        .completion_signal = try dupJsonObjectStringFieldOrDefault(allocator, object, "completion_signal", ""),
        .dependencies = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "dependencies"),
        .final_response = try dupJsonObjectStringFieldOrDefault(allocator, object, "final_response", ""),
        .question = try dupJsonObjectStringFieldOrDefault(allocator, object, "question", ""),
        .blocked_reason = try dupJsonObjectStringFieldOrDefault(allocator, object, "blocked_reason", ""),
        .tool_requests = try dupJsonObjectToolRequestsFieldOrDefault(allocator, object, "tool_requests"),
    };
}

pub fn parseSpecialistResultModelJson(allocator: std.mem.Allocator, text: []const u8) !SpecialistResult {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();

    const object = try requireJsonObject(parsed.value);
    return .{
        .action = try dupJsonObjectStringFieldOrDefault(allocator, object, "action", ""),
        .reasoning = try dupJsonObjectStringFieldOrDefault(allocator, object, "reasoning", ""),
        .status = try dupJsonObjectStringFieldOrDefault(allocator, object, "status", ""),
        .summary = try dupJsonObjectStringFieldOrDefault(allocator, object, "summary", ""),
        .changes = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "changes"),
        .findings = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "findings"),
        .blockers = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "blockers"),
        .next_recommended_agent = try dupJsonObjectStringFieldOrDefault(allocator, object, "next_recommended_agent", ""),
        .confidence = try jsonObjectFloatFieldOrDefault(object, "confidence", 0.0),
        .description = try dupJsonObjectStringFieldOrDefault(allocator, object, "description", ""),
        .result_summary = try dupJsonObjectStringFieldOrDefault(allocator, object, "result_summary", ""),
        .artifacts = try dupJsonObjectStringArrayFieldOrDefault(allocator, object, "artifacts"),
        .follow_up_needed = try dupJsonObjectStringFieldOrDefault(allocator, object, "follow_up_needed", ""),
        .question = try dupJsonObjectStringFieldOrDefault(allocator, object, "question", ""),
        .blocked_reason = try dupJsonObjectStringFieldOrDefault(allocator, object, "blocked_reason", ""),
        .tool_requests = try dupJsonObjectToolRequestsFieldOrDefault(allocator, object, "tool_requests"),
    };
}

pub fn parseToolRequestModelJson(allocator: std.mem.Allocator, text: []const u8) !ToolRequest {
    const parsed = try parseModelValueTree(allocator, text);
    defer parsed.deinit();
    return try dupToolRequestFromJsonValue(allocator, parsed.value);
}

pub fn parseModelValueTree(allocator: std.mem.Allocator, text: []const u8) !std.json.Parsed(std.json.Value) {
    return try std.json.parseFromSlice(std.json.Value, allocator, text, .{
        .ignore_unknown_fields = true,
    });
}

pub fn requireJsonObject(value: std.json.Value) !std.json.ObjectMap {
    return switch (value) {
        .object => |object| object,
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectStringFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
    default_value: []const u8,
) ![]const u8 {
    const value = object.get(field_name) orelse return try allocator.dupe(u8, default_value);
    return try dupJsonStringValueOrDefault(allocator, value, default_value);
}

pub fn dupJsonStringValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
    default_value: []const u8,
) ![]const u8 {
    return switch (value) {
        .null => try allocator.dupe(u8, default_value),
        .string => |text| try allocator.dupe(u8, text),
        .number_string => |text| try allocator.dupe(u8, text),
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectStringArrayFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const []const u8 {
    const value = object.get(field_name) orelse return try allocator.alloc([]const u8, 0);
    return try dupJsonStringArrayValueOrDefault(allocator, value);
}

pub fn dupJsonStringArrayValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
) ![]const []const u8 {
    return switch (value) {
        .null => try allocator.alloc([]const u8, 0),
        .array => |array| {
            var items = try allocator.alloc([]const u8, array.items.len);
            errdefer allocator.free(items);

            var index: usize = 0;
            errdefer {
                while (index > 0) {
                    index -= 1;
                    allocator.free(items[index]);
                }
            }

            for (array.items, 0..) |item, i| {
                items[i] = try dupJsonStringValueOrDefault(allocator, item, "");
                index = i + 1;
            }
            return items;
        },
        else => error.UnexpectedToken,
    };
}

pub fn dupJsonObjectToolRequestsFieldOrDefault(
    allocator: std.mem.Allocator,
    object: std.json.ObjectMap,
    field_name: []const u8,
) ![]const ToolRequest {
    const value = object.get(field_name) orelse return try allocator.alloc(ToolRequest, 0);
    return try dupToolRequestsValueOrDefault(allocator, value);
}

pub fn dupToolRequestsValueOrDefault(
    allocator: std.mem.Allocator,
    value: std.json.Value,
) ![]const ToolRequest {
    return switch (value) {
        .null => try allocator.alloc(ToolRequest, 0),
        .array => |array| {
            var items = try allocator.alloc(ToolRequest, array.items.len);
            errdefer allocator.free(items);

            var index: usize = 0;
            errdefer {
                while (index > 0) {
                    index -= 1;
                    freeOwnedToolRequest(allocator, items[index]);
                }
            }

            for (array.items, 0..) |item, i| {
                items[i] = try dupToolRequestFromJsonValue(allocator, item);
                index = i + 1;
            }
            return items;
        },
        else => error.UnexpectedToken,
    };
}

pub fn dupToolRequestFromJsonValue(allocator: std.mem.Allocator, value: std.json.Value) !ToolRequest {
    const object = try requireJsonObject(value);
    return .{
        .tool = try dupJsonObjectStringFieldOrDefault(allocator, object, "tool", ""),
        .description = try dupJsonObjectStringFieldOrDefault(allocator, object, "description", ""),
        .path = try dupJsonObjectStringFieldOrDefault(allocator, object, "path", ""),
        .pattern = try dupJsonObjectStringFieldOrDefault(allocator, object, "pattern", ""),
        .command = try dupJsonObjectStringFieldOrDefault(allocator, object, "command", ""),
        .content = try dupJsonObjectStringFieldOrDefault(allocator, object, "content", ""),
    };
}

pub fn jsonObjectFloatFieldOrDefault(
    object: std.json.ObjectMap,
    field_name: []const u8,
    default_value: f32,
) !f32 {
    const value = object.get(field_name) orelse return default_value;
    return switch (value) {
        .null => default_value,
        .integer => |integer| @as(f32, @floatFromInt(integer)),
        .float => |float| @as(f32, @floatCast(float)),
        .number_string, .string => |text| try std.fmt.parseFloat(f32, text),
        else => error.UnexpectedToken,
    };
}

pub fn prettyPrintJson(allocator: std.mem.Allocator, text: []const u8) ![]const u8 {
    const normalized = try normalizeModelJson(text);
    const parsed = try std.json.parseFromSlice(std.json.Value, allocator, normalized, .{
        .ignore_unknown_fields = true,
    });
    defer parsed.deinit();
    return try std.fmt.allocPrint(
        allocator,
        "{f}",
        .{std.json.fmt(parsed.value, .{ .whitespace = .indent_2 })},
    );
}

pub fn normalizeModelJson(text: []const u8) ![]const u8 {
    var normalized = trimAscii(text);
    if (normalized.len == 0) return error.EmptyModelOutput;

    if (std.mem.startsWith(u8, normalized, "```")) {
        if (std.mem.indexOfScalar(u8, normalized, '\n')) |first_newline| {
            normalized = trimAscii(normalized[first_newline + 1 ..]);
            if (std.mem.lastIndexOf(u8, normalized, "```")) |last_fence| {
                normalized = trimAscii(normalized[0..last_fence]);
            }
        }
    }

    if (normalized.len == 0) return error.EmptyModelOutput;
    if (normalized[0] == '{' or normalized[0] == '[') return normalized;

    if (std.mem.indexOfScalar(u8, normalized, '{')) |start| {
        if (std.mem.lastIndexOfScalar(u8, normalized, '}')) |finish| {
            if (finish > start) return trimAscii(normalized[start .. finish + 1]);
        }
    }

    if (std.mem.indexOfScalar(u8, normalized, '[')) |start| {
        if (std.mem.lastIndexOfScalar(u8, normalized, ']')) |finish| {
            if (finish > start) return trimAscii(normalized[start .. finish + 1]);
        }
    }

    return normalized;
}
