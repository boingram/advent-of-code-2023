const std = @import("std");

const Allocator = std.mem.Allocator;
const io = @import("io.zig");
const Trie = @import("trie.zig").Trie;

const ProcessingState = enum {
    Prelude,
    Score,
    Color,

    fn next(self: ProcessingState) ProcessingState {
        return switch (self) {
            .Prelude => .Score,
            .Score => .Color,
            .Color => .Score,
        };
    }
};

const Color = enum {
    red,
    green,
    blue,
};

pub fn run(allocator: Allocator) !void {
    const lines = try io.readFile(allocator, "input/day2.txt");
    defer lines.deinit();

    var trie = Trie.new(allocator);
    try trie.insert("red");
    try trie.insert("green");
    try trie.insert("blue");

    var powerSum: usize = 0;

    for (lines.items) |line| {
        var processing = ProcessingState.Prelude;
        var acc: usize = 0;
        var i: usize = 5;

        var maxRed: usize = 1;
        var maxGreen: usize = 1;
        var maxBlue: usize = 1;

        while (i < line.len) {
            switch (processing) {
                .Prelude => {
                    if (line[i] == 58) { // :
                        i += 2;
                        processing = processing.next();
                    } else {
                        i += 1;
                    }
                },
                .Score => {
                    if (line[i] >= 48 and line[i] <= 57) { // digit
                        const n = try std.fmt.parseInt(u8, line[i .. i + 1], 10);
                        acc = acc * 10 + n;
                    } else if (acc != 0) { // if the accumulator isn't 0, we're done processing numbers
                        processing = processing.next();
                    }
                    i += 1;
                },
                .Color => {
                    if (trie.containsSubstring(line[i..])) |color| {
                        const c = std.meta.stringToEnum(Color, color).?;

                        const max = switch (c) {
                            .red => &maxRed,
                            .green => &maxGreen,
                            .blue => &maxBlue,
                        };
                        if (acc > max.*) {
                            max.* = acc;
                        }
                        i += color.len;
                    } else {
                        processing = processing.next();
                        acc = 0;
                        i += 1;
                    }
                },
            }
        }
        powerSum += (maxRed * maxGreen * maxBlue);
    }

    std.debug.print("answer {}", .{powerSum});
}
