const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const data = @embedFile("../data/day02.txt");

const Verb = enum {
    Forward,
    Down,
    Up,
};

const Command = struct {
    verb: Verb,
    amount: u32,

    pub fn from(line: []const u8) !Command {
        var splitter = std.mem.tokenize(line, " ");

        var verbString = splitter.next().?;
        var amountString = splitter.next().?;

        var verb = switch (verbString[0]) {
            'f' => Verb.Forward,
            'd' => Verb.Down,
            'u' => Verb.Up,
            else => @panic("Oops! Wrong verb?"),
        };

        var amount = try std.fmt.parseUnsigned(u32, amountString, 10);

        return Command{
            .verb = verb,
            .amount = amount,
        };
    }
};

fn part1() !void {
    var lineTokenizer = std.mem.tokenize(data, "\r\n");

    var horizontal: u32 = 0;
    var depth: u32 = 0;

    while (lineTokenizer.next()) |line| {
        var command = try Command.from(line);

        switch (command.verb) {
            .Forward => horizontal += command.amount,
            .Down => depth += command.amount,
            .Up => depth -= command.amount,
        }
    }

    print("Part1: Horizontal: {d}, vertical: {d} => Product: {d}\n", .{ horizontal, depth, horizontal * depth });
}

fn part2() !void {
    var lineTokenizer = std.mem.tokenize(data, "\r\n");

    var aim: u32 = 0;
    var horizontal: u32 = 0;
    var depth: u32 = 0;

    while (lineTokenizer.next()) |line| {
        var command = try Command.from(line);

        switch (command.verb) {
            .Forward => {
                horizontal += command.amount;
                depth += command.amount * aim;
            },
            .Down => aim += command.amount,
            .Up => aim -= command.amount,
        }
    }

    print("Part2: Horizontal: {d}, vertical: {d} => Product: {d}\n", .{ horizontal, depth, horizontal * depth });
}

pub fn main() !void {
    try part1();
    try part2();
}
