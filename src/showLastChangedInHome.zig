const std = @import("std");
const EntryKind = std.fs.Dir.Entry.Kind;
const memEql = std.mem.eql;
const parseInt = std.fmt.parseInt;
const stdOutWriter = std.io.getStdOut().writer();

const file_time = struct {
    file: []u8,
    time: i128,
};
pub const LimitedArrayList = struct {
    list: std.ArrayList(file_time),
    max_size: usize,

    pub fn init(allocator: std.mem.Allocator, max_size: usize) LimitedArrayList {
        return LimitedArrayList{ .list = std.ArrayList(file_time).init(allocator), .max_size = max_size };
    }

    pub fn deinit(self: *LimitedArrayList) void {
        self.list.deinit();
    }

    pub fn append(self: *LimitedArrayList, item: file_time) !void {
        if (self.list.items.len >= self.max_size) {
            for (self.list.items, 0..) |ft, i| {
                if (item.time > ft.time) {
                    var alloc = self.list.allocator;
                    try self.list.append(item);
                    const removed_ft = self.list.swapRemove(i);
                    alloc.free(removed_ft.file);
                    return;
                }
            }
            return;
        }
        try self.list.append(item);
    }

    pub fn print(self: *LimitedArrayList) !void {
        for (self.list.items) |item| {
            try stdOutWriter.print("{s} ", .{item.file});
            try printNiceTime(item.time);
        }
    }
};
const DIR = "/home/gadzbi/proj/";
pub fn main() !void {
    const GenPurpAlloc = std.heap.GeneralPurposeAllocator(.{
        .enable_memory_limit = true,
        .never_unmap = true,
        .retain_metadata = true,
    });
    var gpa = GenPurpAlloc{};
    gpa.setRequestedMemoryLimit(64 * 1024 * 1024);
    const main_alloc = gpa.allocator();

    const args = try std.process.argsAlloc(main_alloc);
    var last_mod_size: usize = 5;
    for (args, 0..) |arg, i| {
        if (memEql(u8, arg, "-n")) {
            if (i + 1 >= args.len) break;
            last_mod_size = parseInt(usize, args[i + 1], 10) catch {
                try stdOutWriter.print("failed to parse -n value", .{});
                break;
            };
        }
    }
    std.process.argsFree(main_alloc, args);

    var last_modified = LimitedArrayList.init(main_alloc, last_mod_size);
    defer last_modified.deinit();
    var mdir = std.fs.openDirAbsolute(DIR, .{ .iterate = true }) catch |err| {
        std.log.err("can't access home dir", .{});
        return err;
    };
    defer mdir.close();
    var walker = try mdir.walk(main_alloc);
    defer walker.deinit();
    var entry = try walker.next();
    while (entry != null) {
        switch (entry.?.kind) {
            EntryKind.file => {
                const file_path = try std.mem.concat(main_alloc, u8, &[_][]const u8{ DIR, entry.?.path });
                errdefer main_alloc.free(file_path);
                var file = try entry.?.dir.openFile(file_path, .{ .mode = .read_only });
                defer file.close();
                const file_stat = try file.stat();
                try last_modified.append(.{ .file = file_path, .time = file_stat.mtime });
            },
            else => {},
        }
        entry = try walker.next();
    }
    try last_modified.print();
}

fn printNiceTime(time_stamp: i128) !void {
    const secsFromUnix = @divTrunc(time_stamp, std.time.ns_per_s);
    const timezone_offset = 3600;
    const epoch_seconds = std.time.epoch.EpochSeconds{ .secs = @intCast(secsFromUnix + timezone_offset) };
    const epoch_day = epoch_seconds.getEpochDay();
    const day_seconds = epoch_seconds.getDaySeconds();
    const year_day = epoch_day.calculateYearDay();
    const month_day = year_day.calculateMonthDay();
    const time = .{ year_day.year, month_day.month.numeric(), month_day.day_index, day_seconds.getHoursIntoDay(), day_seconds.getMinutesIntoHour(), day_seconds.getSecondsIntoMinute() };
    try stdOutWriter.print("{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2} UTC\n", time);
}
