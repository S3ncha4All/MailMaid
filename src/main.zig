const std = @import("std");
const mailmaid = @import("mailmaid.zig");

pub fn main() !void {
    std.debug.print("Run MailMaid\n", .{});

    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer allocator.free(args);

    mailmaid.run(args[1..]);
}
