const std = @import("std");

const example_input =
    \\.......S.......
    \\...............
    \\.......^.......
    \\...............
    \\......^.^......
    \\...............
    \\.....^.^.^.....
    \\...............
    \\....^.^...^....
    \\...............
    \\...^.^...^.^...
    \\...............
    \\..^...^.....^..
    \\...............
    \\.^.^.^.^.^...^.
    \\...............
;

const FixedLineLengthBuffer = struct {
    line_length: usize,
    total_lines: usize,
    text: []const u8,

    pub fn init(text: []const u8) !@This() {
        var count = std.mem.count(u8, text, "\n");
        if (text[text.len - 1] != '\n') {
            count += 1;
        }
        const line_length = std.mem.indexOfScalar(u8, text, '\n') orelse return error.NoNewlineFound;

        return .{ .line_length = line_length, .total_lines = count, .text = text };
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

const Coord = struct { x: usize, y: usize };
const CoordSet = std.AutoArrayHashMap(Coord, void);
const CoordCount = std.AutoArrayHashMap(Coord, usize);

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

const inputfile = @embedFile("input");

fn recur(map: FixedLineLengthBuffer, x: usize, initial_y: usize, visited_splits: *CoordSet) !void {
    var y = initial_y;
    var c = map.get(y, x);
    while (c == '.') {
        y += 1;
        c = map.get(y, x);
    }
    if (c == null) {
        return;
    }

    const coord = Coord{ .x = x, .y = y };

    if (visited_splits.contains(coord)) {
        return;
    }

    try visited_splits.put(coord, {});

    try recur(map, x - 1, y, visited_splits);
    try recur(map, x + 1, y, visited_splits);
}

fn recur_count(map: FixedLineLengthBuffer, x: usize, initial_y: usize, cache: *CoordCount) !usize {
    var y = initial_y;
    var c = map.get(y, x);
    while (c == '.') {
        y += 1;
        c = map.get(y, x);
    }
    if (c == null) {
        return 1;
    }

    const coord = Coord{ .x = x, .y = y };

    if (cache.get(coord)) |v| {
        return v;
    }

    var sum: usize = 0;

    sum += try recur_count(map, x - 1, y, cache);
    sum += try recur_count(map, x + 1, y, cache);

    try cache.put(coord, sum);

    return sum;
}

fn run_part1(input: anytype, alloc: std.mem.Allocator) !usize {
    const map: FixedLineLengthBuffer = try .init(input);
    const start = std.mem.indexOfScalar(u8, input, 'S') orelse return error.NoStartPos;
    var split_coords: CoordSet = .init(alloc);

    try recur(map, start, 0, &split_coords);

    return split_coords.count();
}

fn run_part2(input: anytype, alloc: std.mem.Allocator) !usize {
    const map: FixedLineLengthBuffer = try .init(input);
    const start = std.mem.indexOfScalar(u8, input, 'S') orelse return error.NoStartPos;

    var cache: CoordCount = .init(alloc);

    return recur_count(map, start, 0, &cache);
}

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    const p1 = try run_part1(inputfile, alloc);
    const p2 = try run_part2(inputfile, alloc);

    std.debug.print("Part 1: {d}\n", .{p1});
    std.debug.print("Part 2: {d}\n", .{p2});
}

test "input1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(21, run_part1(example_input, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(40, run_part2(example_input, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(1622, run_part1(inputfile, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(55647141923, run_part2(inputfile, alloc));
}
