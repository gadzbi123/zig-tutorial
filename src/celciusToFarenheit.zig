const std = @import("std");
const heap_alloc = std.heap.page_allocator;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(heap_alloc);
    defer std.process.argsFree(heap_alloc, args);

    if (args.len != 2) {
        return error.ValueFromArgNeeded;
    }
    const celsius = try std.fmt.parseFloat(f64, args[1]);
    try stdout.print(" celsius - {d:.2}, farenheit - {d:.2}\n", .{ celsius, calcToFahrenheit(celsius) });
}

fn calcToFahrenheit(c: f64) f64 {
    const f = c * 9.0 / 5.0 + 32.0;
    return f;
}
