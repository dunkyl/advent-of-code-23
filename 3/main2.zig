const std = @import("std");
const allocator = std.heap.page_allocator;

const print = std.debug.print;

// const input =
//     \\467..114..
//     \\...*......
//     \\..35..633.
//     \\......#...
//     \\617*......
//     \\.....+.58.
//     \\..592.....
//     \\......755.
//     \\...$.*....
//     \\.664.598..
// ;
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

fn adjecentTo(p: Point) [8]Point {
    return [_]Point{
        .{ .x = p.x - 1, .y = p.y - 1 },
        .{ .x = p.x - 1, .y = p.y },
        .{ .x = p.x - 1, .y = p.y + 1 },
        .{ .x = p.x, .y = p.y - 1 },
        .{ .x = p.x, .y = p.y + 1 },
        .{ .x = p.x + 1, .y = p.y - 1 },
        .{ .x = p.x + 1, .y = p.y },
        .{ .x = p.x + 1, .y = p.y + 1 },
    };
}

fn findNumberSpanning(p: Point, schematic: Arr2d) ?struct { Point, isize } {
    var left = p.x;
    var right = p.x;
    while (true) {
        const cMaybe = schematic.at(Point{ .x = left, .y = p.y });
        if (cMaybe == null) {
            break;
        }
        const c = cMaybe.?;
        if (c == '.') {
            break;
        } else if (c >= '0' and c <= '9') {
            left -= 1;
        } else {
            break;
        }
    }
    while (true) {
        const cMaybe = schematic.at(Point{ .x = right, .y = p.y });
        if (cMaybe == null) {
            break;
        }
        const c = cMaybe.?;
        if (c == '.') {
            break;
        } else if (c >= '0' and c <= '9') {
            right += 1;
        } else {
            break;
        }
    }
    if (left == right) {
        return null;
    }
    return struct { Point, isize }{
        .{ .x = left + 1, .y = p.y },
        right - left - 1,
    };
}

fn sliceToNumber(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
        const c = text[i];
        const digit = c - '0';
        acc *= 10;
        acc += digit;
    }
    return acc;
}

pub fn main() !void {
    var rows = std.mem.splitSequence(u8, input, "\n");
    var maxRowLen: usize = 0;
    var rowCount: usize = 0;
    while (rows.next()) |row| {
        maxRowLen = @max(maxRowLen, row.len);
        rowCount += 1;
    }
    rows.reset();

    var schematicData = std.ArrayList(u8).init(allocator);
    while (rows.next()) |row| {
        try schematicData.appendSlice(row);
        for (0..(maxRowLen - row.len)) |i| {
            _ = i;
            try schematicData.append('.');
        }
    }
    rows.reset();
    var schematic = Arr2d{
        .data = schematicData.items,
        .stride = @bitCast(maxRowLen),
        .width = @bitCast(maxRowLen),
        .height = @bitCast(rowCount),
    };

    var partNumbersAt = std.AutoHashMap(Point, void).init(allocator);
    _ = partNumbersAt;

    var sum: usize = 0;

    for (0..rowCount) |y| {
        // print("{s}\n", .{rows.next().?});
        for (0..maxRowLen) |x| {
            const p = Point{ .x = @intCast(x), .y = @intCast(y) };

            switch (schematic.at(p).?) {
                '*' => {
                    const neighbors = adjecentTo(p);
                    var uniqueNieghborSpans = std.AutoHashMap(struct { Point, isize }, void).init(allocator);

                    for (neighbors) |n| {
                        const maybeSpan = findNumberSpanning(n, schematic);
                        if (maybeSpan == null) {
                            continue;
                        }
                        const span = maybeSpan.?;
                        try uniqueNieghborSpans.put(span, {});
                    }

                    var gearRatio: usize = 1;
                    if (uniqueNieghborSpans.count() == 2) {
                        var spansIter = uniqueNieghborSpans.keyIterator();
                        while (spansIter.next()) |span| {
                            const sliceMaybe = schematic.sliceHAt(span[0], span[1]);
                            const n = sliceToNumber(sliceMaybe.?);
                            gearRatio *= n;
                        }
                        sum += gearRatio;
                    }
                },
                else => {

                }
            }
        }
    }

    print("sum: {d}\n", .{sum});
}
