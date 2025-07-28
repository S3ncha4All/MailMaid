const std = @import("std");
const ArrayList = std.ArrayList;
const CliCommand = @import("cli_parser.zig").CliCmd;

pub const RequestCommand = struct { method: std.http.Method, url: []u8, header: []std.http.Header, body: ?[]const u8 };

//return .{ .Request = .{ .method = method, .url = cmd.cmds[1], .header = extractHeader(allocator, cmd) catch undefined, .body = null } };

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
