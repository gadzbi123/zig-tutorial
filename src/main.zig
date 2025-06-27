const std = @import("std");
const Thread = std.Thread;

pub extern "c" fn _exit(code: c_int) noreturn;
var stacker: [16 * 1028]u8 = undefined;
threadlocal var my_val: u8 = 1;
pub fn main() !void {
    // var stack = std.heap.FixedBufferAllocator.init(stacker);
    // const stack_alloc = stack.allocator();

    var threads: [10]Thread = undefined;
    for (threads, 0..) |_, i| {
        const nt = try std.Thread.spawn(.{}, add, .{my_val}); //.{ .allocator = stack_alloc }
        threads[i] = nt;
    }

    for (threads) |t| {
        t.join();
    }
    std.debug.print("value is {}, state: \n", .{my_val});
    _exit(2);
}

fn add(val: u8) void {
    my_val += val;
}
