const std = @import("std");
const ArrayList = std.ArrayList;
const http = std.http;

pub const RequestCommand = struct { method: std.http.Method, url: []u8, header: []std.http.Header, body: ?[]const u8 };

pub fn makeRequest(allocator: std.mem.Allocator, request: RequestCommand) void {
    var client = http.Client{ .allocator = allocator };
    defer client.deinit();

    var response_body = ArrayList(u8).init(allocator);

    const response = client.fetch(.{ .method = request.method, .extra_headers = request.header, .location = .{ .url = request.url }, .payload = request.body, .response_storage = .{ .dynamic = &response_body } }) catch |e| {
        std.debug.print("Error!: \n {}", .{e});
        return;
    };

    std.debug.print("Client?: {}\n", .{response});
    std.debug.print("Response:\n {s}\n", .{response_body.items});
}
