const std = @import("std");

//Extremely simple, static ring buffer with no heap allocation.
pub fn RingBuffer(comptime T: type, comptime capacity: usize) type {
    const RingBufferError = error{IndexOutOfbounds};

    return struct {
        const Self = @This();

        index: usize = 0,
        isFull: bool = false,
        buffer: [capacity]T = undefined,

        pub fn push(self: *Self, value: T) void {
            self.buffer[self.index] = value;

            const newIndex = self.index + 1;

            self.index = if (newIndex < capacity) newIndex else 0;

            if (newIndex == capacity)
                self.isFull = true;
        }

        pub fn get(self: *Self, index: usize) !T {
            if (index >= 0 and index < capacity) {
                const internalIndex = try std.math.mod(usize, self.index + index, capacity);
                return self.buffer[internalIndex];
            } else {
                return RingBufferError.IndexOutOfbounds;
            }
        }
    };
}

pub const SliceOps = struct {
    pub fn sum(comptime T: type, slice: []T) usize {
        var s: usize = 0;

        for (slice) |el|
            s += el;

        return s;
    }
};

pub fn countScalar(comptime T: type, buffer: []const T, value: T) usize {
    var i: usize = 0;
    for (buffer) |c| {
        if (c == value)
            i += 1;
    }

    return i;
}
