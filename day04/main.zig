const std = @import("std");

const test_input =
    \\..@@.@@@@.
    \\@@@.@.@.@@
    \\@@@@@.@.@@
    \\@.@@@@..@.
    \\@@.@@@@.@@
    \\.@@@@@@@.@
    \\.@.@.@.@@@
    \\@.@@@.@@@@
    \\.@@@@@@@@.
    \\@.@.@@@.@.
;

const inputfile = @embedFile("input");

const FixedLineLengthBuffer = struct {
    line_length: usize,
    total_lines: usize,
    text: []u8,

    pub fn init(text: []u8) !@This() {
        var count = std.mem.count(u8, text, "\n");
        if (text[text.len - 1] != '\n') {
            count += 1;
        }
        const line_length = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoNewlineFound;

        return .{ .line_length = line_length, .total_lines = count, .text = text };
    }

    pub fn replace(self: @This(), row: usize, col: usize, with: u8) !void {
        if (row < self.total_lines and col < self.line_length) {
            // Account for '\n' at end of line
            const index = row * (self.line_length + 1) + col;
            self.text[index] = with;
        } else {
            return error.OutOfBounds;
        }
    }

    pub fn replace_signed(self: @This(), row: isize, col: isize, with: u8) !void {
        if (row < 0 or col < 0) {
            return error.OutOfBounds;
        } else {
            return self.replace(@intCast(row), @intCast(col), with);
        }
    }

    pub fn replace_pos(self: @This(), coord: Coord, with: u8) !void {
        return self.replace_signed(coord.y, coord.x, with);
    }

    pub fn get_signed(self: @This(), row: isize, col: isize) ?u8 {
        if (row < 0 or col < 0) {
            return null;
        } else {
            return self.get(@intCast(row), @intCast(col));
        }
    }

    pub fn get(self: @This(), row: usize, col: usize) ?u8 {
        if (row < self.total_lines and col < self.line_length) {
            // Account for '\n' at end of line
            const index = row * (self.line_length + 1) + col;
            return self.text[index];
        }

        return null;
    }

    pub fn get_pos(self: @This(), pos: Coord) ?u8 {
        return self.get_signed(pos.y, pos.x);
    }

    pub fn len(self: @This()) usize {
        return self.total_lines;
    }

    pub fn line_len(self: @This()) usize {
        return self.line_length;
    }
};

const Coord = struct { x: isize, y: isize };
const CoordSet = std.AutoArrayHashMap(Coord, void);

fn move_unsafe(c: Coord, dir: Dir) Coord {
    switch (dir) {
        .North => {
            return .{ .x = c.x, .y = c.y - 1 };
        },
        .East => {
            return .{ .x = c.x + 1, .y = c.y };
        },
        .South => {
            return .{ .x = c.x, .y = c.y + 1 };
        },
        .West => {
            return .{ .x = c.x - 1, .y = c.y };
        },
    }
}

fn move_unsafe_diag(c: Coord, dir: DiagDirs) Coord {
    switch (dir) {
        .North => {
            return .{ .x = c.x, .y = c.y - 1 };
        },
        .East => {
            return .{ .x = c.x + 1, .y = c.y };
        },
        .South => {
            return .{ .x = c.x, .y = c.y + 1 };
        },
        .West => {
            return .{ .x = c.x - 1, .y = c.y };
        },
        .NorthWest => {
            return .{ .x = c.x - 1, .y = c.y - 1 };
        },
        .NorthEast => {
            return .{ .x = c.x + 1, .y = c.y - 1 };
        },
        .SouthWest => {
            return .{ .x = c.x - 1, .y = c.y + 1 };
        },
        .SouthEast => {
            return .{ .x = c.x + 1, .y = c.y + 1 };
        },
    }
}

fn move(c: Coord, dir: Dir, extent: usize) ?Coord {
    switch (dir) {
        .North => {
            if (c.y > 0) {
                return .{ .x = c.x, .y = c.y - 1 };
            }
        },
        .East => {
            if (c.x + 1 < extent) {
                return .{ .x = c.x + 1, .y = c.y };
            }
        },
        .South => {
            if (c.y + 1 < extent) {
                return .{ .x = c.x, .y = c.y + 1 };
            }
        },
        .West => {
            if (c.x > 0) {
                return .{ .x = c.x - 1, .y = c.y };
            }
        },
    }
    return null;
}

const Dir = enum { North, South, East, West };
const DiagDirs = enum { North, South, East, West, NorthWest, NorthEast, SouthWest, SouthEast };

const DIRS = [_]Dir{ .East, .North, .South, .West };
const DIAG_DIRS = [_]DiagDirs{ .East, .North, .South, .West, .NorthWest, .NorthEast, .SouthWest, .SouthEast };

fn run_part1(comptime input: anytype) !usize {
    var text: [input.len]u8 = undefined;
    @memmove(&text, input);
    const map: FixedLineLengthBuffer = try .init(&text);
    var total_count: usize = 0;

    for (0..map.len()) |y| {
        for (0..map.line_len()) |x| {
            const coord: Coord = .{ .x = @intCast(x), .y = @intCast(y) };
            if (map.get_pos(coord) == '@') {
                // check neighbors
                var count: usize = 0;
                for (DIAG_DIRS) |dir| {
                    const new_coord = move_unsafe_diag(coord, dir);
                    if (map.get_pos(new_coord) == '@') {
                        count += 1;
                    }
                }
                if (count < 4) {
                    total_count += 1;
                }
            }
        }
    }

    return total_count;
}

fn run_part2(comptime input: anytype) !usize {
    var text: [input.len]u8 = undefined;
    @memmove(&text, input);
    const map: FixedLineLengthBuffer = try .init(&text);

    var coords_remove_buffer: [140 * 140]Coord = undefined;
    var total_count: usize = 0;
    var coords_remove_buffer_index: usize = 1; // should be 0, but no do-while?

    while (coords_remove_buffer_index > 0) {
        coords_remove_buffer_index = 0;

        for (0..map.len()) |y| {
            for (0..map.line_len()) |x| {
                const coord: Coord = .{ .x = @intCast(x), .y = @intCast(y) };
                if (map.get_pos(coord) == '@') {
                    // check neighbors
                    var count: usize = 0;
                    for (DIAG_DIRS) |dir| {
                        const new_coord = move_unsafe_diag(coord, dir);
                        if (map.get_pos(new_coord) == '@') {
                            count += 1;
                        }
                    }
                    if (count < 4) {
                        coords_remove_buffer[coords_remove_buffer_index] = coord;
                        coords_remove_buffer_index += 1;
                        total_count += 1;
                    }
                }
            }
        }

        for (coords_remove_buffer[0..coords_remove_buffer_index]) |c| {
            try map.replace_pos(c, '.');
        }
    }

    return total_count;
}

pub fn main() !void {
    const p1 = try run_part1(inputfile);
    const p2 = try run_part2(inputfile);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    try std.testing.expectEqual(13, run_part1(test_input));
}

test "input2" {
    try std.testing.expectEqual(43, run_part2(test_input));
}

test "star1" {
    try std.testing.expectEqual(1602, run_part1(inputfile));
}

test "star2" {
    try std.testing.expectEqual(9518, run_part2(inputfile));
}
