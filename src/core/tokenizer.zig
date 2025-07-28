const std = @import("std");
const ArrayList = std.ArrayList;

pub const ArgumentToken = struct { argument_type: []u8, argument: []u8 };
pub const Tokens = struct { cmds: [][]u8, arguments: []ArgumentToken };

pub fn parseCommandLine(allocator: std.mem.Allocator, args: [][:0]u8) !Tokens {
    var i: usize = 0;
    var cmds = ArrayList([]u8).init(allocator);
    var arguments = ArrayList(ArgumentToken).init(allocator);
    while (i < args.len) : (i += 1) {
        if (std.mem.startsWith(u8, args[i], "--")) {
            //Argument
            const argType = args[i][2..];
            if (i + 1 < args.len) {
                i += 1;
                try arguments.append(.{ .argument_type = argType, .argument = args[i] });
            } else {
                return error.MissingArgument;
            }
        } else if (std.mem.startsWith(u8, args[i], "-")) {
            //Argument
            const argType = args[i][1..];
            if (i + 1 < args.len) {
                i += 1;
                try arguments.append(.{ .argument_type = argType, .argument = args[i] });
            } else {
                return error.MissingArgument;
            }
        } else {
            //Command
            try cmds.append(args[i]);
        }
    }
    return .{ .cmds = cmds.items, .arguments = arguments.items };
}
