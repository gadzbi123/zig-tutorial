const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var buff = try allocator.alloc(u8, 1000);

    const address = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Server listening on http://{}...\n", .{address});

    while (true) {
        var connection = try server.accept();
        defer connection.stream.close();

        var http_server = std.http.Server.init(connection, buff);
        defer http_server.deinit();

        const method = http_server.request.method;
        const path = http_server.request.target;

        std.debug.print("Received {} request for {}\n", .{ method, path });

        switch (method) {
            .GET => try handleGet(&http_server, path),
            .PUT => try handlePut(&http_server, path),
            .POST => try handlePost(&http_server, path),
            .DELETE => try handleDelete(&http_server, path),
            else => try http_server.respond("Method Not Allowed", .{ .status = .method_not_allowed }),
        }
    }
}

fn handleGet(server: *std.http.Server, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/")) {
        try server.respond("Hello, GET request!", .{});
    } else {
        try server.respond("Not Found", .{ .status = .not_found });
    }
}

fn handlePut(server: *std.http.Server, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try server.respond("Data updated via PUT request!", .{});
    } else {
        try server.respond("Not Found", .{ .status = .not_found });
    }
}

fn handlePost(server: *std.http.Server, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try server.respond("Data created via POST request!", .{});
    } else {
        try server.respond("Not Found", .{ .status = .not_found });
    }
}

fn handleDelete(server: *std.http.Server, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try server.respond("Data deleted via DELETE request!", .{});
    } else {
        try server.respond("Not Found", .{ .status = .not_found });
    }
}
