const std = @import("std");
const ArrayList = std.ArrayList;
const Logger = @import("../util/logger.zig");
const Printer = @import("../util/printer.zig");
const fileUtil = @import("../util/file_util.zig");
const Request = @import("../core/router.zig").Request;
const Client = @import("../service/client_service.zig");
const ArgumentToken = @import("../core/tokenizer.zig").ArgumentToken;

pub fn handle(allocator: std.mem.Allocator, request: Request, modifier: [][]u8, arguments: []ArgumentToken) !void {
    Logger.log("Handle Request", .{});
    const response = switch (request.method) {
        .POST, .PUT, .PATCH => handleWithBody(allocator, request, arguments),
        else => handleBodyless(allocator, request, arguments),
    };
    if (response) |r| {
        if (!isSilent(modifier)) {
            Printer.print("Response. {any}\n", .{r.meta});
            Printer.print("Content: {s}", .{r.content});
        }
    } else |e| {
        Logger.log("Error while handling Request: {}", .{e});
        return e;
    }
}

fn isSilent(modifier: [][]u8) bool {
    for (modifier) |mod| {
        if (std.ascii.eqlIgnoreCase(mod, "S") or std.ascii.eqlIgnoreCase(mod, "SILENT")) {
            return true;
        }
    }
    return false;
}

fn handleBodyless(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) !Client.Response {
    const header = extractHeader(allocator, arguments) catch undefined;
    return Client.makeRequest(allocator, .{ .method = request.method, .url = request.url, .header = header, .body = null });
}

fn handleWithBody(allocator: std.mem.Allocator, request: Request, arguments: []ArgumentToken) !Client.Response {
    const header = extractHeader(allocator, arguments) catch undefined;
    const body = try extractBody(allocator, arguments);
    return Client.makeRequest(allocator, .{ .method = request.method, .url = request.url, .header = header, .body = body });
}

fn extractHeader(allocator: std.mem.Allocator, arguments: []ArgumentToken) ![]std.http.Header {
    var headers = ArrayList(std.http.Header).init(allocator);
    for (arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "H") or std.ascii.eqlIgnoreCase(arg.argument_type, "HEADER")) {
            const eql_index = std.mem.indexOf(u8, arg.argument, "=");
            if (eql_index) |index| {
                const header_name = arg.argument[0..index];
                const header_value = arg.argument[index + 1 ..];
                try headers.append(.{ .name = header_name, .value = header_value });
            }
        }
    }
    return headers.items;
}

fn extractBody(allocator: std.mem.Allocator, arguments: []ArgumentToken) ![]u8 {
    var body: []u8 = "";
    for (arguments) |arg| {
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "B") or std.ascii.eqlIgnoreCase(arg.argument_type, "BODY")) {
            body = arg.argument;
        }
        if (std.ascii.eqlIgnoreCase(arg.argument_type, "BF") or std.ascii.eqlIgnoreCase(arg.argument_type, "BODY-FILE")) {
            body = try extractBodyFromFile(allocator, arg.argument);
        }
    }
    return body;
}

fn extractBodyFromFile(allocator: std.mem.Allocator, path: []u8) ![]u8 {
    const data = try fileUtil.readCompleteFile(allocator, path);
    return data;
}
