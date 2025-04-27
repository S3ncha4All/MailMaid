const std = @import("std");
const http = std.http;
const commands = @import("commands.zig");

pub fn run(args: [][:0]u8) void {
    if (commands.get_command_from_arguments(args)) |command| {
        handle_command(command, args[1..]);
    } else |_| {
        std.debug.print("ERROR!!!", .{});
    }
}

pub fn handle_command(command: commands.Command, args: [][:0]u8) void {
    switch (command) {
        commands.Command.get => {
            handle_method_request(.GET, args);
        },
        commands.Command.post => {
            handle_method_request(.POST, args);
        },
        commands.Command.put => {
            handle_method_request(.PUT, args);
        },
        commands.Command.patch => {
            handle_method_request(.PATCH, args);
        },
        commands.Command.delete => {
            handle_method_request(.DELETE, args);
        },
        commands.Command.help => {
            std.debug.print("HELP\n", .{});
        },
        else => {
            std.debug.print("Other valid Command\n", .{});
        },
    }
}

pub fn handle_method_request(method: http.Method, args: [][:0]u8) void {
    if (commands.parse_arguments(args)) |cmdParams| {
        make_request(method, cmdParams);
    } else |e| {
        std.debug.print("Error: {}", .{e});
    }
}

pub fn make_request(method: http.Method, cmdParams: commands.CommandParameter) void {
    var client = http.Client{ .allocator = std.heap.page_allocator };
    defer client.deinit();

    const response = client.fetch(.{
        .method = method,
        .location = .{ .url = cmdParams.url },
    }) catch |e| {
        std.debug.print("Error!: \n {}", .{e});
        return;
    };

    std.debug.print("Client?: \n{}", .{response});
}
