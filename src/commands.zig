const std = @import("std");
const cmd_err = @import("errors/command_error.zig");

pub const Command = enum {
    parse,
    request,
    get,
    post,
    delete,
    put,
    patch,
    help,

    pub fn to_string(command: Command) []u8 {
        return @tagName(command);
    }

    pub fn from_string(command: []u8) !Command {
        if (std.mem.eql(u8, command, "parse")) return .parse;
        if (std.mem.eql(u8, command, "request")) return .request;
        if (std.mem.eql(u8, command, "get")) return .get;
        if (std.mem.eql(u8, command, "post")) return .post;
        if (std.mem.eql(u8, command, "delete")) return .delete;
        if (std.mem.eql(u8, command, "put")) return .put;
        if (std.mem.eql(u8, command, "patch")) return .patch;
        if (std.mem.eql(u8, command, "help")) return .help;
        return cmd_err.CommandParsingError.InvalidCommand;
    }
};

pub const CommandParameter = struct { command: Command = .help, url: []u8 = "" };

pub fn get_command_from_arguments(args: [][:0]u8) !Command {
    if (args.len > 0) {
        return try Command.from_string(args[0]);
    } else {
        return cmd_err.CommandParsingError.MissingCommand;
    }
}

pub fn parse_arguments(args: [][:0]u8) !CommandParameter {
    var cmdParameter = CommandParameter{};
    if (args.len < 1) {
        return cmd_err.ArgumentParsingError.MissingArgument;
    }
    cmdParameter.url = args[0];
    var i: usize = 1;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        std.debug.print("Argument?: {s}\n", .{arg});
    }
    return cmdParameter;
}
