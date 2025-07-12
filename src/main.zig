const std = @import("std");
const parser = @import("parser/argument_parser.zig");
const commands = @import("parser/command_parser.zig");
const client = @import("client.zig");

pub fn main() !void {
    std.debug.print("Run MailMaid\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);

    const cli_command = try parser.parse_commandline(allocator, args[1..]);
    const command = commands.parse_cli_command(allocator, cli_command);
    switch (command) {
        .Request => |request| {
            client.make_request(allocator, request);
        },
        .Help => std.debug.print("HELP\n", .{}),
    }
}
