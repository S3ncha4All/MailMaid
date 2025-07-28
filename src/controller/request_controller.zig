const std = @import("std");
const ArrayList = std.ArrayList;
const Logger = @import("../util/logger.zig");
const Request = @import("../core/router.zig").Request;
const Client = @import("../service/client_service.zig");
const ArgumentToken = @import("../core/tokenizer.zig").ArgumentToken;

pub fn handle(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) void {
    Logger.log("Handle Request\n", .{});
    const response = switch (request.method) {
        .POST, .PUT, .PATCH => handleBodyless(allocator, request, arguments),
        else => handleBodyless(allocator, request, arguments),
    };
    if (response) |r| {
        std.debug.print("Response. {any}\n", .{r.meta});
        std.debug.print("Content: {s}", .{r.content});
    } else |e| {
        std.debug.print("ERROR\n {}", .{e});
    }
}

fn handleBodyless(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) !Client.Response {
    const header = extractHeader(allocator, arguments) catch undefined;
    return Client.makeRequest(allocator, .{ .method = request.method, .url = request.url, .header = header, .body = null });
}

fn handleWithBody(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) !Client.Response {
    const header = extractHeader(allocator, arguments) catch undefined;
    const body = extractBody(allocator, arguments) catch "";
    return Client.makeRequest(allocator, .{ .method = request.method, .url = request.url, .header = header, .body = body });
}

fn extractHeader(allocator: std.mem.Allocator, arguments: []ArgumentToken) ![]std.http.Header {
    var headers = ArrayList(std.http.Header).init(allocator);
    for (arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "H") or std.ascii.eqlIgnoreCase(arg.argument_type, "HEADER")) {
            const eql_index = std.mem.indexOf(u8, arg.argument, "=");
            if (eql_index) |index| {
                const header_name = arg.argument[0..index];
                const header_value = arg.argument[index + 1 ..];
                try headers.append(.{ .name = header_name, .value = header_value });
            }
        }
    }
    return headers.items;
}

fn extractBody(allocator: std.mem.Allocator, arguments: []ArgumentToken) ![]u8 {
    var body = ArrayList(u8).init(allocator);
    for (arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "B") or std.ascii.eqlIgnoreCase(arg.argument_type, "BODY")) {
            try body.appendSlice(arg.argument);
        }
    }
    return body.toOwnedSlice();
}
