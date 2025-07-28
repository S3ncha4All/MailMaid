const std = @import("std");
const ArrayList = std.ArrayList;
const Tokens = @import("tokenizer.zig").Tokens;

const CommandVerb = enum { Create, List, Collect, Set, Remove, Activate, Import, Delete, Add, Help };
const CommandTag = enum { Help, Request, Init, Collection, History, Environment };

pub const Generic = struct { verb: CommandVerb };
pub const Request = struct { method: std.http.Method, url: []u8 };
const Command = union(CommandTag) { Help: void, Request: Request, Init: void, Collection: Generic, History: Generic, Environment: Generic };

pub fn createRoute(cmd: Tokens) Command {
    if (cmd.cmds.len > 0) {
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "REQUEST")) {
            if (cmd.cmds.len >= 3) {
                const method = getHttpMethod(cmd.cmds[1]) catch .GET;
                return .{ .Request = .{ .method = method, .url = cmd.cmds[2] } };
            }
        }
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "COLLECTION")) {
            const verb = getCommandVerb(cmd.cmds) catch .Help;
            return .{ .Collection = .{ .verb = verb } };
        }
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "HISTORY")) {
            const verb = getCommandVerb(cmd.cmds) catch .Help;
            return .{ .Collection = .{ .verb = verb } };
        }
        if (std.ascii.eqlIgnoreCase(cmd.cmds[0], "ENVIRONMENT")) {
            const verb = getCommandVerb(cmd.cmds) catch .Help;
            return .{ .Collection = .{ .verb = verb } };
        }
        if (std.ascii.endsWithIgnoreCase(cmd.cmds[0], "INIT")) {
            return .{ .Init = {} };
        }
        if (cmd.cmds.len == 2) {
            const method = getHttpMethod(cmd.cmds[0]) catch .GET;
            return .{ .Request = .{ .method = method, .url = cmd.cmds[1] } };
        }
    }
    return .{ .Help = {} };
}

fn getCommandVerb(cmd: [][]u8) !CommandVerb {
    if (cmd.len >= 2) {
        if (std.ascii.eqlIgnoreCase(cmd[1], "Create")) return .Create;
        if (std.ascii.eqlIgnoreCase(cmd[1], "List")) return .List;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Collect")) return .Collect;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Set")) return .Set;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Remove")) return .Remove;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Activate")) return .Activate;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Import")) return .Import;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Delete")) return .Delete;
        if (std.ascii.eqlIgnoreCase(cmd[1], "Add")) return .Add;
    }
    return error.InvalidCommandVerb;
}

fn getHttpMethod(method: []u8) !std.http.Method {
    if (std.ascii.eqlIgnoreCase(method, "GET")) return .GET;
    if (std.ascii.eqlIgnoreCase(method, "POST")) return .POST;
    if (std.ascii.eqlIgnoreCase(method, "DELETE")) return .DELETE;
    if (std.ascii.eqlIgnoreCase(method, "PUT")) return .PUT;
    if (std.ascii.eqlIgnoreCase(method, "PATCH")) return .PATCH;
    if (std.ascii.eqlIgnoreCase(method, "HEAD")) return .HEAD;
    if (std.ascii.eqlIgnoreCase(method, "CONNECT")) return .CONNECT;
    if (std.ascii.eqlIgnoreCase(method, "OPTIONS")) return .OPTIONS;
    if (std.ascii.eqlIgnoreCase(method, "TRACE")) return .TRACE;
    return error.InvalidMethod;
}
