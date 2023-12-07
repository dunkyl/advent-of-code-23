const std = @import("std");
const allocator = std.heap.page_allocator;
const split = std.mem.splitSequence;

const print = std.debug.print;

const inputEx = 
    \\32T3K 765
    \\T55J5 684
    \\KK677 28
    \\KTJJT 220
    \\QQQJA 483
;
const input = @embedFile("input.txt");

const cards = "23456789TJQKA";

fn index(card: u8) usize {
    for (0..cards.len) |i| {
        if (cards[i] == card) return i;
    }
    return 0;
}

fn countCards(hand: []const u8) struct { [13]usize, usize } {
    var counts = [13]usize{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    var tiebreak: usize = 0;
    for (hand) |card| {
        var score = index(card);
        tiebreak = tiebreak*13 + score;
        counts[score] += 1;
    }
    return .{counts, tiebreak};
}

fn scoreHand(hand: []const u8) usize {
    var countsAndTie = countCards(hand);
    const tie = countsAndTie[1];
    var has3 = false;
    var has2 = false;
    for (countsAndTie[0]) |count| {
        switch (count) {
            5 => return 6_000_000+tie,
            4 => return 5_000_000+tie,
            // full house or 3 of a kind
            3 => {
                if (has2) return 4_000_000+tie // full house
                else { has3 = true; } //...
            },
            2 => {
                if (has3) return 4_000_000+tie // full house (again)
                else if (has2) return 2_000_000+tie // 2 pair
                else { has2 = true; } //...
            },
            else => {},
        }
    }
    if (has3) return 3_000_000+tie; // three of a kind
    if (has2) return 1_000_000+tie; // one pair
    return tie; // high card
}

fn parseUsize(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
        if (text[i] > '9' or text[i] < '0') break;
        acc = 10*acc + text[i] - '0';
    }
    return acc;
}

const HandValue = struct {
    score: usize,
    bid: usize,
};

fn compareHand(context: void, lhs: HandValue, rhs: HandValue) bool {
    _ = context;
    return lhs.score < rhs.score;
}

pub fn main() !void {

    var lines = split(u8, input, "\n");

    var handValues = std.ArrayList(HandValue).init(allocator);

    while (lines.next()) |line| {
        var parts = split(u8, line, " ");
        var hand = parts.next().?;
        var bid = parseUsize(parts.next().?);
        // print("{s} score {any}\n", .{hand, scoreHand(hand)});
        try handValues.append(.{.score = scoreHand(hand), .bid = bid});
    }

    std.mem.sort(HandValue, handValues.items, {}, compareHand);

    var total: usize = 0;
    for (0..handValues.items.len) |i| {
        var hand = handValues.items[i];
        // print("{d} - {d}\n", .{i+1, hand.bid});
        total += hand.bid * (i + 1);
    }

    print("Total: {d}\n", .{total});

}