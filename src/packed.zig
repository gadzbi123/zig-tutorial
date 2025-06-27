const std = @import("std");

const S = packed struct {
    a: u3,
    b: bType,
    c: u2,
};
const bType = u2;

pub fn main() void {
    var s: S = S{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(1:3:1) bType = &s.b;
    const val: bType = ptr.*;
    std.debug.print("ptr = {}\n", .{ptr});
    std.debug.print("val = {}\n", .{val});
    std.debug.print("@typeInfo(ptr) = {}\n", .{@typeInfo(@TypeOf(ptr))});
}

const bType2 = u5;
const S2 = packed struct {
    a: u4,
    b: bType2,
    c: u6,
};
test "packed 2 byte struct" {
    var s: S2 = S2{ .a = 1, .b = 2, .c = 3 };
    var s2 align(4) = s;
    const ptr2: *align(4:4:2) bType2 = &s2.b;
    std.debug.print("ptr = {}\n", .{ptr2});
    const ptr: *align(2:4:2) bType2 = &s.b;
    std.debug.print("ptr = {}\n", .{ptr});
    const val: bType2 = ptr.*;
    std.debug.print("val = {}\n", .{val});
    std.debug.print("@typeInfo(ptr) = {}\n", .{@typeInfo(@TypeOf(ptr))});
}

const bType3 = u9;
const S3 = packed struct {
    a: u9,
    b: bType3,
    c: u3,
};
test "packed 3 byte struct" {
    var s: S3 = S3{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(4:9:3) bType3 = &s.b;
    const val: bType3 = ptr.*;
    std.debug.print("ptr = {}\n", .{ptr});
    std.debug.print("val = {}\n", .{val});
    std.debug.print("@typeInfo(ptr) = {}\n", .{@typeInfo(@TypeOf(ptr))});
}

const bType4 = u16;
const S4 = packed struct {
    a: u8,
    b: bType4,
    c: u16,
};
test "packed 5 byte struct" {
    var s: S4 = S4{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(1) bType4 = &s.b;
    const val: bType4 = ptr.*;
    std.debug.print("ptr = {}\n", .{ptr});
    std.debug.print("val = {}\n", .{val});
    std.debug.print("@typeInfo(ptr) = {}\n", .{@typeInfo(@TypeOf(ptr))});
}

const bType5 = u16;
const S5 = packed struct {
    a: u9,
    b: bType5,
    c: u16,
};
test "packed 5 byte struct ?" {
    var s: S5 = S5{ .a = 1, .b = 2, .c = 3 };
    const ptr: *align(8:9:6) bType5 = &s.b;
    const val: bType5 = ptr.*;
    std.debug.print("ptr = {}\n", .{ptr});
    std.debug.print("val = {}\n", .{val});
    std.debug.print("@typeInfo(ptr) = {}\n", .{@typeInfo(@TypeOf(ptr))});
}
