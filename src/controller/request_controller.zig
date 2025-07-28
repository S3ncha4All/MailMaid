const std = @import("std");
const Request = @import("../core/router.zig").Request;
const ArgumentToken = @import("../core/tokenizer.zig").ArgumentToken;

pub fn handle(_: Request, _: []ArgumentToken) void {
    std.debug.print("Manage manageRequestCommand", .{});
}
