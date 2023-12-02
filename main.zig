const std = @import("std");

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;
const Trie = @import("trie.zig").Trie;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    try day1(allocator);
}

fn day1(allocator: Allocator) !void {
    const lines = try readFile(allocator, "input/day1.txt");
    defer lines.deinit();

    var wordsToNums = try getWordsToNums(allocator);
    defer wordsToNums.deinit();

    var trieNode = Trie.new(allocator);
    defer trieNode.deinit();

    var numWordIter = wordsToNums.keyIterator();
    while (numWordIter.next()) |numWord| {
        try trieNode.insert(numWord.*);
    }

    var sum: usize = 0;

    for (lines.items) |line| {
        var a: ?usize = null;
        var b: ?usize = null;

        var i: usize = 0;
        while (i < line.len) {
            if (line[i] >= 48 and line[i] <= 57) {
                const n = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
                if (a == null) {
                    a = n;
                } else {
                    b = n;
                }
            } else if (trieNode.containsSubstring(line[i..])) |sub| {
                const n = wordsToNums.get(sub).?;
                if (a == null) {
                    a = n;
                } else {
                    b = n;
                }
            }
            i += 1;
        }

        if (b == null) {
            sum += a.? * 10 + a.?;
        } else {
            sum += a.? * 10 + b.?;
        }
    }

    std.debug.print("sum = {d}\n", .{sum});
}

fn readFile(allocator: Allocator, comptime name: []const u8) !ArrayList([]const u8) {
    const file = @embedFile(name);

    var lines = ArrayList([]const u8).init(allocator);
    var iter = std.mem.tokenize(u8, file, "\n");
    while (iter.next()) |line| {
        try lines.append(line);
    }
    return lines;
}

fn getWordsToNums(allocator: Allocator) !StringHashMap(usize) {
    const numbers = [_][]const u8{
        "one",
        "two",
        "three",
        "four",
        "five",
        "six",
        "seven",
        "eight",
        "nine",
    };

    var map = StringHashMap(usize).init(allocator);
    for (numbers, 1..) |n, i| {
        try map.put(n, i);
    }

    return map;
}
