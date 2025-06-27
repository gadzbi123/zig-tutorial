const std = @import("std");

const User = struct { id: i64, name: []u8 };

fn getUser(id: i64, name: []u8) *User {
    var user: User = .{ .id = id, .name = name };
    return &user;
}
// var buff: [16 * 1024]u8 = undefined;
pub fn main() !void {
    var alloc_struct = std.heap.GeneralPurposeAllocator(.{
        .verbose_log = true,
    }){};
    var alloc = alloc_struct.allocator();
    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);
    if (args.len < 2) {
        return error.Expected1Arg;
    }
    const args_name = args[1];
    // const name = try alloc.alloc(u8, args_name.len);
    const name = try alloc.alloc(u8, 10);
    // Double free scenario
    // defer alloc.free(name);
    std.mem.copyForwards(u8, name, args_name);
    const new_name = try alloc.realloc(name, args_name.len);
    defer alloc.free(new_name);

    const danglingUser = getUser(1, name);
    std.debug.print("user {}, id {s}\n", .{ danglingUser.id, danglingUser.name });
}
