const std = @import("std");
const allocator = std.heap.page_allocator;

// const input =
//     \\Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
//     \\Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
//     \\Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
//     \\Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
//     \\Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
// ;
const input = @embedFile("input.txt");

const Round = struct {
    countsByColor: std.StringHashMap(u64),
};
const Game = struct {
    rounds: std.ArrayList(Round),
};

fn parseGame(text: []const u8) !struct {u64, Game} {
    var gameAndRounds = std.mem.splitAny(u8, text, ":");
    var gameAndId = std.mem.splitAny(u8, gameAndRounds.next().?, " ");
    _ = gameAndId.next().?;
    const gameId = try std.fmt.parseUnsigned(u64, gameAndId.next().?, 10);
    var roundsTexts = std.mem.splitAny(u8, gameAndRounds.next().?, ";");
    var rounds = std.ArrayList(Round).init(allocator);
    while (roundsTexts.next()) |roundText| {
        var countsByColor = std.StringHashMap(u64).init(allocator);
        var roundTokens = std.mem.splitAny(u8, roundText, " ,");
        while (roundTokens.next()) |token| {
            if (token.len == 0) {
                continue;
            }
            var count = try std.fmt.parseUnsigned(u64, token, 10);
            var color = roundTokens.next().?;
            try countsByColor.put(color, count);
        }
        try rounds.append(.{ .countsByColor = countsByColor });
        
    }
    return .{ gameId, .{ .rounds = rounds } };
}

pub fn main() !void {
    var maxByColor = std.StringHashMap(u64).init(allocator);
    try maxByColor.put("red", 12);
    try maxByColor.put("green", 13);
    try maxByColor.put("blue", 14);

    var games = std.AutoHashMap(u64, Game).init(allocator);

    var roundsTexts = std.mem.tokenizeSequence(u8, input, "\n");
    while (roundsTexts.next()) |roundText| {
        // std.debug.print("parsing GAME {s}\n", .{roundText});
        var idAndGame = try parseGame(roundText);
        var gameId = idAndGame[0];
        var game = idAndGame[1];
        if (!games.contains(gameId)) {
            try games.put(gameId, game);
        } else {
            std.debug.print("GAME {d} already exists!!!\n", .{gameId});
        }
    }

    var sumOfPossible: u64 = 0;
    var gamesIter = games.iterator();
    while (gamesIter.next()) |game| {
        const id = game.key_ptr.*;
        var possible = true;
        const rounds = game.value_ptr.*.rounds;
        for (rounds.items) |round| {
            var colorsIter = round.countsByColor.iterator();
            while (colorsIter.next()) |color| {
                var count = color.value_ptr.*;
                var max = maxByColor.get(color.key_ptr.*).?;
                if (count > max) {
                    possible = false;
                    break;
                }
            }
        }
        if (possible) {
            sumOfPossible += id;
        }
    }

    std.debug.print("sum of possible: {d}\n", .{sumOfPossible});

}