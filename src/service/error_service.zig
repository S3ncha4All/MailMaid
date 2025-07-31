const std = @import("std");

pub fn handleError(err: error.anyerror) !void {
    std.debug.print("{}", .{err});
}
