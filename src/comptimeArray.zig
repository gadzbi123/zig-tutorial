const std = @import("std");
const expect = std.testing.expect;

pub fn main() !void {
    var heapBuff: [1024 * 16]u8 = undefined;
    var alloc_struct = std.heap.FixedBufferAllocator.init(&heapBuff);
    var alloc = alloc_struct.allocator();
    const size = 110;
    const arr = try alloc.alloc(u8, size);
    defer alloc.free(arr);
    var i: u8 = 0;
    while (i < size) : (i += 1) {
        arr[i] = i + 1;
    }
    var sum: u8 = 0;
    i = 0;
    while (i < size) : (i += 1) {
        sum +|= arr[i];
    }
    var sum2: u8 = 0;
    i = 0;
    while (i < size) : (i += 1) {
        sum2 +%= arr[i];
    }
    const out = std.io.getStdOut().writer();
    try out.print("sum : {}\n", .{sum});
    try out.print("sum2 : {}\n", .{sum2});
}
// comptime {
//     @compileLog(fancy_array);
// }
// if var then it is evaluated at runtime, if const its evaluated at comp time
const fancy_array = init: {
    var initial_value: [10]Point = undefined;
    for (&initial_value, 0..) |*pt, j| {
        pt.* = Point{
            .x = @intCast(j),
            .y = @intCast(j * 2),
        };
    }
    break :init initial_value;
};
const Point = struct {
    x: i32,
    y: i32,
};
