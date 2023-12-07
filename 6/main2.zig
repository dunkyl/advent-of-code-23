const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.splitSequence;

const print = std.debug.print;

const inputEx =
    \\Time:      7  15   30
    \\Distance:  9  40  200
;
const input = @embedFile("input.txt");

fn parseUsize(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
        if (text[i] > '9' or text[i] < '0') continue;
        acc = 10 * acc + text[i] - '0';
    }
    return acc;
}

fn parseEach(comptime t: type, fnEach: fn ([]const u8) t, text: []const u8, delim: []const u8) !std.ArrayList(t) {
    var iter = split(u8, text, delim);
    var results = std.ArrayList(t).init(allocator);
    while (iter.next()) |itemText| {
        if (itemText.len == 0) continue;
        try results.append(fnEach(itemText));
    }
    return results;
}

fn race(maxTime: usize, record: usize) usize {
    const fRecord: f64 = @floatFromInt(record);
    const fTime: f64 = @floatFromInt(maxTime);
    const mid = fTime / 2.0;
    const radius = @sqrt(fTime * fTime - 4 * fRecord) / 2;

    const min = @ceil(mid - radius + 0.00001);
    const max = @floor(mid + radius - 0.00001);

    print("  min = {}, max = {}\n", .{ mid - radius, mid + radius });
    const mn: usize = @intFromFloat(min);
    const mx: usize = @intFromFloat(max);
    print("  min = {}, max = {}\n", .{ mn, mx });

    return @intFromFloat((1 + max - min));
}

pub fn main() !void {
    var lines = split(u8, input, "\n");

    var timeIter = split(u8, lines.next().?, ":");
    _ = timeIter.next().?;

    var distIter = split(u8, lines.next().?, ":");
    _ = distIter.next().?;

    const time = parseUsize(timeIter.next().?);
    const record = parseUsize(distIter.next().?);
    print("T = {}, R = {}\n", .{ time, record});
    const ways = race(time, record);
    print("Ways = {}\n", .{ways});
}
