const std = @import("std");
const expectEqual = std.testing.expectEqual;

const NormalStruct = packed struct {
    a: u8,
    b: u16,
    c: u16,
};
test "packed 5 byte struct" {
    var s: NormalStruct = NormalStruct{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(1) u16 = &s.b; // You should be able to use align(8:8:5) but it is not allowed
    // We have error here. left = 1 and right = 8
    try expectEqual(@typeInfo(@TypeOf(ptr)).pointer.alignment, @alignOf(@TypeOf(ptr)));
}
test "packed 5 byte struct (alignCast)" {
    var s: NormalStruct = NormalStruct{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(8:8:5) u16 = @alignCast(&s.b); // error: pointer host size '0' cannot coerce into pointer host size '5'
    const ptr2: *align(0:8:5) u16 = @alignCast(&s.b); // error: alignment must be >= 1
    _ = ptr;
    _ = ptr2;
}

const UnalignedStruct = packed struct {
    a: u9, // different from NormalStruct
    b: u16,
    c: u16,
};
test "packed 5 byte and 1 bit struct (6 bytes total)" {
    var s: UnalignedStruct = UnalignedStruct{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(8:9:6) u16 = &s.b;
    // In align(A:B:C) mean:
    // A - pointer alignment - the alignment of the pointer in bytes (can be 2^n but less then 2<<29)
    // B - pointer bit offset - the bit at which data from that pointer starts at (0 based)
    // C - pointer host size - the size of the acctual data (in bytes), that is pointed to.
    try expectEqual(@typeInfo(@TypeOf(ptr)).pointer.alignment, @alignOf(@TypeOf(ptr)));
}

const UnalignedStruct2 = packed struct {
    a: u7, // different from NormalStruct
    b: u16,
    c: u16,
};
test "packed 4 byte and 7 bit struct (5 bytes total)" {
    var s: UnalignedStruct2 = UnalignedStruct2{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(8:7:5) u16 = &s.b;
    std.debug.print("child-alignment: {}\n", .{@alignOf(@typeInfo(@TypeOf(ptr)).pointer.child)});
    try expectEqual(@typeInfo(@TypeOf(ptr)).pointer.alignment, @alignOf(@TypeOf(ptr)));
}
