const std = @import("std");
const Tokenizer = @import("core/tokenizer.zig");
const Router = @import("core/router.zig");
const RequestController = @import("controller/request_controller.zig");

pub fn main() !void {
    std.debug.print("Run MailMaid\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);

    const tokens = try Tokenizer.parseCommandLine(allocator, args[1..]);
    const route = Router.createRoute(tokens);
    switch (route) {
        .Request => |request| {
            RequestController.handle(allocator, request, tokens.arguments);
        },
        .Init => {
            std.debug.print("initialize workspace", .{});
        },
        .Collection => |_| {
            std.debug.print("Collection command", .{});
        },
        .Environment => |_| {
            std.debug.print("Environment command", .{});
        },
        .History => |_| {
            std.debug.print("History command", .{});
        },
        .Help => std.debug.print("HELP\n", .{}),
    }
}
