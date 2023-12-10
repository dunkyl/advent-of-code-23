const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 =
    \\-L|F7
    \\7S-7|
    \\L|7||
    \\-L-J|
    \\L|-JF
;
const input3 =
    \\..F7.
    \\.FJ|.
    \\SJ.L7
    \\|F--J
    \\LJ...
;
const input = @embedFile("input.txt");

const Arr2d = struct {
    data: []u8,
    stride: isize,
    width: isize,
    height: isize,

    pub fn at(self: Arr2d, p: Point) ?u8 {
        if (p.x < 0 or p.y < 0 or p.x >= self.width or p.y >= self.height) {
            return null;
        }
        const index = p.y * self.stride + p.x;
        return self.data[@bitCast(index)];
    }

    pub fn sliceHAt(self: Arr2d, p: Point, len: isize) ?[]u8 {
        if (p.x < 0 or p.y < 0 or p.x >= self.width or p.y >= self.height) {
            print("out of bounds: {d} {d}\n", p);
            return null;
        }
        if (p.x + len - 1 >= self.width) {
            print("out of range: {d} {d}\n", .{p.x, p.y});
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
const START: u8 = 255;

const DIRS = [4]u8{RIGHT, UP, LEFT, DOWN};
const OPP = [4]u8{LEFT, DOWN, RIGHT, UP};
const OFFSETS = [4]Point{
    .{.x=1, .y=0},
    .{.x=0, .y=-1},
    .{.x=-1,.y= 0},
    .{.x=0, .y=1},
};

fn findAdjacent(grid: Arr2d, p: Point) [2]Point {
    const connect = grid.at(p).?;
    var outIndex: usize = 0;
    var out = [2]Point{.{.x=0, .y=0}, .{.x=0, .y=0}};
    for (0..4) |i| {
        const other = grid.at(.{.x=p.x + OFFSETS[i].x, .y=p.y + OFFSETS[i].y});
        if (other == null) {
            continue;
        }
        if (other.? & OPP[i] != 0 and connect & DIRS[i] != 0) {
            out[outIndex].x = p.x + OFFSETS[i].x;
            out[outIndex].y = p.y + OFFSETS[i].y;
            outIndex += 1;
        }
        if (outIndex == 2) {
            break;
        }
    }
    if (outIndex != 2) {
        print("not enough adjacent: {d} {d}\n", .{p.x, p.y});
        return [2]Point{.{.x=0, .y=0}, .{.x=0, .y=0}};
    }
    return out;
}

pub fn main() !void {
    var lines = split(u8, input, "\n");

    const width: isize = @bitCast(lines.peek().?.len);

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    var nLines: isize = 0;
    var start = Point{.x = 0, .y = 0};
    while (lines.next()) |line| {
        for (0..line.len) |i| {
            try data.append(
                switch (line[i]) {
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
                }
            );
        }
        nLines += 1;
    }

    var grid = Arr2d{
        .data = data.items,
        .stride = width,
        .width = width,
        .height = nLines,
    };

    var prev = [_]Point{start, start};
    var current = findAdjacent(grid, start);
    var steps: usize = 1;
    while (true) {
        steps += 1;
        for (0..2) |i| {
            const nexts = findAdjacent(grid, current[i]);
            const next = if (std.meta.eql( nexts[0], prev[i])) nexts[1] else nexts[0];
            prev[i] = current[i];
            current[i] = next;
        }
        if (std.meta.eql( current[0], current[1])) {
            break;
        }
    }
    print("start: {any}\n", .{start});
    print("end: {any}\nsteps: {d}\n", .{current[0], steps});
}