const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

var global_buffer: [64 * 1024 * 1024]u8 = undefined;
pub fn main() !void {
    // const pa = std.heap.page_allocator;
    // testAllocs(pa) catch |e| std.log.err("pa failed: {}", .{e});
    var fba = std.heap.FixedBufferAllocator.init(&global_buffer);
    lbl: while (true) {
        const alloc = fba.allocator();
        testAllocs(alloc) catch |e| std.log.warn("fba failed: {}", .{e});
        fba.reset();
        continue :lbl;
    }
    // var aa = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // const alloc = aa.allocator();
    // testAllocs(alloc) catch |e| std.log.err("aa failed: {}", .{e});
    // var gpa = std.heap.GeneralPurposeAllocator(.{ .retain_metadata = true, .enable_memory_limit = true }){};
    // const alloc = gpa.allocator();
    // testAllocs(alloc) catch |e| std.log.err("gpa failed: {}", .{e});
}

fn testAllocs(alloc: std.mem.Allocator) !void {
    // const arr = std.ArrayList(u8).init(alloc);
    while (true) {
        _ = try alloc.alloc(u8, 64 * 1024);
    }
}
