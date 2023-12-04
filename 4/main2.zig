const std = @import("std");
const allocator = std.heap.page_allocator;

const print = std.debug.print;

// const input =
//     \\Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
//     \\Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
//     \\Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
//     \\Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
//     \\Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
//     \\Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
// ;
const input = @embedFile("input.txt");

fn sliceToNumber(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
        acc *= 10;
        acc += text[i] - '0';
    }
    return acc;
}

const Card = struct {
    id: usize,
    nWins: usize,
};

var cards = std.ArrayList(Card).init(allocator);
var cardsAwardedByCard = std.AutoHashMap(usize, usize).init(allocator);

fn findCardsAwardedByCard(cardId: usize) !usize {
    // print("findCardsAwardedByCard({d})\n", .{cardId});
    if (cardsAwardedByCard.contains(cardId)) {
        return cardsAwardedByCard.get(cardId).?;
    }
    var nCards = cards.items[cardId].nWins;
    for (cardId+1..cardId+nCards+1) |copyId| {
        nCards += try findCardsAwardedByCard(copyId);
    }
    try cardsAwardedByCard.put(cardId, nCards);
    return nCards;
}

pub fn main() !void {
    var nTotalCards: usize = 0;

    var rows = std.mem.splitSequence(u8, input, "\n");

    

    while (rows.next()) |row| {
        var cardAndNumbers = std.mem.splitSequence(u8, row, ":");
        var cardAndId = std.mem.splitSequence(u8, cardAndNumbers.next().?, " ");
        _ = cardAndId.next();
        var cardId = sliceToNumber(cardAndId.next().?);
        
        var winningNumsAndNums = std.mem.splitSequence(u8, cardAndNumbers.next().?, "|");
        var winningNumsTexts = std.mem.splitSequence(u8, winningNumsAndNums.next().?, " ");
        var numsTexts = std.mem.splitSequence(u8, winningNumsAndNums.next().?, " ");
        var winningNums = std.AutoHashMap(usize, void).init(allocator);
        while (winningNumsTexts.next()) |numText| {
            if (numText.len == 0) {
                continue;
            }
            try winningNums.put(sliceToNumber(numText), {});
        }
        var nums = std.AutoHashMap(usize, void).init(allocator);
        while (numsTexts.next()) |numText| {
            if (numText.len == 0) {
                continue;
            }
            try nums.put(sliceToNumber(numText), {});
        }

        var winningIter = winningNums.keyIterator();
        var nWinning: usize = 0;
        while (winningIter.next()) |winning| {
            if (nums.contains(winning.*)) {
                // print("{d} ", .{winning.*});
                nWinning += 1;
            }
        }
        // print("\n", .{});
        print("Card {d}: {d}\n", .{cardId, nWinning});
        try cards.append(Card{ .id = cardId, .nWins = nWinning });
    }

    // var cardsAwardedByCard = std.AutoHashMap(usize, usize).init(allocator);
    // _ = cardsAwardedByCard;
    nTotalCards += cards.items.len;
    for (0..cards.items.len) |i| {
        nTotalCards += try findCardsAwardedByCard(i);
    }

    print("nTotalCards = {d}", .{nTotalCards});
}
