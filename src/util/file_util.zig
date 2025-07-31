const std = @import("std");

pub fn readCompleteFile(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const data = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
    return data;
}
