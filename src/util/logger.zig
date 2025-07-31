const std = @import("std");

pub fn log(comptime text: []const u8, args: anytype) void {
    const logText = "LOG DATE - " ++ text ++ "\n";
    std.debug.print(logText, args);
}
