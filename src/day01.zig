const std = @import("std");
const util = @import("./util.zig");
const print = std.debug.print;

const data = @embedFile("../data/day01.txt");

const NumberIterator = struct {
    iterator: std.mem.TokenIterator,

    pub fn init(buffer: []const u8) NumberIterator {
        return .{ .iterator = std.mem.tokenize(buffer, "\r\n") };
    }

    fn next(self: *NumberIterator) !?u32 {
        var line = self.iterator.next();

        if (line) |l| {
            return try std.fmt.parseUnsigned(u32, l, 10);
        } else return null;
    }
};

fn part1() !void {
    var iterator = NumberIterator.init(data);

    //This will panic if the file is empty. That's okay.
    var previousNumber: u32 = (try iterator.next()).?;

    var increases: u32 = 0;

    while (try iterator.next()) |number| {
        if (number > previousNumber)
            increases += 1;

        previousNumber = number;
    }

    print("Part1: Found {d} increases.\n", .{increases});
}

fn part2() !void {
    //We only need a sliding window of 3 values
    var buffer = util.RingBuffer(u32, 3){};

    var iterator = NumberIterator.init(data);

    //Fill the ring buffer.
    buffer.push((try iterator.next()).?);
    buffer.push((try iterator.next()).?);
    buffer.push((try iterator.next()).?);

    //Precalculate the initial value
    var previousSum: usize = util.SliceOps.sum(u32, &buffer.buffer);

    var increases: usize = 0;
    while (try iterator.next()) |number| {
        buffer.push(number);

        const newSum = util.SliceOps.sum(u32, &buffer.buffer);

        if (newSum > previousSum)
            increases += 1;

        previousSum = newSum;
    }

    print("Part2: Found {d} increases.\n", .{increases});
}

pub fn main() !void {
    try part1();
    try part2();
}
