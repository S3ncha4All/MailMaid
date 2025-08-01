const std = @import("std");
const StdOut = std.io.getStdOut();

pub fn print(comptime text: []const u8, args: anytype) void {
    StdOut.writer().print(text, args) catch {};
}
