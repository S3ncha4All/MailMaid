const std = @import("std");

pub fn print(text: []const u8, args: anytype) void {
    std.debug.print(text, args);
}
