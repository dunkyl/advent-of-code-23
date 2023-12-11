const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.tokenizeAny;

const print = std.debug.print;

const input2 =
    \\...#......
    \\.......#..
    \\#.........
    \\..........
    \\......#...
    \\.#........
    \\.........#
    \\..........
    \\.......#..
    \\#...#.....
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

pub fn main() !void {
    var lines = split(u8, input, "\n");

    var data = std.ArrayList(u8).init(allocator);
    defer data.deinit();

    const width: isize = @bitCast(lines.peek().?.len);

    var rowsSansGalaxies = std.ArrayList(bool).init(allocator);
    defer rowsSansGalaxies.deinit();
    var colsSansGalaxies = std.ArrayList(bool).init(allocator);
    defer colsSansGalaxies.deinit();

    var galaxies = std.ArrayList(Point).init(allocator);

    var nLines: isize = 0;
    while (lines.next()) |line| {
        try data.appendSlice(line);
        nLines += 1;
    }

    var grid = Arr2d{
        .data = data.items,
        .stride = width,
        .width = width,
        .height = nLines,
    };

    var y: isize = 0;
    var x: isize = 0;
    while (y < grid.height) {
        var rowHasGalaxy = false;
        while (x < grid.width) {
            const p = Point{ .x = x, .y = y };
            const c = grid.at(p).?;
            if (c == '#') {
                rowHasGalaxy = true;
                try galaxies.append(p);
                // print("#", .{});
            } else {
                // print(" ", .{});
            }
            x += 1;
        }
        try rowsSansGalaxies.append(rowHasGalaxy);
        // print("\n", .{});
        x = 0;
        y += 1;
    }

    x = 0;
    y = 0;
    while (x < grid.width) {
        var colHasGalaxy = false;
        while (y < grid.height) {
            const c = grid.at(.{ .x = x, .y = y }).?;
            if (c == '#') {
                colHasGalaxy = true;
            }
            y += 1;
        }
        try colsSansGalaxies.append(colHasGalaxy);
        y = 0;
        x += 1;
    }
    print("rows sans galaxies: {d}\n", .{rowsSansGalaxies.items.len});

    var total: usize = 0;
    for (0..galaxies.items.len) |i| {
        const p = galaxies.items[i];
        for (i + 1..galaxies.items.len) |j| {
            const p2 = galaxies.items[j];
            var dist: usize = 0;
            const minx = @min(p.x, p2.x);
            const maxx = @max(p.x, p2.x);
            const miny = @min(p.y, p2.y);
            const maxy = @max(p.y, p2.y);
            var xx = minx;
            while (xx < maxx) {
                if (!colsSansGalaxies.items[@bitCast(xx)]) {
                    dist += 1_000_000;
                } else {
                    dist += 1;
                }
                xx += 1;
            }

            var yy = miny;
            while (yy < maxy) {
                if (!rowsSansGalaxies.items[@bitCast(yy)]) {
                    dist += 1_000_000;
                } else {
                    dist += 1;
                }
                yy += 1;
            }
            total += dist;
            // print("from {d} to {d}: {d}\n", .{i+1, j+1, dist});
        }
    }

    print("total: {d}\n", .{total});
}
