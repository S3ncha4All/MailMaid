const std = @import("std");
const ArrayList = std.ArrayList;

pub const ArgumentToken = struct { argument_type: []u8, argument: []u8 };
pub const Tokens = struct { cmds: [][]u8, modifier: [][]u8, arguments: []ArgumentToken };

pub fn parseCommandLine(allocator: std.mem.Allocator, args: [][:0]u8) !Tokens {
    var i: usize = 0;
    var cmds = ArrayList([]u8).init(allocator);
    var modifier = ArrayList([]u8).init(allocator);
    var arguments = ArrayList(ArgumentToken).init(allocator);
    while (i < args.len) : (i += 1) {
        if (std.mem.startsWith(u8, args[i], "--")) {
            try parseParameter(args[i][2..], args, &i, &modifier, &arguments);
        } else if (std.mem.startsWith(u8, args[i], "-")) {
            try parseParameter(args[i][1..], args, &i, &modifier, &arguments);
        } else {
            //Command
            try cmds.append(args[i]);
        }
    }
    return .{ .cmds = cmds.items, .modifier = modifier.items, .arguments = arguments.items };
}

fn parseParameter(param: []u8, args: [][:0]u8, i: *usize, modifier: *ArrayList([]u8), arguments: *ArrayList(ArgumentToken)) !void {
    //Argument oder Modifier
    if (i.* + 1 < args.len) {
        i.* += 1;
        if (std.mem.startsWith(u8, args[i.*], "--")) {
            //Modifier
            try modifier.append(args[i.*][2..]);
        } else if (std.mem.startsWith(u8, args[i.*], "-")) {
            //Modifier
            try modifier.append(args[i.*][1..]);
        } else {
            //Argument
            try arguments.append(.{ .argument_type = param, .argument = args[i.*] });
        }
    } else {
        //Modifier
        try modifier.append(param);
    }
}
