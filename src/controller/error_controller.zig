const std = @import("std");
const Printer = @import("../util/printer.zig");

pub fn handle(err: anyerror) void {
    //std.debug.print("{}", .{err});
    switch (err) {
        error.FileNotFound => Printer.print("Datei weg ...", .{}),
        else => Printer.print("Unbekannter Fehler: {}", .{err}),
    }
}
