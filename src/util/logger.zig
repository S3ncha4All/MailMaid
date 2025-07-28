const std = @import("std");

pub fn log(comptime text: []const u8, args: anytype) void {
    std.debug.print(text, args);
}
