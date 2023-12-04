const std = @import("std");
const allocator = std.heap.page_allocator;

// const input =
//     // \\two1nine
//     // \\eightwothree
//     // \\abcone2threexyz
//     // \\xtwone3four
//     // \\4nineeightseven2
//     // \\zoneight234
//     // \\7pqrstsixteen
//     \\plckvxznnineh34eight2
// ;

const input = @embedFile("input.txt");

const spelled = [_][]const u8{
    "one",    "two",    "three", 
    "four",   "five",   "six",
    "seven",  "eight",  "nine"
};

pub fn main() !void {
    var lines = std.mem.splitSequence(u8, input, "\n");
    var values = std.ArrayList(u64).init(allocator);
    var n: u64 = 0;
    while (lines.next()) |line| {
    // for (23..24) |_| {
    //     const line2 = lines.next();
    //     const line = line2.?;
        if (line.len == 0) {
            continue;
        }
        std.debug.print("n = {}\n", .{n});
        var digits = std.ArrayList(u8).init(allocator);
        var wordMatchIndex = [_]u64{0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
        for (line) |c| {
            switch (c) {
                '0' ... '9' => {
                    try digits.append(c - '0');
                    for (0..10) |j| { wordMatchIndex[j] = 0;}
                },
                else => {
                    // std.debug.print("at {c}\n", .{c});
                    for (0..spelled.len) |i| {
                        const word = spelled[i];
                        var index = &wordMatchIndex[i];
                        if (index.* < word.len and word[index.*] == c) {
                            // std.debug.print("matched {c}", .{word[index.*]});
                            index.* += 1;
                            if (index.* >= word.len) {
                                // std.debug.print(": matched whole {s}", .{word});
                                try digits.append(@intCast(i+1));
                                index.* = 0;
                                // for (0..10) |j| { wordMatchIndex[j] = 0;}
                            } else {
                                // std.debug.print(": matched {d}/{d} {s}", .{index.*, word.len, word});
                            }
                            // std.debug.print("\n", .{});
                        } else if (word[0] == c) {
                            // std.debug.print("matched {c}", .{word[0]});
                            index.* = 1;
                            // std.debug.print(": matched {d}/{d} {s}", .{index.*, word.len, word});
                            // std.debug.print("\n", .{});
                        } else {
                            index.* = 0;
                        }
                    }
                },
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
        // std.debug.print("value = {}\n", .{value});
        sum += value;
    }
    std.debug.print("sum = {}\n", .{sum});
}

