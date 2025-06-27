const std = @import("std");
const expect = std.testing.expect;
const expectError = std.testing.expectError;
const tst = struct {
    usingnamespace @import("std.testing");
};

fn isOpt(comptime T: type, i: usize) !bool {
    const fields = @typeInfo(T).@"struct".fields;
    return switch (i) {
        inline 0...fields.len - 1 => |idx| @typeInfo(fields[idx].type) == .optional,
        else => return error.IndexOutOfBounds,
    };
}

const Struct1 = struct { a: u32, b: ?u32 };

test "comptime" {
    var index: usize = 0;
    try expect(!try isOpt(Struct1, index));
    index += 1;
    try expect(try isOpt(Struct1, index));
    index += 1;
    try expectError(error.IndexOutOfBounds, isOpt(Struct1, index));
}

const Struct2 = struct { a: u32, b: ?u32, c: u32 };

test "comptime 2" {
    var index: usize = 0;
    try expect(!try isOpt(Struct2, index));
    index += 1;
    try expect(try isOpt(Struct2, index));
    index += 1;
    try tst.expect(!try isOpt(Struct2, index));
    index += 1;
    try expectError(error.IndexOutOfBounds, isOpt(Struct2, index));
}
