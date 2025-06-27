const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer);

    const address = try std.net.Address.parseIp("127.0.0.1", 8080);
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Server listening on http://{}...\n", .{address});

    while (true) {
        var connection = try server.accept();
        defer connection.stream.close();

        const request = try readHttpRequest(connection.stream, &buffer);

        const parsed_request = parseHttpRequest(request) catch |err| {
            std.debug.print("Error parsing request: {}\n", .{err});
            continue;
        };

        std.debug.print("Received {} request for {s}\n", .{ parsed_request.method, parsed_request.path });

        switch (parsed_request.method) {
            .GET => try handleGet(connection.stream, parsed_request.path),
            .PUT => try handlePut(connection.stream, parsed_request.path),
            .POST => try handlePost(connection.stream, parsed_request.path),
            .DELETE => try handleDelete(connection.stream, parsed_request.path),
            else => try sendResponse(connection.stream, "405 Method Not Allowed", "Method Not Allowed"),
        }
    }
}

fn readHttpRequest(stream: std.net.Stream, buffer: *[]u8) ![]u8 {
    var total_read: usize = 0;
    var header_end_found = false;

    // Read until we find the end of headers (\r\n\r\n)
    while (total_read < buffer.len - 1 and !header_end_found) {
        const bytes_read = try stream.read(buffer.*[total_read .. total_read + 1]);
        if (bytes_read == 0) break;

        total_read += bytes_read;

        // Check for end of headers
        if (total_read >= 4) {
            const end_check = buffer.*[total_read - 4 .. total_read];
            if (std.mem.eql(u8, end_check, "\r\n\r\n")) {
                header_end_found = true;
            }
        }
    }

    return buffer.*[0..total_read];
}

const HttpMethod = enum {
    GET,
    POST,
    PUT,
    DELETE,
    UNKNOWN,
};

const HttpRequest = struct {
    method: HttpMethod,
    path: []const u8,
};

fn parseHttpRequest(request: []const u8) !HttpRequest {
    var lines = std.mem.splitSequence(u8, request, "\r\n");
    const first_line = lines.next() orelse return error.InvalidRequest;

    var parts = std.mem.splitSequence(u8, first_line, " ");
    const method_str = parts.next() orelse return error.InvalidRequest;
    const path = parts.next() orelse return error.InvalidRequest;

    const method = if (std.mem.eql(u8, method_str, "GET"))
        HttpMethod.GET
    else if (std.mem.eql(u8, method_str, "POST"))
        HttpMethod.POST
    else if (std.mem.eql(u8, method_str, "PUT"))
        HttpMethod.PUT
    else if (std.mem.eql(u8, method_str, "DELETE"))
        HttpMethod.DELETE
    else if (std.mem.eql(u8, method_str, "PATCH"))
        HttpMethod.PATCH
    else
        HttpMethod.UNKNOWN;

    return HttpRequest{
        .method = method,
        .path = path,
    };
}

fn sendResponse(stream: std.net.Stream, status: []const u8, body: []const u8) !void {
    const response = std.fmt.allocPrint(std.heap.page_allocator, "HTTP/1.1 {s}\r\nContent-Length: {d}\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n{s}", .{ status, body.len, body }) catch return;
    defer std.heap.page_allocator.free(response);

    _ = try stream.writeAll(response);
}

fn handleGet(stream: std.net.Stream, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/")) {
        try sendResponse(stream, "200 OK", "Hello, GET request!");
    } else {
        try sendResponse(stream, "404 Not Found", "Not Found");
    }
}

fn handlePut(stream: std.net.Stream, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try sendResponse(stream, "200 OK", "Data updated via PUT request!");
    } else {
        try sendResponse(stream, "404 Not Found", "Not Found");
    }
}

fn handlePost(stream: std.net.Stream, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try sendResponse(stream, "201 Created", "Data created via POST request!");
    } else {
        try sendResponse(stream, "404 Not Found", "Not Found");
    }
}

fn handleDelete(stream: std.net.Stream, path: []const u8) !void {
    if (std.mem.eql(u8, path, "/data")) {
        try sendResponse(stream, "200 OK", "Data deleted via DELETE request!");
    } else {
        try sendResponse(stream, "404 Not Found", "Not Found");
    }
}
