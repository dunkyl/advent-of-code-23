const std = @import("std");
const allocator = std.heap.page_allocator;

// const input =
//     \\1abc2
//     \\pqr3stu8vwx
//     \\a1b2c3d4e5f
//     \\treb7uchet
// ;

const input = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.splitSequence(u8, input, "\n");
    var values = std.ArrayList(u64).init(allocator);
    var n: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            continue;
        }
        std.debug.print("n = {}\n", .{n});
        var digits = std.ArrayList(u8).init(allocator);
        for (line) |c| {
            switch (c) {
                '0' ... '9' => {
                    try digits.append(c - '0');
                },
                else => {},
            }
        }
        var value: u64 = digits.items[0];
        value *= 10;
        value += digits.getLast();
        try values.append(value);
        n += 1;
    }
    var sum: u64 = 0;
    for (values.items) |value| {
        std.debug.print("value = {}\n", .{value});
        sum += value;
    }
    std.debug.print("sum = {}\n", .{sum});
}

