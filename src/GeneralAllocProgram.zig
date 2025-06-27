const std = @import("std");

const Person = struct { name: []u8, age: u8 };
var global_buffer: [64 * 1024]u8 = undefined;
pub fn main() !void {
    // var fba = std.heap.FixedBufferAllocator.init(&global_buffer);
    // const main_alloc = fba.allocator();
    var main_alloc = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
        .never_unmap = true,
        .retain_metadata = true,
    }){};
    defer {
        const check = main_alloc.deinit();
        std.debug.print("has leak = {}", .{check});
    }

    main_alloc.setRequestedMemoryLimit(1000);
    var parena = std.heap.ArenaAllocator.init(main_alloc.allocator());
    defer {
        parena.deinit();
        std.debug.print("freed arena", .{});
    }
    const person_arena = parena.allocator();
    var i: usize = 0;
    while (true) {
        i += 1;
        std.debug.print("Creating person {}, buff_size = {}", .{ i, i * @sizeOf(Person) });
        _ = person_arena.create(Person) catch break;
        // defer alloc.destroy(p);
    }
}
