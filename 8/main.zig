const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 = 
    \\RL
    \\
    \\AAA = (BBB, CCC)
    \\BBB = (DDD, EEE)
    \\CCC = (ZZZ, GGG)
    \\DDD = (DDD, DDD)
    \\EEE = (EEE, EEE)
    \\GGG = (GGG, GGG)
    \\ZZZ = (ZZZ, ZZZ)
;
const input3 =
    \\LLR
    \\
    \\AAA = (BBB, BBB)
    \\BBB = (AAA, ZZZ)
    \\ZZZ = (ZZZ, ZZZ)
;
const input = @embedFile("input.txt");

pub fn main() !void {
    var lines = split(u8, input, "\n");

    const directions = lines.next().?;

    var graph = std.AutoHashMap([3]u8, [2][3]u8).init(allocator);
    defer graph.deinit();

    while (lines.next()) |line| {
        var iter = split(u8, line, " =(,)");
        var node = iter.next().?[0..3].*;
        var left = iter.next().?[0..3].*;
        var right = iter.next().?[0..3].*;
        var branch = [2][3]u8 { left, right };
        try graph.put(node, branch);
    }

    var current: [3]u8 = "AAA".*;
    var steps: usize = 0;
    while(!std.mem.eql(u8, &current, "ZZZ")) {
        const dir = directions[steps % directions.len];
        // print("At {s} going {c}\n", .{current, dir});
        current = graph.get(current).?[dir / ('L' + 1)];
        steps += 1;
    }

    print("Steps: {d}\n", .{steps});
}