const std = @import("std");

pub fn log(text: []const u8, args: anytype) void {
    std.debug.print(text, args);
}
