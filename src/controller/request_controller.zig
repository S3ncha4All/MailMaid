const std = @import("std");
const ArrayList = std.ArrayList;
const Request = @import("../core/router.zig").Request;
const ArgumentToken = @import("../core/tokenizer.zig").ArgumentToken;
const Client = @import("../service/client_service.zig");

pub fn handle(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) void {
    std.debug.print("Manage manageRequestCommand", .{});
    const header = extractHeader(allocator, arguments) catch undefined;
    const body = extractBody(allocator, arguments) catch "";
    Client.makeRequest(allocator, .{ .method = request.method, .url = request.url, .header = header, .body = body });
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
