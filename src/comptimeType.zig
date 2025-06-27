const std = @import("std");
const expect = std.testing.expect;

const U = union(enum) {
    a: f32,
    b: u32,
};
fn getNum(u: U) u32 {
    switch (u) {
        inline else => |num, tag| {
            if (tag == .a) {
                return @intFromFloat(num);
            }
            return num;
        },
    }
    unreachable;
}

test "getNumUnion" {
    const u = U{ .b = 32 };
    try expect(getNum(u) == 32);
    const u2b = U{ .a = 1.2 };
    try expect(getNum(u2b) == 1);
}
