const std = @import("std");
const heap_alloc = std.heap.page_allocator;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(heap_alloc);
    defer std.process.argsFree(heap_alloc, args);

    if (args.len != 3) {
        return error.Expected2RangeArguments;
    }

    const start = try std.fmt.parseInt(usize, args[1], 10);
    const end = try std.fmt.parseInt(usize, args[2], 10);

    var v: usize = start;
    while (v < end) : (v += 1) {
        const div3 = @intFromBool(@mod(v, 3) == 0);
        const div5 = @intFromBool(@mod(v, 5) == 0);
        const case = div3 + (2 * @as(u2, div5));
        switch (case) {
            3 => try stdout.print("Fizz Buzz", .{}),
            2 => try stdout.print("Buzz", .{}),
            1 => try stdout.print("Fizz", .{}),
            0 => try stdout.print("{}", .{v}),
        }
        try stdout.print("\n", .{});
    }
}
