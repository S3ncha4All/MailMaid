const std = @import("std");
const Printer = @import("../util/printer.zig");
const Generic = @import("../core/router.zig").Generic;
const ArgumentToken = @import("../core/tokenizer.zig").ArgumentToken;

pub fn handle(_: std.mem.Allocator, generic: Generic, _: [][]u8, _: []ArgumentToken) !void {
    switch (generic.verb) {
        .List => {
            Printer.print("Handle Collection: LIST", .{});
            //List all available Collections
        },
        .Create => {
            Printer.print("Handle Collection: CREATE", .{});
            //Create a new empty Collection
        },
        .Add => {
            Printer.print("Handle Collection: ADD", .{});
            //Add a new Request Template to a given Collection
        },
        .Import => {
            Printer.print("Handle Collection: IMPORT", .{});
            //Create a new Collection with a given API Specification
        },
        .Delete => {
            Printer.print("Handle Collection: DELETE", .{});
            //Delete a given Collection
        },
        .Remove => {
            Printer.print("Handle Collection: REMOVE", .{});
            //Remove a Request Template from a given Collection
        },
        else => {
            Printer.print("Handle Collection: HELP", .{});
            //Help
        },
    }
}
