const std = @import("std");

const Allocator = std.mem.Allocator;
const AutoHashMap = std.AutoHashMap;

pub const Trie = struct {
    allocator: Allocator,
    children: AutoHashMap(u8, Trie),
    terminal: bool,

    pub fn new(allocator: Allocator) Trie {
        const children = AutoHashMap(u8, Trie).init(allocator);
        const trie = Trie{ .allocator = allocator, .children = children, .terminal = false };
        return trie;
    }

    pub fn insert(self: *Trie, key: []const u8) !void {
        var child = try self.getChild(key[0]);

        if (key.len > 1) {
            try child.insert(key[1..]);
        } else {
            child.terminal = true;
        }
    }

    fn getChild(self: *Trie, key: u8) !*Trie {
        const child = try self.children.getOrPut(key);
        if (!child.found_existing) {
            const trie = Trie.new(self.allocator);
            child.value_ptr.* = trie;
        }

        return child.value_ptr;
    }

    pub fn contains(trie: Trie, word: []const u8) bool {
        var node = trie;
        for (word) |c| {
            if (node.children.get(c)) |v| {
                node = v;
            } else {
                return false;
            }
        }
        return node.terminal;
    }

    pub fn containsSubstring(self: Trie, word: []const u8) ?[]const u8 {
        var node = self;
        for (word, 0..) |c, i| {
            if (node.terminal) {
                return word[0..i];
            }
            if (node.children.get(c)) |v| {
                node = v;
            } else {
                return null;
            }
        }
        if (node.terminal) {
            return word;
        } else {
            return null;
        }
    }

    pub fn deinit(self: *Trie) void {
        var iter = self.children.valueIterator();
        while (iter.next()) |child| {
            child.*.deinit();
        }

        self.children.deinit();
    }
};

const expect = std.testing.expect;

test "trie works" {
    var trie = Trie.new(std.testing.allocator);
    defer trie.deinit();

    const word1 = "test";
    const word2 = "tent";
    const word3 = "taco";

    try trie.insert(word1);
    try trie.insert(word2);
    try trie.insert(word3);

    try expect(trie.contains(word1));
    try expect(trie.contains(word2));
    try expect(trie.contains(word3));
    try expect(!trie.contains("help"));
}

test "find word" {
    var trie = Trie.new(std.testing.allocator);
    defer trie.deinit();

    try trie.insert("five");

    const word = trie.containsSubstring("fivetczxxvjrrq").?;
    try std.testing.expectEqualStrings(word, "five");
}
