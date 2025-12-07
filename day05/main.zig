const std = @import("std");

const example_input =
    \\3-5
    \\10-14
    \\16-20
    \\12-18
    \\
    \\1
    \\5
    \\8
    \\11
    \\17
    \\32
;

const inputfile = @embedFile("input");

fn run_part1(input: anytype, alloc: std.mem.Allocator) !usize {
    var ranges = std.array_list.Managed(struct { usize, usize }).init(alloc);
    var groupIter = std.mem.tokenizeSequence(u8, input, "\n\n");
    var count: usize = 0;

    const rangesInput = groupIter.next().?;
    // ranges are inclusive!

    var rangesIter = std.mem.tokenizeScalar(u8, rangesInput, '\n');

    while (rangesIter.next()) |range| {
        const dashPos = std.mem.indexOfScalar(u8, range, '-').?;
        const a = try std.fmt.parseInt(usize, range[0..dashPos], 10);
        const b = try std.fmt.parseInt(usize, range[dashPos + 1 ..], 10);
        try ranges.append(.{ a, b });
    }

    const items = groupIter.next().?;

    var itemsIter = std.mem.tokenizeScalar(u8, items, '\n');

    while (itemsIter.next()) |itemStr| {
        const item = try std.fmt.parseInt(usize, itemStr, 10);

        for (ranges.items) |r| {
            const from = r.@"0";
            const to = r.@"1";

            if (item >= from and item <= to) {
                count += 1;
                break;
            }
        }
    }

    return count;
}

fn run_part2(input: anytype, alloc: std.mem.Allocator) !usize {
    var ranges = std.array_list.Managed(struct { a: usize, b: usize }).init(alloc);
    var groupIter = std.mem.tokenizeSequence(u8, input, "\n\n");
    var sum: usize = 0;

    const rangesInput = groupIter.next().?;
    // ranges are inclusive!

    var rangesIter = std.mem.tokenizeScalar(u8, rangesInput, '\n');

    while (rangesIter.next()) |range| {
        const dashPos = std.mem.indexOfScalar(u8, range, '-').?;
        const a = try std.fmt.parseInt(usize, range[0..dashPos], 10);
        const b = try std.fmt.parseInt(usize, range[dashPos + 1 ..], 10);
        try ranges.append(.{ .a = a, .b = b });
    }

    var needs_recalc = true;

    while (needs_recalc) {
        needs_recalc = false;
        validate: for (0..ranges.items.len) |i| {
            for (i + 1..ranges.items.len) |j| {
                const r1 = ranges.items[i];
                const r2 = ranges.items[j];

                if (@max(r1.a, r2.a) <= @min(r1.b, r2.b)) {
                    ranges.items[i].a = @min(r1.a, r2.a);
                    ranges.items[i].b = @max(r1.b, r2.b);
                    needs_recalc = true;
                    _ = ranges.swapRemove(j);
                    break :validate;
                }
            }
        }
    }

    for (ranges.items) |range| {
        sum += range.b - range.a + 1;
    }

    return sum;
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
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(3, run_part1(example_input, alloc));
}

test "input2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(14, run_part2(example_input, alloc));
}

test "star1" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(607, run_part1(inputfile, alloc));
}

test "star2" {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_allocator.deinit();
    const alloc = arena_allocator.allocator();
    try std.testing.expectEqual(342433357244012, run_part2(inputfile, alloc));
}
