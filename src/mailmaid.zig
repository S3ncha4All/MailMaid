const std = @import("std");
const http = std.http;

pub fn run(args: [][:0]u8) void {
    parse_arguments(args);
    make_request();
}

pub fn make_request() void {
    const host = "https://httpbin.org/get";
    _ = 80;

    var client = http.Client{ .allocator = std.heap.page_allocator };
    defer client.deinit();

    const response = client.fetch(.{
        .method = .GET,
        .location = .{ .url = host },
    }) catch |e| {
        std.debug.print("Error!: \n {}", .{e});
        return;
    };

    std.debug.print("Client?: \n{}", .{response});
}

pub fn parse_arguments(args: [][:0]u8) void {
    std.debug.print("Iterator?: {s}\n", .{args});
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        std.debug.print("Argument?: {s}\n", .{arg});
    }
}
