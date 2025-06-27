const std = @import("std");
const testing = std.testing;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const test_alloc = std.testing.allocator;
const eql = std.mem.eql;

pub fn main2() !void {
    // std.debug.print("Hi bud: {s}\n", .{"nigga"});
    // var my_var = @as(u32, 5);
    // my_var += 1;
    // const my_const = @as(i32, 2);
    // try testing.expectEqual(my_var + my_const, 8);

    // const arr1 = [_]u8{ 'a', 'b', 'c' };
    // std.debug.print("arr: {any}\n", .{arr1});
    // var start: u8 = 0;
    // while (start < 10) : (start += 2) {
    //     if (start >= arr1.len) break;
    //     start += if (arr1[start] == 'c') 2 else 1;
    // }
    // std.debug.print("start={}\n", .{start});

    const string = [_]u8{ 'a', 'l', 'e', 'k' };
    for (string) |c| {
        const new_c = toUpperCaseSwitch(c);
        std.debug.print("new char: {c}\n", .{new_c});
    }
    const err = error{ TooLongString, EmptyString, IllegalChar };
    try testing.expect(err.TooLongString != err.EmptyString);

    // const maybe_str1: err!*const [14]u8 = "veryLongString";
    const maybe_str1: err!void = err.TooLongString;
    const strOrEmpty = maybe_str1 catch |e| {
        try testing.expect(e == err.TooLongString);
    };
    _ = strOrEmpty;
    // std.debug.print("str: {s}\n", .{strOrEmpty});

    var x: u8 = 223;
    switch (x) {
        //statement
        0...221 => {
            x = 0;
        },
        //expression
        222, 223 => x = 255,
        else => {},
    }
    try testing.expect(x == 255);
    std.debug.print("x is {}\n", .{x});

    const arr1 = [_]u8{ 'a', 'b', 'c' };
    var start: u8 = 0;
    // @setRuntimeSafety(false)
    while (start < 100) : (start += 1) {
        if (start >= arr1.len) break;
        std.debug.print("char: {}\n", .{arr1[start]});
        start += if (arr1[start] == 'c') 1 else 0;
    }
    std.debug.print("start = {any}\n", .{start});
    // var my_val: i32 = 0x123456;
    // var my_ptr: *i32 = &my_val;
    // my_ptr.* = 1;
    // std.debug.print("my_ptr= {}", .{my_ptr.*});
}

const Dirs = enum {
    up,
    down,
    left,
    right,
    pub fn getOpposite(self: Dirs) Dirs {
        return switch (self) {
            Dirs.up => Dirs.down,
            Dirs.down => Dirs.up,
            Dirs.left => Dirs.right,
            Dirs.right => Dirs.left,
        };
    }
};
test "get right opposite" {
    try expect(Dirs.down == Dirs.getOpposite(Dirs.up));
    try expect(Dirs.left != Dirs.getOpposite(Dirs.left));
}

const Vec3 = struct { x: f32, y: f32, z: f32 = 0 };
test "vec work" {
    const my_vec = Vec3{ .x = 5, .y = 19 };
    _ = my_vec;
}

const Age = union {
    exact: f64,
    roundDown: u32,
};

/// Order of values matter
const CurrentDirectionValues = union(Dirs) {
    up: bool,
    down: bool,
    left: i32,
    right: i32,
};

test "union test" {
    const KacperAge = Age{ .roundDown = 24 };
    std.debug.print("Kacper Age = {}\n", .{KacperAge.roundDown});
    // std.debug.print("Kacper Age = {}\n", .{KacperAge.exact}); //Cant do that
    const cd = CurrentDirectionValues{ .left = 42 };
    std.debug.print("Dir = {}\n", .{cd});
}

test "labled yield" {
    const added = blk: {
        var added_val: i32 = 32;
        var i: i32 = 0;
        while (i < 10) : (i += 1) added_val += 12;
        break :blk added_val;
    };
    try expectEqual(152, added);
}
test "arraylist with alloc" {
    var arr = std.ArrayList(i32).init(test_alloc);
    defer arr.deinit();
    try arr.append(2);
    try arr.appendSlice(&[_]i32{ 1, 2, 3, 4, 5 });
    arr.items[0] = 5;
    try testing.expect(eql(i32, &[_]i32{ 5, 1, 2, 3, 4, 5 }, arr.items));
}

test "const pointers" {
    var x: [100]u8 = [_]u8{ 1, 2 } ** 50;
    const y: [*]u8 = &x;
    y[1] = 5;
    y[55] = 5;
    try testing.expect(x[1] == 5);
    try testing.expect(x[55] == 5);
}

fn toUpperCaseLetter(c: u8) u8 {
    if (c >= 97 and c <= 122) {
        return c - 32;
    } else {
        return c;
    }
}

fn toUpperCaseSwitch(c: u8) u8 {
    return switch (c) {
        'a'...'z' => c - ('a' - 'A'),
        else => c,
    };
}
