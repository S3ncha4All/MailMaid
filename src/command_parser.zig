const std = @import("std");
const ArrayList = std.ArrayList;
const CliCommand = @import("argument_parser.zig").CliCmd;

pub const RequestCommand = struct { method: std.http.Method, url: []u8, header: []std.http.Header, body: []const u8 };

const CommandTag = enum { Help, Request };

const Command = union(CommandTag) { Help: void, Request: RequestCommand };

pub fn parse_cli_command(allocator: std.mem.Allocator, cmd: CliCommand) Command {
    if (cmd.cmds.len > 0) {
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "REQUEST")) {
            if (cmd.cmds.len == 3) {
                const method = get_http_method(cmd.cmds[1]) catch .GET;
                return .{ .Request = .{ .method = method, .url = cmd.cmds[2], .header = extract_header(allocator, cmd) catch undefined, .body = extract_body(allocator, cmd) catch "" } };
            }
        }
        if (cmd.cmds.len == 2) {
            const method = get_http_method(cmd.cmds[0]) catch .GET;
            return .{ .Request = .{ .method = method, .url = cmd.cmds[1], .header = extract_header(allocator, cmd) catch undefined, .body = "" } };
        }
    }
    return .{ .Help = {} };
}

fn get_http_method(method: []u8) !std.http.Method {
    if (std.ascii.eqlIgnoreCase(method, "GET")) return .GET;
    if (std.ascii.eqlIgnoreCase(method, "POST")) return .POST;
    if (std.ascii.eqlIgnoreCase(method, "DELETE")) return .DELETE;
    if (std.ascii.eqlIgnoreCase(method, "PUT")) return .PUT;
    if (std.ascii.eqlIgnoreCase(method, "PATCH")) return .PATCH;
    return error.InvalidMethod;
}

fn extract_header(allocator: std.mem.Allocator, cmd: CliCommand) ![]std.http.Header {
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

fn extract_body(allocator: std.mem.Allocator, cmd: CliCommand) ![]u8 {
    var body = ArrayList(u8).init(allocator);
    for (cmd.arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "B") or std.ascii.eqlIgnoreCase(arg.argument_type, "BODY")) {
            try body.appendSlice(arg.argument);
        }
    }
    return body.toOwnedSlice();
}
