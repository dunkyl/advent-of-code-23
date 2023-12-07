const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.splitSequence;

const print = std.debug.print;

const inputEx = @embedFile("ex1.txt");
const input = @embedFile("input.txt");

fn parseUsize(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
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

const RangeMap = struct {
    src_start: usize,
    dest_start: usize,
    len: usize,
};

fn parseRangeMap(text: []const u8) !RangeMap {
    var rangeItems = try parseEach(usize, parseUsize, text, " ");
    var rangeMap = RangeMap{
        .src_start = rangeItems.items[0],
        .dest_start = rangeItems.items[1],
        .len = rangeItems.items[2],
    };
    return rangeMap;
}

fn applyRangeMap(n: usize, m: RangeMap) usize {
    if (n < m.src_start or n >= m.src_start + m.len) {
        return n;
    }
    return m.dest_start + (n - m.src_start);
}
fn applyRangeMaps(n: usize, ms: []RangeMap) usize {
    for (ms) |m| {
        if (n >= m.src_start and n < m.src_start + m.len) {
            return m.dest_start + (n - m.src_start);
        }
    }
    return n;
}

pub fn main() !void {
    var lines = split(u8, input, "\n");

    var seedsIter = split(u8, lines.next().?, ":");
    _ = lines.next().?; // skip blank
    _ = seedsIter.next().?; // skip label
    var seeds = try parseEach(usize, parseUsize, seedsIter.next().?, " ");

    print("SEEDS {any}\n", .{seeds.items});

    var mapsList = std.ArrayList(std.ArrayList(RangeMap)).init(allocator);

    for (0..7) |i| {
        _ = i;
        var maps = std.ArrayList(RangeMap).init(allocator);
        _ = lines.next().?;
        while (lines.next()) |line| {
            if (line.len == 0) break;
            try maps.append(try parseRangeMap(line));
        }
        try mapsList.append(maps);
    }

    var lowest: usize = 2 << 32;
    for (0..1_000_000_000) |loc| {
        if (loc % 10_000_000 == 0) print("... LOC {d}\n", .{loc});
        var seed = loc;
        for (0..mapsList.items.len) |mi| {
            const maps = mapsList.items[mapsList.items.len - mi - 1];
            seed = applyRangeMaps(seed, maps.items);
            // print("  MAP {d}:  {d}\n", .{mi, seed});
        }
        for (0..seeds.items.len/2) |si| {
            const low = seeds.items[si*2];
            const high = seeds.items[si*2+1]+low;
            if (seed >= low and seed < high) {
                // print("LOC {d} <- SEED {d}\n", .{loc, seed});
                if (loc < lowest) lowest = loc;
            }
        }
    }
    print("LOWEST {d}\n", .{lowest});
}
