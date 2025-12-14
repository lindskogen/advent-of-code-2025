const std = @import("std");

const example_input =
    \\7,1
    \\11,1
    \\11,7
    \\9,7
    \\9,5
    \\2,5
    \\2,3
    \\7,3
;

const inputfile = @embedFile("input");

const Point = struct { x: isize, y: isize };
const Line = struct { p1: Point, p2: Point };

fn rect_points(rect: *[4]Point, a: Point, b: Point) void {
    const x1 = @min(a.x, b.x);
    const x2 = @max(a.x, b.x);
    const y1 = @min(a.y, b.y);
    const y2 = @max(a.y, b.y);

    rect[0].x = x1;
    rect[0].y = y1;

    rect[1].x = x2;
    rect[1].y = y1;

    rect[2].x = x2;
    rect[2].y = y2;

    rect[3].x = x1;
    rect[3].y = y2;
}

fn calculate_area(p1: Point, p2: Point) usize {
    const width = @abs(p1.x - p2.x) + 1;
    const height = @abs(p1.y - p2.y) + 1;

    return width * height;
}

fn run_part1(input: anytype, alloc: std.mem.Allocator) !usize {
    var nums: std.ArrayList(Point) = .empty;
    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');

    while (lineIter.next()) |line| {
        var coordsIter = std.mem.tokenizeScalar(u8, line, ',');

        const x = try std.fmt.parseInt(isize, coordsIter.next().?, 10);
        const y = try std.fmt.parseInt(isize, coordsIter.next().?, 10);

        try nums.append(alloc, .{ .x = x, .y = y });
    }

    const len = nums.items.len;

    var max: usize = 0;

    for (0..len) |i| {
        for (i + 1..len) |j| {
            const area = calculate_area(nums.items[i], nums.items[j]);
            if (area > max) {
                max = area;
            }
        }
    }

    return max;
}

const Result = struct { size: usize, p1: Point, p2: Point };

fn run_part2(input: anytype, alloc: std.mem.Allocator) !usize {
    var nums: std.ArrayList(Point) = .empty;
    var edges: std.ArrayList(Line) = .empty;
    var sizes: std.ArrayList(Result) = .empty;
    var lineIter = std.mem.tokenizeScalar(u8, input, '\n');

    while (lineIter.next()) |line| {
        var coordsIter = std.mem.tokenizeScalar(u8, line, ',');

        const x = try std.fmt.parseInt(isize, coordsIter.next().?, 10);
        const y = try std.fmt.parseInt(isize, coordsIter.next().?, 10);

        try nums.append(alloc, .{ .x = x, .y = y });
    }

    for (0..nums.items.len) |i| {
        try edges.append(alloc, Line{ .p1 = nums.items[i], .p2 = nums.items[@mod(i + 1, nums.items.len)] });
        const a = nums.items[i];

        for (i + 1..nums.items.len) |j| {
            const b = nums.items[j];
            const x1 = @min(a.x, b.x);
            const x2 = @max(a.x, b.x);
            const y1 = @min(a.y, b.y);
            const y2 = @max(a.y, b.y);

            try sizes.append(alloc, .{ .size = calculate_area(a, b), .p1 = .{ .x = x1, .y = y1 }, .p2 = .{ .x = x2, .y = y2 } });
        }
    }

    std.mem.sort(Result, sizes.items, {}, struct {
        fn lessThan(_: void, a: Result, b: Result) bool {
            return a.size > b.size;
        }
    }.lessThan);

    for (sizes.items) |res| {
        std.debug.print("{any}\n", .{res});
    }

    const max: usize = 0;

    outer: for (sizes.items) |res| {
        const x1 = @min(res.p1.x, res.p2.x);
        const y1 = @min(res.p1.y, res.p2.y);
        const x2 = @max(res.p1.x, res.p2.x);
        const y2 = @max(res.p1.y, res.p2.y);

        for (edges.items) |edge| {
            const x3 = edge.p1.x;
            const y3 = edge.p1.y;
            const x4 = edge.p2.x;
            const y4 = edge.p2.y;

            if (x4 > x1 and x3 < x2 and y4 > y1 and y3 < y2) {
                continue :outer;
            }
        }

        std.debug.print("{any}\n", .{res});
        return res.size;
    }

    return max;
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
    try std.testing.expectEqual(50, run_part1(example_input, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(24, run_part2(example_input, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(4748985168, run_part1(inputfile, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.testing.allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(1550760868, run_part2(inputfile, alloc));
}
