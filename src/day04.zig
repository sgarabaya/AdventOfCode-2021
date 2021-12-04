const std = @import("std");
const print = std.debug.print;
const util = @import("./util.zig");

const NumberCount = 100;
const BoardCount = 100;
const data = @embedFile("../data/day04.txt");

const BingoCell = struct {
    number: u8,
    marked: bool = false,
};

const Board = struct {
    cells: [5][5]BingoCell = undefined,

    fn mark(self: *Board, number: u8) bool {
        var x: u8 = 0;
        while (x < 5) : (x += 1) {
            var y: u8 = 0;
            while (y < 5) : (y += 1) {
                const cell = &(self.cells[x][y]);
                if (cell.number == number) {
                    cell.marked = true;
                    return true;
                }
            }
        }

        return false;
    }

    fn checkIfWon(self: Board) bool {
        var i: u8 = 0;
        while (i < 5) : (i += 1) {
            const won = self.checkVertically(i) or self.checkHorizontally(i);

            if (won)
                return won;
        }

        return false;
    }

    fn checkVertically(self: Board, column: u8) bool {
        var y: u8 = 0;
        while (y < 5) : (y += 1) {
            if (!self.cells[column][y].marked)
                return false;
        }

        //If we didn't find an unmarked cell, we won!
        return true;
    }

    fn checkHorizontally(self: Board, row: u8) bool {
        var x: u8 = 0;
        while (x < 5) : (x += 1) {
            if (!self.cells[x][row].marked)
                return false;
        }

        //If we didn't find an unmarked cell, we won!
        return true;
    }

    fn calculateScore(self: Board) u16 {
        var score: u16 = 0;

        var x: u8 = 0;
        while (x < 5) : (x += 1) {
            var y: u8 = 0;
            while (y < 5) : (y += 1) {
                if (!self.cells[x][y].marked)
                    score += self.cells[x][y].number;
            }
        }

        return score;
    }

    fn print(self: Board) void {
        var x: u8 = 0;
        while (x < 5) : (x += 1) {
            var y: u8 = 0;
            while (y < 5) : (y += 1) {
                const cell = &(self.cells[x][y]);
                if (cell.marked) {
                    print("[{d}] ", .{cell.number});
                } else {
                    print("{d} ", .{cell.number});
                }
            }
            print("\n", .{});
        }
    }
};

fn parseNumbers(line: []const u8) ![NumberCount]u8 {
    var lineTokenizer = std.mem.tokenize(line, ",");
    var numbers: [NumberCount]u8 = undefined;

    var position: u8 = 0;
    while (lineTokenizer.next()) |n| {
        numbers[position] = try std.fmt.parseUnsigned(u8, n, 10);
        position += 1;
    }

    return numbers;
}

fn parseBingoBoard(tokenizer: *std.mem.TokenIterator) !?Board {
    if (tokenizer.index == tokenizer.buffer.len)
        return null;

    var board: Board = .{};

    var x: u8 = 0;
    while (x < 5) : (x += 1) {
        var line = tokenizer.next().?;
        var numbers = std.mem.tokenize(line, " ");
        var y: u8 = 0;
        while (y < 5) : (y += 1) {
            const n = numbers.next().?;
            const cellNumber = try std.fmt.parseUnsigned(u8, n, 10);

            board.cells[x][y].number = cellNumber;
            board.cells[x][y].marked = false;
        }
    }

    return board;
}

const WinPair = util.Pair(*Board, u8);

fn findWinningBoard(numbers: [NumberCount]u8, boards: []Board) ?WinPair {
    var numberIndex: u8 = 0;

    while (numberIndex < numbers.len) : (numberIndex += 1) {
        var n = numbers[numberIndex];
        var boardIndex: u8 = 0;
        while (boardIndex < boards.len) : (boardIndex += 1) {
            var board = &boards[boardIndex];

            if (board.mark(n))
                if (board.checkIfWon())
                    return WinPair.init(board, n);
        }
    }

    return null;
}

fn findLastWinningBoard(numbers: [NumberCount]u8, boards: []Board) ?WinPair {
    var lastBoard: ?WinPair = null;

    var availableBoards: [BoardCount]bool = undefined;
    {
        var boardIndex: u8 = 0;
        while (boardIndex < BoardCount) : (boardIndex += 1)
            availableBoards[boardIndex] = true;
    }

    var numberIndex: u8 = 0;
    while (numberIndex < NumberCount) : (numberIndex += 1) {
        const n = numbers[numberIndex];
        var boardIndex: u8 = 0;
        while (boardIndex < BoardCount) : (boardIndex += 1) {
            if (availableBoards[boardIndex]) {
                var board = &boards[boardIndex];
                if (board.mark(n) and board.checkIfWon()) {
                    lastBoard = WinPair.init(board, n);
                    availableBoards[boardIndex] = false;
                }
            }
        }
    }

    return lastBoard;
}

fn part1() !void {
    var tokenizer = std.mem.tokenize(data, "\r\n");
    const numbers = try parseNumbers(tokenizer.next().?);

    var boards: [NumberCount]Board = undefined;
    {
        var boardIndex: u8 = 0;
        while (boardIndex < NumberCount) : (boardIndex += 1) {
            if (try parseBingoBoard(&tokenizer)) |board|
                boards[boardIndex] = board;
        }
    }

    print("Part 1:\n", .{});
    if (findWinningBoard(numbers, &boards)) |winning| {
        const winningBoard = winning.a;
        const n = winning.b;
        const score = winningBoard.calculateScore();

        print("Board won at number {d} with score: {d}\n\n", .{ n, score });
        print("The result is {d}\n", .{n * score});
    } else {
        print("No winning board?\n", .{});
    }
}

fn part2() !void {
    var tokenizer = std.mem.tokenize(data, "\r\n");
    const numbers = try parseNumbers(tokenizer.next().?);

    var boards: [100]Board = undefined;
    var boardIndex: u8 = 0;
    while (boardIndex < 100) : (boardIndex += 1) {
        if (try parseBingoBoard(&tokenizer)) |board|
            boards[boardIndex] = board;
    }

    print("\nPart 2:\n", .{});
    if (findLastWinningBoard(numbers, &boards)) |winning| {
        const winningBoard = winning.a;
        const n = winning.b;
        const score = winningBoard.calculateScore();

        print("Last board to win, won at number {d} with score: {d}\n\n", .{ n, score });
        print("The result is {d}\n", .{n * score});
    } else {
        print("No winning board?\n", .{});
    }
}

pub fn main() !void {
    try part1();
    try part2();
}
