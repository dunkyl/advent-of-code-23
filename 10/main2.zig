const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 =
    \\..........
    \\.S------7.
    \\.|F----7|.
    \\.||....||.
    \\.||....||.
    \\.|L-7F-J|.
    \\.|..||..|.
    \\.L--JL--J.
    \\..........
;
const input3 =
    \\.F----7F7F7F7F-7....
    \\.|F--7||||||||FJ....
    \\.||.FJ||||||||L7....
    \\FJL7L7LJLJ||LJ.L-7..
    \\L--J.L7...LJS7F-7L7.
    \\....F-J..F7FJ|L7L7L7
    \\....L7.F7||L7|.L7L7|
    \\.....|FJLJ|FJ|F7|.LJ
    \\....FJL-7.||.||||...
    \\....L---J.LJ.LJLJ...
;
const input4 =
    \\FF7FSF7F7F7F7F7F---7
    \\L|LJ||||||||||||F--J
    \\FL-7LJLJ||||||LJL-77
    \\F--JF--7||LJLJ7F7FJ-
    \\L---JF-JLJ.||-FJLJJ7
    \\|F|F-JF---7F7-L7L|7|
    \\|FFJF7L7F-JF7|JL---7
    \\7-L-JL7||F7|L7F-7F7|
    \\L.L7LFJ|||||FJL7||LJ
    \\L7JLJL-JLJLJL--JLJ.L
;
const input = @embedFile("input.txt");

const Arr2d = struct {
    data: []u8,
    stride: isize,
    width: isize,
    height: isize,

    pub fn at(self: Arr2d, p: Point) ?*u8 {
        if (p.x < 0 or p.y < 0 or p.x >= self.width or p.y >= self.height) {
            return null;
        }
        const index = p.y * self.stride + p.x;
        return &self.data[@bitCast(index)];
    }

    pub fn sliceHAt(self: Arr2d, p: Point, len: isize) ?[]u8 {
        if (p.x < 0 or p.y < 0 or p.x >= self.width or p.y >= self.height) {
            print("out of bounds: {d} {d}\n", p);
            return null;
        }
        if (p.x + len - 1 >= self.width) {
            print("out of range: {d} {d}\n", .{ p.x, p.y });
            return null;
        }
        const index = p.y * self.stride + p.x;
        return self.data[@bitCast(index)..@bitCast(index + len)];
    }
};

const Point = struct {
    x: isize,
    y: isize,
};

const RIGHT: u8 = 1;
const UP: u8 = 2;
const LEFT: u8 = 4;
const DOWN: u8 = 8;
const IS_PATH: u8 = 16;
const IS_ENCLOSED: u8 = 32;
const START: u8 = 255;


const DIRS = [4]u8{ RIGHT, UP, LEFT, DOWN };
const OPP = [4]u8{ LEFT, DOWN, RIGHT, UP };
const OFFSETS = [4]Point{
    .{ .x = 1, .y = 0 },
    .{ .x = 0, .y = -1 },
    .{ .x = -1, .y = 0 },
    .{ .x = 0, .y = 1 },
};

fn findAdjacent(grid: Arr2d, p: Point) [2]Point {
    const connect = grid.at(p).?.*;
    var outIndex: usize = 0;
    var out = [2]Point{ .{ .x = 0, .y = 0 }, .{ .x = 0, .y = 0 } };
    for (0..4) |i| {
        const other = grid.at(.{ .x = p.x + OFFSETS[i].x, .y = p.y + OFFSETS[i].y });
        if (other == null) {
            continue;
        }
        if (other.?.* & OPP[i] != 0 and connect & DIRS[i] != 0) {
            out[outIndex].x = p.x + OFFSETS[i].x;
            out[outIndex].y = p.y + OFFSETS[i].y;
            outIndex += 1;
        }
        if (outIndex == 2) {
            break;
        }
    }
    if (outIndex != 2) {
        print("not enough adjacent: {d} {d}\n", .{ p.x, p.y });
        return [2]Point{ .{ .x = 0, .y = 0 }, .{ .x = 0, .y = 0 } };
    }
    return out;
}

pub fn main() !void {
    var lines = split(u8, input, "\n");

    const width: isize = @bitCast(lines.peek().?.len);

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    var nLines: isize = 0;
    var start = Point{ .x = 0, .y = 0 };
    while (lines.next()) |line| {
        for (0..line.len) |i| {
            try data.append(switch (line[i]) {
                '|' => UP | DOWN,
                '-' => LEFT | RIGHT,
                'F' => RIGHT | DOWN,
                '7' => LEFT | DOWN,
                'J' => LEFT | UP,
                'L' => RIGHT | UP,
                'S' => s: {
                    start.x = @bitCast(i);
                    start.y = nLines;
                    break :s START;
                },
                else => 0,
            });
        }
        nLines += 1;
    }

    var grid = Arr2d{
        .data = data.items,
        .stride = width,
        .width = width,
        .height = nLines,
    };

    var prev = [_]Point{ start, start };
    var current = findAdjacent(grid, start);
    var steps: usize = 1;
    print("start: {any}\n", .{start});
    print("current: {any}\n", .{current});

    var k = IS_PATH;
    for (0..2) |i| {
        grid.at(current[i]).?.* |= IS_PATH;
        
        if (current[i].x == start.x) {
            if (current[i].y > start.y) {
                print("  current[{d}] is down\n", .{i});
                k |= DOWN;
            } else {
                print("  current[{d}] is up\n", .{i});
                k |= UP;
            }
        } else {
            if (current[i].x > start.x) {
                print("  current[{d}] is right\n", .{i});
                k |= RIGHT;
            } else {
                print("  current[{d}] is left\n", .{i});
                k |= LEFT;
            }
        }
    }
    grid.at(start).?.* = k;

    print("start: {any}\n", .{grid.at(start).?.*});
    
    
    while (true) {
        steps += 1;
        for (0..2) |i| {
            const nexts = findAdjacent(grid, current[i]);
            const next = if (std.meta.eql(nexts[0], prev[i])) nexts[1] else nexts[0];
            prev[i] = current[i];
            current[i] = next;
        }
        grid.at(current[0]).?.* |= IS_PATH;
        grid.at(current[1]).?.* |= IS_PATH;
        if (std.meta.eql(current[0], current[1])) {
            break;
        }
    }
    
    print("end: {any}\nsteps: {d}\n", .{ current[0], steps });

    var enclosed: usize = 0;
    var x: isize = 0;
    var y: isize = 0;
    while (y < grid.height) {
        while(x < grid.width) {
            const p = Point{ .x = x, .y = y };
            const c = grid.at(p).?.*;
            if (c & IS_PATH == 0) {
                var crosses: usize = 0;
                var x2 = x + 1;
                while (x2 < grid.width) {
                    const p2 = Point{ .x = x2, .y = y };
                    const c2 = grid.at(p2).?.*;
                    if (c2 & (UP) != 0 and c2 & IS_PATH != 0) {
                        crosses += 1;
                    }
                    x2 += 1;
                }
                if (crosses % 2 == 1) {
                    enclosed += 1;
                    grid.at(p).?.* |= IS_ENCLOSED;
                }
            }
            x += 1;
            // print("{d} {d}\n", .{ x, y });
        }
        x = 0;
        y += 1;
    }

    print("enclosed: {d}\n", .{ enclosed });

    x = 0;
    y = 0;
    while (y < grid.height) {
        while(x < grid.width) {
            const p = Point{ .x = x, .y = y };
            const c = grid.at(p).?.*;
            if (c & IS_PATH != 0) {
                print(".", .{});
            } else if (c & IS_ENCLOSED != 0) {
                print("O", .{});
            } else {
                print(" ", .{});
            }
            x += 1;
        }
        print("\n", .{});
        x = 0;
        y += 1;
    }
    
    
}
