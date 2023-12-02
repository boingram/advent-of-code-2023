const std = @import("std");

const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn readFile(allocator: Allocator, comptime name: []const u8) !ArrayList([]const u8) {
    const file = @embedFile(name);

    var lines = ArrayList([]const u8).init(allocator);
    var iter = std.mem.tokenize(u8, file, "\n");
    while (iter.next()) |line| {
        try lines.append(line);
    }
    return lines;
}
