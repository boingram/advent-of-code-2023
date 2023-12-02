const std = @import("std");

const day = @import("day2.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try day.run(allocator);
}
