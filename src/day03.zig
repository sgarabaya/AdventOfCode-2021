const std = @import("std");
const Allocator = std.mem.Allocator;
const print = std.debug.print;
const util = @import("./util.zig");

const data = @embedFile("../data/day03.txt");

//Calculate the amount of lines in comptime.
const lineCount = comptime {
    @setEvalBranchQuota(28000);
    return util.countScalar(u8, data, '\n') + 1;
};

fn part1() !void {
    var tokenizer = std.mem.tokenize(data, "\r\n");

    var oneCount = [_]u16{0} ** 12;
    var zeroCount = [_]u16{0} ** 12;
    while (tokenizer.next()) |line| {
        for (line) |bit, i| {
            if (bit == '1') {
                oneCount[i] += 1;
            } else {
                zeroCount[i] += 1;
            }
        }
    }

    var gamma: u32 = 0;
    var epsilon: u32 = 0;

    var i: u32 = 0;
    while (i < 12) : (i += 1) {
        gamma <<= 1;
        epsilon <<= 1;

        if (oneCount[i] > zeroCount[i]) {
            gamma |= 1;
        } else {
            epsilon |= 1;
        }
    }

    print("Part1:\n\tγ = {d}\n\tε = {d}\n\tε × γ = {d}\n", .{ gamma, epsilon, gamma * epsilon });
}

fn countSelected1Bits(lines: [][]const u8, availables: []bool, position: usize) usize {
    var count: usize = 0;
    var i: usize = 0;
    while (i < availables.len) : (i += 1) {
        if (availables[i]) {
            if (lines[i][position] == '1')
                count += 1;
        }
    }

    return count;
}

fn part2() !void {
    var tokenizer = std.mem.tokenize(data, "\r\n");
    var lines: [lineCount][]const u8 = undefined;

    //Block to limit the scope of lineIndex
    {
        var lineIndex: usize = 0;
        while (tokenizer.next()) |line| {
            lines[lineIndex] = line;
            lineIndex += 1;
        }
    }

    var oxygenRatings: [lineCount]bool = undefined;
    var co2scrubberRatings: [lineCount]bool = undefined;

    //Initialize both sets to true
    {
        var i: usize = 0;
        while (i < lineCount) : (i += 1) {
            oxygenRatings[i] = true;
            co2scrubberRatings[i] = true;
        }
    }

    //Calculate oxygen ratings
    {
        var i: usize = 0;
        while (i < 12) : (i += 1) {
            const oxygenRatingsCount = util.countScalar(bool, &oxygenRatings, true);
            const co2scrubberRatingsCount = util.countScalar(bool, &co2scrubberRatings, true);

            if (oxygenRatingsCount > 1 or co2scrubberRatingsCount > 1) {
                const oxygen1BitsCount = countSelected1Bits(&lines, &oxygenRatings, i);
                const bestOxygenBit: u8 = if (oxygen1BitsCount >= (oxygenRatingsCount - oxygen1BitsCount)) '1' else '0';

                const co21BitsCount = countSelected1Bits(&lines, &co2scrubberRatings, i);
                const bestCO2Bit: u8 = if (co21BitsCount >= (co2scrubberRatingsCount - co21BitsCount)) '0' else '1';

                for (lines) |line, lineIndex| {
                    const c = line[i];

                    if (oxygenRatingsCount > 1 and oxygenRatings[lineIndex]) {
                        if (c != bestOxygenBit)
                            oxygenRatings[lineIndex] = false;
                    }
                    if (co2scrubberRatingsCount > 1 and co2scrubberRatings[lineIndex]) {
                        if (c != bestCO2Bit)
                            co2scrubberRatings[lineIndex] = false;
                    }
                }
            }
        }
    }

    print("\nPart2:\n", .{});

    var bestOxygenRating: u32 = 0;
    var bestCO2Rating: u32 = 0;

    for (oxygenRatings) |value, index| {
        if (value) {
            bestOxygenRating = try std.fmt.parseUnsigned(u32, lines[index], 2);
            print("\tBest Oxygen {s} => {d}\n", .{ lines[index], bestOxygenRating });
        }
    }
    for (co2scrubberRatings) |value, index| {
        if (value) {
            bestCO2Rating = try std.fmt.parseUnsigned(u32, lines[index], 2);
            print("\tBest CO2 Scrubber {s} => {d}\n", .{ lines[index], bestCO2Rating });
        }
    }

    print("\tResulting value: {d}\n", .{bestOxygenRating * bestCO2Rating});
}

pub fn main() !void {
    try part1();
    try part2();
}
