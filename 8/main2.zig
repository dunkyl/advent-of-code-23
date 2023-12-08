const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 =
    \\LR
    \\
    \\11A = (11B, XXX)
    \\11B = (XXX, 11Z)
    \\11Z = (11B, XXX)
    \\22A = (22B, XXX)
    \\22B = (22C, 22C)
    \\22C = (22Z, 22Z)
    \\22Z = (22B, 22B)
    \\XXX = (XXX, XXX)
;
const input = @embedFile("input.txt");

fn lcm(a: usize, b: usize) usize {
    return a * b / std.math.gcd(a, b);
}

pub fn main() !void {
    var lines = split(u8, input, "\n");

    const directions = lines.next().?;

    var graph = std.AutoHashMap([3]u8, [2][3]u8).init(allocator);
    defer graph.deinit();

    var starts = std.ArrayList([3]u8).init(allocator);

    while (lines.next()) |line| {
        var iter = split(u8, line, " =(,)");
        var node = iter.next().?[0..3].*;
        var left = iter.next().?[0..3].*;
        var right = iter.next().?[0..3].*;
        var branch = [2][3]u8{ left, right };
        try graph.put(node, branch);

        if (node[2] == 'A') {
            try starts.append(node);
        }
    }

    
    var phases = std.ArrayList(?usize).init(allocator);
    var periods = std.ArrayList(?usize).init(allocator);
    var periodsFound: usize = 0;
    for (0..starts.items.len) |_| {
        try phases.append(null);
        try periods.append(null);
    }

    

    var steps: usize = 0;
    var currents = try starts.clone();
    while (true) {
        const dir = directions[steps % directions.len];
        
        for (0..starts.items.len) |i| {
            if (periods.items[i] != null) continue;
            // print("At {s} going {c}\n", .{current, dir});
            currents.items[i] = graph.get(currents.items[i]).?[dir / ('L' + 1)];
            if (currents.items[i][2] == 'Z') {
                if (phases.items[i] == null) {
                    phases.items[i] = steps + 1;
                } else {
                    periods.items[i] = steps - phases.items[i].? + 1;
                    periodsFound += 1;
                }
            }
        }
        if (periodsFound == currents.items.len) {
            break;
        }
        steps += 1;
        
        
    }
    print("Found all periods step {d}\n", .{steps});
    var periodLcm: usize = 1;
    for (0..periods.items.len) |i| {
        print("Start: {s} Phase: {d} Period: {d}\n", .{ starts.items[i], phases.items[i].?, periods.items[i].?});
        periodLcm = lcm(periodLcm, periods.items[i].?);
    }
    print("Period LCM: {d}\n", .{periodLcm});

    steps = 0;
    while (true) {
        var zs: usize = 0;
        for (0..starts.items.len) |i| {
            const thisIndex = (steps - phases.items[i].?) % periods.items[i].?;
            // print("  {s} is index {d}\n", .{currents.items[i], thisIndex});
            if (thisIndex == 0) {
                zs += 1;
            }
        }
        if (zs == starts.items.len) {
            break;
        }
        steps += periodLcm;
    }

    

    print("Steps: {d}\n", .{steps});
}
