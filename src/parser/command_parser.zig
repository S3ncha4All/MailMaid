const std = @import("std");
const ArrayList = std.ArrayList;
const CliCommand = @import("argument_parser.zig").CliCmd;

pub const RequestCommand = struct { method: std.http.Method, url: []u8, header: []std.http.Header, body: ?[]const u8 };
const CommandTag = enum { Help, Request };
const Command = union(CommandTag) { Help: void, Request: RequestCommand };

pub fn parseCliCommand(allocator: std.mem.Allocator, cmd: CliCommand) Command {
    if (cmd.cmds.len > 0) {
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "REQUEST")) {
            if (cmd.cmds.len == 3) {
                const method = getHttpMethod(cmd.cmds[1]) catch .GET;
                return .{ .Request = .{ .method = method, .url = cmd.cmds[2], .header = extractHeader(allocator, cmd) catch undefined, .body = extractBody(allocator, cmd) catch null } };
            }
        }
        if (cmd.cmds.len == 2) {
            const method = getHttpMethod(cmd.cmds[0]) catch .GET;
            return .{ .Request = .{ .method = method, .url = cmd.cmds[1], .header = extractHeader(allocator, cmd) catch undefined, .body = null } };
        }
    }
    return .{ .Help = {} };
}

fn getHttpMethod(method: []u8) !std.http.Method {
    if (std.ascii.eqlIgnoreCase(method, "GET")) return .GET;
    if (std.ascii.eqlIgnoreCase(method, "POST")) return .POST;
    if (std.ascii.eqlIgnoreCase(method, "DELETE")) return .DELETE;
    if (std.ascii.eqlIgnoreCase(method, "PUT")) return .PUT;
    if (std.ascii.eqlIgnoreCase(method, "PATCH")) return .PATCH;
    if (std.ascii.eqlIgnoreCase(method, "HEAD")) return .HEAD;
    if (std.ascii.eqlIgnoreCase(method, "CONNECT")) return .CONNECT;
    if (std.ascii.eqlIgnoreCase(method, "OPTIONS")) return .OPTIONS;
    if (std.ascii.eqlIgnoreCase(method, "TRACE")) return .TRACE;
    return error.InvalidMethod;
}

fn extractHeader(allocator: std.mem.Allocator, cmd: CliCommand) ![]std.http.Header {
    var headers = ArrayList(std.http.Header).init(allocator);
    for (cmd.arguments) |arg| {
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

fn extractBody(allocator: std.mem.Allocator, cmd: CliCommand) ![]u8 {
    var body = ArrayList(u8).init(allocator);
    for (cmd.arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "B") or std.ascii.eqlIgnoreCase(arg.argument_type, "BODY")) {
            try body.appendSlice(arg.argument);
        }
    }
    return body.toOwnedSlice();
}
