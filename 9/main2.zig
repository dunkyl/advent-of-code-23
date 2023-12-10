const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 =
    \\0 3 6 9 12 15
    \\1 3 6 10 15 21
    \\10 13 16 21 30 45
;
const input = @embedFile("input.txt");

fn parseIsize(text: []const u8) isize {
    var acc: isize = 0;
    var sign: isize = 1;
    for (0..text.len) |i| {
        if (text[i] == '-') {
            sign = -1;
            continue;
        }
        if (text[i] > '9' or text[i] < '0') break;
        acc = 10 * acc + text[i] - '0';
    }
    return sign * acc;
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

pub fn main() !void {
    var lines = split(u8, input, "\n");

    var sum: isize = 0;

    while (lines.next()) |line| {
        var history = try parseEach(isize, parseIsize, line, " ");
        defer history.deinit();

        var diffSeqs = std.ArrayList(std.ArrayList(isize)).init(allocator);
        try diffSeqs.append(history);
        // print("{any}\n", .{history.items});
        while (true) {
            var last = diffSeqs.getLast().items;
            var diffs = try std.ArrayList(isize).initCapacity(allocator, last.len - 1);
            var allZero = true;
            for (last[0 .. last.len - 1], last[1..]) |prevItem, item| {
                var diff = item - prevItem;
                allZero = diff == 0 and allZero;
                // print("{d}  ", .{diff});
                try diffs.append(diff);
            }
            if (allZero) break;
            try diffSeqs.append(diffs);
        }

        var prediction: isize = 0;
        // print("{d}", .{prediction});
        for (0..diffSeqs.items.len) |i| {
            var diffs = diffSeqs.items[diffSeqs.items.len - 1 - i];
            var first = diffs.items[0];
            prediction = first - prediction;
            // print(" + {d}", .{last});
        }
        // print("\nprediction: {d}\n", .{prediction});

        sum += prediction;
    }

    print("sum: {d}\n", .{sum});
}
