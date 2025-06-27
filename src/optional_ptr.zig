const std = @import("std");

pub fn main() !void {
    var pi: anyerror!?f64 = 1;
    if (pi) |*p| {
        p.* = 5;
    } else {
        pi = 3.14;
    }
    std.debug.print("pi is {}\n", .{pi.?});
}
