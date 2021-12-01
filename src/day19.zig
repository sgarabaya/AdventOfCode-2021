const std = @import("std");
const Allocator = std.mem.Allocator;

fn part1(allocator: *Allocator) !void {}

fn part2(allocator: *Allocator) !void {}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    try part1(&gpa.allocator);
    try part2(&gpa.allocator);
}
