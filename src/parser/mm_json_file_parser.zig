const std = @import("std");

const json_env = struct {
    id : u32,
    name: []u8,
    values: ?std.json.Value = null
};

const json_request_body = struct {
    type: []u8,
    body: []u8
};

const json_request = struct {
    id : u32,
    name: []u8,
    description: []u8,
    method: []u8,
    url: []u8,
    header: ?std.json.Value = null,
    body: json_request_body
};

const json_workspace = struct {env: []json_env, requests: []json_request};

pub fn parse_workspace(allocator:std.mem.Allocator, dir: [] const u8) !json_workspace {
    const data = try std.fs.cwd().readFileAlloc(allocator, dir, std.math.maxInt(usize));
    const parsed = try std.json.parseFromSlice(json_workspace, allocator, data, .{});
    return parsed.value;
}

test "test_parse_json_workspace" {
    const allocator = std.heap.page_allocator;
    const test_workspace = "test/test.mm.json";
    const json = try parse_workspace(allocator, test_workspace);
    std.debug.print("JSON:\n {}\n", .{json});
    std.debug.print("Key / Value = {any} /  {any}\n", .{
        json.env[0].values.?.object.keys()[0],
        json.env[0].values.?.object.values()[0]
    });
}