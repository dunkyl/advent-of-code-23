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

const cards = "J23456789TQKA";

fn index(card: u8) usize {
    for (0..cards.len) |i| {
        if (cards[i] == card) return i;
    }
    return 0;
}

fn countCards(hand: []const u8) struct { [13]usize, usize } {
    var counts = [13]usize{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
    var tiebreak: usize = 0;
    for (hand) |card| {
        var score = index(card);
        tiebreak = tiebreak * 13 + score;
        counts[score] += 1;
    }
    return .{ counts, tiebreak };
}

fn scoreHand(hand: []const u8) usize {
    var countsAndTie = countCards(hand);
    const tie = countsAndTie[1];
    const score = 0;
    _ = score;
    var has5 = false;
    var has4 = false;
    var has3 = false;
    var has2: usize = 0;
    var js = countsAndTie[0][0];
    for (countsAndTie[0][1..]) |count| {
        switch (count) {
            5 => has5 = true,
            4 => has4 = true,
            3 => has3 = true,
            2 => has2 += 1,
            else => {},
        }
    }
    if (has5 or (has4 and js == 1) or (has3 and js == 2) or (js >= 4) or (has2 == 1 and js == 3)) {
        return 6_000_000 + tie; // five of a kind
    }
    if (has4 or (has3 and js == 1) or (has2 == 1 and js == 2) or (js == 3)) {
        return 5_000_000 + tie; // four of a kind
    } 
    if ((has3 and has2 == 1) or (has2 == 2 and js == 1)) {
        return 4_000_000 + tie; // full house
    }
    if (has3 or (has2 == 1 and js == 1) or (js == 2)) {
        return 3_000_000 + tie; // three of a kind
    }
    if ((has2 == 2)) {
        return 2_000_000 + tie; // two pair
    }
    if ((has2 == 1) or (js == 1)) {
        return 1_000_000 + tie; // one pair
    }
    return tie;
}

fn parseUsize(text: []const u8) usize {
    var acc: usize = 0;
    for (0..text.len) |i| {
        if (text[i] > '9' or text[i] < '0') break;
        acc = 10 * acc + text[i] - '0';
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
        try handValues.append(.{ .score = scoreHand(hand), .bid = bid });
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
