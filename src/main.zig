const std = @import("std");
const Logger = @import("util/logger.zig");
const Router = @import("core/router.zig");
const Printer = @import("util/printer.zig");
const Tokenizer = @import("core/tokenizer.zig");
const RequestController = @import("controller/request_controller.zig");
const InitController = @import("controller/init_controller.zig");
const CollectionController = @import("controller/collection_controller.zig");
const ErrorController = @import("controller/error_controller.zig");

pub fn main() !void {
    Printer.print("Run MailMaid\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    const args = try std.process.argsAlloc(allocator);

    const tokens = try Tokenizer.parseCommandLine(allocator, args[1..]);
    const route = Router.createRoute(tokens);
    process(allocator, route, tokens) catch |err| {
        ErrorController.handle(err);
    };
}

fn process(allocator: std.mem.Allocator, route: Router.Command, tokens: Tokenizer.Tokens) !void {
    switch (route) {
        .Request => |request| {
            try RequestController.handle(allocator, request, tokens.modifier, tokens.arguments);
        },
        .Init => {
            try InitController.handle();
        },
        .Collection => |generic| {
            try CollectionController.handle(allocator, generic, tokens.modifier, tokens.arguments);
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
