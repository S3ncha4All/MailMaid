const std = @import("std");
const ArrayList = std.ArrayList;
const http = std.http;

pub const Request = struct { method: std.http.Method, url: []u8, header: []std.http.Header, body: ?[]const u8 };
pub const Response = struct { meta: http.Client.FetchResult, content: []u8 };

pub fn makeRequest(allocator: std.mem.Allocator, request: Request) !Response {
    var client = http.Client{ .allocator = allocator };
    var responseBody = ArrayList(u8).init(allocator);
    const response = try client.fetch(.{ .method = request.method, .extra_headers = request.header, .location = .{ .url = request.url }, .payload = request.body, .response_storage = .{ .dynamic = &responseBody } });
    const content = try responseBody.toOwnedSlice();
    return .{ .meta = response, .content = content };
}
