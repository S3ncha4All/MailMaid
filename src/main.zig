const std = @import("std");
const mailmaid = @import("mailmaid.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("Run MailMaid\n", .{});

    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    mailmaid.run(args);
}
